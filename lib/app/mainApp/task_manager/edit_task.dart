import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:hrms/app/mainApp/task_manager/add_task.dart';
import 'package:hrms/app/mainApp/task_manager/project_list_call_back.dart';
import 'package:hrms/app/mainApp/task_manager/task_type_call_back.dart';
import 'package:hrms/app/uiComponent/custom_header.dart';
import 'package:hrms/appUtil/app_util_config.dart';
import 'package:hrms/appUtil/network_util.dart';
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';

class EditTask extends StatefulWidget {
  var scaffoldKey;
  var title;
 late int taskId;
  String hrsDropdownValue;
  String minDropdownValue;
  String projectDropdownvalue;
  String clientDropdownvalue;
  String taskTypeDropdownvalue;
  int clientId;
  int projectId;
  int taskTypeId;
  String task;

  EditTask(
      {Key? key,
      required this.scaffoldKey,
      required this.title,
      required this.taskId,
      required this.hrsDropdownValue,
      required this.minDropdownValue,
      required this.clientDropdownvalue,
      required this.projectDropdownvalue,
      required this.taskTypeDropdownvalue,
      required this.clientId,
      required this.projectId,
      required this.taskTypeId,
      required this.task})
      : super(key: key);

  @override
  State<StatefulWidget> createState() {
    return EditTaskState();
  }
}

class EditTaskState extends State<EditTask> {
  var formkey = GlobalKey<FormState>();
  Future<SharedPreferences> _prefs = SharedPreferences.getInstance();
  TextEditingController taskController = TextEditingController();
  NetworkUtil _networkUtil = NetworkUtil();
  ClientListApiCallBack? activeListApi;
  ProjectListCallBack? _projectListCallBack;
  TaskTypeCallBack? _taskTypeCallBack;

 String? _clientDropdownValue, _projectDropdownValue, _typeDropdownValue;
  int _userId = 0;
  var now = new DateTime.now();
 String? _apiToken = "", formatted, _localTask;
 late BuildContext _context;
 late int _companyId;
  var formatter = new DateFormat('yyyy-MM-dd');
  TextEditingController? txtTask;

  @override
  void initState() {
    super.initState();
    formatted = formatter.format(now);
    _context = context;
    getClientList();
    getTaskTypeList();
    txtTask = TextEditingController(text: widget.task); //widget.task;
  }

  @override
  Widget build(BuildContext context) {
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
              CustomHeaderWithBack(
                  scaffoldKey: widget.scaffoldKey, title: widget.title),
              Form(
                key: formkey,
                child: Padding(
                    padding: EdgeInsets.only(top: ScreenUtil().setSp(170)),
                    child:
                        (activeListApi != null && activeListApi!.data!.length > 0)
                            ? buildListView()
                            : Container(
                                child: Center(child: Text('Loading')),
                              )),
              )
            ],
          ),
        ),
      ),
    );
  }

  Widget buildListView() {
    return ListView(
      children: <Widget>[
        Container(
          padding: EdgeInsets.only(top: 20),
          margin: EdgeInsets.only(left: 20, right: 20),
          child: Row(
            children: <Widget>[
              Expanded(
                child: Text(
                  'Client : ',
                  style: TextStyle(fontSize: ScreenUtil().setSp(15)),
                ),
              ),
              SizedBox(
                width: 15,
              ),
              Expanded(
                child: Text(
                  'Project : ',
                  style: TextStyle(fontSize: ScreenUtil().setSp(15)),
                ),
              )
            ],
          ),
        ),
        Container(
          padding: const EdgeInsets.only(top: 0),
          margin: EdgeInsets.only(left: 20, right: 20),
          child: Row(
            children: <Widget>[
              clientDropDownList(),
              SizedBox(
                width: 15,
              ),
              projectDropDownList(),
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
                style: TextStyle(fontSize: ScreenUtil().setSp(15)),
                textAlign: TextAlign.start,
              ),
              typeDropDownList(),
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
                style: TextStyle(fontSize: ScreenUtil().setSp(15)),
                textAlign: TextAlign.start,
              ),
              TextFormField(
                  // controller: TextEditingController(text: widget.task),
                  controller: txtTask,
                  maxLines: null,
                  onChanged: (newtask) {
                    widget.task = newtask;
                  }),
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
                  style: TextStyle(fontSize: ScreenUtil().setSp(15)),
                ),
              ),
              SizedBox(
                width: 15,
              ),
              Expanded(
                child: Text(
                  'Minutes : ',
                  style: TextStyle(fontSize: ScreenUtil().setSp(15)),
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
                  hint: Text(widget.hrsDropdownValue),
                  isExpanded: true,
                  value: widget.hrsDropdownValue,
                  onChanged: (newValue) {
                    setState(() {
                      widget.hrsDropdownValue = newValue.toString();
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
                  hint: Text(widget.minDropdownValue),
                  isExpanded: true,
                  value: (widget.minDropdownValue),
                  onChanged: (newValue) {
                    setState(() {
                      widget.minDropdownValue = newValue.toString();
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
                      borderRadius: BorderRadius.all(Radius.circular(20.0))),
                  padding: const EdgeInsets.fromLTRB(70, 7, 70, 7),
                  child:
                      const Text('Edit Task', style: TextStyle(fontSize: 17)),
                ),
                onPressed: () {
                  if (formkey.currentState!.validate()) {
                    if (_typeDropdownValue == null &&
                      widget.taskTypeDropdownvalue == null) {
                    showBottomToast('Select Task type');
                  } else if (txtTask!.text.isEmpty) {
                    showBottomToast('Task is required');
                  } else if (hrsToMin() == '0') {
                showBottomToast('Total time should not be zero');
              } else {
                editTask(widget.taskId.toString());
              }
                  }
                },
              )),
        ),
      ],
    );
  }

  void editTask(
    String taskId,
  ) async {
    String minutes = hrsToMin();
    final SharedPreferences prefs = await _prefs;
    if (prefs.getBool(SP_IS_LOGIN_BOOL) != null) {
      _userId = prefs.getInt(SP_ID)!;
      _apiToken = prefs.getString(SP_API_TOKEN)!;
    }

    String _client;
    if (_clientDropdownValue == '') {
      _client = widget.clientId.toString();
    } else {
      _client = _clientDropdownValue ?? "";
    }

    String _project;
    if (_projectDropdownValue == '') {
      _project = widget.projectId.toString();
    } else {
      _project = _projectDropdownValue ?? "";
    }

    String _type;
    if (_typeDropdownValue == '') {
      _type = widget.taskTypeId.toString();
    } else {
      _type = _typeDropdownValue ?? "";
    }

    try {
      var map = new Map<String, dynamic>();
      map["appType"] = Platform.operatingSystem.toUpperCase();
      map["userId"] = _userId.toString();
      map["api_token"] = _apiToken;
      map['task'] = widget.task;
      map['minutes'] = minutes;
      map['taskDate'] = DateFormat('yyyy-MM-dd').format(DateTime.now().toUtc());
      ;
      map['taskId'] = taskId;
      map["clientId"] = _client;
      map["projectId"] = _project;
      map["taskType"] = _type;
      showLoader(_context);
      _networkUtil.post(apiEditTask, body: map).then((dynamic res) {
        AppLog.showLog(res.toString());
        Navigator.pop(_context);
        if (res['success'] == true) {
          showCenterToast('Task Succesfully Edited');
          setState(() {
            Navigator.of(context).pop({'reload': true});
          });
        } else {
          showBottomToast('Something went wrong. Please try again! ');
        }
      });
    } catch (e) {
      Navigator.of(context).pop({'reload': true});
      print(e.toString());
    }
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

  getProjectList(String client) async {
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
      map["clientId"] = client;

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
      print(e.toString());
    }
    return 'success';
  }

  String hrsToMin() {
    var hrs = int.parse(widget.hrsDropdownValue);
    var min = int.parse(widget.minDropdownValue);
    var time = (hrs * 60) + min;
    return time.toString();
  }

  Widget clientDropDownList() {
    return Expanded(
      child: DropdownButton(
        hint: Text(widget.clientDropdownvalue),
        items: activeListApi?.data!.map((item) {
          return DropdownMenuItem(
            child: new Text(item.clientName ?? ""),
            value: item.id.toString(),
          );
        }).toList(),
        onChanged: (newValue) {
          _projectDropdownValue = "";
          setState(() {
            _clientDropdownValue = newValue.toString();
            print(_clientDropdownValue);
            getProjectList(_clientDropdownValue ?? "");
          });
        },
        isExpanded: true,
        value: _clientDropdownValue,
      ),
    );
  }

  Widget projectDropDownList() {
    return (_projectListCallBack != null &&
            _projectListCallBack?.data != null &&
            _projectListCallBack!.data!.length > 0)
        ? Expanded(
            child: DropdownButton(
              items: _projectListCallBack?.data!.map((dataItem) {
                return DropdownMenuItem(
                  child: new Text(dataItem.name?? ""),
                  value: dataItem.id.toString(),
                );
              }).toList(),
              onChanged: (newValue) {
                setState(() {
                  _projectDropdownValue = newValue.toString();
                });
              },
              isExpanded: true,
              value: _projectDropdownValue,
            ),
          )
        : Expanded(
            child: Text(widget.projectDropdownvalue),
          );
  }

  Widget typeDropDownList() {
    return (_taskTypeCallBack != null &&
            _taskTypeCallBack?.data != null &&
            _taskTypeCallBack!.data.length > 0)
        ? DropdownButton(
            hint: Text(widget.taskTypeDropdownvalue),
            items: _taskTypeCallBack?.data.map((dataItem) {
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
        : Text(widget.taskTypeDropdownvalue);
  }
}
