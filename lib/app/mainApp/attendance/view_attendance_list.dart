import 'dart:async';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:hrms/app/uiComponent/custom_header.dart';
import 'package:hrms/appUtil/app_util_config.dart';
import 'package:hrms/appUtil/network_util.dart';
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../../app_splash_screen.dart';
import 'attendance_list.dart';

class ViewAttendanceList extends StatefulWidget {
  var scaffoldKey;
  var title;

  ViewAttendanceList(
      {Key? key, required this.scaffoldKey, required this.title})
      : super(key: key);

  @override
  _ViewAttendanceListState createState() {
    return _ViewAttendanceListState();
  }
}

class _ViewAttendanceListState extends State<ViewAttendanceList> {
  NetworkUtil _networkUtil = NetworkUtil();
  Future<SharedPreferences> _prefs = SharedPreferences.getInstance();
  final GlobalKey<ScaffoldState> _scaffoldKey = new GlobalKey<ScaffoldState>();
  final GlobalKey<RefreshIndicatorState> _refreshIndicatorKey =
      new GlobalKey<RefreshIndicatorState>();
  String? apiToken;
  late int userId;

  @override
  void initState() {
    super.initState();
    apiCallForGetAttendanceForSelectedDate();
  }

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
  void dispose() {
    super.dispose();
  }

  DayAttendanceListApi? _dayAttendanceListApi;
  var _noDataFound = 'Loading...';

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
              CustomHeaderWithBackGreen(
                  scaffoldKey: widget.scaffoldKey, title: widget.title),
              Container(
                margin: EdgeInsets.only(top: 90.0),
                child: Column(
                  children: <Widget>[
                    Expanded(
                      child: RefreshIndicator(
                        key: _refreshIndicatorKey,
                        onRefresh: _handleRefresh,
                        child: (_dayAttendanceListApi?.attendanceItems?.attendanceDetails.isNotEmpty ?? false)
                            ? ListView.builder(
                                shrinkWrap: true,
                                // physics: NeverScrollableScrollPhysics(),
                                physics: ScrollPhysics(),
                                itemBuilder: (BuildContext context, int index) {
                                  return Padding(
                                    padding: EdgeInsets.only(
                                        left: ScreenUtil().setSp(10),
                                        right: ScreenUtil().setSp(10),
                                        top: ScreenUtil().setSp(5),
                                        bottom: ScreenUtil().setSp(5)),
                                    child: Column(
                                      children: <Widget>[
                                        (index == 0)
                                            ? firstCard(
                                                _dayAttendanceListApi!
                                                    .attendanceItems!
                                                    .attendanceDetails[0]
                                                    .attachment!,
                                                '${DateFormat('dd MMM, yyyy').format(DateFormat("yyyy-MM-dd").parse(_dayAttendanceListApi!.attendanceItems!.attendanceDetails[0].punchDate!, true).toLocal())}',
                                                '${DateFormat('hh:mm a').format(DateFormat("yyyy-MM-dd HH:mm:ss").parse(_dayAttendanceListApi!.attendanceItems!.attendanceDetails[0].inTime!, true).toLocal())}',
                                                '${DateFormat('hh:mm a').format(DateFormat("yyyy-MM-dd HH:mm:ss").parse(_dayAttendanceListApi!.attendanceItems!.attendanceDetails[0].outTime!, true).toLocal())}',
                                                '${_dayAttendanceListApi!.attendanceItems!.attendanceDetails[0].totalWorkingHours}',
                                                '${_dayAttendanceListApi!.attendanceItems!.attendanceDetails[0].totalPauseHours}')
                                            : pauseCard(
                                                '${DateFormat('hh:mm a').format(DateFormat("yyyy-MM-dd HH:mm:ss").parse(_dayAttendanceListApi!.attendanceItems!.attendanceDetails[index].inTime!, true).toLocal())}',
                                                (_dayAttendanceListApi!
                                                            .attendanceItems!
                                                            .attendanceDetails[
                                                                index]
                                                            .outTime ==
                                                        '')
                                                    ? ''
                                                    : '${DateFormat('hh:mm a').format(DateFormat("yyyy-MM-dd HH:mm:ss").parse(_dayAttendanceListApi!.attendanceItems!.attendanceDetails[index].outTime!, true).toLocal())}',
                                                (_dayAttendanceListApi!
                                                            .attendanceItems!
                                                            .attendanceDetails[
                                                                index]
                                                            .outTime ==
                                                        '')
                                                    ? ''
                                                    : '${DateTime.parse(_dayAttendanceListApi!.attendanceItems!.attendanceDetails[index].outTime!).difference(DateTime.parse(_dayAttendanceListApi!.attendanceItems!.attendanceDetails[index].inTime!)).inMinutes} minutes',
                                                '${_dayAttendanceListApi!.attendanceItems!.attendanceDetails[index].reason}'),
                                      ],
                                    ),
                                  );
                                },
                                itemCount: _dayAttendanceListApi!
                                    .attendanceItems!.attendanceDetails.length,
                              )
                            : Container(
                                child: Center(
                                  child: Column(
                                    children: <Widget>[
                                      SizedBox(
                                        height: 180.0,
                                      ),
                                      Text(
                                        _noDataFound,
                                      ),
                                    ],
                                  ),
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

  Future apiCallForGetAttendanceForSelectedDate() async {
    final SharedPreferences prefs = await _prefs;
    if (prefs.getBool(SP_IS_LOGIN_BOOL) != null) {
       userId = prefs.getInt(SP_ID)!;
      apiToken = prefs.getString(SP_API_TOKEN)!;
    }
    var map = new Map<String, dynamic>();
    map["appType"] = Platform.operatingSystem.toUpperCase();
    map["userId"] = userId.toString();
    map["api_token"] = apiToken;
    map['punchDate'] = DateFormat('yyyy-MM-dd').format(DateTime.now());
    _dayAttendanceListApi = null;
    print(map);
    try {
      _noDataFound = 'Loading...';
      _networkUtil.post(apiAttendanceSingle, body: map).then((dynamic res) {
        _noDataFound = noDataFound;
        try {
          AppLog.showLog(res.toString());
          _dayAttendanceListApi = DayAttendanceListApi.fromJson(res);
          if (_dayAttendanceListApi!.status == unAuthorised) {
            logout();
          } else if (!_dayAttendanceListApi!.success) {
            showBottomToast(_dayAttendanceListApi!.message!);
          }
        } catch (es) {
          showErrorLog(es.toString());
          showCenterToast(noDataFound);
        }
        setState(() {});
      });
    } catch (e) {
      showErrorLog(e.toString());
      showCenterToast(noDataFound);
      _noDataFound = noDataFound;
      setState(() {});
    }
  }

  void logout() async {
    final SharedPreferences prefs = await _prefs;
    prefs.clear();
    Navigator.pushAndRemoveUntil(
        context,
        PageRouteBuilder(pageBuilder: (BuildContext context,
            Animation animation, Animation secondaryAnimation) {
          return AppSplashScreen();
        }, transitionsBuilder: (BuildContext context,
            Animation<double> animation,
            Animation<double> secondaryAnimation,
            Widget child) {
          return new SlideTransition(
            position: new Tween<Offset>(
              begin: const Offset(1.0, 0.0),
              end: Offset.zero,
            ).animate(animation),
            child: child,
          );
        }),
        (Route route) => false);
  }

  Widget firstCard(String imgurl, String date, String inTime, String outTome,
      String workingHrs, String pauseHrs) {
    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8.0)),
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
                date,
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
              padding: EdgeInsets.all(2),
              child: Row(
                children: <Widget>[
                  FadeInImage.assetNetwork(
                    placeholder: 'assets/image/default.png',
                    image: imgurl,
                    fit: BoxFit.fill,
                    width: ScreenUtil().setSp(90.0),
                    height: ScreenUtil().setSp(90.0),
                  ),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: <Widget>[
                        Padding(
                          padding: EdgeInsets.only(
                              left: ScreenUtil().setSp(15),
                              right: ScreenUtil().setSp(10)),
                          child: Row(
                            children: <Widget>[
                              Expanded(
                                flex: 3,
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: <Widget>[
                                    Text('In Time : '),
                                    Text(inTime,
                                        style: TextStyle(
                                            fontWeight: FontWeight.bold,
                                            fontSize: ScreenUtil().setSp(14))),
                                    SizedBox(
                                      height: ScreenUtil().setSp(5),
                                    ),
                                    Text('Out Time : '),
                                    Text(outTome,
                                        style: TextStyle(
                                            fontWeight: FontWeight.bold,
                                            fontSize: ScreenUtil().setSp(14))),
                                  ],
                                ),
                              ),
                              Expanded(
                                flex: 5,
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: <Widget>[
                                    Text('Total Pause Hours:'),
                                    Text(pauseHrs,
                                        style: TextStyle(
                                            fontWeight: FontWeight.bold,
                                            fontSize: ScreenUtil().setSp(14))),
                                    SizedBox(
                                      height: ScreenUtil().setSp(5),
                                    ),
                                    Text('Total Working Hours:'),
                                    Text(workingHrs,
                                        style: TextStyle(
                                            fontWeight: FontWeight.bold,
                                            fontSize: ScreenUtil().setSp(14))),
                                  ],
                                ),
                              )
                            ],
                          ),
                        )
                      ],
                    ),
                  )
                ],
              )),
        ],
      ),
    );
  }

  Widget pauseCard(
      String startTime, String endTime, String total, String reason) {
    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8.0)),
      elevation: 5,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: <Widget>[
          Container(
              decoration: new BoxDecoration(
                  borderRadius: new BorderRadius.only(
                      bottomLeft: Radius.circular(10),
                      bottomRight: Radius.circular(10))),
              padding: EdgeInsets.all(10),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  // Expanded(
                  //  child:
                  Text(
                    'Pause Reason',
                    style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: ScreenUtil().setSp(15),
                        color: appPrimaryColor),
                    textAlign: TextAlign.left,
                  ),
                  Text(
                    reason,
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                    ),
                    maxLines: null,
                    textAlign: TextAlign.left,
                  ),

                  SizedBox(
                    height: ScreenUtil().setSp(5),
                  ),
                  // )
                  Row(
                    children: <Widget>[
                      Expanded(
                        child: Text('Start Time'),
                      ),
                      Expanded(
                        child: Text('End Time'),
                      ),
                      Expanded(
                        child: Text('Total Time'),
                      ),
                    ],
                  ),
                  Row(
                    children: <Widget>[
                      Expanded(
                        child: Text(startTime,
                            style: TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: ScreenUtil().setSp(14))),
                      ),
                      Expanded(
                        child: Text(endTime,
                            style: TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: ScreenUtil().setSp(14))),
                      ),
                      Expanded(
                        child: Text(total,
                            style: TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: ScreenUtil().setSp(14))),
                      ),
                    ],
                  ),
                ],
              )),
          Container(
            color: appPrimaryColor,
            height: 2.0,
          )
        ],
      ),
    );
  }
}
