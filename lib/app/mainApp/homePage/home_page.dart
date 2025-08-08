// ignore_for_file: unnecessary_new, unnecessary_const

import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'dart:math';

import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:geolocator/geolocator.dart' as geo;
import 'package:hrms/app/dashboard.dart';
import 'package:hrms/app/mainApp/attendance/view_attendance_list.dart';
import 'package:hrms/app/mainApp/birthday/birthday_screen.dart';
import 'package:hrms/app/mainApp/driver/add_package.dart';
import 'package:hrms/app/mainApp/driver/driver.dart';
import 'package:hrms/app/mainApp/driver/vehicle_details.dart';
import 'package:hrms/app/mainApp/meeting/meeting_list.dart';
import 'package:hrms/app/mainApp/task_manager/add_task.dart';
import 'package:hrms/app/mainApp/task_manager/view_task.dart';
import 'package:hrms/app/uiComponent/custom_header.dart';
import 'package:hrms/appUtil/app_util_config.dart';
import 'package:hrms/appUtil/global.dart' as global;
import 'package:hrms/appUtil/network_util.dart';
import 'package:hrms/app_splash_screen.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';
import 'package:latlong2/latlong.dart' as dist;
import 'package:location/location.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:percent_indicator/circular_percent_indicator.dart';
import 'package:permission_handler/permission_handler.dart' as ph;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:timezone/timezone.dart' as tz;
import 'package:url_launcher/url_launcher.dart';
import 'package:youtube_player_flutter/youtube_player_flutter.dart';
import 'api_call_back.dart';
// import 'package:flutter_qr_code_scaner/flutter_qr_code_scaner.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:timer_builder/timer_builder.dart';
import 'package:loading_btn/loading_btn.dart';
import 'package:fluttertoast/fluttertoast.dart';

class HomePage extends StatefulWidget {
  var scaffoldKey;
  var title;

  HomePage({Key? key, required this.scaffoldKey, required this.title})
      : super(key: key);

  @override
  _HomePageState createState() {
    return _HomePageState();
  }
}

class _HomePageState extends State<HomePage> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  String result = '';
  String deviceId = '0355172100480688';
  int workingMiniutes = 540;

  NetworkUtil _networkUtil = NetworkUtil();
  Future<SharedPreferences> _prefs = SharedPreferences.getInstance();

  final ph.Permission _permission1 = ph.Permission.location;
  PermissionStatus _permissionStatus = PermissionStatus.denied;

  MeetingListApiCallBack? _meetingListApiCallBack;
  String _apiToken = "", _geoBaselatitude = "", _geoBaselongitude = "";
  int _attendanceStatus = 0,
      _attendanceId = 0,
      _attendanceBreakId = 0,
      _isSelfi = 0,
      _isGeofence = 0,
      _isGeotracking = 0,
      _distance = 100,
      _userId = 0,
      _task_manager = 0,
      _companyId = 0,
      _geofenceForWorkingType = 0,
      _driver = 0;
  String _outTime = "",
      _inTime = "",
      _fullInTime = "",
      _fullOutTime = "",
      _totalHours = "00:00",
      _deviceId = "",
      _taskCount = "00"; //,
//      _serverTime = '';
  double _timeCountChart = 0.01, _taskCountChart = 0.01;
  TaskListApiCallBack? _taskList;
  DriverPackageApiCallBack? _driverPackageApiCallBack;
  WorkingTypeApiCallBack? _workingTypeApiCallBack;
  TodaysBirthdayApiCallBack? _todaysBirthdayApiCallBack;
  String? dropDownValue;

  //variable for image capture
   File? _imageFile;
  dynamic _pickImageError;

  ///for location
  Location _locationService = new Location();
  bool _permission = false;
  String? error;
  late LocationData _startLocation;
  late LocationData _pos;

  late geo.Position _currentPosition;
  String _currentAddress = '';
  final dist.Distance distance = const dist.Distance();
  double meter = 0;
  var _noDataFound = 'Loading...';
  String _reason = '-';
  bool isDisabled = false;

  ///for event card
  int _id = 0,
      _driver_delivery = 0,
      _select_bike = 0; //Change G1..._select_bike = 1;
  String? _vehicle_selection_date, _company, _driver_package_date;

  String _title = '',
      msg = '',
      img = '',
      videoCode = '',
      start = '',
      end = '${DateTime.now()}';

  ///for driver
  var formatter = new DateFormat('yyyy-MM-dd');
  String? today;

  late YoutubePlayerController _controller;
  late FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin;

  TextEditingController reasonController = TextEditingController();

  String getSystemTime() {
    var now = new DateTime.now();
    return new DateFormat("hh:mm:ss a").format(now);
  }

  ///TO do by Raghu
  ///replace '@mipmap/ic_launcher' with appicon if want
  void initializeNotification() async {
    try {
      flutterLocalNotificationsPlugin = FlutterLocalNotificationsPlugin();

      // Android initialization
      const AndroidInitializationSettings initializationSettingsAndroid =
          AndroidInitializationSettings('@mipmap/ic_launcher');

      // iOS (Darwin) initialization
      const DarwinInitializationSettings initializationSettingsDarwin =
          DarwinInitializationSettings(
        requestSoundPermission: true,
        requestBadgePermission: true,
        requestAlertPermission: true,
      );

      // Combine platform settings
      const InitializationSettings initializationSettings =
          InitializationSettings(
        android: initializationSettingsAndroid,
        iOS: initializationSettingsDarwin,
      );

      // Initialize plugin with new callback
      await flutterLocalNotificationsPlugin.initialize(
        initializationSettings,
        onDidReceiveNotificationResponse: (NotificationResponse response) {
          debugPrint('Notification clicked with payload: ${response.payload}');
          handleNotificationClick(response.payload);
        },
      );
    } catch (e) {
      debugPrint('Notification initialization error: $e');
    }
  }

  /// Handle notification click
  void handleNotificationClick(String? payload) {
    if (payload != null) {
      debugPrint("Payload received: $payload");
      // Navigate or perform an action based on the payload
    }
  }

  @override
  void initState() {
    super.initState();
    initializeNotification();
    today = formatter.format(DateTime.now());
    getSpData();
    // initLocationState();
    initProjectVersion();
    initApiCall();
    apiCallForBirthdayData();
    apiCallForGetWorkingType();
  }

  @override
  void dispose() {
    super.dispose();
  }

  ///TO DO by Raghu
  ///Please add data(title, body) in schedule function
  ///Change Duration(minutes: 20)
  ///Also add appicon

  Future<void> _scheduleNotificationForPause(String pauseTime) async {
    try {
      var scheduledNotificationDateTime =
          DateTime.parse(pauseTime).add(const Duration(minutes: 45));

      // Vibration pattern for Android
      var vibrationPattern = Int64List(4);
      vibrationPattern[0] = 0;
      vibrationPattern[1] = 1000;
      vibrationPattern[2] = 5000;
      vibrationPattern[3] = 2000;

      // Android channel details
      var androidPlatformChannelSpecifics = AndroidNotificationDetails(
        'resume_channel',
        'Resume Attendance',
        channelDescription: 'Reminder for Resume Attendance',
        vibrationPattern: vibrationPattern,
        enableLights: true,
        importance: Importance.max,
        priority: Priority.high,
        color: const Color.fromARGB(255, 255, 0, 0),
        ledColor: const Color.fromARGB(255, 255, 0, 0),
        ledOnMs: 1000,
        ledOffMs: 500,
      );

      // iOS (Darwin) details
      var iOSPlatformChannelSpecifics = const DarwinNotificationDetails(
        sound: 'slow_spring_board.aiff',
      );

      var platformChannelSpecifics = NotificationDetails(
        android: androidPlatformChannelSpecifics,
        iOS: iOSPlatformChannelSpecifics,
      );

      // Schedule notification
      await flutterLocalNotificationsPlugin.zonedSchedule(
        10,
        'Resume your attendance',
        'Did you forget to resume your attendance? Resume now...',
        tz.TZDateTime.from(scheduledNotificationDateTime, tz.local),
        platformChannelSpecifics,
        androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
        matchDateTimeComponents: DateTimeComponents.time,
      );
    } catch (e) {
      debugPrint("Error scheduling pause notification: $e");
    }
  }

  Future<void> _scheduleNotification(String inTime) async {
    try {
      var scheduledNotificationDateTime =
          DateTime.parse(inTime).add(const Duration(hours: 9, minutes: 30));

      debugPrint(
          "Scheduling stop attendance notification at $scheduledNotificationDateTime");

      // Vibration pattern
      var vibrationPattern = Int64List(4);
      vibrationPattern[0] = 0;
      vibrationPattern[1] = 1000;
      vibrationPattern[2] = 5000;
      vibrationPattern[3] = 2000;

      var androidPlatformChannelSpecifics = AndroidNotificationDetails(
        'stop_attendance_channel',
        'Stop Attendance',
        channelDescription: 'Reminder to stop attendance',
        importance: Importance.max,
        priority: Priority.high,
        ticker: 'ticker',
        vibrationPattern: vibrationPattern,
        enableLights: true,
        color: const Color.fromARGB(255, 255, 0, 0),
        ledColor: const Color.fromARGB(255, 255, 0, 0),
        ledOnMs: 1000,
        ledOffMs: 500,
      );

      var iOSPlatformChannelSpecifics = const DarwinNotificationDetails();

      var platformChannelSpecifics = NotificationDetails(
        android: androidPlatformChannelSpecifics,
        iOS: iOSPlatformChannelSpecifics,
      );

      await flutterLocalNotificationsPlugin.zonedSchedule(
        1,
        'Stop your attendance',
        'You have not stopped your attendance today. Please check.',
        tz.TZDateTime.from(scheduledNotificationDateTime, tz.local),
        platformChannelSpecifics,
        androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
        matchDateTimeComponents: DateTimeComponents.time,
      );
    } catch (e) {
      debugPrint("Error scheduling stop attendance notification: $e");
    }
  }

  // Future<void> _showNotification() async {
  //   var androidPlatformChannelSpecifics = AndroidNotificationDetails(
  //       'your channel id', 'your channel name', 'your channel description',
  //       importance: Importance.Max, priority: Priority.High, ticker: 'ticker');
  //   var iOSPlatformChannelSpecifics = IOSNotificationDetails();
  //   var platformChannelSpecifics = NotificationDetails(
  //       androidPlatformChannelSpecifics, iOSPlatformChannelSpecifics);
  //   await flutterLocalNotificationsPlugin.show(
  //       0, 'plain title', 'plain body', platformChannelSpecifics,
  //       payload: 'item x');
  // }
  // currentProgressColor() {
  //   if (_timeCountChart % 2 == 0) {
  //     return global.appPrimaryColor;
  //   } else {
  //     return appWhiteColor;
  //   }
  // }

  @override
  Widget build(BuildContext context) {
    _totalHoursShow();
    // TODO: implement build
    return Container(
      color: global.appBackground,
      child: RefreshIndicator(
        color: global.appPrimaryColor,
        onRefresh: () async {
          setState(() {});
        },
        child: GestureDetector(
          onTap: () {
            FocusScope.of(context).requestFocus(new FocusNode());
          },
          child: Stack(
            children: <Widget>[
              CustomHeader(
                scaffoldKey: widget.scaffoldKey,
                title: widget.title,
                // height: 250,
              ),
              Container(
                margin: const EdgeInsets.only(top: 85.0),
                child: ListView(
                  children: <Widget>[
                    (DateTime.parse(end).difference(DateTime.now()).inMinutes >
                                0 &&
                            _title.isNotEmpty &&
                            msg.isNotEmpty)
                        ? Visibility(
                            visible: true,
                            child: Card(
                              shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(5.0)),
                              margin: const EdgeInsets.only(
                                  left: 20.0, right: 20.0, bottom: 5),
                              child: Container(
                                width: 305,
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: <Widget>[
                                    Padding(
                                      padding: const EdgeInsets.only(
                                          left: 20.0, top: 20.0),
                                      child: Row(
                                        children: <Widget>[
                                          Text(
                                            _title,
                                            style: TextStyle(
                                                color: global.appPrimaryColor),
                                          ),
                                        ],
                                      ),
                                    ),
                                    Padding(
                                      padding: const EdgeInsets.only(
                                          left: 20, right: 20),
                                      child: Text(
                                        msg,
                                        maxLines: 2,
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                    ),
                                    Row(
                                      mainAxisAlignment: MainAxisAlignment.end,
                                      children: <Widget>[
                                        Hero(
                                          tag: 'Readmore',
                                          child: GestureDetector(
                                            child: const Text(
                                              'Read More',
                                              style: TextStyle(
                                                fontSize: 13.0,
                                                color: Colors.blue,
                                                fontFamily: font,
                                              ),
                                            ),
                                            onTap: () {
                                              showReadMore();
                                            },
                                          ),
                                        ),
                                        const SizedBox(
                                          width: 15,
                                        )
                                      ],
                                    ),
                                    const SizedBox(
                                      height: 10,
                                    )
                                  ],
                                ),
                              ),
                            ),
                          )
                        : const Visibility(
                            child: Text(''),
                            visible: false,
                          ),
                    Card(
                      margin: const EdgeInsets.only(
                          left: 20.0, right: 20.0, top: 5.0, bottom: 10),
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(20.0)),
                      child: Container(
                        width: 305,
                        child: Column(
                          children: <Widget>[
                            Padding(
                              padding:
                                  const EdgeInsets.only(left: 16.0, top: 16.0),
                              child: Row(
                                children: <Widget>[
                                  Text(
                                    DateFormat('yyyy-MM-dd')
                                        .format(DateTime.now()),
                                    style: TextStyle(
                                        color: global.colorText,
                                        fontFamily: font),
                                  ),
                                  const SizedBox(width: 5.0),
                                  Container(
                                    height: 15.0,
                                    width: 1.5,
                                    color: global.appPrimaryColor,
                                  ),
                                  const SizedBox(width: 5.0),
                                  TimerBuilder.periodic(
                                      const Duration(seconds: 1),
                                      builder: (context) {
                                    // print("${getSystemTime()}");
                                    return Text(
                                      getSystemTime(),
                                      style: TextStyle(
                                          color: global.colorText,
                                          fontFamily: font),
                                    );
                                  }),
                                  const SizedBox(width: 5.0),
                                  Container(
                                    height: 15.0,
                                    width: 1.5,
                                    color: global.appPrimaryColor,
                                  ),
                                  const SizedBox(width: 5.0),
                                  Text(
                                    DateFormat('EEEE').format(DateTime.now()),
                                    style: TextStyle(
                                        color: global.colorText,
                                        fontFamily: font),
                                  ),
                                ],
                              ),
                            ),
                            // Padding(
                            //   padding: const EdgeInsets.only(
                            //       left: 20.0, top: 10.0, bottom: 2.0),
                            //   child: Align(
                            //     alignment: Alignment.centerLeft,
                            //     child: Row(
                            //       children: <Widget>[
                            //         Container(
                            //           height: 3.0,
                            //           width: 30.0,
                            //           color: global.appPrimaryColor,
                            //         ),
                            //         Container(
                            //           height: 1.0,
                            //           width: 70.0,
                            //           color: global.appPrimaryColor,
                            //         ),
                            //       ],
                            //     ),
                            //   ),
                            // ),
                            const SizedBox(
                              height: 10,
                            ),
                            Row(
                              children: <Widget>[
                                Flexible(
                                    flex: 3,
                                    fit: FlexFit.tight,
                                    child: InkWell(
                                      onTap: () async {
                                        final SharedPreferences prefs =
                                            await _prefs;

                                        String name =
                                            prefs.getString(SP_FIRST_NAME)!;
                                        String email =
                                            prefs.getString(SP_EMAIL)!;
                                        String image =
                                            prefs.getString(SP_PROFILE_IMAGE)!;
                                        String _projectVersion =
                                            prefs.getString(SP_version)!;

                                        Navigator.of(context).pushReplacement(
                                            new MaterialPageRoute(
                                                builder:
                                                    (BuildContext context) =>
                                                        new DashboardPage(
                                                          name: name,
                                                          email: email,
                                                          image: image,
                                                          projectVersion:
                                                              _projectVersion,
                                                          // selectedIndexBottom: 1,
                                                          // selectedIndexSideDrawer: 1,
                                                        )));
                                      },
                                      child: Column(
                                        children: <Widget>[
                                          // Center(
                                          //     child: Text(
                                          //   'Working Time',
                                          //   style: TextStyle(
                                          //       fontSize: 10.0,
                                          //       color: appColorBlackText),
                                          // )),
                                          Padding(
                                            padding: const EdgeInsets.all(8.0),
                                            child: Container(
                                              height: 150,
                                              width: 150,
                                              decoration: const BoxDecoration(
                                                  color: appWhiteColor,
                                                  borderRadius:
                                                      const BorderRadius.all(
                                                          const Radius.circular(
                                                              75)),
                                                  boxShadow: const [
                                                    BoxShadow(
                                                        //offset: Offset(0, 4),
                                                        color: Color.fromARGB(
                                                            255,
                                                            210,
                                                            207,
                                                            207), //edited
                                                        spreadRadius: 4,
                                                        blurRadius: 10 //edited
                                                        )
                                                  ]),
                                              child: Stack(
                                                children: [
                                                  // Align(
                                                  //   alignment: Alignment.center,
                                                  //   child: CircularPercentIndicator(
                                                  //     radius: 70.0,
                                                  //     animation: true,
                                                  //     animationDuration: 1200,
                                                  //     lineWidth: 8.0,
                                                  //     percent: _timeCountChart,
                                                  //     startAngle: 180.0,
                                                  //     circularStrokeCap:
                                                  //         CircularStrokeCap.round,
                                                  //     progressColor:
                                                  //         (_timeCountChart % 2 == 0)
                                                  //             ? appWhiteColor
                                                  //             : global.appPrimaryColor,
                                                  //     //  currentProgressColor(),
                                                  //     backgroundColor: appWhiteColor,
                                                  //   ),
                                                  // ),
                                                  Align(
                                                    alignment: Alignment.center,
                                                    child:
                                                        CircularPercentIndicator(
                                                      radius: 60.0,
                                                      animation: true,
                                                      animationDuration: 1200,
                                                      lineWidth: 8.0,
                                                      percent: _timeCountChart,
                                                      center: new Text(
                                                        'Working Time \n ${_totalHours}',
                                                        textAlign:
                                                            TextAlign.center,
                                                        style: TextStyle(
                                                            color: global
                                                                .colorTextDarkBlue,
                                                            fontWeight:
                                                                FontWeight.w600,
                                                            fontSize: 12.0,
                                                            fontFamily: font),
                                                      ),
                                                      startAngle: 180.0,
                                                      circularStrokeCap:
                                                          CircularStrokeCap
                                                              .round,
                                                      progressColor: global
                                                          .colorTextDarkBlue,
                                                      backgroundColor:
                                                          global.appBackground,
                                                    ),
                                                  ),
                                                ],
                                              ),
                                            ),
                                          )
                                        ],
                                      ),
                                    )),
                                // Container(
                                //   width: 1,
                                //   height: 140.0,
                                //   color: Colors.grey[300],
                                // ),
                                Flexible(
                                    flex: 3,
                                    fit: FlexFit.tight,
                                    child: InkWell(
                                      onTap: () async {
                                        // Map results = await Navigator.of(context)
                                        //     .push(new MaterialPageRoute(
                                        //   builder: (BuildContext context) {
                                        //     return MeetingList(
                                        //       scaffoldKey: widget.scaffoldKey,
                                        //       title: 'Meeting',
                                        //       screenName: 'home',
                                        //     );
                                        //   },
                                        // ));
                                        final SharedPreferences prefs =
                                            await _prefs;

                                        String name =
                                            prefs.getString(SP_FIRST_NAME)!;
                                        String email =
                                            prefs.getString(SP_EMAIL)!;
                                        String image =
                                            prefs.getString(SP_PROFILE_IMAGE)!;
                                        String _projectVersion =
                                            prefs.getString(SP_version)!;

                                        _buttonShowAllTaskTapped();

                                        // Navigator.of(context).pushReplacement(
                                        //     new MaterialPageRoute(
                                        //         builder: (BuildContext context) =>
                                        //             new
                                        //             DashboardPage(
                                        //               name: name,
                                        //               email: email,
                                        //               image: image,
                                        //               projectVersion:
                                        //                   _projectVersion,
                                        //               selectedIndexBottom: 0,
                                        //               selectedIndexSideDrawer: 0,
                                        //             )
                                        //             ));
                                      },
                                      child: Column(
                                        children: <Widget>[
                                          // Center(
                                          //     child: Text(
                                          //   'Meeting/Task',
                                          //   style: TextStyle(
                                          //       fontSize: 10.0,
                                          //       color: appColorBlackText),
                                          // )),
                                          Padding(
                                            padding: const EdgeInsets.all(8.0),
                                            child: Container(
                                              height: 150,
                                              width: 150,
                                              decoration: const BoxDecoration(
                                                  color: appWhiteColor,
                                                  borderRadius:
                                                      BorderRadius.all(
                                                          Radius.circular(75)),
                                                  boxShadow: [
                                                    BoxShadow(
                                                        //offset: Offset(0, 4),
                                                        color: Color.fromARGB(
                                                            255,
                                                            210,
                                                            207,
                                                            207), //edited
                                                        spreadRadius: 4,
                                                        blurRadius: 10 //edited
                                                        )
                                                  ]),
                                              child: Stack(
                                                children: [
                                                  // Align(
                                                  //   alignment: Alignment.center,
                                                  //   child: CircularPercentIndicator(
                                                  //     radius: 70.0,
                                                  //     animation: true,
                                                  //     animationDuration: 1200,
                                                  //     lineWidth: 8.0,
                                                  //     percent: _taskCountChart,
                                                  //     startAngle: 180.0,
                                                  //     circularStrokeCap:
                                                  //         CircularStrokeCap.round,

                                                  //     progressColor:
                                                  //         (_taskCountChart % 2 == 0)
                                                  //             ? appWhiteColor
                                                  //             : global.appPrimaryColor,
                                                  //     backgroundColor: appWhiteColor,
                                                  //   ),
                                                  // ),
                                                  Align(
                                                    alignment: Alignment.center,
                                                    child:
                                                        CircularPercentIndicator(
                                                      radius: 60.0,
                                                      animation: true,
                                                      animationDuration: 1200,
                                                      lineWidth: 8.0,
                                                      percent: _taskCountChart,
                                                      center: new Text(
                                                        'Task \n ${_taskCount != null ? _taskCount : '0/0'}',
                                                        textAlign:
                                                            TextAlign.center,
                                                        style: TextStyle(
                                                            color: global
                                                                .colorTextDarkBlue,
                                                            fontWeight:
                                                                FontWeight.w600,
                                                            fontSize: 12.0,
                                                            fontFamily: font),
                                                      ),
                                                      startAngle: 180.0,
                                                      circularStrokeCap:
                                                          CircularStrokeCap
                                                              .round,
                                                      progressColor: global
                                                          .colorTextDarkBlue,
                                                      backgroundColor:
                                                          global.appBackground,
                                                    ),
                                                  ),
                                                ],
                                              ),
                                            ),
                                          ),
                                        ],
                                      ),
                                    )),
                              ],
                            ),
                            const SizedBox(
                              height: 20,
                            ),
                          ],
                        ),
                      ),
                    ),
                    // Card(
                    //   margin: EdgeInsets.only(
                    //       left: 20.0, right: 20.0, top: 10.0, bottom: 10),
                    //   child:
                    Container(
                      decoration: BoxDecoration(
                          color: global.appBackground,
                          borderRadius:
                              const BorderRadius.all(Radius.circular(20))),
                      margin: const EdgeInsets.only(
                          left: 20.0, right: 20.0, top: 10.0, bottom: 10),
                      width: 305,
                      child: Column(
                        children: <Widget>[
                          // Padding(
                          //   padding: const EdgeInsets.all(20),
                          //   child: Row(
                          //     children: <Widget>[
                          //       Icon(
                          //         Icons.calendar_today,
                          //         color: appColorRedIcon,
                          //         size: 20.0,
                          //       ),
                          //       SizedBox(
                          //         width: 5.0,
                          //       ),
                          //       Text(
                          //         'Attendance',
                          //         style: TextStyle(color: global.appPrimaryColor),
                          //       ),
                          //     ],
                          //   ),
                          // ),
                          // Padding(
                          //   padding: const EdgeInsets.only(
                          //       left: 20.0, top: 10.0, bottom: 15.0),
                          //   child: Align(
                          //     alignment: Alignment.centerLeft,
                          //     child: Row(
                          //       children: <Widget>[
                          //         Container(
                          //           height: 3.0,
                          //           width: 30.0,
                          //           color: global.appPrimaryColor,
                          //         ),
                          //         Container(
                          //           height: 1.0,
                          //           width: 70.0,
                          //           color: global.appPrimaryColor,
                          //         ),
                          //       ],
                          //     ),
                          //   ),
                          // ),
                          const SizedBox(
                            height: 20,
                          ),
                          Row(
                            children: <Widget>[
                              Column(
                                children: <Widget>[
                                  Text(
                                    'In Time',
                                    style: TextStyle(
                                        fontSize: 15.0,
                                        color: global.colorTextDarkBlue,
                                        fontWeight: FontWeight.bold,
                                        fontFamily: font),
                                  ),
                                  const SizedBox(
                                    height: 5,
                                  ),
                                  new Text(
                                    _inTime,
                                    style: const TextStyle(
                                        color: appColorBlackText,
                                        fontFamily: font,
                                        fontSize: 10.0),
                                  ),
                                  const SizedBox(
                                    height: 8.0,
                                  ),
                                  GestureDetector(
                                      child: SizedBox(
                                        width: 100,
                                        child: Padding(
                                          padding: const EdgeInsets.all(1.0),
                                          child: Card(
                                            shape: RoundedRectangleBorder(
                                              borderRadius:
                                                  BorderRadius.circular(20.0),
                                            ),
                                            color: (_attendanceStatus == 1 ||
                                                    _attendanceStatus == 2 ||
                                                    _attendanceStatus == 3)
                                                ? global.appDarkPrimaryColor
                                                : global.appBottomNavColor,
                                            child: Padding(
                                              padding:
                                                  const EdgeInsets.all(4.0),
                                              child: Center(
                                                child: Row(
                                                  children: <Widget>[
                                                    Expanded(
                                                      child: Container(),
                                                    ),
                                                    const Icon(
                                                      Icons.pause,
                                                      color: appWhiteColor,
                                                      size: 20.0,
                                                    ),
                                                    Text(
                                                        (_attendanceStatus == 2)
                                                            ? 'Resume'
                                                            : 'Pause',
                                                        style: const TextStyle(
                                                            color:
                                                                appWhiteColor,
                                                            fontFamily: font,
                                                            fontSize: 10.0)),
                                                    Expanded(
                                                      child: Container(),
                                                    ),
                                                  ],
                                                ),
                                              ),
                                            ),
                                          ),
                                        ),
                                      ),
                                      onTap: () async {
                                        if (_attendanceStatus == 1 ||
                                            _attendanceStatus == 3) {
                                          pauseAttendanceDialog();
                                        } else if (_attendanceStatus == 2) {
                                          resumeAttendanceDialog();
                                        }
                                      }),
                                ],
                              ),
                              const Expanded(child: Text('')),
                              Column(
                                children: <Widget>[
                                  const SizedBox(
                                    height: 5.0,
                                  ),
                                  _loadAttendanceButton(),
                                  const SizedBox(
                                    height: 10.0,
                                  ),
                                ],
                              ),
                              const Expanded(child: Text('')),
                              Container(
                                width: 100,
                                child: Column(
                                  children: <Widget>[
                                    Text(
                                      'Out Time',
                                      style: TextStyle(
                                          fontSize: 15.0,
                                          color: global.colorTextDarkBlue,
                                          fontWeight: FontWeight.bold,
                                          fontFamily: font),
                                    ),
                                    const SizedBox(
                                      height: 8,
                                    ),
                                    new Text(
                                      _outTime,
                                      style: const TextStyle(
                                          color: appColorBlackText,
                                          fontFamily: font,
                                          fontSize: 10.0),
                                    ),
                                    const SizedBox(
                                      height: 5.0,
                                    ),
                                    Padding(
                                      padding: const EdgeInsets.all(1.0),
                                      child: Card(
                                        shape: RoundedRectangleBorder(
                                          borderRadius:
                                              BorderRadius.circular(20.0),
                                        ),
                                        color: global.appDarkPrimaryColor,
                                        child: Padding(
                                          // padding: const EdgeInsets.all(3.0),
                                          padding: const EdgeInsets.only(
                                              left: 3,
                                              right: 3,
                                              top: 4,
                                              bottom: 4),
                                          child: GestureDetector(
                                              child: Center(
                                                child: Row(
                                                  children: <Widget>[
                                                    Expanded(
                                                      child: Container(),
                                                    ),
                                                    // Padding(
                                                    //   // padding:
                                                    //   //     const EdgeInsets.all(
                                                    //   //         3.0),
                                                    //   padding: EdgeInsets.only(
                                                    //       left: 3,
                                                    //       right: 3,
                                                    //       top: 4,
                                                    //       bottom: 4),
                                                    //   child: Icon(
                                                    //     Icons.remove_red_eye,
                                                    //     color: appWhiteColor,
                                                    //     size: 15.0,
                                                    //   ),
                                                    // ),
                                                    Container(
                                                      height: 20,
                                                      padding:
                                                          const EdgeInsets.only(
                                                              top: 5),
                                                      child: const Text(
                                                          'View Records',
                                                          style: TextStyle(
                                                              color:
                                                                  Colors.white,
                                                              fontSize: 10.0,
                                                              fontFamily:
                                                                  font)),
                                                    ),
                                                    Expanded(
                                                      child: Container(),
                                                    ),
                                                  ],
                                                ),
                                              ),
                                              onTap: () {
                                                //                                              widget.scaffoldKey.
                                                // Navigator.of(context).push(
                                                //     new MaterialPageRoute(
                                                //         builder: (BuildContext
                                                //                 context) =>
                                                //             new ViewAttendanceList(
                                                //                 scaffoldKey: widget
                                                //                     .scaffoldKey,
                                                //                 title:
                                                //                     'View Records')));
                                                //                                              _uploadAttendanceLocationApiCall('2');
                                                Navigator.of(context)
                                                    .push(new MaterialPageRoute(
                                                        builder: (BuildContext
                                                                context) =>
                                                            new ViewAttendanceList(
                                                                scaffoldKey: widget
                                                                    .scaffoldKey,
                                                                title:
                                                                    'View Records')))
                                                    .then((card) => {
                                                          setState(() {
                                                            //print("G1----> ");
                                                            _totalHoursShow();
                                                          })
                                                        });
                                              }),
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                    // shape: RoundedRectangleBorder(
                    //     borderRadius: BorderRadius.circular(20.0)),
                    // ),
                    loadDriverCard(),
                    loadTaskManager(),
                    birthdayCard(),
                    const SizedBox(
                      height: 10,
                    ),

                    ///Please Check Raghu
                    ///Comment ka kelay?? Meeting card ??
                    //  loadMeeting(),
                  ],
                ),
                //  ),
              )
            ],
          ),
        ),
      ),
    );
  }

  Future<void> showReadMore() {
    return showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return StatefulBuilder(
          builder: (context, setState) {
            return AlertDialog(
              contentPadding: const EdgeInsets.all(0),
              shape: const RoundedRectangleBorder(
                borderRadius: BorderRadius.all(Radius.circular(15)),
              ),
              content: Container(
                height: MediaQuery.of(context).size.height * 0.7,
                width: double.maxFinite,
                decoration: const BoxDecoration(
                  borderRadius: BorderRadius.all(Radius.circular(15)),
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: <Widget>[
                    // 🔹 Your existing dialog UI remains unchanged
                    Container(
                      decoration: const BoxDecoration(
                        gradient: LinearGradient(
                          colors: [
                            Color.fromRGBO(255, 81, 54, 1),
                            Color.fromRGBO(255, 163, 54, 1),
                          ],
                        ),
                        borderRadius: BorderRadius.only(
                          topLeft: Radius.circular(15),
                          topRight: Radius.circular(15),
                        ),
                      ),
                      padding: const EdgeInsets.all(10),
                      child: Text(
                        _title,
                        textAlign: TextAlign.center,
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w400,
                          color: Colors.white,
                        ),
                      ),
                    ),
                    Expanded(
                      child: ListView(
                        shrinkWrap: true,
                        children: <Widget>[
                          Padding(
                            padding: const EdgeInsets.all(10),
                            child: Text(
                              msg,
                              textAlign: TextAlign.justify,
                              style: const TextStyle(fontSize: 15),
                            ),
                          ),
                          if (img.isNotEmpty)
                            Padding(
                              padding:
                                  const EdgeInsets.symmetric(horizontal: 20),
                              child: Container(
                                height: 150,
                                decoration: BoxDecoration(
                                  image: DecorationImage(
                                    fit: BoxFit.fill,
                                    image: CachedNetworkImageProvider(img),
                                  ),
                                ),
                              ),
                            ),
                          if (videoCode.isNotEmpty)
                            Padding(
                              padding:
                                  const EdgeInsets.symmetric(horizontal: 20),
                              child: SizedBox(
                                height: 200,
                                child: YoutubePlayer(
                                  controller: _controller,
                                  showVideoProgressIndicator: true,
                                ),
                              ),
                            ),
                        ],
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.all(10),
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: global.appPrimaryColor,
                        ),
                        child: const Text(
                          'OK',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                        onPressed: () => Navigator.pop(context),
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }

  void getSpData() async {
    // showBottomToast('Enter in getSpData');
    final SharedPreferences prefs = await _prefs;
    _companyId = prefs.getInt(SP_COMPANY_ID)!;
    _attendanceStatus = prefs.getInt(SP_ATTENDANCE_STATUS)!;
    //print('G1--_attendanceStatus---01>${_attendanceStatus}');
    if (_companyId != 120 || _attendanceStatus == 4) {
      if (prefs.getString(SP_ATTENDANCE_DATE) !=
          DateFormat('yyyy-MM-dd').format(DateTime.now())) {
        prefs.setInt(SP_ATTENDANCE_STATUS, 0);
        prefs.setInt(SP_ATTENDANCE_ID, 0);
        prefs.setInt(SP_ATTENDANCE_BREAK_ID, 0);
        prefs.setString(SP_ATTENDANCE_IN_TIME, '');
        prefs.setString(SP_ATTENDANCE_OUT_TIME, '');
        prefs.setString(SP_ATTENDANCE_IN_TIME_DATE, '');
        prefs.setString(SP_ATTENDANCE_OUT_TIME_DATE, '');
      }
    } else
      workingMiniutes = 600;

    _apiToken = prefs.getString(SP_API_TOKEN)!;
    _userId = prefs.getInt(SP_ID)!;
    _deviceId = prefs.getString(DEVICE_ID)!;
    _isSelfi = prefs.getInt(SP_ATTENDANCE_SELFIE)!;
    _companyId = prefs.getInt(SP_COMPANY_ID)!;

    _isGeofence = prefs.getInt(GEOFENCING)!;
    _distance = prefs.getInt(DISTANCE)!;
    _geoBaselatitude = prefs.getString(LATITUDE)!;
    _geoBaselongitude = prefs.getString(LONGITUDE)!;

    _isGeotracking = prefs.getInt(SP_LOCATION_TRACKING)!;

    _driver_delivery = prefs.getInt(SP_DRIVER)!;
    _vehicle_selection_date = prefs.getString(SP_VEHICLE_SELECTION_UPLOAD_DATE);
    _driver_package_date = prefs.getString(SP_DRIVER_PACKAGE_UPLOAD_DATE);
    _company = prefs.getString(SP_COMPANY_NAME)!;

    //for attendance
    _attendanceStatus = prefs.getInt(SP_ATTENDANCE_STATUS)!;
    //print('G1--_attendanceStatus---02>${_attendanceStatus}');

    _attendanceId = prefs.getInt(SP_ATTENDANCE_ID)!;
    _attendanceBreakId = prefs.getInt(SP_ATTENDANCE_BREAK_ID)!;
    _task_manager = prefs.getInt(TASK_MANAGER)!;
    _inTime = (prefs.getString(SP_ATTENDANCE_IN_TIME) != null)
        ? prefs.getString(SP_ATTENDANCE_IN_TIME)!
        : '-';
    _outTime = (prefs.getString(SP_ATTENDANCE_OUT_TIME)! != null)
        ? prefs.getString(SP_ATTENDANCE_OUT_TIME)!
        : '-';
    _fullInTime = (prefs.getString(SP_ATTENDANCE_IN_TIME_DATE) != null)
        ? prefs.getString(SP_ATTENDANCE_IN_TIME_DATE)!
        : '';
    _fullOutTime = (prefs.getString(SP_ATTENDANCE_OUT_TIME_DATE) != null)
        ? prefs.getString(SP_ATTENDANCE_OUT_TIME_DATE)!
        : '';
    if (_fullInTime != '') {
      _inTime = DateFormat('hh:mm a').format(
          DateFormat("yyyy-MM-dd HH:mm:ss").parse(_fullInTime, true).toLocal());
//      _inTime = DateFormat('hh:mm a').format(DateTime.parse(_fullInTime, true).toLocal());
    } else {
      _inTime = '-';
    }
    if (_fullOutTime != '') {
      _outTime = DateFormat('hh:mm a').format(DateFormat("yyyy-MM-dd HH:mm:ss")
          .parse(_fullOutTime, true)
          .toLocal());
//      _outTime = DateFormat('hh:mm a').format(DateTime.parse(_fullOutTime));
    } else {
      _outTime = '-';
    }

    _id = prefs.getInt(SP_NEWS_ID)!;
    _title = prefs.getString(SP_NEWS_TITLE) ?? "";
    msg = prefs.getString(SP_NEWS_MESSAGE) ?? "";
    img = prefs.getString(SP_NEWS_URL) ?? "";
    videoCode = prefs.getString(SP_NEWS_VIDEOCODE) ?? '';
    start = prefs.getString(SP_NEWS_START) ?? "";
    end = prefs.getString(SP_NEWS_END) ?? "${DateTime.now()}";
    if (videoCode != '') {
      _controller = YoutubePlayerController(
        initialVideoId: videoCode,
        flags: const YoutubePlayerFlags(
          autoPlay: false,
        ),
      );
    }
    setState(() {});
//    _totalHours = "09:20";
  }

  //For location tracking
  initLocationState() async {
    await _locationService.changeSettings(
        accuracy: LocationAccuracy.high, interval: 1000);

    // Platform messages may fail, so we use a try/catch PlatformException.
    try {
      bool serviceStatus = await _locationService.serviceEnabled();
      // print("Service status: $serviceStatus");
      if (serviceStatus) {
        PermissionStatus statuss = await _locationService.requestPermission();
        _permission = (statuss == PermissionStatus.granted) ? true : false;
//        _permission = await _locationService.requestPermission();
//        print("Permission: $_permission");
        if (_permission) {
          _startLocation = await _locationService.getLocation();
        }
      } else {
        bool serviceStatusResult = await _locationService.requestService();
        //print("Service status activated after request: $serviceStatusResult");
        if (serviceStatusResult) {
          initLocationState();
        }
      }
    } on PlatformException catch (e) {
      print(e);
      if (e.code == 'PERMISSION_DENIED') {
        error = e.message!;
      } else if (e.code == 'SERVICE_STATUS_ERROR') {
        error = e.message!;
      }
    }

    setState(() {});
  }

  /// button design and click event----------
Widget _loadAttendanceButton() {
  return Center(
    child: GestureDetector(
      child: Container(
        height: 120,
        width: 120,
        decoration: BoxDecoration(
          image: const DecorationImage(
            image: AssetImage('assets/image/default_bg.png'), // ✅ Fixed here
            fit: BoxFit.fill,
          ),
          borderRadius: BorderRadius.circular(60),
        ),
        child: _loadAttendanceButtonIcon(),
      ),
      onTap: () async {
        var connectivityResult = await Connectivity().checkConnectivity();
        apiCall(connectivityResult);
      },
    ),
  );
}

  Widget _loadAttendanceButtonIcon() {
    //print("g1--_attendanceStatus--->$_attendanceStatus");
    switch (_attendanceStatus) {
      case 0:
        return Icon(
          Icons.play_arrow,
          color: global.appDarkPrimaryColor,
          size: 70.0,
        );
      // return ImageIcon(
      //   AssetImage("assets/image/btn_play_pause.png"),
      //   color: appWhiteColor,
      //   size: 70.0,
      // );
      case 1:
        return const Icon(
          Icons.stop,
          color: Colors.red,
          size: 70.0,
        );

      case 2:
        return Icon(
          Icons.stop,
          color: global.appBottomNavColor,
          size: 70.0,
        );
      case 3:
        return const Icon(
          Icons.stop,
          color: Colors.red,
          size: 70.0,
        );
      case 4:
        return Icon(
          Icons.cloud_done,
          color: global.appBottomNavColor,
          size: 60.0,
        );
    }
    return Icon(
      Icons.play_arrow,
      color: global.appDarkPrimaryColor,
      size: 70.0,
    );
  }

  List<Color> _loadAttendanceButtonColor() {
    switch (_attendanceStatus) {
      case 0:
        return [global.appAccentColor, global.appAccentColor];
      case 1:
        return [appNavigationHeader, appNavigationHeader];
      case 2:
        return [chartGray, chartGray];
      case 3:
        return [appNavigationHeader, appNavigationHeader];
      case 4:
        return [chartGray, chartGray];
    }

    return [global.appAccentColor, global.appAccentColor];
  }

  // InputImageRotation rotationIntToImageRotation(int rotation) {
  //   switch (rotation) {
  //     case 90:
  //       return InputImageRotation.rotation90deg;
  //     case 180:
  //       return InputImageRotation.rotation180deg;
  //     case 270:
  //       return InputImageRotation.rotation270deg;
  //     default:
  //       return InputImageRotation.rotation0deg;
  //   }
  // }

  Future _buttonTapped() async {
    getSpData();
    initLocationState();
    // print(_geoBaselatitude);
    //print(_geoBaselongitude);
    try {
      if (_isGeofence == 1) {
        meter = distance(
            new dist.LatLng(
                _startLocation.latitude!, _startLocation.longitude!),
            new dist.LatLng(double.parse(_geoBaselatitude),
                double.parse(_geoBaselongitude)));
      }
    } catch (e) {}
    switch (_attendanceStatus) {
      case 0:
        // _imageFile = null;
        if (_driver_delivery == 1) {
          dropDownValue = '0';
          final SharedPreferences prefs = await _prefs;
          if (prefs.getBool(SP_IS_LOGIN_BOOL) != null) {
            _vehicle_selection_date =
                prefs.getString(SP_VEHICLE_SELECTION_UPLOAD_DATE)!;
          }
          if (_vehicle_selection_date !=
              DateFormat('yyyy/MM/dd').format(DateTime.now())) {
            _vehicleSelect();
          } else {
            startAttendanceDialog();
          }
        } else {
          startAttendanceDialog();
          break;
        }
        break;
      case 1:
        if (_driver_delivery == 1 &&
            _driver_package_date !=
                DateFormat('yyyy/MM/dd').format(DateTime.now())) {
          _updatePackageList();
        } else {
          stopAttendanceDialog();
        }
        break;
      case 2:
        showBottomToast('Resume your attendance first');
        break;
      case 3:
        if (_driver_delivery == 1 &&
            _driver_package_date !=
                DateFormat('yyyy/MM/dd').format(DateTime.now())) {
          _updatePackageList();
        } else {
          stopAttendanceDialog();
          // await stopBackgroundLocation();
        }
        break;
      case 4:
        showBottomToast('You have already stop your attendance');
        break;
    }
  }

  /// start Attendance ----------------------
  void startAttendanceDialog() {
    showDialog(
        context: context,
        barrierDismissible: false,
        builder: (BuildContext context) {
          return StatefulBuilder(builder: (context, setState) {
            return AlertDialog(
              contentPadding: const EdgeInsets.all(0),
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.all(
                      Radius.circular(ScreenUtil().setSp(10)))),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                // crossAxisAlignment: CrossAxisAlignment.stretch,
                children: <Widget>[
                  Container(
                      decoration: BoxDecoration(
                          color: global.appPrimaryColor,
                          borderRadius: const BorderRadius.only(
                              topLeft: const Radius.circular(10),
                              topRight: const Radius.circular(10))),
                      padding: const EdgeInsets.all(15),
                      child: Row(
                        children: <Widget>[
                          Text(
                            'Start Your Attendance',
                            textAlign: TextAlign.center,
                            style: TextStyle(
                                fontSize: ScreenUtil().setSp(16),
                                fontWeight: FontWeight.bold,
                                fontFamily: font,
                                color: appWhiteColor),
                          ),
                          Expanded(
                            child: Container(),
                          ),
                          GestureDetector(
                            child: const Icon(
                              Icons.close,
                              color: Colors.white,
                              size: 30.0,
                            ),
                            onTap: () {
                              Navigator.pop(context);
                              result = '';
                            },
                          )
                        ],
                      )),
                  const SizedBox(
                    height: 10.0,
                  ),
                  //workFrom,  if (_driver_delivery == 1) {
                  (_driver_delivery != 1)
                      ? const Padding(
                          padding: EdgeInsets.only(left: 16.0, right: 16.0),
                          child: Text('Work Location',
                              style: TextStyle(
                                fontSize: 15.0,
                                fontFamily: font,
                                fontWeight: FontWeight.bold,
                              )),
                        )
                      : Container(
                          child: const Text(''),
                        ),
                  (_driver_delivery != 1)
                      ? Padding(
                          padding: EdgeInsets.only(
                            left: ScreenUtil().setSp(10),
                            top: ScreenUtil().setSp(10),
                            right: ScreenUtil().setSp(10),
                          ),
                          child: Container(
                              padding: EdgeInsets.only(
                                  left: ScreenUtil().setSp(10), right: 10),
                              decoration: BoxDecoration(
                                color: Colors.white,
                                border:
                                    Border.all(width: 1, color: Colors.grey),
                                borderRadius: BorderRadius.circular(25),
                              ),
                              child: (_workingTypeApiCallBack
                                          ?.items?.isNotEmpty ??
                                      false)
                                  ? DropdownButtonHideUnderline(
                                      child: DropdownButton(
                                        underline: const SizedBox(),
                                        icon: new Image.asset(
                                          'assets/image/arrow.png',
                                          width: 25,
                                          height: 40,
                                        ),
                                        hint:
                                            const Text('Select Work Location'),
                                        items: _workingTypeApiCallBack!.items
                                            ?.map((dataItem) {
                                          return DropdownMenuItem(
                                            child:
                                                new Text(dataItem.name ?? ""),
                                            value: dataItem.id.toString(),
                                          );
                                        }).toList(),
                                        onChanged: (newValue) {
                                          setState(() {
                                            dropDownValue = newValue.toString();
                                            // int index =
                                            //     int.parse(dropDownValue);

                                            // _geofenceForWorkingType =
                                            //     _workingTypeApiCallBack
                                            //         .items[index].geofencing;
                                            // print(
                                            //     'GEO :$_geofenceForWorkingType');
                                          });
                                        },
                                        isExpanded: true,
                                        value: dropDownValue,
                                      ),
                                    )
                                  : DropdownButtonHideUnderline(
                                      child: DropdownButton<String>(
                                        hint: Text('Select Task Type'),
                                        items: [],
                                        onChanged: (String? newValue) {},
                                        isExpanded: true,
                                        value: dropDownValue,
                                      ),
                                    )))
                      : Container(
                          child: const Text(''),
                        ),
                  const SizedBox(
                    height: 10,
                  ),
                  (_isSelfi == 1)
                      ?
                      // (_imageFile != null)
                      //     ? SizedBox(
                      //         height: 140,
                      //         width: 140,
                      //         child: ClipRRect(
                      //           borderRadius: BorderRadius.circular(60.0),
                      //           child: CircleAvatar(
                      //             backgroundImage: FileImage(_imageFile),
                      //           ),
                      //         ))
                      //     : Container(
                      //         // child: const Icon(
                      //         //   Icons.image,
                      //         //   color: Colors.grey,
                      //         //   size: 150.0,
                      //         // ),
                      //         decoration: const BoxDecoration(
                      //           color: Colors.transparent,
                      //           image: DecorationImage(
                      //               image:
                      //                   AssetImage('assets/image/camera.png'),
                      //               fit: BoxFit.fitHeight),
                      //         ),
                      //         width: 150,
                      //         height: 150,
                      //       )
                      SizedBox(
                          width: 150,
                          height: 150,
                          child: InkWell(
                            child: _imageFile == null
                                ? Container(
                                    height: 150,
                                    width: 150,
                                    decoration: BoxDecoration(
                                      color: global.colorTextDarkBlue,
                                      borderRadius: BorderRadius.circular(75),
                                      image: DecorationImage(
                                          image: global.bg_profile.isNotEmpty
                                              ? CachedNetworkImageProvider(
                                                  global.bg_profile)
                                              : AssetImage(
                                                      global.bg_profileDefault)
                                                  as ImageProvider,
                                          fit: BoxFit.fill),
                                    ),
                                    padding: const EdgeInsets.all(40),
                                    child: Image.asset(
                                      "assets/image/cameraOutline1.png",
                                      height: 100,
                                    ),
                                  )
                                : Container(
                                    height: 150,
                                    width: 150,
                                    decoration: BoxDecoration(
                                      image: DecorationImage(
                                          image: global.bg_profile.isNotEmpty
                                              ? CachedNetworkImageProvider(
                                                  global.bg_profile)
                                              : AssetImage(
                                                      global.bg_profileDefault)
                                                  as ImageProvider,
                                          fit: BoxFit.fill),
                                    ),
                                    child: Container(
                                      margin: const EdgeInsets.all(10),
                                      padding: const EdgeInsets.all(10),
                                      child: ClipRRect(
                                        borderRadius:
                                            BorderRadius.circular(80.0),
                                        child: Platform.isAndroid
                                            ? Image.file(
                                                _imageFile!,
                                                fit: BoxFit.fill,
                                              )
                                            : Container(
                                                width:
                                                    200, // the size you prefer
                                                height: 200,
                                                // transformAlignment:
                                                //     Alignment.center,
                                                // transform: Matrix4.rotationZ(
                                                //   -3.1415926535897932 /
                                                //       2, // here
                                                // ),
                                                child: Image.file(
                                                  _imageFile!,
                                                  fit: BoxFit.fill,
                                                )),
                                      ),
                                    ),
                                  ),
                            onTap: () async {
                              try {
                                //_imageFile =
                                // PickedFile? file = await ImagePicker().getImage(
                                //   source: ImageSource.camera,
                                //   maxWidth: 200.0,
                                //   maxHeight: 450.0,
                                //   imageQuality: 100,
                                // );
                                final ImagePicker picker = ImagePicker();

                                XFile? file = await picker.pickImage(
                                  source: ImageSource.camera,
                                  maxWidth: 200.0,
                                  maxHeight: 450.0,
                                  imageQuality: 100,
                                );

                                if (file != null) {
                                  _imageFile = File(file.path);
                                } else {
                                  print("No image selected");
                                }

                                //print("selfie image: ${file.path}");
                                setState(() {});
                              } catch (e) {
                                _pickImageError = e;
                                //showBottomToast("Image picker error: $_pickImageError");
                              }
                            },
                          ),
                        )
                      : Container(),
                  const SizedBox(
                    height: 10,
                  ),
                  (_isSelfi == 1)
                      ? Padding(
                          padding: const EdgeInsets.only(
                            left: 45.0,
                            right: 45.0,
                          ),
                          child: Card(
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(20.0),
                            ),
                            color: appColorRedIcon,
                            child: GestureDetector(
                              child: Row(
                                crossAxisAlignment: CrossAxisAlignment.center,
                                children: <Widget>[
                                  Expanded(
                                    child: Container(),
                                  ),
                                  const Padding(
                                    padding: EdgeInsets.all(4.0),
                                    child: Icon(
                                      Icons.camera,
                                      color: appWhiteColor,
                                      size: 25.0,
                                    ),
                                  ),
                                  const Text('Take a Selfie',
                                      style: TextStyle(
                                          fontFamily: font,
                                          fontWeight: FontWeight.bold,
                                          color: Colors.white,
                                          fontSize: 16.0)),
                                  Expanded(
                                    child: Container(),
                                  ),
                                ],
                              ),
                              onTap: () async {
                                //showBottomToast('take selfi button tapped');
                                try {
                                  //_imageFile =
                                  final ImagePicker picker = ImagePicker();

                                  XFile? file = await picker.pickImage(
                                    source: ImageSource.camera,
                                    maxWidth: 200.0,
                                    maxHeight: 450.0,
                                    imageQuality: 100,
                                  );

                                  if (file != null) {
                                    print("Image Path: ${file.path}");
                                    _imageFile = File(file.path);
                                  } else {
                                    print("No image selected");
                                  }
                                  //
                                  // print("selfie image: ${file.path}");
                                  setState(() {});
                                } catch (e) {
                                  _pickImageError = e;
                                  //showBottomToast("Image picker error: $_pickImageError");
                                }
                              },
                            ),
                          ),
                        )
                      : Container(),
                  const SizedBox(
                    height: 10.0,
                  ),
                  (_select_bike == 1)
                      ? Column(
                          children: [
                            Padding(
                              padding: const EdgeInsets.only(
                                  left: 16.0, right: 16.0),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: <Widget>[
                                  const Flexible(
                                    flex: 2,
                                    child: Text('Bike No',
                                        style: TextStyle(
                                          fontSize: 15.0,
                                          fontFamily: font,
                                          fontWeight: FontWeight.bold,
                                        )),
                                  ),
                                  const SizedBox(
                                    width: 10.0,
                                  ),
                                  Flexible(
                                    flex: 3,
                                    child: Text(result,
                                        style: const TextStyle(
                                          fontSize: 15.0,
                                          fontFamily: font,
                                          fontWeight: FontWeight.bold,
                                        )),
                                  ),
                                ],
                              ),
                            ),
                            Padding(
                              padding: const EdgeInsets.only(
                                left: 45.0,
                                right: 45.0,
                              ),
                              child: Card(
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(20.0),
                                ),
                                color: appColorBlueProgressBar,
                                child: GestureDetector(
                                  child: Row(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.center,
                                    children: <Widget>[
                                      Expanded(
                                        child: Container(),
                                      ),
                                      const Padding(
                                        padding: EdgeInsets.all(4.0),
                                        child: Icon(
                                          Icons.camera,
                                          color: appWhiteColor,
                                          size: 25.0,
                                        ),
                                      ),
                                      const Text('Scan Bike QR Code',
                                          style: TextStyle(
                                              fontFamily: font,
                                              color: Colors.white,
                                              fontSize: 16.0)),
                                      Expanded(
                                        child: Container(),
                                      ),
                                    ],
                                  ),
                                  // onTap: () async {
                                  //   String results = await Navigator.push(
                                  //     context,
                                  //     MaterialPageRoute(
                                  //       builder: (context) =>
                                  //           const ScanQrcodePage(),
                                  //     ),
                                  //   );
                                  //   setState(() {
                                  //     if (results == deviceId) {
                                  //       result = 'MH 12 PH 4073';
                                  //     } else {
                                  //       result = 'NA';
                                  //     }
                                  //   });
                                  // },
                                ),
                              ),
                            ),
                          ],
                        )
                      : Container(),

                  Padding(
                    padding: const EdgeInsets.only(left: 16.0, right: 16.0),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: <Widget>[
                        const Text('Start Time:',
                            style: TextStyle(
                              fontSize: 14.0,
                              // fontFamily: font,
                              fontWeight: FontWeight.bold,
                            )),
                        const SizedBox(
                          width: 10.0,
                        ),
                        Text(DateFormat('hh:mm a').format(DateTime.now()),
                            style: const TextStyle(
                              fontSize: 14.0,
                              // fontFamily: font,
                              fontWeight: FontWeight.bold,
                            )),
                      ],
                    ),
                  ),

                  (_isGeofence == 1)
                      ? Padding(
                          padding:
                              const EdgeInsets.only(left: 16.0, right: 16.0),
                          child: Text(
                              (meter > _distance)
                                  ? 'You are away from your location by  ${meter - _distance} meters'
                                  : '',
                              style: const TextStyle(
                                fontSize: 15.0,
                                fontFamily: font,
                                fontWeight: FontWeight.bold,
                              )),
                        )
                      : Container(),
                  const SizedBox(
                    height: 10.0,
                  ),
//                  Padding(
//                    padding: const EdgeInsets.only(left: 50.0, right: 50.0),
//                    child: Card(
//                      shape: RoundedRectangleBorder(
//                        borderRadius: BorderRadius.circular(20.0),
//                      ),
//                      color: appColorRedIcon,
//                      child: GestureDetector(
//                        child: Center(
//                          child: Padding(
//                            padding: const EdgeInsets.all(8.0),
//                            child: Center(
//                              child: Text('Start',
//                                  style: TextStyle(
//                                    color: Colors.white,
//                                    fontSize: 15.0,
//                                    fontWeight: FontWeight.bold,
//                                  )),
//                            ),
//                          ),
//                        ),
//                        onTap: () async {
//                          if (_isSelfi == 1 && _imageFile == null) {
//                            showBottomToast(
//                                'Selfie is mandatory for attendance');
//                          } else if (_isGeofence == 1 && meter > _distance) {
//                            showBottomToast(
//                                'You are away from your location by  ${meter - _distance} meters, Please start your attendance near to your base loaction');
//                          } else {
//                            _startAttendanceApiCall(context);
//                          }
//                        },
//                      ),
//                    ),
//                  ),
                  //RAghu
                  Center(
                    child: Container(
                      padding: const EdgeInsets.only(
                        top: 20,
                      ),
                      height: 55,
                      margin: const EdgeInsets.all(0),
                      child: LoadingBtn(
                        height: 35,
                        borderRadius: 20,
                        animate: true,
                        color: global.appPrimaryColor,
                        width: MediaQuery.of(context).size.width * 0.45,
                        loader: Container(
                          padding: const EdgeInsets.all(10),
                          width: 35,
                          height: 35,
                          child: const CircularProgressIndicator(
                            valueColor:
                                AlwaysStoppedAnimation<Color>(Colors.white),
                          ),
                        ),
                        child: const Text("Start",
                            style: TextStyle(
                                fontSize: 16,
                                color: appWhiteColor,
                                fontFamily: font)),
                        onTap: (startLoading, stopLoading, btnState) async {
                          if (btnState == ButtonState.idle) {
                            startLoading();
                            // call your network api
                            if (_isSelfi == 1 && _imageFile == null) {
                              showBottomToast(
                                  'Selfie is mandatory for attendance');
                              stopLoading();
                            } else if ((result == '' && _select_bike == 1) ||
                                (result == 'NA' && _select_bike == 1)) {
                              showBottomToast('Scan the QR Code of the Bike');
                              stopLoading();
                            } else if (_isGeofence == 1 && meter > _distance) {
                              showBottomToast(
                                  'You are away from your location by  ${meter - _distance} meters, Please start your attendance near to your base location');
                              stopLoading();
                            } else
                              _startAttendanceApiCall(context);

                            await Future.delayed(const Duration(seconds: 10));
                            stopLoading();
                          } else {
                            Fluttertoast.showToast(
                                msg: "Please wait...",
                                toastLength: Toast.LENGTH_SHORT,
                                gravity: ToastGravity.CENTER,
//        timeInSecForIos: 1,
                                backgroundColor: Colors.red,
                                textColor: Colors.white,
                                fontSize: 16.0);
                          }
                        },
                      ),
                    ),
                  ),
                  // Container(
                  //   width: MediaQuery.of(context).size.width / 2,
                  //   child: ElevatedButton(
                  //     style: ElevatedButton.styleFrom(
                  //         backgroundColor: global.appDarkPrimaryColor,
                  //         // elevation: 10,
                  //         textStyle: const TextStyle(color: Colors.white),
                  //         padding: const EdgeInsets.all(0.0),
                  //         shape: RoundedRectangleBorder(
                  //             borderRadius: BorderRadius.circular(20.0))),
                  //     child: const Text('Start',
                  //         style: TextStyle(
                  //             fontFamily: font,
                  //             color: appWhiteColor,
                  //             fontSize: 16,
                  //             fontWeight: FontWeight.bold)),
                  //     onPressed: () async {
                  //       //showBottomToast('Start button tapped');
                  //       if (_isSelfi == 1 && _imageFile == null) {
                  //         showBottomToast('Selfie is mandatory for attendance');
                  //         // } else if (result==''||result=='NA') {
                  //         //Change by G1...
                  //       } else if ((result == '' && _select_bike == 1) ||
                  //           (result == 'NA' && _select_bike == 1)) {
                  //         showBottomToast('Scan the QR Code of the Bike');
                  //       } else if (_isGeofence == 1 && meter > _distance) {
                  //         showBottomToast(
                  //             'You are away from your location by  ${meter - _distance} meters, Please start your attendance near to your base location');
                  //       } else if (dropDownValue == null) {
                  //         showBottomToast('Select Work Location');
                  //       } else {
                  //         if (!isDisabled) {
                  //           // if (isDisabled == false) {
                  //           // showBottomToast('Successful');
                  //           showLoader(context);
                  //           _startAttendanceApiCall(context);
                  //         }
                  //       }
                  //     },
                  //   ),
                  // ),
                  const SizedBox(
                    height: 20.0,
                  ),
                ],
              ),
            );
          });
        }).then((val) {
      setState(() {});
    });
  }

  double calculateDistance(dynamic selectedlat, dynamic selectedlng,
      dynamic compareLat, dynamic compareLng) {
    var p = 0.017453292519943295;
    var c = cos;
    var a = 0.5 -
        c((selectedlat - compareLat) * p) / 2 +
        c(compareLat * p) *
            c(selectedlat * p) *
            (1 - c((selectedlng - compareLng) * p)) /
            2;
    // print("back screen ${compareLat} &&& ${compareLng}");
    // print(" google map1 ${selectedlat} &&& ${selectedlng}");
    // print( lngSelected);
    return 12742 * asin(sqrt(a));
  }

  void _startAttendanceApiCall(BuildContext _context) async {
    var connectivityResult = await (Connectivity().checkConnectivity());
    if (connectivityResult != ConnectivityResult.none) {
      //sahil changes
      geo.Position position = await geo.Geolocator.getCurrentPosition(
          desiredAccuracy: geo.LocationAccuracy.best);

      // print("Current lat lng: ${position.latitude}, ${position.longitude}");

      //showBottomToast('start api call');
      var map = new Map<String, dynamic>();
      map["appType"] = Platform.operatingSystem.toUpperCase();
      map["userId"] = '$_userId';
      map["api_token"] = _apiToken;
      map["punchTypeId"] = '1';
      map["deviceId"] = deviceId;
      map['punchDate'] =
          DateFormat('yyyy-MM-dd').format(DateTime.now().toUtc());
      map['time'] =
          DateFormat('yyyy-MM-dd HH:mm:ss').format(DateTime.now().toUtc());

//    map['time'] = _serverTime;

      map['longitude'] = '${position.longitude}';
      map['latitude'] = '${position.latitude}';
      //print("Current");
      map['workTypeId'] = dropDownValue;
      if (_isSelfi == 1) {
        String _imageData =
            "data:image/jpeg;base64,${base64Encode(_imageFile!.readAsBytesSync()).toString()}";
        map['attachment'] = _imageData;
      }
      print(map);

      try {
        // showLoader(context);
        _networkUtil.post(apiAttendanceMark, body: map).then((dynamic res) {
          try {
            // print('G1--->04');
            // Navigator.pop(context);
            AppLog.showLog(res.toString());
            StartAttendanceApiCallBack _startAttendanceApiCallBack =
                StartAttendanceApiCallBack.fromJson(res);
            // print('G1--->01');
            if (_startAttendanceApiCallBack.status == unAuthorised) {
              logout();
            } else if (_startAttendanceApiCallBack.success) {
              // print('G1--->02');
              saveStartSPData(_startAttendanceApiCallBack.items!);
              _scheduleNotification(
                  '${DateFormat("yyyy-MM-dd HH:mm:ss").parse(_startAttendanceApiCallBack.items!.inTime, true).toLocal()}');
              showBottomToast(_startAttendanceApiCallBack.message);
              // showBottomToast('Start attendance sucess');
              Future.delayed(Duration.zero, () {
                Navigator.pop(context);
              });
              _uploadAttendanceLocationApiCall('1');
              // if (!isDisabled) {
              //   // if (isDisabled == false) {
              //   if (position != null) {
              //     _uploadAttendanceLocationApiCall(
              //         '1', position.latitude, position.longitude);
              //   } else if (_startLocation != null) {
              //     _uploadAttendanceLocationApiCall(
              //         '1', _startLocation.latitude, _startLocation.longitude);
              //   } else {
              //     _uploadAttendanceLocationApiCall(
              //         '1', _pos.latitude, _pos.longitude);
              //   }
              // }
            } else {
              //print('Sahil else');
              showBottomToast(_startAttendanceApiCallBack.message);
              // showBottomToast('Start attendance failure');
            }
          } catch (se) {
            showErrorLog(se.toString());
            showCenterToast(errorApiCall);
            // showBottomToast('Start attendance se');
          }
        });
      } catch (e) {
        showErrorLog(e.toString());
        showCenterToast(errorApiCall);
        // showBottomToast('Start attendance e');
      }
    } else {
      showCenterToast('No Internet Connection');
    }
  }

  void saveStartSPData(Items items) async {
    //showBottomToast('Enter in saveStartSPData');
    final SharedPreferences prefss = await _prefs;
    prefss.setInt(SP_ATTENDANCE_STATUS, 1);

    prefss.setInt(SP_ATTENDANCE_ID, items.id);
    prefss.setString(SP_TRACKER_IN_TIME,
        DateFormat('yyyy-MM-dd%20HH:mm').format(DateTime.now()));

    prefss.setString(SP_ATTENDANCE_DATE,
        DateFormat('yyyy-MM-dd').format(DateTime.now().toUtc()));
    prefss.setString(SP_ATTENDANCE_IN_TIME,
        DateFormat('hh:mm a').format(DateTime.now().toUtc()));

    prefss.setString(SP_ATTENDANCE_IN_TIME_DATE, '${DateTime.now().toUtc()}');
    setState(() {});
    getSpData();
  }

  ///Start attendance location dropdown options
  Future apiCallForGetWorkingType() async {
    final SharedPreferences prefs = await _prefs;
    if (prefs.getBool(SP_IS_LOGIN_BOOL) != null) {
      _userId = prefs.getInt(SP_ID)!;
      _apiToken = prefs.getString(SP_API_TOKEN)!;
      _companyId = prefs.getInt(SP_COMPANY_ID)!;
      _driver_delivery = prefs.getInt(SP_DRIVER)!;
    }
    if (_driver_delivery > 0) {
      return 0;
    }
    var map = new Map<String, dynamic>();
    map["api_token"] = _apiToken;
    map["appType"] = Platform.operatingSystem.toUpperCase();
    map["userId"] = '$_userId';
    map["companyId"] = '$_companyId';
    // map['isDiver'] = _driver_delivery;

    try {
      _noDataFound = 'Loading...';
      _networkUtil.post(apiGetWorkingTypeList, body: map).then((dynamic res) {
        _noDataFound = noDataFound;
        try {
          AppLog.showLog(res.toString());
          _workingTypeApiCallBack = WorkingTypeApiCallBack.fromJson(res);
          if (_workingTypeApiCallBack!.status == unAuthorised) {
            logout();
          } else if (!(_workingTypeApiCallBack!.success ?? false)) {
            showBottomToast(_workingTypeApiCallBack!.message ?? "");
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

  /// pause Attendance-----------------------
  void pauseAttendanceDialog() {
    showDialog(
        context: context,
        barrierDismissible: false,
        builder: (BuildContext context) {
          return StatefulBuilder(builder: (context, setState) {
            return AlertDialog(
              contentPadding: const EdgeInsets.all(0),
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.all(
                      Radius.circular(ScreenUtil().setSp(10)))),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: <Widget>[
                  Container(
                      decoration: new BoxDecoration(
                          color: global.appPrimaryColor,
                          borderRadius: const BorderRadius.only(
                              topLeft: const Radius.circular(10),
                              topRight: const Radius.circular(10))),
                      padding: const EdgeInsets.all(15),
                      child: Row(
                        children: <Widget>[
                          Text(
                            'Pause Your Attendance',
                            textAlign: TextAlign.center,
                            style: TextStyle(
                                fontSize: ScreenUtil().setSp(16),
                                fontFamily: font,
                                fontWeight: FontWeight.bold,
                                color: appWhiteColor),
                          ),
                          Expanded(
                            child: Container(),
                          ),
                          GestureDetector(
                            child: const Icon(
                              Icons.close,
                              color: Colors.white,
                              size: 30.0,
                            ),
                            onTap: () {
                              Navigator.pop(context);
                            },
                          )
                        ],
                      )),
                  const SizedBox(
                    height: 5.0,
                  ),
                  Padding(
                    padding: const EdgeInsets.only(left: 16.0, right: 16.0),
                    child: Row(
                      children: <Widget>[
                        Flexible(
                          flex: 2,
                          child: Text('Time  :',
                              style: TextStyle(
                                color: global.colorTextDarkBlue,
                                fontSize: 15.0,
                                fontFamily: font,
                                fontWeight: FontWeight.bold,
                              )),
                        ),
                        const SizedBox(
                          width: 10.0,
                        ),
                        Flexible(
                          flex: 3,
                          child:
                              Text(DateFormat('hh:mm a').format(DateTime.now()),
                                  style: TextStyle(
                                    color: global.colorTextDarkBlue,
                                    fontSize: 15.0,
                                    fontFamily: font,
                                    fontWeight: FontWeight.bold,
                                  )),
                        ),
                      ],
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.only(left: 16.0, right: 16.0),
                    child: Text('Do you want to pause your attendance?',
                        style: TextStyle(
                          fontSize: 15.0,
                          color: global.colorTextDarkBlue,
                          fontFamily: font,
                          fontWeight: FontWeight.bold,
                        )),
                  ),
                  const SizedBox(
                    height: 10.0,
                  ),
                  Form(
                    key: _formKey,
                    child: Column(
                      children: <Widget>[
                        Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: TextFormField(
                            style: const TextStyle(fontFamily: font),
                            controller: reasonController,
                            maxLines: 4,
                            autovalidateMode: AutovalidateMode.always,
                            autocorrect: true,
                            keyboardType: TextInputType.text,
                            // validator: (val) {
                            //   if (val.isEmpty) {
                            //     return 'Reason is required';
                            //   }
                            //   return null;
                            // },
                            onSaved: (String? value) {
                              _reason = value!;
                              print(value);
                            },
                            decoration: InputDecoration(
                              labelText: 'Reason',
                              contentPadding: const EdgeInsets.fromLTRB(
                                  10.0, 10.0, 10.0, 10.0),
                              border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(25.0)),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(
                    height: 15.0,
                  ),
                  Center(
                    child: Container(
                      padding: const EdgeInsets.only(
                        top: 20,
                      ),
                      height: 55,
                      margin: const EdgeInsets.all(0),
                      child: LoadingBtn(
                        height: 35,
                        borderRadius: 20,
                        animate: true,
                        color: global.appPrimaryColor,
                        width: MediaQuery.of(context).size.width * 0.45,
                        loader: Container(
                          padding: const EdgeInsets.all(10),
                          width: 35,
                          height: 35,
                          child: const CircularProgressIndicator(
                            valueColor:
                                AlwaysStoppedAnimation<Color>(Colors.white),
                          ),
                        ),
                        child: const Text("Pause",
                            style: TextStyle(
                                fontSize: 16,
                                color: appWhiteColor,
                                fontFamily: font)),
                        onTap: (startLoading, stopLoading, btnState) async {
                          if (btnState == ButtonState.idle) {
                            startLoading();
                            // call your network api
                            if (_formKey.currentState!.validate() &&
                                reasonController.text.isNotEmpty) {
                              _formKey.currentState!.save();
                              _pauseAttendanceApiCall(context);
                              // reasonController.text = "";
                            } else {
                              showBottomToast('Reason is required');
                              stopLoading();
                            }
                            await Future.delayed(const Duration(seconds: 10));
                            stopLoading();
                          } else {
                            Fluttertoast.showToast(
                                msg: "Please wait...",
                                toastLength: Toast.LENGTH_SHORT,
                                gravity: ToastGravity.CENTER,
//        timeInSecForIos: 1,
                                backgroundColor: Colors.red,
                                textColor: Colors.white,
                                fontSize: 16.0);
                          }
                        },
                      ),
                    ),
                  ),
                  // Padding(
                  //   padding: const EdgeInsets.only(left: 60, right: 60),
                  //   child: ElevatedButton(
                  //       style: ElevatedButton.styleFrom(
                  //           backgroundColor: global.btnBgColor,
                  //           elevation: 0,
                  //           textStyle: const TextStyle(color: Colors.white),
                  //           padding: const EdgeInsets.all(0.0),
                  //           shape: RoundedRectangleBorder(
                  //               borderRadius: BorderRadius.circular(20.0))),
                  //       child: const Text('Pause',
                  //           style: TextStyle(
                  //               fontSize: 16,
                  //               color: appWhiteColor,
                  //               fontFamily: font)),
                  //       onPressed: () async {
                  //         print(isDisabled);
                  //         if (!isDisabled) {
                  //           // if (isDisabled == false) {
                  //           if (_formKey.currentState.validate() &&
                  //               reasonController.text.isNotEmpty) {
                  //             _formKey.currentState.save();
                  //             showLoader(context);
                  //             _pauseAttendanceApiCall(context);
                  //             // reasonController.text = "";
                  //           } else {
                  //             showBottomToast('Reason is required');
                  //           }
                  //         }
                  //       }),
                  // ),
                  const SizedBox(
                    height: 15.0,
                  ),
                ],
              ),
            );
          });
        }).then((val) {
      setState(() {});
    });
  }

  void _pauseAttendanceApiCall(BuildContext _context) async {
    var connectivityResult = await (Connectivity().checkConnectivity());
    if (connectivityResult != ConnectivityResult.none) {
      geo.Position position = await geo.Geolocator.getCurrentPosition(
          desiredAccuracy: geo.LocationAccuracy.best);

      //print("Current lat lng: ${position.latitude}, ${position.longitude}");
      // showLoader(context);
      var map = new Map<String, dynamic>();
      final SharedPreferences prefs = await _prefs;
      if (prefs.getBool(SP_IS_LOGIN_BOOL) != null) {
        _userId = prefs.getInt(SP_ID)!;
        _apiToken = prefs.getString(SP_API_TOKEN)!;
      }
      map["appType"] = Platform.operatingSystem.toUpperCase();
      map["userId"] = '$_userId';
      map["api_token"] = _apiToken;
      map["punchTypeId"] = '3';
      map['punchDate'] =
          DateFormat('yyyy-MM-dd').format(DateTime.now().toUtc());
//    map['punchDate'] = getDateTime(_serverTime, 'yyyy-MM-dd');
      map['time'] =
          DateFormat('yyyy-MM-dd HH:mm:ss').format(DateTime.now().toUtc());
//    map['time'] = _serverTime;

      map['longitude'] = '${position.longitude}';
      map['latitude'] = '${position.latitude}';
      //print("Current");
      map['reason'] = _reason;
      map["deviceId"] = deviceId;

      print(map);
      try {
        _networkUtil.post(apiAttendanceMark, body: map).then((dynamic res) {
          AppLog.showLog(res.toString());
          PauseAttendanceApiCall _pauseAttendanceApiCall =
              PauseAttendanceApiCall.fromJson(res);
          if (_pauseAttendanceApiCall.status == unAuthorised) {
            logout();
          } else if (_pauseAttendanceApiCall.success) {
            showBottomToast(_pauseAttendanceApiCall.message);
            savePauseSPData(_pauseAttendanceApiCall.items!);
            _scheduleNotificationForPause(
                '${DateFormat("yyyy-MM-dd HH:mm:ss").parse(_pauseAttendanceApiCall.items!.inTime, true).toLocal()}');
            _uploadAttendanceLocationApiCall('2');
            Future.delayed(Duration.zero, () {
              // Navigator.pop(context);
              Navigator.pop(_context);
            });
            // if (!isDisabled) {
            //   if (position != null) {
            //     _uploadAttendanceLocationApiCall(
            //         '2', position.latitude, position.longitude);
            //   } else if (_startLocation != null) {
            //     _uploadAttendanceLocationApiCall(
            //         '2', _startLocation.latitude, _startLocation.longitude);
            //   } else {
            //     _uploadAttendanceLocationApiCall(
            //         '2', _pos.latitude, _pos.longitude);
            //   }
            // }
            reasonController.text = "";
          } else {
            showBottomToast(_pauseAttendanceApiCall.message);
          }
        });
      } catch (e) {
        setState(() {
          isDisabled = false;
        });
        showErrorLog(e.toString());
        showCenterToast(errorApiCall);
      }
    } else {
      showCenterToast('No Internet Connection');
    }
  }

  void savePauseSPData(PauseItems items) async {
    final SharedPreferences prefss = await _prefs;
    prefss.setInt(SP_ATTENDANCE_BREAK_ID, items.id);
    prefss.setInt(SP_ATTENDANCE_STATUS, 2);
    getSpData();
  }

  /// resume Attendance----------------------
  void resumeAttendanceDialog() {
    showDialog(
        context: context,
        barrierDismissible: false,
        builder: (BuildContext context) {
          return StatefulBuilder(builder: (context, setState) {
            return AlertDialog(
              contentPadding: const EdgeInsets.all(0),
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.all(
                      Radius.circular(ScreenUtil().setSp(10)))),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: <Widget>[
                  Container(
                      decoration: new BoxDecoration(
                          color: global.appPrimaryColor,
                          borderRadius: const BorderRadius.only(
                              topLeft: const Radius.circular(10),
                              topRight: const Radius.circular(10))),
                      padding: const EdgeInsets.all(15),
                      child: Row(
                        children: <Widget>[
                          Text(
                            'Resume Your Attendance',
                            textAlign: TextAlign.center,
                            style: TextStyle(
                                fontSize: ScreenUtil().setSp(16),
                                fontWeight: FontWeight.bold,
                                fontFamily: font,
                                color: appWhiteColor),
                          ),
                          Expanded(
                            child: Container(),
                          ),
                          GestureDetector(
                            child: const Icon(
                              Icons.close,
                              color: Colors.white,
                              size: 30.0,
                            ),
                            onTap: () {
                              Navigator.pop(context);
                            },
                          )
                        ],
                      )),
                  const SizedBox(
                    height: 5.0,
                  ),
                  Padding(
                    padding: const EdgeInsets.only(left: 16.0, right: 16.0),
                    child: Row(
                      children: <Widget>[
                        Flexible(
                          flex: 2,
                          child: Text('Time  :',
                              style: TextStyle(
                                fontSize: 15.0,
                                fontFamily: font,
                                color: global.colorTextDarkBlue,
                                fontWeight: FontWeight.bold,
                              )),
                        ),
                        const SizedBox(
                          width: 10.0,
                        ),
                        Flexible(
                          flex: 3,
                          child:
                              Text(DateFormat('hh:mm a').format(DateTime.now()),
                                  style: TextStyle(
                                    fontSize: 15.0,
                                    fontFamily: font,
                                    color: global.colorTextDarkBlue,
                                    fontWeight: FontWeight.bold,
                                  )),
                        ),
                      ],
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.only(left: 16.0, right: 16.0),
                    child: Text('Do you want to resume your attendance?',
                        style: TextStyle(
                          fontSize: 15.0,
                          fontFamily: font,
                          color: global.colorTextDarkBlue,
                          fontWeight: FontWeight.bold,
                        )),
                  ),
                  const SizedBox(
                    height: 10.0,
                  ),
                  Container(),
                  Center(
                    child: Container(
                      padding: const EdgeInsets.only(
                        top: 20,
                      ),
                      height: 55,
                      margin: const EdgeInsets.all(0),
                      child: LoadingBtn(
                        height: 35,
                        borderRadius: 20,
                        animate: true,
                        color: global.appPrimaryColor,
                        width: MediaQuery.of(context).size.width * 0.45,
                        loader: Container(
                          padding: const EdgeInsets.all(10),
                          width: 35,
                          height: 35,
                          child: const CircularProgressIndicator(
                            valueColor:
                                AlwaysStoppedAnimation<Color>(Colors.white),
                          ),
                        ),
                        child: const Text("Resume",
                            style: TextStyle(
                                fontSize: 16,
                                color: appWhiteColor,
                                fontFamily: font)),
                        onTap: (startLoading, stopLoading, btnState) async {
                          if (btnState == ButtonState.idle) {
                            startLoading();
                            // call your network api
                            _resumeAttendanceApiCall(context);
                            await Future.delayed(const Duration(seconds: 10));
                            stopLoading();
                          } else {
                            Fluttertoast.showToast(
                                msg: "Please wait...",
                                toastLength: Toast.LENGTH_SHORT,
                                gravity: ToastGravity.CENTER,
//        timeInSecForIos: 1,
                                backgroundColor: Colors.red,
                                textColor: Colors.white,
                                fontSize: 16.0);
                          }
                        },
                      ),
                    ),
                  ),
                  // Center(
                  //   child: Container(
                  //       padding: const EdgeInsets.only(
                  //         top: 20,
                  //       ),
                  //       height: 55,
                  //       margin: const EdgeInsets.all(0),
                  //       child: ElevatedButton(
                  //         style: ElevatedButton.styleFrom(
                  //             backgroundColor: global.appPrimaryColor,
                  //             elevation: 5,
                  //             textStyle: const TextStyle(color: Colors.white),
                  //             padding: const EdgeInsets.all(0.0),
                  //             shape: RoundedRectangleBorder(
                  //                 borderRadius: BorderRadius.circular(20.0))),
                  //         child: Container(
                  //           decoration: const BoxDecoration(
                  //               borderRadius:
                  //                   BorderRadius.all(Radius.circular(20.0))),
                  //           padding: const EdgeInsets.fromLTRB(70, 7, 70, 7),
                  //           child: const Text('Resume',
                  //               style: TextStyle(
                  //                   fontSize: 17, color: appWhiteColor)),
                  //         ),
                  //         onPressed: () {
                  //           if (!isDisabled) {
                  //             // if (isDisabled == false) {
                  //             showLoader(context);
                  //             _resumeAttendanceApiCall(context);
                  //           }
                  //         },
                  //       )),
                  // ),
//                  Padding(
//                    padding: const EdgeInsets.only(left: 50.0, right: 50.0),
//                    child: Card(
//                      shape: RoundedRectangleBorder(
//                        borderRadius: BorderRadius.circular(20.0),
//                      ),
//                      color: appColorRedIcon,
//                      child: GestureDetector(
//                        child: Center(
//                          child: Padding(
//                            padding: const EdgeInsets.all(8.0),
//                            child: Center(
//                              child: Text('Resume',
//                                  style: TextStyle(
//                                    color: Colors.white,
//                                    fontSize: 15.0,
//                                    fontWeight: FontWeight.bold,
//                                  )),
//                            ),
//                          ),
//                        ),
//                        onTap: () async {
//                          _resumeAttendanceApiCall(context);
//                        },
//                      ),
//                    ),
//                  ),
                  const SizedBox(
                    height: 15.0,
                  ),
                ],
              ),
            );
          });
        }).then((val) {
      setState(() {});
    });
  }

  Future<void> _resumeAttendanceApiCall(BuildContext _context) async {
    var connectivityResult = await (Connectivity().checkConnectivity());
    if (connectivityResult != ConnectivityResult.none) {
      geo.Position position = await geo.Geolocator.getCurrentPosition(
          desiredAccuracy: geo.LocationAccuracy.best);

      //print("Current lat lng: ${position.latitude}, ${position.longitude}");
      // showLoader(context);
      var map = new Map<String, dynamic>();
      map["appType"] = Platform.operatingSystem.toUpperCase();
      map["userId"] = '$_userId';
      map["id"] = '$_attendanceBreakId';
      map["api_token"] = _apiToken;
      map["punchTypeId"] = '4';
      map['punchDate'] =
          DateFormat('yyyy-MM-dd').format(DateTime.now().toUtc());
      map['time'] =
          DateFormat('yyyy-MM-dd HH:mm:ss').format(DateTime.now().toUtc());
//    map['time'] = _serverTime;

      map['longitude'] = '${position.longitude}';
      map['latitude'] = '${position.latitude}';
      //print("Current");
      map["deviceId"] = deviceId;

      print(map);

      try {
        _networkUtil.post(apiAttendanceMark, body: map).then((dynamic res) {
          AppLog.showLog(res.toString());
          ResumeAttendanceApiCallBack _resumeAttendanceApiCallBack =
              ResumeAttendanceApiCallBack.fromJson(res);
          if (_resumeAttendanceApiCallBack.status == unAuthorised) {
            logout();
          } else if (_resumeAttendanceApiCallBack.success) {
            showBottomToast(_resumeAttendanceApiCallBack.message);
            saveResumeSPData();
            cancelNotificationForPause(
                _resumeAttendanceApiCallBack.resumeItems!.outTime,
                _resumeAttendanceApiCallBack.resumeItems!.inTime);
            _uploadAttendanceLocationApiCall('3');
            Future.delayed(Duration.zero, () {
              Navigator.pop(_context);
            });
            setState(() {});
            // if (!isDisabled) {
            //   // if (isDisabled == false) {
            //   if (position != null) {
            //     _uploadAttendanceLocationApiCall(
            //         '3', position.latitude, position.longitude);
            //   } else if (_startLocation != null) {
            //     _uploadAttendanceLocationApiCall(
            //         '3', _startLocation.latitude, _startLocation.longitude);
            //   } else {
            //     _uploadAttendanceLocationApiCall(
            //         '3', _pos.latitude, _pos.longitude);
            //   }
            // }
          } else {
            showBottomToast(_resumeAttendanceApiCallBack.message);
          }
        });
      } catch (e) {
        showErrorLog(e.toString());
        showCenterToast(errorApiCall);
      }
    } else {
      showCenterToast('No Internet Connection');
    }
    //   } catch (e) {
    //     setState(() {
    //       isDisabled = false;
    //     });
    //     showErrorLog(e.toString());
    //   }
    // }
  }

  Future cancelNotificationForPause(String out, String inTime) async {
    int pauseTime =
        DateTime.parse(out).difference(DateTime.parse(inTime)).inMinutes;
    if (pauseTime < 45) {
      await flutterLocalNotificationsPlugin.cancel(10);
    }
  }

  void saveResumeSPData() async {
    final SharedPreferences prefss = await _prefs;
    prefss.setInt(SP_ATTENDANCE_STATUS, 3);
    getSpData();
  }

  /// stop Attendance------------------------
  void stopAttendanceDialog() {
    showDialog(
        context: context,
        barrierDismissible: false,
        builder: (BuildContext context) {
          return StatefulBuilder(builder: (context, setState) {
            return AlertDialog(
              contentPadding: const EdgeInsets.all(0),
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.all(
                      Radius.circular(ScreenUtil().setSp(10)))),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: <Widget>[
                  Container(
                      decoration: new BoxDecoration(
                          color: appColorRedIcon,
                          borderRadius: const BorderRadius.only(
                              topLeft: const Radius.circular(10),
                              topRight: const Radius.circular(10))),
                      padding: const EdgeInsets.all(15),
                      child: Row(
                        children: <Widget>[
                          Text(
                            'Stop Your Attendance',
                            textAlign: TextAlign.center,
                            style: TextStyle(
                                fontSize: ScreenUtil().setSp(16),
                                fontWeight: FontWeight.bold,
                                fontFamily: font,
                                color: appWhiteColor),
                          ),
                          Expanded(
                            child: Container(),
                          ),
                          GestureDetector(
                            child: const Icon(
                              Icons.close,
                              color: Colors.white,
                              size: 30.0,
                            ),
                            onTap: () {
                              Navigator.pop(context);
                            },
                          )
                        ],
                      )),
                  const SizedBox(
                    height: 5.0,
                  ),
                  Padding(
                    padding: const EdgeInsets.only(left: 16.0, right: 16.0),
                    child: Row(
                      children: <Widget>[
                        Flexible(
                          flex: 2,
                          child: Text('Time  :',
                              style: TextStyle(
                                fontSize: 15.0,
                                fontFamily: font,
                                color: global.colorTextDarkBlue,
                                fontWeight: FontWeight.bold,
                              )),
                        ),
                        const SizedBox(
                          width: 10.0,
                        ),
                        Flexible(
                          flex: 3,
                          child:
                              Text(DateFormat('hh:mm a').format(DateTime.now()),
                                  style: TextStyle(
                                    fontSize: 15.0,
                                    fontFamily: font,
                                    color: global.colorTextDarkBlue,
                                    fontWeight: FontWeight.bold,
                                  )),
                        ),
                      ],
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.only(left: 16.0, right: 16.0),
                    child: Text('Do you want to stop your attendance?',
                        style: TextStyle(
                          fontSize: 15.0,
                          fontFamily: font,
                          color: global.colorTextDarkBlue,
                          fontWeight: FontWeight.bold,
                        )),
                  ),
                  const SizedBox(
                    height: 10.0,
                  ),
                  Center(
                    child: Container(
                      padding: const EdgeInsets.only(
                        top: 20,
                      ),
                      height: 55,
                      margin: const EdgeInsets.all(0),
                      child: LoadingBtn(
                        height: 35,
                        borderRadius: 20,
                        animate: true,
                        color: appColorRedIcon,
                        width: MediaQuery.of(context).size.width * 0.45,
                        loader: Container(
                          padding: const EdgeInsets.all(10),
                          width: 35,
                          height: 35,
                          child: const CircularProgressIndicator(
                            valueColor:
                                AlwaysStoppedAnimation<Color>(Colors.white),
                          ),
                        ),
                        child: const Text("Stop",
                            style: TextStyle(
                                fontSize: 16,
                                color: appWhiteColor,
                                fontFamily: font)),
                        onTap: (startLoading, stopLoading, btnState) async {
                          if (btnState == ButtonState.idle) {
                            startLoading();
                            // call your network api
                            _stopAttendanceApiCall(context);
                            await Future.delayed(const Duration(seconds: 10));
                            stopLoading();
                          } else {
                            Fluttertoast.showToast(
                                msg: "Please wait...",
                                toastLength: Toast.LENGTH_SHORT,
                                gravity: ToastGravity.CENTER,
//        timeInSecForIos: 1,
                                backgroundColor: Colors.red,
                                textColor: Colors.white,
                                fontSize: 16.0);
                          }
                        },
                      ),
                    ),
                  ),
                  // Center(
                  //   child: Container(
                  //       padding: const EdgeInsets.only(
                  //         top: 20,
                  //       ),
                  //       height: 55,
                  //       margin: const EdgeInsets.all(0),
                  //       child: ElevatedButton(
                  //         style: ElevatedButton.styleFrom(
                  //             elevation: 5,
                  //             textStyle: const TextStyle(color: Colors.white),
                  //             padding: const EdgeInsets.all(0.0),
                  //             shape: RoundedRectangleBorder(
                  //                 borderRadius: BorderRadius.circular(20.0))),
                  //         child: Container(
                  //           decoration: const BoxDecoration(
                  //               gradient: LinearGradient(
                  //                 colors: <Color>[
                  //                   appColorRedIcon,
                  //                   Colors.redAccent,
                  //                 ],
                  //               ),
                  //               borderRadius:
                  //                   BorderRadius.all(Radius.circular(20.0))),
                  //           padding: const EdgeInsets.fromLTRB(70, 7, 70, 7),
                  //           child: const Text('Stop',
                  //               style: TextStyle(
                  //                 fontSize: 17,
                  //                 fontFamily: font,
                  //                 color: appWhiteColor,
                  //               )),
                  //         ),
                  //         onPressed: () {
                  //           // if (_totalDistance <= 5) {
                  //           //   _stopAttendanceApiCall(context);
                  //           //   showBottomToast("You are in working radius");
                  //           // } else {
                  //           //   showBottomToast("You are not in working radius");
                  //           // }
                  //           // if (isDisabled == false) {
                  //           if (!isDisabled) {
                  //             showLoader(context);
                  //             _stopAttendanceApiCall(context);
                  //           }
                  //         },
                  //       )),
                  // ),
                  const SizedBox(
                    height: 15.0,
                  ),
                ],
              ),
            );
          });
        }).then((val) {
      setState(() {});
    });
  }

  Future<void> _stopAttendanceApiCall(BuildContext _context) async {
    var connectivityResult = await (Connectivity().checkConnectivity());
    if (connectivityResult != ConnectivityResult.none) {
      geo.Position position = await geo.Geolocator.getCurrentPosition(
          desiredAccuracy: geo.LocationAccuracy.high);
      setState(() {});
      // print("Current lat lng: ${position.latitude}, ${position.longitude}");
      geo.Position _CurrentLocation = await geo.Geolocator.getCurrentPosition();
      var map = new Map<String, dynamic>();
      map["appType"] = Platform.operatingSystem.toUpperCase();
      map["userId"] = '$_userId';
      map["api_token"] = _apiToken;
      map["punchTypeId"] = '2';
      map["id"] = '$_attendanceId';
      map['time'] =
          DateFormat('yyyy-MM-dd HH:mm:ss').format(DateTime.now().toUtc());
//    map['time'] = _serverTime;

      map['longitude'] = '${position.longitude}';
      map['latitude'] = '${position.latitude}';
      //print("Current");
      map["deviceId"] = deviceId;
      print(map);
      try {
        _networkUtil.post(apiAttendanceMark, body: map).then((dynamic res) {
          AppLog.showLog(res.toString());
          StopAttendanceApiCallBack _stopAttendanceApiCallBack =
              StopAttendanceApiCallBack.fromJson(res);
          if (_stopAttendanceApiCallBack.status == unAuthorised) {
            logout();
          } else if (_stopAttendanceApiCallBack.success) {
            saveStopSPData();
            //cancelNotification();
            cancelNotification(_stopAttendanceApiCallBack.items!.outTime,
                _stopAttendanceApiCallBack.items!.inTime);
            _uploadAttendanceLocationApiCall('4');
            Future.delayed(Duration.zero, () {
              Navigator.of(context).pop();
            });
            // if (isDisabled == false) {

            // if (!isDisabled) {
            //   if (position != null) {
            //     _uploadAttendanceLocationApiCall(
            //         '4', position.latitude, position.longitude);
            //   } else if (_startLocation != null) {
            //     _uploadAttendanceLocationApiCall(
            //         '4', _startLocation.latitude, _startLocation.longitude);
            //   } else {
            //     _uploadAttendanceLocationApiCall(
            //         '4', _pos.latitude, _pos.longitude);
            //   }
            // }
          } else {
            showBottomToast(_stopAttendanceApiCallBack.message);
          }
        });
      } catch (e) {
        showErrorLog(e.toString());
        showCenterToast(errorApiCall);
      }
    } else {
      showCenterToast('No Internet Connection');
    }
  }

  void saveStopSPData() async {
    final SharedPreferences prefss = await _prefs;
    prefss.setInt(SP_ATTENDANCE_STATUS, 4);
    prefss.setString(SP_ATTENDANCE_OUT_TIME,
        DateFormat('hh:mm a').format(DateTime.now().toUtc()));
    prefss.setString(SP_ATTENDANCE_OUT_TIME_DATE, '${DateTime.now().toUtc()}');
    prefss.setString(SP_TRACKER_OUT_TIME,
        DateFormat('yyyy-MM-dd%20HH:mm').format(DateTime.now()));

    getSpData();
  }

  ///To do by Raghu
  ///Please check time (_totalHours)
  // Future cancelNotification() async {
  //   //int workTime =
  //   //   DateTime.parse(out).difference(DateTime.parse(inTime)).inHours;
  //   if (double.parse(_totalHours) < 9.00) {
  //     await flutterLocalNotificationsPlugin.cancel(1);
  //   }
  // }
  Future cancelNotification(String outTime, String inTime) async {
    int workTime =
        DateTime.parse(outTime).difference(DateTime.parse(inTime)).inMinutes;
    if (workTime < 570) {
      await flutterLocalNotificationsPlugin.cancel(1);
    }
  }

  void _totalHoursShow() {
    try {
      if (_attendanceStatus > 0 && _attendanceStatus < 4) {
        int inHours = DateTime.now()
            .difference(DateFormat("yyyy-MM-dd HH:mm:ss")
                .parse(_fullInTime, true)
                .toLocal())
            .inHours;
        int inMinutes = DateTime.now()
            .difference(DateFormat("yyyy-MM-dd HH:mm:ss")
                .parse(_fullInTime, true)
                .toLocal())
            .inMinutes;
        _timeCountChart = (double.parse(
                    (inMinutes / workingMiniutes).toStringAsFixed(2)) >
                0.01)
            ? (double.parse((inMinutes / workingMiniutes).toStringAsFixed(2)) >
                    1)
                ? 1.0
                : double.parse((inMinutes / workingMiniutes).toStringAsFixed(2))
            : 0.01;
        _totalHours =
            '${inHours.toString().padLeft(2, '0')}:${(inMinutes % 60).toString().padLeft(2, '0')}';
      } else if (_attendanceStatus == 4) {
        int inHours = DateTime.parse(_fullOutTime)
            .difference(DateTime.parse(_fullInTime))
            .inHours;
        int inMinutes = DateTime.parse(_fullOutTime)
            .difference(DateTime.parse(_fullInTime))
            .inMinutes;
        _timeCountChart = (double.parse(
                    (inMinutes / workingMiniutes).toStringAsFixed(2)) >
                0.01)
            ? (double.parse((inMinutes / workingMiniutes).toStringAsFixed(2)) >
                    1)
                ? 1.0
                : double.parse((inMinutes / workingMiniutes).toStringAsFixed(2))
            : 0.01;
        //print(_timeCountChart);
        _totalHours =
            '${inHours.toString().padLeft(2, '0')}:${(inMinutes % 60).toString().padLeft(2, '0')}';
      } else {
        _totalHours = '00:00';
        _timeCountChart = 0.01;
      }
    } catch (e) {
      print(e.toString());
    }
    setState(() {});
  }

  /// meeting and task api call-------------
  Future apiCallForGetMeeting() async {
    final SharedPreferences prefs = await _prefs;
    if (prefs.getBool(SP_IS_LOGIN_BOOL) != null) {
      _userId = prefs.getInt(SP_ID)!;
      _apiToken = prefs.getString(SP_API_TOKEN)!;
    }
    var map = new Map<String, dynamic>();
    map["appType"] = Platform.operatingSystem.toUpperCase();
    map["userId"] = _userId.toString();
    map["api_token"] = _apiToken;
    map['meetingDate'] = new DateFormat('yyyy-MM-dd').format(DateTime.now());
    try {
      _noDataFound = 'Loading...';
      _networkUtil.post(apiMeetingList, body: map).then((dynamic res) {
        _noDataFound = noDataFound;
        try {
          AppLog.showLog(res.toString());
          _meetingListApiCallBack = MeetingListApiCallBack.fromJson(res);
          if (_meetingListApiCallBack!.status == unAuthorised) {
            logout();
          } else if (_meetingListApiCallBack!.success) {
            _taskCount = _meetingListApiCallBack!.items.length
                .toString()
                .padLeft(2, '0');
            if (_meetingListApiCallBack!.items.length < 10) {
//              _taskCountChart = (_meetingListApiCallBack.items.length / 10);
              //print(_taskCount + "taskCount");
            } else {
              _taskCountChart = (_meetingListApiCallBack!.items.length / 20);
            }
          } else {
            _taskCountChart = 0.01;
            _taskCount = '00';
          }
//          setState(() {});
        } catch (es) {
          showErrorLog(es.toString());
//          showCenterToast(errorApiCall);
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

  Future apiCallForGetMeetingWithLoader() async {
    final SharedPreferences prefs = await _prefs;
    if (prefs.getBool(SP_IS_LOGIN_BOOL) != null) {
      _userId = prefs.getInt(SP_ID)!;
      _apiToken = prefs.getString(SP_API_TOKEN)!;
    }
    var map = new Map<String, dynamic>();
    map["appType"] = Platform.operatingSystem.toUpperCase();
    map["userId"] = _userId.toString();
    map["api_token"] = _apiToken;
    map['meetingDate'] = new DateFormat('yyyy-MM-dd').format(DateTime.now());
    try {
      _noDataFound = 'Loading...';
      _meetingListApiCallBack = null;
      showLoader(context);
      _networkUtil.post(apiMeetingList, body: map).then((dynamic res) {
        _noDataFound = noDataFound;
        Navigator.pop(context);
        try {
          AppLog.showLog(res.toString());
          _meetingListApiCallBack = MeetingListApiCallBack.fromJson(res);
          if (_meetingListApiCallBack!.status == unAuthorised) {
            logout();
          } else if (_meetingListApiCallBack!.success) {
            _taskCount = _meetingListApiCallBack!.items.length
                .toString()
                .padLeft(2, '0');
            if (_meetingListApiCallBack!.items.length < 10) {
              _taskCountChart = (_meetingListApiCallBack!.items.length / 10);
            } else {
              _taskCountChart = (_meetingListApiCallBack!.items.length / 20);
            }
          } else {
            _taskCountChart = 0.01;
            _taskCount = '00';
          }
//          _serverTime = _meetingListApiCallBack.current_time;
          setState(() {});
        } catch (es) {
          showErrorLog(es.toString());
          showCenterToast(errorApiCall);
        }
        setState(() {
          _buttonTapped();
        });
      });
    } catch (e) {
      showErrorLog(e.toString());
      showCenterToast(errorApiCall);
      _noDataFound = noDataFound;
      setState(() {});
    }
  }

  /// location upload api call-------------
  void _uploadAttendanceLocationApiCall(String _attendanceType) async {
    geo.Position position = await geo.Geolocator.getCurrentPosition(
        desiredAccuracy: geo.LocationAccuracy.high);
    setState(() {});
    // geo.Position _CurrentLocation = await geo.Geolocator.getCurrentPosition();
    // showBottomToast('Enter in upload');
    var map = new Map<String, dynamic>();
    final SharedPreferences prefs = await _prefs;
    if (prefs.getBool(SP_IS_LOGIN_BOOL) != null) {
      _userId = prefs.getInt(SP_ID)!;
      _apiToken = prefs.getString(SP_API_TOKEN)!;
    }
    map["api_token"] = _apiToken;
    map["appType"] = Platform.operatingSystem.toUpperCase();
    map["userId"] = '$_userId';
    map["date"] = DateFormat('yyyy-MM-dd').format(DateTime.now().toUtc());
    map["deviceId"] = _deviceId;
    // if (_startLocation != null) {
    //   map['longitude'] = '${_startLocation.longitude}';
    //   map['latitude'] = '${_startLocation.latitude}';
    //   print("Start");
    // } else {
    //   map['longitude'] = '${_CurrentLocation.longitude}';
    //   map['latitude'] = '${_CurrentLocation.latitude}';
    //   print("Current");
    // }
    //new sahil changes
    map['longitude'] = '${position.longitude}';
    map['latitude'] = '${position.latitude}';
    // print("Current");

    // map["longitude"] = "${_startLocation.longitude}";
    // map["latitude"] = "${_startLocation.latitude}";
    map["deviceDate"] =
        DateFormat('yyyy-MM-dd HH:mm:ss').format(DateTime.now().toUtc());
    map["locationAccuracy"] = _attendanceType;
    map["serverId"] = "0";
    map["id"] = "1";
    print(map);
    //showBottomToast('Error in location api call params');
    try {
      _networkUtil.post(apiTrackingAddNew, body: map).then((dynamic res) {
        try {
          AppLog.showLog(res.toString());
          // GeoTrackingAddApiCallBack _apiCallBack =
          //     GeoTrackingAddApiCallBack.fromJson(res);
          //showBottomToast('Location api success');

//          if (_apiCallBack.serverId>0) {
////            saveStartSPData(_startAttendanceApiCallBack.items);
//          } else {
////            showBottomToast(_startAttendanceApiCallBack!.message);
//          }
        } catch (se) {
          // showCenterToast(errorApiCall);
          //showBottomToast('Error in location api call params se');
        }
      });
    } catch (e) {
      showErrorLog(e.toString());
      // showCenterToast(errorApiCall);
      // showBottomToast('Error in location api call params e');
    }
  }

//   void _uploadAttendanceLocationApiCall(
//       String _attendanceType, double lat, double long) async {
//     setState(() {
//       isDisabled = true;
//     });
//     // geo.Position _CurrentLocation = await geo.Geolocator.getCurrentPosition();
//     // showBottomToast('Enter in upload');
//     var map = new Map<String, dynamic>();
//     final SharedPreferences prefs = await _prefs;
//     if (prefs.getBool(SP_IS_LOGIN_BOOL) != null) {
//       _userId = prefs.getInt(SP_ID)!;
//       _apiToken = prefs.getString(SP_API_TOKEN)!;
//     }
//     map["api_token"] = _apiToken;
//     map["appType"] = Platform.operatingSystem.toUpperCase();
//     map["userId"] = '$_userId';
//     map["date"] = DateFormat('yyyy-MM-dd').format(DateTime.now().toUtc());
//     map["deviceId"] = _deviceId;
//     //sahil changes
//     // if (position != null) {
//     map['longitude'] = '${lat}';
//     map['latitude'] = '${long}';
//     print("Current");
//     // } else {
//     //   map['longitude'] = '${_startLocation.longitude}';
//     //   map['latitude'] = '${_startLocation.latitude}';
//     //   print("Start");
//     // }

//     // if (_startLocation != null) {
//     //   map['longitude'] = '${_startLocation.longitude}';
//     //   map['latitude'] = '${_startLocation.latitude}';
//     //   print("Start");
//     // } else {
//     //   map['longitude'] = '${_CurrentLocation.longitude}';
//     //   map['latitude'] = '${_CurrentLocation.latitude}';
//     //   print("Current");
//     // }
//     // map["longitude"] = "${_startLocation.longitude}";
//     // map["latitude"] = "${_startLocation.latitude}";
//     map["deviceDate"] =
//         DateFormat('yyyy-MM-dd HH:mm:ss').format(DateTime.now().toUtc());
//     map["locationAccuracy"] = _attendanceType;
//     map["serverId"] = "0";
//     map["id"] = "1";
//     print("parameter -----> $map");
//     //showBottomToast('Error in location api call params');
//     try {
//       _networkUtil.post(apiTrackingAddNew, body: map).then((dynamic res) {
//         try {
//           AppLog.showLog(res.toString());
//           GeoTrackingAddApiCallBack _apiCallBack =
//               GeoTrackingAddApiCallBack.fromJson(res);
//           setState(() {
//             isDisabled = false;
//           });
//           //showBottomToast('Location api success');

// //          if (_apiCallBack.serverId>0) {
// ////            saveStartSPData(_startAttendanceApiCallBack.items);
// //          } else {
// ////            showBottomToast(_startAttendanceApiCallBack!.message);
// //          }
//         } catch (se) {
//           setState(() {
//             isDisabled = false;
//           });
//           // showCenterToast(errorApiCall);
//           //showBottomToast('Error in location api call params se');
//         }
//       });
//     } catch (e) {
//       setState(() {
//         isDisabled = false;
//       });
//       showErrorLog(e.toString());
//       // showCenterToast(errorApiCall);
//       // showBottomToast('Error in location api call params e');
//     }
//   }

  void _uploadAttendanceLocationApiCallNew(String _attendanceType) async {
    geo.Position _CurrentLocation = await geo.Geolocator.getCurrentPosition();
    // showBottomToast('Enter in upload');
    var map = new Map<String, dynamic>();
    final SharedPreferences prefs = await _prefs;
    if (prefs.getBool(SP_IS_LOGIN_BOOL) != null) {
      _userId = prefs.getInt(SP_ID)!;
      _apiToken = prefs.getString(SP_API_TOKEN)!;
    }
    map["api_token"] = _apiToken;
    map["appType"] = Platform.operatingSystem.toUpperCase();
    map["userId"] = '$_userId';
    map["date"] = DateFormat('yyyy-MM-dd').format(DateTime.now().toUtc());
    map["deviceId"] = _deviceId;
    map['longitude'] = '${_startLocation.longitude}';
    map['latitude'] = '${_startLocation.latitude}';
    //print("Start");

    // map["longitude"] = "${_startLocation.longitude}";
    // map["latitude"] = "${_startLocation.latitude}";
    map["deviceDate"] =
        DateFormat('yyyy-MM-dd HH:mm:ss').format(DateTime.now().toUtc());
    map["locationAccuracy"] = _attendanceType;
    map["serverId"] = "0";
    map["id"] = "1";
    print(map);
    //showBottomToast('Error in location api call params');
    try {
      _networkUtil.post(apiTrackingAdd, body: map).then((dynamic res) {
        try {
          AppLog.showLog(res.toString());
          LocationTracking _locationTracking = LocationTracking.fromJson(res);
          // GeoTrackingAddApiCallBack _apiCallBack =
          //     GeoTrackingAddApiCallBack.fromJson(res);
          //showBottomToast('Location api success');

//          if (_apiCallBack.serverId>0) {
////            saveStartSPData(_startAttendanceApiCallBack.items);
//          } else {
////            showBottomToast(_startAttendanceApiCallBack!.message);
//          }
        } catch (se) {
          // showCenterToast(errorApiCall);
          //showBottomToast('Error in location api call params se');
        }
      });
    } catch (e) {
      showErrorLog(e.toString());
      // showCenterToast(errorApiCall);
      // showBottomToast('Error in location api call params e');
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

  Color hexToColor(String code) {
    return new Color(int.parse(code.substring(1, 7), radix: 16) + 0xFF000000);
  }

  /// api for time check.....................
  Future apiCall(var connectivityResult) async {
    String _projectVersion = '1';
    String _projectCode = '1';
    // var connectivityResult = await (Connectivity().checkConnectivity());
    // if (connectivityResult == ConnectivityResult.mobile ||
    //     connectivityResult == ConnectivityResult.wifi) {
    // var connectivityResult = await (Connectivity().checkConnectivity());
    var connectivityResult1 = await (Connectivity().checkConnectivity());
    if (connectivityResult1 == ConnectivityResult.mobile) {
// I am connected to a mobile network. }
    } else if (connectivityResult1 == ConnectivityResult.wifi) {
// I am connected to a wifi network.
    }

    if (connectivityResult1 != ConnectivityResult.none) {
      var map = new Map<String, dynamic>();
      map["appType"] =
          (Platform.operatingSystem.toUpperCase() == 'ANDROID') ? '0' : '1';
      map["appVersionName"] = _projectVersion;
      map["appVersionCode"] = _projectCode;
      map["updatePriority"] = '1';
      print(map);
      try {
        showLoader(context);
        _networkUtil.post(getAppVersion, body: map).then((dynamic res) {
          Navigator.pop(context);
          try {
            AppLog.showLog(res.toString());
            AppUpdateApiCallBack _appUpdateApiCallBack =
                AppUpdateApiCallBack.fromJson(res);
            if (_appUpdateApiCallBack.status == unAuthorised) {
              logout();
            } else if (_appUpdateApiCallBack.success) {
              var dDayUtc = new DateTime.utc(
                DateTime.parse(
                        _appUpdateApiCallBack.current_utc_time.toString())
                    .year,
                DateTime.parse(
                        _appUpdateApiCallBack.current_utc_time.toString())
                    .month,
                DateTime.parse(
                        _appUpdateApiCallBack.current_utc_time.toString())
                    .day,
                DateTime.parse(
                        _appUpdateApiCallBack.current_utc_time.toString())
                    .hour,
                DateTime.parse(
                        _appUpdateApiCallBack.current_utc_time.toString())
                    .minute,
                DateTime.parse(
                        _appUpdateApiCallBack.current_utc_time.toString())
                    .second,
              );
              var dDayLocal = dDayUtc.toLocal();

              int timeDifference =
                  dDayLocal.difference(DateTime.now().toUtc()).inMinutes;
              timeDifference =
                  (timeDifference < 0) ? (-1 * timeDifference) : timeDifference;
              //print(timeDifference.toString());
              if (timeDifference > bufferTime) {
                showDialog(
                    context: context,
                    barrierDismissible: false,
                    builder: (BuildContext context) {
                      return StatefulBuilder(builder: (context, setState) {
                        return AlertDialog(
                          contentPadding: const EdgeInsets.all(0),
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.all(
                                  Radius.circular(ScreenUtil().setSp(10)))),
                          content: Column(
                            mainAxisSize: MainAxisSize.min,
                            crossAxisAlignment: CrossAxisAlignment.stretch,
                            children: <Widget>[
                              Container(
                                  decoration: new BoxDecoration(
                                      color: global.appPrimaryColor,
                                      borderRadius: const BorderRadius.only(
                                          topLeft: const Radius.circular(10),
                                          topRight: const Radius.circular(10))),
                                  padding: const EdgeInsets.all(15),
                                  child: Row(
                                    children: <Widget>[
                                      Text(
                                        'Time Incorrect',
                                        textAlign: TextAlign.center,
                                        style: TextStyle(
                                            fontSize: ScreenUtil().setSp(16),
                                            fontWeight: FontWeight.bold,
                                            color: appWhiteColor),
                                      ),
                                      Expanded(
                                        child: Container(),
                                      ),
                                    ],
                                  )),
                              const SizedBox(
                                height: 5.0,
                              ),
                              Padding(
                                padding: const EdgeInsets.only(
                                    left: 16.0, right: 16.0),
                                child: Row(
                                  children: <Widget>[
                                    Flexible(
                                      flex: 2,
                                      child: Text(
                                          'Device date time is incorrect. Please correct it. Current date time is ${_appUpdateApiCallBack.current_time}',
                                          style: const TextStyle(
                                            fontSize: 15.0,
                                            fontWeight: FontWeight.bold,
                                          )),
                                    ),
                                  ],
                                ),
                              ),
                              const SizedBox(
                                height: 10.0,
                              ),
                              Padding(
                                padding: const EdgeInsets.only(
                                    left: 50.0, right: 50.0),
                                child: Card(
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(20.0),
                                  ),
                                  color: appColorRedIcon,
                                  child: GestureDetector(
                                    child: const Center(
                                      child: Padding(
                                        padding: EdgeInsets.all(8.0),
                                        child: Center(
                                          child: Text('Ok',
                                              style: TextStyle(
                                                color: Colors.white,
                                                fontSize: 15.0,
                                                fontWeight: FontWeight.bold,
                                              )),
                                        ),
                                      ),
                                    ),
                                    onTap: () async {
                                      Navigator.pop(context);
                                      exit(0);
                                    },
                                  ),
                                ),
                              ),
                              const SizedBox(
                                height: 15.0,
                              ),
                            ],
                          ),
                        );
                      });
                    }).then((val) {
                  setState(() {});
                });
              } else {
                _buttonTapped();
              }
            }
          } catch (es) {
            showErrorLog(es.toString());
            showCenterToast(errorApiCall);
          }
          setState(() {});
        });
      } catch (e) {
        Navigator.pop(context);
        showErrorLog(e.toString());
        showCenterToast(errorApiCall);
      }
    } else {
      //print('G1--->');
      showCenterToast('No Internet');
    }
  }

  void initProjectVersion() async {
    String projectVersion;
    String projectCode;
    String projectAppID;
    String projectName;

    //Change by G1...
    PackageInfo.fromPlatform().then((PackageInfo packageInfo) {
      projectVersion = packageInfo.version;
      projectCode = packageInfo.buildNumber;
      projectName = packageInfo.appName;
      projectAppID = packageInfo.packageName;
      //print("version--->" + packageInfo.version);
    });
  }

  loadTaskManager() {
    if (_task_manager == 1) {
      return Card(
        shape:
            RoundedRectangleBorder(borderRadius: BorderRadius.circular(20.0)),
        margin: const EdgeInsets.only(
            left: 20.0, right: 20.0, top: 10.0, bottom: 10),
        child: Container(
          width: 305,
          child: Column(
            children: <Widget>[
              Padding(
                padding:
                    const EdgeInsets.only(left: 20.0, top: 10.0, right: 10),
                child: Row(
                  children: <Widget>[
                    // Icon(
                    //   Icons.playlist_add_check,
                    //   color: appColorRedIcon,
                    //   size: 23.0,
                    // ),
                    // SizedBox(
                    //   width: 5.0,
                    // ),
                    Text(
                      'Task',
                      style:
                          TextStyle(color: global.colorText, fontFamily: font),
                    ),
                    Expanded(
                      child: Container(),
                    ),
                    Center(
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: global.btnBgColor,
                          padding: EdgeInsets.only(
                              left: ScreenUtil().setSp(5),
                              right: ScreenUtil().setSp(5),
                              top: ScreenUtil().setSp(1),
                              bottom: ScreenUtil().setSp(1)),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(25.0),
                          ),
                        ),
                        child: const Text('Add',
                            style: TextStyle(
                                color: Colors.white, fontFamily: font)),
                        onPressed: () {
                          _buttonAddTaskTapped();
                        },
                      ),
                    ),
                    const SizedBox(
                      width: 5.0,
                    ),
                  ],
                ),
              ),

              // Padding(
              //   padding:
              //       const EdgeInsets.only(left: 20.0, top: 10.0, bottom: 15.0),
              //   child: Align(
              //     alignment: Alignment.centerLeft,
              //     child: Row(
              //       children: <Widget>[
              //         Container(
              //           height: 3.0,
              //           width: 30.0,
              //           color: global.appPrimaryColor,
              //         ),
              //         Container(
              //           height: 1.0,
              //           width: 70.0,
              //           color: global.appPrimaryColor,
              //         ),
              //       ],
              //     ),
              //   ),
              // ),
              (_taskList?.data!.isNotEmpty ?? false)
                  ? buildList()
                  : Center(
                      child: Text(
                        "", //_noDataFound,
                        style: TextStyle(
                            fontSize: 15.0,
                            fontFamily: font,
                            color: global.colorText),
                      ),
                    ),
              const SizedBox(
                height: 0,
              ),
              (_taskList != null)
                  ? Container(
                      height: 50,
                      margin: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                          color: global.appPrimaryColor,
                          borderRadius:
                              const BorderRadius.all(Radius.circular(25))),
                      child: Row(
                        children: <Widget>[
                          Expanded(
                            child: Container(
                              margin: const EdgeInsets.only(left: 15.0),
                              child: Text(
                                (_taskList != null)
                                    ? 'Total Task Minutes : ${_taskList!.totalCount ?? 0}'
                                    : '',
                                style: const TextStyle(
                                    fontSize: 15.0,
                                    fontFamily: font,
                                    color: appWhiteColor),
                              ),
                            ),
                          ),
                          GestureDetector(
                            child: Container(
                              margin: const EdgeInsets.only(right: 5.0),
                              height: 40,
                              decoration: const BoxDecoration(
                                  color: appWhiteColor,
                                  borderRadius:
                                      BorderRadius.all(Radius.circular(25))),
                              child: Padding(
                                padding:
                                    const EdgeInsets.only(left: 15, right: 15),
                                child: Align(
                                  alignment: Alignment.center,
                                  child: Text(
                                    'Show All Task',
                                    style: TextStyle(
                                        fontFamily: font,
                                        color: global.appPrimaryColor),
                                  ),
                                ),
                              ),
                            ),
                            onTap: () {
                              _buttonShowAllTaskTapped();
                            },
                          ),
                        ],
                      ),
                    )
                  : Container()
            ],
          ),
        ),
      );
    } else {
      return Container();
    }
  }

  Future _buttonShowAllTaskTapped() async {
    Map results = await Navigator.of(context).push(new MaterialPageRoute(
      builder: (BuildContext context) {
        return Tasks(
          scaffoldKey: widget.scaffoldKey,
          title: 'View Task',
        );
      },
    ));
    if (results.containsKey('reload')) {
      //print("sahil refresh--->${_taskList.taskCount}");
      initApiCall();
    }
  }

  Future _buttonAddTaskTapped() async {
    Map results = await Navigator.of(context).push(new MaterialPageRoute(
      builder: (BuildContext context) {
        return AddTask(
          scaffoldKey: widget.scaffoldKey,
          title: 'Add Task',
        );
      },
    ));
    if (results.containsKey('reload')) {
      initApiCall();
    }
  }

  Widget buildList() {
    //print(_taskList.data[0].percentage);
    var percentage = _taskList!.data![0].percentage ?? 0.01;
    percentage = (percentage > 100) ? 100 : percentage;
    return Padding(
      padding: const EdgeInsets.only(left: 8, right: 8, bottom: 18, top: 8),
      child: Card(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8.0)),
        elevation: 5,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: <Widget>[
                Visibility(
                    child: (_taskList!.data![0].isNew == 1)
                        ? Container(
                            decoration: const BoxDecoration(
                                color: Colors.green,
                                borderRadius: BorderRadius.only(
                                    topLeft: Radius.circular(8))),
                            padding: const EdgeInsets.only(
                                top: 2, bottom: 2, left: 10, right: 10),
                            child: const Text(
                              'New',
                              style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 8.0,
                                  fontFamily: font),
                            ))
                        : const Visibility(
                            visible: false,
                            child: Text(''),
                          )),
                Container(
                  child: (_taskList!.data![0].isApproved == 0)
                      ? Container(
                          decoration: const BoxDecoration(
                              color: Colors.red,
                              borderRadius: BorderRadius.only(
                                  topRight: Radius.circular(8))),
                          padding: const EdgeInsets.all(3),
                          child: const Text(
                            'Non-approved',
                            style: TextStyle(
                                color: Colors.white,
                                fontSize: 8.0,
                                fontFamily: font),
                          ),
                        )
                      : (_taskList!.data![0].isApproved == 1)
                          ? Container(
                              decoration: const BoxDecoration(
                                  color: Colors.green,
                                  borderRadius: BorderRadius.only(
                                      topRight: Radius.circular(8))),
                              padding: const EdgeInsets.all(2),
                              child: const Text(
                                'Approved',
                                style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 8.0,
                                    fontFamily: font),
                              ),
                            )
                          : Container(
                              decoration: const BoxDecoration(
                                  color: Colors.red,
                                  borderRadius: BorderRadius.only(
                                      topRight: Radius.circular(8))),
                              padding: const EdgeInsets.all(2),
                              child: const Text(
                                'Rejected',
                                style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 8.0,
                                    fontFamily: font),
                              ),
                            ),
                ),
              ],
            ),
            const SizedBox(
              height: 8,
            ),
            Row(
              children: <Widget>[
                Expanded(
                  child: Row(
                    children: <Widget>[
                      const SizedBox(
                        width: 15,
                      ),
                      // Icon(
                      //   Icons.folder_shared,
                      //   color: Colors.deepOrange,
                      //   size: 15,
                      // ),
                      Image.asset(
                        'assets/image/client.png',
                        width: 15,
                        height: 15,
                        fit: BoxFit.fill,
                        color: global.appDarkPrimaryColor,
                      ),
                      const SizedBox(
                        width: 5,
                      ),
                      Flexible(
                        child: Text(
                          ' ${_taskList!.data![0].clientName}',
                          style: TextStyle(
                              fontSize: 14.0,
                              color: global.colorText,
                              fontFamily: font),
                          maxLines: 2,
                        ),
                      )
                    ],
                  ),
                ),
                Expanded(
                  child: Row(
                    children: <Widget>[
                      const SizedBox(
                        width: 5,
                      ),
                      // Icon(
                      //   Icons.people,
                      //   color: Colors.deepOrange,
                      //   size: 15,
                      // ),
                      Image.asset(
                        'assets/image/client_name.png',
                        width: 15,
                        height: 15,
                        fit: BoxFit.fill,
                        color: global.appDarkPrimaryColor,
                      ),
                      const SizedBox(
                        width: 5,
                      ),
                      Flexible(
                        child: Text(
                          ' ${_taskList!.data![0].projectName}',
                          style: TextStyle(
                              fontSize: 14.0,
                              color: global.colorText,
                              fontFamily: font),
                          maxLines: 2,
                        ),
                      )
                    ],
                  ),
                ),
                const SizedBox(
                  width: 8,
                ),
              ],
            ),
            Padding(
              padding: const EdgeInsets.only(left: 15, right: 15, top: 8),
              child: Text(
                _taskList!.data![0].task ?? "",
                style: TextStyle(
                    fontSize: 14.0, color: global.colorText, fontFamily: font),
                maxLines: null,
              ),
            ),
            Padding(
              padding: const EdgeInsets.only(left: 15, right: 15, top: 8),
              child: Row(
                children: <Widget>[
                  Expanded(
                    flex: 2,
                    child: Row(
                      children: <Widget>[
                        // Icon(
                        //   Icons.access_time,
                        //   color: Colors.deepOrange,
                        //   size: 15,
                        // ),
                        Image.asset(
                          'assets/image/time.png',
                          width: 15,
                          height: 15,
                          fit: BoxFit.fill,
                          color: global.appDarkPrimaryColor,
                        ),
                        const SizedBox(
                          width: 5,
                        ),
                        Text(
                          '  ${_taskList!.data![0].minutes}:00',
                          style:
                              const TextStyle(fontSize: 14.0, fontFamily: font),
                        ),
                      ],
                    ),
                  ),
                  Expanded(
                      flex: 3,
                      child: getProgressBar('$percentage %', percentage))
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.only(left: 8, right: 8, top: 8),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: <Widget>[
                  Text(
                    DateFormat('hh:mm a').format(
                        DateFormat("yyyy-MM-dd HH:mm:ss")
                            .parse(_taskList!.data![0].createdAt ?? "", true)
                            .toLocal()),
                    style: dateTimeTextStyle,
                  ),
                  const SizedBox(
                    width: 15,
                  ),
                  //Text(_taskList.data[0].createdAt),
                  //Text(DateFormat('hh:mm a')
                  //   .format(DateTime.parse(_taskList.data[0].created_at))),
                ],
              ),
            ),
            const SizedBox(
              height: 8,
            ),
          ],
        ),
      ),
    );
  }

  void getTaskList() async {
    try {
      final SharedPreferences prefs = await _prefs;
      if (prefs.getBool(SP_IS_LOGIN_BOOL) != null) {
        _userId = prefs.getInt(SP_ID)!;
        _apiToken = prefs.getString(SP_API_TOKEN)!;
      }
      var map = new Map<String, dynamic>();
      map["appType"] = Platform.operatingSystem.toUpperCase();
      map["userId"] = _userId.toString();
      map["api_token"] = _apiToken;
      map['taskDate'] = DateFormat('yyyy/MM/dd').format(DateTime.now());
      print(map);

      _networkUtil.post(apiGetTaskList, body: map).then((dynamic res) {
        try {
          String message = res["message"];
          if (message.toLowerCase() == "No Data Found".toLowerCase()) {
            // print('G1--->task remove 05');
            _taskList = null;
            _taskCount = '0/0';
            _taskCountChart = 0.01;
            setState(() {});
          } else {
            _taskList = TaskListApiCallBack.fromJson(res);
            _taskCount =
                '${_taskList!.taskApprovedCount} / ${_taskList!.taskCount}';
            // _taskCountChart =
            //     ((_taskList.taskApprovedCount / _taskList.taskCount) > 0)
            //         ? (_taskList.taskApprovedCount / _taskList.taskCount)
            //         : 0.01;
//added by shital
            _taskCountChart =
                ((_taskList!.taskApprovedCount! / _taskList!.taskCount!) > 0)
                    ? (_taskList!.taskApprovedCount! / _taskList!.taskCount!)
                    : 0.01;
            _taskCountChart = _taskList!.taskCount! / 100;
            AppLog.showLog(res.toString());
            if (_taskList!.status == unAuthorised) {
              logout();
            } else if (_taskList!.success == true) {
              setState(() {});
            }
          }
        } catch (ex) {
//          showBottomToast('Something went wrong, Try later!');
          print(ex);
        }
      });
    } catch (e) {
      print(e.toString());
    }
  }

  loadDriverCard() {
    if (_driver_delivery == 1) {
      return Card(
        shape:
            RoundedRectangleBorder(borderRadius: BorderRadius.circular(20.0)),
        margin:
            const EdgeInsets.only(left: 20.0, right: 20, top: 10, bottom: 10),
        child: Container(
          width: 305,
          child: Column(
            children: <Widget>[
              Padding(
                padding: const EdgeInsets.all(20),
                child: Row(
                  children: <Widget>[
                    // Icon(
                    //   Icons.folder,
                    //   color: appColorRedIcon,
                    //   size: 23.0,
                    // ),
                    // SizedBox(
                    //   width: 5,
                    // ),
                    Text(
                      'Package List',
                      style:
                          TextStyle(color: global.colorText, fontFamily: font),
                    ),
                    Expanded(
                      child: Container(),
                    ),
                    (_driverPackageApiCallBack!.items.length > 0 &&
                            _driverPackageApiCallBack!.items[0].date == today)
                        ? Center(
                            child: _status(
                                _driverPackageApiCallBack!.items[0].status),
                          )
                        : const Center(
                            child: Text(''),
                          )
                  ],
                ),
              ),
              // Padding(
              //   padding:
              //       const EdgeInsets.only(left: 20.0, top: 10.0, bottom: 15.0),
              //   child: Align(
              //     alignment: Alignment.centerLeft,
              //     child: Row(
              //       children: <Widget>[
              //         Container(
              //           height: 3.0,
              //           width: 30.0,
              //           color: global.appPrimaryColor,
              //         ),
              //         Container(
              //           height: 1.0,
              //           width: 70.0,
              //           color: global.appPrimaryColor,
              //         ),
              //       ],
              //     ),
              //   ),
              // ),
              (_driverPackageApiCallBack!.items.length > 0 &&
                      _driverPackageApiCallBack!.items[0].date == today)
                  ? buildDriverListView()
                  : global.noRecordFound(_noDataFound),
            ],
          ),
        ),
      );
    } else {
      return Container();
    }
  }

  Widget buildDriverListView() {
    return Column(
      children: <Widget>[
        Padding(
          padding: const EdgeInsets.only(
            left: 20.0,
            top: 10,
            right: 20.0,
          ),
          child: Row(
            children: <Widget>[
              const Icon(
                Icons.business_center,
                color: appColorRedIcon,
                size: 16.0,
              ),
              const SizedBox(
                width: 5,
              ),
              Text(_driverPackageApiCallBack!.items[0].received,
                  style: const TextStyle(fontWeight: FontWeight.bold)),
              const SizedBox(
                width: 5,
              ),
              const Text('Received')
            ],
          ),
        ),
        Padding(
          padding: const EdgeInsets.only(
            left: 20.0,
            top: 10,
            right: 20.0,
          ),
          child: Row(
            children: <Widget>[
              const Icon(
                Icons.assignment_turned_in,
                color: appColorRedIcon,
                size: 16.0,
              ),
              const SizedBox(
                width: 5,
              ),
              Text(_driverPackageApiCallBack!.items[0].delivered,
                  style: const TextStyle(fontWeight: FontWeight.bold)),
              const SizedBox(
                width: 5,
              ),
              const Text('Delivered')
            ],
          ),
        ),
        Padding(
          padding: const EdgeInsets.only(
              left: 20.0, top: 10, right: 20.0, bottom: 20),
          child: Row(
            children: <Widget>[
              const Icon(
                Icons.attach_money,
                color: appColorRedIcon,
                size: 16.0,
              ),
              const SizedBox(
                width: 5,
              ),
              Text(
                _driverPackageApiCallBack!.items[0].cashOnDelivery ?? '0.0',
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
              const SizedBox(
                width: 5,
              ),
              const Text('Cash Collection')
            ],
          ),
        )
      ],
    );
  }

  Widget _status(int status) {
    switch (status) {
      case 0:
        return Text(
          'Pending',
          style: TextStyle(color: global.appPrimaryColor),
        );
      case 1:
        return Text(
          'Approved',
          style: TextStyle(color: global.appAccentColor),
        );
      case 2:
        return Text(
          'Rejected',
          style: TextStyle(color: global.chartRed),
        );
      default:
        return const Text(
          'Unknown',
          style: TextStyle(color: Colors.grey),
        );
    }
  }

  Future apiCallForPackageList() async {
    final SharedPreferences prefs = await _prefs;
    if (prefs.getBool(SP_IS_LOGIN_BOOL) != null) {
      _userId = prefs.getInt(SP_ID)!;
      _apiToken = prefs.getString(SP_API_TOKEN)!;
    }
    var map = new Map<String, dynamic>();
    map["appType"] = Platform.operatingSystem.toUpperCase();
    map["user_id"] = _userId.toString();
    map["api_token"] = _apiToken;
    print(map);
    try {
      _noDataFound = 'Loading...';
      _networkUtil.post(apiGetDeliveryList, body: map).then((dynamic res) {
        _noDataFound = noDataFound;
        try {
          AppLog.showLog(res.toString());
          _driverPackageApiCallBack = DriverPackageApiCallBack.fromJson(res);
          if (_driverPackageApiCallBack!.status == unAuthorised) {
            logout();
          }
          if (_driverPackageApiCallBack!.success) {
            //showBottomToast(_driverPackageApiCallBack!.message);
          } else {
//            showBottomToast(_driverPackageApiCallBack!.message);
          }
        } catch (es) {
          showErrorLog(es.toString());
          showCenterToast(errorApiCall);
        }

        setState(() {});
      });
    } catch (e) {
      showErrorLog(e.toString());
      _noDataFound = noDataFound;
      setState(() {});
    }
  }

  Future _vehicleSelect() async {
    Map results = await Navigator.of(context).push(new MaterialPageRoute(
        builder: (BuildContext context) => new Vehicle(
            scaffoldKey: widget.scaffoldKey,
            title: 'Vehicle Details',
            companyName: _company)));

    if (results.containsKey('reload')) {
      setState(() {
        if (results['reload']) {
          startAttendanceDialog();
        }
      });
    } else {
      setState(() {});
    }
  }

  Future _updatePackageList() async {
    Map results = await Navigator.of(context).push(new MaterialPageRoute(
      builder: (BuildContext context) {
        return AddPackage(
          scaffoldKey: widget.scaffoldKey,
          title: 'Add Package',
        );
      },
    ));

    if (results.containsKey('reload')) {
      stopAttendanceDialog();
    } else {
      setState(() {});
    }
  }

  Widget birthdayCard() {
    return Card(
      elevation: 5,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20.0)),
      margin:
          const EdgeInsets.only(left: 20.0, right: 20.0, top: 10.0, bottom: 10),
      child: Container(
        padding: const EdgeInsets.all(20),
        child: //(_todaysBirthdayApiCallBack!.items.length > 0)
            (_todaysBirthdayApiCallBack?.items?.isNotEmpty ?? false)
                ? getBirthdayPageView()
                : Container(
                    child: Column(
                      children: <Widget>[
                        const SizedBox(
                          height: 01,
                        ),
                        // Icon(
                        //   CommunityMaterialIcons.cake,
                        //   color: global.appPrimaryColor,
                        //   size: 50,
                        // ),
                        Image.asset(
                          'assets/image/birthday.png',
                          width: 100,
                          height: 100,
                          fit: BoxFit.fill,
                        ),
                        const SizedBox(
                          height: 10,
                        ),
                        Text(
                          'No Birthday Today',
                          style: TextStyle(
                              color: global.colorText, fontFamily: font),
                        ),
                        const SizedBox(
                          height: 10,
                        ),
                        ElevatedButton(
                          style: ElevatedButton.styleFrom(
                              backgroundColor: global.appDarkPrimaryColor,
                              shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(20.0))),
                          child: const Text(
                            'View Birthday List',
                            style: TextStyle(
                                color: Colors.white, fontFamily: font),
                          ),
                          onPressed: () {
                            Navigator.of(context).push(new MaterialPageRoute(
                                builder: (BuildContext context) =>
                                    new BirthdayList(
                                        scaffoldKey: widget.scaffoldKey,
                                        title: 'Birthday List')));
                          },
                        ),
                      ],
                    ),
                  ),
      ),
    );
  }

  Widget getBirthdayPageView() {
    return ListView.builder(
      shrinkWrap: true,
      physics: const ClampingScrollPhysics(),
      itemBuilder: (BuildContext context, int index) {
        return Column(
          children: [
            Container(
              margin: const EdgeInsets.only(top: 5.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      Container(
                        height: 80,
                        width: 80,
                        decoration: new BoxDecoration(
                          borderRadius: new BorderRadius.circular(10),
                          image: DecorationImage(
                              image: global.bg_profile != null
                                  ? CachedNetworkImageProvider(
                                      global.bg_profile)
                                  : AssetImage(global.bg_profileDefault)
                                      as ImageProvider,
                              fit: BoxFit.fill),
                        ),
                        child: Container(
                          margin: const EdgeInsets.all(10),
                          height: 70,
                          width: 70,
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(35.0),
                            child: CachedNetworkImage(
                              imageUrl: _todaysBirthdayApiCallBack!
                                      .items![index].profileImage ??
                                  "",
                              placeholder: (context, url) => const Center(
                                  child: CircularProgressIndicator()),
                              errorWidget: (context, url, error) => Container(
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(15),
                                  image: const DecorationImage(
                                      image: AssetImage(
                                          'assets/image/default.png'),
                                      fit: BoxFit.cover),
                                ),
                              ),
                            ),
                            // FadeInImage.assetNetwork(
                            //   placeholder: 'assets/image/default.png',
                            //   image: _todaysBirthdayApiCallBack
                            //       .items[index].profileImage,
                            // ),
                          ),
                        ),
                      ),
                      Container(
                        margin: const EdgeInsets.only(left: 15),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text('Happy birthday',
                                style: TextStyle(
                                    fontSize: ScreenUtil().setSp(18),
                                    color: global.appPrimaryColor,
                                    fontWeight: FontWeight.normal,
                                    fontFamily: font)),
                            const SizedBox(
                              height: 8,
                            ),
                            Text(
                                "${_todaysBirthdayApiCallBack!.items![index].firstName.toString() ?? ''} ${_todaysBirthdayApiCallBack!.items![index].lastName ?? ''}",
                                style: TextStyle(
                                    fontSize: ScreenUtil().setSp(15),
                                    fontWeight: FontWeight.normal,
                                    color: global.colorText,
                                    fontFamily: font)),
                          ],
                        ),
                      ),
                    ],
                  ),
                  Row(
                    children: <Widget>[
                      Expanded(
                        child: Row(
                          children: <Widget>[
                            const SizedBox(
                              width: 15,
                            ),
                            Icon(
                              Icons.calendar_today,
                              color: global.appPrimaryColor,
                              size: 15,
                            ),
                            const SizedBox(
                              width: 10,
                            ),
                            Text(
                                DateFormat('yyyy-MM-dd').format(
                                  DateTime.parse(_todaysBirthdayApiCallBack!
                                          .items![index].birthDate ??
                                      ""),
                                ),
                                style: TextStyle(
                                    color: global.colorText, fontFamily: font)),
                            const Expanded(child: Text("")),
                            ElevatedButton(
                                onPressed: () => launch(
                                    "tel://${_todaysBirthdayApiCallBack!.items![index].contactNo}"),
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: global.btnBgColor,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(25.0),
                                  ),
                                ),
                                child: Row(
                                  children: [
                                    const Icon(
                                      Icons.call,
                                      color: appWhiteColor,
                                      size: 15,
                                    ),
                                    const SizedBox(
                                      width: 10,
                                    ),
                                    new Text(
                                      _todaysBirthdayApiCallBack!
                                              .items![index].contactNo ??
                                          "",
                                      style: const TextStyle(
                                          fontFamily: font,
                                          // decoration: TextDecoration.underline,
                                          color: appWhiteColor),
                                    ),
                                  ],
                                )),
                          ],
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            _todaysBirthdayApiCallBack!.items!.length > 1
                ? Container(
                    margin: const EdgeInsets.only(top: 10, bottom: 5),
                    height: 1,
                    color: global.appBottomNavColor,
                  )
                : Container()
          ],
        );
      },
      itemCount: _todaysBirthdayApiCallBack!.items!.length,
    );
  }

  Future apiCallForBirthdayData() async {
    final SharedPreferences prefs = await _prefs;
    if (prefs.getBool(SP_IS_LOGIN_BOOL) != null) {
      _userId = prefs.getInt(SP_ID)!;
      _apiToken = prefs.getString(SP_API_TOKEN)!;
      _companyId = prefs.getInt(SP_COMPANY_ID)!;
    }
    var map = new Map<String, dynamic>();
    map["appType"] = Platform.operatingSystem.toUpperCase();
    map["userId"] = _userId.toString();
    map["api_token"] = _apiToken;
    map['companyId'] = _companyId.toString();
    print(map);
    //print(apiGetTodaysBirthday);
    try {
      _noDataFound = 'Loading...';
      _networkUtil.post(apiGetTodaysBirthday, body: map).then((dynamic res) {
        _noDataFound = noDataFound;
        try {
          AppLog.showLog(res.toString());
          _todaysBirthdayApiCallBack = TodaysBirthdayApiCallBack.fromJson(res);
          if (_todaysBirthdayApiCallBack!.status == unAuthorised) {
            logout();
          }
          if (_todaysBirthdayApiCallBack!.success) {
            //showBottomToast(_driverPackageApiCallBack!.message);
          } else {
//            showBottomToast(_todaysBirthdayApiCallBack!.message);
          }
        } catch (es) {
          showErrorLog(es.toString());
          //showCenterToast(errorApiCall);
        }
        setState(() {});
      });
    } catch (e) {
      showErrorLog(e.toString());
      _noDataFound = noDataFound;
      setState(() {});
    }
  }

  Widget loadMeeting() {
    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20.0)),
      margin:
          const EdgeInsets.only(left: 30.0, right: 30.0, top: 10.0, bottom: 10),
      child: Container(
        width: 305,
        child: Column(
          children: <Widget>[
            Padding(
              padding: const EdgeInsets.only(left: 20.0, top: 20.0),
              child: Row(
                children: <Widget>[
                  const Icon(
                    Icons.calendar_today,
                    color: appColorRedIcon,
                    size: 20.0,
                  ),
                  const SizedBox(
                    width: 5.0,
                  ),
                  Text(
                    'Meeting ',
                    style: TextStyle(color: global.appPrimaryColor),
                  ),
                ],
              ),
            ),
            Padding(
              padding:
                  const EdgeInsets.only(left: 20.0, top: 10.0, bottom: 15.0),
              child: Align(
                alignment: Alignment.centerLeft,
                child: Row(
                  children: <Widget>[
                    Container(
                      height: 3.0,
                      width: 30.0,
                      color: global.appPrimaryColor,
                    ),
                    Container(
                      height: 1.0,
                      width: 70.0,
                      color: global.appPrimaryColor,
                    ),
                  ],
                ),
              ),
            ),
            (_meetingListApiCallBack!.items.length > 0)
                ? ListView.builder(
                    shrinkWrap: true,
                    physics: const ClampingScrollPhysics(),
                    itemBuilder: (BuildContext context, int index) {
                      return Padding(
                        padding: EdgeInsets.only(
                            left: ScreenUtil().setSp(10),
                            right: ScreenUtil().setSp(10),
                            top: ScreenUtil().setSp(5),
                            bottom: ScreenUtil().setSp(5)),
                        child: GestureDetector(
                          child: Card(
                            shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(8.0)),
                            elevation: 5,
                            child: Column(
                              children: <Widget>[
                                Card(
                                  shape: const RoundedRectangleBorder(
                                    borderRadius: BorderRadius.only(
                                      topLeft: Radius.circular(8.0),
                                      topRight: Radius.circular(8.0),
                                    ),
                                  ),
                                  margin: const EdgeInsets.all(0.0),
                                  color: global.appPrimaryColor,
                                  child: Padding(
                                    padding:
                                        EdgeInsets.all(ScreenUtil().setSp(8)),
                                    child: Row(
                                      children: <Widget>[
                                        Flexible(
                                            flex: 3,
                                            fit: FlexFit.tight,
                                            child: Row(
                                              children: <Widget>[
                                                const Icon(
                                                  Icons.domain,
                                                  color: Colors.white,
                                                  size: 20.0,
                                                ),
                                                const SizedBox(
                                                  width: 5.0,
                                                ),
                                                Text(
                                                  _meetingListApiCallBack!
                                                      .items[index].clientName,
                                                  style: const TextStyle(
                                                      color: Colors.white),
                                                ),
                                              ],
                                            )),
                                        Container(
                                          width: 1,
                                          height: 30.0,
                                          color: Colors.grey[300],
                                        ),
                                        const SizedBox(
                                          width: 5.0,
                                        ),
                                        Flexible(
                                            flex: 3,
                                            fit: FlexFit.tight,
                                            child: Row(
                                              children: <Widget>[
                                                const Icon(
                                                  Icons.calendar_today,
                                                  color: Colors.white,
                                                  size: 20.0,
                                                ),
                                                const SizedBox(
                                                  width: 5.0,
                                                ),
                                                Text(
//                                                  DateFormat("yyyy/MM/dd", "en_US").parse("2012/01/01"),
                                                  '${DateTime.parse(_meetingListApiCallBack!.items[index].meetingDate).day.toString().padLeft(2, '0')}/'
                                                  '${DateTime.parse(_meetingListApiCallBack!.items[index].meetingDate).month.toString().padLeft(2, '0')}/'
                                                  '${DateTime.parse(_meetingListApiCallBack!.items[index].meetingDate).year.toString().padLeft(2, '0')}',
//                                                  _attendanceListApiCallBack
//                                                      .items[index].punchDate,
                                                  style: const TextStyle(
                                                      color: Colors.white),
                                                ),
                                              ],
                                            )),
                                      ],
                                    ),
                                  ),
                                ),
                                Padding(
                                  padding:
                                      EdgeInsets.all(ScreenUtil().setSp(8)),
                                  child: Container(
                                    width: double.infinity,
                                    child: Row(
                                      children: <Widget>[
                                        Flexible(
                                            flex: 3,
                                            fit: FlexFit.tight,
                                            child: Row(
                                              children: <Widget>[
                                                Text(
                                                  'Meeting Start \n'
                                                  '${DateTime.parse(_meetingListApiCallBack!.items[index].meetingStart).hour.toString().padLeft(2, '0')}:'
                                                  '${DateTime.parse(_meetingListApiCallBack!.items[index].meetingStart).minute.toString().padLeft(2, '0')}:'
                                                  '${DateTime.parse(_meetingListApiCallBack!.items[index].meetingStart).second.toString().padLeft(2, '0')}'
                                                  '',
//                                                  'In Time  Hours ',
                                                  style: TextStyle(
                                                      color: Colors.black,
                                                      fontSize: ScreenUtil()
                                                          .setSp(10)),
                                                ),
                                              ],
                                            )),
                                        Container(
                                          width: 1,
                                          height: 30.0,
                                          color: Colors.grey[300],
                                        ),
                                        const SizedBox(
                                          width: 5.0,
                                        ),
                                        Flexible(
                                            flex: 3,
                                            fit: FlexFit.tight,
                                            child: Row(
                                              children: <Widget>[
                                                Text(
                                                  'Meeting End \n'
                                                  '${DateTime.parse(_meetingListApiCallBack!.items[index].meetingEnd).hour.toString().padLeft(2, '0')}:'
                                                  '${DateTime.parse(_meetingListApiCallBack!.items[index].meetingEnd).minute.toString().padLeft(2, '0')}:'
                                                  '${DateTime.parse(_meetingListApiCallBack!.items[index].meetingEnd).second.toString().padLeft(2, '0')} ',
                                                  style: TextStyle(
                                                      color: Colors.black,
                                                      fontSize: ScreenUtil()
                                                          .setSp(10)),
                                                ),
                                              ],
                                            )),
                                      ],
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      );
                    },
                    itemCount: _meetingListApiCallBack!.items.length,
                  )
                : global.noRecordFound(_noDataFound),
          ],
        ),
      ),
    );
  }

  void initApiCall() async {
    final SharedPreferences prefs = await _prefs;
    _task_manager = prefs.getInt(TASK_MANAGER)!;
    _driver_delivery = prefs.getInt(SP_DRIVER)!;
    if (_task_manager == 1) {
      getTaskList();
    }
    if (_driver_delivery == 1) {
      apiCallForPackageList();
    }
    // apiCallForBirthdayData();
  }
}

// class ScanQrcodePage extends StatefulWidget {
//   const ScanQrcodePage({Key key}) : super(key: key);

//   @override
//   _ScanQrcodePageState createState() => _ScanQrcodePageState();
// }

// class _ScanQrcodePageState extends State<ScanQrcodePage> {
//   //Change by G1...
//   final GlobalKey<QrcodeReaderViewState> _key = GlobalKey();
//   final Completer<Widget> _qrcodeReaderViewcompleter = Completer<Widget>();

//   @override
//   void initState() {
//     super.initState();
//     WidgetsBinding.instance?.addPostFrameCallback((timeStamp) {
//       //Change by G1...
//       final _widget = QrcodeReaderView(
//         key: _key,
//         onScan: onScan,
//         hasImagePicker: false,
//         hasHintText: false,
//         hasLightSwitch: false,
//         headerWidget: AppBar(
//           backgroundColor: Colors.transparent,
//           elevation: 0.0,
//         ),
//       );

//       Future.delayed(const Duration(milliseconds: 280), () {
//         _qrcodeReaderViewcompleter.complete(_widget);
//         //Change by G1...
//         // _qrcodeReaderViewcompleter.complete();
//       });
//     });
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       body: FutureBuilder<Widget>(
//           future: _qrcodeReaderViewcompleter.future,
//           builder: (BuildContext context, AsyncSnapshot<Widget> snapshot) {
//             if (snapshot.hasData) {
//               return snapshot.data;
//             } else if (snapshot.hasError) {
//               return const Icon(Icons.error_outline);
//             } else {
//               return Container(
//                 color: Colors.black,
//                 child: const Center(
//                   child: CupertinoActivityIndicator(
//                     animating: true,
//                   ),
//                 ),
//               );
//             }
//           }),
//     );
//   }

//   Future onScan(String data) async {
//     // print('识别为: $data');
//     //Change by G1...
//     _key.currentState?.stopScan();

//     Navigator.pop(context, data);
//   }

//   @override
//   void dispose() {
//     super.dispose();
//   }
// }
