import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:hrms/appUtil/app_util_config.dart';
import 'package:hrms/appUtil/network_util.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ForgotPassword extends StatefulWidget {
  ForgotPassword({Key? key}) : super(key: key);

  @override
  _ForgotPasswordState createState() {
    return _ForgotPasswordState();
  }
}

class _ForgotPasswordState extends State<ForgotPassword> {
  Future<SharedPreferences> _prefs = SharedPreferences.getInstance();
  bool isLogin = false;
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  String? _email;
  NetworkUtil _networkUtil = NetworkUtil();

  Future apiCall() async {
    if (_formKey.currentState!.validate()) {
      _formKey.currentState!.save();
      var map = new Map<String, dynamic>();
      map["appType"] = Platform.operatingSystem.toUpperCase();
      map["email"] = _email;
      print(map);
      try {
        showLoader(context);
        _networkUtil.post(apiForgotPassword, body: map).then((dynamic res) {
          Navigator.pop(context);
          try {
            AppLog.showLog(res.toString());
            if (res['status'] == unAuthorised) {
              logout(context);
            } else if (res['success'] == true) {
              showBottomToast(res['message']);
              Navigator.pop(context);
            } else {
              showBottomToast(res['message']);
            }
          } catch (es) {
            showErrorLog(es.toString());
            showCenterToast(errorApiCall);
          }
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
    //2,436 x 1,125

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
            autovalidateMode: AutovalidateMode.disabled,
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
              fontFamily: "Montserrat-Regular",
            ),
            decoration: InputDecoration(
              hintText: '  Enter Email ID',
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
              _email = value;
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
          padding: EdgeInsets.only(
              left: ScreenUtil().setSp(50),
              right: ScreenUtil().setSp(50),
              top: ScreenUtil().setSp(5),
              bottom: ScreenUtil().setSp(5)),
          backgroundColor: btnBgColor,
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(25.0)),
        ),
        onPressed: () {
          setState(() {
            apiCall();
          });
        },
        child: Text('Reset Password',
            style: TextStyle(color: Colors.white, fontFamily: "Montserrat")),
      ),
    );

    return SafeArea(
      child: Scaffold(
        body: Container(
          color: appPrimaryColor,
          child: Stack(
            children: <Widget>[
              // Container(
              //   color: appWhiteColor,
              //   child:
              ListView(
                children: <Widget>[
                  Padding(
                    padding: EdgeInsets.all(0),
                    child: Form(
                      key: _formKey,
                      child: Column(
                        children: <Widget>[
                          Stack(
                            children: <Widget>[
                              // SimpleHeader(),

                              Padding(
                                padding: EdgeInsets.only(
                                    top: ScreenUtil().setSp(170),
                                    left: ScreenUtil().setSp(46),
                                    right: ScreenUtil().setSp(45)),
                                child: SvgPicture.asset(
                                  'assets/svg/forgot_password.svg',
                                  fit: BoxFit.fill,
                                  height: ScreenUtil().setSp(230.95),
                                  width: ScreenUtil().setSp(250.68),
                                ),
                              ),
                              Image.asset(
                                'assets/image/logo_bg.png',
                                width: MediaQuery.of(context).size.width,
                                height: 250,
                                fit: BoxFit.fill,
                              ),
                            ],
                          ),
                          // logo,
                          SizedBox(
                            height: 20,
                          ),
                          Padding(
                            padding: const EdgeInsets.all(2.0),
                            child: Text(
                              'Forgot Password?',
                              style: TextStyle(
                                  fontSize: 18.0,
                                  fontFamily: 'Montserrat',
                                  fontWeight: FontWeight.w800,
                                  color: appWhiteColor),
                            ),
                          ),
                          SizedBox(
                            height: 20,
                          ),
                          email,
                          SizedBox(height: 10.0),
                          loginButton,
                        ],
                      ),
                    ),
                  )
                ],
              ),
              Padding(
                padding: EdgeInsets.only(top: ScreenUtil().setSp(30), left: 5),
                // child: ElevatedButton.icon(
                //     onPressed: () {
                //       Navigator.of(context).pop();
                //     },
                //     icon: Icon(
                //       Icons.arrow_back_ios,
                //       color: Colors.white,
                //       size: 30,
                //     ),
                //     label: Text('')),
                child: IconButton(
                  icon: Icon(
                    Icons.arrow_back_ios,
                    color: Colors.black,
                    size: 30,
                  ),
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    super.dispose();
  }
}
