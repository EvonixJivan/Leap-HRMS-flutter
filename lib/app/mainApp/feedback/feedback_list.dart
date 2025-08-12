import 'dart:async';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:hrms/appUtil/network_util.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../../appUtil/app_util_config.dart';
import '../../uiComponent/custom_header.dart';
import 'package:intl/intl.dart';

class FeedBackList extends StatefulWidget {
  var scaffoldKey;
  var title;

  FeedBackList({Key? key, required this.scaffoldKey, required this.title})
      : super(key: key);

  @override
  _FeedBackListState createState() {
    return _FeedBackListState();
  }
}

class _FeedBackListState extends State<FeedBackList> {
  NetworkUtil _networkUtil = NetworkUtil();
  Future<SharedPreferences> _prefs = SharedPreferences.getInstance();
  final GlobalKey<ScaffoldState> _scaffoldKey = new GlobalKey<ScaffoldState>();
  final GlobalKey<RefreshIndicatorState> _refreshIndicatorKey =
      new GlobalKey<RefreshIndicatorState>();
  FeedbackListApiCallBack? _feedbackListApiCallBack;
  TextEditingController remarkController = TextEditingController();
 String? apiToken, _remark;
 late int userId, roleId, companyId, role;
  var _noDataFound = 'Loading...';
  bool isVisible = true;

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
    //apicallForFeedbackList();
    checkIsManager();
  }

  @override
  void dispose() {
    super.dispose();
  }

  Future checkIsManager() async {
    final SharedPreferences prefs = await _prefs;

    if (prefs.getBool(SP_IS_LOGIN_BOOL) != null) {
       userId = prefs.getInt(SP_ID)!;
      companyId = prefs.getInt(SP_COMPANY_ID)!;
      apiToken = prefs.getString(SP_API_TOKEN)!;
      role = prefs.getInt(SP_ROLE)!;
      if (role == 4) {
        isVisible = true;
        userId = 0;
        print('USER: $userId');
        apicallForFeedbackList();
      } else {
        isVisible = false;
        print('USER: $userId');
        apicallForFeedbackList();
      }
    }
  }

  Future apicallForFeedbackList() async {
    // final SharedPreferences prefs = await _prefs;
    // if (prefs.getBool(SP_IS_LOGIN_BOOL) != null) {
    //    userId = prefs.getInt(SP_ID)!;
    //   companyId = prefs.getInt(SP_COMPANY_ID)!;
    //   apiToken = prefs.getString(SP_API_TOKEN)!;
    // }
    var map = new Map<String, dynamic>();
    map["appType"] = Platform.operatingSystem.toUpperCase();
    map["userId"] = userId.toString();
    map["api_token"] = apiToken;
    map['companyId'] = companyId.toString();
    BuildContext _context = context;

    print(map);
    try {
      _noDataFound = 'Loading...';
      _networkUtil.post(apiGetMyFeedbackList, body: map).then((dynamic res) {
        _noDataFound = noDataFound;

        try {
          AppLog.showLog(res.toString());
          _feedbackListApiCallBack = FeedbackListApiCallBack.fromJson(res);
          if (_feedbackListApiCallBack!.status == unAuthorised) {
            logout(context);
          } else if (_feedbackListApiCallBack!.success) {
            showBottomToast(_feedbackListApiCallBack!.message);
          } else {
            showBottomToast(_feedbackListApiCallBack!.message);
          }
        } catch (es) {
          showErrorLog(es.toString());
          showCenterToast(errorApiCall);
        }
        setState(() {});
      });
    } catch (e) {
      _noDataFound = noDataFound;
      showErrorLog(e.toString());
      showCenterToast(errorApiCall);
    }
  }

  Future apiCallForChangeStatus(
      int _feedbackId, String _status, String _remark) async {
    final SharedPreferences prefs = await _prefs;
    var map = new Map<String, dynamic>();
    String _apiToken = prefs.getString(SP_API_TOKEN)!;
    int _userId = prefs.getInt(SP_ID)!;
    map["appType"] = Platform.operatingSystem.toUpperCase();
    map["api_token"] = _apiToken;
    map["userId"] = _userId.toString();
    map["feedbackId"] = _feedbackId.toString();
    map["status"] = _status;
    map["remark"] = remarkController.text;
    showLoader(context);

    print(map);
    try {
      _noDataFound = 'Loading...';
      _networkUtil.post(apiUpdateFeedbackstatus, body: map).then((dynamic res) {
        _noDataFound = noDataFound;

        try {
          Navigator.pop(context);
          AppLog.showLog(res.toString());
          ChangeFeedbackStatusApiCallBack _changeFeedbackStatusApiCallBack =
              ChangeFeedbackStatusApiCallBack.fromJson(res);
          if (_changeFeedbackStatusApiCallBack.status == unAuthorised) {
            logout(context);
          }
          if (!_changeFeedbackStatusApiCallBack.success) {
            showBottomToast(_changeFeedbackStatusApiCallBack.message);
          }
        } catch (es) {
          showErrorLog(es.toString());
          showCenterToast(errorApiCall);
        }
        setState(() {});
        Navigator.of(context).pop();
        checkIsManager();
        //apicallForFeedbackList();
      });
    } catch (e) {
      showErrorLog(e.toString());
      showCenterToast(errorApiCall);
      _noDataFound = noDataFound;
      setState(() {});
    }
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
       top: false,
        bottom: true,
      child: Scaffold(
        body: Container(
          color: appBackgroundDashboard,
          child: Stack(
            children: <Widget>[
              CustomHeaderWithBack(
                  scaffoldKey: widget.scaffoldKey, title: widget.title),
              Container(
                margin: EdgeInsets.only(top: 90.0),
                child: Column(
                  children: <Widget>[
                    Expanded(
                      child: RefreshIndicator(
                        key: _refreshIndicatorKey,
                        onRefresh: _handleRefresh,
                        child: (_feedbackListApiCallBack?.items.isNotEmpty ?? false)
                            ? getFeedbackListView()
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
      ),
    );
  }

  Widget getFeedbackListView() {
    return ListView.builder(
        shrinkWrap: true,
        itemBuilder: (BuildContext context, int index) {
          return Card(
              margin: EdgeInsets.only(
                  left: ScreenUtil().setSp(10),
                  right: ScreenUtil().setSp(10),
                  top: ScreenUtil().setSp(5),
                  bottom: ScreenUtil().setSp(5)),
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8.0)),
              elevation: 5,
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
                          padding: EdgeInsets.all(8),
                          child: Text(
                            _feedbackListApiCallBack!.items[index].moduleName,
                            textAlign: TextAlign.left,
                            style: TextStyle(
                                fontSize: ScreenUtil().setSp(15),
                                fontWeight: FontWeight.bold,
                                color: Colors.white),
                          )),
                      Container(
                        decoration: new BoxDecoration(
                            borderRadius: new BorderRadius.only(
                                bottomLeft: Radius.circular(10),
                                bottomRight: Radius.circular(10))),
                        padding: EdgeInsets.all(10),
                        child: Row(
                          children: <Widget>[
                            Expanded(
                                // flex: 4,
                                child: Column(
                              children: <Widget>[
                                Row(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: <Widget>[
                                    Text(
                                      'Title     : ',
                                      style: TextStyle(
                                          fontWeight: FontWeight.bold),
                                      maxLines: null,
                                    ),
                                    SizedBox(
                                      width: ScreenUtil().setSp(5),
                                    ),
                                    Expanded(
                                      child: Text(_feedbackListApiCallBack!
                                          .items[index].feedbackTitle),
                                    ),
                                  ],
                                ),
                                SizedBox(
                                  height: ScreenUtil().setSp(5),
                                ),
                                Row(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: <Widget>[
                                    Text('Details : ',
                                        style: TextStyle(
                                            fontWeight: FontWeight.bold)),
                                    SizedBox(
                                      width: ScreenUtil().setSp(5),
                                    ),
                                    Expanded(
                                      child: Text(
                                        _feedbackListApiCallBack!
                                            .items[index].feedbackDetail,
                                        maxLines: null,
                                      ),
                                    ),
                                  ],
                                ),
                                SizedBox(
                                  height: ScreenUtil().setSp(5),
                                ),
                                Row(
                                  children: <Widget>[
                                    Expanded(
                                      child: Row(
                                        children: <Widget>[
                                          Text('Status  : ',
                                              style: TextStyle(
                                                  fontWeight: FontWeight.bold)),
                                          SizedBox(
                                            width: ScreenUtil().setSp(5),
                                          ),
                                          Text(_feedbackListApiCallBack!
                                              .items[index].status),
                                        ],
                                      ),
                                    ),
                                    Expanded(
                                      child: Row(
                                        children: <Widget>[
                                          Text('Remark : ',
                                              style: TextStyle(
                                                  fontWeight: FontWeight.bold)),
                                          SizedBox(
                                            width: ScreenUtil().setSp(5),
                                          ),
                                          Text(_feedbackListApiCallBack!
                                              .items[index].remark),
                                        ],
                                      ),
                                    ),
                                  ],
                                ),
                                SizedBox(
                                  height: ScreenUtil().setSp(8),
                                ),
                                Row(
                                  crossAxisAlignment: CrossAxisAlignment.end,
                                  children: <Widget>[
                                    Expanded(
                                        child: Visibility(
                                      visible: isVisible,
                                      child: ElevatedButton(
                                        style: ElevatedButton.styleFrom(
                                            backgroundColor: appPrimaryColor),
                                        child: Text(
                                          'Change Status',
                                          style: TextStyle(color: Colors.white),
                                        ),
                                        onPressed: () {
                                          showAlertForChangeStatus(index);
                                        },
                                      ),
                                    )),
                                    Expanded(
                                      child: Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.end,
                                        children: <Widget>[
                                          Text(
                                            '${DateFormat('hh:mm a, dd MMM yyyy').format(DateFormat("yyyy-MM-dd HH:mm:ss").parse(_feedbackListApiCallBack!.items[index].updatedAt, true).toLocal())}',
                                            style: dateTimeTextStyle,
                                          ),
                                        ],
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            )),
                          ],
                        ),
                      ),
                    ]),
                // ),
              ));
        },
        itemCount: _feedbackListApiCallBack!.items.length);
  }

  Widget showAlertForChangeStatus(int index) {
    showDialog(
        context: context,
        builder: (BuildContext context) {
          return StatefulBuilder(builder: (context, setState) {
            return AlertDialog(
              contentPadding: EdgeInsets.all(0),
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.all(
                      Radius.circular(ScreenUtil().setSp(10)))),
              content: Container(
                decoration: new BoxDecoration(
                    borderRadius: new BorderRadius.all(
                        Radius.circular(ScreenUtil().setSp(10)))),
                padding: EdgeInsets.only(bottom: ScreenUtil().setSp(7)),
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
                        padding: EdgeInsets.all(15),
                        child: Row(
                          children: <Widget>[
                            Expanded(
                              child: Text(
                                'Change Status',
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                    fontSize: ScreenUtil().setSp(16),
                                    fontWeight: FontWeight.bold,
                                    color: appWhiteColor),
                              ),
                            ),
                            GestureDetector(
                              child: Icon(
                                Icons.close,
                                color: Colors.white,
                                size: 20,
                              ),
                              onTap: () {
                                remarkController.text = '';
                                Navigator.pop(context);
                              },
                            ),
                          ],
                        )),
                    Padding(
                      padding: EdgeInsets.only(
                          left: ScreenUtil().setSp(20),
                          top: ScreenUtil().setSp(8),
                          bottom: ScreenUtil().setSp(8),
                          right: ScreenUtil().setSp(20)),
                      child:
                          Text('Do you want to Change the Status of feedback?'),
                    ),
                    Padding(
                      padding: const EdgeInsets.only(left: 8.0, right: 8.0),
                      child: Container(
                        decoration: BoxDecoration(
                          color: Colors.grey[100],
                          border: Border.all(width: 1, color: Colors.grey),
                          borderRadius: BorderRadius.circular(3),
                        ),
                        child: TextFormField(
                          controller: remarkController,
                          minLines: 1,
                          maxLines: 2,
                          keyboardType: TextInputType.text,
                          decoration: InputDecoration(
                              border: InputBorder.none,
                              hintText: 'Remark',
                              prefixIcon: Icon(
                                Icons.rate_review,
                                color: Colors.grey,
                              )),
                          onSaved: (String? value) {
                            _remark = value!;
                            print(value);
                          },
                        ),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.only(
                          left: 8.0, right: 8.0, top: 8.0),
                      child: Row(
                        children: <Widget>[
                          Expanded(
                            child: ElevatedButton(
                              style: ElevatedButton.styleFrom(
                                  elevation: 5, backgroundColor: appColorFour),
                              child: Text(
                                'View',
                                style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 13.0,
                                    fontWeight: FontWeight.bold),
                              ),
                              onPressed: () {
                                if (remarkController.text != '') {
                                  apiCallForChangeStatus(
                                      _feedbackListApiCallBack!.items[index].id,
                                      'view',
                                      remarkController.text);
                                } else {
                                  showCenterToast('Remark is mandatory');
                                }
                                remarkController.text = '';
                              },
                            ),
                          ),
                          SizedBox(
                            width: 15.0,
                          ),
                          Expanded(
                            child: ElevatedButton(
                              style: ElevatedButton.styleFrom(
                                  elevation: 5, backgroundColor: appColorFour),
                              child: Text(
                                'Working',
                                style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 13.0,
                                    fontWeight: FontWeight.bold),
                              ),
                              onPressed: () {
                                if (remarkController.text != '') {
                                  apiCallForChangeStatus(
                                      _feedbackListApiCallBack!.items[index].id,
                                      'working',
                                      remarkController.text);
                                } else {
                                  showCenterToast('Remark is mandatory');
                                }
                                remarkController.text = '';
                              },
                            ),
                          ),
                        ],
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.only(left: 8.0, right: 8.0),
                      child: Row(
                        children: <Widget>[
                          Expanded(
                            child: ElevatedButton(
                              style: ElevatedButton.styleFrom(
                                  elevation: 5, backgroundColor: appColorFour),
                              child: Text(
                                'fixed',
                                style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 13.0,
                                    fontWeight: FontWeight.bold),
                              ),
                              onPressed: () {
                                if (remarkController.text != '') {
                                  apiCallForChangeStatus(
                                      _feedbackListApiCallBack!.items[index].id,
                                      'fixed',
                                      remarkController.text);
                                } else {
                                  showCenterToast('Remark is mandatory');
                                }
                                remarkController.text = '';
                              },
                            ),
                          ),
                          SizedBox(
                            width: 15.0,
                          ),
                          Expanded(
                            child: ElevatedButton(
                              style: ElevatedButton.styleFrom(
                                  elevation: 5, backgroundColor: appColorFour),
                              child: Text(
                                'cantFix',
                                style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 13.0,
                                    fontWeight: FontWeight.bold),
                              ),
                              onPressed: () {
                                if (remarkController.text != '') {
                                  apiCallForChangeStatus(
                                      _feedbackListApiCallBack!.items[index].id,
                                      'cantFix',
                                      remarkController.text);
                                } else {
                                  showCenterToast('Remark is mandatory');
                                }
                                remarkController.text = '';
                              },
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            );
          });
        });
    // Add a return statement to satisfy the non-nullable return type
    return SizedBox.shrink();
  }

}

class FeedbackListApiCallBack {
  final int totalCount;
  final bool success;
  final List<Items> items;
  final String message;
  final int status;
  final String currentTime;
  final String currentUtcTime;

  FeedbackListApiCallBack({
    required this.totalCount,
    required this.success,
    required this.items,
    required this.message,
    required this.status,
    required this.currentTime,
    required this.currentUtcTime,
  });

  factory FeedbackListApiCallBack.fromJson(Map<String, dynamic> json) {
    return FeedbackListApiCallBack(
      totalCount: json['total_count'],
      success: json['success'],
      items: json['items'] != null
          ? List<Items>.from(json['items'].map((v) => Items.fromJson(v)))
          : <Items>[],
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

class Items {
  final int id;
  final int userId;
  final String userName;
  final String companyName;
  final String feedbackTitle;
  final String feedbackDetail;
  final String moduleName;
  final String status;
  final String remark;
  final String createdAt;
  final String updatedAt;

  Items({
    required this.id,
    required this.userId,
    required this.userName,
    required this.companyName,
    required this.feedbackTitle,
    required this.feedbackDetail,
    required this.moduleName,
    required this.status,
    required this.remark,
    required this.createdAt,
    required this.updatedAt,
  });

  factory Items.fromJson(Map<String, dynamic> json) {
    return Items(
      id: json['id'],
      userId: json['userId'],
      userName: json['userName'],
      companyName: json['companyName'],
      feedbackTitle: json['feedbackTitle'],
      feedbackDetail: json['feedbackDetail'],
      moduleName: json['moduleName'],
      status: json['status'],
      remark: json['remark'],
      createdAt: json['created_at'],
      updatedAt: json['updated_at'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'userId': userId,
      'userName': userName,
      'companyName': companyName,
      'feedbackTitle': feedbackTitle,
      'feedbackDetail': feedbackDetail,
      'moduleName': moduleName,
      'status': status,
      'remark': remark,
      'created_at': createdAt,
      'updated_at': updatedAt,
    };
  }
}

class ChangeFeedbackStatusApiCallBack {
  final int totalCount;
  final bool success;
  final Item? items;
  final String message;
  final int status;
  final String currentTime;
  final String currentUtcTime;

  ChangeFeedbackStatusApiCallBack({
    required this.totalCount,
    required this.success,
    required this.items,
    required this.message,
    required this.status,
    required this.currentTime,
    required this.currentUtcTime,
  });

  factory ChangeFeedbackStatusApiCallBack.fromJson(Map<String, dynamic> json) {
    return ChangeFeedbackStatusApiCallBack(
      totalCount: json['total_count'],
      success: json['success'],
      items: json['items'] != null ? Item.fromJson(json['items']) : null,
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
      'items': items?.toJson(),
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
  final int companyId;
  final String moduleName;
  final String title;
  final String detail;
  final String status;
  final String remark;
  final String createdAt;
  final String updatedAt;
  final int deletedAt;

  Item({
    required this.id,
    required this.userId,
    required this.companyId,
    required this.moduleName,
    required this.title,
    required this.detail,
    required this.status,
    required this.remark,
    required this.createdAt,
    required this.updatedAt,
    required this.deletedAt,
  });

  factory Item.fromJson(Map<String, dynamic> json) {
    return Item(
      id: json['id'],
      userId: json['userId'],
      companyId: json['companyId'],
      moduleName: json['moduleName'],
      title: json['title'],
      detail: json['detail'],
      status: json['status'],
      remark: json['remark'],
      createdAt: json['created_at'],
      updatedAt: json['updated_at'],
      deletedAt: json['deleted_at'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'userId': userId,
      'companyId': companyId,
      'moduleName': moduleName,
      'title': title,
      'detail': detail,
      'status': status,
      'remark': remark,
      'created_at': createdAt,
      'updated_at': updatedAt,
      'deleted_at': deletedAt,
    };
  }
}