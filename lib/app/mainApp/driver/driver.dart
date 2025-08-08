import 'dart:async';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:hrms/app/mainApp/driver/add_package.dart';
import 'package:hrms/app/mainApp/driver/packageDetails.dart';
import 'package:hrms/app/uiComponent/custom_header.dart';
import 'package:hrms/appUtil/app_util_config.dart';
import 'package:hrms/appUtil/network_util.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:intl/intl.dart';

class Driver extends StatefulWidget {
  var scaffoldKey;
  var title;

  Driver({Key? key, required this.scaffoldKey, required this.title})
      : super(key: key);

  @override
  _DriverState createState() {
    return _DriverState();
  }
}

class _DriverState extends State<Driver> {
  NetworkUtil _networkUtil = NetworkUtil();
  Future<SharedPreferences> _prefs = SharedPreferences.getInstance();
  final GlobalKey<ScaffoldState> _scaffoldKey = new GlobalKey<ScaffoldState>();
  final GlobalKey<RefreshIndicatorState> _refreshIndicatorKey =
      new GlobalKey<RefreshIndicatorState>();
  DriverPackageApiCallBack? _driverPackageApiCallBack;
  var _noDataFound = 'Loading...';
  var now = new DateTime.now();
 String? formatted;
 String? apiToken;
 late int userId;

  var formatter = new DateFormat('yyyy-MM-dd');
  String? today;

  Future<Null> _handleRefresh() {
    final Completer<Null> completer = new Completer<Null>();
    new Timer(const Duration(seconds: 3), () {
      completer.complete(null);
    });
    return completer.future.then((_) {
      // _scaffoldKey.currentState?.showSnackBar(new SnackBar(
      //     content: const Text('Refresh complete'),
      //     action: new SnackBarAction(
      //         label: 'RETRY',
      //         onPressed: () {
      //           _refreshIndicatorKey.currentState.show();
      //         })));
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text(("Refresh complete").toString()),
          action: new SnackBarAction(
              label: 'RETRY',
              onPressed: () {
                _refreshIndicatorKey.currentState!.show();
              })));
    });
  }

  @override
  void initState() {
    super.initState();
    formatted = formatter.format(now);
    today = formatted;
    apiCallForPackageList();
  }

  @override
  void dispose() {
    super.dispose();
  }

  Future apiCallForPackageList() async {
    final SharedPreferences prefs = await _prefs;
    if (prefs.getBool(SP_IS_LOGIN_BOOL) != null) {
       userId = prefs.getInt(SP_ID)!;
      apiToken = prefs.getString(SP_API_TOKEN)!;
    }
    var map = new Map<String, dynamic>();
    map["appType"] = Platform.operatingSystem.toUpperCase();
    map["user_id"] = userId.toString();
    map["api_token"] = apiToken;
    print(map);
    try {
      _noDataFound = 'Loading...';
      _networkUtil.post(apiGetDeliveryList, body: map).then((dynamic res) {
        _noDataFound = noDataFound;
        try {
          AppLog.showLog(res.toString());
          _driverPackageApiCallBack = DriverPackageApiCallBack.fromJson(res);
          if (_driverPackageApiCallBack!.status == unAuthorised) {
            logout(context);
          } else if (!_driverPackageApiCallBack!.success) {
            showBottomToast(_driverPackageApiCallBack!.message);
          }
        } catch (es) {
          showErrorLog(es.toString());
          showCenterToast(errorApiCall);
        }
        setState(() {});
      });
    } catch (e) {
      showErrorLog(e.toString());
      showCenterToast(errorApiCall);
      _noDataFound = noDataFound;
      setState(() {});
    }
  }

  Future _cardTapped(int index) async {
    Map results = await Navigator.of(context).push(new MaterialPageRoute(
      builder: (BuildContext context) {
        return PackageDetails(
          scaffoldKey: widget.scaffoldKey,
          title: 'Package',
          id: _driverPackageApiCallBack!.items[index].id,
          date: _driverPackageApiCallBack!.items[index].date,
          delivered: _driverPackageApiCallBack!.items[index].delivered,
          received: _driverPackageApiCallBack!.items[index].received,
          wrongCust:
              _driverPackageApiCallBack!.items[index].wrongCustomerDetails,
          custNotAvail:
              _driverPackageApiCallBack!.items[index].customerNotAvailable,
          rescheduled: _driverPackageApiCallBack!.items[index].rescheduled,
          cancelled: _driverPackageApiCallBack!.items[index].cancelled,
          notAttempted: _driverPackageApiCallBack!.items[index].notAttempted,
          cash: _driverPackageApiCallBack!.items[index].cashOnDelivery,
          comment: _driverPackageApiCallBack!.items[index].comment,
        );
      },
    ));

    if (results.containsKey('reload')) {
      apiCallForPackageList();
    }
  }

  Future _floatingButtonTapped() async {
    Map results = await Navigator.of(context).push(new MaterialPageRoute(
      builder: (BuildContext context) {
        return AddPackage(
          scaffoldKey: widget.scaffoldKey,
          title: 'Add Package',
        );
      },
    ));

    if (results.containsKey('reload')) {
      apiCallForPackageList();
    }
  }

  @override
  Widget build(BuildContext context) {


    return Scaffold(
      body: Container(
        color: appBackgroundDashboard,
        child: Stack(
          children: <Widget>[
            CustomHeaderWithBackGreen(
                scaffoldKey: widget.scaffoldKey, title: widget.title),
            Container(
              margin: EdgeInsets.only(top: 90),
              child: Column(
                children: <Widget>[
                  Expanded(
                    child: RefreshIndicator(
                      key: _refreshIndicatorKey,
                      onRefresh: _handleRefresh,
                      child: (_driverPackageApiCallBack!.items.length > 0)
                          ? getPackageListView()
                          : Container(
                              child: Center(
                                child: Text(_noDataFound),
                              ),
                            ),
                    ),
                  ),
                ],
              ),
            )
          ],
        ),
      ),
      floatingActionButton: _showFabButton(),
    );
  }

  Widget getPackageListView() {
    return ListView.builder(
      shrinkWrap: true,
      itemBuilder: (BuildContext context, int index) {
        return Padding(
          padding: EdgeInsets.only(
              left: ScreenUtil().setSp(8),
              right: ScreenUtil().setSp(8),
              top: ScreenUtil().setSp(5),
              bottom: ScreenUtil().setSp(5)),
          child: Card(
              margin: EdgeInsets.only(
                  left: ScreenUtil().setSp(5), right: ScreenUtil().setSp(5)),
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8.0)),
              elevation: 5,
              child: GestureDetector(
                onTap: () {
                  _cardTapped(index);
                },
                child: Container(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: <Widget>[
                      Container(
                          decoration: new BoxDecoration(
                              color: appPrimaryColor,
                              borderRadius: new BorderRadius.only(
                                  topLeft: Radius.circular(10),
                                  topRight: Radius.circular(10))),
                          padding: EdgeInsets.only(
                              left: 5, top: 8, right: 5, bottom: 8),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: <Widget>[

                              Text(
                                DateFormat('dd MMM, yyyy').format(DateTime.parse(_driverPackageApiCallBack!.items[index].date)),
                                //'5677867',
                                textAlign: TextAlign.left,
                                style: TextStyle(
                                    fontSize: ScreenUtil().setSp(15),
                                    fontWeight: FontWeight.bold,
                                    color: Colors.white),
                              ),
                              (_driverPackageApiCallBack!.items[index].date ==
                                      today)
                                  ? Visibility(
                                      visible: true,
                                      child: Icon(
                                        Icons.edit,
                                        color: Colors.white,
                                        size: 18,
                                      ),
                                    )
                                  : Visibility(
                                      visible: false,
                                      child: Text(''),
                                    )
                            ],
                          )),
                      Container(
                          decoration: new BoxDecoration(
                              borderRadius: new BorderRadius.only(
                                  bottomLeft: Radius.circular(10),
                                  bottomRight: Radius.circular(10))),
                          padding: EdgeInsets.all(5),
                          child: Padding(
                            padding: EdgeInsets.all(ScreenUtil().setSp(0)),
                            child: Row(
                              children: <Widget>[
                                Flexible(
                                  flex: 3,
                                  fit: FlexFit.tight,
                                  child: Row(
                                    children: <Widget>[
                                      Text('Package Received: '),
                                      Text(_driverPackageApiCallBack!
                                          .items[index].received),
                                    ],
                                  ),
                                ),
                                Container(
                                  width: 1,
                                  height: 30.0,
                                  color: Colors.grey[300],
                                ),
                                SizedBox(
                                  width: 5.0,
                                ),
                                Flexible(
                                  flex: 3,
                                  fit: FlexFit.tight,
                                  child: Row(
                                    children: <Widget>[
                                      Text('Package Delivered: '),
                                      Text(_driverPackageApiCallBack!
                                          .items[index].delivered),
                                      //Text('95'),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          )),
                    ],
                  ),
                ),
              )),
        );
      },
      itemCount: _driverPackageApiCallBack!.items.length,
    );
  }

  visibilityStatus() {
    if (_driverPackageApiCallBack!.items.length > 0 &&
        _driverPackageApiCallBack!.items[0].date != today) {
      return true;
    }
    if (_driverPackageApiCallBack!.items.length == 0) return true;
      return false;
  }

  Widget _showFabButton() {
    if (_driverPackageApiCallBack!.items.length == 0) {
    return Visibility(
      visible: true,
      child: FloatingActionButton(
        child: Icon(Icons.add),
        backgroundColor: appAccentColor,
        onPressed: () {
          _floatingButtonTapped();
        },
      ),
    );
  } else if (_driverPackageApiCallBack!.items.length > 0 &&
      _driverPackageApiCallBack!.items[0].date != today) {
    return Visibility(
      visible: true,
      child: FloatingActionButton(
        child: Icon(Icons.add),
        backgroundColor: appAccentColor,
        onPressed: () {
          _floatingButtonTapped();
        },
      ),
    );
  }

    return Visibility(
      visible: false,
      child: Text(''),
    );
  }
}
/*
class DriverPackageApiCallBack {
  int totalCount;
  bool success;
  List<Item> items;
  String message;
  int status;
  String currentTime;
  String currentUtcTime;

  DriverPackageApiCallBack(
      {this.totalCount,
      this.success,
      this.items,
      this.message,
      this.status,
      this.currentTime,
      this.currentUtcTime});

  DriverPackageApiCallBack.fromJson(Map<String, dynamic> json) {
    totalCount = json['total_count'];
    success = json['success'];
    if (json['items'] != null) {
      items = new List<Item>();
      json['items'].forEach((v) {
        items.add(new Item.fromJson(v));
      });
    }
    message = json['message'];
    status = json['status'];
    currentTime = json['current_time'];
    currentUtcTime = json['current_utc_time'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['total_count'] = this.totalCount;
    data['success'] = this.success;
    if (this.items != null) {
      data['items'] = this.items.map((v) => v.toJson()).toList();
    }
    data['message'] = this.message;
    data['status'] = this.status;
    data['current_time'] = this.currentTime;
    data['current_utc_time'] = this.currentUtcTime;
    return data;
  }
}

class Item {
  int id;
  int userId;
  String date;
  String received;
  String delivered;
  String comment;
  String remark;
  int status;
  int totalPackagesReceived;
  int totalDelivered;
  int wrongCustomerDetails;
  int customerNotAvailable;
  int rescheduled;
  int cancelled;
  int notAttempted;
  int isdeleted;
  String cashOnDelivery;
  String createdAt;
  String updatedAt;

  Item(
      {this.id,
      this.userId,
      this.date,
      this.received,
      this.delivered,
      this.comment,
      this.remark,
      this.status,
      this.totalPackagesReceived,
      this.totalDelivered,
      this.wrongCustomerDetails,
      this.customerNotAvailable,
      this.rescheduled,
      this.cancelled,
      this.notAttempted,
      this.isdeleted,
      this.cashOnDelivery,
      this.createdAt,
      this.updatedAt});

  Item.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    userId = json['user_id'];
    date = json['date'];
    received = json['received'];
    delivered = json['delivered'];
    comment = json['comment'];
    remark = json['remark'];
    status = json['status'];
    totalPackagesReceived = json['total_packages_received'];
    totalDelivered = json['total_delivered'];
    wrongCustomerDetails = json['wrong_customer_details'];
    customerNotAvailable = json['customer_not_available'];
    rescheduled = json['rescheduled'];
    cancelled = json['cancelled'];
    notAttempted = json['not_attempted'];
    isdeleted = json['isdeleted'];
    cashOnDelivery = json['cash_on_delivery'];
    createdAt = json['created_at'];
    updatedAt = json['updated_at'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['id'] = this.id;
    data['user_id'] = this.userId;
    data['date'] = this.date;
    data['received'] = this.received;
    data['delivered'] = this.delivered;
    data['comment'] = this.comment;
    data['remark'] = this.remark;
    data['status'] = this.status;
    data['total_packages_received'] = this.totalPackagesReceived;
    data['total_delivered'] = this.totalDelivered;
    data['wrong_customer_details'] = this.wrongCustomerDetails;
    data['customer_not_available'] = this.customerNotAvailable;
    data['rescheduled'] = this.rescheduled;
    data['cancelled'] = this.cancelled;
    data['not_attempted'] = this.notAttempted;
    data['isdeleted'] = this.isdeleted;
    data['cash_on_delivery'] = this.cashOnDelivery;
    data['created_at'] = this.createdAt;
    data['updated_at'] = this.updatedAt;
    return data;
  }
}
*/

class DriverPackageApiCallBack {
  final int totalCount;
  final bool success;
  final List<Item> items;
  final String message;
  final int status;
  final String currentTime;
  final String currentUtcTime;

  DriverPackageApiCallBack({
    required this.totalCount,
    required this.success,
    required this.items,
    required this.message,
    required this.status,
    required this.currentTime,
    required this.currentUtcTime,
  });

  factory DriverPackageApiCallBack.fromJson(Map<String, dynamic> json) {
    return DriverPackageApiCallBack(
      totalCount: json['total_count'],
      success: json['success'],
      items: json['items'] != null
          ? List<Item>.from(json['items'].map((v) => Item.fromJson(v)))
          : <Item>[],
      message: json['message'],
      status: json['status'],
      currentTime: json['current_time'],
      currentUtcTime: json['current_utc_time'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'total_count': totalCount,
      'success': success,
      'items': items.map((v) => v.toJson()).toList(),
      'message': message,
      'status': status,
      'current_time': currentTime,
      'current_utc_time': currentUtcTime,
    };
  }
}

class Item {
  final int id;
  final int userId;
  final String date;
  final String received;
  final String delivered;
  final String comment;
  final String remark;
  final int status;
  final int totalPackagesReceived;
  final int totalDelivered;
  final int wrongCustomerDetails;
  final int customerNotAvailable;
  final int rescheduled;
  final int cancelled;
  final int notAttempted;
  final int approvedBy;
  final int isdeleted;
  final String cashOnDelivery;
  final String createdAt;
  final String updatedAt;

  Item({
    required this.id,
    required this.userId,
    required this.date,
    required this.received,
    required this.delivered,
    required this.comment,
    required this.remark,
    required this.status,
    required this.totalPackagesReceived,
    required this.totalDelivered,
    required this.wrongCustomerDetails,
    required this.customerNotAvailable,
    required this.rescheduled,
    required this.cancelled,
    required this.notAttempted,
    required this.approvedBy,
    required this.isdeleted,
    required this.cashOnDelivery,
    required this.createdAt,
    required this.updatedAt,
  });

  factory Item.fromJson(Map<String, dynamic> json) {
    return Item(
      id: json['id'],
      userId: json['user_id'],
      date: json['date'],
      received: json['received'],
      delivered: json['delivered'],
      comment: json['comment'],
      remark: json['remark'],
      status: json['status'],
      totalPackagesReceived: json['total_packages_received'],
      totalDelivered: json['total_delivered'],
      wrongCustomerDetails: json['wrong_customer_details'],
      customerNotAvailable: json['customer_not_available'],
      rescheduled: json['rescheduled'],
      cancelled: json['cancelled'],
      notAttempted: json['not_attempted'],
      approvedBy: json['approved_by'],
      isdeleted: json['isdeleted'],
      cashOnDelivery: json['cash_on_delivery'],
      createdAt: json['created_at'],
      updatedAt: json['updated_at'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'user_id': userId,
      'date': date,
      'received': received,
      'delivered': delivered,
      'comment': comment,
      'remark': remark,
      'status': status,
      'total_packages_received': totalPackagesReceived,
      'total_delivered': totalDelivered,
      'wrong_customer_details': wrongCustomerDetails,
      'customer_not_available': customerNotAvailable,
      'rescheduled': rescheduled,
      'cancelled': cancelled,
      'not_attempted': notAttempted,
      'approved_by': approvedBy,
      'isdeleted': isdeleted,
      'cash_on_delivery': cashOnDelivery,
      'created_at': createdAt,
      'updated_at': updatedAt,
    };
  }
}
