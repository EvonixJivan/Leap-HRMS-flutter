import 'dart:io';

import 'package:flutter/material.dart';
import 'package:hrms/app/uiComponent/app_loader.dart';
import 'package:hrms/appUtil/app_providers.dart';
import 'package:hrms/appUtil/app_util_config.dart';
import 'package:hrms/appUtil/network_util.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AllTasks extends StatefulWidget {
  final filterBy;
  final date;
  Function refresh;

  AllTasks({Key? key, this.filterBy, this.date, required this.refresh});

  @override
  State<StatefulWidget> createState() {
    return AllTasksState();
  }
}

class AllTasksState extends State<AllTasks> {
  Future<SharedPreferences> _prefs = SharedPreferences.getInstance();
  NetworkUtil _networkUtil = NetworkUtil();
  TodoListApiCallBack? _taskList;
  List<bool> inputs = [];
  bool done = false;
 late int userId;
  var now = new DateTime.now();
  String? formatted, _apiToken;
  var formatter = new DateFormat('yyyy-MM-dd');

  @override
  void initState() {
    formatted = formatter.format(now);
    getCredential();
  }

  getCredential() async {
    final SharedPreferences prefs = await _prefs;
    if (prefs.getBool(SP_IS_LOGIN_BOOL) != null) {
       userId = prefs.getInt(SP_ID)!;
      _apiToken = prefs.getString(SP_API_TOKEN)!;
      getTodoList();
    }
  }

  // Future<String> getTodoList() async {
    Future<void> getTodoList() async {

    try {
      final SharedPreferences prefs = await _prefs;
      if (prefs.getBool(SP_IS_LOGIN_BOOL) != null) {
        _apiToken = prefs.getString(SP_API_TOKEN)!;
      }
      var map = new Map<String, dynamic>();
      map["appType"] = Platform.operatingSystem.toUpperCase();
      map["userId"] = userId.toString();
      map["api_token"] = _apiToken;
      map["filter"] = widget.filterBy;
      map["selectDate"] = widget.date;
      Provider.of<ApiLoader>(context).show();
      _networkUtil.post(apiGetTodoList, body: map).then((dynamic res) {
        try {
          _taskList = TodoListApiCallBack.fromJson(res);
        } catch (ex) {
          print(ex);
        }
        AppLog.showLog(res.toString());
        Provider.of<ApiLoader>(context).hide();
        if (_taskList?.success == true) {
          setState(() {
            inputs = [];
            for (int i = 0; i < _taskList!.data!.length; i++) {
              inputs.add(false);
            }
          });
        } else {
          showBottomToast(_taskList!.message ?? "");
        }
      });
    } catch (e) {
      setState(() {});
      Provider.of<ApiLoader>(context).hide();
      showBottomToast('Internal server error');
      print(e);
      Provider.of<ApiLoader>(context).loaderChange();
    }
  }

  void itemChange(bool val, int index) {
    setState(() {
      inputs[index] = val;
      changeTaskStatus((_taskList?.data![index].id).toString(), val);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Stack(children: <Widget>[
      Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
        Expanded(
          child: (_taskList != null &&
                  _taskList?.data != null &&
                  _taskList!.data!.length > 0)
              ? getTodoView()
              : Container(
                  child: Center(
                    child: Text(
                      noDataFound,
                      style: TextStyle(fontSize: 30),
                    ),
                  ),
                ),
        ),
      ]),
      AppLoaderView(),
    ]);
  }

  Widget getTodoView() {
    return ListView.builder(
      shrinkWrap: true,
      itemBuilder: (BuildContext context, int index) {
        return Padding(
          padding: EdgeInsets.only(left: 5, right: 5, top: 1),
          child: Card(
            elevation: 3,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: <Widget>[
                (_taskList?.data![index].isComplete == 1)
                    ? Checkbox(
                        value: true,
                        onChanged: (bool? value) {
                          itemChange(value!, index);
                        },
                      )
                    : Checkbox(
                        value: inputs[index],
                        onChanged: (bool? value) {
                          itemChange(value!, index);
                        },
                      ),
                Expanded(
                  child: Padding(
                    padding:
                        const EdgeInsets.only(left: 10, top: 10, bottom: 10),
                    child: (_taskList?.data![index].isComplete == 1)
                        ? Text(
                            _taskList!.data![index].tasks ?? "",
                            softWrap: true,
                            maxLines: null,
                            textAlign: TextAlign.left,
                            style: TextStyle(
                                fontSize: 12,
                                decoration: TextDecoration.lineThrough),
                          )
                        : Text(
                            _taskList!.data![index].tasks ?? "",
                            softWrap: true,
                            maxLines: null,
                            textAlign: TextAlign.left,
                            style: TextStyle(fontSize: 12),
                          ),
                  ),
                ),
                IconButton(
                  icon: const Icon(
                    Icons.delete,
                    color: Color.fromRGBO(255, 81, 54, 1),
                  ),
                  onPressed: () {
                    getAlert(_taskList!.data![index].id!);
                  },
                ),
              ],
            ),
          ),
        );
      },
      itemCount: _taskList?.data!.length,
    );
  }

  Future<Future> getAlert(int taskId) async {
    return showDialog(
        context: context,
        builder: (BuildContext context) {
          return StatefulBuilder(builder: (context, setState) {
            return AlertDialog(
              contentPadding: EdgeInsets.all(0),
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.all(Radius.circular(20))),
              content: Container(
                decoration: new BoxDecoration(
                    borderRadius: new BorderRadius.all(Radius.circular(20))),
                padding: EdgeInsets.only(bottom: 10),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: <Widget>[
                    Container(
                        decoration: new BoxDecoration(
                            gradient: LinearGradient(
                              colors: <Color>[
                                Color.fromRGBO(255, 81, 54, 1),
                                Color.fromRGBO(255, 163, 54, 1),
                              ],
                            ),
                            borderRadius: new BorderRadius.only(
                                topLeft: Radius.circular(20),
                                topRight: Radius.circular(20))),
                        padding: EdgeInsets.all(15),
                        child: Text(
                          'Delete',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.w400,
                              color: Colors.white),
                        )),
                    Container(
                      padding: const EdgeInsets.only(top: 30, bottom: 20),
                      margin: EdgeInsets.only(left: 20, right: 20),
                      child: Text(
                        'Are you sure?',
                        textAlign: TextAlign.center,
                        style: TextStyle(fontSize: 20),
                      ),
                    ),
                    //   Center(
                    //     child:
                    Row(
                      children: <Widget>[
                        Expanded(
                          flex: 2,
                          child: Container(
                            padding: EdgeInsets.only(left: 25),
                            child: ElevatedButton(
                              style: ElevatedButton.styleFrom(
                                  shape: RoundedRectangleBorder(
                                      borderRadius:
                                          BorderRadius.circular(20.0))),
                              child: Text('Cancel'),
                              onPressed: () {
                                Navigator.of(context).pop();
                              },
                            ),
                          ),
                        ),
                        //SizedBox(width: 20,),
                        Expanded(
                          flex: 3,
                          child: Container(
                              padding: EdgeInsets.only(
                                  right: 25, left: 25, top: 0, bottom: 0),
                              decoration: BoxDecoration(
                                  borderRadius:
                                      BorderRadius.all(Radius.circular(20))),
                              child: ElevatedButton(
                                style: ElevatedButton.styleFrom(
                                    elevation: 2,
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
                                      const EdgeInsets.fromLTRB(15, 9, 15, 9),
                                  child: const Text('Yes, Delete it!',
                                      style: TextStyle(fontSize: 14)),
                                ),
                                onPressed: () {
                                  setState(() {
                                    deleteTask(taskId);
                                    Navigator.of(context).pop();
                                  });
                                },
                              )),
                        ),
                      ],
                    ),
                    // ),
                  ],
                ),
              ),
            );
          });
        });
  }

  void deleteTask(int taskId) async {
    try {
      final SharedPreferences prefs = await _prefs;
      if (prefs.getBool(SP_IS_LOGIN_BOOL) != null) {
        _apiToken = prefs.getString(SP_API_TOKEN)!;
      }
      var map = new Map<String, dynamic>();
      map["appType"] = Platform.operatingSystem.toUpperCase();
      map["userId"] = userId.toString();
      map["api_token"] = _apiToken;
      map["taskId"] = taskId.toString();

      print(taskId);
      Provider.of<ApiLoader>(context).show();

      _networkUtil.post(apiDeleteToDoTask, body: map).then((dynamic res) {
        AppLog.showLog(res.toString());
        Provider.of<ApiLoader>(context).hide();
        if (res['success'] == true) {
          setState(() {
            getTodoList();
            //_isReload = true;
          });
        } else if (res['success'] == false) {
          showBottomToast(res['message']);
        }
      });
    } catch (e) {
      Provider.of<ApiLoader>(context).loaderChange();
    }
  }

  void changeTaskStatus(String taskId, bool isCheck) async {
    final SharedPreferences prefs = await _prefs;
    _apiToken = prefs.getString(SP_API_TOKEN)!;
    String isTrue;
    if (isCheck == true) {
      isTrue = '1';
    } else {
      isTrue = '0';
    }
    try {
      final SharedPreferences prefs = await _prefs;
      if (prefs.getBool(SP_IS_LOGIN_BOOL) != null) {
        _apiToken = prefs.getString(SP_API_TOKEN)!;
      }
      var map = new Map<String, dynamic>();
      map["appType"] = Platform.operatingSystem.toUpperCase();
      map["userId"] = userId.toString();
      map["api_token"] = _apiToken;
      map["status"] = isTrue;
      map["taskId"] = taskId;

      Provider.of<ApiLoader>(context).show();
      _networkUtil.post(apiChangeToDoTaskStatus, body: map).then((dynamic res) {
        AppLog.showLog(res.toString());
        Provider.of<ApiLoader>(context).hide();
        if (res['success'] == true) {
          showBottomToast(_taskList?.message ?? "");
          getTodoList();
          setState(() {});
        } else {
          showBottomToast(_taskList?.message ?? "");
        }
      });
    } catch (e) {
      print(e.toString());
    }
  }
}

class TodoListApiCallBack {
  int? status;
  bool? success;
  String? message;
  int? offset;
  int? count;
  List<Data>? data;
  int? limit;

  TodoListApiCallBack(
      {required this.status,
     required this.success,
     required this.message,
     required this.offset,
     required this.count,
     required this.data,
     required this.limit});

  TodoListApiCallBack.fromJson(Map<String, dynamic> json) {
    status = json['status'];
    success = json['success'];
    message = json['message'];
    offset = json['offset'];
    count = json['count'];
    if (json['data'] != null) {
       data = List<Data>.from(json['data'].map((v) => Data.fromJson(v)));
    }
    limit = json['limit'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['status'] = this.status;
    data['success'] = this.success;
    data['message'] = this.message;
    data['offset'] = this.offset;
    data['count'] = this.count;
    data['data'] = this.data!.map((v) => v.toJson()).toList();
      data['limit'] = this.limit;
    return data;
  }
}

class Data {
  int? id;
 String? tasks;
  int? userId;
  int? isComplete;
  int? isDelete;

  Data({required this.id, required this.tasks, required this.userId, required this.isComplete, required this.isDelete});

  Data.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    tasks = json['tasks'];
    userId = json['userId'];
    isComplete = json['isComplete'];
    isDelete = json['isDelete'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['id'] = this.id;
    data['tasks'] = this.tasks;
    data['userId'] = this.userId;
    data['isComplete'] = this.isComplete;
    data['isDelete'] = this.isDelete;
    return data;
  }
}
