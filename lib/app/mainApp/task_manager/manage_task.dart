import 'dart:async' show Future;
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:hrms/app/mainApp/task_manager/add_task.dart';
import 'package:hrms/app/mainApp/task_manager/edit_task.dart';
import 'package:hrms/app/mainApp/task_manager/project_list_call_back.dart';
import 'package:hrms/app/mainApp/task_manager/view_task.dart';
import 'package:hrms/app/uiComponent/app_loader.dart';
import 'package:hrms/app/uiComponent/custom_header.dart';
import 'package:hrms/appUtil/app_util_config.dart';
import 'package:hrms/appUtil/network_util.dart';
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';

class HomeScreen extends StatefulWidget {
  var scaffoldKey;
  var title;

  HomeScreen({Key? key, @required this.scaffoldKey, @required this.title})
      : super(key: key);

  @override
  _HomeScreenState createState() => new _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  var formkey = GlobalKey<FormState>();
  Future<SharedPreferences> _prefs = SharedPreferences.getInstance();
  NetworkUtil _networkUtil = NetworkUtil();
  TaskListApiCallBack? _taskList;
  ProjectListCallBack? _projectListCallBack;
  ClientListApiCallBack? _clientListApiCallBack;
  String? _hrstDropdownValue,
      _minDropdownValue,
      _projectDropdownValue,
      _clientDropdownValue,
      projectDropdownvalue,
      clientDropdownvalue,
      typeDropDownvalue;

 String? _taskstring;
 late int _projectId, _clientId, _typeId;
 late int userId;
  var now = new DateTime.now();
 String? _apiToken = "", formatted, formattedForApiCall;
  var formatter = new DateFormat('EEE, d MMM, yyyy');
  var formatterForApiCall = new DateFormat('yyyy-MM-dd');

  @override
  void initState() {
    super.initState();
    formatted = formatter.format(now);
    getCredential();
    getClientList();
  }

  getCredential() async {
    final SharedPreferences prefs = await _prefs;
    if (prefs.getBool(SP_IS_LOGIN_BOOL) != null) {
       userId = prefs.getInt(SP_ID)!;
      _apiToken = prefs.getString(SP_API_TOKEN)!;
      getTaskList();
    }
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
       top: false,
        bottom: true,
      child: new Scaffold(
          backgroundColor: Colors.grey[100],
          body: Stack(
            children: <Widget>[
              CustomHeaderWithBack(
                  scaffoldKey: widget.scaffoldKey, title: widget.title),
              Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
                new Card(
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(5.0)),
                  margin: EdgeInsets.only(
                      top: ScreenUtil().setSp(120),
                      left: ScreenUtil().setSp(10),
                      right: ScreenUtil().setSp(10)),
                  elevation: 2,
                  child: Padding(
                    padding: EdgeInsets.all(7),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: <Widget>[
                        Text(
                          formatted ?? "",
                          style: TextStyle(
                              color: Color.fromRGBO(255, 81, 54, 1),
                              fontSize: 18.0),
                          textAlign: TextAlign.left,
                        ),
                        Row(
                          children: <Widget>[
                            Icon(
                              Icons.access_time,
                              color: Colors.grey,
                              size: 18,
                            ),
                            (_taskList != null &&
                                    _taskList?.data != null &&
                                    _taskList!.data!.length > 0)
                                ? Text(
                                    ' ${_taskList?.totalCount}/480',
                                    style: TextStyle(
                                        color: Colors.green, fontSize: 18.0),
                                  )
                                : Text(
                                    ' 0/480',
                                    style: TextStyle(
                                        color: Colors.green, fontSize: 18.0),
                                  ),
                          ],
                        )
                      ],
                    ),
                  ),
                ),
                Expanded(
                  child: (_taskList != null &&
                          _taskList?.data != null &&
                          _taskList!.data!.length > 0)
                      ? getListView()
                      : Container(
                          child: Center(
                            child: Text(
                              noDataFound,
                              style: TextStyle(fontSize: 30),
                            ),
                          ),
                        ),
                )
              ]),
              AppLoaderView(),
            ],
          ),
          floatingActionButton: Container(
            height: 50,
            width: 50,
            child: FloatingActionButton(
              onPressed: () {
                _buttonTapped();
              },
              backgroundColor: Colors.deepOrange,
              child: Icon(Icons.add, color: Colors.white,),
            ),
          )),
    );
  }

  Future _buttonTapped() async {
    Map results = await Navigator.of(context).push(new MaterialPageRoute(
      builder: (BuildContext context) {
        return AddTask(
          scaffoldKey: widget.scaffoldKey,
          title: widget.title,
        );
      },
    ));

    if (results.containsKey('reload')) {
      getTaskList();
    }
  }

  Future _editButtonTapped(int index) async {
    Map results = await Navigator.of(context).push(new MaterialPageRoute(
      builder: (BuildContext context) {
        return EditTask(
          scaffoldKey: widget.scaffoldKey,
          title: 'Edit Task',
          taskId: _taskList!.data![index].id!,
          hrsDropdownValue: _hrstDropdownValue ?? "",
          minDropdownValue: _minDropdownValue ?? "",
          projectDropdownvalue: _taskList!.data![index].projectName ?? "",
          clientDropdownvalue: _taskList!.data![index].clientName ?? "",
          clientId: _clientId,
          projectId: _projectId,
          taskTypeId: _typeId,
          task: _taskstring ?? "",
          taskTypeDropdownvalue: _taskList!.data![index].taskType ?? "",
          // type: _typeDrop
        );
      },
    ));

    getTaskList();
    }

  Widget getListView() {
    return ListView.builder(
      shrinkWrap: true,
      itemBuilder: (BuildContext context, int index) {
        return Padding(
          padding: const EdgeInsets.only(left: 8, right: 8, bottom: 8),
          child: Card(
            elevation: 5,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: <Widget>[
                    Align(
                      alignment: Alignment.topLeft,
                      child: Visibility(
                          child: (_taskList?.data![index].isNew == 1)
                              ? Container(
                                  decoration: BoxDecoration(
                                      color: Colors.green,
                                      borderRadius: BorderRadius.only(
                                          topLeft: Radius.circular(3))),
                                  padding: EdgeInsets.only(
                                      top: 2, bottom: 2, left: 10, right: 10),
                                  child: Text(
                                    'New',
                                    style: TextStyle(
                                        color: Colors.white, fontSize: 8.0),
                                  ))
                              : Visibility(
                                  visible: false,
                                  child: Text(''),
                                )),
                    ),
                    Container(
                      child: (_taskList?.data![index].isApproved == 0)
                          ? Container(
                              decoration: BoxDecoration(
                                  color: Colors.deepOrange,
                                  borderRadius: BorderRadius.only(
                                      topRight: Radius.circular(3))),
                              padding: EdgeInsets.all(2),
                              child: Text(
                                'Non-approved',
                                style: TextStyle(
                                    color: Colors.white, fontSize: 8.0),
                              ),
                            )
                          : (_taskList?.data![index].isApproved == 1)
                              ? Container(
                                  decoration: BoxDecoration(
                                      color: Colors.green,
                                      borderRadius: BorderRadius.only(
                                          topRight: Radius.circular(3))),
                                  padding: EdgeInsets.all(2),
                                  child: Text(
                                    'Approved',
                                    style: TextStyle(
                                        color: Colors.white, fontSize: 8.0),
                                  ),
                                )
                              : Container(
                                  decoration: BoxDecoration(
                                      color: Colors.red,
                                      borderRadius: BorderRadius.only(
                                          topRight: Radius.circular(3))),
                                  padding: EdgeInsets.all(2),
                                  child: Text(
                                    'Rejected',
                                    style: TextStyle(
                                        color: Colors.white, fontSize: 8.0),
                                  ),
                                ),
                    ),
                  ],
                ),
                (_taskList?.data![index].clientName != '')
                    ? Row(children: <Widget>[
                        Expanded(
                          child: Row(
                            children: <Widget>[
                              SizedBox(
                                width: 8,
                              ),
                              Icon(
                                Icons.people,
                                color: Colors.deepOrange,
                                size: 15,
                              ),
                              Text(
                                ' ${_taskList?.data![index].clientName}',
                                style: TextStyle(
                                  fontSize: 14.0,
                                ),
                                maxLines: 2,
                              )
                            ],
                          ),
                        ),
                        (_taskList?.data![index].isApproved == 0)
                            ? Container(
                                padding: const EdgeInsets.all(0.0),
                                width: 40,
                                height: 30,
                                child: ElevatedButton(
                                  style: ElevatedButton.styleFrom(
                                      elevation: 0,
                                      ),
                                  child: const Icon(
                                    Icons.delete,
                                    color: Color.fromRGBO(255, 81, 54, 1),
                                    size: 20,
                                  ),
                                  onPressed: () {
                                    showDialog(
                                        context: context,
                                        builder: (BuildContext context) {
                                          return StatefulBuilder(
                                              builder: (context, setState) {
                                            return AlertDialog(
                                              contentPadding: EdgeInsets.all(0),
                                              shape: RoundedRectangleBorder(
                                                  borderRadius:
                                                      BorderRadius.all(
                                                          Radius.circular(20))),
                                              content: Container(
                                                decoration: new BoxDecoration(
                                                    borderRadius:
                                                        new BorderRadius.all(
                                                            Radius.circular(
                                                                20))),
                                                padding:
                                                    EdgeInsets.only(bottom: 10),
                                                child: Column(
                                                  mainAxisSize:
                                                      MainAxisSize.min,
                                                  crossAxisAlignment:
                                                      CrossAxisAlignment
                                                          .stretch,
                                                  children: <Widget>[
                                                    Container(
                                                        decoration:
                                                            new BoxDecoration(
                                                                gradient:
                                                                    LinearGradient(
                                                                  colors: <
                                                                      Color>[
                                                                    Color
                                                                        .fromRGBO(
                                                                            255,
                                                                            81,
                                                                            54,
                                                                            1),
                                                                    Color
                                                                        .fromRGBO(
                                                                            255,
                                                                            163,
                                                                            54,
                                                                            1),
                                                                  ],
                                                                ),
                                                                borderRadius: new BorderRadius
                                                                        .only(
                                                                    topLeft: Radius
                                                                        .circular(
                                                                            20),
                                                                    topRight: Radius
                                                                        .circular(
                                                                            20))),
                                                        padding:
                                                            EdgeInsets.all(15),
                                                        child: Text(
                                                          'Delete',
                                                          textAlign:
                                                              TextAlign.center,
                                                          style: TextStyle(
                                                              fontSize: 20,
                                                              fontWeight:
                                                                  FontWeight
                                                                      .w400,
                                                              color:
                                                                  Colors.white),
                                                        )),
                                                    Container(
                                                      padding:
                                                          const EdgeInsets.only(
                                                              top: 30,
                                                              bottom: 20),
                                                      margin: EdgeInsets.only(
                                                          left: 20, right: 20),
                                                      child: Text(
                                                        'Are you sure?',
                                                        textAlign:
                                                            TextAlign.center,
                                                        style: TextStyle(
                                                            fontSize: 20),
                                                      ),
                                                    ),
                                                    Row(
                                                      children: <Widget>[
                                                        Expanded(
                                                          flex: 2,
                                                          child: Container(
                                                            padding:
                                                                EdgeInsets.only(
                                                                    left: 25),
                                                            child:
                                                                ElevatedButton(
                                                              style: ElevatedButton.styleFrom(
                                                                  shape: RoundedRectangleBorder(
                                                                      borderRadius:
                                                                          BorderRadius.circular(
                                                                              20.0))),
                                                              child: Text(
                                                                  'Cancel'),
                                                              onPressed: () {
                                                                Navigator.of(
                                                                        context)
                                                                    .pop();
                                                              },
                                                            ),
                                                          ),
                                                        ),
                                                        Expanded(
                                                          flex: 3,
                                                          child: Container(
                                                              padding: EdgeInsets
                                                                  .only(
                                                                      right: 25,
                                                                      left: 25,
                                                                      top: 0,
                                                                      bottom:
                                                                          0),
                                                              decoration: BoxDecoration(
                                                                  borderRadius:
                                                                      BorderRadius.all(
                                                                          Radius.circular(
                                                                              20))),
                                                              child:
                                                                  ElevatedButton(
                                                                style: ElevatedButton
                                                                    .styleFrom(
                                                                  backgroundColor:
                                                                      Colors
                                                                          .white,
                                                                  elevation: 0,
                                                                  textStyle: TextStyle(
                                                                      color: Colors
                                                                          .white),
                                                                  padding:
                                                                      const EdgeInsets
                                                                              .all(
                                                                          0.0),
                                                                  shape: RoundedRectangleBorder(
                                                                      borderRadius:
                                                                          BorderRadius.circular(
                                                                              20.0)),
                                                                ),
                                                                child:
                                                                    Container(
                                                                  decoration:
                                                                      const BoxDecoration(
                                                                          // gradient:
                                                                          //     LinearGradient(
                                                                          //   colors: <Color>[
                                                                          //     Color.fromRGBO(255, 81, 54, 1),
                                                                          //     Color.fromRGBO(255, 163, 54, 1),
                                                                          //   ],
                                                                          // ),
                                                                          borderRadius:
                                                                              BorderRadius.all(Radius.circular(20.0))),
                                                                  padding:
                                                                      const EdgeInsets
                                                                              .fromLTRB(
                                                                          10,
                                                                          9,
                                                                          15,
                                                                          9),
                                                                  child: const Text(
                                                                      'Yes, Delete it!',
                                                                      style: TextStyle(
                                                                          fontSize:
                                                                              14)),
                                                                ),
                                                                onPressed: () {
                                                                  setState(() {
                                                                    deleteTask(
                                                                        '${_taskList?.data![index].id}');
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
                                  },
                                ),
                              )
                            : Container(),
                        SizedBox(
                          width: 10,
                        )
                      ])
                    : Container(),
                Row(
                  children: <Widget>[
                    Expanded(
                      child: Row(
                        children: <Widget>[
                          SizedBox(
                            width: 8,
                          ),
                          Icon(
                            Icons.folder_shared,
                            color: Colors.deepOrange,
                            size: 15,
                          ),
                          Text(
                            ' ${_taskList?.data![index].projectName}',
                            style: TextStyle(
                              fontSize: 14.0,
                            ),
                            maxLines: 2,
                          )
                        ],
                      ),
                    ),
                    Visibility(
                        child: (_taskList?.data![index].isApproved == 0)
                            ? Container(
                                padding: const EdgeInsets.all(0.0),
                                width: 40,
                                height: 30,
                                child: ElevatedButton(
                                  style: ElevatedButton.styleFrom(
                                   
                                      elevation: 0),
                                  child: const Icon(
                                    Icons.edit,
                                    color: Colors.teal,
                                    size: 20,
                                  ),
                                  onPressed: () {
                                    // getClientList();
                                    var time = _taskList!.data![index].minutes!
                                        .split(':');
                                    print(time);
                                    _hrstDropdownValue = time[0];
                                    _minDropdownValue = time[1];
                                    _taskstring = _taskList!.data![index].task;
                                    _clientId = _taskList!.data![index].clientId!;
                                    _projectId =
                                        _taskList!.data![index].projectId!;
                                    _typeId = _taskList!.data![index].taskTypeId!;

                                    projectDropdownvalue =
                                        _taskList!.data![index].projectName;
                                    clientDropdownvalue =
                                        _taskList!.data![index].clientName;
                                    typeDropDownvalue =
                                        _taskList!.data![index].taskType;

                                    _editButtonTapped(index);
                                  },
                                ),
                              )
                            : Visibility(
                                visible: false,
                                child: Text(''),
                              )),
                    //),
                    SizedBox(
                      width: 10,
                    )
                  ],
                ),
                Padding(
                  padding: const EdgeInsets.only(left: 8, right: 8, top: 8),
                  child: Text(
                    _taskList!.data![index].task ?? "",
                    style: TextStyle(fontSize: 14.0),
                    maxLines: null,
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.only(left: 8, right: 8, top: 8),
                  child: Row(
                    children: <Widget>[
                      Expanded(
                        flex: 2,
                        child: Row(
                          children: <Widget>[
                            Icon(
                              Icons.access_time,
                              color: Colors.deepOrange,
                              size: 15,
                            ),
                            Text(
                              '  ${_taskList?.data![index].minutes}:00 ',
                              style: TextStyle(fontSize: 14.0),
                            ),
                          ],
                        ),
                      ),
                      Expanded(
                        flex: 3,
                        child: getProgressBar(
                            ('${((_taskList?.data![index].percentage ?? 1) > 100) ? 100 : _taskList?.data![index].percentage ?? 1}'),
                            (((_taskList?.data![index].percentage ?? 1) > 100)
                                ? 100
                                : _taskList?.data![index].percentage ?? 1)),
                      )
                    ],
                  ),
                ),
                Padding(
                  padding: EdgeInsets.only(left: 8, right: 8, top: 8),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: <Widget>[
                      Text(
                          '${DateFormat('hh:mm a').format(DateFormat("yyyy-MM-dd HH:mm:ss").parse(_taskList!.data![index].createdAt ?? "", true).toLocal())}')
                      // Text(DateFormat('hh:mm a, dd MMM').format(
                      //     DateTime.parse(_taskList?.data[index].created_at))),
                    ],
                  ),
                ),
                SizedBox(
                  height: 8,
                ),
              ],
            ),
          ),
        );
      },
      itemCount: _taskList?.data!.length,
    );
  }

  @override
  void screenUpdate() {
    setState(() {});
  }

  void editTask(
    String taskId,
  ) async {
    String minutes = hrsToMin();
    final SharedPreferences prefs = await _prefs;
    if (prefs.getBool(SP_IS_LOGIN_BOOL) != null) {
       userId = prefs.getInt(SP_ID)!;
      _apiToken = prefs.getString(SP_API_TOKEN)!;
    }
    try {
      var map = new Map<String, dynamic>();
      map["appType"] = Platform.operatingSystem.toUpperCase();
      map["userId"] = userId.toString();
      map["api_token"] = _apiToken;
      map['task'] = _taskstring;
      map['minutes'] = minutes;
      map['taskDate'] =
          DateFormat('EEE, d MMM, yyyy').format(DateTime.now().toUtc());
      map['taskId'] = taskId;

      showLoader(context);
      _networkUtil.post(apiEditTask, body: map).then((dynamic res) {
        AppLog.showLog(res.toString());
        Navigator.pop(context);
        if (res['success'] == true) {
          setState(() {
            getTaskList();
          });
          Navigator.pop(context);
        } else {
          showBottomToast(_taskList!.message ?? "");
        }
      });
    } catch (e) {
      Navigator.pop(context);
      print(e.toString());
    }
  }

  String hrsToMin() {
    var hrs = int.parse(_hrstDropdownValue ?? "");
    var min = int.parse(_minDropdownValue ?? "");
    var time = (hrs * 60) + min;
    return time.toString();
  }

  ///Api calls
  // Future<String> getTaskList() async {
  //   final SharedPreferences prefs = await _prefs;
  //   _apiToken = prefs.getString(SP_API_TOKEN)!;
  //   try {
  //     final SharedPreferences prefs = await _prefs;
  //     if (prefs.getBool(SP_IS_LOGIN_BOOL) != null) {
  //        userId = prefs.getInt(SP_ID)!;
  //       _apiToken = prefs.getString(SP_API_TOKEN)!;
  //     }
  //     var map = new Map<String, dynamic>();
  //     map["appType"] = Platform.operatingSystem.toUpperCase();
  //     map["userId"] = userId.toString();
  //     map["api_token"] = _apiToken;
  //     map['taskDate'] = DateFormat('yyyy-MM-dd').format(DateTime.now().toUtc());

  //     showLoader(context);
  //     _taskList = null;
  //     _networkUtil.post(apiGetTaskList, body: map).then((dynamic res) {
  //       Navigator.pop(context);
  //       try {
  //         _taskList = TaskListApiCallBack.fromJson(res);
  //         setState(() {});
  //       } catch (ex) {
  //         print(ex);
  //         setState(() {});
  //       }
  //       AppLog.showLog(res.toString());
  //       if (_taskList?.success == true) {
  //         setState(() {});
  //       }
  //     });
  //   } catch (e) {
  //     print(e.toString());
  //     Navigator.pop(context);
  //   }
  // }

Future<String> getTaskList() async {
  final SharedPreferences prefs = await _prefs;
  _apiToken = prefs.getString(SP_API_TOKEN)!;

  try {
    final SharedPreferences prefs = await _prefs;
    if (prefs.getBool(SP_IS_LOGIN_BOOL) != null) {
      userId = prefs.getInt(SP_ID)!;
      _apiToken = prefs.getString(SP_API_TOKEN)!;
    }

    var map = {
      "appType": Platform.operatingSystem.toUpperCase(),
      "userId": userId.toString(),
      "api_token": _apiToken,
      "taskDate": DateFormat('yyyy-MM-dd').format(DateTime.now().toUtc()),
    };

    showLoader(context);
    _taskList = null;

    var res = await _networkUtil.post(apiGetTaskList, body: map);
    Navigator.pop(context);

    try {
      _taskList = TaskListApiCallBack.fromJson(res);
      AppLog.showLog(res.toString());

      if (_taskList?.success == true) {
        setState(() {});
        return "success";
      } else {
        return "failed";
      }
    } catch (ex) {
      print(ex);
      setState(() {});
      return "parse_error";
    }
  } catch (e) {
    print(e.toString());
    Navigator.pop(context);
    return "error";
  }
}

  void deleteTask(String taskId) async {
    final SharedPreferences prefs = await _prefs;
    if (prefs.getBool(SP_IS_LOGIN_BOOL) != null) {
       userId = prefs.getInt(SP_ID)!;
      _apiToken = prefs.getString(SP_API_TOKEN)!;
    }
    try {
      var map = new Map<String, dynamic>();
      map["appType"] = Platform.operatingSystem.toUpperCase();
      map["userId"] = userId.toString();
      map["api_token"] = _apiToken;
      map['taskId'] = taskId;
      showLoader(context);

      _networkUtil.post(apiDeleteTask, body: map).then((dynamic res) {
        AppLog.showLog(res.toString());
        Navigator.pop(context);
        if (res['success'] == true) {
          getTaskList();
          showCenterToast('Task Deleted');
          Navigator.pop(context);
        } else if (res['success'] == false) {
          showBottomToast(res['message']);
        }
      });
    } catch (e) {
      Navigator.pop(context);
    }
  }

  getClientList() async {
    try {
      final SharedPreferences prefs = await _prefs;
      if (prefs.getBool(SP_IS_LOGIN_BOOL) != null) {
         userId = prefs.getInt(SP_ID)!;
        _apiToken = prefs.getString(SP_API_TOKEN)!;
      }
      var map = new Map<String, dynamic>();
      map["appType"] = Platform.operatingSystem.toUpperCase();
      map["userId"] = userId.toString();
      map["api_token"] = _apiToken;
      _networkUtil.post(apiGetClientList, body: map).then((dynamic res) {
        _clientListApiCallBack = ClientListApiCallBack.fromJson(res);
        AppLog.showLog(res.toString());
        if (_clientListApiCallBack!.success) {
          setState(() {});
        } else {
          showBottomToast(_clientListApiCallBack!.message ?? "");
        }
      });
    } catch (e) {}
    return 'success';
  }

  getProjectList(String client) async {
    final SharedPreferences prefs = await _prefs;
    if (prefs.getBool(SP_IS_LOGIN_BOOL) != null) {
       userId = prefs.getInt(SP_ID)!;
      _apiToken = prefs.getString(SP_API_TOKEN)!;
    }
    try {
      var map = new Map<String, dynamic>();
      map["appType"] = Platform.operatingSystem.toUpperCase();
      map["userId"] = userId.toString();
      map["api_token"] = _apiToken;
      map['clientId'] = _clientDropdownValue;

      _networkUtil.post(apiGetProjectList, body: map).then((dynamic res) {
        _projectListCallBack = ProjectListCallBack.fromJson(res);
        AppLog.showLog(res.toString());
        if (_projectListCallBack!.success) {
          setState(() {});
        } else {
          showBottomToast(_projectListCallBack!.message ?? "");
        }
      });
    } catch (e) {}
    return 'success';
  }
}
