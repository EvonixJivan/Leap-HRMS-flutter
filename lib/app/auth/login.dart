import 'dart:io';

import 'package:device_info_plus/device_info_plus.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:hrms/app/mainApp/attendance/attendance_list.dart';
import 'package:hrms/app/uiComponent/custom_header.dart';
import 'package:hrms/appUtil/app_util_config.dart';
import 'package:hrms/appUtil/network_util.dart';
import 'package:intl/intl.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../app_splash_screen.dart';
import '../dashboard.dart';
import 'forgot_password.dart';

class LoginScreen extends StatefulWidget {
  LoginScreen({Key? key}) : super(key: key);

  @override
  _LoginScreenState createState() {
    return _LoginScreenState();
  }
}

class _LoginScreenState extends State<LoginScreen> {
  final Permission _permission = Permission.location;
  PermissionStatus _permissionStatus = PermissionStatus.denied;

  Future<SharedPreferences> _prefs = SharedPreferences.getInstance();
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  NetworkUtil _networkUtil = NetworkUtil();
  bool isLogin = false;
  bool _obscureText = true;
  String? _email, _password, _deviceId, _deviceName, _deviceManufacturer;
  DeviceInfoPlugin deviceInfo = DeviceInfoPlugin();
  bool _obscureTextVerify = true;

  void _toggle() {
    setState(() {
      _obscureText = !_obscureText;
    });
  }

  Future apiCall() async {
    if (_formKey.currentState!.validate()) {
      _formKey.currentState!.save();

      var map = new Map<String, dynamic>();
      map["appType"] = Platform.operatingSystem.toUpperCase();
      map["username"] = _email;
      map["password"] = _password;
      map["deviceId"] = _deviceId;
      map["fcmToken"] =
          'kjahdsklfhaklsfhklasjhflksdjhaflkjsdhlfkjhalkfjhklasdjfhks';
      map["deviceName"] = _deviceName;
      map["deviceManufacturer"] = _deviceManufacturer;
      map['flag'] = 'Email';
      print(map);
      try {
        showLoader(context);
        _networkUtil.post(apiLogin, body: map).then((dynamic res) {
          Navigator.pop(context);
          try {
            AppLog.showLog(res.toString());
            showBottomToast(res['message']);
            LoginApiCallBack loginApiCallBack = LoginApiCallBack.fromJson(res);
            if (loginApiCallBack.success) {
              if (loginApiCallBack.items != null) {
                saveData(loginApiCallBack.items!);
              }
            } else {}
          } catch (es) {
            showErrorLog(es.toString());
          }
        });
      } catch (e) {
        Navigator.pop(context);
        showErrorLog(e.toString());
        showCenterToast(errorApiCall);
      }
    }
  }

  Future<Null> _isLogin() async {
    final SharedPreferences prefs = await _prefs;
    isLogin = (prefs.getBool(SP_IS_LOGIN_BOOL) != null)
        ? prefs.getBool(SP_IS_LOGIN_BOOL)!
        : false;
    if (!isLogin) {
      prefs.setBool(SP_IS_LOGIN_BOOL, false);
    }
  }

  void getDeviceInfo() async {
    if (Platform.isAndroid) {
      AndroidDeviceInfo androidInfo = await deviceInfo.androidInfo;
      _deviceId = androidInfo.id;
      _deviceName = androidInfo.brand;
      _deviceManufacturer = androidInfo.manufacturer;
      print('Running on ${androidInfo.model}');
    } else if (Platform.isIOS) {
      IosDeviceInfo iosInfo = await deviceInfo.iosInfo;
      _deviceId = iosInfo.identifierForVendor!;
      _deviceName = iosInfo.name;
      _deviceManufacturer = iosInfo.name;
      print('Running on ${iosInfo.name}');
    }
  }

  @override
  void initState() {
    super.initState();
    getDeviceInfo();
    _isLogin();
    _listenForPermissionStatus();
  }

  Future<void> saveLoginData() async {
    final SharedPreferences prefs = await _prefs;
    prefs.setBool(SP_IS_LOGIN_BOOL, true);
  }

  @override
  Widget build(BuildContext context) {
    //2,436 x 1,125

    final forgotPassword = Hero(
      tag: 'forgotPassword',
      child: GestureDetector(
        child: Text(
          'Forgot Password',
          style: TextStyle(
            color: tfBackgroundColor,
            fontSize: 13.0,
            fontFamily: font,
            // decoration: TextDecoration.underline,
          ),
        ),
        onTap: () {
          Navigator.of(context).push(new MaterialPageRoute(
              builder: (BuildContext context) => ForgotPassword()));
        },
      ),
    );
    final otherLogin = Hero(
      tag: 'otherLogin',
      child: GestureDetector(
        child: Container(
          height: 40,
          padding: EdgeInsets.only(top: 13, left: 15, right: 15),
          decoration: new BoxDecoration(
              color: appWhiteColor,
              borderRadius: new BorderRadius.circular(25)),
          child: Text(
            'Login with Employee ID',
            style: TextStyle(
              fontSize: 13.0,
              fontFamily: font,
            ),
          ),
        ),
        onTap: () {
          if (Platform.isAndroid) {
            if (_permissionStatus != PermissionStatus.granted) {
              requestPermission(_permission);
            } else {
              Navigator.of(context).push(new MaterialPageRoute(
                  builder: (BuildContext context) => NewLoginScreen()));
            }
          } else {
            Navigator.of(context).push(new MaterialPageRoute(
                builder: (BuildContext context) => NewLoginScreen()));
          }
        },
      ),
    );
    final logo = Hero(
      tag: 'hero',
      child: Image.asset(
        'assets/image/aipex_logo.png',
        height: ScreenUtil().setSp(90),
        width: ScreenUtil().setSp(180),
      ),
    );

    final email = Row(children: <Widget>[
      new Expanded(
        child: Padding(
          padding: EdgeInsets.only(
              left: ScreenUtil().setSp(40), right: ScreenUtil().setSp(40)),
          child: TextFormField(
            autocorrect: true,
            keyboardType: TextInputType.emailAddress,
            autofocus: false,
            validator: (val) {
              if (val!.isEmpty) {
                return 'Email is required';
              }
              if (!AppUtil.isEmail(val)) {
                return 'Not a valid email.';
              }
              return null;
            },
            style: TextStyle(
              fontFamily: font,
            ),
            decoration: InputDecoration(
              hintText: '  Employee Email ID',
              filled: true,
              fillColor: tfBackgroundColor,
              contentPadding: EdgeInsets.fromLTRB(10.0, 5.0, 10.0, 5.0),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(25.0),
                borderSide: BorderSide.none,
              ),
              enabledBorder: UnderlineInputBorder(
                borderSide: BorderSide.none,
                borderRadius: BorderRadius.circular(25.7),
              ),
            ),
            onSaved: (String? value) {
              _email = value!;
              print(value);
            },
          ),
        ),
      ),
    ]);

    final password = Row(children: <Widget>[
      new Expanded(
        child: Padding(
          padding: EdgeInsets.only(
              left: ScreenUtil().setSp(40), right: ScreenUtil().setSp(40)),
          child: TextFormField(
            autocorrect: true,
            keyboardType: TextInputType.visiblePassword,
            autofocus: false,
            validator: (val) {
              if (val!.isEmpty) {
                return 'Password is required';
              }
              return null;
            },
            obscureText: _obscureText,
            style: TextStyle(
              fontFamily: font,
            ),
            decoration: InputDecoration(
              contentPadding: EdgeInsets.only(
                  left: 20.0, right: 20.0, bottom: 2.0, top: 12.0),
              hintText: '  Password',
              filled: true,
              fillColor: tfBackgroundColor,
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(25.0),
                borderSide: BorderSide.none,
              ),
              enabledBorder: UnderlineInputBorder(
                borderSide: BorderSide.none,
                borderRadius: BorderRadius.circular(25.7),
              ),
              suffixIcon: new GestureDetector(
                onTap: () {
                  setState(() {
                    _obscureText = !_obscureText;
                  });
                },
                child: new Icon(
                    _obscureText ? Icons.visibility : Icons.visibility_off),
              ),
            ),
            onSaved: (String? value) {
              _password = value!;
              print(value);
            },
          ),
        ),
      ),
    ]);

    final loginButton = Padding(
      padding: EdgeInsets.all(10.0),
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(
          backgroundColor: btnBgColor,
          padding: EdgeInsets.only(
              left: ScreenUtil().setSp(50),
              right: ScreenUtil().setSp(50),
              top: ScreenUtil().setSp(5),
              bottom: ScreenUtil().setSp(5)),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(25.0),
          ),
        ),
        onPressed: () {
          if (Platform.isAndroid) {
            if (_permissionStatus != PermissionStatus.granted) {
              requestPermission(_permission);
            } else {
              apiCall();
            }
          } else {
            apiCall();
          }
        },
        child: Text('Login',
            style: TextStyle(color: Colors.white, fontFamily: font)),
      ),
    );

    return SafeArea(
       top: false,
        bottom: true,
      child: SafeArea(
        child: Scaffold(
          body: Stack(
            children: <Widget>[
              logo,
              Container(
                color: appPrimaryColor,
                child: ListView(
                  children: <Widget>[
                    Padding(
                      padding: EdgeInsets.all(0),
                      child: Form(
                        key: _formKey,
                        child: Column(
                          children: <Widget>[
                            Stack(
                              children: <Widget>[
                                SimpleHeader(),
                                Image.asset(
                                  'assets/image/logo_bg.png',
                                  width: MediaQuery.of(context).size.width,
                                  height: 250,
                                  fit: BoxFit.fill,
                                ),
                                Padding(
                                  padding: EdgeInsets.only(
                                      top: ScreenUtil().setSp(190),
                                      left: ScreenUtil().setSp(20),
                                      right: ScreenUtil().setSp(0)),
                                  child: Image.asset(
                                    'assets/image/login_ig.png',
                                    height: ScreenUtil().setSp(230.95),
                                    fit: BoxFit.fill,
                                  ),
                                ),
                              ],
                            ),
                            SizedBox(height: 30.0),
                            email,
                            SizedBox(height: 10.0),
                            password,
                            loginButton,
                            Container(
                              margin: EdgeInsets.only(left: 40, right: 40),
                              height: 50,
                              decoration: new BoxDecoration(
                                  color: Color.fromARGB(255, 230, 176, 132),
                                  borderRadius: new BorderRadius.circular(25)),
                              padding: EdgeInsets.all(5),
                              child: Row(
                                children: [
                                  otherLogin,
                                  Expanded(child: Text('')),
                                  forgotPassword,
                                  Expanded(child: Text('')),
                                ],
                              ),
                            ),
                            SizedBox(height: 50.0),
                          ],
                        ),
                      ),
                    ),
                    Align(
                      alignment: Alignment.center,
                      child: Container(
                        width: MediaQuery.of(context).size.width - 200,
                        padding: EdgeInsets.only(bottom: 30),
                        height: 3,
                        color: appWhiteColor,
                      ),
                    ),
                    SizedBox(height: 10.0),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  void dispose() {
    super.dispose();
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

  void saveData(Items items) async {
    final SharedPreferences prefs = await _prefs;
    prefs.setBool(
      SP_IS_LOGIN_BOOL,
      true,
    );
    prefs.setString(
      SP_API_TOKEN,
      items.tokenKey,
    );
    prefs.setString(
      SP_LAST_NAME,
      items.first_name,
    );
    prefs.setString(
      SP_EMAIL,
      items.email,
    );
    prefs.setString(
      SP_CONTACT_NO,
      items.contact_no,
    );
    prefs.setString(
      SP_PROFILE_IMAGE,
      items.profileImage,
    );
    prefs.setString(
      SP_COMPANY_NAME,
      items.company_name,
    );
    prefs.setString(
      LATITUDE,
      items.latitude,
    );
    prefs.setString(
      LONGITUDE,
      items.longitude,
    );
    prefs.setString(
      DEVICE_ID,
      _deviceId ?? "",
    );
    prefs.setInt(
      SP_ROLE,
      items.role_id,
    );
    prefs.setInt(
      SP_LOCATION_TRACKING,
      items.location_tracking,
    );
    prefs.setInt(
      SP_LOCATION_TRACKING_DURATION,
      items.location_tracking_duration,
    );
    prefs.setInt(
      SP_ATTENDANCE_SELFIE,
      items.attendance_selfie,
    );
    prefs.setInt(
      SP_ID,
      items.id,
    );
    prefs.setInt(
      SP_COMPANY_ID,
      items.company_id,
    );
    prefs.setInt(
      GEOFENCING,
      items.geofencing,
    );
    prefs.setInt(
      DISTANCE,
      items.distance,
    );
    prefs.setInt(
      TASK_MANAGER,
      items.task_manager,
    );
    prefs.setString(SP_COMPANY_LOGO, items.company_logo);
    prefs.setInt(SP_DRIVER, items.driver_delivery);
    prefs.setInt(APPROVE_TASK, (items.role_id < 5) ? 1 : 0);
    prefs.setInt(TEAM_LEAD_ID, items.team_lead_id);
    prefs.setString(SP_HELPLINE_NO, items.helpline_no);
    prefs.setInt(
        SP_BUFFER_LEAVE,
        (items.no_of_days_limit_for_leave == null)
            ? 30
            : items.no_of_days_limit_for_leave);
    prefs.setInt(
        SP_BUFFER_ATTENDANCE,
        (items.no_of_days_limit_for_mark_attendance == null)
            ? 4
            : items.no_of_days_limit_for_mark_attendance);
    syncAttendance(items);
  }

  void syncAttendance(Items items) async {
    DayAttendanceListApi? _dayAttendanceListApi;
    final SharedPreferences prefs = await _prefs;
    var map = new Map<String, dynamic>();
    map["appType"] = Platform.operatingSystem.toUpperCase();
    map["userId"] = '${items.id}';
    map["api_token"] = items.tokenKey;
    map['punchDate'] = DateFormat('yyyy-MM-dd').format(DateTime.now());
    _dayAttendanceListApi = null;
    print(map);
    showLoader(context);
    try {
      _networkUtil.post(apiAttendanceSingle, body: map).then((dynamic res) {
        try {
          Navigator.pop(context);
          AppLog.showLog(res.toString());
          _dayAttendanceListApi = DayAttendanceListApi.fromJson(res);
          if (_dayAttendanceListApi!.success) {
            if (_dayAttendanceListApi!.attendanceItems!.attendanceDetails.length >
                0) {
              List<AttendanceDetail> attendanceDetails =
                  _dayAttendanceListApi!.attendanceItems!.attendanceDetails;

              prefs.setString(SP_ATTENDANCE_DATE,
                  DateFormat('yyyy-MM-dd').format(DateTime.now()));
              int status = 0;
              for (int i = 0; i < attendanceDetails.length; i++) {
                if (i == 0) {
                  status = (attendanceDetails[i].endLatitude != null) ? 4 : 1;
                  prefs.setInt(SP_ATTENDANCE_ID, attendanceDetails[i].id!);
                  prefs.setString(
                      SP_ATTENDANCE_IN_TIME, attendanceDetails[i].inTime?? "");
                  prefs.setString(
                      SP_ATTENDANCE_IN_TIME_DATE, attendanceDetails[i].inTime ?? "");
                  prefs.setString(
                      SP_ATTENDANCE_OUT_TIME, attendanceDetails[i].outTime ?? "");
                  prefs.setString(SP_ATTENDANCE_OUT_TIME_DATE,
                      attendanceDetails[i].outTime ?? "");
                                } else {
                  if (status != 4) {
                    status =
                        (attendanceDetails[i].endLongitute != null) ? 3 : 2;
                  }
                  prefs.setInt(SP_ATTENDANCE_BREAK_ID, attendanceDetails[i].id!);
                }
              }
              prefs.setInt(SP_ATTENDANCE_STATUS, status);
            } else {
              prefs.setInt(SP_ATTENDANCE_STATUS, 0);
              prefs.setString(SP_ATTENDANCE_DATE,
                  DateFormat('yyyy-MM-dd').format(DateTime.now()));
              prefs.setString(SP_ATTENDANCE_IN_TIME, '');
              prefs.setString(SP_ATTENDANCE_IN_TIME_DATE, '');
              prefs.setString(SP_ATTENDANCE_OUT_TIME_DATE, '');
              prefs.setString(SP_ATTENDANCE_OUT_TIME, '');
              prefs.setString(SP_ATTENDANCE_ID, '');
              prefs.setString(SP_ATTENDANCE_BREAK_ID, '');
            }
          }
        } catch (es) {}
        Navigator.of(context).pushReplacement(new MaterialPageRoute(
            builder: (BuildContext context) => new DashboardPage(
                name: items.first_name ?? '',
                email: items.email ?? '',
                image: items.profileImage ?? '',
                projectVersion: PROJECT_VERSION)));
      });
    } catch (e) {
      Navigator.pop(context);
      Navigator.of(context).pushReplacement(new MaterialPageRoute(
          builder: (BuildContext context) => new DashboardPage(
              name: items.first_name ?? '',
              email: items.email ?? '',
              image: items.profileImage ?? '',
              projectVersion: PROJECT_VERSION)));
      setState(() {});
    }
  }

  void checkServiceStatus(BuildContext context, Permission permission) async {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      content: Text((await permission.status).toString()),
    ));
  }

  Future<void> requestPermission(Permission permission) async {
    final status = await permission.request();

    setState(() {
      print(status);
      _permissionStatus = status;
      if (_permissionStatus == PermissionStatus.permanentlyDenied &&
          Platform.isAndroid) {
        showDialog(
            context: context,
            builder: (BuildContext context) {
              return StatefulBuilder(builder: (context, setState) {
                return AlertDialog(
                  contentPadding: EdgeInsets.all(0),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.all(Radius.circular(20))),
                  content: Container(
                    decoration: new BoxDecoration(
                        borderRadius:
                            new BorderRadius.all(Radius.circular(20))),
                    padding: EdgeInsets.only(bottom: 10),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: <Widget>[
                        Container(
                            decoration: new BoxDecoration(
                                color: appPrimaryColor,
                                borderRadius: new BorderRadius.only(
                                    topLeft: Radius.circular(20),
                                    topRight: Radius.circular(20))),
                            padding: EdgeInsets.all(15),
                            child: Text(
                              'Permission',
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                  fontSize: 20,
                                  fontWeight: FontWeight.w400,
                                  color: Colors.white),
                            )),
                        Container(
                          padding: const EdgeInsets.only(top: 30, bottom: 20),
                          margin: EdgeInsets.only(left: 20, right: 20),
                          child: Text(
                            'Allow permission to download pdf file. Please enable it from the app setting.',
                            textAlign: TextAlign.center,
                          ),
                        ),
                        Row(
                          children: <Widget>[
                            Expanded(
                              child: Container(
                                  padding: EdgeInsets.only(left: 25, right: 25),
                                  decoration: BoxDecoration(
                                      borderRadius: BorderRadius.all(
                                          Radius.circular(20))),
                                  child: ElevatedButton(
                                    style: ElevatedButton.styleFrom(
                                        backgroundColor: Colors.green,
                                        textStyle:
                                            TextStyle(color: Colors.white),
                                        shape: RoundedRectangleBorder(
                                            borderRadius:
                                                BorderRadius.circular(20.0))),
                                    child: Text('Ok'),
                                    onPressed: () {
                                      setState(() {
                                        Navigator.pop(context);
                                      });
                                    },
                                  )),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                );
              });
            });
      
      }
      print(_permissionStatus);
    });
  }

  void _listenForPermissionStatus() async {
    final status = await _permission.status;
    setState(() => _permissionStatus = status);
  }
}

class LoginApiCallBack {
  String current_time;
  String current_utc_time;
  Items? items;
  String message;
  int status;
  bool success;
  int total_count;

  LoginApiCallBack(
      {required this.current_time,
     required this.current_utc_time,
     required this.items,
     required this.message,
     required this.status,
     required this.success,
     required this.total_count});

  factory LoginApiCallBack.fromJson(Map<String, dynamic> json) {
    return LoginApiCallBack(
      current_time: json['current_time'],
      current_utc_time: json['current_utc_time'],
      items: json['items'] != null ? Items.fromJson(json['items']) : null,
      message: json['message'],
      status: json['status'],
      success: json['success'],
      total_count: json['total_count'],
    );
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['current_time'] = this.current_time;
    data['current_utc_time'] = this.current_utc_time;
    data['message'] = this.message;
    data['status'] = this.status;
    data['success'] = this.success;
    data['total_count'] = this.total_count;
    data['items'] = this.items!.toJson();
      return data;
  }
}

class Items {
  int attendance_selfie;
  int company_id;
  String company_logo;
  String company_name;
  String contact_no;
  String deviceId;
  int distance;
  String email;
  String first_name;
  int gender;
  int geofencing;
  int id;
  int is_admin;
  int is_manager;
  int driver_delivery;
  String latitude;
  int location_tracking;
  int location_tracking_duration;
  String longitude;
  String profileImage;
  int role_id;
  int task_manager;
  int team_lead_id;
  String tokenKey;
  String helpline_no;
  int no_of_days_limit_for_mark_attendance;
  int no_of_days_limit_for_leave;

  Items({
    required this.attendance_selfie,
    required this.company_id,
    required this.company_logo,
    required this.company_name,
    required this.contact_no,
    required this.deviceId,
    required this.distance,
    required this.email,
    required this.first_name,
    required this.gender,
    required this.geofencing,
    required this.id,
    required this.is_admin,
    required this.is_manager,
    required this.driver_delivery,
    required this.latitude,
    required this.location_tracking,
    required this.location_tracking_duration,
    required this.longitude,
    required this.profileImage,
    required this.role_id,
    required this.task_manager,
    required this.team_lead_id,
    required this.tokenKey,
    required this.helpline_no,
    required this.no_of_days_limit_for_mark_attendance,
    required this.no_of_days_limit_for_leave,
  });

  factory Items.fromJson(Map<String, dynamic> json) {
    return Items(
      attendance_selfie: json['attendance_selfie'],
      company_id: json['company_id'],
      company_logo: json['company_logo'],
      company_name: json['company_name'],
      contact_no: json['contact_no'],
      deviceId: json['deviceId'],
      // distance: json['distance'],
      email: json['email'],
      first_name: json['first_name'],
      gender: json['gender'],
      geofencing: json['geofencing'],
      id: json['id'],
      is_admin: json['is_admin'],
      is_manager: json['is_manager'],
      driver_delivery: json['driver_delivery'],
      // latitude: json['latitude'],
      location_tracking: json['location_tracking'],
      location_tracking_duration: json['location_tracking_duration'],
      // longitude: json['longitude'],
      profileImage: json['profileImage'],
      role_id: json['role_id'],
      task_manager: json['task_manager'],
      // team_lead_id: json['team_lead_id'],
      tokenKey: json['tokenKey'],
      // helpline_no: json['helpline_no'],
      //Change by G1...
      //Change by G1...
      team_lead_id: json["team_lead_id"] == null ? 0 : json["team_lead_id"],
      helpline_no: json["helpline_no"] == null ? "" : json["helpline_no"],
      latitude: json["latitude"] == null ? "" : json["latitude"],
      longitude: json["longitude"] == null ? "" : json["longitude"],
      distance: json["distance"] == null ? 0 : json["distance"],

      no_of_days_limit_for_mark_attendance:
          json['no_of_days_limit_for_mark_attendance'],
      no_of_days_limit_for_leave: json['no_of_days_limit_for_leave'],
    );
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['attendance_selfie'] = this.attendance_selfie;
    data['company_id'] = this.company_id;
    data['company_logo'] = this.company_logo;
    data['company_name'] = this.company_name;
    data['contact_no'] = this.contact_no;
    data['deviceId'] = this.deviceId;
    data['distance'] = this.distance;
    data['email'] = this.email;
    data['first_name'] = this.first_name;
    data['gender'] = this.gender;
    data['geofencing'] = this.geofencing;
    data['id'] = this.id;
    data['is_admin'] = this.is_admin;
    data['is_manager'] = this.is_manager;
    data['driver_delivery'] = this.driver_delivery;
    data['latitude'] = this.latitude;
    data['location_tracking'] = this.location_tracking;
    data['location_tracking_duration'] = this.location_tracking_duration;
    data['longitude'] = this.longitude;
    data['profileImage'] = this.profileImage;
    data['role_id'] = this.role_id;
    data['task_manager'] = this.task_manager;
    data['team_lead_id'] = this.team_lead_id;
    data['tokenKey'] = this.tokenKey;
    data['helpline_no'] = this.helpline_no;
    // data['helpline_no'] == null ? null : this.helpline_no;

    data['no_of_days_limit_for_mark_attendance'] =
        this.no_of_days_limit_for_mark_attendance;
    data['no_of_days_limit_for_leave'] = this.no_of_days_limit_for_leave;

    return data;
  }
}

class NewLoginScreen extends StatefulWidget {
  NewLoginScreen({Key? key}) : super(key: key);

  @override
  _NewLoginScreenState createState() {
    return _NewLoginScreenState();
  }
}

class _NewLoginScreenState extends State<NewLoginScreen> {
  Future<SharedPreferences> _prefs = SharedPreferences.getInstance();
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  NetworkUtil _networkUtil = NetworkUtil();
  bool isLogin = false;
  bool _obscureText = true;
  String? _email, _password, _deviceId, _deviceName, _deviceManufacturer;
  DeviceInfoPlugin deviceInfo = DeviceInfoPlugin();
  bool _obscureTextVerify = true;

  void _toggle() {
    setState(() {
      _obscureText = !_obscureText;
    });
  }

  Future apiCall() async {
    if (_formKey.currentState!.validate()) {
      _formKey.currentState!.save();

      var map = new Map<String, dynamic>();
      map["appType"] = Platform.operatingSystem.toUpperCase();
      map["username"] = _email;
      map["password"] = _password;
      map["deviceId"] = _deviceId;
      map["flag"] = 'EmployeeCode';

      // map["fcmToken"] =
      //   'kjahdsklfhaklsfhklasjhflksdjhaflkjsdhlfkjhalkfjhklasdjfhks';
      map["deviceName"] = '';
      //_deviceName;
      map["deviceManufacturer"] = '';
      // _deviceManufacturer;
      print(map);
      try {
        showLoader(context);
        _networkUtil.post(apiLoginWithFlag, body: map).then((dynamic res) {
          Navigator.pop(context);
          try {
            AppLog.showLog(res.toString());
            LoginApiCallBack loginApiCallBack = LoginApiCallBack.fromJson(res);
            if (loginApiCallBack.status == unAuthorised) {
              logout();
            }
            if (loginApiCallBack.success) {
              showBottomToast(loginApiCallBack.message);
              if (loginApiCallBack.items != null) {
                saveData(loginApiCallBack.items!);
              }
            } else {
              showBottomToast(loginApiCallBack.message);
            }
          } catch (es) {
            showErrorLog(es.toString());
            showBottomToast(res['message']);
          }
        });
      } catch (e) {
        Navigator.pop(context);
        showErrorLog(e.toString());
        showCenterToast(errorApiCall);
      }
    }
  }

  Future<Null> _isLogin() async {
    final SharedPreferences prefs = await _prefs;
    isLogin = (prefs.getBool(SP_IS_LOGIN_BOOL) != null)
        ? prefs.getBool(SP_IS_LOGIN_BOOL)!
        : false;
    if (!isLogin) {
      prefs.setBool(SP_IS_LOGIN_BOOL, false);
    }
  }

  void getDeviceInfo() async {
    if (Platform.isAndroid) {
      AndroidDeviceInfo androidInfo = await deviceInfo.androidInfo;
       _deviceId = androidInfo.id;
      _deviceName = androidInfo.brand;
      _deviceManufacturer = androidInfo.manufacturer;
      print('Running on ${androidInfo.model}');
    } else if (Platform.isIOS) {
      IosDeviceInfo iosInfo = await deviceInfo.iosInfo;
      _deviceId = iosInfo.identifierForVendor!;
      _deviceName = iosInfo.name;
      _deviceManufacturer = iosInfo.name;
      print('Running on ${iosInfo.name}');
    }
  }

  @override
  void initState() {
    super.initState();
    getDeviceInfo();
    _isLogin();
  }

  Future<void> saveLoginData() async {
    final SharedPreferences prefs = await _prefs;
    prefs.setBool(SP_IS_LOGIN_BOOL, true);
  }

  @override
  Widget build(BuildContext context) {
    //2,436 x 1,125

    final forgotPassword = Hero(
      tag: 'forgotPassword',
      child: GestureDetector(
        child: Text(
          'Forgot Password',
          style: TextStyle(
            color: tfBackgroundColor,
            fontSize: 13.0,
            fontFamily: 'Montserrat',
            // decoration: TextDecoration.underline,
          ),
        ),
        onTap: () {
          Navigator.of(context).push(new MaterialPageRoute(
              builder: (BuildContext context) => ForgotPassword()));
        },
      ),
    );

    final back = Hero(
      tag: 'back',
      child: GestureDetector(
        child: Container(
          height: 40,
          padding: EdgeInsets.only(top: 13, left: 20, right: 20),
          decoration: new BoxDecoration(
              color: appWhiteColor,
              borderRadius: new BorderRadius.circular(25)),
          child: Text(
            'Login with email',
            style: TextStyle(
              fontSize: 13.0,
              fontFamily: 'Montserrat',
              // decoration: TextDecoration.underline,
            ),
          ),
        ),
        onTap: () {
          Navigator.pop(context);
        },
      ),
    );

    final logo = Hero(
      tag: 'hero',
      child: Image.asset(
        'assets/image/aipex_logo.png',
        height: ScreenUtil().setSp(90),
        width: ScreenUtil().setSp(180),
      ),
    );

    final email = Row(children: <Widget>[
      new Expanded(
        child: Padding(
          padding: EdgeInsets.only(
              left: ScreenUtil().setSp(40), right: ScreenUtil().setSp(40)),
          child: TextFormField(
            autocorrect: true,
            keyboardType: TextInputType.text,
            autofocus: false,
            validator: (val) {
              if (val!.isEmpty) {
                return 'Employee code is required';
              }
              return null;
            },
            style: TextStyle(
              fontFamily: font,
            ),
            decoration: InputDecoration(
              hintText: '   Employee Code',
              filled: true,
              fillColor: tfBackgroundColor,
              contentPadding: EdgeInsets.fromLTRB(10.0, 5.0, 10.0, 5.0),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(25.0),
                borderSide: BorderSide.none,
              ),
              enabledBorder: UnderlineInputBorder(
                borderSide: BorderSide.none,
                borderRadius: BorderRadius.circular(25.7),
              ),
            ),
            onSaved: (String? value) {
              _email = value!.trim();
              print(value);
            },
          ),
        ),
      ),
    ]);

    final password = Row(children: <Widget>[
      new Expanded(
        child: Padding(
          padding: EdgeInsets.only(
              left: ScreenUtil().setSp(40), right: ScreenUtil().setSp(40)),
          child: TextFormField(
            autocorrect: true,
            keyboardType: TextInputType.visiblePassword,
            autofocus: false,
            validator: (val) {
              if (val!.isEmpty) {
                return 'Password is required';
              }
              return null;
            },
            obscureText: _obscureText,
            style: TextStyle(
              fontFamily: font,
            ),
            decoration: InputDecoration(
              contentPadding: EdgeInsets.only(
                  left: 20.0, right: 20.0, bottom: 2.0, top: 15.0),
              hintText: ' Password',
              filled: true,
              fillColor: tfBackgroundColor,
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(25.0),
                borderSide: BorderSide.none,
              ),
              enabledBorder: UnderlineInputBorder(
                borderSide: BorderSide.none,
                borderRadius: BorderRadius.circular(25.7),
              ),
              suffixIcon: new GestureDetector(
                onTap: () {
                  setState(() {
                    _obscureText = !_obscureText;
                  });
                },
                child: new Icon(
                    _obscureText ? Icons.visibility : Icons.visibility_off),
              ),
            ),
            onSaved: (String? value) {
              _password = value!;
              print(value);
            },
          ),
        ),
      ),
    ]);

    final loginButton = Padding(
      padding: EdgeInsets.all(10.0),
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(
          backgroundColor: btnBgColor,
          padding: EdgeInsets.only(
              left: ScreenUtil().setSp(50),
              right: ScreenUtil().setSp(50),
              top: ScreenUtil().setSp(5),
              bottom: ScreenUtil().setSp(5)),
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(25.0)),
        ),
        onPressed: () {
          apiCall();
        },
        child: Text('Login',
            style: TextStyle(color: Colors.white, fontFamily: font)),
      ),
    );

    return SafeArea(
      child: Scaffold(
        body: Stack(
          children: <Widget>[
            Container(
              color: appPrimaryColor,
              child: ListView(
                children: <Widget>[
                  Padding(
                    padding: EdgeInsets.all(0),
                    child: Form(
                      key: _formKey,
                      child: Column(
                        children: <Widget>[
                          Stack(
                            children: <Widget>[
                              SimpleHeader(),
                              Image.asset(
                                'assets/image/logo_bg.png',
                                width: MediaQuery.of(context).size.width,
                                height: 250,
                                fit: BoxFit.fill,
                              ),
                              Padding(
                                padding: EdgeInsets.only(
                                    top: ScreenUtil().setSp(190),
                                    left: ScreenUtil().setSp(20),
                                    right: ScreenUtil().setSp(0)),
                                child: Image.asset(
                                  'assets/image/login_ig.png',
                                  height: ScreenUtil().setSp(230.95),
                                  fit: BoxFit.fill,
                                ),
                              ),
                            ],
                          ),
                          SizedBox(height: 30.0),
                          email,
                          SizedBox(height: 10.0),
                          password,
                          loginButton,
                          // forgotPassword,
                          // SizedBox(height: 20.0),
                          // back
                          Container(
                            margin: EdgeInsets.only(left: 40, right: 40),
                            height: 50,
                            decoration: new BoxDecoration(
                                color: Color.fromARGB(255, 230, 176, 132),
                                borderRadius: new BorderRadius.circular(25)),
                            padding: EdgeInsets.all(5),
                            child: Row(
                              children: [
                                back,
                                Expanded(child: Text('')),
                                forgotPassword,
                                Expanded(child: Text('')),
                              ],
                            ),
                          ),
                          SizedBox(height: 50.0),
                        ],
                      ),
                    ),
                  ),
                  Align(
                    alignment: Alignment.center,
                    child: Container(
                      width: MediaQuery.of(context).size.width - 200,
                      padding: EdgeInsets.only(bottom: 30),
                      height: 3,
                      color: appWhiteColor,
                    ),
                  ),
                  SizedBox(height: 10.0),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  void dispose() {
    super.dispose();
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

  void saveData(Items items) async {
    final SharedPreferences prefs = await _prefs;
    prefs.setBool(
      SP_IS_LOGIN_BOOL,
      true,
    );
    prefs.setString(
      SP_API_TOKEN,
      items.tokenKey,
    );
    prefs.setString(
      SP_LAST_NAME,
      items.first_name,
    );
    prefs.setString(
      SP_EMAIL,
      items.email,
    );
    prefs.setString(
      SP_CONTACT_NO,
      items.contact_no,
    );
    prefs.setString(
      SP_PROFILE_IMAGE,
      items.profileImage,
    );
    prefs.setString(
      SP_COMPANY_NAME,
      items.company_name,
    );
    prefs.setString(
      LATITUDE,
      items.latitude,
    );
    prefs.setString(
      LONGITUDE,
      items.longitude,
    );
    prefs.setString(
      DEVICE_ID,
      _deviceId ?? "",
    );
    prefs.setInt(
      SP_ROLE,
      items.role_id,
    );
    prefs.setInt(
      SP_LOCATION_TRACKING,
      items.location_tracking,
    );
    prefs.setInt(
      SP_LOCATION_TRACKING_DURATION,
      items.location_tracking_duration,
    );
    prefs.setInt(
      SP_ATTENDANCE_SELFIE,
      items.attendance_selfie,
    );
    prefs.setInt(
      SP_ID,
      items.id,
    );
    prefs.setInt(
      SP_COMPANY_ID,
      items.company_id,
    );
    prefs.setInt(
      GEOFENCING,
      items.geofencing,
    );
    prefs.setInt(
      DISTANCE,
      items.distance,
    );
    prefs.setInt(
      TASK_MANAGER,
      items.task_manager,
    );
    prefs.setString(SP_COMPANY_LOGO, items.company_logo);
    prefs.setInt(SP_DRIVER, items.driver_delivery);
    prefs.setInt(APPROVE_TASK, (items.role_id < 5) ? 1 : 0);
    prefs.setInt(TEAM_LEAD_ID, items.team_lead_id);
    prefs.setString(SP_HELPLINE_NO, items.helpline_no);
    prefs.setInt(
        SP_BUFFER_LEAVE,
        (items.no_of_days_limit_for_leave == null)
            ? 30
            : items.no_of_days_limit_for_leave);
    prefs.setInt(
        SP_BUFFER_ATTENDANCE,
        (items.no_of_days_limit_for_mark_attendance == null)
            ? 4
            : items.no_of_days_limit_for_mark_attendance);

    syncAttendance(items);
  }

  void syncAttendance(Items items) async {
    DayAttendanceListApi? _dayAttendanceListApi;
    final SharedPreferences prefs = await _prefs;
    var map = new Map<String, dynamic>();
    map["appType"] = Platform.operatingSystem.toUpperCase();
    map["userId"] = '${items.id}';
    map["api_token"] = items.tokenKey;
    map['punchDate'] = DateFormat('yyyy-MM-dd').format(DateTime.now());
    _dayAttendanceListApi = null;
    print(map);
    showLoader(context);
    try {
      _networkUtil.post(apiAttendanceSingle, body: map).then((dynamic res) {
        try {
          Navigator.pop(context);
          AppLog.showLog(res.toString());
          _dayAttendanceListApi = DayAttendanceListApi.fromJson(res);
          if (_dayAttendanceListApi!.success) {
            if (_dayAttendanceListApi!.attendanceItems!.attendanceDetails.length >
                0) {
              List<AttendanceDetail> attendanceDetails =
                  _dayAttendanceListApi!.attendanceItems!.attendanceDetails;

              prefs.setString(SP_ATTENDANCE_DATE,
                  DateFormat('yyyy-MM-dd').format(DateTime.now()));
              int status = 0;
              for (int i = 0; i < attendanceDetails.length; i++) {
                if (i == 0) {
                  status = (attendanceDetails[i].endLatitude != null) ? 4 : 1;
                  prefs.setInt(SP_ATTENDANCE_ID, attendanceDetails[i].id!);
                  prefs.setString(
                      SP_ATTENDANCE_IN_TIME, attendanceDetails[i].inTime ?? "");
                  prefs.setString(
                      SP_ATTENDANCE_IN_TIME_DATE, attendanceDetails[i].inTime ?? "");
                  prefs.setString(
                      SP_ATTENDANCE_OUT_TIME, attendanceDetails[i].outTime ?? "");
                  prefs.setString(SP_ATTENDANCE_OUT_TIME_DATE,
                      attendanceDetails[i].outTime ?? "");
                                } else {
                  if (status != 4) {
                    status =
                        (attendanceDetails[i].endLongitute != null) ? 3 : 2;
                  }
                  prefs.setInt(SP_ATTENDANCE_BREAK_ID, attendanceDetails[i].id!);
                }
              }
              prefs.setInt(SP_ATTENDANCE_STATUS, status);
            } else {
              prefs.setInt(SP_ATTENDANCE_STATUS, 0);
              prefs.setString(SP_ATTENDANCE_DATE,
                  DateFormat('yyyy-MM-dd').format(DateTime.now()));
              prefs.setString(SP_ATTENDANCE_IN_TIME, '');
              prefs.setString(SP_ATTENDANCE_IN_TIME_DATE, '');
              prefs.setString(SP_ATTENDANCE_OUT_TIME_DATE, '');
              prefs.setString(SP_ATTENDANCE_OUT_TIME, '');
              prefs.setString(SP_ATTENDANCE_ID, '');
              prefs.setString(SP_ATTENDANCE_BREAK_ID, '');
            }
          }
        } catch (es) {}
        Navigator.of(context).pushReplacement(new MaterialPageRoute(
            builder: (BuildContext context) => new DashboardPage(
                name: items.first_name ?? '',
                email: items.email ?? '',
                image: items.profileImage ?? '',
                projectVersion: PROJECT_VERSION)));
      });
    } catch (e) {
      Navigator.pop(context);
      Navigator.of(context).pushReplacement(new MaterialPageRoute(
          builder: (BuildContext context) => new DashboardPage(
              name: items.first_name ?? '',
              email: items.email ?? '',
              image: items.profileImage ?? '',
              projectVersion: PROJECT_VERSION)));
      setState(() {});
    }
  }
}
