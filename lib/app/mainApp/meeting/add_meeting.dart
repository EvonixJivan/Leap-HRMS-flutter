import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:hrms/app/uiComponent/custom_header.dart';
import 'package:hrms/appUtil/app_util_config.dart';
import 'package:hrms/appUtil/network_util.dart';
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:location/location.dart';
import 'dart:async';
import 'package:flutter/services.dart';
import 'package:geocoding/geocoding.dart' as loc;
import 'package:geolocator/geolocator.dart' as geo;

class AddMeeting extends StatefulWidget {
  var scaffoldKey;
  var title;

  AddMeeting({Key? key, required this.scaffoldKey, required this.title})
      : super(key: key);

  @override
  _AddMeetingState createState() {
    return _AddMeetingState();
  }
}

class _AddMeetingState extends State<AddMeeting> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  NetworkUtil _networkUtil = NetworkUtil();
  Future<SharedPreferences> _prefs = SharedPreferences.getInstance();
  AddMeetingCallBack? _addMeetingCallBack;
  Location _locationService = new Location();
  bool _permission = false;
 String? _clientName,
      _contactPerson,
      _purposeOfMeeting,
      _description,
      _clientContact,
      _clientEmail;
  bool sendCopy = false;
  var _meetingDate = 'Meeting Date';
  DateTime? start;
  TimeOfDay? _meetingStartTime;
  TimeOfDay? _meetingEndTime;
 late LocationData _startLocation;
 String? error;
  var _nextMeetingDate = 'Next Meeting Date';
 String? _apiToken;
 late int _userId;
  String _deviceId = ""; //,
 late  geo.Position _currentPosition;
  String _currentAddress = '';
 late LocationData _pos;

  @override
  void initState() {
    super.initState();
    initLocationState();
  }

  @override
  void dispose() {
    super.dispose();
  }

  ///To Do by Raghu
  ///Please check _uploadAttendanceLocationApiCall may be this gives error.

  Future apiCallForAddMeeting() async {
    final SharedPreferences prefs = await _prefs;
    if (prefs.getBool(SP_IS_LOGIN_BOOL) != null) {
      _userId = prefs.getInt(SP_ID)!;
      _apiToken = prefs.getString(SP_API_TOKEN)!;
      _deviceId = prefs.getString(DEVICE_ID)!;
    }
    var startTime = DateTime(start!.year, start!.month, start!.day,
            _meetingStartTime!.hour, _meetingStartTime!.minute)
        .toUtc();
    var endTime = DateTime(start!.year, start!.month, start!.day,
            _meetingEndTime!.hour, _meetingEndTime!.minute)
        .toUtc();
    print('UTC START TIME: $startTime');
    print('UTC END TIME: $endTime');

    var map = new Map<String, dynamic>();
    map["appType"] = Platform.operatingSystem.toUpperCase();
    map["userId"] = _userId.toString();
    map["api_token"] = _apiToken;
    map["clientName"] = _clientName;
    map["contactPerson"] = _contactPerson;
    map["title"] = _purposeOfMeeting;
    map["meetingDate"] = '$_meetingDate 00:0:00';
    map["meetingStart"] = startTime.toString().padLeft(2, '0');

    map["meetingEnd"] = endTime.toString().padLeft(2, '0');
//        ('$_meetingDate ${_meetingEndTime.hour}:${_meetingEndTime.minute}:00')
//            .toString()
//            .padLeft(2, '0');
    map["nextMeetingDate"] = '$_nextMeetingDate 00:0:00';
    map["clientContactNo"] = _clientContact;
    map["clientEmail"] = _clientEmail;
    map["description"] = _description;
    map["sendCopyToClient"] = sendCopy ? '1' : '0';

    print(map);
    try {
      showLoader(context);
      _networkUtil.post(apiAddMeeting, body: map).then((dynamic res) {
        try {
          AppLog.showLog(res.toString());
          _addMeetingCallBack = AddMeetingCallBack.fromJson(res);
          if (_addMeetingCallBack!.status == unAuthorised) {
            logout(context);
          } else if (_addMeetingCallBack!.success) {
            _uploadAttendanceLocationApiCall('5');
          } else {
            showBottomToast(_addMeetingCallBack!.message ?? "");
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
    //  }
  }

  initLocationState() async {
    await _locationService.changeSettings(
        accuracy: LocationAccuracy.high, interval: 1000);

    // Platform messages may fail, so we use a try/catch PlatformException.
    try {
      bool serviceStatus = await _locationService.serviceEnabled();
      print("Service status: $serviceStatus");
      if (serviceStatus) {
        PermissionStatus statuss = await _locationService.requestPermission();
        _permission = (statuss == PermissionStatus.granted) ? true : false;
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
  Widget build(BuildContext context) {
    final contactName = Padding(
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
        validator: (value) {
          if (value!.isEmpty) {
            return 'Client name is required';
          }
          return null;
        },
        decoration: InputDecoration(
          hintStyle: TextStyle(color: colorText, fontFamily: font),
          hintText: '  Client Name',
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
        // decoration: InputDecoration(
        //     border: InputBorder.none,
        //     hintText: 'Client Name',
        //     prefixIcon: Icon(
        //       Icons.keyboard,
        //       color: Colors.grey,
        //     )),
        onSaved: (String? value) {
          _clientName = value!;
          print(value);
        },
      )),
    );

    final contactPerson = Padding(
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
        keyboardType: TextInputType.text,
        validator: (value) {
          if (value!.isEmpty) {
            return 'Contact person is required';
          }
          return null;
        },
        decoration: InputDecoration(
          hintStyle: TextStyle(color: colorText),
          hintText: '  Contact Person',
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
        // decoration: InputDecoration(
        //     border: InputBorder.none,
        //     hintText: 'Contact Person',
        //     prefixIcon: Icon(
        //       Icons.person,
        //       color: Colors.grey,
        //     )),
        onSaved: (String? value) {
          _contactPerson = value!;
          print(value);
        },
      )),
    );

    final purposeOfMeeting = Padding(
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
        maxLines: null,
        validator: (value) {
          if (value!.isEmpty) {
            return 'Purpose of meeting is required';
          }
          return null;
        },
        decoration: InputDecoration(
          hintStyle: TextStyle(color: colorText),
          hintText: '  Purpose Of Meeting',
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
        // decoration: InputDecoration(
        //     border: InputBorder.none,
        //     hintText: 'Purpose Of Meeting',
        //     prefixIcon: Icon(
        //       Icons.bookmark,
        //       color: Colors.grey,
        //     )),
        onSaved: (String? value) {
          _purposeOfMeeting = value!;
          print(value);
        },
      )),
    );

    final description = Padding(
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
        maxLines: null,
        validator: (value) {
          if (value!.isEmpty) {
            return 'Description is required';
          }
          return null;
        },
        decoration: InputDecoration(
          hintStyle: TextStyle(color: colorText),
          hintText: 'Description',
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
        // decoration: InputDecoration(
        //     border: InputBorder.none,
        //     hintText: 'Description',
        //     prefixIcon: Icon(
        //       Icons.note,
        //       color: Colors.grey,
        //     )),
        onSaved: (String? value) {
          _description = value!;
          print(value);
        },
      )),
    );

    final clientContact = Padding(
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
        validator: (value) {
          if (value!.isEmpty) {
            return 'Client contact is required';
          }
          if (value.length != 10) {
            return 'Enter valid contact';
          }
          return null;
        },
        keyboardType: TextInputType.phone,
        decoration: InputDecoration(
          hintStyle: TextStyle(color: colorText),
          hintText: '  Client Contact',
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
        // decoration: InputDecoration(
        //     border: InputBorder.none,
        //     hintText: 'Client Contact',
        //     prefixIcon: Icon(
        //       Icons.call,
        //       color: Colors.grey,
        //     )),
        onSaved: (String? value) {
          _clientContact = value!;
          print(value);
        },
      )),
    );

    final clientEmail = Padding(
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
        validator: (value) {
          if (value!.isEmpty) {
            return 'Client email is required';
          }
          if (!AppUtil.isEmail(value)) {
            return 'Not a valid email.';
          }
          return null;
        },
        keyboardType: TextInputType.emailAddress,
        decoration: InputDecoration(
          hintStyle: TextStyle(color: colorText),
          hintText: '  Client Email',
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
        // decoration: InputDecoration(
        //     border: InputBorder.none,
        //     hintText: 'Client Email',
        //     prefixIcon: Icon(
        //       Icons.email,
        //       color: Colors.grey,
        //     )),
        onSaved: (String? value) {
          _clientEmail = value!;
          print(value);
        },
      )),
    );

    final meetingDate = Padding(
        padding: EdgeInsets.only(
            left: ScreenUtil().setSp(10),
            top: ScreenUtil().setSp(10),
            right: ScreenUtil().setSp(10),
            bottom: ScreenUtil().setSp(10)),
        child: Container(
          //padding: EdgeInsets.all(2),
          decoration: BoxDecoration(
            color: tfBackgroundColor,
            border: Border.all(width: 1, color: tfBackgroundColor),
            borderRadius: BorderRadius.circular(25.0),
          ),
          child: ElevatedButton(
            style: ElevatedButton.styleFrom(
                backgroundColor: tfBackgroundColor, elevation: 0),
            child: Row(
              children: <Widget>[
                Icon(
                  Icons.calendar_today,
                  color: colorTextDarkBlue,
                ),
                SizedBox(
                  width: ScreenUtil().setSp(5),
                ),
                Text(_meetingDate),
              ],
            ),
            onPressed: () {
              // setState(() {
              _selectDate();
              // });
            },
          ),
        ));

    final nextMeetingDate = Padding(
        padding: EdgeInsets.only(
            left: ScreenUtil().setSp(10),
            top: ScreenUtil().setSp(10),
            right: ScreenUtil().setSp(10),
            bottom: ScreenUtil().setSp(10)),
        child: Container(
          decoration: BoxDecoration(
            color: tfBackgroundColor,
            border: Border.all(
              width: 1,
              color: tfBackgroundColor,
            ),
            borderRadius: BorderRadius.circular(25.0),
          ),
          child: ElevatedButton(
            style: ElevatedButton.styleFrom(
                backgroundColor: tfBackgroundColor, elevation: 0),
            child: Row(
              children: <Widget>[
                Icon(
                  Icons.calendar_today,
                  color: colorTextDarkBlue,
                ),
                SizedBox(
                  width: ScreenUtil().setSp(5),
                ),
                Text(_nextMeetingDate),
              ],
            ),
            onPressed: () {
              setState(() {
                _selectNextDate();
              });
            },
          ),
        ));

    final meetingStartTime = Padding(
        padding: EdgeInsets.only(
            left: ScreenUtil().setSp(10),
            top: ScreenUtil().setSp(10),
            right: ScreenUtil().setSp(10),
            bottom: ScreenUtil().setSp(10)),
        child: Container(
          decoration: BoxDecoration(
            color: tfBackgroundColor,
            border: Border.all(
              width: 1,
              color: tfBackgroundColor,
            ),
            borderRadius: BorderRadius.circular(25.0),
          ),
          child: ElevatedButton(
            style: ElevatedButton.styleFrom(
                backgroundColor: tfBackgroundColor, elevation: 0),
            child: Row(
              children: <Widget>[
                Icon(
                  Icons.timer,
                  color: colorTextDarkBlue,
                ),
                SizedBox(
                  width: ScreenUtil().setSp(5),
                ),
                Text((_meetingStartTime != null
                    ? '${_meetingStartTime!.hour}:${_meetingStartTime!.minute}'
                    : 'HH:MM')),
              ],
            ),
            onPressed: () {
              setState(() {
                _startTime();
              });
            },
          ),
        ));

    final meetingEndTime = Padding(
        padding: EdgeInsets.only(
            left: ScreenUtil().setSp(10),
            top: ScreenUtil().setSp(10),
            right: ScreenUtil().setSp(10),
            bottom: ScreenUtil().setSp(10)),
        child: Container(
          decoration: BoxDecoration(
            color: tfBackgroundColor,
            border: Border.all(
              width: 1,
              color: tfBackgroundColor,
            ),
            borderRadius: BorderRadius.circular(25.0),
          ),
          child: ElevatedButton(
            style: ElevatedButton.styleFrom(
                backgroundColor: tfBackgroundColor, elevation: 0),
            child: Row(
              children: <Widget>[
                Icon(
                  Icons.timer,
                  color: colorTextDarkBlue,
                ),
                SizedBox(
                  width: ScreenUtil().setSp(5),
                ),
                Text((_meetingEndTime != null
                    ? '${_meetingEndTime!.hour}:${_meetingEndTime!.minute}'
                    : 'HH:MM')),
              ],
            ),
            onPressed: () {
              setState(() {
                _endTime();
              });
            },
          ),
        ));

    final sendCopyToClient = CheckboxListTile(
      title: Text('Send copy to client'),
      controlAffinity: ListTileControlAffinity.platform,
      value: sendCopy,
      activeColor: appPrimaryColor,
      onChanged: (bool? newValue) {
        setState(() {
          sendCopy = newValue!;
        });
      },
    );

    final submitButton = Row(
      children: <Widget>[
        SizedBox(
          width: ScreenUtil().setSp(30),
        ),
        Expanded(
          child: ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: btnBgColor,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10.0)),
            ),
            onPressed: () {
              if (_formKey.currentState!.validate()) {
                _formKey.currentState!.save();
                if (_meetingDate == 'Meeting Date') {
                  showBottomToast('Meeting Date is required');
                } else            apiCallForAddMeeting();
          
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
        body: GestureDetector(
          child: Stack(
            children: <Widget>[
              // CustomHeader(scaffoldKey: widget.scaffoldKey, title: widget.title),
              CustomHeaderWithBack(
                  scaffoldKey: widget.scaffoldKey, title: widget.title),
              Container(
                margin: EdgeInsets.only(top: 90.0),
                child: ListView(
                  children: <Widget>[
                    Card(
                      color: appBackgroundColor,
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
                            headingText('Client Name'),
                            contactName,
                            headingText('Contact Person'),
                            contactPerson,
                            headingText('Purpose of Meeting'),
                            purposeOfMeeting,
                            headingText('Description'),
                            description,
                            headingText('Meeting Date'),
                            meetingDate,
                            headingText('Meeting Start Time'),
                            meetingStartTime,
                            headingText('Meeting End Time'),
                            meetingEndTime,
                            headingText('Next Meeting Date'),
                            nextMeetingDate,
                            headingText('Client Contact'),
                            clientContact,
                            headingText('Client Email'),
                            clientEmail,
                            sendCopyToClient,
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
            FocusScope.of(context).requestFocus(new FocusNode());
          },
        ),
      ),
    );
  }

  Widget headingText(String name) {
    return Padding(
      padding: EdgeInsets.only(
          left: ScreenUtil().setSp(10),
          top: ScreenUtil().setSp(10),
          right: ScreenUtil().setSp(10)),
      child: Text(
        name,
        style: TextStyle(
          fontFamily: font,
            fontWeight: FontWeight.w500, fontSize: ScreenUtil().setSp(15)),
      ),
    );
  }


Future _selectDate() async {
  DateTime now = DateTime.now();
  DateTime? _picked = await showDatePicker(
    context: context,
    initialDate: now,
    firstDate: DateTime(2016),
    lastDate: DateTime(now.year + 5), // Set to 5 years ahead
  );

  if (_picked != null) {
    setState(() {
      start = _picked;
      _meetingDate = DateFormat('yyyy-MM-dd').format(_picked);
    });
  }
}

  Future _selectNextDate() async {
      DateTime now = DateTime.now();

    DateTime? _picked = await showDatePicker(
        context: context,
        initialDate: now,
        firstDate:  DateTime(2016),
        lastDate:  DateTime(now.year + 5));
  
     if (_picked != null) {
    setState(() {
       _nextMeetingDate = new DateFormat('dd-MM-yyyy').format(_picked);
    });
  }
  }

  Future _startTime() async {
    _meetingStartTime = (await showTimePicker(
      context: context,
      initialTime: TimeOfDay.now(),
    ))!;
    setState(() {});
  }

  Future _endTime() async {
    _meetingEndTime = (await showTimePicker(
      context: context,
      initialTime: TimeOfDay.now(),
    ))!;
    setState(() {});
  }

  /// location upload api call-------------
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
        "${DateFormat('yyyy-MM-dd HH:mm:ss').format(DateTime.now())}";
    map["locationAccuracy"] = _attendanceType;
    map["serverId"] = "0";
    map["id"] = "1";
    print(map);
    try {
      _networkUtil.post(apiTrackingAddNew, body: map).then((dynamic res) {
        try {
          Navigator.pop(context);
          showBottomToast(_addMeetingCallBack!.message ?? "");
          Navigator.of(context).pop({'reload': true});
          setState(() {});
        } catch (se) {}
      });
    } catch (e) {
      showErrorLog(e.toString());
      showCenterToast(errorApiCall);
    }
  }
}

class AddMeetingCallBack {
  late int totalCount;
 late bool success;
 late Items? items;
 String? message;
 late int status;
 String? currentTime;
 String? currentUtcTime;

  AddMeetingCallBack(
      {required this.totalCount,
     required this.success,
     required this.items,
     required this.message,
     required this.status,
     required this.currentTime,
     required this.currentUtcTime});

  AddMeetingCallBack.fromJson(Map<String, dynamic> json) {
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
 late int id;
 late int userId;
 String? clientName;
String? title;
 String? description;
late  String meetingDate;
 String? meetingStart;
 String? meetingEnd;
String? attachment;
 String? nextMeetingDate;
 String? clientContactNo;
 String? clientEmail;
 late int sendCopyToClient;
 String? contactPerson;
 late int isdeleted;
 late int status;
 String? createdAt;
 String? updatedAt;

  Items(
      {required this.id,
     required this.userId,
     required this.clientName,
     required this.title,
     required this.description,
     required this.meetingDate,
     required this.meetingStart,
     required this.meetingEnd,
     required this.attachment,
     required this.nextMeetingDate,
     required this.clientContactNo,
     required this.clientEmail,
     required this.sendCopyToClient,
     required this.contactPerson,
     required this.isdeleted,
     required this.status,
     required this.createdAt,
     required this.updatedAt});

  Items.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    userId = json['userId'];
    clientName = json['clientName'];
    title = json['title'];
    description = json['description'];
    meetingDate = json['meetingDate'];
    meetingStart = json['meetingStart'];
    meetingEnd = json['meetingEnd'];
    attachment = json['attachment'];
    nextMeetingDate = json['nextMeetingDate'];
    clientContactNo = json['clientContactNo'];
    clientEmail = json['clientEmail'];
    sendCopyToClient = json['sendCopyToClient'];
    contactPerson = json['contactPerson'];
    isdeleted = json['isdeleted'];
    status = json['status'];
    createdAt = json['created_at'];
    updatedAt = json['updated_at'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['id'] = this.id;
    data['userId'] = this.userId;
    data['clientName'] = this.clientName;
    data['title'] = this.title;
    data['description'] = this.description;
    data['meetingDate'] = this.meetingDate;
    data['meetingStart'] = this.meetingStart;
    data['meetingEnd'] = this.meetingEnd;
    data['attachment'] = this.attachment;
    data['nextMeetingDate'] = this.nextMeetingDate;
    data['clientContactNo'] = this.clientContactNo;
    data['clientEmail'] = this.clientEmail;
    data['sendCopyToClient'] = this.sendCopyToClient;
    data['contactPerson'] = this.contactPerson;
    data['isdeleted'] = this.isdeleted;
    data['status'] = this.status;
    data['created_at'] = this.createdAt;
    data['updated_at'] = this.updatedAt;
    return data;
  }
}
