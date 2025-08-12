import 'dart:async';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:hrms/app/mainApp/setting/change_password.dart';
import 'package:hrms/app/uiComponent/custom_header.dart';
import 'package:hrms/appUtil/app_util_config.dart';
import 'package:hrms/appUtil/network_util.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:shared_preferences/shared_preferences.dart';
// import 'package:get_version/get_version.dart';
import 'package:url_launcher/url_launcher.dart';

class AppSetting extends StatefulWidget {
  var scaffoldKey;
  var title;

  AppSetting({Key? key, @required this.scaffoldKey, @required this.title})
      : super(key: key);

  @override
  _AppSettingState createState() {
    return _AppSettingState();
  }
}

class _AppSettingState extends State<AppSetting> {
  NetworkUtil _networkUtil = NetworkUtil();
  Future<SharedPreferences> _prefs = SharedPreferences.getInstance();
  UserCallBack? _userCallBack;
  Items? _items;
  String? apiToken;
 late int userId;
  bool isNotification = true;
  bool isSync = true;
  var _noDataFound = 'Loading...';
  String _projectVersion = '', _helpline = '';
  int companyId = 0;

  @override
  void initState() {
    super.initState();
    getSpData();
    apiCallForGetUser();
    getMyAppVersion();
  }

  @override
  void dispose() {
    super.dispose();
  }

  Future getSpData() async {
    final SharedPreferences prefs = await _prefs;
    if (prefs.getBool(SP_IS_LOGIN_BOOL) != null) {
      _helpline = prefs.getString(SP_HELPLINE_NO)!;
    }
  }

  Future apiCallForGetUser() async {
    final SharedPreferences prefs = await _prefs;
    if (prefs.getBool(SP_IS_LOGIN_BOOL) != null) {
       userId = prefs.getInt(SP_ID)!;
      apiToken = prefs.getString(SP_API_TOKEN)!;
      companyId = prefs.getInt(SP_COMPANY_ID)!;
    }
    var map = new Map<String, dynamic>();
    map["appType"] = Platform.operatingSystem.toUpperCase();
    map["userId"] = userId.toString();
    map["api_token"] = apiToken;
    print(map);
    try {
      _noDataFound = 'Loading...';
      _networkUtil.post(apiUserInformation, body: map).then((dynamic res) {
        _noDataFound = noDataFound;
        try {
          AppLog.showLog(res.toString());

          _userCallBack = UserCallBack.fromJson(res);
          _items = _userCallBack!.items;
          if (_userCallBack!.status == unAuthorised) {
            logout(context);
          } else if (!_userCallBack!.success) {
            showBottomToast(_userCallBack!.message ?? "");
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
  Widget build(BuildContext context) {
    return SafeArea(
       top: false,
        bottom: true,
      child: Container(
        color: appBackgroundDashboard,
        child: Stack(
          children: <Widget>[
            CustomHeader(scaffoldKey: widget.scaffoldKey, title: widget.title),
            (_userCallBack != null)
                ? Padding(
                    padding: EdgeInsets.only(top: ScreenUtil().setSp(120)),
                    child: ListView(
                      children: <Widget>[
                        profileCard(),
                        settingCard(),
                        helpLineCard(),
                      ],
                    ),
                  )
                : Container(
                    child: Center(
                      child: Text(_noDataFound),
                      //new CircularProgressIndicator(),
                    ),
                  ),
          ],
        ),
      ),
    );
  }

  Widget profileCard() {
    return Padding(
      padding: EdgeInsets.only(
          left: ScreenUtil().setSp(15),
          top: ScreenUtil().setSp(10),
          right: ScreenUtil().setSp(10)),
      child: Stack(
        children: <Widget>[
          Container(
            width: double.infinity,
            margin: const EdgeInsets.only(top: 90.0),
            child: Card(
              elevation: 5,
              child: Column(
                children: <Widget>[
                  // SizedBox(
                  //   height: ScreenUtil().setSp(15),
                  // ),
                  //
                  // SizedBox(
                  //   height: ScreenUtil().setSp(20),
                  // ),
                  // Row(
                  //   children: [
                  //     Expanded(child: Text("")),
                  //     IconButton(
                  //       icon: const Icon(Icons.edit),
                  //       color: Colors.orange,
                  //       onPressed: () async {
                  //         Map results =
                  //             await Navigator.of(context).push( MaterialPageRoute(
                  //           builder: (BuildContext context) {
                  //             return EditProfile(
                  //               scaffoldKey: widget.scaffoldKey,
                  //               title: 'Edit Profile',
                  //               url: "http://aipex.co/hrmsfe_latest/#/employee/addemployee;id="+userId.toString()+"companyId="+companyId.toString(),
                  //               // url: 'https://flutter.dev/?gclid=Cj0KCQiAosmPBhCPARIsAHOen-P3rTKk1ykN6PA04qhVCY8ga3QUzfgJOgiqAiq9In0LgDwQqsYNuyEaAswhEALw_wcB&gclsrc=aw.ds',
                  //             );
                  //           },
                  //         ));
                  //         // launch("http://aipex.co/hrmsfe_latest/#/employee/addemployee;id="+userId.toString()+"companyId="+companyId.toString());
                  //         // print ("http://aipex.co/hrmsfe_latest/#/employee/addemployee;id="+userId.toString()+"companyId="+companyId.toString());
                  //       },
                  //     ),
                  //   ],
                  // ),
                  Text(_items!.firstName ?? "",
                      style: TextStyle(
                          fontSize: ScreenUtil().setSp(15),
                          fontWeight: FontWeight.bold)),
                  SizedBox(
                    height: ScreenUtil().setSp(10),
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: <Widget>[
                      Icon(
                        Icons.email,
                        color: Colors.blue,
                        size: ScreenUtil().setSp(15),
                      ),
                      SizedBox(
                        width: ScreenUtil().setSp(10),
                      ),
                      Text(_items!.email ?? ""),
                    ],
                  ),
                  SizedBox(
                    height: ScreenUtil().setSp(10),
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: <Widget>[
                      Icon(
                        Icons.call,
                        color: Colors.blue,
                        size: ScreenUtil().setSp(15),
                      ),
                      SizedBox(
                        width: ScreenUtil().setSp(10),
                      ),
                      Text(_items!.contactNo),
                    ],
                  ),
                  SizedBox(
                    height: ScreenUtil().setSp(15),
                  ),
                ],
              ),
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10.0)),
            ),
          ),
          Center(
            child: Container(
              height: 120,
              width: 120,
              decoration: new BoxDecoration(
                  borderRadius: new BorderRadius.circular(60),
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [appWhiteColor, appWhiteColor],
                  )),
              child: Padding(
                padding: const EdgeInsets.all(4.0),
                child: Container(
                  height: 116,
                  width: 116,
                  decoration: new BoxDecoration(
                    borderRadius: new BorderRadius.circular(58),
                  ),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(58.0),
                    child: FadeInImage.assetNetwork(
                      placeholder: 'assets/image/aipex_logo.png',
                      image: _userCallBack!.items!.profileImage ?? "",
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget settingCard() {
    return Padding(
      padding: EdgeInsets.only(
          left: ScreenUtil().setSp(15),
          top: ScreenUtil().setSp(10),
          right: ScreenUtil().setSp(10)),
      child: Card(
        elevation: 5,
        child: Column(
          children: <Widget>[
            Padding(
              padding: EdgeInsets.only(
                  left: ScreenUtil().setSp(15),
                  top: ScreenUtil().setSp(10),
                  right: ScreenUtil().setSp(10)),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: <Widget>[
                  Text(
                    'Notification',
                    style: TextStyle(
                        fontSize: ScreenUtil().setSp(15),
                        fontWeight: FontWeight.bold),
                    textAlign: TextAlign.left,
                  ),
                  Switch(
                    value: isNotification,
                    onChanged: (value) {
                      setState(() {
                        isNotification = value;
                      });
                    },
                    activeTrackColor: Colors.lightGreen[300],
                    activeColor: appAccentColor,
                  ),
                ],
              ),
            ),
            Padding(
              padding: EdgeInsets.only(
                  left: ScreenUtil().setSp(15), right: ScreenUtil().setSp(10)),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: <Widget>[
                  Text(
                    'Sync App in background',
                    style: TextStyle(
                        fontSize: ScreenUtil().setSp(15),
                        fontWeight: FontWeight.bold),
                    textAlign: TextAlign.left,
                  ),
                  Switch(
                    value: isSync,
                    onChanged: (value) {
                      setState(() {
                        isSync = value;
                      });
                    },
                    activeTrackColor: Colors.lightGreen[300],
                    activeColor: appAccentColor,
                  ),
                ],
              ),
            ),
            Padding(
              padding: EdgeInsets.only(right: ScreenUtil().setSp(10)),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: <Widget>[
                  MaterialButton(
                         elevation: 0,
                    child: Text(
                      'Change Password',
                       style: TextStyle(
                        color: Colors.black,
                        fontSize: ScreenUtil().setSp(15),
                        fontWeight: FontWeight.bold),
                      textAlign: TextAlign.left,
                    ),
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) => ChangePassword(
                                  scaffoldKey: widget.scaffoldKey,
                                  title: 'Change Password',
                                )),
                      );
                    },
                  ),
                  Text('')
                ],
              ),
            ),
            Padding(
              padding: EdgeInsets.only(right: ScreenUtil().setSp(10)),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: <Widget>[
                  MaterialButton(
                    elevation: 0,
                    child: Text(
                      'Logout',
                       style: TextStyle(
                        color: Colors.black,
                        fontSize: ScreenUtil().setSp(15),
                        fontWeight: FontWeight.bold),
                      textAlign: TextAlign.left,
                    ),
                    onPressed: () {
                      showAlert();
                    },
                  ),
                  Text('')
                ],
              ),
            ),
            Padding(
              padding: EdgeInsets.only(
                  left: ScreenUtil().setSp(15),
                  top: ScreenUtil().setSp(10),
                  right: ScreenUtil().setSp(10),
                  bottom: ScreenUtil().setSp(20)),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: <Widget>[
                  Text(
                    'App Version ${_projectVersion}',
                    style: TextStyle(
                        fontSize: ScreenUtil().setSp(15),
                        fontWeight: FontWeight.bold,
                        color: appAccentColor),
                    textAlign: TextAlign.left,
                  ),
                  Text('')
                ],
              ),
            ),
          ],
        ),
        shape:
            RoundedRectangleBorder(borderRadius: BorderRadius.circular(10.0)),
      ),
    );
  }

  Widget helpLineCard() {
    return Padding(
      padding: EdgeInsets.only(
          left: ScreenUtil().setSp(15),
          top: ScreenUtil().setSp(10),
          right: ScreenUtil().setSp(10)),
      child: Card(
        elevation: 5,
        child: Column(
          children: <Widget>[
            Padding(
              padding: EdgeInsets.only(
                  left: ScreenUtil().setSp(15),
                  top: ScreenUtil().setSp(10),
                  right: ScreenUtil().setSp(10)),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: <Widget>[
                  Text(
                    'HelpLine : ',
                    style: TextStyle(
                        fontSize: ScreenUtil().setSp(15),
                        fontWeight: FontWeight.bold),
                    textAlign: TextAlign.left,
                  ),
                  ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: btnBgColor,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(25.0),
                        ),
                      ),
                      // style: ElevatedButton.styleFrom(
                      //     backgroundColor: Colors.grey[200]),
                      onPressed: () => launch("tel://$_helpline"),
                      child: Row(
                        children: <Widget>[
                          Icon(
                            Icons.call,
                            color: appWhiteColor,
                            size: 20,
                          ),
                          SizedBox(
                            width: 10,
                          ),
                          new Text(
                            _helpline,
                            style: TextStyle(
                                decoration: TextDecoration.underline,
                                color: Colors.blue),
                          ),
                        ],
                      )),
                ],
              ),
            ),
          ],
        ),
        shape:
            RoundedRectangleBorder(borderRadius: BorderRadius.circular(10.0)),
      ),
    );
  }

  void showAlert() {
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
                padding: EdgeInsets.only(bottom: ScreenUtil().setSp(10)),
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
                        child: Text(
                          'Logout',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                              fontSize: ScreenUtil().setSp(16),
                              fontWeight: FontWeight.bold,
                              color: appWhiteColor),
                        )),
                    Padding(
                      padding: EdgeInsets.only(
                          left: ScreenUtil().setSp(20),
                          top: ScreenUtil().setSp(20)),
                      child: Text('Are you sure want to logout?'),
                    ),
                  ],
                ),
              ),
              actions: <Widget>[
                ElevatedButton(
                  child: new Text(
                    "CANCEL",
                    style: TextStyle(color: chartRed),
                  ),
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                ),
                ElevatedButton(
                  child: new Text(
                    "YES, LOGOUT",
                    style: TextStyle(color: chartRed),
                  ),
                  onPressed: () {
                    logout(context);
                  },
                ),
              ],
            );
          });
        });
  }

  void getMyAppVersion() async {
    // try {
    //   _projectVersion = await GetVersion.projectVersion;
    // } on PlatformException {
    //   _projectVersion = PROJECT_VERSION;
    // }
    //Change by G1...
    PackageInfo.fromPlatform().then((PackageInfo packageInfo) {
      _projectVersion = packageInfo.version;
    });
  }
}

class UserCallBack {
  late int totalCount;
 late bool success;
 late Items? items;
 String? message;
late  int status;

  UserCallBack(
      {required this.totalCount, required this.success, required this.items, required this.message, required this.status});

  UserCallBack.fromJson(Map<String, dynamic> json) {
    totalCount = json['total_count'];
    success = json['success'];
    items = json['items'] != null ? new Items.fromJson(json['items']) : null;
    message = json['message'];
    status = json['status'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['total_count'] = this.totalCount;
    data['success'] = this.success;
    data['items'] = this.items!.toJson();
      data['message'] = this.message;
    data['status'] = this.status;
    return data;
  }
}

class Items {
 late int id;
 String? firstName;
 late int companyId;
 late int roleId;
 late int isAdmin;
 late int isManager;
 String? email;
 late int gender;
late  String contactNo;
 String? profileImage;
 String? tokenKey;
 String? deviceId;
 late int locationTrackingDuration;
 String? companyLogo;
 String? companyName;
 late int locationTracking;
 late int attendanceSelfie;

  Items(
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
     required this.companyLogo,
    required  this.companyName,
     required this.locationTracking,
    required  this.attendanceSelfie});

  Items.fromJson(Map<String, dynamic> json) {
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
    companyLogo = json['company_logo'];
    companyName = json['company_name'];
    locationTracking = json['location_tracking'];
    attendanceSelfie = json['attendance_selfie'];
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
    data['company_logo'] = this.companyLogo;
    data['company_name'] = this.companyName;
    data['location_tracking'] = this.locationTracking;
    data['attendance_selfie'] = this.attendanceSelfie;
    return data;
  }
}
