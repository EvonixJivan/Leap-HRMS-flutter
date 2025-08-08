import 'dart:async';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:hrms/app/mainApp/task_manager/all_tasks.dart';
import 'package:hrms/app/mainApp/task_manager/team_lead/approve_task.dart';
import 'package:hrms/app/uiComponent/custom_header.dart';
import 'package:hrms/appUtil/app_providers.dart';
import 'package:hrms/appUtil/app_util_config.dart';
import 'package:hrms/appUtil/network_util.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

class Todo extends StatefulWidget {
  var scaffoldKey;
  var title;
  Todo({Key? key, @required this.scaffoldKey, @required this.title});

  @override
  State<StatefulWidget> createState() {
    return TodoState();
  }
}

class TodoState extends State<Todo> with TickerProviderStateMixin {
  TabController? _controller;
  var formTodokey = GlobalKey<FormState>();
  Future<SharedPreferences> _prefs = SharedPreferences.getInstance();
  TextEditingController taskController = TextEditingController();
  NetworkUtil _networkUtil = NetworkUtil();
  var now = new DateTime.now();
  TodoListApiCallBack? _taskList;
  EmployeeListApiCallBack? _employeeListApiCallBack;
  String? _teamDropdownValue, apiToken, userId;
  var _noDataFound = 'Loading...';
 late int companyId;
  int? teamLeadId, teamLead;

  var _valueToAdd = new DateFormat('dd-MM-yyyy').format(DateTime.now());
  var _valueToFilter = new DateFormat('dd-MM-yyyy').format(DateTime.now());
  var _valueToAddForAPI = new DateFormat('yyyy-MM-dd').format(DateTime.now());
  var _valueToFilterForAPI =
      new DateFormat('yyyy-MM-dd').format(DateTime.now());
  var _todayDate = new DateFormat('yyyy-MM-dd').format(DateTime.now());

  Future _selectDateAdd() async {
    DateTime? picked = await showDatePicker(
        context: context,
        initialDate: new DateTime.now(),
        firstDate: new DateTime(2016),
        lastDate: new DateTime(2025));
    // if (picked != null && (picked.isAfter(DateTime.now()))) {
    final today = DateTime(now.year, now.month, now.day);
    final aDate = DateTime(picked!.year, picked.month, picked.day);

    if (aDate == today) {
      setState(() {
        _valueToAdd = new DateFormat('dd-MM-yyyy').format(picked);
        _valueToAddForAPI = new DateFormat('yyyy-MM-dd').format(picked);
        _controller?.animateTo(0);
      });
    } else if ((picked.isAfter(DateTime.now()))) {
      setState(() {
        _valueToAdd = new DateFormat('dd-MM-yyyy').format(picked);
        _valueToAddForAPI = new DateFormat('yyyy-MM-dd').format(picked);
        _controller?.animateTo(0);
      });
    } else {
      showBottomToast("You can't select the older date.");
    }
  }

  Future isTeamLead() async {
    final SharedPreferences prefs = await _prefs;
    if (prefs.getBool(SP_IS_LOGIN_BOOL) != null) {
      teamLead = prefs.getInt(APPROVE_TASK)!;
    }
  }

  Future _selectDateFilter() async {
    DateTime? picked = await showDatePicker(
        context: context,
        initialDate: new DateTime.now(),
        firstDate: new DateTime(2016),
        lastDate: new DateTime(2025));
    if (picked != null)
      setState(() {
        _valueToFilter = new DateFormat('dd-MM-yyyy').format(picked);
        _valueToFilterForAPI = new DateFormat('yyyy-MM-dd').format(picked);
        if (_controller?.index == 0) {
          _controller?.animateTo(2);
          _controller?.animateTo(0);
        } else {
          _controller?.animateTo(0);
        }
      });
  }

  @override
  void initState() {
    super.initState();
    _controller = TabController(vsync: this, length: 5);
    _controller?.addListener(_handleTabSelection);
    isTeamLead();
    apiCallForTeamMembers();
  }

  @override
  void dispose() {
    _controller?.dispose();
    super.dispose();
  }

  _handleTabSelection() {
    if (_controller!.indexIsChanging) {
      setState(() {});
    }
  }

  String? _apiToken;

  Future apiCallForTeamMembers() async {
    final SharedPreferences prefs = await _prefs;
    if (prefs.getBool(SP_IS_LOGIN_BOOL) != null) {
      userId = prefs.getInt(SP_ID)!.toString();
      companyId = prefs.getInt(SP_COMPANY_ID)!;
      teamLeadId = prefs.getInt(TEAM_LEAD_ID)!;
      _apiToken = prefs.getString(SP_API_TOKEN)!;
    }
    int? _role = prefs.getInt(SP_ROLE)!;
    var map = new Map<String, dynamic>();
    map["appType"] = Platform.operatingSystem.toUpperCase();
    map["userId"] = userId;
    map["companyId"] = companyId.toString();
    map["roleId"] = _role.toString();
    map["api_token"] = _apiToken;
    map["teamLeadId"] = teamLeadId.toString();
    print('PARAMS FOr Employeelist${map}');
    try {
      _noDataFound = 'Loading...';
      _networkUtil.post(apiGetEmployeelist, body: map).then((dynamic res) {
        _noDataFound = noDataFound;
        try {
          AppLog.showLog(res.toString());
          _employeeListApiCallBack = EmployeeListApiCallBack.fromJson(res);
          if (_employeeListApiCallBack?.status == unAuthorised) {
            logout(context);
          } else if (!_employeeListApiCallBack!.success!) {
            showBottomToast(_employeeListApiCallBack!.message ?? "");
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

  Future addTask() async {
    if (formTodokey.currentState!.validate()) {
      formTodokey.currentState!.save();

      final SharedPreferences prefs = await _prefs;
      _apiToken = prefs.getString(SP_API_TOKEN)!;
      print(_valueToAddForAPI);

      try {
        if (prefs.getBool(SP_IS_LOGIN_BOOL) != null) {
          _apiToken = prefs.getString(SP_API_TOKEN)!;
          userId = prefs.getInt(SP_ID)!.toString();
        }

        if (_teamDropdownValue == '' || _teamDropdownValue == null) {
          userId = userId; 
        } else {
          userId = _teamDropdownValue;
        }
        var map = new Map<String, dynamic>();
        map["appType"] = Platform.operatingSystem.toUpperCase();
        map["userId"] = userId;
        map["api_token"] = _apiToken;
        map["taskDate"] =
            new DateFormat('yyyy-MM-dd').format(DateTime.now().toUtc());
        ;
        map["task"] = taskController.text;
        map["is_complete"] = '0';

        print('Params $map');
        Provider.of<ApiLoader>(context).show();
        _networkUtil.post(apiAddToDoTask, body: map).then((dynamic res) {
          print("G1--res-->$res");
          AppLog.showLog(res.toString());
       Provider.of<ApiLoader>(context, listen: false).hide();
          if (res['success'] == true) {
            setState(() {
              taskController.text = '';
              showBottomToast('Task added successfully.');
              // getTodoList();
            });
          } else {
            showBottomToast(res['message']);
          }
        });
      } catch (e) {
        setState(() {});
       Provider.of<ApiLoader>(context, listen: false).hide();
        showBottomToast('Internal server error');
        print(e);
        // Provider.of<ApiLoader>(context).loaderChange();
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final teamMember = Padding(
        padding: EdgeInsets.only(
          left: ScreenUtil().setSp(20),
          top: ScreenUtil().setSp(10),
          right: ScreenUtil().setSp(20),
        ),
        child: Container(
            padding: EdgeInsets.only(left: ScreenUtil().setSp(10)),
            decoration: BoxDecoration(
              color: Colors.grey[100],
              border: Border.all(width: 1, color: Colors.grey),
              borderRadius: BorderRadius.circular(3),
            ),
            child: (_employeeListApiCallBack != null &&
                    _employeeListApiCallBack?.data != null &&
                    _employeeListApiCallBack!.data!.length > 0)
                ? DropdownButton(
                    hint: Text('Select Team Member'),
                    items: _employeeListApiCallBack?.data!.map((dataItem) {
                      return DropdownMenuItem(
                        child: new Text(
                            '${dataItem.firstName} ${dataItem.lastName}'),
                        value: dataItem.id.toString(),
                      );
                    }).toList(),
                    onChanged: (newValue) {
                      setState(() {
                        _teamDropdownValue = newValue.toString();
                      });
                    },
                    isExpanded: true,
                    value: _teamDropdownValue,
                  )
                : DropdownButton<String>(
                    hint: Text('Select Team Member'),
                    items: [],
                    onChanged: (String? newValue) {},
                    isExpanded: true,
                    value: _teamDropdownValue,
                  )
                
                  ));
    return Scaffold(
      body: Container(
        child: Form(
          key: formTodokey,
          child: DefaultTabController(
            child: Center(
              child: Column(
                children: <Widget>[
                  CustomHeaderWithBack(
                      scaffoldKey: widget.scaffoldKey, title: widget.title),
                  Visibility(
                      child: (teamLead == 1)
                          ? Container(
                              child: teamMember,
                            )
                          : Visibility(
                              visible: false,
                              child: Text(''),
                            )),
                  Card(
                      elevation: 3,
                      child: Column(
                        children: <Widget>[
                          Padding(
                            padding: const EdgeInsets.only(
                                top: 5, left: 20, right: 20),
                            child: Container(
                              child: ElevatedButton(
                                style: ElevatedButton.styleFrom(
                                    backgroundColor: Colors.white,
                                    elevation: 2),
                                child: Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: <Widget>[
                                    Text(_valueToAdd),
                                    Icon(Icons.calendar_today),
                                  ],
                                ),
                                onPressed: () {
                                  setState(() {
                                    _selectDateAdd();
                                  });
                                },
                              ),
                            ),
                          ),
                          Container(
                            margin: EdgeInsets.only(left: 20, right: 20),
                            child: TextFormField(
                              validator: (value) {
                                if (value!.isEmpty) {
                                  return 'Please add task';
                                }
                                return null;
                              },
                              controller: taskController,
                              maxLines: 1,
                              decoration: InputDecoration(hintText: "Add Task"),
                            ),
                          ),
                          SizedBox(
                            height: 20,
                          ),
                          Center(
                            child: Container(
                                height: 35,
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
                                            Colors.green,
                                            Colors.green
                                          ],
                                        ),
                                        borderRadius: BorderRadius.all(
                                            Radius.circular(20.0))),
                                    padding:
                                        const EdgeInsets.fromLTRB(70, 7, 70, 7),
                                    child: const Text('Add ToDo Task',
                                        style: TextStyle(fontSize: 17)),
                                  ),
                                  onPressed: () {
                                    setState(() {
                                      addTask();
                                    });
                                  },
                                )),
                          ),
                          SizedBox(
                            height: 10,
                          ),
                        ],
                      )),
                  SizedBox(
                    height: 5,
                  ),
                  Divider(
                    height: 1,
                    color: Colors.black,
                  ),
                  SizedBox(
                    height: 5,
                  ),
                  Padding(
                    padding: const EdgeInsets.only(left: 20, right: 20),
                    child: Container(
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.white, elevation: 2),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: <Widget>[
                            Text(_valueToFilter),
                            Icon(Icons.calendar_today),
                          ],
                        ),
                        onPressed: () {
                          setState(() {
                            _selectDateFilter();
                          });
                        },
                      ),
                    ),
                  ),
                  Container(
                    decoration: new BoxDecoration(
                      gradient: new LinearGradient(colors: [
                        Color.fromRGBO(255, 81, 54, 1),
                        Color.fromRGBO(255, 163, 54, 1),
                      ]),
                    ),
                    height: 40,
                    child: TabBar(
                      controller: _controller,
                      isScrollable: true,
                      labelColor: Colors.green,
                      unselectedLabelColor: Colors.white,
                      indicator: BoxDecoration(color: Colors.grey[200]),
                      tabs: [
                        Container(
                          child: Tab(
                            text: "All Tasks",
                          ),
                        ),
                        Container(
                          margin: EdgeInsets.all(5),
                          child: Tab(text: "Scheduled"),
                        ),
                        Container(
                          margin: EdgeInsets.all(5),
                          child: Tab(text: "Today"),
                        ),
                        Container(
                          margin: EdgeInsets.all(5),
                          child: Tab(text: "Done"),
                        ),
                        Container(
                          margin: EdgeInsets.all(5),
                          child: Tab(text: "Deleted"),
                        ),
                      ],
                    ),
                  ),
                  Expanded(
                    child: TabBarView(
                      controller: _controller,
                      children: [
                        AllTasks(
                          filterBy: '',
                          date: _valueToFilterForAPI,
                          refresh: refresh,
                        ),
                        AllTasks(
                          filterBy: 'scheduled',
                          date: _valueToFilterForAPI,
                          refresh: refresh,
                        ),
                        AllTasks(
                          filterBy: '',
                          date: _todayDate,
                          refresh: refresh,
                        ),
                        AllTasks(
                          filterBy: 'done',
                          date: _valueToFilterForAPI,
                          refresh: refresh,
                        ),
                        AllTasks(
                          filterBy: 'deleted',
                          date: _valueToFilterForAPI,
                          refresh: refresh,
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            length: 5,
          ),
        ),
      ),
    );
  }

  refresh() {
    setState(() {});
  }

  // Future<String> getTodoList() async {
  //   try {
  //     final SharedPreferences prefs = await _prefs;
  //     if (prefs.getBool(SP_IS_LOGIN_BOOL) != null) {
  //       userId = prefs.getInt(SP_ID)!.toString();
  //       _apiToken = prefs.getString(SP_API_TOKEN)!;
  //     }
  //     var map = new Map<String, dynamic>();
  //     map["appType"] = Platform.operatingSystem.toUpperCase();
  //     map["userId"] = userId;
  //     map["api_token"] = _apiToken;
  //     map["filter"] = '';
  //     map["selectDate"] =
  //         DateFormat('yyyy-MM-dd').format(DateTime.now().toUtc());
  //     // _valueToFilterForAPI;
  //     print('PARAMS: $map');
  //     Provider.of<ApiLoader>(context).show();
  //     _networkUtil.post(apiGetTodoList, body: map).then((dynamic res) {
  //       try {
  //         _taskList = TodoListApiCallBack.fromJson(res);
  //       } catch (ex) {
  //         print(ex);
  //       }
  //       AppLog.showLog(res.toString());
  //       Provider.of<ApiLoader>(context).hide();
  //       if (_taskList?.success == true) {
  //         setState(() {});
  //       } else {
  //         showBottomToast(_taskList?.message ?? "");
  //       }
  //     });
  //   } catch (e) {
  //     print(e.toString());
  //     Provider.of<ApiLoader>(context).loaderChange();
  //   }
  // }

}
