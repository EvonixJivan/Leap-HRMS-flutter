import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:hrms/app/mainApp/feedback/feedback_list.dart';
import 'package:hrms/appUtil/app_util_config.dart';
import 'package:hrms/appUtil/network_util.dart';
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';


class FeedBack extends StatefulWidget {
  var scaffoldKey;
  var title;

  FeedBack({
    Key? key,
    @required this.scaffoldKey,
    @required this.title,
  }) : super(key: key);

  @override
  State<StatefulWidget> createState() {
    return _FeedBackState();
  }
}

class _FeedBackState extends State<FeedBack> {
  NetworkUtil _networkUtil = NetworkUtil();
  Future<SharedPreferences> _prefs = SharedPreferences.getInstance();
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  TextEditingController titleController = TextEditingController();
  TextEditingController detailController = TextEditingController();
  FeedbackApiCallBack? _feedbackApiCallBack;
  late int userId, companyId, isDriver = 0, isTask = 0, isLead;
 String? apiToken, currentDate, moduleDropDownValue;
  List<String> _modules = [];

  @override
  void initState() {
    super.initState();
    getModuleOptions();
  }

  Future getModuleOptions() async {
    final SharedPreferences prefs = await _prefs;
    if (prefs.getBool(SP_IS_LOGIN_BOOL) != null) {
      isDriver = prefs.getInt(SP_DRIVER)!;
      isTask = prefs.getInt(TASK_MANAGER)!;
      isLead = prefs.getInt(SP_ROLE)!;
      _modules = [
        'Dashboard',
        'Attendance',
        'Meeting',
        'Leave',
        'Documents',
        'Holiday',
        'Task/ToDo Manager',
        'Settings',
        'Notifications',
        'Feedback',
        'Helpline'
      ];
      if (isDriver == 1) {
        _modules = [
          'Dashboard',
          'Driver',
          'Attendance',
          'Meeting',
          'Leave',
          'Documents',
          'Holiday',
          'Settings',
          'Notifications',
          'Feedback',
          'Helpline'
        ];
      } else if (isTask == 1) {
        if (isLead == 4) {
          _modules = [
            'Dashboard',
            'Attendance',
            'Meeting',
            'Leave',
            'Documents',
            'Holiday',
            'Task/ToDo Manager',
            'My Team',
            'Settings',
            'Notifications',
            'Feedback',
            'Helpline'
          ];
        } else {
          _modules = [
            'Dashboard',
            'Attendance',
            'Meeting',
            'Leave',
            'Documents',
            'Holiday',
            'Task/ToDo Manager',
            'Settings',
            'Notifications',
            'Feedback',
            'Helpline'
          ];
        }
      }
    }
  }

  Future submitButtonTapped() async {
    final SharedPreferences prefs = await _prefs;
    if (prefs.getBool(SP_IS_LOGIN_BOOL) != null) {
       userId = prefs.getInt(SP_ID)!;
      companyId = prefs.getInt(SP_COMPANY_ID)!;
      apiToken = prefs.getString(SP_API_TOKEN)!;
    }

    var map = new Map<String, dynamic>();
    map["appType"] = Platform.operatingSystem.toUpperCase();
    map["userId"] = userId.toString();
    map["api_token"] = apiToken;
    map['moduleName'] = moduleDropDownValue;
    map['feedbackTitle'] = titleController.text;
    map['companyId'] = companyId.toString();
    map['feedbackDetail'] = detailController.text;
    map['status'] = 'Open';
    BuildContext _context = context;

    print(map);
    try {
      showLoader(_context);
      _networkUtil.post(apiAddFeedback, body: map).then((dynamic res) {
        try {
          Navigator.pop(_context);
          AppLog.showLog(res.toString());
          _feedbackApiCallBack = FeedbackApiCallBack.fromJson(res);
          if (_feedbackApiCallBack!.status == unAuthorised) {
            logout(context);
          } else if (_feedbackApiCallBack!.success) {
            showBottomToast(_feedbackApiCallBack!.message ?? "");
            // Navigator.pop(context);
            //Change by G1...
            Navigator.of(context).push(new MaterialPageRoute(
                builder: (BuildContext context) => FeedBackList(
                    scaffoldKey: widget.scaffoldKey, title: 'Feedback List')));
          } else {
            showBottomToast(_feedbackApiCallBack!.message ?? "");
          }
        } catch (es) {
          showErrorLog(es.toString());
          showCenterToast(errorApiCall);
          Navigator.pop(_context);
        }
        setState(() {});
      });
    } catch (e) {
      Navigator.pop(_context);
      showErrorLog(e.toString());
      showCenterToast(errorApiCall);
    }
  }

  @override
  Widget build(BuildContext context) {
    final module = Padding(
      padding: EdgeInsets.only(
          left: ScreenUtil().setSp(10),
          top: ScreenUtil().setSp(10),
          right: ScreenUtil().setSp(10),
          bottom: ScreenUtil().setSp(10)),
      child: Container(
          padding: EdgeInsets.only(left: ScreenUtil().setSp(10)),
          // decoration: BoxDecoration(
          //   color: Colors.grey[100],
          //   border: Border.all(width: 1, color: Colors.grey),
          //   borderRadius: BorderRadius.circular(3),
          // ),
          decoration: BoxDecoration(
            color: tfBackgroundColor,
            border: Border.all(
              width: 1,
              color: tfBackgroundColor,
            ),
            borderRadius: BorderRadius.circular(25.0),
          ),
          child: DropdownButtonHideUnderline(
            child: DropdownButton<String>(
              hint: Text('Select Module'),
              isExpanded: true,
              items: _modules.map((String value) {
                return new DropdownMenuItem<String>(
                  value: value,
                  child: new Text(value),
                );
              }).toList(),
              onChanged: (newValue) {
                setState(() {
                  moduleDropDownValue = newValue.toString();
                });
              },
              value: moduleDropDownValue,
            ),
          )),
    );

    final feedbacktitle = Padding(
      padding: EdgeInsets.only(
          left: ScreenUtil().setSp(10),
          top: ScreenUtil().setSp(10),
          right: ScreenUtil().setSp(10),
          bottom: ScreenUtil().setSp(10)),
      child: Container(
          // decoration: BoxDecoration(
          //   color: Colors.grey[100],
          //   border: Border.all(width: 1, color: Colors.grey),
          //   borderRadius: BorderRadius.circular(3),
          // ),
          child: TextFormField(
        controller: titleController,
        maxLength: 100,
        keyboardType: TextInputType.text,
        minLines: 1,
        maxLines: 2,
        // validator: (value) {
        //   if (value.isEmpty) {
        //     return 'Feedback title is required';
        //   }
        //   return null;
        // },
        // decoration: InputDecoration(
        //     border: InputBorder.none,
        //     hintText: 'Title',
        //     prefixIcon: Icon(
        //       Icons.title,
        //       color: Colors.grey,
        //     )),
        decoration: InputDecoration(
          hintStyle: TextStyle(color: colorText, fontFamily: font),
          hintText: '  Title',
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
        onChanged: (String value) {
          setState(() {
            //  _phoneNumber = value;
          });
        },
      )),
    );

    final detail = Padding(
      padding: EdgeInsets.only(
          left: ScreenUtil().setSp(10),
          top: ScreenUtil().setSp(10),
          right: ScreenUtil().setSp(10),
          bottom: ScreenUtil().setSp(10)),
      child: Container(
          // decoration: BoxDecoration(
          //   color: Colors.grey[100],
          //   border: Border.all(width: 1, color: Colors.grey),
          //   borderRadius: BorderRadius.circular(3),
          // ),
          child: TextFormField(
        controller: detailController,
        keyboardType: TextInputType.text,
        maxLength: 500,
        minLines: 3,
        maxLines: 5,
        // validator: (value) {
        //   if (value.isEmpty) {
        //     return 'Details are required';
        //   }
        //   return null;
        // },
        // decoration: InputDecoration(
        //     border: InputBorder.none,
        //     hintText: 'Details',
        //     hintStyle: TextStyle(
        //       height: 2.8,
        //     ),
        //     prefixIcon: Icon(
        //       Icons.details,
        //       color: Colors.grey,
        //     )),
        decoration: InputDecoration(
          hintStyle: TextStyle(color: colorText, fontFamily: font),
          hintText: '  Details',
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
        onChanged: (String value) {
          setState(() {
            //_meterReading = value;
          });
        },
      )),
    );

    final submitButton = Row(
      children: <Widget>[
        SizedBox(
          width: ScreenUtil().setSp(30),
        ),
        Expanded(
          child: ElevatedButton(
            style: ElevatedButton.styleFrom(
              // backgroundColor: appPrimaryColor,
              backgroundColor: btnBgColor,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10.0)),
            ),
            onPressed: () {
              if (_formKey.currentState!.validate()) {
                _formKey.currentState!.save();
                if (titleController.text.isEmpty) {
                showBottomToast("Feedback title is required");
              } else if (detailController.text.isEmpty) {
                showBottomToast("Feedback Details are required");
              } else {
                submitButtonTapped();
              }
              }
            },
            child: Text('Submit',
                style: TextStyle(
                    color: Colors.white, fontWeight: FontWeight.bold)),
          ),
        ),
        SizedBox(
          width: ScreenUtil().setSp(30),
        ),
      ],
    );

    return SafeArea(
       top: false,
        bottom: true,
      child: Scaffold(
        body: Container(
          color: appBackgroundDashboard,
          child: GestureDetector(
            child: Stack(
              children: <Widget>[
                // CustomHeaderWithBackGreen(scaffoldKey:widget.scaffoldKey, title: widget.title),
                // CustomHeader(
                //     scaffoldKey: widget.scaffoldKey, title: widget.title),
                getCustomAppBar(),
                Container(
                  margin: EdgeInsets.only(top: 90.0),
                  child: ListView(
                    children: <Widget>[
                      Card(
                        color: appBackground,
                        margin: EdgeInsets.only(
                            left: ScreenUtil().setSp(20),
                            right: ScreenUtil().setSp(20),
                            bottom: ScreenUtil().setSp(30)),
                        elevation: 5,
                        child: Form(
                          key: _formKey,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: <Widget>[
                              SizedBox(
                                height: ScreenUtil().setSp(20),
                              ),
                              Center(
                                child: Text(
                                  DateFormat('dd MMM, yyyy')
                                      .format(DateTime.now()),
                                  style: TextStyle(
                                      // color: appAccentColor,
                                      color: colorTextDarkBlue,
                                      fontSize: ScreenUtil().setSp(18),
                                      fontWeight: FontWeight.w800),
                                ),
                              ),
                              SizedBox(height: 10),
                              module,
                              feedbacktitle,
                              detail,
                              submitButton,
                              SizedBox(
                                height: ScreenUtil().setSp(20),
                              )
                            ],
                          ),
                        ),
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10.0)),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            onTap: () {
              //Navigator.of(context).pop();
              FocusScope.of(context).requestFocus(new FocusNode());
            },
          ),
        ),
      ),
    );
  }

  Widget getCustomAppBar() {
    return PreferredSize(
      preferredSize: Size(MediaQuery.of(context).size.width, 250),
      child: Container(
        width: MediaQuery.of(context).size.width,
        height: 250,
        child: Container(
          decoration: BoxDecoration(
            color: Colors.transparent,
            image: DecorationImage(
                image: AssetImage('assets/image/navigation_bg.png'),
                fit: BoxFit.fill),
          ),
          child: Column(
            children: <Widget>[
              Container(
                margin: EdgeInsets.fromLTRB(10, 50, 10, 0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    GestureDetector(
                      child: Icon(
                        Icons.arrow_back_ios,
                        size: 25,
                        color: Colors.white,
                      ),
                      onTap: () {
                        print('click ');
                        Navigator.pop(context);
                      },
                    ),
                    Text(
                      widget.title,
                      style: TextStyle(fontSize: 22, color: Colors.white),
                    ),
                    InkWell(
                      child: Icon(
                        Icons.list,
                        size: 30,
                        color: Colors.white,
                      ),
                      onTap: () {
                        Navigator.of(context).push(new MaterialPageRoute(
                            builder: (BuildContext context) => FeedBackList(
                                scaffoldKey: widget.scaffoldKey,
                                title: 'Feedback List')));
                      },
                    ),
                  ],
                ),
              ),
              SizedBox(
                height: 20.0,
              )
            ],
          ),
        ),
      ),
    );
  }
}

class FeedbackApiCallBack {
  late int totalCount;
 late bool success;
 late Items? items;
 String? message;
 late int status;
 String? currentTime;
 String? currentUtcTime;

  FeedbackApiCallBack(
      {required this.totalCount,
     required this.success,
     required this.items,
     required this.message,
     required this.status,
     required this.currentTime,
     required this.currentUtcTime});

  FeedbackApiCallBack.fromJson(Map<String, dynamic> json) {
    totalCount = json['total_count'];
    success = json['success'];
    items = json['items'] != null ? new Items.fromJson(json['items']) : null;
    message = json['message'];
    status = json['status'];
    currentTime = json['current_time'];
    currentUtcTime = json['current_utc_time'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['total_count'] = this.totalCount;
    data['success'] = this.success;
    data['items'] = this.items!.toJson();
      data['message'] = this.message;
    data['status'] = this.status;
    data['current_time'] = this.currentTime;
    data['current_utc_time'] = this.currentUtcTime;
    return data;
  }
}

class Items {
  final String userId;
  final String companyId;
  final String moduleName;
  final String title;
  final String detail;
  final String status;
  final String createdAt;
  final String updatedAt;
  final int id;

  Items({
    required this.userId,
    required this.companyId,
    required this.moduleName,
    required this.title,
    required this.detail,
    required this.status,
    required this.createdAt,
    required this.updatedAt,
    required this.id,
  });

  factory Items.fromJson(Map<String, dynamic> json) {
    return Items(
      userId: json['userId'],
      companyId: json['companyId'],
      moduleName: json['moduleName'],
      title: json['title'],
      detail: json['detail'],
      status: json['status'],
      createdAt: json['created_at'],
      updatedAt: json['updated_at'],
      id: json['id'],
    );
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['userId'] = userId;
    data['companyId'] = companyId;
    data['moduleName'] = moduleName;
    data['title'] = title;
    data['detail'] = detail;
    data['status'] = status;
    data['created_at'] = createdAt;
    data['updated_at'] = updatedAt;
    data['id'] = id;
    return data;
  }
}