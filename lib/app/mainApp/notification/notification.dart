import 'dart:async';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:hrms/appUtil/network_util.dart';
import '../../../appUtil/app_util_config.dart';
import '../../uiComponent/custom_header.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:intl/intl.dart';

class NotificationList extends StatefulWidget {
  var scaffoldKey;
  var title;

  NotificationList({Key? key, required this.scaffoldKey, required this.title})
      : super(key: key);

  @override
  _NotificationListState createState() {
    return _NotificationListState();
  }
}

class _NotificationListState extends State<NotificationList> {
  final GlobalKey<ScaffoldState> _scaffoldKey = new GlobalKey<ScaffoldState>();
  final GlobalKey<RefreshIndicatorState> _refreshIndicatorKey =
      new GlobalKey<RefreshIndicatorState>();
  NetworkUtil _networkUtil = NetworkUtil();
  Future<SharedPreferences> _prefs = SharedPreferences.getInstance();
  NotificationApiCallBack? _notificationApiCallBack;
 late int userId;
 String? apiToken;
  var _noDataFound = 'Loading...';

  Future<Null> _handleRefresh() {
    final Completer<Null> completer = new Completer<Null>();
    new Timer(const Duration(seconds: 3), () {
      completer.complete(null);
    });
    return completer.future.then((_) {
    });
  }

  Future apiCallForGetNotifications() async {
    final SharedPreferences prefs = await _prefs;
    if (prefs.getBool(SP_IS_LOGIN_BOOL) != null) {
       userId = prefs.getInt(SP_ID)!;
      apiToken = prefs.getString(SP_API_TOKEN)!;
    }
    var map = new Map<String, dynamic>();
    map["appType"] = Platform.operatingSystem.toUpperCase();
    map['userId'] = userId.toString();
    map["api_token"] = apiToken;

    print(map);
    try {
      _noDataFound = 'Loading...';
      _networkUtil.post(apiGetNotification, body: map).then((dynamic res) {
        _noDataFound = noDataFound;
        try {
          AppLog.showLog(res.toString());

          _notificationApiCallBack = NotificationApiCallBack.fromJson(res);
          if (_notificationApiCallBack!.status == unAuthorised) {
            logout(context);
          } else if (!_notificationApiCallBack!.success!) {
            showBottomToast(_notificationApiCallBack!.message ?? "");
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

  @override
  void initState() {
    apiCallForGetNotifications();
    super.initState();
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {

    final TextTheme textTheme = Theme.of(context).textTheme;
    return SafeArea(
       top: false,
        bottom: true,
      child: Scaffold(
        body: Container(
          color: appBackgroundDashboard,
          child: Stack(
            children: <Widget>[
               CustomHeaderWithBack(scaffoldKey: widget.scaffoldKey, title: widget.title),
              // CustomHeader(scaffoldKey: widget.scaffoldKey, title: widget.title),
      
              // CustomHeaderWithBackGreen(
              //     scaffoldKey: widget.scaffoldKey, title: widget.title),
              Container(
                margin: EdgeInsets.only(top: 90.0),
                child: Column(
                  children: <Widget>[
                    Expanded(
                      child: RefreshIndicator(
                          key: _refreshIndicatorKey,
                          onRefresh: _handleRefresh,
                          child: (_notificationApiCallBack?.items?.isNotEmpty ?? false)
                              ? getNotificationListView()
                              : Container(
                                  child: Center(
                                    child: Text(_noDataFound),
                                  ),
                                )),
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

  Widget getNotificationListView() {
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
                        _notificationApiCallBack!.items![index].fcmTitle ?? "",
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
                    child: Column(
                      children: <Widget>[
                        Row(
                          children: <Widget>[
                            Expanded(
                              child: Text(
                                _notificationApiCallBack!
                                    .items![index].fcmMessage ?? "",
                                style: TextStyle(fontWeight: FontWeight.normal),
                                maxLines: null,
                              ),
                            ),
                          ],
                        ),
                        SizedBox(
                          height: ScreenUtil().setSp(5),
                        ),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.end,
                          children: <Widget>[
                            Text(
                              DateFormat('HH:mm aa - dd MMM, yyyy').format(DateTime.parse(_notificationApiCallBack!
                            .items![index].createdDate ?? ""
                                ))),
                          ],
                        ),
                      ],
                    ),
                  ),
                ],
              ));
        },
        itemCount: _notificationApiCallBack!.items!.length);
  }
}

class NotificationApiCallBack {
   int? totalCount;
  bool? success;
  List<Items>? items;
 String? message;
  int? status;

  NotificationApiCallBack(
      {required this.totalCount, required this.success, required this.items, required this.message, required this.status});

  NotificationApiCallBack.fromJson(Map<String, dynamic> json) {
    totalCount = json['total_count'];
    success = json['success'];
    if (json['items'] != null) {
    items =[];
      json['items'].forEach((v) {
        items!.add(new Items.fromJson(v));
      });
    }
    message = json['message'];
    status = json['status'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['total_count'] = this.totalCount;
    data['success'] = this.success;
    data['items'] = this.items!.map((v) => v.toJson()).toList();
      data['message'] = this.message;
    data['status'] = this.status;
    return data;
  }
}

class Items {
 int? id;
  int? companyId;
  int? userId;
 String? fcmMessage;
 String? fcmTitle;
 String? imageUrl;
 String? createdDate;
  int? isDeleted;

  Items(
      {required this.id,
     required this.companyId,
     required this.userId,
     required this.fcmMessage,
     required this.fcmTitle,
     required this.imageUrl,
     required this.createdDate,
     required this.isDeleted});

  Items.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    companyId = json['companyId'];
    userId = json['userId'];
    fcmMessage = json['fcm_message'];
    fcmTitle = json['fcm_title'];
    imageUrl = json['image_url'];
    createdDate = json['created_date'];
    isDeleted = json['is_deleted'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['id'] = this.id;
    data['companyId'] = this.companyId;
    data['userId'] = this.userId;
    data['fcm_message'] = this.fcmMessage;
    data['fcm_title'] = this.fcmTitle;
    data['image_url'] = this.imageUrl;
    data['created_date'] = this.createdDate;
    data['is_deleted'] = this.isDeleted;
    return data;
  }
}
