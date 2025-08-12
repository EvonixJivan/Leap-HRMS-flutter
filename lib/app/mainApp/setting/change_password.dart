import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:hrms/app/uiComponent/custom_header.dart';
import 'package:hrms/appUtil/app_util_config.dart';
import 'package:hrms/appUtil/network_util.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ChangePassword extends StatefulWidget {
  var scaffoldKey;
  var title;

  ChangePassword({Key? key, required this.scaffoldKey, required this.title})
      : super(key: key);

  @override
  _ChangePasswordState createState() {
    return _ChangePasswordState();
  }
}

class _ChangePasswordState extends State<ChangePassword> {
  NetworkUtil _networkUtil = NetworkUtil();
  Future<SharedPreferences> _prefs = SharedPreferences.getInstance();
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  TextEditingController newPassword = TextEditingController();
  ChangePasswordCallBack? _changePasswordCallBack;
 String? apiToken, email, _newPassword;
  bool _obscureText = true;
  bool _obscureTextVerify = true;

  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    super.dispose();
  }

  Future apiCallForChangePassword() async {
    final SharedPreferences prefs = await _prefs;
    if (_formKey.currentState!.validate()) {
      _formKey.currentState!.save();
      if (prefs.getBool(SP_IS_LOGIN_BOOL) != null) {
        apiToken = prefs.getString(SP_API_TOKEN)!;
        email = prefs.getString(SP_EMAIL)!;
      }
      var map = new Map<String, dynamic>();
      map["appType"] = Platform.operatingSystem.toUpperCase();
      map['email'] = email;
      map["api_token"] = apiToken;
      map['newPassword'] = _newPassword;
      print(map);
      try {
        showLoader(context);
        _networkUtil.post(apiResetPassword, body: map).then((dynamic res) {
          Navigator.pop(context);
          try {
            AppLog.showLog(res.toString());
            _changePasswordCallBack = ChangePasswordCallBack.fromJson(res);
            if (_changePasswordCallBack!.status == unAuthorised) {
              logout(context);
            }
            if (_changePasswordCallBack!.success) {
              Navigator.pop(context);
              showBottomToast(_changePasswordCallBack!.message ?? "");
            } else {
              showBottomToast(_changePasswordCallBack!.message ?? "");
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
    }
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
       top: false,
        bottom: true,
      child: Scaffold(
        body: Stack(children: <Widget>[
          CustomHeaderWithBack(
              scaffoldKey: widget.scaffoldKey, title: widget.title),
          Padding(
            padding: EdgeInsets.only(
                left: ScreenUtil().setSp(15),
                top: ScreenUtil().setSp(10),
                right: ScreenUtil().setSp(10)),
            child: Card(
              elevation: 5,
              margin: EdgeInsets.only(
                left: ScreenUtil().setSp(20),
                right: ScreenUtil().setSp(20),
                top: ScreenUtil().setSp(200),
              ),
              child: Form(
                key: _formKey,
                child: ListView(
                  shrinkWrap: true,
                  physics: NeverScrollableScrollPhysics(),
                  children: <Widget>[
                    Padding(
                      padding: EdgeInsets.only(
                          left: ScreenUtil().setSp(10),
                          top: ScreenUtil().setSp(10),
                          right: ScreenUtil().setSp(10)),
                      child: Container(
                          padding: EdgeInsets.all(5),
                          decoration: BoxDecoration(
                            color: Colors.grey[100],
                            border: Border.all(width: 1, color: Colors.grey),
                            borderRadius: BorderRadius.circular(3),
                          ),
                          child: TextFormField(
                            controller: newPassword,
                            validator: (value) {
                              if (value!.isEmpty) {
                                return 'New Password is required';
                              }
                              return null;
                            },
                            onSaved: (String? value) {
                              _newPassword = value!;
                            },
                            obscureText: _obscureText,
                            decoration: InputDecoration(
                              border: InputBorder.none,
                              hintText: 'New Password',
                              prefixIcon: Icon(
                                Icons.lock,
                                color: Colors.black,
                              ),
                              suffixIcon: new GestureDetector(
                                onTap: () {
                                  setState(() {
                                    _obscureText = !_obscureText;
                                  });
                                },
                                child: new Icon(_obscureText
                                    ? Icons.visibility
                                    : Icons.visibility_off),
                              ),
                            ),
                          )),
                    ),
                    SizedBox(
                      height: ScreenUtil().setSp(10),
                    ),
                    Padding(
                      padding: EdgeInsets.only(
                          left: ScreenUtil().setSp(10),
                          top: ScreenUtil().setSp(10),
                          right: ScreenUtil().setSp(10)),
                      child: Container(
                          padding: EdgeInsets.all(5),
                          decoration: BoxDecoration(
                            color: Colors.grey[100],
                            border: Border.all(width: 1, color: Colors.grey),
                            borderRadius: BorderRadius.circular(3),
                          ),
                          child: TextFormField(
                            validator: (value) {
                              if (value != newPassword.text) {
                                return 'Password is not matching';
                              }
                              return null;
                            },
                            obscureText: _obscureTextVerify,
                            decoration: InputDecoration(
                              border: InputBorder.none,
                              hintText: 'Verify Password',
                              prefixIcon: Icon(
                                Icons.lock,
                                color: Colors.black,
                              ),
                              suffixIcon: new GestureDetector(
                                onTap: () {
                                  setState(() {
                                    _obscureTextVerify = !_obscureTextVerify;
                                  });
                                },
                                child: new Icon(_obscureTextVerify
                                    ? Icons.visibility
                                    : Icons.visibility_off),
                              ),
                            ),
                          )),
                    ),
                    SizedBox(
                      height: ScreenUtil().setSp(10),
                    ),
                    Padding(
                      padding: EdgeInsets.only(
                          left: ScreenUtil().setSp(10),
                          top: ScreenUtil().setSp(10),
                          right: ScreenUtil().setSp(10),
                          bottom: ScreenUtil().setSp(15)),
                      child: ElevatedButton(
                        // style: ElevatedButton.styleFrom(
                        //     elevation: 2,
                        //     backgroundColor: appColorRedIcon,
                        //     shape: RoundedRectangleBorder(
                        //         borderRadius: new BorderRadius.circular(5.0)),
                        //     side: BorderSide(color: appPrimaryColor)),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: btnBgColor,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(25.0),
                          ),
                        ),
                        child: Text(
                          'Reset Password',
                          style: TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                              fontSize: ScreenUtil().setSp(15)),
                        ),
                        onPressed: () {
                          apiCallForChangePassword();
                        },
                      ),
                    ),
                  ],
                ),
              ),
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10.0)),
            ),
          ),
        ]),
      ),
    );
  }
}

class ChangePasswordCallBack {
  late int totalCount;
 late bool success;
 late int items;
 String? message;
 late int status;

  ChangePasswordCallBack(
      {required this.totalCount, required this.success, required this.items, required this.message, required this.status});

  ChangePasswordCallBack.fromJson(Map<String, dynamic> json) {
    totalCount = json['total_count'];
    success = json['success'];
    items = json['items'];
    message = json['message'];
    status = json['status'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['total_count'] = this.totalCount;
    data['success'] = this.success;
    data['items'] = this.items;
    data['message'] = this.message;
    data['status'] = this.status;
    return data;
  }
}
