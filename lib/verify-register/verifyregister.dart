// Verify
import 'dart:async';
import 'dart:io';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:hrms/app/mainApp/task_manager/project_list_call_back.dart';
import 'package:hrms/app/mainApp/task_manager/task_type_call_back.dart';
import 'package:hrms/app/uiComponent/custom_header.dart';
import 'package:hrms/appUtil/app_util_config.dart';
import 'package:hrms/appUtil/network_util.dart';
import 'package:intl/intl.dart';
import 'package:location/location.dart';

import 'package:shared_preferences/shared_preferences.dart';
import 'package:geocoding/geocoding.dart' as loc;
import 'package:geolocator/geolocator.dart' as geo;

// ignore: must_be_immutable
class Verify extends StatefulWidget {
  var scaffoldKey;
  var title;

  Verify({required Key key, @required this.scaffoldKey, @required this.title})
      : super(key: key);

  @override
  State<StatefulWidget> createState() {
    return VerifyState();
  }
}

class VerifyState extends State<Verify> {
  int _userId = 0, _attendanceStatus = 0;
  String _deviceId = "";
  late BuildContext _context;
  bool _isVisible = true;
  bool _secondFormvisible = false;
  bool _thirdFormvisible = false;

  ///for location
  Location _locationService = new Location();
  bool _permission = false;
  String? error;
  late LocationData _startLocation;
  String _apiToken = "";
  late int _companyId;
  File? _tImage;
  String? selectedImage;

  var formkey = GlobalKey<FormState>();
  Future<SharedPreferences> _prefs = SharedPreferences.getInstance();
  TextEditingController taskController = TextEditingController();
  NetworkUtil _networkUtil = NetworkUtil();
  late ClientListApiCallBack activeListApi;
  late ProjectListCallBack _projectListCallBack;
  late TaskTypeCallBack _taskTypeCallBack;

  String? _clientDropdownValue, _projectDropdownValue;
  String? _hrstDropdownValue, _minDropdownValue, _typeDropdownValue;
  bool isnewtask = false, isMoreTask = false;
  String newtask = '0', status = 'Not stated / Stop';

  var now = new DateTime.now();
  var _toDate = '';
  var _fromDate = '';
  String? formatted;
  var formatter = new DateFormat('yyyy-MM-dd');
     late geo.Position _currentPosition;
  String _currentAddress = '';
  late LocationData _pos;

  @override
  void initState() {
    super.initState();
    _context = context;
    formatted = formatter.format(now);
    getSpData();
    getTaskTypeList();
    getClientList();
    initLocationState();
  }

  void getSpData() async {
    final SharedPreferences prefs = await _prefs;
    _apiToken = prefs.getString(SP_API_TOKEN)!;
    _userId = prefs.getInt(SP_ID)!;
    _deviceId = prefs.getString(DEVICE_ID)!;
    _attendanceStatus = prefs.getInt(SP_ATTENDANCE_STATUS)!;
  }

  initLocationState() async {
    await _locationService.changeSettings(
        accuracy: LocationAccuracy.high, interval: 1000);
    try {
      bool serviceStatus = await _locationService.serviceEnabled();
      print("Service status: $serviceStatus");
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
        print("Service status activated after request: $serviceStatusResult");
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

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
   final taskType = Container(
  child: (_taskTypeCallBack.data.length > 0)
      ? DropdownButton(
          underline: SizedBox(),
          hint: Text(
            'Select Branch',
            style: TextStyle(color: colorText, fontFamily: font),
          ),
          items: _taskTypeCallBack.data.map<DropdownMenuItem<String>>((dataItem) {
            return DropdownMenuItem<String>(
              child: Text(dataItem.typeName ?? ""),
              value: dataItem.id.toString(),
            );
          }).toList(),
          onChanged: (String? newValue) {
            setState(() {
              _typeDropdownValue = newValue!;
            });
          },
          isExpanded: true,
          value: _typeDropdownValue,
        )
      : DropdownButton<String>(
          hint: Text('Select Task Type'),
          items: [],
          onChanged: (String? newValue) {},
          isExpanded: true,
          value: _typeDropdownValue,
        ),
);

    final drop = Container(
        child: (_taskTypeCallBack.data.length > 0)
            ? DropdownButton(
                underline: SizedBox(),
                hint: Text('Select Marital Status'),
                items: _taskTypeCallBack.data.map((dataItem) {
                  return DropdownMenuItem(
                    child: new Text(dataItem.typeName ?? ""),
                    value: dataItem.id.toString(),
                  );
                }).toList(),
                onChanged: (newValue) {
                  setState(() {
                    _typeDropdownValue = newValue.toString();
                  });
                },
                isExpanded: true,
                value: _typeDropdownValue,
              )
            : DropdownButton<String>(
                hint: Text('Select Marital Status'),
                items: [],
                onChanged: (newValue) {},
                isExpanded: true,
                value: _typeDropdownValue,
              ));

    return SafeArea(
       top: false,
        bottom: true,
      child: Scaffold(
        body: GestureDetector(
          onTap: () {
            FocusScope.of(context).requestFocus(new FocusNode());
          },
          child: Stack(
            children: <Widget>[
              CustomHeader(scaffoldKey: widget.scaffoldKey, title: widget.title),
              // CustomHeaderWithReloadBack(
              //     scaffoldKey: widget.scaffoldKey, title: widget.title),
              Visibility(
                visible: _isVisible,
                child: Form(
                  key: formkey,
                  child: Padding(
                    padding: EdgeInsets.only(
                        top: ScreenUtil().setSp(90),
                        left: ScreenUtil().setSp(20),
                        right: ScreenUtil().setSp(20),
                        bottom: ScreenUtil().setSp(20)),
                    child: Card(
                      color: appBackgroundColor,
                      elevation: 5,
                      child: ListView(
                        children: <Widget>[
                          Padding(
                            padding: EdgeInsets.all(7),
                            child: Text(
                              'Add Employee',
      
                              // '${DateFormat(' dd, MMM yyyy').format(DateTime.now())}',
                              // style: titleStyle,
                              style: TextStyle(
                                  color: colorText,
                                  fontFamily: fontmedium,
                                  fontWeight: FontWeight.w500),
      
                              textAlign: TextAlign.center,
                            ),
                          ),
                          //ProfileUI
                          Column(
                            children: [
                              Container(
                                padding: EdgeInsets.all(8),
                                height: 120,
                                width: 120,
                                decoration: new BoxDecoration(
                                  image: DecorationImage(
                                      image: AssetImage(
                                          'assets/image/btn_play_pause.png'),
                                      fit: BoxFit.fill),
                                  borderRadius: new BorderRadius.circular(60),
                                ),
                                child: Padding(
                                  padding: const EdgeInsets.all(8.0),
                                  child: Container(
                                    height: 45,
                                    width: 45,
                                    decoration: new BoxDecoration(
                                      color: colorTextDarkBlue,
                                      image: DecorationImage(
                                          image: AssetImage(
                                              'assets/image/upload_image.png'),
                                          fit: BoxFit.fill),
                                      borderRadius: new BorderRadius.circular(60),
                                    ),
                                  ),
                                ),
                              ),
                              // Container(
                              //   height: 90,
                              //   width: 90,
                              //   decoration: new BoxDecoration(
                              //     image: DecorationImage(
                              //         image: AssetImage(
                              //             'assets/image/btn_play_pause.png'),
                              //         fit: BoxFit.fill),
                              //     borderRadius: new BorderRadius.circular(60),
                              //   ),
                              //   child:
                              //   Container(
                              //     height: 45,
                              //     width: 45,
                              //     decoration: new BoxDecoration(
                              //       color: colorTextDarkBlue,
                              //       image: DecorationImage(
                              //           image: AssetImage(
                              //               'assets/image/upload_image.png'),
                              //           fit: BoxFit.fill),
                              //       borderRadius: new BorderRadius.circular(60),
                              //     ),
                              //   ),
                              // ),
                            ],
                          ),
                          Container(
                            padding: EdgeInsets.only(top: 5, bottom: 5),
                            margin: EdgeInsets.only(left: 23, right: 20, top: 20),
                            decoration: new BoxDecoration(
                              color: tfBackgroundColor,
                              borderRadius: new BorderRadius.circular(70),
                              // )
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: <Widget>[
                                taskType,
                              ],
                            ),
                          ),
                          Container(
                            padding: EdgeInsets.only(top: 20),
                            margin: EdgeInsets.only(left: 20, right: 20),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: <Widget>[
                                TextFormField(
                                  // controller: taskController,
                                  //autofocus: true,
                                  maxLines: null,
                                  decoration: InputDecoration(
                                    hintStyle: TextStyle(
                                        color: colorText, fontFamily: font),
                                    hintText: '  Full Name',
                                    filled: true,
                                    fillColor: tfBackgroundColor,
                                    contentPadding:
                                        EdgeInsets.fromLTRB(10.0, 5.0, 10.0, 5.0),
                                    focusedBorder: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(25.0),
                                      borderSide: BorderSide.none,
                                    ),
                                    enabledBorder: UnderlineInputBorder(
                                      borderSide: BorderSide.none,
                                      borderRadius: BorderRadius.circular(25.7),
                                    ),
                                  ),
      
                                  // decoration:
                                  //     InputDecoration(labelText: "First Name"),
                                  // validator: (value) {
                                  //   if (value.isEmpty) {
                                  //     return 'Please enter task';
                                  //   }
                                  // },
                                ),
                              ],
                            ),
                          ),
                          Container(
                            padding: const EdgeInsets.only(top: 15, bottom: 0),
                            margin: EdgeInsets.only(left: 20, right: 20),
                            child: Row(
                              children: <Widget>[
                                Expanded(
                                  child: Container(
                                    decoration: new BoxDecoration(
                                      color: tfBackgroundColor,
                                      borderRadius: new BorderRadius.circular(70),
                                      // )
                                    ),
                                    child: DropdownButton(
                                      underline: SizedBox(),
                                      hint: Text(
                                        ' Gender',
                                        style: TextStyle(
                                            color: colorText, fontFamily: font),
                                      ),
                                      isExpanded: true,
                                      value: _hrstDropdownValue,
                                      onChanged: (newValue) {
                                        setState(() {
                                          _hrstDropdownValue = newValue.toString();
                                        });
                                      },
                                      items: [
                                        'Male',
                                        'Female',
                                      ].map<DropdownMenuItem<String>>(
                                          (String value) {
                                        return DropdownMenuItem(
                                          child: new Text(value),
                                          value: value,
                                        );
                                      }).toList(),
                                    ),
                                  ),
                                ),
                                SizedBox(
                                  width: 15,
                                ),
                                Expanded(
                                  child: Container(
                                    padding: EdgeInsets.only(top: 20, bottom: 20),
                                    margin: EdgeInsets.only(left: 20, right: 20),
                                    decoration: new BoxDecoration(
                                      color: tfBackgroundColor,
      
                                      borderRadius: new BorderRadius.circular(70),
                                      // )
                                    ),
                                    child: Row(
                                      children: <Widget>[
                                        // Icon(
                                        //   Icons.calendar_today,
                                        //   color: Colors.black,
                                        //   size: ScreenUtil().setSp(15),
                                        // ),
                                        ImageIcon(
                                          AssetImage(
                                              'assets/image/calendaricon.png'),
                                          color: appPrimaryColor,
                                          size: ScreenUtil().setSp(15),
                                        ),
                                        SizedBox(
                                          width: ScreenUtil().setSp(15),
                                        ),
                                        Text(
                                          'BirthDate',
                                          style: TextStyle(
                                              color: colorText, fontFamily: font),
                                        ),
                                        SizedBox(),
                                        Text(_toDate),
                                      ],
                                    ),
                                  ),
                                )
                              ],
                            ),
                          ),
                          Container(
                            padding: EdgeInsets.only(top: 20),
                            margin: EdgeInsets.only(left: 20, right: 20),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: <Widget>[
                                // Text(
                                //   'Middle Name: ',
                                //   style:
                                //       TextStyle(fontSize: ScreenUtil().setSp(15)),
                                //   textAlign: TextAlign.start,
                                // ),
                                TextFormField(
                                  // controller: taskController,
                                  //autofocus: true,
                                  maxLines: null,
                                  decoration: InputDecoration(
                                    hintStyle: TextStyle(
                                        color: colorText, fontFamily: font),
                                    hintText: '  Mobile Number',
                                    filled: true,
                                    fillColor: tfBackgroundColor,
                                    contentPadding:
                                        EdgeInsets.fromLTRB(10.0, 5.0, 10.0, 5.0),
                                    focusedBorder: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(25.0),
                                      borderSide: BorderSide.none,
                                    ),
                                    enabledBorder: UnderlineInputBorder(
                                      borderSide: BorderSide.none,
                                      borderRadius: BorderRadius.circular(25.7),
                                    ),
                                  ),
                                  // decoration:
                                  //     InputDecoration(labelText: "Middle Name"),
                                  // validator: (value) {
                                  //   if (value.isEmpty) {
                                  //     return 'Please enter task';
                                  //   }
                                  // },
                                ),
                              ],
                            ),
                          ),
                          Container(
                            padding: EdgeInsets.only(top: 20),
                            margin: EdgeInsets.only(left: 20, right: 20),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: <Widget>[
                                // Text(
                                //   'Last  Name: ',
                                //   style:
                                //       TextStyle(fontSize: ScreenUtil().setSp(15)),
                                //   textAlign: TextAlign.start,
                                // ),
                                TextFormField(
                                  // controller: taskController,
                                  //autofocus: true,
                                  maxLines: null,
                                  decoration: InputDecoration(
                                    hintStyle: TextStyle(
                                        color: colorText, fontFamily: font),
                                    hintText: ' Emergency Mobile Number',
                                    filled: true,
                                    fillColor: tfBackgroundColor,
                                    contentPadding:
                                        EdgeInsets.fromLTRB(10.0, 5.0, 10.0, 5.0),
                                    focusedBorder: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(25.0),
                                      borderSide: BorderSide.none,
                                    ),
                                    enabledBorder: UnderlineInputBorder(
                                      borderSide: BorderSide.none,
                                      borderRadius: BorderRadius.circular(25.7),
                                    ),
                                  ),
                                  // validator: (value) {
                                  //   if (value.isEmpty) {
                                  //     return 'Please enter task';
                                  //   }
                                  // },
                                ),
                              ],
                            ),
                          ),
      
                          Container(
                            padding: EdgeInsets.only(top: 20),
                            margin: EdgeInsets.only(left: 20, right: 20),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: <Widget>[
                                // Text(
                                //   'Present Address: ',
                                //   style:
                                //       TextStyle(fontSize: ScreenUtil().setSp(15)),
                                //   textAlign: TextAlign.start,
                                // ),
                                TextFormField(
                                  // controller: taskController,
                                  //autofocus: true,
                                  maxLines: null,
                                  decoration: InputDecoration(
                                    hintStyle: TextStyle(
                                        color: colorText, fontFamily: font),
                                    hintText: '  Present Address',
                                    filled: true,
                                    fillColor: tfBackgroundColor,
                                    contentPadding:
                                        EdgeInsets.fromLTRB(10.0, 5.0, 10.0, 5.0),
                                    focusedBorder: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(25.0),
                                      borderSide: BorderSide.none,
                                    ),
                                    enabledBorder: UnderlineInputBorder(
                                      borderSide: BorderSide.none,
                                      borderRadius: BorderRadius.circular(25.7),
                                    ),
                                  ),
                                  // decoration: InputDecoration(
                                  //     labelText: "Present Address"),
                                  // validator: (value) {
                                  //   if (value.isEmpty) {
                                  //     return 'Please enter task';
                                  //   }
                                  // },
                                ),
                              ],
                            ),
                          ),
                          Container(
                            padding: EdgeInsets.only(top: 20),
                            margin: EdgeInsets.only(left: 20, right: 20),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: <Widget>[
                                // Text(
                                //   'Permanent Address: ',
                                //   style:
                                //       TextStyle(fontSize: ScreenUtil().setSp(15)),
                                //   textAlign: TextAlign.start,
                                // ),
                                TextFormField(
                                  // controller: taskController,
                                  //autofocus: true,
                                  maxLines: null,
                                  decoration: InputDecoration(
                                    hintStyle: TextStyle(
                                        color: colorText, fontFamily: font),
                                    hintText: '  Permanent Address',
                                    filled: true,
                                    fillColor: tfBackgroundColor,
                                    contentPadding:
                                        EdgeInsets.fromLTRB(10.0, 5.0, 10.0, 5.0),
                                    focusedBorder: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(25.0),
                                      borderSide: BorderSide.none,
                                    ),
                                    enabledBorder: UnderlineInputBorder(
                                      borderSide: BorderSide.none,
                                      borderRadius: BorderRadius.circular(25.7),
                                    ),
                                  ),
                                  // decoration: InputDecoration(
                                  //     labelText: "Permanent Address"),
                                  // validator: (value) {
                                  //   if (value.isEmpty) {
                                  //     return 'Please enter task';
                                  //   }
                                  // },
                                ),
                              ],
                            ),
                          ),
                          SizedBox(
                            height: 20,
                          ),
                          Container(
                            padding: const EdgeInsets.only(top: 0, bottom: 20),
                            margin: EdgeInsets.only(left: 20, right: 20),
                            child: Row(
                              children: <Widget>[
                                Expanded(
                                  child: Container(
                                    decoration: new BoxDecoration(
                                      color: tfBackgroundColor,
                                      borderRadius: new BorderRadius.circular(70),
                                      // )
                                    ),
                                    child: DropdownButton(
                                      underline: SizedBox(),
                                      hint: Text(
                                        'Select City',
                                        style: TextStyle(
                                            color: colorText, fontFamily: font),
                                      ),
                                      isExpanded: true,
                                      value: _hrstDropdownValue,
                                      onChanged: (newValue) {
                                        setState(() {
                                          _hrstDropdownValue = newValue.toString();
                                        });
                                      },
                                      items: [
                                        'Male',
                                        'Female',
                                      ].map<DropdownMenuItem<String>>(
                                          (String value) {
                                        return DropdownMenuItem(
                                          child: new Text(value),
                                          value: value,
                                        );
                                      }).toList(),
                                    ),
                                  ),
                                ),
                                SizedBox(
                                  width: 15,
                                ),
                                Expanded(
                                  child: Container(
                                    decoration: new BoxDecoration(
                                      color: tfBackgroundColor,
                                      borderRadius: new BorderRadius.circular(70),
                                      // )
                                    ),
                                    child: DropdownButton(
                                      underline: SizedBox(),
                                      hint: Text(
                                        'Select State',
                                        style: TextStyle(
                                            color: colorText, fontFamily: font),
                                      ),
                                      isExpanded: true,
                                      value: _minDropdownValue,
                                      onChanged: (newValue) {
                                        setState(() {
                                          _minDropdownValue = newValue.toString();
                                        });
                                      },
                                      items: [
                                        '00',
                                        '05',
                                        '10',
                                        '15',
                                        '20',
                                        '25',
                                        '30',
                                        '35',
                                        '40',
                                        '45',
                                        '50',
                                        '55'
                                      ].map<DropdownMenuItem<String>>(
                                          (String value) {
                                        return DropdownMenuItem(
                                          child: new Text(value),
                                          value: value,
                                        );
                                      }).toList(),
                                    ),
                                  ),
                                )
                              ],
                            ),
                          ),
                          Container(
                            padding: EdgeInsets.only(top: 20),
                            margin: EdgeInsets.only(left: 20, right: 20),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: <Widget>[
                                // Text(
                                //   'First Name: ',
                                //   style:
                                //       TextStyle(fontSize: ScreenUtil().setSp(15)),
                                //   textAlign: TextAlign.start,
                                // ),
                                TextFormField(
                                  // controller: taskController,
                                  //autofocus: true,
                                  maxLines: null,
                                  decoration: InputDecoration(
                                    hintStyle: TextStyle(
                                        color: colorText, fontFamily: font),
                                    hintText: ' Zip Code',
                                    filled: true,
                                    fillColor: tfBackgroundColor,
                                    contentPadding:
                                        EdgeInsets.fromLTRB(10.0, 5.0, 10.0, 5.0),
                                    focusedBorder: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(25.0),
                                      borderSide: BorderSide.none,
                                    ),
                                    enabledBorder: UnderlineInputBorder(
                                      borderSide: BorderSide.none,
                                      borderRadius: BorderRadius.circular(25.7),
                                    ),
                                  ),
                                  // decoration:
                                  //     InputDecoration(labelText: "Zip Code"),
                                  // validator: (value) {
                                  //   if (value.isEmpty) {
                                  //     return 'Please enter task';
                                  //   }
                                  // },
                                ),
                              ],
                            ),
                          ),
                          Padding(
                            padding: const EdgeInsets.all(10.0),
                            child: Center(
                              child: Container(
                                  padding: EdgeInsets.only(
                                    top: 20,
                                  ),
                                  height: 55,
                                  margin: EdgeInsets.all(0),
                                  child: ElevatedButton(
                                    style: ElevatedButton.styleFrom(
                                        elevation: 5,
                                        textStyle: TextStyle(color: Colors.white),
                                        padding: const EdgeInsets.all(0.0),
                                        shape: RoundedRectangleBorder(
                                            borderRadius:
                                                BorderRadius.circular(20.0))),
                                    child: Container(
                                      decoration: const BoxDecoration(
                                          color: btnBgColor,
                                          borderRadius: BorderRadius.all(
                                              Radius.circular(20.0))),
                                      padding:
                                          const EdgeInsets.fromLTRB(50, 7, 50, 7),
                                      child: const Text(
                                        'Next',
                                        style: TextStyle(
                                            color: appBackground, fontSize: 17),
                                      ),
                                    ),
                                    onPressed: () {
                                      showToast();
                                    },
                                  )),
                            ),
                          ),
                          SizedBox(
                            height: 30,
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
              //secondform
              Visibility(
                visible: _secondFormvisible,
                child: Form(
                  key: formkey,
                  child: Padding(
                    padding: EdgeInsets.only(
                        top: ScreenUtil().setSp(90),
                        left: ScreenUtil().setSp(20),
                        right: ScreenUtil().setSp(20),
                        bottom: ScreenUtil().setSp(20)),
                    child: Card(
                      color: appBackgroundColor,
                      elevation: 5,
                      child: ListView(
                        children: <Widget>[
                          Padding(
                            padding: EdgeInsets.all(5),
                            child: Text(
                              'Other Information',
                              // '${DateFormat(' dd, MMM yyyy').format(DateTime.now())}',
                              style: titleStyle,
                              textAlign: TextAlign.center,
                            ),
                          ),
      
                          Container(
                            padding: EdgeInsets.only(top: 20),
                            margin: EdgeInsets.only(left: 20, right: 20),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: <Widget>[
                                // Text(
                                //   'First Name: ',
                                //   style:
                                //       TextStyle(fontSize: ScreenUtil().setSp(15)),
                                //   textAlign: TextAlign.start,
                                // ),
                                TextFormField(
                                  // controller: taskController,
                                  //autofocus: true,
                                  maxLines: null,
                                  decoration: InputDecoration(
                                    hintStyle: TextStyle(
                                        color: colorText, fontFamily: font),
                                    hintText: ' Qualification',
                                    filled: true,
                                    fillColor: tfBackgroundColor,
                                    contentPadding:
                                        EdgeInsets.fromLTRB(10.0, 5.0, 10.0, 5.0),
                                    focusedBorder: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(25.0),
                                      borderSide: BorderSide.none,
                                    ),
                                    enabledBorder: UnderlineInputBorder(
                                      borderSide: BorderSide.none,
                                      borderRadius: BorderRadius.circular(25.7),
                                    ),
                                  ),
                                  // decoration:
                                  //     InputDecoration(labelText: "Qualification"),
                                  // validator: (value) {
                                  //   if (value.isEmpty) {
                                  //     return 'Please enter task';
                                  //   }
                                  // },
                                ),
                              ],
                            ),
                          ),
                          Container(
                            padding: EdgeInsets.only(top: 20),
                            margin: EdgeInsets.only(left: 20, right: 20),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: <Widget>[
                                // Text(
                                //   'First Name: ',
                                //   style:
                                //       TextStyle(fontSize: ScreenUtil().setSp(15)),
                                //   textAlign: TextAlign.start,
                                // ),
                                TextFormField(
                                  // controller: taskController,
                                  //autofocus: true,
                                  maxLines: null,
                                  decoration: InputDecoration(
                                    hintStyle: TextStyle(
                                        color: colorText, fontFamily: font),
                                    hintText: '  Mothers Name',
                                    filled: true,
                                    fillColor: tfBackgroundColor,
                                    contentPadding:
                                        EdgeInsets.fromLTRB(10.0, 5.0, 10.0, 5.0),
                                    focusedBorder: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(25.0),
                                      borderSide: BorderSide.none,
                                    ),
                                    enabledBorder: UnderlineInputBorder(
                                      borderSide: BorderSide.none,
                                      borderRadius: BorderRadius.circular(25.7),
                                    ),
                                  ),
                                  // decoration:
                                  //     InputDecoration(labelText: "Mothers Name"),
                                  // validator: (value) {
                                  //   if (value.isEmpty) {
                                  //     return 'Please enter task';
                                  //   }
                                  // },
                                ),
                              ],
                            ),
                          ),
                          Container(
                            padding: EdgeInsets.only(top: 20),
                            margin: EdgeInsets.only(left: 20, right: 20),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: <Widget>[
                                // Text(
                                //   'First Name: ',
                                //   style:
                                //       TextStyle(fontSize: ScreenUtil().setSp(15)),
                                //   textAlign: TextAlign.start,
                                // ),
                                TextFormField(
                                  // controller: taskController,
                                  //autofocus: true,
                                  maxLines: null,
                                  decoration: InputDecoration(
                                    hintStyle: TextStyle(
                                        color: colorText, fontFamily: font),
                                    hintText: ' Take Home',
                                    filled: true,
                                    fillColor: tfBackgroundColor,
                                    contentPadding:
                                        EdgeInsets.fromLTRB(10.0, 5.0, 10.0, 5.0),
                                    focusedBorder: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(25.0),
                                      borderSide: BorderSide.none,
                                    ),
                                    enabledBorder: UnderlineInputBorder(
                                      borderSide: BorderSide.none,
                                      borderRadius: BorderRadius.circular(25.7),
                                    ),
                                  ),
                                  // decoration:
                                  //     InputDecoration(labelText: "Take Home"),
                                  // validator: (value) {
                                  //   if (value.isEmpty) {
                                  //     return 'Please enter task';
                                  //   }
                                  // },
                                ),
                              ],
                            ),
                          ),
                          Container(
                            padding: EdgeInsets.only(top: 20),
                            margin: EdgeInsets.only(left: 20, right: 20),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: <Widget>[
                                // Text(
                                //   'First Name: ',
                                //   style:
                                //       TextStyle(fontSize: ScreenUtil().setSp(15)),
                                //   textAlign: TextAlign.start,
                                // ),
                                TextFormField(
                                  // controller: taskController,
                                  //autofocus: true,
                                  maxLines: null,
                                  decoration: InputDecoration(
                                    hintStyle: TextStyle(
                                        color: colorText, fontFamily: font),
                                    hintText: ' Gross Salary',
                                    filled: true,
                                    fillColor: tfBackgroundColor,
                                    contentPadding:
                                        EdgeInsets.fromLTRB(10.0, 5.0, 10.0, 5.0),
                                    focusedBorder: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(25.0),
                                      borderSide: BorderSide.none,
                                    ),
                                    enabledBorder: UnderlineInputBorder(
                                      borderSide: BorderSide.none,
                                      borderRadius: BorderRadius.circular(25.7),
                                    ),
                                  ),
                                  // decoration:
                                  //     InputDecoration(labelText: "Gross Salary"),
                                  // validator: (value) {
                                  //   if (value.isEmpty) {
                                  //     return 'Please enter task';
                                  //   }
                                  // },
                                ),
                              ],
                            ),
                          ),
                          Container(
                            padding: EdgeInsets.only(top: 20),
                            margin: EdgeInsets.only(left: 20, right: 20),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: <Widget>[
                                // Text(
                                //   'First Name: ',
                                //   style:
                                //       TextStyle(fontSize: ScreenUtil().setSp(15)),
                                //   textAlign: TextAlign.start,
                                // ),
                                TextFormField(
                                  // controller: taskController,
                                  //autofocus: true,
                                  maxLines: null,
                                  decoration: InputDecoration(
                                    hintStyle: TextStyle(
                                        color: colorText, fontFamily: font),
                                    hintText: ' Marital Status',
                                    filled: true,
                                    fillColor: tfBackgroundColor,
                                    contentPadding:
                                        EdgeInsets.fromLTRB(10.0, 5.0, 10.0, 5.0),
                                    focusedBorder: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(25.0),
                                      borderSide: BorderSide.none,
                                    ),
                                    enabledBorder: UnderlineInputBorder(
                                      borderSide: BorderSide.none,
                                      borderRadius: BorderRadius.circular(25.7),
                                    ),
                                  ),
                                  // decoration: InputDecoration(labelText: "CTC"),
                                  // validator: (value) {
                                  //   if (value.isEmpty) {
                                  //     return 'Please enter task';
                                  //   }
                                  // },
                                ),
                              ],
                            ),
                          ),
                          SizedBox(height: 10),
      
                          // Container(
                          //   padding: EdgeInsets.only(top: 10),
                          //   margin: EdgeInsets.only(left: 20, right: 20),
                          //   child: Column(
                          //     crossAxisAlignment: CrossAxisAlignment.start,
                          //     children: <Widget>[
                          //       Text(
                          //         'Marital Status: ',
                          //         style:
                          //             TextStyle(fontSize: ScreenUtil().setSp(15)),
                          //         textAlign: TextAlign.start,
                          //       ),
                          //       drop,
                          //     ],
                          //   ),
                          // ),
      
                          Container(
                            padding: EdgeInsets.only(top: 20),
                            margin: EdgeInsets.only(left: 20, right: 20),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: <Widget>[
                                // Text(
                                //   'Middle Name: ',
                                //   style:
                                //       TextStyle(fontSize: ScreenUtil().setSp(15)),
                                //   textAlign: TextAlign.start,
                                // ),
                                TextFormField(
                                  // controller: taskController,
                                  //autofocus: true,
                                  maxLines: null,
                                  decoration: InputDecoration(
                                    hintStyle: TextStyle(
                                        color: colorText, fontFamily: font),
                                    hintText: ' UAN Number',
                                    filled: true,
                                    fillColor: tfBackgroundColor,
                                    contentPadding:
                                        EdgeInsets.fromLTRB(10.0, 5.0, 10.0, 5.0),
                                    focusedBorder: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(25.0),
                                      borderSide: BorderSide.none,
                                    ),
                                    enabledBorder: UnderlineInputBorder(
                                      borderSide: BorderSide.none,
                                      borderRadius: BorderRadius.circular(25.7),
                                    ),
                                  ),
                                  // decoration:
                                  //     InputDecoration(labelText: "UAN number"),
                                  // validator: (value) {
                                  //   if (value.isEmpty) {
                                  //     return 'Please enter task';
                                  //   }
                                  // },
                                ),
                              ],
                            ),
                          ),
      
                          Container(
                            padding: EdgeInsets.only(top: 20),
                            margin: EdgeInsets.only(left: 20, right: 20),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: <Widget>[
                                // Text(
                                //   'Middle Name: ',
                                //   style:
                                //       TextStyle(fontSize: ScreenUtil().setSp(15)),
                                //   textAlign: TextAlign.start,
                                // ),
                                TextFormField(
                                  // controller: taskController,
                                  //autofocus: true,
                                  maxLines: null,
                                  decoration: InputDecoration(
                                    hintStyle: TextStyle(
                                        color: colorText, fontFamily: font),
                                    hintText: ' ESIC Number',
                                    filled: true,
                                    fillColor: tfBackgroundColor,
                                    contentPadding:
                                        EdgeInsets.fromLTRB(10.0, 5.0, 10.0, 5.0),
                                    focusedBorder: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(25.0),
                                      borderSide: BorderSide.none,
                                    ),
                                    enabledBorder: UnderlineInputBorder(
                                      borderSide: BorderSide.none,
                                      borderRadius: BorderRadius.circular(25.7),
                                    ),
                                  ),
                                  // decoration:
                                  //     InputDecoration(labelText: "ESIC Number"),
                                  // validator: (value) {
                                  //   if (value.isEmpty) {
                                  //     return 'Please enter task';
                                  //   }
                                  // },
                                ),
                              ],
                            ),
                          ),
      
                          Padding(
                            padding: const EdgeInsets.all(10.0),
                            child: Row(
                              children: [
                                Container(
                                    padding: EdgeInsets.only(
                                      top: 20,
                                    ),
                                    height: 55,
                                    margin: EdgeInsets.all(0),
                                    child: ElevatedButton(
                                      style: ElevatedButton.styleFrom(
                                          elevation: 5,
                                          textStyle:
                                              TextStyle(color: appBackground),
                                          padding: const EdgeInsets.all(0.0),
                                          shape: RoundedRectangleBorder(
                                              borderRadius:
                                                  BorderRadius.circular(20.0))),
                                      child: Container(
                                        decoration: const BoxDecoration(
                                            color: btnBgColor,
                                            borderRadius: BorderRadius.all(
                                                Radius.circular(20.0))),
                                        padding: const EdgeInsets.fromLTRB(
                                            50, 7, 50, 7),
                                        child: const Text('Prev  ',
                                            style: TextStyle(
                                                color: appBackground,
                                                fontSize: 17)),
                                      ),
                                      onPressed: () {
                                        setState(() {
                                          _secondFormvisible = false;
                                          _isVisible = true;
                                        });
                                      },
                                    )),
                                Expanded(child: Text("")),
                                Container(
                                    padding: EdgeInsets.only(
                                      top: 20,
                                    ),
                                    height: 55,
                                    margin: EdgeInsets.all(0),
                                    child: ElevatedButton(
                                      style: ElevatedButton.styleFrom(
                                          elevation: 5,
                                          textStyle:
                                              TextStyle(color: appBackground),
                                          padding: const EdgeInsets.all(0.0),
                                          shape: RoundedRectangleBorder(
                                              borderRadius:
                                                  BorderRadius.circular(20.0))),
                                      child: Container(
                                        decoration: const BoxDecoration(
                                            color: btnBgColor,
                                            borderRadius: BorderRadius.all(
                                                Radius.circular(20.0))),
                                        padding: const EdgeInsets.fromLTRB(
                                            50, 7, 50, 7),
                                        child: const Text('Next',
                                            style: TextStyle(
                                                color: appBackground,
                                                fontSize: 17)),
                                      ),
                                      onPressed: () {
                                        setState(() {
                                          _secondFormvisible = false;
                                          _thirdFormvisible = true;
                                        });
                                      },
                                    )),
                              ],
                            ),
                          ),
      
                          SizedBox(
                            height: 30,
                          ),
                          // loadAttendanceStatus(),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
              //third form
              Visibility(
                visible: _thirdFormvisible,
                child: Form(
                  key: formkey,
                  child: Padding(
                    padding: EdgeInsets.only(
                        top: ScreenUtil().setSp(90),
                        left: ScreenUtil().setSp(20),
                        right: ScreenUtil().setSp(20),
                        bottom: ScreenUtil().setSp(20)),
                    child: Card(
                      color: appBackgroundColor,
                      elevation: 5,
                      child: ListView(
                        children: <Widget>[
                          Padding(
                            padding: EdgeInsets.all(5),
                            child: Text(
                              'Passport details',
                              // '${DateFormat(' dd, MMM yyyy').format(DateTime.now())}',
                              style: titleStyle,
                              textAlign: TextAlign.center,
                            ),
                          ),
      
                          Container(
                            padding: const EdgeInsets.only(top: 0, bottom: 20),
                            margin: EdgeInsets.only(left: 20, right: 20),
                            child: Row(
                              children: <Widget>[
                                Expanded(
                                  child: TextFormField(
                                    // controller: taskController,
                                    //autofocus: true,
                                    maxLines: null,
                                    decoration: InputDecoration(
                                      hintStyle: TextStyle(
                                          color: colorText, fontFamily: font),
                                      hintText: ' Passport Number',
                                      filled: true,
                                      fillColor: tfBackgroundColor,
                                      contentPadding: EdgeInsets.fromLTRB(
                                          10.0, 5.0, 10.0, 5.0),
                                      focusedBorder: OutlineInputBorder(
                                        borderRadius: BorderRadius.circular(25.0),
                                        borderSide: BorderSide.none,
                                      ),
                                      enabledBorder: UnderlineInputBorder(
                                        borderSide: BorderSide.none,
                                        borderRadius: BorderRadius.circular(25.7),
                                      ),
                                    ),
                                    // decoration: InputDecoration(
                                    //     labelText: "Passport Number"),
                                    // validator: (value) {
                                    //   if (value.isEmpty) {
                                    //     return 'Please enter task';
                                    //   }
                                    // },
                                  ),
                                ),
                                SizedBox(
                                  width: 15,
                                ),
                                Expanded(
                                  child: TextFormField(
                                    controller: taskController,
                                    //autofocus: true,
                                    maxLines: null,
                                    decoration: InputDecoration(
                                      hintStyle: TextStyle(
                                          color: colorText, fontFamily: font),
                                      hintText: ' Passport issue Date',
                                      filled: true,
                                      fillColor: tfBackgroundColor,
                                      contentPadding: EdgeInsets.fromLTRB(
                                          10.0, 5.0, 10.0, 5.0),
                                      focusedBorder: OutlineInputBorder(
                                        borderRadius: BorderRadius.circular(25.0),
                                        borderSide: BorderSide.none,
                                      ),
                                      enabledBorder: UnderlineInputBorder(
                                        borderSide: BorderSide.none,
                                        borderRadius: BorderRadius.circular(25.7),
                                      ),
                                    ),
      
                                    // decoration: InputDecoration(
                                    //     labelText: "Passport Issue Date"),
                                    // validator: (value) {
                                    //   if (value.isEmpty) {
                                    //     return 'Please enter task';
                                    //   }
                                    // },
                                  ),
                                )
                              ],
                            ),
                          ),
                          Container(
                            padding: const EdgeInsets.only(top: 0, bottom: 20),
                            margin: EdgeInsets.only(left: 20, right: 20),
                            child: Row(
                              children: <Widget>[
                                Expanded(
                                  child: TextFormField(
                                    // controller: taskController,
                                    //autofocus: true,
                                    maxLines: null,
                                    decoration: InputDecoration(
                                      hintStyle: TextStyle(
                                          color: colorText, fontFamily: font),
                                      hintText: ' Passport Expiry Date',
                                      filled: true,
                                      fillColor: tfBackgroundColor,
                                      contentPadding: EdgeInsets.fromLTRB(
                                          10.0, 5.0, 10.0, 5.0),
                                      focusedBorder: OutlineInputBorder(
                                        borderRadius: BorderRadius.circular(25.0),
                                        borderSide: BorderSide.none,
                                      ),
                                      enabledBorder: UnderlineInputBorder(
                                        borderSide: BorderSide.none,
                                        borderRadius: BorderRadius.circular(25.7),
                                      ),
                                    ),
                                    // decoration: InputDecoration(
                                    //     labelText: "Passport Expiry Date"),
                                    // validator: (value) {
                                    //   if (value.isEmpty) {
                                    //     return 'Please enter task';
                                    //   }
                                    // },
                                  ),
                                ),
                                SizedBox(
                                  width: 15,
                                ),
                                Expanded(
                                  child: TextFormField(
                                    controller: taskController,
                                    //autofocus: true,
                                    maxLines: null,
                                    decoration: InputDecoration(
                                      hintStyle: TextStyle(
                                          color: colorText, fontFamily: font),
                                      hintText: ' NIC Number',
                                      filled: true,
                                      fillColor: tfBackgroundColor,
                                      contentPadding: EdgeInsets.fromLTRB(
                                          10.0, 5.0, 10.0, 5.0),
                                      focusedBorder: OutlineInputBorder(
                                        borderRadius: BorderRadius.circular(25.0),
                                        borderSide: BorderSide.none,
                                      ),
                                      enabledBorder: UnderlineInputBorder(
                                        borderSide: BorderSide.none,
                                        borderRadius: BorderRadius.circular(25.7),
                                      ),
                                    ),
                                    // decoration:
                                    //     InputDecoration(labelText: "NIC Number"),
                                    // validator: (value) {
                                    //   if (value.isEmpty) {
                                    //     return 'Please enter task';
                                    //   }
                                    // },
                                  ),
                                )
                              ],
                            ),
                          ),
      
                          SizedBox(
                            height: 15,
                          ),
                          Padding(
                            padding: EdgeInsets.all(5),
                            child: Text(
                              'Visa Details',
                              // '${DateFormat(' dd, MMM yyyy').format(DateTime.now())}',
                              style: titleStyle,
                              textAlign: TextAlign.center,
                            ),
                          ),
                          Container(
                            padding: const EdgeInsets.only(top: 0, bottom: 20),
                            margin: EdgeInsets.only(left: 20, right: 20),
                            child: Row(
                              children: <Widget>[
                                Expanded(
                                  child: TextFormField(
                                    // controller: taskController,
                                    //autofocus: true,
                                    maxLines: null,
                                    decoration: InputDecoration(
                                      hintStyle: TextStyle(
                                          color: colorText, fontFamily: font),
                                      hintText: ' Visa Number',
                                      filled: true,
                                      fillColor: tfBackgroundColor,
                                      contentPadding: EdgeInsets.fromLTRB(
                                          10.0, 5.0, 10.0, 5.0),
                                      focusedBorder: OutlineInputBorder(
                                        borderRadius: BorderRadius.circular(25.0),
                                        borderSide: BorderSide.none,
                                      ),
                                      enabledBorder: UnderlineInputBorder(
                                        borderSide: BorderSide.none,
                                        borderRadius: BorderRadius.circular(25.7),
                                      ),
                                    ),
                                    // decoration:
                                    //     InputDecoration(labelText: "Visa Number"),
                                    // validator: (value) {
                                    //   if (value.isEmpty) {
                                    //     return 'Please enter task';
                                    //   }
                                    // },
                                  ),
                                ),
                                SizedBox(
                                  width: 15,
                                ),
                                Expanded(
                                  child: TextFormField(
                                    controller: taskController,
                                    //autofocus: true,
                                    maxLines: null,
                                    decoration: InputDecoration(
                                      hintStyle: TextStyle(
                                          color: colorText, fontFamily: font),
                                      hintText: 'visa Issue Date',
                                      filled: true,
                                      fillColor: tfBackgroundColor,
                                      contentPadding: EdgeInsets.fromLTRB(
                                          10.0, 5.0, 10.0, 5.0),
                                      focusedBorder: OutlineInputBorder(
                                        borderRadius: BorderRadius.circular(25.0),
                                        borderSide: BorderSide.none,
                                      ),
                                      enabledBorder: UnderlineInputBorder(
                                        borderSide: BorderSide.none,
                                        borderRadius: BorderRadius.circular(25.7),
                                      ),
                                    ),
                                    // decoration: InputDecoration(
                                    //     labelText: "Visa Issue Date"),
                                    // validator: (value) {
                                    //   if (value.isEmpty) {
                                    //     return 'Please enter task';
                                    //   }
                                    // },
                                  ),
                                )
                              ],
                            ),
                          ),
                          Container(
                            padding: const EdgeInsets.only(top: 0, bottom: 20),
                            margin: EdgeInsets.only(left: 20, right: 20),
                            child: Row(
                              children: <Widget>[
                                Expanded(
                                  child: TextFormField(
                                    // controller: taskController,
                                    //autofocus: true,
                                    maxLines: null,
                                    decoration: InputDecoration(
                                      hintStyle: TextStyle(
                                          color: colorText, fontFamily: font),
                                      hintText: ' Visa Expiry Date',
                                      filled: true,
                                      fillColor: tfBackgroundColor,
                                      contentPadding: EdgeInsets.fromLTRB(
                                          10.0, 5.0, 10.0, 5.0),
                                      focusedBorder: OutlineInputBorder(
                                        borderRadius: BorderRadius.circular(25.0),
                                        borderSide: BorderSide.none,
                                      ),
                                      enabledBorder: UnderlineInputBorder(
                                        borderSide: BorderSide.none,
                                        borderRadius: BorderRadius.circular(25.7),
                                      ),
                                    ),
                                    // decoration: InputDecoration(
                                    //     labelText: "Visa Expiry Date"),
                                    // validator: (value) {
                                    //   if (value.isEmpty) {
                                    //     return 'Please enter task';
                                    //   }
                                    // },
                                  ),
                                ),
                                SizedBox(
                                  width: 15,
                                ),
                                Expanded(
                                  child: TextFormField(
                                    // controller: taskController,
                                    //autofocus: true,
                                    maxLines: null,
                                    decoration: InputDecoration(
                                      hintStyle: TextStyle(
                                          color: colorText, fontFamily: font),
                                      hintText: ' Visa Status',
                                      filled: true,
                                      fillColor: tfBackgroundColor,
                                      contentPadding: EdgeInsets.fromLTRB(
                                          10.0, 5.0, 10.0, 5.0),
                                      focusedBorder: OutlineInputBorder(
                                        borderRadius: BorderRadius.circular(25.0),
                                        borderSide: BorderSide.none,
                                      ),
                                      enabledBorder: UnderlineInputBorder(
                                        borderSide: BorderSide.none,
                                        borderRadius: BorderRadius.circular(25.7),
                                      ),
                                    ),
                                    // decoration:
                                    //     InputDecoration(labelText: "Visa Status"),
                                    // validator: (value) {
                                    //   if (value.isEmpty) {
                                    //     return 'Please enter task';
                                    //   }
                                    // },
                                  ),
                                )
                              ],
                            ),
                          ),
                          SizedBox(
                            height: 15,
                          ),
                          Padding(
                            padding: EdgeInsets.all(5),
                            child: Text(
                              'Emirates /license Details',
                              // '${DateFormat(' dd, MMM yyyy').format(DateTime.now())}',
                              style: titleStyle,
                              textAlign: TextAlign.center,
                            ),
                          ),
                          Container(
                            padding: const EdgeInsets.only(top: 0, bottom: 20),
                            margin: EdgeInsets.only(left: 20, right: 20),
                            child: Row(
                              children: <Widget>[
                                Expanded(
                                  child: TextFormField(
                                    // controller: taskController,
                                    //autofocus: true,
                                    maxLines: null,
                                    decoration: InputDecoration(
                                      hintStyle: TextStyle(
                                          color: colorText, fontFamily: font),
                                      hintText: ' Emirates',
                                      filled: true,
                                      fillColor: tfBackgroundColor,
                                      contentPadding: EdgeInsets.fromLTRB(
                                          10.0, 5.0, 10.0, 5.0),
                                      focusedBorder: OutlineInputBorder(
                                        borderRadius: BorderRadius.circular(25.0),
                                        borderSide: BorderSide.none,
                                      ),
                                      enabledBorder: UnderlineInputBorder(
                                        borderSide: BorderSide.none,
                                        borderRadius: BorderRadius.circular(25.7),
                                      ),
                                    ),
                                    // decoration:
                                    //     InputDecoration(labelText: "Emirates"),
                                    // validator: (value) {
                                    //   if (value.isEmpty) {
                                    //     return 'Please enter task';
                                    //   }
                                    // },
                                  ),
                                ),
                                SizedBox(
                                  width: 15,
                                ),
                                Expanded(
                                  child: TextFormField(
                                    controller: taskController,
                                    //autofocus: true,
                                    maxLines: null,
                                    decoration: InputDecoration(
                                      hintStyle: TextStyle(
                                          color: colorText, fontFamily: font),
                                      hintText: ' Emirates Code',
                                      filled: true,
                                      fillColor: tfBackgroundColor,
                                      contentPadding: EdgeInsets.fromLTRB(
                                          10.0, 5.0, 10.0, 5.0),
                                      focusedBorder: OutlineInputBorder(
                                        borderRadius: BorderRadius.circular(25.0),
                                        borderSide: BorderSide.none,
                                      ),
                                      enabledBorder: UnderlineInputBorder(
                                        borderSide: BorderSide.none,
                                        borderRadius: BorderRadius.circular(25.7),
                                      ),
                                    ),
                                    // decoration: InputDecoration(
                                    //     labelText: "Emirates Code"),
                                    // validator: (value) {
                                    //   if (value.isEmpty) {
                                    //     return 'Please enter task';
                                    //   }
                                    // },
                                  ),
                                )
                              ],
                            ),
                          ),
                          Container(
                            padding: const EdgeInsets.only(top: 0, bottom: 20),
                            margin: EdgeInsets.only(left: 20, right: 20),
                            child: Row(
                              children: <Widget>[
                                Expanded(
                                  child: TextFormField(
                                    // controller: taskController,
                                    //autofocus: true,
                                    maxLines: null,
                                    decoration: InputDecoration(
                                      hintStyle: TextStyle(
                                          color: colorText, fontFamily: font),
                                      hintText: ' Emirates Expiry Date',
                                      filled: true,
                                      fillColor: tfBackgroundColor,
                                      contentPadding: EdgeInsets.fromLTRB(
                                          10.0, 5.0, 10.0, 5.0),
                                      focusedBorder: OutlineInputBorder(
                                        borderRadius: BorderRadius.circular(25.0),
                                        borderSide: BorderSide.none,
                                      ),
                                      enabledBorder: UnderlineInputBorder(
                                        borderSide: BorderSide.none,
                                        borderRadius: BorderRadius.circular(25.7),
                                      ),
                                    ),
                                    // decoration: InputDecoration(
                                    //     labelText: "Emirates Expiry Date"),
                                    // validator: (value) {
                                    //   if (value.isEmpty) {
                                    //     return 'Please enter task';
                                    //   }
                                    // },
                                  ),
                                ),
                                SizedBox(
                                  width: 15,
                                ),
                                Expanded(
                                  child: TextFormField(
                                    controller: taskController,
                                    //autofocus: true,
                                    maxLines: null,
                                    decoration: InputDecoration(
                                      hintStyle: TextStyle(
                                          color: colorText, fontFamily: font),
                                      hintText: ' License Number',
                                      filled: true,
                                      fillColor: tfBackgroundColor,
                                      contentPadding: EdgeInsets.fromLTRB(
                                          10.0, 5.0, 10.0, 5.0),
                                      focusedBorder: OutlineInputBorder(
                                        borderRadius: BorderRadius.circular(25.0),
                                        borderSide: BorderSide.none,
                                      ),
                                      enabledBorder: UnderlineInputBorder(
                                        borderSide: BorderSide.none,
                                        borderRadius: BorderRadius.circular(25.7),
                                      ),
                                    ),
                                    // decoration: InputDecoration(
                                    //     labelText: "License number"),
                                    // validator: (value) {
                                    //   if (value.isEmpty) {
                                    //     return 'Please enter task';
                                    //   }
                                    // },
                                  ),
                                )
                              ],
                            ),
                          ),
                          Container(
                            padding: const EdgeInsets.only(top: 0, bottom: 20),
                            margin: EdgeInsets.only(left: 20, right: 20),
                            child: Row(
                              children: <Widget>[
                                Expanded(
                                  child: TextFormField(
                                    // controller: taskController,
                                    //autofocus: true,
                                    maxLines: null,
                                    decoration: InputDecoration(
                                      hintStyle: TextStyle(
                                          color: colorText, fontFamily: font),
                                      hintText: ' License Expiry',
                                      filled: true,
                                      fillColor: tfBackgroundColor,
                                      contentPadding: EdgeInsets.fromLTRB(
                                          10.0, 5.0, 10.0, 5.0),
                                      focusedBorder: OutlineInputBorder(
                                        borderRadius: BorderRadius.circular(25.0),
                                        borderSide: BorderSide.none,
                                      ),
                                      enabledBorder: UnderlineInputBorder(
                                        borderSide: BorderSide.none,
                                        borderRadius: BorderRadius.circular(25.7),
                                      ),
                                    ),
                                    // decoration: InputDecoration(
                                    //     labelText: "License Expiry"),
                                    // validator: (value) {
                                    //   if (value.isEmpty) {
                                    //     return 'Please enter task';
                                    //   }
                                    // },
                                  ),
                                ),
                                SizedBox(
                                  width: 15,
                                ),
                                Expanded(
                                  child: TextFormField(
                                    // controller: taskController,
                                    //autofocus: true,
                                    maxLines: null,
                                    decoration: InputDecoration(
                                      hintStyle: TextStyle(
                                          color: colorText, fontFamily: font),
                                      hintText: ' License Type',
                                      filled: true,
                                      fillColor: tfBackgroundColor,
                                      contentPadding: EdgeInsets.fromLTRB(
                                          10.0, 5.0, 10.0, 5.0),
                                      focusedBorder: OutlineInputBorder(
                                        borderRadius: BorderRadius.circular(25.0),
                                        borderSide: BorderSide.none,
                                      ),
                                      enabledBorder: UnderlineInputBorder(
                                        borderSide: BorderSide.none,
                                        borderRadius: BorderRadius.circular(25.7),
                                      ),
                                    ),
                                    // decoration: InputDecoration(
                                    //     labelText: "License Type"),
                                    // validator: (value) {
                                    //   if (value.isEmpty) {
                                    //     return 'Please enter task';
                                    //   }
                                    // },
                                  ),
                                )
                              ],
                            ),
                          ),
                          Padding(
                            padding: EdgeInsets.all(5),
                            child: Text(
                              'Bank details',
                              // '${DateFormat(' dd, MMM yyyy').format(DateTime.now())}',
                              style: titleStyle,
                              textAlign: TextAlign.center,
                            ),
                          ),
                          Container(
                            padding: const EdgeInsets.only(top: 0, bottom: 20),
                            margin: EdgeInsets.only(left: 20, right: 20),
                            child: Row(
                              children: <Widget>[
                                Expanded(
                                  child: TextFormField(
                                    // controller: taskController,
                                    //autofocus: true,
                                    maxLines: null,
                                    decoration: InputDecoration(
                                      hintStyle: TextStyle(
                                          color: colorText, fontFamily: font),
                                      hintText: ' Bank Name',
                                      filled: true,
                                      fillColor: tfBackgroundColor,
                                      contentPadding: EdgeInsets.fromLTRB(
                                          10.0, 5.0, 10.0, 5.0),
                                      focusedBorder: OutlineInputBorder(
                                        borderRadius: BorderRadius.circular(25.0),
                                        borderSide: BorderSide.none,
                                      ),
                                      enabledBorder: UnderlineInputBorder(
                                        borderSide: BorderSide.none,
                                        borderRadius: BorderRadius.circular(25.7),
                                      ),
                                    ),
                                    // decoration:
                                    //     InputDecoration(labelText: "Bank Name"),
                                    // validator: (value) {
                                    //   if (value.isEmpty) {
                                    //     return 'Please enter task';
                                    //   }
                                    // },
                                  ),
                                ),
                                SizedBox(
                                  width: 15,
                                ),
                                Expanded(
                                  child: TextFormField(
                                    controller: taskController,
                                    //autofocus: true,
                                    maxLines: null,
                                    decoration: InputDecoration(
                                      hintStyle: TextStyle(
                                          color: colorText, fontFamily: font),
                                      hintText: ' Account Number',
                                      filled: true,
                                      fillColor: tfBackgroundColor,
                                      contentPadding: EdgeInsets.fromLTRB(
                                          10.0, 5.0, 10.0, 5.0),
                                      focusedBorder: OutlineInputBorder(
                                        borderRadius: BorderRadius.circular(25.0),
                                        borderSide: BorderSide.none,
                                      ),
                                      enabledBorder: UnderlineInputBorder(
                                        borderSide: BorderSide.none,
                                        borderRadius: BorderRadius.circular(25.7),
                                      ),
                                    ),
                                    // decoration: InputDecoration(
                                    //     labelText: "Account Number"),
                                    // validator: (value) {
                                    //   if (value.isEmpty) {
                                    //     return 'Please enter task';
                                    //   }
                                    // },
                                  ),
                                )
                              ],
                            ),
                          ),
                          Container(
                            padding: const EdgeInsets.only(top: 0, bottom: 20),
                            margin: EdgeInsets.only(left: 20, right: 20),
                            child: Row(
                              children: <Widget>[
                                Expanded(
                                  child: TextFormField(
                                    // controller: taskController,
                                    //autofocus: true,
                                    maxLines: null,
                                    decoration: InputDecoration(
                                      hintStyle: TextStyle(
                                          color: colorText, fontFamily: font),
                                      hintText: ' IFSC Code',
                                      filled: true,
                                      fillColor: tfBackgroundColor,
                                      contentPadding: EdgeInsets.fromLTRB(
                                          10.0, 5.0, 10.0, 5.0),
                                      focusedBorder: OutlineInputBorder(
                                        borderRadius: BorderRadius.circular(25.0),
                                        borderSide: BorderSide.none,
                                      ),
                                      enabledBorder: UnderlineInputBorder(
                                        borderSide: BorderSide.none,
                                        borderRadius: BorderRadius.circular(25.7),
                                      ),
                                    ),
                                    // decoration:
                                    //     InputDecoration(labelText: "IFSC Code"),
                                    // validator: (value) {
                                    //   if (value.isEmpty) {
                                    //     return 'Please enter task';
                                    //   }
                                    // },
                                  ),
                                ),
                                SizedBox(
                                  width: 15,
                                ),
                                Expanded(
                                  child: TextFormField(
                                    controller: taskController,
                                    //autofocus: true,
                                    maxLines: null,
                                    decoration: InputDecoration(
                                      hintStyle: TextStyle(
                                          color: colorText, fontFamily: font),
                                      hintText: ' IBAN',
                                      filled: true,
                                      fillColor: tfBackgroundColor,
                                      contentPadding: EdgeInsets.fromLTRB(
                                          10.0, 5.0, 10.0, 5.0),
                                      focusedBorder: OutlineInputBorder(
                                        borderRadius: BorderRadius.circular(25.0),
                                        borderSide: BorderSide.none,
                                      ),
                                      enabledBorder: UnderlineInputBorder(
                                        borderSide: BorderSide.none,
                                        borderRadius: BorderRadius.circular(25.7),
                                      ),
                                    ),
                                    // decoration:
                                    //     InputDecoration(labelText: "IBAN"),
                                    // validator: (value) {
                                    //   if (value.isEmpty) {
                                    //     return 'Please enter task';
                                    //   }
                                    // },
                                  ),
                                )
                              ],
                            ),
                          ),
      
                          Padding(
                            padding: const EdgeInsets.all(10.0),
                            child: Row(
                              children: [
                                Container(
                                    padding: EdgeInsets.only(
                                      top: 20,
                                    ),
                                    height: 55,
                                    margin: EdgeInsets.all(0),
                                    child: ElevatedButton(
                                      style: ElevatedButton.styleFrom(
                                          elevation: 5,
                                          textStyle:
                                              TextStyle(color: Colors.white),
                                          padding: const EdgeInsets.all(0.0),
                                          shape: RoundedRectangleBorder(
                                              borderRadius:
                                                  BorderRadius.circular(20.0))),
                                      child: Container(
                                        decoration: const BoxDecoration(
                                            color: btnBgColor,
                                            // gradient: LinearGradient(
                                            //   colors: <Color>[
                                            //     Color.fromRGBO(255, 81, 54, 1),
                                            //     Color.fromRGBO(255, 163, 54, 1),
                                            //   ],
                                            // ),
                                            borderRadius: BorderRadius.all(
                                                Radius.circular(20.0))),
                                        padding: const EdgeInsets.fromLTRB(
                                            50, 7, 50, 7),
                                        child: const Text('Prev  ',
                                            style: TextStyle(
                                                color: appBackgroundColor,
                                                fontSize: 17)),
                                      ),
                                      onPressed: () {
                                        setState(() {
                                          _thirdFormvisible = false;
                                          _secondFormvisible = true;
                                        });
                                      },
                                    )),
                                Expanded(child: Text("")),
                                Container(
                                    padding: EdgeInsets.only(
                                      top: 20,
                                    ),
                                    height: 55,
                                    margin: EdgeInsets.all(0),
                                    child: ElevatedButton(
                                      style: ElevatedButton.styleFrom(
                                          elevation: 5,
                                          textStyle:
                                              TextStyle(color: Colors.white),
                                          padding: const EdgeInsets.all(0.0),
                                          shape: RoundedRectangleBorder(
                                              borderRadius:
                                                  BorderRadius.circular(20.0))),
                                      child: Container(
                                        decoration: const BoxDecoration(
                                            color: btnBgColor,
      
                                            // gradient: LinearGradient(
                                            //   colors: <Color>[
                                            //     Color.fromRGBO(255, 81, 54, 1),
                                            //     Color.fromRGBO(255, 163, 54, 1),
                                            //   ],
                                            // ),
                                            borderRadius: BorderRadius.all(
                                                Radius.circular(20.0))),
                                        padding: const EdgeInsets.fromLTRB(
                                            50, 7, 50, 7),
                                        child: const Text('Submit',
                                            style: TextStyle(
                                                color: appBackgroundColor,
                                                fontSize: 17)),
                                      ),
                                      onPressed: () {
                                        Navigator.pop(context);
                                      },
                                    )),
                              ],
                            ),
                          ),
      
                          SizedBox(
                            height: 30,
                          ),
                          // loadAttendanceStatus(),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
      
              //  AppLoaderView(),
            ],
          ),
        ),
      ),
    );
  }

  getClientList() async {
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
      map["companyId"] = "120";
      _networkUtil.post(apiGetClientList, body: map).then((dynamic res) {
        activeListApi = ClientListApiCallBack.fromJson(res);
        AppLog.showLog(res.toString());
        if (activeListApi.success) {
          setState(() {});
        } else {
          showBottomToast(activeListApi.message);
        }
      });
    } catch (e) {}
    return 'success';
  }

  getProjectList() async {
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
      map["clientId"] = _clientDropdownValue;

      _networkUtil.post(apiGetProjectList, body: map).then((dynamic res) {
        _projectListCallBack = ProjectListCallBack.fromJson(res);
        AppLog.showLog(res.toString());
        if (_projectListCallBack.data!.length == 0) {
          setState(() {});
          showCenterToast('No project found contact to Admin');
        }

        if (_projectListCallBack.success) {
          setState(() {});
        } else {
          showBottomToast(_projectListCallBack.message?? "");
        }
      });
    } catch (e) {
      print(e.toString());
    }
    return 'success';
  }

  getTaskTypeList() async {
    try {
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
      _networkUtil.post(apiGetTaskType, body: map).then((dynamic res) {
        _taskTypeCallBack = TaskTypeCallBack.fromJson(res);
        AppLog.showLog(res.toString());
        if (_taskTypeCallBack.success) {
          setState(() {});
        } else {
          showBottomToast(_taskTypeCallBack.message?? "");
        }
      });
    } catch (e) {
      print('TASK');
      print(e.toString());
    }
    return 'success';
  }

  Future addTask() async {
    final SharedPreferences prefs = await _prefs;
    int? id = prefs.getInt(SP_ID);
    _apiToken = prefs.getString(SP_API_TOKEN)!;

    if (isnewtask == true) {
      newtask = '1';
    } else {
      newtask = '0';
    }
    String minutes = hrsToMin();
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
      map["taskDate"] = DateFormat('yyyy-MM-dd').format(DateTime.now().toUtc());
      map["clientId"] = _clientDropdownValue;
      map["projectId"] = _projectDropdownValue;
      map["task"] = taskController.text;
      map["minutes"] = minutes;
      map["is_new"] = newtask;
      map["taskType"] = _typeDropdownValue;

      print('PARAMS: $map');
      showLoader(_context);
      _networkUtil.post(apiAddTask, body: map).then((dynamic res) {
        _projectListCallBack = ProjectListCallBack.fromJson(res);
        AppLog.showLog(res.toString());
        if (res['success'] == true) {
          showCenterToast('Task Added');
          _uploadAttendanceLocationApiCall('7');
        } else {
          Navigator.pop(_context);
          Navigator.of(context).pop({'reload': true});
        }
      });
    } catch (e) {
      Navigator.pop(_context);
      print(e.toString());
      showCenterToast(errorApiCall);
    }
    return 'success';
  }

  String hrsToMin() {
    var hrs = int.parse(_hrstDropdownValue?? "");
    var min = int.parse(_minDropdownValue?? "");
    var time = (hrs * 60) + min;
    return time.toString();
  }

  clear() {
    formkey.currentState?.reset();
    taskController.clear();
    isnewtask = false;
    isMoreTask = false;
    _clientDropdownValue = '';
    _projectDropdownValue = '';
    _hrstDropdownValue = '';
    _minDropdownValue = '';
    _typeDropdownValue = '';
  }

  void _uploadAttendanceLocationApiCall(String _attendanceType) async {

    geo.Position position = await geo.Geolocator.getCurrentPosition(
        desiredAccuracy: geo.LocationAccuracy.best);

    await geo.Geolocator.getCurrentPosition(
            desiredAccuracy: geo.LocationAccuracy.high)
        .then((geo.Position position) async {
      List<loc.Placemark> placemarks = await loc.placemarkFromCoordinates(
          position.latitude, position.longitude);

      if (placemarks.isNotEmpty) {
        loc.Placemark currentPlace = placemarks[0];
        setState(() {
          _currentPosition = position;
          _currentAddress =
              "${currentPlace.street}, ${currentPlace.subLocality}, ${currentPlace.locality}, ${currentPlace.administrativeArea}, ${currentPlace.country}";
          print("Akshada1---->${_currentAddress}");
        });
      }
      // setState(() => _currentPosition = position);
    }).catchError((e) {
      debugPrint(e);
    });

    print("Current lat lng: ${position.latitude}, ${position.longitude}");

    var map = new Map<String, dynamic>();
    map["appType"] = Platform.operatingSystem.toUpperCase();
    map["userId"] = '$_userId';
    map["api_token"] = _apiToken;
    map["date"] = "${DateFormat('yyyy-MM-dd').format(DateTime.now().toUtc())}";
    map["deviceId"] = "$_deviceId";
    map['longitude'] = '${position.longitude}';
    map['latitude'] = '${position.latitude}';
    print("Current");
      // map["longitude"] = "${_startLocation.longitude}";
    // map["latitude"] = "${_startLocation.latitude}";
    map["deviceDate"] =
        "${DateFormat('yyyy-MM-dd HH:mm:ss').format(DateTime.now().toUtc())}";
    map["locationAccuracy"] = _attendanceType;
    map["serverId"] = "0";
    map["id"] = "1";
    print(map);
    try {
      _networkUtil.post(apiTrackingAddNew, body: map).then((dynamic res) {
        try {
          if (isMoreTask == true) {
            Navigator.pop(_context);
            clear();
          } else {
            Navigator.pop(_context);
            Navigator.of(context).pop({'reload': true});
          }
        } catch (se) {
          Navigator.pop(_context);
          Navigator.of(context).pop({'reload': true});
        }
      });
    } catch (e) {
      Navigator.of(context).pop({'reload': true});
      showErrorLog(e.toString());
      showCenterToast(errorApiCall);
    }
  }

  Widget loadAttendanceStatus() {
    switch (_attendanceStatus) {
      case 0:
        return Container(
          color: Colors.red,
          child: Center(
              child: Padding(
            padding: const EdgeInsets.all(8.0),
            child: Text('Attendance is Not started',
                style: TextStyle(color: Colors.white, fontSize: 15.0)),
          )),
        );
        status = 'Not stated / Stop';
        break;
      case 1:
        break;
      case 2:
        return Container(
          color: Colors.orange,
          child: Center(
              child: Padding(
            padding: const EdgeInsets.all(8.0),
            child: Text('Attendance is pause',
                style: TextStyle(color: Colors.white, fontSize: 15.0)),
          )),
        );
        break;
      case 3:
        break;
      case 4:
        return Container(
          color: Colors.red,
          child: Center(
              child: Padding(
            padding: const EdgeInsets.all(8.0),
            child: Text('Attendance is Stop',
                style: TextStyle(color: Colors.white, fontSize: 15.0)),
          )),
        );
    }

    return Container();
  }

  void showToast() {
    setState(() {
      _isVisible = !_isVisible;
      _secondFormvisible = true;
    });
  }

  Future _selectFromDateAttendance() async {
    DateTime? _picked = await showDatePicker(
        context: context,
        initialDate: new DateTime.now(),
        firstDate: new DateTime(2016),
        lastDate: new DateTime(2025));
    setState(() {
      _fromDate = new DateFormat('yyyy-MM-dd').format(_picked!);
      // Navigator.of(context).pop();
      // showDialogbox();
    });
  }

  void showDialogbox() {
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
                          'Select date to filter.',
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
                      child: Text('Select From Date : '),
                    ),
                    Container(
                      padding: EdgeInsets.only(
                          left: ScreenUtil().setSp(20),
                          right: ScreenUtil().setSp(20)),
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.grey[100],
                          elevation: 0,
                          shape: RoundedRectangleBorder(
                              borderRadius: new BorderRadius.circular(5),
                              side: BorderSide(color: Colors.black)),
                        ),
                        child: Row(
                          children: <Widget>[
                            Icon(
                              Icons.calendar_today,
                              color: Colors.black,
                              size: ScreenUtil().setSp(15),
                            ),
                            SizedBox(
                              width: ScreenUtil().setSp(5),
                            ),
                            Text(_fromDate),
                          ],
                        ),
                        onPressed: () {
                          // _selectFromDateAttendance();
                        },
                      ),
                    ),
                    Padding(
                      padding: EdgeInsets.only(
                        left: ScreenUtil().setSp(20),
                        top: ScreenUtil().setSp(10),
                      ),
                      child: Text('Select To Date : '),
                    ),
                    Container(
                      padding: EdgeInsets.only(
                          bottom: ScreenUtil().setSp(20),
                          left: ScreenUtil().setSp(20),
                          right: ScreenUtil().setSp(20)),
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.grey[100],
                            elevation: 0,
                            shape: RoundedRectangleBorder(
                                borderRadius: new BorderRadius.circular(5),
                                side: BorderSide(color: Colors.black))),
                        child: Row(
                          children: <Widget>[
                            Icon(
                              Icons.calendar_today,
                              color: Colors.black,
                              size: ScreenUtil().setSp(15),
                            ),
                            SizedBox(
                              width: ScreenUtil().setSp(5),
                            ),
                            Text(_toDate),
                          ],
                        ),
                        onPressed: () {
                          setState(() {
                            // _selectToDateAttendance();
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
                            backgroundColor: appColorRedIcon,
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
                            // apiCallForGetAttendanceOfMonth();

                            // saveData();
                            Navigator.of(context).pop();
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

  _showCupertinoModalSheet() {
    try {
      showCupertinoModalPopup(
        context: context,
        builder: (BuildContext context) => CupertinoActionSheet(
          title: Text(' Perform Action'
              // ${AppLocalizations.of(context).lbl_actions}'
              ),
          actions: [
            CupertinoActionSheetAction(
              child: Text(
                'Take Picture',
                // '${AppLocalizations.of(context).lbl_take_picture}',
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: Colors.black,
                    ),
              ),
              onPressed: () async {
                Navigator.pop(context);
                // _tImage = await br.openCamera();
                // selectedImage = _tImage.path;

                setState(() {});
              },
            ),
            CupertinoActionSheetAction(
              child: Text(
                'upload',
                // '${AppLocalizations.of(context).txt_upload_image_desc}',
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: Colors.black,
                    ),
              ),
              onPressed: () async {
                Navigator.pop(context);

                // _tImage = await br.selectImageFromGallery();

                // selectedImage = _tImage.path;

                setState(() {});
              },
            ),
            CupertinoActionSheetAction(
              child: Text(
                'Remove Image',
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: Colors.black,
                    ),
              ),
              onPressed: () async {
                Navigator.pop(context);
                _tImage = null;
                // global.currentUser.userImage = "";
                // global.selectedImage = "";
                // removeProfileImage();
                setState(() {});
              },
            )
          ],
          cancelButton: CupertinoActionSheetAction(
            child: Text('cancel',
                // ${AppLocalizations.of(context).lbl_cancel}',
                style: TextStyle(color: Theme.of(context).primaryColor)),
            onPressed: () {
              Navigator.pop(context);
            },
          ),
        ),
      );
    } catch (e) {
      print(
          "Exception - profile_edit_screen.dart - _showCupertinoModalSheet():" +
              e.toString());
    }
  }

}

class ClientListApiCallBack {
  List<Data> data;
  String extra;
  int limit;
  String message;
  int offset;
  int status;
  bool success;
  int total;

  ClientListApiCallBack(
      {required this.data,
     required this.extra,
     required this.limit,
     required this.message,
     required this.offset,
     required this.status,
     required this.success,
     required this.total});

  factory ClientListApiCallBack.fromJson(Map<String, dynamic> json) {
    return ClientListApiCallBack(
      data: json['data'] != null
          ? (json['data'] as List).map((i) => Data.fromJson(i)).toList()
          : [],
      extra: json['extra'],
      limit: json['limit'],
      message: json['message'],
      offset: json['offset'],
      status: json['status'],
      success: json['success'],
      total: json['total'],
    );
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['extra'] = this.extra;
    data['limit'] = this.limit;
    data['message'] = this.message;
    data['offset'] = this.offset;
    data['status'] = this.status;
    data['success'] = this.success;
    data['total'] = this.total;
    data['data'] = this.data.map((v) => v.toJson()).toList();
      return data;
  }
}

class Data {
  String authorizePersonName;
  String clientName;
  int id;

  Data({required this.authorizePersonName, required this.clientName, required this.id});

  factory Data.fromJson(Map<String, dynamic> json) {
    return Data(
      authorizePersonName: json['authorizePersonName'],
      clientName: json['clientName'],
      id: json['id'],
    );
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['authorizePersonName'] = this.authorizePersonName;
    data['clientName'] = this.clientName;
    data['id'] = this.id;
    return data;
  }
}
