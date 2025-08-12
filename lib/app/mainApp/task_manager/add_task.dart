import 'dart:async';
import 'dart:io';

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
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:hrms/appUtil/global.dart' as global;

// ignore: must_be_immutable
class AddTask extends StatefulWidget {
  var scaffoldKey;
  var title;

  AddTask({Key? key, @required this.scaffoldKey, @required this.title})
      : super(key: key);

  @override
  State<StatefulWidget> createState() {
    return AddTaskState();
  }
}

class AddTaskState extends State<AddTask> {
  int _userId = 0, _attendanceStatus = 0;
  String _deviceId = "";
  late BuildContext _context;

  ///for location
  late Location _locationService = new Location();
  bool _permission = false;
  String? error;
  late LocationData _startLocation;
  String _apiToken = "";
  late int _companyId;
  late geo.Position _currentPosition;
  String? _currentAddress = '';
  late LocationData _pos;

  var formkey = GlobalKey<FormState>();
  Future<SharedPreferences> _prefs = SharedPreferences.getInstance();
  TextEditingController taskController = TextEditingController();
  NetworkUtil _networkUtil = NetworkUtil();
  ClientListApiCallBack? activeListApi;
  ProjectListCallBack? _projectListCallBack;
  TaskTypeCallBack? _taskTypeCallBack;
  final scaffoldKey = GlobalKey<ScaffoldState>();

  String? _clientDropdownValue, _projectDropdownValue;
  String? _hrstDropdownValue, _minDropdownValue, _typeDropdownValue;
  bool isnewtask = false, isMoreTask = false;
  String newtask = '0', status = 'Not stated / Stop';
  int isLoadAPI = 0;

  var now = new DateTime.now();
  String? formatted;
  var formatter = new DateFormat('yyyy-MM-dd');

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

  Future<void> checkInternet() async {
    var connectivityResult1 = await (Connectivity().checkConnectivity());
    if (connectivityResult1 == ConnectivityResult.mobile) {
    } else if (connectivityResult1 == ConnectivityResult.wifi) {}
    // print('G1---->${connectivityResult1}');

    var connectivityResult = await (Connectivity().checkConnectivity());
    // print('G1---->${connectivityResult}');
    if (connectivityResult != ConnectivityResult.none) {
      if (isLoadAPI == 1) {
        getTaskTypeList();
        getClientList();
      } else if (isLoadAPI == 2) {
        showLoader(context);
        getProjectList();
      } else if (isLoadAPI == 3) {
        addTask();
      }
    } else {
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

  @override
  Widget build(BuildContext context) {
    final taskType = Container(
        child: (_taskTypeCallBack?.data.isNotEmpty ?? false)
            ? DropdownButton(
                hint: Text('Select Task Type'),
                items: _taskTypeCallBack!.data.map((dataItem) {
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
                hint: Text('Select Task Type'),
                items: [],
                onChanged: (String? newValue) {},
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
              CustomHeaderWithReloadBack(
                  scaffoldKey: widget.scaffoldKey, title: widget.title),
              Form(
                key: formkey,
                child: Padding(
                  padding: EdgeInsets.only(
                      top: ScreenUtil().setSp(90),
                      left: ScreenUtil().setSp(5),
                      right: ScreenUtil().setSp(5),
                      bottom: ScreenUtil().setSp(5)),
                  child: Card(
                    elevation: 5,
                    child: ListView(
                      children: <Widget>[
                        Padding(
                          padding: EdgeInsets.all(5),
                          child: Text(
                            '${DateFormat(' dd, MMM yyyy').format(DateTime.now())}',
                            style: titleStyle,
                            textAlign: TextAlign.center,
                          ),
                        ),
                        Container(
                          padding: EdgeInsets.only(top: 20),
                          margin: EdgeInsets.only(left: 20, right: 20),
                          child: Row(
                            children: <Widget>[
                              Expanded(
                                child: Text(
                                  'Client : ',
                                  style:
                                      TextStyle(fontSize: ScreenUtil().setSp(15)),
                                ),
                              ),
                              SizedBox(
                                width: 15,
                              ),
                              Expanded(
                                child: Text(
                                  'Project : ',
                                  style:
                                      TextStyle(fontSize: ScreenUtil().setSp(15)),
                                ),
                              )
                            ],
                          ),
                        ),
                        Container(
                          padding: const EdgeInsets.only(top: 0),
                          margin: EdgeInsets.only(left: 20, right: 20, top: 10),
                          child: Row(
                            children: <Widget>[
                              (activeListApi?.data?.isNotEmpty ?? false)
                                  ? Expanded(
                                      child: DropdownButton(
                                        hint: Text('Select Client'),
                                        items: activeListApi?.data!.map((item) {
                                          return DropdownMenuItem(
                                            child: new Text(
                                              item.clientName ?? "",
                                              maxLines: 2,
                                              style: TextStyle(
                                                  overflow:
                                                      TextOverflow.ellipsis),
                                            ),
                                            value: item.id.toString(),
                                          );
                                        }).toList(),
                                        onChanged: (newValue) {
                                          _projectDropdownValue = "";
      //                                         setState(() {
      //                                           _clientDropdownValue = newValue;
      // //                                          print(_clientDropdownValue);
      //                                           getProjectList();
      //                                         });
                                          setState(() {
                                            _clientDropdownValue =
                                                newValue.toString();
                                            //                                          print(_clientDropdownValue);
                                            // getProjectList();
                                            isLoadAPI = 2;
                                            checkInternet();
                                          });
                                        },
                                        isExpanded: true,
                                        value: _clientDropdownValue,
                                      ),
                                    )
                                  : Expanded(
                                      child: Text('Loading....'),
                                    ),
                              SizedBox(
                                width: 15,
                              ),
                              (_projectListCallBack?.data!.isNotEmpty ?? false)
                                  ? Expanded(
                                      child: DropdownButton(
                                        hint: Text('Select Project'),
                                        items: _projectListCallBack!.data!
                                            .map((dataItem) {
                                              return DropdownMenuItem(
                                                child: Text(
                                                  dataItem.name ?? "",
                                                  maxLines: 2,
                                                  style: TextStyle(
                                                    fontSize:
                                                        ScreenUtil().setSp(15),
                                                    overflow:
                                                        TextOverflow.ellipsis,
                                                  ),
                                                ),
                                                value: dataItem.id.toString(),
                                              );
                                            })
                                            .toSet() // remove duplicate values if any
                                            .toList(),
                                        onChanged: (newValue) {
                                          setState(() {
                                            _projectDropdownValue =
                                                newValue.toString();
                                          });
                                        },
                                        isExpanded: true,
                                        value: _projectListCallBack!.data!.any(
                                                (item) =>
                                                    item.id.toString() ==
                                                    _projectDropdownValue)
                                            ? _projectDropdownValue
                                            : null, // fallback to null if invalid
                                      ),
                                    )
                                  : Expanded(
                                      child: Text(
                                          (_projectListCallBack?.data?.isEmpty ??
                                                  true)
                                              ? 'No Project Found'
                                              : 'Loading....'),
                                    ),
                            ],
                          ),
                        ),
                        Container(
                          padding: EdgeInsets.only(top: 10),
                          margin: EdgeInsets.only(left: 20, right: 20),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: <Widget>[
                              Text(
                                'Task Type : ',
                                style:
                                    TextStyle(fontSize: ScreenUtil().setSp(15)),
                                textAlign: TextAlign.start,
                              ),
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
                              Text(
                                'Task : ',
                                style:
                                    TextStyle(fontSize: ScreenUtil().setSp(15)),
                                textAlign: TextAlign.start,
                              ),
                              TextFormField(
                                controller: taskController,
                                //autofocus: true,
                                maxLines: null,
                                decoration:
                                    InputDecoration(labelText: "Add Task"),
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
                          child: Row(
                            children: <Widget>[
                              Expanded(
                                child: Text(
                                  'Hours : ',
                                  style:
                                      TextStyle(fontSize: ScreenUtil().setSp(15)),
                                ),
                              ),
                              SizedBox(
                                width: 15,
                              ),
                              Expanded(
                                child: Text(
                                  'Minutes : ',
                                  style:
                                      TextStyle(fontSize: ScreenUtil().setSp(15)),
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
                                child: DropdownButton(
                                  hint: Text('Choose Hours'),
                                  isExpanded: true,
                                  value: _hrstDropdownValue,
                                  onChanged: (newValue) {
                                    setState(() {
                                      _hrstDropdownValue = newValue.toString();
                                    });
                                  },
                                  items: [
                                    '00',
                                    '01',
                                    '02',
                                    '03',
                                    '04',
                                    '05',
                                    '06',
                                    '07',
                                    '08',
                                    '09'
                                  ].map<DropdownMenuItem<String>>((String value) {
                                    return DropdownMenuItem(
                                      child: new Text(value),
                                      value: value,
                                    );
                                  }).toList(),
                                ),
                              ),
                              SizedBox(
                                width: 15,
                              ),
                              Expanded(
                                child: DropdownButton(
                                  hint: Text('Choose minutes'),
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
                                  ].map<DropdownMenuItem<String>>((String value) {
                                    return DropdownMenuItem(
                                      child: new Text(value),
                                      value: value,
                                    );
                                  }).toList(),
                                ),
                              )
                            ],
                          ),
                        ),
                        Container(
                          child: CheckboxListTile(
                            title: Text('is new task'),
                            controlAffinity: ListTileControlAffinity.leading,
                            value: isnewtask,
                            onChanged: (bool? newValue) {
                              setState(() {
                                isnewtask = newValue ?? false;
                              });
                            },
                          ),
                        ),
                        Center(
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
                                      gradient: LinearGradient(
                                        colors: <Color>[
                                          Color.fromRGBO(255, 81, 54, 1),
                                          Color.fromRGBO(255, 163, 54, 1),
                                        ],
                                      ),
                                      borderRadius: BorderRadius.all(
                                          Radius.circular(20.0))),
                                  padding:
                                      const EdgeInsets.fromLTRB(70, 7, 70, 7),
                                  child: const Text('Add Task',
                                      style: TextStyle(fontSize: 17)),
                                ),
                                onPressed: () {
                                  if (formkey.currentState!.validate()) {
                                    if (taskController.text.isEmpty) {
                                      showBottomToast('Please enter task');
                                    } else if (_minDropdownValue == null) {
                                      showBottomToast('Select minutes');
                                    } else if (hrsToMin() == '0') {
                                      showBottomToast(
                                          'Total time should not be zero');
                                    } else {
                                      addTask();
                                    }
                                  }
                                },
                              )),
                        ),
                        Container(
                          child: CheckboxListTile(
                            title: Text('Want to add more task'),
                            controlAffinity: ListTileControlAffinity.leading,
                            value: isMoreTask,
                            onChanged: (bool? newValue) {
                              setState(() {
                                isMoreTask = newValue!;
                              });
                            },
                          ),
                        ),
                        SizedBox(
                          height: 30,
                        ),
                        loadAttendanceStatus(),
                      ],
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
      map["companyId"] = _companyId.toString();
      _networkUtil.post(apiGetClientList, body: map).then((dynamic res) {
        activeListApi = ClientListApiCallBack.fromJson(res);
        AppLog.showLog(res.toString());
        if (activeListApi!.success) {
          setState(() {});
        } else {
          showBottomToast(activeListApi!.message ?? "");
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
        Navigator.of(context).pop();
        AppLog.showLog(res.toString());
        if (_projectListCallBack!.data!.length == 0) {
          setState(() {});
          showCenterToast('No project found contact to Admin');
        }

        if (_projectListCallBack!.success) {
          setState(() {});
        } else {
          showBottomToast(_projectListCallBack!.message ?? "");
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
        if (_taskTypeCallBack!.success) {
          setState(() {});
        } else {
          showBottomToast(_taskTypeCallBack!.message ?? "");
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
    int id = prefs.getInt(SP_ID)!;
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
    var hrs = int.parse(_hrstDropdownValue ?? "");
    var min = int.parse(_minDropdownValue ?? "");
    var time = (hrs * 60) + min;
    return time.toString();
  }

  clear() {
    formkey.currentState!.reset();
    taskController.clear();
    isnewtask = false;
    isMoreTask = false;
    _clientDropdownValue = "null";
    _projectDropdownValue = "null";
    _hrstDropdownValue = "null";
    _minDropdownValue = "null";
    _typeDropdownValue = "null";
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
}

class ClientListApiCallBack {
  List<Data>? data;
  String? extra;
  int? limit;
  String? message;
  int? offset;
  int? status;
  bool success;
  int? total;

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
    data['data'] = this.data!.map((v) => v.toJson()).toList();
    return data;
  }
}

class Data {
  String? authorizePersonName;
  String? clientName;
  int? id;

  Data(
      {required this.authorizePersonName,
      required this.clientName,
      required this.id});

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
