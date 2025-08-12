import 'dart:async';
import 'dart:io';
import 'package:device_info_plus/device_info_plus.dart';
import 'package:flutter/services.dart';
import 'package:connectivity_plus/connectivity_plus.dart';

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:hrms/appUtil/app_util_config.dart';
import 'package:intl/intl.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:url_launcher/url_launcher.dart';
// import 'package:get_version/get_version.dart';

import 'app/auth/login.dart';
import 'app/dashboard.dart';
import 'appUtil/network_util.dart';

class AppSplashScreen extends StatefulWidget {
  @override
  _AppSplashScreenState createState() => _AppSplashScreenState();
}

class _AppSplashScreenState extends State<AppSplashScreen> {
  //Variable for Connectivity
  ConnectivityResult _connectionStatus = ConnectivityResult.none;
  final Connectivity _connectivity = Connectivity();
  late StreamSubscription<ConnectivityResult> _connectivitySubscription;

  // String _platformVersion = 'Unknown';
  String _projectVersion = '';
  int companyId = 0;
  // PackageInfo _packageInfo = PackageInfo(
  //   appName: packageInfo.appName,
  //   packageName: 'Unknown',
  //   version: 'Unknown',
  //   buildNumber: 'Unknown',
  // );

  // String _projectCode = '';
  // String _projectAppID = '';
  // String _projectName = '';
  Future<SharedPreferences> _prefs = SharedPreferences.getInstance();
  bool isLogin = false;
  String name = '',
      email = '',
      image = '',
      title = '',
      msg = '',
      img = '',
      videoCode = '',
      start = '',
      end = '',
      companyLogo = '',
      companyLogoDefault = 'assets/image/aipex_logo.png';
  late int id;
  String? _deviceId;
  NetworkUtil _networkUtil = NetworkUtil();

  @override
  Widget build(BuildContext context) {
    //2,436 x 1,125
//    ScreenUtil.instance = ScreenUtil.getInstance()..init(context);
//    ScreenUtil.instance = ScreenUtil(width: 375, height: 812)..init(context);
    return SafeArea(
       top: false,
        bottom: true,
      child: Scaffold(
          body: Container(
        color: appWhiteColor,
        child: Stack(
          children: <Widget>[
            Align(alignment: Alignment.bottomCenter, child: loadLogo()),
            Image.asset(
              'assets/image/splash_bg.png',
              width: MediaQuery.of(context).size.width,
              height: MediaQuery.of(context).size.height - 100,
              fit: BoxFit.fill,
            ),
            Align(
              alignment: Alignment.topCenter,
              child: Container(
                padding: EdgeInsets.only(left: 30),
                child: Image.asset(
                  'assets/image/splash_ig.png',
                  height: MediaQuery.of(context).size.height - 250,
                  fit: BoxFit.fill,
                ),
              ),
            ),
          ],
        ),
      )),
    );
  }

  @override
  void initState() {
    super.initState();

    _initPlatformState();
    _isLogin();
    getDeviceInfo();
    print(companyLogo);
    // getSpData();
    initConnectivity();
    // _connectivitySubscription =
    //     _connectivity.onConnectivityChanged.listen(_updateConnectionStatus);
  }

  Future _isLogin() async {
    final SharedPreferences prefs = await _prefs;
    isLogin = ((prefs.getBool(SP_IS_LOGIN_BOOL) != null)
        ? prefs.getBool(SP_IS_LOGIN_BOOL)
        : false)!;
    if (isLogin) {
      companyLogo = prefs.getString(SP_COMPANY_LOGO)!;
      name = prefs.getString(SP_LAST_NAME)!;
      email = prefs.getString(SP_EMAIL)!;
      image = prefs.getString(SP_PROFILE_IMAGE)!;
      companyId = prefs.getInt(SP_COMPANY_ID)!;
    }
    if (prefs.getInt(SP_ATTENDANCE_STATUS) == null) {
      prefs.setInt(
        SP_ATTENDANCE_STATUS,
        0,
      );
    }
    if (prefs.getString(SP_ATTENDANCE_DATE) == null) {
      prefs.setString(
        SP_ATTENDANCE_DATE,
        DateFormat('yyyy-MM-dd').format(DateTime.now()),
      );
    }
    if (prefs.getString(SP_ATTENDANCE_IN_TIME) == null) {
      prefs.setString(
        SP_ATTENDANCE_DATE,
        '',
      );
    }
    if (prefs.getString(SP_ATTENDANCE_OUT_TIME) == null) {
      prefs.setString(
        SP_ATTENDANCE_OUT_TIME,
        '',
      );
    }
    if (prefs.getString(SP_ATTENDANCE_OUT_TIME_DATE) == null) {
      prefs.setString(
        SP_ATTENDANCE_OUT_TIME_DATE,
        '',
      );
    }
    if (prefs.getInt(SP_ATTENDANCE_ID) == null) {
      prefs.setInt(
        SP_ATTENDANCE_ID,
        0,
      );
    }
    if (prefs.getInt(SP_ATTENDANCE_BREAK_ID) == null) {
      prefs.setInt(
        SP_ATTENDANCE_BREAK_ID,
        0,
      );

//      if (prefs.getString(SP_COMPANY_LOGO) == null) {
//        prefs.setString(
//          SP_ATTENDANCE_BREAK_ID,
//          'assets/image/aipex_logo.png',
//        );
//      }
      /*
    if (prefs.getInt(SP_NEWS_ID) == null) {
      prefs.setInt(SP_NEWS_ID, 0);
    }
      if (prefs.getString(SP_NEWS_TITLE) == null) {
        prefs.setString(
          SP_NEWS_TITLE,
          '',
        );
      }
      if (prefs.getString(SP_NEWS_MESSAGE) == null) {
        prefs.setString(
          SP_NEWS_MESSAGE,
          '',
        );
      }
      if (prefs.getString(SP_NEWS_URL) == null) {
        prefs.setString(
          SP_NEWS_URL,
          '',
        );
      }
      if (prefs.getString(SP_NEWS_VIDEOCODE) == null) {
        prefs.setString(
          SP_NEWS_VIDEOCODE,
          '',
        );
      }
      if (prefs.getString(SP_NEWS_START) == null) {
        prefs.setString(
          SP_NEWS_START,
          '',
        );
      }
      if (prefs.getString(SP_NEWS_END) == null) {
        prefs.setString(
          SP_NEWS_END,
          '',
        );
      }

       */
    }

    if (companyId != 120) {
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
    }
  }

  @override
  void dispose() {
    super.dispose();
  }

  void _initPlatformState() async {
    //   String platformVersion;
    //   // Platform messages may fail, so we use a try/catch PlatformException.
    //   try {
    //     platformVersion = await GetVersion.platformVersion;
    //   } on PlatformException {
    //     platformVersion = 'Failed to get platform version.';
    //   }

    String projectVersion;
    // Platform messages may fail, so we use a try/catch PlatformException.
    PackageInfo.fromPlatform().then((PackageInfo packageInfo) {
      _projectVersion = packageInfo.version;
      print("version---02>" + packageInfo.version);
      apiCall();
    });

    // setState(() {
    //   //     _platformVersion = platformVersion;
    //   _projectVersion = projectVersion;

    //   print("version---03>");

    //   apiCall();
    // });
  }

  void saveData(List<News> news) async {
    final SharedPreferences prefs = await _prefs;
    news.forEach((_news) {
      prefs.setString(SP_NEWS_TITLE, _news.title);
      prefs.setString(SP_NEWS_MESSAGE, _news.message);
      prefs.setString(SP_NEWS_URL, _news.image_url);
      prefs.setString(SP_NEWS_VIDEOCODE, _news.youtube_video_code);
      prefs.setString(SP_NEWS_START, _news.start_time);
      prefs.setString(SP_NEWS_END, _news.end_time);
    });
  }

  DeviceInfoPlugin deviceInfo = DeviceInfoPlugin();

  void getDeviceInfo() async {
    if (Platform.isAndroid) {
      AndroidDeviceInfo androidInfo = await deviceInfo.androidInfo;
      _deviceId = androidInfo.id;
      print('Running on ${androidInfo.model}');
    } else if (Platform.isIOS) {
      IosDeviceInfo iosInfo = await deviceInfo.iosInfo;
      _deviceId = iosInfo.identifierForVendor!;
      print('Running on ${iosInfo.name}');
    }
  }

  void saveUserData(UserData user) async {
    final SharedPreferences prefs = await _prefs;
    prefs.setBool(
      SP_IS_LOGIN_BOOL,
      true,
    );
//    prefs.setString(
//      SP_API_TOKEN,
//      user.tokenKey,
//    );
    prefs.setString(
      SP_LAST_NAME,
      user.firstName ?? "",
    );
    prefs.setString(
      SP_EMAIL,
      user.email ?? "",
    );
    prefs.setString(
      SP_CONTACT_NO,
      user.contactNo ?? "",
    );
    prefs.setString(
      SP_PROFILE_IMAGE,
      user.profileImage ?? "",
    );
    prefs.setString(
      SP_COMPANY_NAME,
      user.companyName ?? "",
    );
    prefs.setString(
      LATITUDE,
      user.latitude ?? "",
    );
    prefs.setString(
      LONGITUDE,
      user.longitude ?? "",
    );
    prefs.setString(
      DEVICE_ID,
      _deviceId ?? "",
    );
    prefs.setInt(
      SP_ROLE,
      user.roleId,
    );
    prefs.setInt(
      SP_LOCATION_TRACKING,
      user.locationTracking,
    );
    prefs.setInt(
      SP_LOCATION_TRACKING_DURATION,
      user.locationTrackingDuration,
    );
    prefs.setInt(
      SP_ATTENDANCE_SELFIE,
      user.attendanceSelfie,
    );
    prefs.setInt(
      SP_ID,
      user.id,
    );
    prefs.setInt(
      SP_COMPANY_ID,
      user.companyId,
    );
    prefs.setInt(
      GEOFENCING,
      user.geofencing,
    );
    prefs.setInt(
      DISTANCE,
      user.distance,
    );
    prefs.setInt(
      TASK_MANAGER,
      user.taskManager,
    );
    prefs.setString(SP_COMPANY_LOGO, user.companyLogo ?? "");
    prefs.setInt(SP_DRIVER, user.driverDelivery);
    prefs.setInt(APPROVE_TASK, (user.roleId < 5) ? 1 : 0);
    prefs.setInt(TEAM_LEAD_ID, user.teamLeadId);
    prefs.setBool(SP_GOOGLE_SECRATE_CODE, user.googleSecrateCode);
    prefs.setString(SP_HELPLINE_NO, user.helpline_no ?? "");
    prefs.setInt(SP_BUFFER_LEAVE,
        (user.noOfDaysLimitForLeave == null) ? 30 : user.noOfDaysLimitForLeave);
    prefs.setInt(
        SP_BUFFER_ATTENDANCE,
        (user.noOfDaysLimitForMarkAttendance == null)
            ? 4
            : user.noOfDaysLimitForMarkAttendance);
    Navigator.of(context).pushReplacement(new MaterialPageRoute(
        builder: (BuildContext context) => new DashboardPage(
              name: name,
              email: email,
              image: image,
              projectVersion: _projectVersion,
            )));
  }

  Future apiCall() async {
    var connectivityResult = await (Connectivity().checkConnectivity());
    if (connectivityResult != ConnectivityResult.none) {
      final SharedPreferences prefs = await _prefs;
      var userId = 0, companyId = 0;
      if (prefs.getBool(SP_IS_LOGIN_BOOL) != null) {
        userId = prefs.getInt(SP_ID) ?? 0;
        companyId = prefs.getInt(SP_COMPANY_ID) ?? 0;
      }
      var map = new Map<String, dynamic>();
      map["appType"] =
          (Platform.operatingSystem.toUpperCase() == 'ANDROID') ? '0' : '1';
      map["appVersionName"] = appVersionName;
      map["appVersionCode"] = androidVersion;
      map["userId"] = '$userId';
      map["companyId"] = '$companyId';
      map["updatePriority"] = '1';
      print(map);
       
      try {
        showLoader(context);
        _networkUtil.post(getAppVersion, body: map).then((dynamic res) {
          Navigator.pop(context);
          try {
            // AppLog.showLog(res.toString());
            AppUpdateApiCallBack _appUpdateApiCallBack =
                AppUpdateApiCallBack.fromJson(res);
            // print("G1---99>${res}");
            if (!_appUpdateApiCallBack.success) {
              if (isLogin) {
                Navigator.of(context).pushReplacement(new MaterialPageRoute(
                    builder: (BuildContext context) => new DashboardPage(
                        name: name,
                        email: email,
                        image: image,
                        projectVersion: _projectVersion)));
              } else {
                Navigator.of(context).pushReplacement(new MaterialPageRoute(
                    builder: (BuildContext context) => new LoginScreen()));
              }
            } else {
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
              print("g1----88>${timeDifference.toString()} && ${bufferTime}");
              print(
                  "g1----99>${androidVersion.toString()} && ${_appUpdateApiCallBack.items[0].app_build_version}");

              if (timeDifference > bufferTime) {
                print('time difference');
                showDialog(
                    context: context,
                    barrierDismissible: false,
                    builder: (BuildContext context) {
                      return StatefulBuilder(builder: (context, setState) {
                        return AlertDialog(
                          contentPadding: EdgeInsets.all(0),
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.all(
                                  Radius.circular(ScreenUtil().setSp(10)))),
                          content: Column(
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
                              SizedBox(
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
                                          style: TextStyle(
                                            fontSize: 15.0,
                                            fontWeight: FontWeight.bold,
                                          )),
                                    ),
                                  ],
                                ),
                              ),
                              SizedBox(
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
                                    child: Center(
                                      child: Padding(
                                        padding: const EdgeInsets.all(8.0),
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
                              SizedBox(
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
                PackageInfo.fromPlatform().then((PackageInfo packageInfo) {
                  _projectVersion = packageInfo.version;
                  print("version---01>" + packageInfo.version);
                });
                if (Platform.isIOS) {
                  final mversion = _projectVersion.replaceAll(".", "");
                  final apiVersion = _appUpdateApiCallBack
                      .items[0].app_build_version
                      .replaceAll(".", "");
                  print("G111---version>${mversion}");
                  print("G111---1>${apiVersion}");
                  // if (_projectVersion >
                  //     double.parse(
                  //         _appUpdateApiCallBack.items[0].app_build_version)) {
                  //Changes by... G1

                  if (int.parse(mversion) < int.parse(apiVersion)) {
                    showDialog(
                        context: context,
                        barrierDismissible: false,
                        builder: (BuildContext context) {
                          return StatefulBuilder(builder: (context, setState) {
                            return AlertDialog(
                              contentPadding: EdgeInsets.all(0),
                              shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.all(
                                      Radius.circular(ScreenUtil().setSp(10)))),
                              content: Column(
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
                                          Text(
                                            'App Update',
                                            textAlign: TextAlign.center,
                                            style: TextStyle(
                                                fontSize:
                                                    ScreenUtil().setSp(16),
                                                fontWeight: FontWeight.bold,
                                                color: appWhiteColor),
                                          ),
                                          Expanded(
                                            child: Container(),
                                          ),
                                        ],
                                      )),
                                  SizedBox(
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
                                              'A new version of AiPex HRMS is available. Please update to version',
                                              style: TextStyle(
                                                fontSize: 15.0,
                                                fontWeight: FontWeight.bold,
                                              )),
                                        ),
                                      ],
                                    ),
                                  ),
                                  SizedBox(
                                    height: 10.0,
                                  ),
                                  Padding(
                                    padding: const EdgeInsets.only(
                                        left: 20.0, right: 20.0),
                                    child: Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceAround,
                                      children: <Widget>[
                                        Expanded(
                                          child: Card(
                                            shape: RoundedRectangleBorder(
                                              borderRadius:
                                                  BorderRadius.circular(20.0),
                                            ),
                                            color: appColorRedIcon,
                                            child: GestureDetector(
                                              child: Padding(
                                                padding:
                                                    const EdgeInsets.all(8.0),
                                                child: Center(
                                                  child: Text('Update',
                                                      style: TextStyle(
                                                        color: Colors.white,
                                                        fontSize: 15.0,
                                                        fontWeight:
                                                            FontWeight.bold,
                                                      )),
                                                ),
                                              ),
                                              onTap: () async {
                                                final Uri url = Uri.parse(
                                                    "https://apps.apple.com/app/id1495636713");
                                                if (await canLaunchUrl(url)) {
                                                  await launchUrl(url,
                                                      mode: LaunchMode
                                                          .externalApplication);
                                                } else {
                                                  throw 'Could not launch $url';
                                                }
                                              },
                                            ),
                                          ),
                                        ),
                                        Expanded(
                                          child: Card(
                                            shape: RoundedRectangleBorder(
                                              borderRadius:
                                                  BorderRadius.circular(20.0),
                                            ),
                                            color: appColorRedIcon,
                                            child: GestureDetector(
                                              child: Center(
                                                child: Padding(
                                                  padding:
                                                      const EdgeInsets.all(8.0),
                                                  child: Center(
                                                    child: Text('Skip',
                                                        style: TextStyle(
                                                          color: Colors.white,
                                                          fontSize: 15.0,
                                                          fontWeight:
                                                              FontWeight.bold,
                                                        )),
                                                  ),
                                                ),
                                              ),
                                              onTap: () async {
                                                Navigator.pop(context);
                                                if (isLogin) {
                                                  saveUserData(
                                                      _appUpdateApiCallBack
                                                          .userData!);
                                                } else {
                                                  Navigator.of(context).pushReplacement(
                                                      new MaterialPageRoute(
                                                          builder: (BuildContext
                                                                  context) =>
                                                              new LoginScreen()));
                                                }
                                              },
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                  SizedBox(
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
                    saveData(_appUpdateApiCallBack.news);
                    if (isLogin) {
                      saveUserData(_appUpdateApiCallBack.userData!);
                    } else {
                      Navigator.of(context).pushReplacement(
                          new MaterialPageRoute(
                              builder: (BuildContext context) =>
                                  new LoginScreen()));
                    }
                  }
                }
                if (Platform.isAndroid) {
                  final mversion = _projectVersion.replaceAll(".", "");
                  // String apiVersion = "160";
                  final apiVersion = _appUpdateApiCallBack
                      .items[0].app_build_version
                      .replaceAll(".", "");
                  print("G111---version>${mversion}");
                  print("G111---1>${apiVersion}");
                  // if (mversion.compareTo(apiVersion) < 0) {
                  if (int.parse(mversion) < int.parse(apiVersion)) {
                    //update dialog here
                    showDialog(
                        context: context,
                        barrierDismissible: false,
                        builder: (BuildContext context) {
                          return StatefulBuilder(builder: (context, setState) {
                            return AlertDialog(
                              contentPadding: EdgeInsets.all(0),
                              shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.all(
                                      Radius.circular(ScreenUtil().setSp(10)))),
                              content: Column(
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
                                          Text(
                                            'App Update',
                                            textAlign: TextAlign.center,
                                            style: TextStyle(
                                                fontSize:
                                                    ScreenUtil().setSp(16),
                                                fontWeight: FontWeight.bold,
                                                color: appWhiteColor),
                                          ),
                                          Expanded(
                                            child: Container(),
                                          ),
                                        ],
                                      )),
                                  SizedBox(
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
                                              'A new version of AiPex HRMS is available. Please update to version',
                                              style: TextStyle(
                                                fontSize: 15.0,
                                                fontWeight: FontWeight.bold,
                                              )),
                                        ),
                                      ],
                                    ),
                                  ),
                                  SizedBox(
                                    height: 10.0,
                                  ),
                                  Padding(
                                    padding: const EdgeInsets.only(
                                        left: 50.0, right: 50.0),
                                    child: Row(
                                      children: [
                                        Expanded(
                                          child: Card(
                                            shape: RoundedRectangleBorder(
                                              borderRadius:
                                                  BorderRadius.circular(20.0),
                                            ),
                                            color: appColorRedIcon,
                                            child: GestureDetector(
                                              child: Center(
                                                child: Padding(
                                                  padding:
                                                      const EdgeInsets.all(8.0),
                                                  child: Center(
                                                    child: Text('Update',
                                                        style: TextStyle(
                                                          color: Colors.white,
                                                          fontSize: 15.0,
                                                          fontWeight:
                                                              FontWeight.bold,
                                                        )),
                                                  ),
                                                ),
                                              ),
                                              onTap: () async {
                                                final Uri url = Uri.parse(Theme
                                                                .of(context)
                                                            .platform ==
                                                        TargetPlatform.iOS
                                                    ? "https://apps.apple.com/app/id1393616437"
                                                    : "https://play.google.com/store/apps/details?id=co.aipex.hrms");

                                                if (await canLaunchUrl(url)) {
                                                  await launchUrl(url,
                                                      mode: LaunchMode
                                                          .externalApplication);
                                                } else {
                                                  throw 'Could not launch $url';
                                                }
                                              },
                                            ),
                                          ),
                                        ),
                                        Expanded(
                                          child: Card(
                                            shape: RoundedRectangleBorder(
                                              borderRadius:
                                                  BorderRadius.circular(20.0),
                                            ),
                                            color: appColorRedIcon,
                                            child: GestureDetector(
                                              child: Center(
                                                child: Padding(
                                                  padding:
                                                      const EdgeInsets.all(8.0),
                                                  child: Center(
                                                    child: Text('Skip',
                                                        style: TextStyle(
                                                          color: Colors.white,
                                                          fontSize: 15.0,
                                                          fontWeight:
                                                              FontWeight.bold,
                                                        )),
                                                  ),
                                                ),
                                              ),
                                              onTap: () async {
                                                Navigator.pop(context);
                                                if (isLogin) {
                                                  saveUserData(
                                                      _appUpdateApiCallBack
                                                          .userData!);
                                                } else {
                                                  Navigator.of(context).pushReplacement(
                                                      new MaterialPageRoute(
                                                          builder: (BuildContext
                                                                  context) =>
                                                              new LoginScreen()));
                                                }
                                              },
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                  SizedBox(
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
                    saveData(_appUpdateApiCallBack.news);
                    if (isLogin) {
                      saveUserData(_appUpdateApiCallBack.userData!);
                    } else {
                      Navigator.of(context).pushReplacement(
                          new MaterialPageRoute(
                              builder: (BuildContext context) =>
                                  new LoginScreen()));
                    }
                  }
                }
              }
            }
          } catch (es) {
            showErrorLog(es.toString());
            showCenterToast(errorApiCall);
          }
//          setState(() {});
        });
      } catch (e) {
        Navigator.pop(context);
        showErrorLog(e.toString());
        showCenterToast(errorApiCall);
      }
    } else {
      showCenterToast('No Internet');
    }
  }

  // showDialogUpdate(){

  // }

  Widget loadLogo() {
    try {
      return Padding(
          padding: EdgeInsets.only(
            left: ScreenUtil().setSp(75),
            right: ScreenUtil().setSp(75),
            top: ScreenUtil().setSp(40),
            bottom: ScreenUtil().setSp(28),
          ),
          child: (companyLogo == '')
              ? Image.asset(
                  companyLogoDefault,
                  //'assets/image/aipex_logo.png',
                  height: ScreenUtil().setSp(80),
                  width: ScreenUtil().setSp(170),
                )
              : Container(
                  width: ScreenUtil().setSp(140),
                  height: ScreenUtil().setSp(70),
                  child: new Image.network(companyLogo),
                ));
    } catch (e) {
      return Padding(
          padding: EdgeInsets.only(
            left: ScreenUtil().setSp(75),
            right: ScreenUtil().setSp(75),
            top: ScreenUtil().setSp(40),
            bottom: ScreenUtil().setSp(8),
          ),
          child: Image.asset(
            companyLogoDefault,
            //'assets/image/aipex_logo.png',
            height: ScreenUtil().setSp(80),
            width: ScreenUtil().setSp(170),
          ));
    }
  }

  //Method for Connectivity
 Future<void> initConnectivity() async {
  List<ConnectivityResult> results;
  try {
    results = await _connectivity.checkConnectivity(); // ✅ returns List<ConnectivityResult>
  } on PlatformException catch (e) {
    print("Connectivity check failed: $e");
    return;
  }

  if (!mounted) return;

  // ✅ Take the first available connection type (or none)
  final ConnectivityResult result = 
      results.isNotEmpty ? results.first : ConnectivityResult.none;

  await _updateConnectionStatus(result);
}

  //Method for Connectivity
  Future<void> _updateConnectionStatus(ConnectivityResult result) async {
    setState(() {
      _connectionStatus = result;
    });
  }
}

class AppUpdateApiCallBack {
  String current_time;
  String current_utc_time;
  List<Item> items;
  List<News> news;
  UserData? userData; // ✅ make nullable
  String message;
  int status;
  bool success;
  int total_count;

  AppUpdateApiCallBack({
    required this.current_time,
    required this.current_utc_time,
    required this.items,
    required this.news,
    this.userData, // ✅ nullable
    required this.message,
    required this.status,
    required this.success,
    required this.total_count,
  });

  factory AppUpdateApiCallBack.fromJson(Map<String, dynamic> json) {
    return AppUpdateApiCallBack(
      current_time: json['current_time'],
      current_utc_time: json['current_utc_time'],
      items: (json['items'] as List<dynamic>?)
              ?.map((i) => Item.fromJson(i))
              .toList() ??
          [],
      news: (json['news'] as List<dynamic>?)
              ?.map((i) => News.fromJson(i))
              .toList() ??
          [],
      userData: json['userData'] != null
          ? UserData.fromJson(json['userData'])
          : null, // ✅ handle null safely
      message: json['message'],
      status: json['status'],
      success: json['success'],
      total_count: json['total_count'],
    );
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = {};
    data['current_time'] = current_time;
    data['current_utc_time'] = current_utc_time;
    data['message'] = message;
    data['status'] = status;
    data['success'] = success;
    data['total_count'] = total_count;
    data['items'] = items.map((v) => v.toJson()).toList();
    data['news'] = news.map((v) => v.toJson()).toList();
    if (userData != null) {
      data['userData'] = userData!.toJson(); // ✅ only add if not null
    }
    return data;
  }
}


class Item {
  String app_build_version;
  int app_type;
  int app_version_code;
  String app_version_name;
  String app_version_no;
  int id;
  int is_delete;
  String update_datetime;
  int update_priority;

  Item(
      {required this.app_build_version,
      required this.app_type,
      required this.app_version_code,
      required this.app_version_name,
      required this.app_version_no,
      required this.id,
      required this.is_delete,
      required this.update_datetime,
      required this.update_priority});

  factory Item.fromJson(Map<String, dynamic> json) {
    return Item(
      app_build_version: json['app_build_version'],
      app_type: json['app_type'],
      app_version_code: json['app_version_code'],
      app_version_name: json['app_version_name'],
      app_version_no: json['app_version_no'],
      id: json['id'],
      is_delete: json['is_delete'],
      update_datetime: json['update_datetime'],
      update_priority: json['update_priority'],
    );
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['app_build_version'] = this.app_build_version;
    data['app_type'] = this.app_type;
    data['app_version_code'] = this.app_version_code;
    data['app_version_name'] = this.app_version_name;
    data['app_version_no'] = this.app_version_no;
    data['id'] = this.id;
    data['is_delete'] = this.is_delete;
    data['update_datetime'] = this.update_datetime;
    data['update_priority'] = this.update_priority;
    return data;
  }
}

class News {
  int id; // 2,
  String title; //"Title with 100 char",
  String message; // "Title with 1000 char",
  String image_url; // "https://google.com",
  String youtube_video_code; // "n38s34oasd",
  String start_time; // "2020-04-20 23:17:22",
  String end_time; // "2020-04-20 23:17:22"

  News(
      {required this.id,
      required this.title,
      required this.message,
      required this.image_url,
      required this.youtube_video_code,
      required this.start_time,
      required this.end_time});

  factory News.fromJson(Map<String, dynamic> json) {
    return News(
        id: json['id'],
        title: json['title'],
        message: json['message'],
        image_url: json['image_url'],
        youtube_video_code: json['youtube_video_code'],
        start_time: json['start_time'],
        end_time: json['end_time']);
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['id'] = this.id;
    data['title'] = this.title;
    data['message'] = this.message;
    data['image_url'] = this.image_url;
    data['youtube_video_code'] = this.youtube_video_code;
    data['start_time'] = this.start_time;
    data['end_time'] = this.end_time;
    return data;
  }
}

class UserData {
  late int id;
  String? firstName;
  late int companyId;
  late int roleId;
  late int isAdmin;
  late int isManager;
  String? email;
  late int gender;
  String? contactNo;
  String? profileImage;
  String? tokenKey;
  String? deviceId;
  late int locationTrackingDuration;
  late int geofencing;
  String? latitude;
  String? longitude;
  late int distance;
  late int teamLeadId;
  String? companyLogo;
  String? companyName;
  late bool googleSecrateCode;
  late int noOfDaysLimitForMarkAttendance;
  late int noOfDaysLimitForLeave;
  late int locationTracking;
  late int attendanceSelfie;
  late int driverDelivery;
  late int taskManager;
  String? helpline_no;

  UserData(
      {required this.id,
      required this.firstName,
      required this.companyId,
      required this.roleId,
      required this.isAdmin,
      required this.isManager,
      required this.email,
      required this.gender,
      required this.contactNo,
      required this.profileImage,
      required this.tokenKey,
      required this.deviceId,
      required this.locationTrackingDuration,
      required this.geofencing,
      required this.latitude,
      required this.longitude,
      required this.distance,
      required this.teamLeadId,
      required this.companyLogo,
      required this.companyName,
      required this.googleSecrateCode,
      required this.noOfDaysLimitForMarkAttendance,
      required this.noOfDaysLimitForLeave,
      required this.locationTracking,
      required this.attendanceSelfie,
      required this.driverDelivery,
      required this.taskManager,
      required this.helpline_no});

  UserData.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    firstName = json['first_name'];
    companyId = json['company_id'];
    roleId = json['role_id'];
    isAdmin = json['is_admin'];
    isManager = json['is_manager'];
    email = json['email'];
    gender = json['gender'];
    contactNo = json['contact_no'];
    profileImage = json['profileImage'];
    tokenKey = json['tokenKey'];
    deviceId = json['deviceId'];
    locationTrackingDuration = json['location_tracking_duration'];
    geofencing = json['geofencing'];
    // latitude = json['latitude'];
    // longitude = json['longitude'];
    // distance = json['distance'];
    teamLeadId = json['team_lead_id'];
    companyLogo = json['company_logo'];
    companyName = json['company_name'];
    googleSecrateCode = json['google_secrate_code'];
    noOfDaysLimitForMarkAttendance =
        json['no_of_days_limit_for_mark_attendance'];
    noOfDaysLimitForLeave = json['no_of_days_limit_for_leave'];
    locationTracking = json['location_tracking'];
    attendanceSelfie = json['attendance_selfie'];
    driverDelivery = json['driver_delivery'];
    taskManager = json['task_manager'];
    // helpline_no = json['helpline_no'];
    //Change by G1...
    helpline_no = json["helpline_no"] == null ? "" : json["helpline_no"];
    latitude = json["latitude"] == null ? "" : json["latitude"];
    longitude = json["longitude"] == null ? "" : json["longitude"];
    // distance = json["distance"] == null ? "" : json["distance"];
    distance = json["distance"] == null ? 0 : json["distance"];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['id'] = this.id;
    data['first_name'] = this.firstName;
    data['company_id'] = this.companyId;
    data['role_id'] = this.roleId;
    data['is_admin'] = this.isAdmin;
    data['is_manager'] = this.isManager;
    data['email'] = this.email;
    data['gender'] = this.gender;
    data['contact_no'] = this.contactNo;
    data['profileImage'] = this.profileImage;
    data['tokenKey'] = this.tokenKey;
    data['deviceId'] = this.deviceId;
    data['location_tracking_duration'] = this.locationTrackingDuration;
    data['geofencing'] = this.geofencing;
    data['latitude'] = this.latitude;
    data['longitude'] = this.longitude;
    data['distance'] = this.distance;
    data['team_lead_id'] = this.teamLeadId;
    data['company_logo'] = this.companyLogo;
    data['company_name'] = this.companyName;
    data['google_secrate_code'] = this.googleSecrateCode;
    data['no_of_days_limit_for_mark_attendance'] =
        this.noOfDaysLimitForMarkAttendance;
    data['no_of_days_limit_for_leave'] = this.noOfDaysLimitForLeave;
    data['location_tracking'] = this.locationTracking;
    data['attendance_selfie'] = this.attendanceSelfie;
    data['driver_delivery'] = this.driverDelivery;
    data['task_manager'] = this.taskManager;
    data['helpline_no'] = this.helpline_no;
    return data;
  }
}
