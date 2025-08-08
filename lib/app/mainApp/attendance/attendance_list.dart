// ignore_for_file: missing_required_param, unnecessary_brace_in_string_interps, unnecessary_new

import 'dart:async';
import 'dart:io';
import 'package:community_material_icon/community_material_icon.dart';
import 'package:flutter/material.dart';
import 'package:flutter_calendar_carousel/classes/event.dart';
import 'package:flutter_calendar_carousel/flutter_calendar_carousel.dart'
    show CalendarCarousel, EventList;
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:geolocator/geolocator.dart';
import 'package:hrms/app/mainApp/attendance/attendance_request.dart';
import 'package:hrms/app/mainApp/attendance/current_location.dart';
import 'package:hrms/appUtil/app_util_config.dart';
import 'package:hrms/appUtil/global.dart' as global;
import 'package:hrms/appUtil/network_util.dart';
import 'package:hrms/app_splash_screen.dart';
import 'package:intl/intl.dart';
import 'package:intl/intl.dart' show DateFormat;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:cached_network_image/cached_network_image.dart';

class AttendanceList extends StatefulWidget {
  var scaffoldKey;
  var title;

  AttendanceList({Key? key, required this.scaffoldKey, required this.title})
      : super(key: key);

  @override
  _AttendanceListState createState() {
    return _AttendanceListState();
  }
}

class _AttendanceListState extends State<AttendanceList> {
  AttendanceListApiCallBack? _attendanceListApiCallBack;
  DayAttendanceListApi? _dayAttendanceListApi;
  final GlobalKey<ScaffoldState> _scaffoldKey = new GlobalKey<ScaffoldState>();
  final GlobalKey<RefreshIndicatorState> _refreshIndicatorKey =
      new GlobalKey<RefreshIndicatorState>();
  NetworkUtil _networkUtil = NetworkUtil();
  Future<SharedPreferences> _prefs = SharedPreferences.getInstance();
  String? apiToken, attFromDate, attToDate;
 late int userId, bufferDays, attendanceStatus = 0;
  var startDate = new DateFormat('yyyy-MM-dd')
      .format(DateTime.now().subtract(const Duration(days: 30)));
  var endDate = new DateFormat('yyyy-MM-dd').format(DateTime.now());
  var _fromDate = '';
  var _toDate = '';
  var strResulte = '';
  DateTime _currentDate = DateTime.now();
  DateTime _currentDate2 = DateTime.now();
  String _currentMonth = DateFormat.yMMM().format(DateTime.now());
  DateTime _targetDateTime = DateTime.now();
  DateTime _startDate = DateTime.now().toUtc();
  DateTime _endDate = DateTime.now().toUtc();
  var startday = '';
  var endday = '';
  late CalendarCarousel _calendarCarousel;
 String? selectedDate;
  var _noDataFound = 'Loading...';
  bool isVisible = false;
  final scaffoldKey = GlobalKey<ScaffoldState>();
  int isLoadAPI = 0;
  Future<Null> _handleRefresh() {
    final Completer<Null> completer = new Completer<Null>();
    new Timer(const Duration(seconds: 3), () {
      completer.complete(null);
    });
    return completer.future.then((_) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text(("Refresh complete").toString()),
          action: new SnackBarAction(
              label: 'RETRY',
              onPressed: () {
                _refreshIndicatorKey.currentState!.show();
              })));
    });
  }

  Future apiCallForGetAttendanceOfMonth() async {
    final SharedPreferences prefs = await _prefs;
    if (prefs.getBool(SP_IS_LOGIN_BOOL) != null) {
       userId = prefs.getInt(SP_ID)!;
      apiToken = prefs.getString(SP_API_TOKEN)!;
    }
    var map = new Map<String, dynamic>();
    map["appType"] = Platform.operatingSystem.toUpperCase();
    map["id"] = userId.toString();
    map["loginUser"] = userId.toString();
    map["api_token"] = apiToken;
    if (_fromDate.isEmpty) {
      map['startDate'] = startDate;
    } else {
      map['startDate'] = _fromDate;
    }
    if (_toDate.isEmpty) {
      map['endDate'] = endDate;
    } else {
      map['endDate'] = _toDate;
    }

    print(map);
    print(apiAttendanceListNew);
    try {
      _noDataFound = 'Loading...';
      _networkUtil.post(apiAttendanceListNew, body: map).then((dynamic res) {
        _noDataFound = noDataFound;
        try {
          AppLog.showLog(res.toString());
          _attendanceListApiCallBack = AttendanceListApiCallBack.fromJson(res);
          if (_attendanceListApiCallBack!.status == unAuthorised) {
            logout();
          } else if (!_attendanceListApiCallBack!.success!) {
            showBottomToast(_attendanceListApiCallBack!.message!);
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

  Future apiCallForGetAttendanceForMonth(var start, var end) async {
    // print("here i m");
    final SharedPreferences prefs = await _prefs;
    if (prefs.getBool(SP_IS_LOGIN_BOOL) != null) {
       userId = prefs.getInt(SP_ID)!;
      apiToken = prefs.getString(SP_API_TOKEN)!;
    }
    var map = new Map<String, dynamic>();
    map["appType"] = Platform.operatingSystem.toUpperCase();
    map["id"] = userId.toString();
    map["loginUser"] = userId.toString();
    map["api_token"] = apiToken;
    map['startDate'] = startDate;
    map['endDate'] = endDate;

    // print(map);
    try {
      _noDataFound = 'Loading...';
      _networkUtil.post(apiAttendanceListNew, body: map).then((dynamic res) {
        _noDataFound = noDataFound;
        try {
          AppLog.showLog(res.toString());
          _attendanceListApiCallBack = AttendanceListApiCallBack.fromJson(res);
          if (_attendanceListApiCallBack!.status == unAuthorised) {
            logout();
          } else if (!_attendanceListApiCallBack!.success!) {
            showBottomToast(_attendanceListApiCallBack!.message!);
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
    map['punchDate'] = selectedDate;
    _dayAttendanceListApi = null;
    // print(map);
    try {
      _noDataFound = 'Loading...';
      _networkUtil.post(apiAttendanceSingle, body: map).then((dynamic res) {
        _noDataFound = noDataFound;
        try {
          AppLog.showLog(res.toString());
          _dayAttendanceListApi = DayAttendanceListApi.fromJson(res);
          if (_dayAttendanceListApi!.status == unAuthorised) {
            logout();
          } else if (!_dayAttendanceListApi!.success) {}
        } catch (es) {
          showErrorLog(es.toString());
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

  Future trackingData() async {
    final SharedPreferences prefs = await _prefs;
    if (prefs.getBool(SP_IS_LOGIN_BOOL) != null) {
       userId = prefs.getInt(SP_ID)!;
      apiToken = prefs.getString(SP_API_TOKEN)!;
    }
    var map = new Map<String, dynamic>();
    map["appType"] = Platform.operatingSystem.toUpperCase();
    map["userId"] = userId.toString();
    map["api_token"] = apiToken;
    map['punchDate'] = selectedDate;
    _dayAttendanceListApi = null;
    // print(map);
    try {
      _noDataFound = 'Loading...';
      _networkUtil
          .get(
        apiTracking,
      )
          .then((dynamic res) {
        _noDataFound = noDataFound;
        try {
          AppLog.showLog(res.toString());
        } catch (es) {
          showErrorLog(es.toString());
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
    super.initState();
    isLoadAPI = 0;
    checkInternet();
  }

  Future<void> checkInternet() async {
    var connectivityResult1 = await (Connectivity().checkConnectivity());
    if (connectivityResult1 == ConnectivityResult.mobile) {
    } else if (connectivityResult1 == ConnectivityResult.wifi) {}
    var connectivityResult = await (Connectivity().checkConnectivity());
    if (connectivityResult != ConnectivityResult.none) {
      if (isLoadAPI == 1) {
        apiCallForGetAttendanceOfMonth();
      } else {
        _isDriver();
        _getBufferDays();
        apiCallForGetAttendanceOfMonth();
        selectedDate = DateFormat('yyyy-MM-dd').format(DateTime.now());
        apiCallForGetAttendanceForSelectedDate();
      }
    } else {
      _noDataFound = global.noInternet;
      setState(() {});
      showNetworkErrorSnackBar1(scaffoldKey);
    }
  }

  showNetworkErrorSnackBar1(GlobalKey<ScaffoldState> scaffoldKey) {
    try {
      // bool isConnected;
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        behavior: SnackBarBehavior.floating,
        margin: const EdgeInsets.only(bottom: 0.0),
        duration: const Duration(days: 1),
        content: Row(
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: <Widget>[
            const Icon(
              Icons.signal_wifi_off,
              color: Colors.white,
            ),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.only(
                  left: 16.0,
                ),
                child: Text(
                  global.noInternet,
                  textAlign: TextAlign.start,
                ),
              ),
            ),
          ],
        ),
        action: SnackBarAction(
            textColor: Colors.white,
            label: 'RETRY',
            onPressed: () {
              ScaffoldMessenger.of(context).removeCurrentSnackBar();
              checkInternet();
            }),
        backgroundColor: Colors.grey,
      ));
    } catch (e) {
      print("Exception -  base.dart - showNetworkErrorSnackBar1():" +
          e.toString());
    }
  }

  @override
  void dispose() {
    super.dispose();
  }

  /// Remove condition once buffer saved from Login model
  Future _getBufferDays() async {
    final SharedPreferences prefs = await _prefs;
    if (prefs.getInt(SP_ATTENDANCE_STATUS) != null) {
      attendanceStatus = prefs.getInt(SP_ATTENDANCE_STATUS)!;
    } else {
      attendanceStatus = 0;
    }
    if (prefs.getInt(SP_BUFFER_ATTENDANCE) != null) {
      bufferDays = prefs.getInt(SP_BUFFER_ATTENDANCE)!;
    } else {
      bufferDays = 4;
    }
  }

  ///Check for driver
  Future _isDriver() async {
    final SharedPreferences prefs = await _prefs;
    int driver = prefs.getInt(SP_ROLE)!;
    if (driver == 5) {
      isVisible = false;
    } else {
      isVisible = true;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: scaffoldKey,
      backgroundColor: global.appBackground,
      body: GestureDetector(
        onTap: () {
          FocusScope.of(context).requestFocus(new FocusNode());
        },
        child: Stack(
          children: <Widget>[
            getCustomHeader(),
            Padding(
              padding: EdgeInsets.only(top: ScreenUtil().setSp(90)),
              child: ListView(
                physics: const BouncingScrollPhysics(),
                children: <Widget>[
                  getCalendarView(),
                  getIntroView(),
                  getAttendanceOfTheDayView(),
                  //Check live app and hide show tracking  btn by G1...
                  (attendanceStatus > 11) //(attendanceStatus > 0)

                      ? Container(
                          padding: EdgeInsets.only(
                              left: ScreenUtil().setSp(20),
                              right: ScreenUtil().setSp(20),
                              bottom: ScreenUtil().setSp(15),
                              top: ScreenUtil().setSp(10)),
                          child: ElevatedButton(
                            style: ElevatedButton.styleFrom(
                                backgroundColor: global.btnBgColor,
                                shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(20.0))),
                            child: Text(
                              'Show Tracking',
                              style: TextStyle(
                                  color: appWhiteColor,
                                  fontSize: ScreenUtil().setSp(15),
                                  fontWeight: FontWeight.w600,
                                  fontFamily: font),
                            ),
                            onPressed: () {
                              // getCurrentPosition();
                              setState(() {
                                apiCallForGetAttendanceOfMonth();
                                Navigator.of(context).push(
                                    new MaterialPageRoute(
                                        builder: (BuildContext context) =>
                                            const CurrentLocationScreen()));
                              });
                            },
                          ),
                        )
                      : Container(
                          child: const Text(''),
                        ),
                ],
              ),
            )
          ],
        ),
      ),
    );
  }

  Widget firstCard(
      String imgurl,
      String date,
      String inTime,
      String outTime,
      String workingHrs,
      String pauseHrs,
      String approvalStatus,
      int status,
      String _reason,
      int workType) {
    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20.0)),
      elevation: 5,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: <Widget>[
          Container(
              decoration: new BoxDecoration(
                  color: global.appBottomNavColor,
                  borderRadius: const BorderRadius.only(
                    topLeft: Radius.circular(20),
                    topRight: Radius.circular(20),
                  )),
              padding: const EdgeInsets.all(12),
              child: Row(
                children: <Widget>[
                  Text(
                    DateFormat('yyyy-MM-dd').format(DateTime.parse(date)),
                    textAlign: TextAlign.left,
                    style: TextStyle(
                        fontSize: ScreenUtil().setSp(15),
                        fontWeight: FontWeight.w600,
                        fontFamily: font,
                        color: Colors.white),
                  ),
                  Expanded(
                    child: Container(
                      child: const Text(''),
                    ),
                  ),
                  (approvalStatus.toLowerCase() == 'pending')
                      ? GestureDetector(
                          child: Row(
                            children: <Widget>[
                              Text(
                                // 'Request Status: $approvalStatus',
                                status == 0
                                    ? 'Request Status: Absent'
                                    : 'Request Status: Present',
                                style: TextStyle(
                                    fontSize: ScreenUtil().setSp(12),
                                    fontWeight: FontWeight.w600,
                                    color: Colors.white,
                                    fontFamily: font),
                              ),
                              const SizedBox(
                                width: 5,
                              ),
                              Visibility(
                                visible: isVisible,
                                child: Icon(
                                  Icons.edit,
                                  size: ScreenUtil().setSp(20),
                                  color: Colors.white,
                                ),
                              )
                            ],
                          ),
                          onTap: () async {
                            Map results = await Navigator.of(context)
                                .push(MaterialPageRoute(
                              builder: (BuildContext context) {
                                return AttendanceRequest(
                                  scaffoldKey: widget.scaffoldKey,
                                  title: 'Request for Attendance',
                                  date: _currentDate2,
                                  inTime: DateTime.parse(inTime).toLocal(),
                                  outTime: DateTime.parse(outTime).toLocal(),
                                  reason: _reason,
                                  // workType: workType,
                                );
                              },
                            ));

                            if (results.containsKey('reload')) {
                              apiCallForGetAttendanceOfMonth();
                              apiCallForGetAttendanceForSelectedDate();
                            }
                          },
                        )
                      : Container(
                          child: const Text(''),
                        )
                ],
              )),
          Container(
              decoration: const BoxDecoration(
                  borderRadius: BorderRadius.only(
                      bottomLeft: Radius.circular(20),
                      bottomRight: Radius.circular(20))),
              padding: const EdgeInsets.all(12),
              child: Row(
                children: <Widget>[
                  Flexible(
                    child: PhysicalModel(
                        clipBehavior: Clip.antiAliasWithSaveLayer,
                        color: Colors.black,
                        shape: BoxShape.rectangle,
                        borderRadius: BorderRadius.circular(10),
                        child: CachedNetworkImage(
                          imageUrl: imgurl,
                          fit: BoxFit.fill,
                          width: ScreenUtil().setSp(90.0),
                          height: ScreenUtil().setSp(90.0),
                          placeholder: (context, url) =>
                              const Center(child: CircularProgressIndicator()),
                          errorWidget: (context, url, error) => Container(
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(20),
                              image: const DecorationImage(
                                  image:
                                      AssetImage('assets/image/aipex_logo.png'),
                                  fit: BoxFit.cover),
                            ),
                          ),
                        )),
                  ),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      Padding(
                        padding: EdgeInsets.only(left: ScreenUtil().setSp(10)),
                        child: Container(
                          child: Row(
                            children: <Widget>[
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: <Widget>[
                                  Text(
                                    'In Time',
                                    style: TextStyle(
                                      color: global.colorText,
                                      fontFamily: font,
                                    ),
                                  ),
                                  const SizedBox(
                                    height: 5,
                                  ),
                                  Text(
                                    DateFormat('hh:mm a').format(
                                        DateFormat("yyyy-MM-dd HH:mm:ss")
                                            .parse(inTime, true)
                                            .toLocal()),
                                    style: TextStyle(
                                      color: global.colorText,
                                      fontFamily: font,
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                  const SizedBox(
                                    height: 5,
                                  ),
                                  Text(
                                    'Out Time',
                                    style: TextStyle(
                                        color: global.colorText,
                                        fontFamily: font),
                                  ),
                                  const SizedBox(
                                    height: 5,
                                  ),
                                  Text(
                                    DateFormat('hh:mm a').format(
                                        DateFormat("yyyy-MM-dd HH:mm:ss")
                                            .parse(outTime, true)
                                            .toLocal()),
                                    style: TextStyle(
                                        color: global.colorText,
                                        fontFamily: font,
                                        fontWeight: FontWeight.w500),
                                  ),
                                ],
                              ),
                              const SizedBox(width: 15),
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: <Widget>[
                                  Text(
                                    'Total Pause Hours',
                                    style: TextStyle(
                                        color: global.colorText,
                                        fontFamily: font),
                                  ),
                                  const SizedBox(
                                    height: 5,
                                  ),
                                  Text(
                                    pauseHrs,
                                    style: TextStyle(
                                        color: global.colorText,
                                        fontFamily: font,
                                        fontWeight: FontWeight.w500),
                                  ),
                                  const SizedBox(
                                    height: 5,
                                  ),
                                  Text(
                                    'Total Working Hours',
                                    style: TextStyle(
                                        color: global.colorText,
                                        fontFamily: font),
                                  ),
                                  const SizedBox(
                                    height: 5,
                                  ),
                                  Text(
                                    workingHrs,
                                    style: TextStyle(
                                        color: global.colorText,
                                        fontFamily: font,
                                        fontWeight: FontWeight.w500),
                                  ),
                                ],
                              )
                            ],
                          ),
                        ),
                      )
                    ],
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
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20.0)),
      elevation: 5,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: <Widget>[
          Container(
              decoration: const BoxDecoration(
                  borderRadius: BorderRadius.only(
                      bottomLeft: Radius.circular(20),
                      bottomRight: Radius.circular(20))),
              padding: const EdgeInsets.all(12),
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
                        color: global.appPrimaryColor,
                        fontFamily: font),
                    textAlign: TextAlign.left,
                  ),
                  Text(
                    reason,
                    style: const TextStyle(
                        fontWeight: FontWeight.bold, fontFamily: font),
                    maxLines: null,
                    textAlign: TextAlign.left,
                  ),

                  SizedBox(
                    height: ScreenUtil().setSp(6),
                  ),
                  // )
                  Row(
                    children: const <Widget>[
                      Expanded(
                        child: Text(
                          'Start Time',
                          style: TextStyle(fontFamily: font),
                        ),
                      ),
                      Expanded(
                        child: Text('End Time',
                            style: TextStyle(fontFamily: font)),
                      ),
                      Expanded(
                        child: Text('Total Time',
                            style: TextStyle(fontFamily: font)),
                      ),
                    ],
                  ),
                  Row(
                    children: <Widget>[
                      Expanded(
                        child: Text(startTime,
                            style: TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: ScreenUtil().setSp(14),
                                fontFamily: font)),
                      ),
                      Expanded(
                        child: Text(endTime,
                            style: TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: ScreenUtil().setSp(14),
                                fontFamily: font)),
                      ),
                      Expanded(
                        child: Text(total,
                            style: TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: ScreenUtil().setSp(14),
                                fontFamily: font)),
                      ),
                    ],
                  ),
                ],
              )),
          // Container(
          //   color: global.appPrimaryColor,
          //   height: 2.0,
          // )
        ],
      ),
    );
  }

  Widget getCustomHeader() {
    return PreferredSize(
      preferredSize:
          Size(MediaQuery.of(context).size.width, ScreenUtil().setSp(250)),
      child: Container(
        width: MediaQuery.of(context).size.width,
        height: 250,
        decoration: BoxDecoration(
              color: Colors.transparent,
              image: DecorationImage(
                  image: AssetImage('assets/image/navigation_bg.png'),
                  fit: BoxFit.fill),
            ),
        child: ClipRRect(
          borderRadius: const BorderRadius.only(
            bottomLeft: Radius.circular(50),
          ),
          child: Container(
            // color: appColorFour,
            child: Column(
              children: <Widget>[
                Container(
                  margin: EdgeInsets.fromLTRB(
                      ScreenUtil().setSp(10),
                      ScreenUtil().setSp(50),
                      ScreenUtil().setSp(10),
                      ScreenUtil().setSp(0)),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      GestureDetector(
                        child: Icon(
                          Icons.menu,
                          size: ScreenUtil().setSp(30),
                          color: Colors.white,
                        ),
                        onTap: () {
                          print('click ');
                          if (widget.scaffoldKey.currentState.isDrawerOpen) {
                            widget.scaffoldKey.currentState.openEndDrawer();
                          } else {
                            widget.scaffoldKey.currentState.openDrawer();
                          }
                        },
                      ),
                      Text(
                        widget.title,
                        style: TextStyle(
                            fontSize: ScreenUtil().setSp(22),
                            color: Colors.white,
                            fontFamily: font),
                      ),
                      GestureDetector(
                        child: Icon(
                          CommunityMaterialIcons.filter,
                          size: ScreenUtil().setSp(30),
                          color: Colors.white,
                        ),
                        onTap: () {
                          isLoadAPI = 0;
                          checkInternet();
                          _fromDate = '';
                          _toDate = '';
                          showFilterDialog();
                        },
                      ),
                    ],
                  ),
                ),
                const SizedBox(
                  height: 20.0,
                )
              ],
            ),
          ),
        ),
      ),
    );
  }

  // Future _selectFromDateAttendance() async {
  //   DateTime? _picked = await showDatePicker(
  //       context: context,
  //       initialDate: new DateTime.now(),
  //       firstDate: new DateTime(2016),
  //       lastDate: new DateTime(2025));
  //   setState(() {
  //     _fromDate = new DateFormat('yyyy-MM-dd').format(_picked!);
  //     Navigator.of(context).pop();
  //     showFilterDialog();
  //   });
  // }
  Future _selectFromDateAttendance() async {
  DateTime today = DateTime.now();
  DateTime? _picked = await showDatePicker(
    context: context,
    initialDate: today,
    firstDate: DateTime(2016),
    lastDate: today, // <- Fix here
  );

  if (_picked != null) {
    setState(() {
      _fromDate = DateFormat('yyyy-MM-dd').format(_picked);
      Navigator.of(context).pop();
      showFilterDialog();
    });
  }
}

  Future _selectToDateAttendance() async {
      DateTime today = DateTime.now();

    DateTime? _picked = await showDatePicker(
        context: context,
        initialDate: today,
        firstDate:  DateTime(2016),
        lastDate: today);
         if (_picked != null) {
    setState(() {
      _toDate = new DateFormat('yyyy-MM-dd').format(_picked);
      Navigator.of(context).pop();
      showFilterDialog();
    });
         }
  }

  void logout() async {
    final SharedPreferences prefs = await _prefs;
    prefs.clear();
    // ignore: use_build_context_synchronously
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

  void showFilterDialog() {
    showDialog(
        context: context,
        builder: (BuildContext context) {
          return StatefulBuilder(builder: (context, setState) {
            return AlertDialog(
              contentPadding: const EdgeInsets.all(0),
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.all(
                      Radius.circular(ScreenUtil().setSp(10)))),
              content: Container(
                decoration: new BoxDecoration(
                    color: global.appBackground,
                    borderRadius: new BorderRadius.all(
                        Radius.circular(ScreenUtil().setSp(10)))),
                padding: EdgeInsets.only(bottom: ScreenUtil().setSp(10)),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: <Widget>[
                    Container(
                        decoration: new BoxDecoration(
                            color: global.appPrimaryColor,
                            borderRadius: const BorderRadius.only(
                                topLeft: Radius.circular(10),
                                topRight: Radius.circular(10))),
                        padding: const EdgeInsets.all(15),
                        child: Text(
                          'Select date to filter.',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                              fontSize: ScreenUtil().setSp(16),
                              fontWeight: FontWeight.w600,
                              fontFamily: font,
                              color: appWhiteColor),
                        )),
                    Padding(
                      padding: EdgeInsets.only(
                          left: ScreenUtil().setSp(20),
                          top: ScreenUtil().setSp(20)),
                      child: Text(
                        'Select From Date : ',
                        style: TextStyle(
                            color: global.colorText, fontFamily: font),
                      ),
                    ),
                    Container(
                      padding: EdgeInsets.only(
                          left: ScreenUtil().setSp(20),
                          right: ScreenUtil().setSp(20)),
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: appWhiteColor,
                          elevation: 0,
                          shape: RoundedRectangleBorder(
                              borderRadius: new BorderRadius.circular(25)),
                        ),
                        child: Row(
                          children: <Widget>[
                            Icon(
                              Icons.calendar_today,
                              color: global.appPrimaryColor,
                              size: ScreenUtil().setSp(15),
                            ),
                            SizedBox(
                              width: ScreenUtil().setSp(5),
                            ),
                            Text(
                              _fromDate,
                              style: TextStyle(
                                  color: global.colorText, fontFamily: font),
                            ),
                          ],
                        ),
                        onPressed: () {
                          _selectFromDateAttendance();
                        },
                      ),
                    ),
                    Padding(
                      padding: EdgeInsets.only(
                        left: ScreenUtil().setSp(20),
                        top: ScreenUtil().setSp(10),
                      ),
                      child: Text(
                        'Select To Date : ',
                        style: TextStyle(
                            color: global.colorText, fontFamily: font),
                      ),
                    ),
                    Container(
                      padding: EdgeInsets.only(
                          bottom: ScreenUtil().setSp(20),
                          left: ScreenUtil().setSp(20),
                          right: ScreenUtil().setSp(20)),
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: appWhiteColor,
                          elevation: 0,
                          shape: RoundedRectangleBorder(
                            borderRadius: new BorderRadius.circular(25),
                          ),
                        ),
                        child: Row(
                          children: <Widget>[
                            Icon(
                              Icons.calendar_today,
                              color: global.appPrimaryColor,
                              size: ScreenUtil().setSp(15),
                            ),
                            SizedBox(
                              width: ScreenUtil().setSp(5),
                            ),
                            Text(
                              _toDate,
                              style: TextStyle(
                                  color: global.colorText, fontFamily: font),
                            ),
                          ],
                        ),
                        onPressed: () {
                          setState(() {
                            _selectToDateAttendance();
                          });
                        },
                      ),
                    ),
                    Container(
                      padding: EdgeInsets.only(
                        left: ScreenUtil().setSp(35),
                        right: ScreenUtil().setSp(35),
                      ),
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                            backgroundColor: global.btnBgColor,
                            shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(20.0))),
                        child: Text(
                          'Submit',
                          style: TextStyle(
                              color: appWhiteColor,
                              fontSize: ScreenUtil().setSp(15),
                              fontWeight: FontWeight.bold),
                        ),
                        onPressed: () {
                          setState(() {
                            print(
                                "data-------------------data-----------data------");
                            if (_fromDate.isEmpty || _fromDate == '') {
                              showCenterToast("Please Select Form Date");
                            } else if (_toDate.isEmpty || _toDate == '') {
                              showCenterToast("Please Select To Date");
                            } else if (_fromDate.compareTo(_toDate) > 0) {
                              // print("DxT1 is before DT2");
                              showCenterToast(
                                  "To Date should be equal or greater than From Date");
                            } else {
                              // apiCallForGetAttendanceOfMonth();
                              isLoadAPI = 1;
                              checkInternet();
                              // saveData();
                              Navigator.of(context).pop();
                            }
                          });
                        },
                      ),
                    ),
                  ],
                ),
              ),
            );
          });
        });
  }

  Widget getIntroView() {
    return Padding(
      padding:
          const EdgeInsets.only(left: 20.0, right: 20.0, top: 10, bottom: 10),
      child: Card(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        child: Padding(
          padding: const EdgeInsets.all(12.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: <Widget>[
              Row(
                children: <Widget>[
                  const SizedBox(
                    width: 10.0,
                  ),
                  Expanded(
                    child: Row(
                      children: <Widget>[
                        Container(
                          margin: const EdgeInsets.symmetric(horizontal: 1.0),
                          decoration: const BoxDecoration(
                              color: Colors.green,
                              borderRadius:
                                  BorderRadius.all(Radius.circular(10))),
                          height: 8,
                          width: 8,
                        ),
                        const SizedBox(
                          width: 5.0,
                        ),
                        Text(
                          'Present',
                          style: TextStyle(
                              color: global.colorText, fontFamily: font),
                        ),
                      ],
                    ),
                  ),
                  Expanded(
                    child: Row(
                      children: <Widget>[
                        Container(
                          margin: const EdgeInsets.symmetric(horizontal: 1.0),
                          // color: Colors.red,
                          decoration: const BoxDecoration(
                              color: Colors.red,
                              borderRadius:
                                  BorderRadius.all(Radius.circular(10))),
                          height: 8,
                          width: 8,
                        ),
                        const SizedBox(
                          width: 5.0,
                        ),
                        Text(
                          'Absent',
                          style: TextStyle(
                              color: global.colorText, fontFamily: font),
                        ),
                      ],
                    ),
                  ),
                  Expanded(
                    child: Row(
                      children: <Widget>[
                        Container(
                          margin: const EdgeInsets.symmetric(horizontal: 1.0),
                          // color: Colors.indigo,
                          decoration: const BoxDecoration(
                              color: Colors.indigo,
                              borderRadius:
                                  BorderRadius.all(Radius.circular(10))),
                          height: 8,
                          width: 8,
                        ),
                        const SizedBox(
                          width: 5.0,
                        ),
                        Text(
                          'On Leave',
                          style: TextStyle(
                              color: global.colorText, fontFamily: font),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(
                height: 5.0,
              ),
              Row(
                children: <Widget>[
                  const SizedBox(
                    width: 10.0,
                  ),
                  Expanded(
                    child: Row(
                      children: <Widget>[
                        Container(
                          margin: const EdgeInsets.symmetric(horizontal: 1.0),
                          // color: Colors.yellow,
                          decoration: const BoxDecoration(
                              color: Colors.yellow,
                              borderRadius:
                                  BorderRadius.all(Radius.circular(10))),
                          height: 8,
                          width: 8,
                        ),
                        const SizedBox(
                          width: 5.0,
                        ),
                        Text(
                          'Holiday',
                          style: TextStyle(
                              color: global.colorText, fontFamily: font),
                        ),
                      ],
                    ),
                  ),
                  Expanded(
                    child: Row(
                      children: <Widget>[
                        Container(
                          margin: const EdgeInsets.symmetric(horizontal: 1.0),
                          // color: Colors.blueGrey,
                          decoration: const BoxDecoration(
                              color: Colors.blueGrey,
                              borderRadius:
                                  BorderRadius.all(Radius.circular(10))),
                          height: 8,
                          width: 8,
                        ),
                        const SizedBox(
                          width: 5.0,
                        ),
                        Text(
                          'Weekoff',
                          style: TextStyle(
                              color: global.colorText, fontFamily: font),
                        ),
                      ],
                    ),
                  ),
                  Expanded(
                    child: Row(
                      children: <Widget>[
                        Container(
                          margin: const EdgeInsets.symmetric(horizontal: 1.0),
                          color: Colors.white,
                          height: 8,
                          width: 8,
                        ),
                        const SizedBox(
                          width: 5.0,
                        ),
                        const Text(''),
                      ],
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget getCalendarView() {
    EventList<Event> _markedDateMap = new EventList<Event>(
      events: {
        new DateTime(2022, 12, 10): [
          new Event(
            date: new DateTime(2022, 12, 10),
            title: 'Event 1',
            icon: const Icon(Icons.person),
            dot: Container(
              margin: const EdgeInsets.symmetric(horizontal: 1.0),
              // color: Colors.red,
              height: 5.0,
              width: 5.0,
            ),
          ),
        ],
      },
    );
    if (_attendanceListApiCallBack?.items!.isNotEmpty ?? false) {
      for (var i = 0; i < _attendanceListApiCallBack!.items!.length; i++) {
        final DateTime myDate =
            DateTime.parse(_attendanceListApiCallBack!.items![i].punchDate!);
        final int year = myDate.year;
        final int month = myDate.month;
        final int day = myDate.day;

        //FOR Week-off
        if (_attendanceListApiCallBack!.items![i].isWeeklyOff == "true") {
          _markedDateMap.add(
            new DateTime(year, month, day),
            Event(
              date: new DateTime(year, month, day),
              title: 'Week-off',
              dot: Container(
                margin: const EdgeInsets.symmetric(horizontal: 1.0),
                // color: Colors.blueGrey,
                decoration: const BoxDecoration(
                    color: Colors.blueGrey,
                    borderRadius: BorderRadius.all(Radius.circular(10))),
                height: 5,
                width: 5,
              ),
            ),
          );
        }
        if (_attendanceListApiCallBack!.items![i].isHoliday == "true") {
          _markedDateMap.add(
              new DateTime(year, month, day),
              Event(
                  date: new DateTime(year, month, day),
                  title: 'Holiday',
                  dot: Container(
                    margin: const EdgeInsets.symmetric(horizontal: 1.0),
                    // color: Colors.yellow,
                    decoration: const BoxDecoration(
                        color: Colors.yellow,
                        borderRadius: BorderRadius.all(Radius.circular(10))),
                    height: 5,
                    width: 5,
                  )));
        }
        if (_attendanceListApiCallBack!.items![i].isOnLeave == "true") {
          _markedDateMap.add(
              new DateTime(year, month, day),
              Event(
                  date: new DateTime(year, month, day),
                  title: 'On Leave',
                  dot: Container(
                    margin: const EdgeInsets.symmetric(horizontal: 1.0),
                    // color: Colors.indigo,
                    decoration: const BoxDecoration(
                        color: Colors.indigo,
                        borderRadius: BorderRadius.all(Radius.circular(10))),
                    height: 5,
                    width: 5,
                  )));
        } else {
          if (_attendanceListApiCallBack!.items![i].isPresent == "true") {
            _markedDateMap.add(
                new DateTime(year, month, day),
                Event(
                    date: new DateTime(year, month, day),
                    title: 'Event title',
                    dot: Container(
                      margin: const EdgeInsets.symmetric(horizontal: 1.0),
                      // color: Colors.green,
                      decoration: const BoxDecoration(
                          color: Colors.green,
                          borderRadius: BorderRadius.all(Radius.circular(10))),
                      height: 5,
                      width: 5,
                    )));
          } else if (_attendanceListApiCallBack!.items![i].isHoliday != "true" &&
              _attendanceListApiCallBack!.items![i].isWeeklyOff != "true" &&
              _attendanceListApiCallBack!.items![i].isPresent != "true") {
            _markedDateMap.add(
                new DateTime(year, month, day),
                Event(
                    date: new DateTime(year, month, day),
                    title: 'Event title',
                    dot: Container(
                      margin: const EdgeInsets.symmetric(horizontal: 1.0),
                      // color: Colors.red,
                      decoration: const BoxDecoration(
                          color: Colors.red,
                          borderRadius: BorderRadius.all(Radius.circular(10))),
                      height: 5,
                      width: 5,
                    )));
          }
        }
      }

      _calendarCarousel = CalendarCarousel<Event>(
        todayBorderColor: Colors.blue,
        onDayPressed: (DateTime date, List<Event> events) {
          print('pressed date $date');
          setState(
            () => _currentDate2 = date,
          );
          selectedDate = DateFormat('yyyy-MM-dd').format(_currentDate2);
          apiCallForGetAttendanceForSelectedDate();
        },
        staticSixWeekFormat: true,
        markedDatesMap: _markedDateMap,
        weekendTextStyle: const TextStyle(color: Colors.red),
        thisMonthDayBorderColor: Colors.grey,
        height: ScreenUtil().setSp(320),
        selectedDateTime: _currentDate2,
        targetDateTime: _targetDateTime,
        customGridViewPhysics: const NeverScrollableScrollPhysics(),
        showHeader: false,
        todayTextStyle: const TextStyle(
          color: Colors.white,
        ),
        todayButtonColor: Colors.blue,
        selectedDayTextStyle: const TextStyle(
          color: Colors.white,
        ),
        selectedDayButtonColor: global.appAccentColor,
        minSelectedDate: _currentDate.subtract(const Duration(days: 360)),
        maxSelectedDate: _currentDate.add(const Duration(days: 360)),
        prevDaysTextStyle: const TextStyle(
          fontSize: 16,
          color: Colors.grey,
        ),
        inactiveDaysTextStyle: const TextStyle(
          color: Colors.grey,
          fontSize: 16,
        ),
        onCalendarChanged: (DateTime date) {
          setState(() {
            _targetDateTime = date;
            _currentMonth = DateFormat.yMMM().format(_targetDateTime);
          });
        },
      );
      print("hi m here");
      return Column(
        children: <Widget>[
          Card(
              margin: EdgeInsets.only(
                  left: ScreenUtil().setSp(20),
                  right: ScreenUtil().setSp(20),
                  top: ScreenUtil().setSp(10),
                  bottom: ScreenUtil().setSp(10)),
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20.0),
                  side:
                      BorderSide(width: 0.5, color: global.appBottomNavColor)),
              child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: <Widget>[
                    Container(
                      decoration: BoxDecoration(
                          color: global.appBottomNavColor,
                          borderRadius: const BorderRadius.only(
                              topLeft: Radius.circular(20),
                              topRight: Radius.circular(20))),
                      padding: const EdgeInsets.all(12),
                      child: Container(
                        margin: EdgeInsets.only(
                          left: ScreenUtil().setSp(10),
                          right: ScreenUtil().setSp(10),
                        ),
                        child: Row(
                          children: <Widget>[
                            ElevatedButton(
                              style: ElevatedButton.styleFrom(
                                backgroundColor: global.btnBgColor,
                                shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(25.0)),
                              ),
                              child: const Text(
                                'PREV',
                                style: TextStyle(
                                    color: appWhiteColor, fontFamily: font),
                              ),
                              onPressed: () {
                                setState(() {
                                  _targetDateTime = DateTime(
                                      _targetDateTime.year,
                                      _targetDateTime.month - 1);
                                  _currentMonth =
                                      DateFormat.yMMM().format(_targetDateTime);
                                  _startDate = DateTime(_targetDateTime.year,
                                      _targetDateTime.month, 1);
                                  _endDate = DateTime(_targetDateTime.year,
                                      _targetDateTime.month + 1, 0);
                                  startday = DateFormat('yyyy-MM-dd')
                                      .format(_startDate);
                                  endday =
                                      DateFormat('yyyy-MM-dd').format(_endDate);

                                  String cmonth =
                                      DateFormat.yMMM().format(DateTime.now());
                                  if (_currentMonth == cmonth) {
                                    apiCallForGetAttendanceForMonth(
                                        startday, selectedDate);
                                  } else {
                                    apiCallForGetAttendanceForMonth(
                                        startday, endday);
                                  }
                                });
                              },
                            ),
                            Expanded(
                                child: Text(
                              _currentMonth,
                              style: TextStyle(
                                fontWeight: FontWeight.w600,
                                color: Colors.white,
                                fontSize: ScreenUtil().setSp(20),
                              ),
                              textAlign: TextAlign.center,
                            )),
                            ElevatedButton(
                              style: ElevatedButton.styleFrom(
                                backgroundColor: global.btnBgColor,
                                shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(25.0)),
                              ),
                              child: const Text(
                                'NEXT',
                                style: TextStyle(
                                    color: appWhiteColor, fontFamily: font),
                              ),
                              onPressed: () {
                                setState(() {
                                  _targetDateTime = DateTime(
                                      _targetDateTime.year,
                                      _targetDateTime.month + 1);
                                  _currentMonth =
                                      DateFormat.yMMM().format(_targetDateTime);

                                  _startDate = DateTime(_targetDateTime.year,
                                      _targetDateTime.month, 1);
                                  _endDate = DateTime(_targetDateTime.year,
                                      _targetDateTime.month + 1, 0);
                                  startday = DateFormat('yyyy-MM-dd')
                                      .format(_startDate);
                                  endday =
                                      DateFormat('yyyy-MM-dd').format(_endDate);

                                  String cmonth =
                                      DateFormat.yMMM().format(DateTime.now());
                                  if (_currentMonth == cmonth) {
                                    apiCallForGetAttendanceForMonth(
                                        startday, selectedDate);
                                  } else {
                                    apiCallForGetAttendanceForMonth(
                                        startday, endday);
                                  }
                                });
                              },
                            )
                          ],
                        ),
                      ),
                    ),
                    Container(
                        decoration: const BoxDecoration(
                            borderRadius: BorderRadius.only(
                                bottomLeft: Radius.circular(20),
                                bottomRight: Radius.circular(20))),
                        padding: const EdgeInsets.all(12),
                        child: _calendarCarousel),
                  ]))
        ],
      );
    } else {
      return Container(child: const Text(''));
    }
  }

  Widget getAttendanceOfTheDayView() {
    return (_dayAttendanceListApi?.attendanceItems?.attendanceDetails.isNotEmpty == true)
        ? ListView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemBuilder: (BuildContext context, int index) {
              return Padding(
                padding: EdgeInsets.only(
                    left: ScreenUtil().setSp(20),
                    right: ScreenUtil().setSp(20),
                    top: ScreenUtil().setSp(5),
                    bottom: ScreenUtil().setSp(10)),
                child: Column(
                  children: <Widget>[
                    (index == 0)
                        ? firstCard(
                            _dayAttendanceListApi!.attendanceItems!
                                .attendanceDetails[0].attachment!,
                            _dayAttendanceListApi!
                                .attendanceItems!.attendanceDetails[0].punchDate!,
                            _dayAttendanceListApi!
                                .attendanceItems!.attendanceDetails[0].inTime!,
                            _dayAttendanceListApi!
                                .attendanceItems!.attendanceDetails[0].outTime!,
                            '${_dayAttendanceListApi!.attendanceItems!.attendanceDetails[0].totalWorkingHours}',
                            '${_dayAttendanceListApi!.attendanceItems!.attendanceDetails[0].totalPauseHours}',
                            _dayAttendanceListApi!.attendanceItems!
                                .attendanceDetails[0].approvalStatus ?? "",
                            _dayAttendanceListApi!
                                .attendanceItems!.attendanceDetails[0].status!,
                            _dayAttendanceListApi!
                                .attendanceItems!.attendanceDetails[0].reason ?? "",
                            _dayAttendanceListApi!
                                .attendanceItems!.attendanceDetails[0].type_id!,
                          )
                        : pauseCard(
                            '${DateFormat('hh:mm a').format(DateFormat("yyyy-MM-dd HH:mm:ss").parse(_dayAttendanceListApi!.attendanceItems!.attendanceDetails[index].inTime!, true).toLocal())}',
                            (_dayAttendanceListApi!.attendanceItems!
                                        .attendanceDetails[index].outTime ==
                                    '')
                                ? ''
                                : '${DateFormat('hh:mm a').format(DateFormat("yyyy-MM-dd HH:mm:ss").parse(_dayAttendanceListApi!.attendanceItems!.attendanceDetails[index].outTime!, true).toLocal())}',
                            (_dayAttendanceListApi!.attendanceItems!
                                        .attendanceDetails[index].outTime ==
                                    '')
                                ? ''
                                : '${DateTime.parse(_dayAttendanceListApi!.attendanceItems!.attendanceDetails[index].outTime!).difference(DateTime.parse(_dayAttendanceListApi!.attendanceItems!.attendanceDetails[index].inTime!)).inMinutes} minutes',
                            '${_dayAttendanceListApi!.attendanceItems!.attendanceDetails[index].reason}'),
                  ],
                ),
              );
            },
            itemCount:
                _dayAttendanceListApi!.attendanceItems!.attendanceDetails.length,
          )
        : Container(
            child: Center(
              child: Column(
                children: <Widget>[
                  global.noRecordFound(_noDataFound),
                  const SizedBox(
                    height: 60.0,
                  ),
                  (_noDataFound == noDataFound)
                      ? ElevatedButton(
                          style: ElevatedButton.styleFrom(
                              backgroundColor: global.btnBgColor,
                              shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(20.0))),
                          child: const Text(
                            'Attendance Request',
                            style: TextStyle(
                                color: appWhiteColor, fontFamily: font),
                          ),
                          onPressed: () {
                            _buttonTapped();
                          },
                        )
                      : Container(
                          child: const Text(''),
                        )
                  // : Container(
                  //     child: Text(''),
                  //   )
                ],
              ),
            ),
          );
  }

  Future _buttonTapped() async {
    Map results = await Navigator.of(context).push(new MaterialPageRoute(
      builder: (BuildContext context) {
        return AttendanceRequest(
            scaffoldKey: widget.scaffoldKey,
            title: 'Request for Attendance',
            date: _currentDate2,
            inTime: DateTime.now(), // Provide a default DateTime value
            outTime: DateTime.now(), reason: '', // Provide a default DateTime value
            );
      },
    ));

    if (results.containsKey('reload')) {
      // apiCallForGetLeave('All');
      apiCallForGetAttendanceOfMonth();
      apiCallForGetAttendanceForSelectedDate();
    }
  }
}

void getCurrentPosition() async {
  //permision
  LocationPermission permission = await Geolocator.checkPermission();
  if (permission == LocationPermission.denied ||
      permission == LocationPermission.deniedForever) {
    print("permission not given");
    LocationPermission asked = await Geolocator.requestPermission();
  } else {
    Position currentPosition = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.best);
  }
}

DateTime? getDateTimeFor(String punchDate) {
  try {
    var nDate = new DateTime(
      DateTime.parse(punchDate).year,
      DateTime.parse(punchDate).month,
      DateTime.parse(punchDate).day,
    );

    return nDate;
  } catch (e) {
    showErrorLog(e.toString());
  }
  return null;
}

class AttendanceListApiCallBack {
  List<Item>? items;
  String? message;
  int? status;
  bool? success;
  int? total_count;

  AttendanceListApiCallBack(
      {required this.items, required this.message, required this.status, required this.success, required this.total_count});

  factory AttendanceListApiCallBack.fromJson(Map<String, dynamic> json) {
    return AttendanceListApiCallBack(
      items: json['items'] != null
          ? (json['items'] as List).map((i) => Item.fromJson(i)).toList()
          : [],
      message: json['message'],
      status: json['status'],
      success: json['success'],
      total_count: json['total_count'],
    );
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['message'] = this.message;
    data['status'] = this.status;
    data['success'] = this.success;
    data['total_count'] = this.total_count;
    data['items'] = this.items!.map((v) => v.toJson()).toList();
      return data;
  }
}

class Item {
  String? isFullDay;
  String? isHalfDay;
  String? isHoliday;
  String? isOnLeave;
  String? isPresent;
  String? isWeeklyOff;
  String? punchDate;

  Item(
      {required this.isFullDay,
     required this.isHalfDay,
     required this.isHoliday,
     required this.isOnLeave,
     required this.isPresent,
     required this.isWeeklyOff,
     required this.punchDate});

  factory Item.fromJson(Map<String, dynamic> json) {
    return Item(
      isFullDay: json['isFullDay'],
      isHalfDay: json['isHalfDay'],
      isHoliday: json['isHoliday'],
      isOnLeave: json['isOnLeave'],
      isPresent: json['isPresent'],
      isWeeklyOff: json['isWeeklyOff'],
      punchDate: json['punchDate'],
    );
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['isFullDay'] = this.isFullDay;
    data['isHalfDay'] = this.isHalfDay;
    data['isHoliday'] = this.isHoliday;
    data['isOnLeave'] = this.isOnLeave;
    data['isPresent'] = this.isPresent;
    data['isWeeklyOff'] = this.isWeeklyOff;
    data['punchDate'] = this.punchDate;
    // print(punchDate);
    return data;
  }
}

class CustomDialog extends StatelessWidget {
  final String? title, description, buttonText;
  final Image image;

  CustomDialog({
    required this.title,
    required this.description,
    required this.buttonText,
    required this.image,
  });

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(8.0),
      ),
      elevation: 0.0,
      backgroundColor: Colors.transparent,
      child: Container(
        child: const Text(''),
      ),
    );
  }
}

class AttendanceSingleApiCallBack {
  late int totalCount;
 late bool success;
 late List<Items> items;
 String? message;
 late int status;

  AttendanceSingleApiCallBack(
      {required this.totalCount, required this.success, required this.items, required this.message, required this.status});

  AttendanceSingleApiCallBack.fromJson(Map<String, dynamic> json) {
    totalCount = json['total_count'];
    success = json['success'];
    if (json['items'] != null) {
      items = [];
      json['items'].forEach((v) {
        items.add(new Items.fromJson(v));
      });
    }
    message = json['message'];
    status = json['status'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['total_count'] = this.totalCount;
    data['success'] = this.success;
    data['items'] = this.items.map((v) => v.toJson()).toList();
      data['message'] = this.message;
    data['status'] = this.status;
    return data;
  }
}

class Items {
 late int id;
 late int userId;
 late int punchTypeId;
 String? punchDate;
 String? inTime;
 String? outTime;
 String? startLongitude;
 String? startLatitude;
 String? endLongitute;
 String? endLatitude;
 String? attachment;

  Items(
      {required this.id,
      required this.userId,
      required this.punchTypeId,
     required this.punchDate,
     required this.inTime,
     required this.outTime,
     required this.startLongitude,
     required this.startLatitude,
     required this.endLongitute,
     required this.endLatitude,
     required this.attachment});

  Items.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    userId = json['userId'];
    punchTypeId = json['punchTypeId'];
    punchDate = json['punchDate'];
    inTime = json['inTime'];
    outTime = json['outTime'];
    startLongitude = json['startLongitude'];
    startLatitude = json['startLatitude'];
    endLongitute = json['endLongitute'];
    endLatitude = json['endLatitude'];
    attachment = json['attachment'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['id'] = this.id;
    data['userId'] = this.userId;
    data['punchTypeId'] = this.punchTypeId;
    data['punchDate'] = this.punchDate;
    data['inTime'] = this.inTime;
    data['outTime'] = this.outTime;
    data['startLongitude'] = this.startLongitude;
    data['startLatitude'] = this.startLatitude;
    data['endLongitute'] = this.endLongitute;
    data['endLatitude'] = this.endLatitude;
    data['attachment'] = this.attachment;
    return data;
  }
}

class DayAttendanceListApi {
  AttendanceItems? attendanceItems;
  String? message;
  int? status;
  bool success;
  int? total_count;

  DayAttendanceListApi({
    required this.attendanceItems,
    required this.message,
    required this.status,
    required this.success,
    required this.total_count,
  });

  factory DayAttendanceListApi.fromJson(Map<String, dynamic> json) {
    return DayAttendanceListApi(
      attendanceItems: json['items'] != null
          ? AttendanceItems.fromJson(json['items'])
          : null,
      message: json['message'],
      status: json['status'],
      success: json['success'],
      total_count: json['total_count'], // no change needed
    );
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = {};
    data['message'] = this.message;
    data['status'] = this.status;
    data['success'] = this.success;
    data['total_count'] = this.total_count;
    data['attendanceItems'] = this.attendanceItems?.toJson();
    return data;
  }
}

class AttendanceItems {
  List<AttendanceDetail> attendanceDetails;
  String? totalPauseHours;
  String? totalWorkingHours;

  AttendanceItems(
      {required this.attendanceDetails, required this.totalPauseHours, required this.totalWorkingHours});

  factory AttendanceItems.fromJson(Map<String, dynamic> json) {
    return AttendanceItems(
      attendanceDetails: json['attendanceDetails'] != null
          ? (json['attendanceDetails'] as List)
              .map((i) => AttendanceDetail.fromJson(i))
              .toList()
          : [],
      totalPauseHours: json['totalPauseHours'],
      totalWorkingHours: json['totalWorkingHours'],
    );
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['totalPauseHours'] = this.totalPauseHours;
    data['totalWorkingHours'] = this.totalWorkingHours;
    data['attendanceDetails'] =
        this.attendanceDetails.map((v) => v.toJson()).toList();
      return data;
  }
}

class AttendanceDetail {
  String? attachment;
  String? attendance;
  String? endLatitude;
  String? endLongitute;
  String? inTime;
  String? outTime;
  String? punchDate;
  int? punchTypeId;
  String? reason;
  String? startLatitude;
  String? startLongitude;
  String? totalPauseHours;
  String? totalWorkingHours;
  String? approvalStatus;
  int? status;
  int? userId;
  int? id, type_id;

  AttendanceDetail(
      {required this.attachment,
     required this.attendance,
     required this.endLatitude,
     required this.endLongitute,
     required this.inTime,
     required this.outTime,
     required this.punchDate,
     required this.punchTypeId,
     required this.reason,
     required this.startLatitude,
     required this.startLongitude,
     required this.totalPauseHours,
     required this.totalWorkingHours,
     required this.approvalStatus,
     required this.status,
     required this.userId,
     required this.id,
     required this.type_id});

  factory AttendanceDetail.fromJson(Map<String, dynamic> json) {
    return AttendanceDetail(
      attachment: json['attachment'] != null ? json['attachment'] : null,
      attendance: json['attendance'],
      endLatitude: json['endLatitude'],
      endLongitute: json['endLongitute'],
      inTime: json['inTime'],
      outTime: json['outTime'],
      punchDate: json['punchDate'],
      punchTypeId: json['punchTypeId'],
      reason: json['reason'] != null ? json['reason'] : null,
      startLatitude: json['startLatitude'],
      startLongitude: json['startLongitude'],
      totalPauseHours: json['totalPauseHours'],
      totalWorkingHours: json['totalWorkingHours'],
      approvalStatus:
          json['approval_status'] != null ? json['approval_status'] : null,
      status: json['status'] != null ? json['status'] : null,
      userId: json['userId'],
      id: json['id'],
      type_id: json['type_id'],
    );
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['attendance'] = this.attendance;
    data['endLatitude'] = this.endLatitude;
    data['endLongitute'] = this.endLongitute;
    data['inTime'] = this.inTime;
    data['outTime'] = this.outTime;
    data['punchDate'] = this.punchDate;
    data['punchTypeId'] = this.punchTypeId;
    data['startLatitude'] = this.startLatitude;
    data['startLongitude'] = this.startLongitude;
    data['totalPauseHours'] = this.totalPauseHours;
    data['totalWorkingHours'] = this.totalWorkingHours;
    data['approvalStatus'] = this.approvalStatus;
    data['status'] = this.status;
    data['userId'] = this.userId;
    data['id'] = this.id;
    data['type_id'] = this.type_id;
    data['attachment'] = this.attachment;
      data['reason'] = this.reason;
      return data;
  }
}

