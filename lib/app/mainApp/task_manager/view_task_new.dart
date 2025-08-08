import 'dart:io';

import 'package:flutter/material.dart';
import 'package:hrms/app/mainApp/task_manager/manage_task.dart';
import 'package:hrms/app/mainApp/task_manager/team_lead/comments.dart';
import 'package:hrms/app/mainApp/task_manager/todo.dart';
import 'package:hrms/app/uiComponent/custom_header.dart';
import 'package:hrms/appUtil/app_providers.dart';
import 'package:hrms/appUtil/app_util_config.dart';
import 'package:hrms/appUtil/calendar_strip.dart';
//import 'package:hrms/appUtil/calendar_strip.dart';
import 'package:hrms/appUtil/network_util.dart';
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';
//import 'package:calendar_strip/calendar_strip.dart' as cs;
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_speed_dial/flutter_speed_dial.dart';
import 'package:provider/provider.dart';

class Tasks extends StatefulWidget {
  var scaffoldKey;
  var title;

  Tasks({Key? key, @required this.scaffoldKey, @required this.title})
      : super(key: key);

  @override
  _TaskListState createState() => _TaskListState();
}

class _TaskListState extends State<Tasks> {
  Future<SharedPreferences> _prefs = SharedPreferences.getInstance();
  NetworkUtil _networkUtil = NetworkUtil();
  TaskListApiCallBack? _taskList;
  late int userId;
  late int id;
 String? _apiToken = '';
 late ScrollController scrollController;
  bool dialVisible = true;
  var now = new DateTime.now();
 String? formatted;

  var formatter = new DateFormat('yyyy-MM-dd');
 String? selectedDate;
  var _noDataFound = 'Loading...';
late  DateTime nDate;

  @override
  void initState() {
    super.initState();
    setState(() {
      getCredential();
    });
    formatted = formatter.format(now);
    selectedDate = formatted;
  }

  getCredential() async {
    final SharedPreferences prefs = await _prefs;
    if (prefs.getBool(SP_IS_LOGIN_BOOL) != null) {
       userId = prefs.getInt(SP_ID)!;
      _apiToken = prefs.getString(SP_API_TOKEN)!;
      print('USER ID $userId');
      apiCallForGetTaskList();
    }
  }

  @override
  Widget build(BuildContext context) {
    final apiLoader = Provider.of<ApiLoader>(context);
    if (apiLoader.reload) {
      getCredential();
    }
    DateTime startDate = DateTime.now().subtract(Duration(days: 5000));
    DateTime endDate = DateTime.now().add(Duration(days: 5000));

    return Scaffold(
      backgroundColor: Colors.grey[100],
      body: Stack(
        children: <Widget>[
          CustomHeaderWithBack(
              scaffoldKey: widget.scaffoldKey, title: widget.title),
          Padding(
            padding: EdgeInsets.only(top: ScreenUtil().setSp(90)),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: <Widget>[
                Card(
                  elevation: 5,
                  child: CalendarStrip(
                    containerHeight: 80,
                    startDate: startDate,
                    endDate: endDate,
                    onDateSelected: (date) {
                      setState(() {
                        this.selectedDate = formatter.format(date);
                        apiCallForGetTaskList();
                      });
                    },
                    dateTileBuilder: dateTileBuilder,
                    iconColor: Colors.black87,
                    monthNameWidget: monthNameWidget,
                    containerDecoration: BoxDecoration(color: Colors.white),
                    onWeekSelected: (start, end) {
                      print('Week selected: $start - $end');
                    }, markedDates: [],
                     leftIcon: Icon(Icons.chevron_left),
                    rightIcon: Icon(Icons.chevron_right),  selectedDate: nDate,
                  ),
                ),
                new Card(
                  elevation: 2,
                  child: Padding(
                    padding: EdgeInsets.fromLTRB(7, 7, 7, 7),
                    child: (_taskList != null &&
                           _taskList?.data != null &&
                           _taskList!.data.length > 0)
                        ? Text(
                            'Total Working Minutes : ${_taskList?.totalCount}',
                            style: TextStyle(
                                color: Color.fromRGBO(255, 81, 54, 1),
                                fontSize: 18.0),
                          )
                        : Text(
                            "Total Working Minutes : " + '0',
                            style: TextStyle(
                                color: Color.fromRGBO(255, 81, 54, 1),
                                fontSize: 18.0),
                          ),
                  ),
                ),
                // SizedBox(
                //   height: 5.0,
                // ),
                Expanded(
                  child: (_taskList != null &&
                         _taskList?.data != null &&
                         _taskList!.data.length > 0)
                      ? buildList()
                      : Container(
                          child: Center(
                            child: Text(
                              'No data found',
                              style: TextStyle(fontSize: 30),
                            ),
                          ),
                        ),
                )
              ],
            ),
          ),
          // AppLoaderView(),
        ],
      ),
      floatingActionButton: SpeedDial(
//        marginRight: 18,
//        marginBottom: 20,
        animatedIcon: AnimatedIcons.menu_close,
        animatedIconTheme: IconThemeData(size: 22.0),

        closeManually: false,
        curve: Curves.bounceIn,
        overlayColor: Colors.black,
        overlayOpacity: 0.5,
        tooltip: 'Speed Dial',
        heroTag: 'speed-dial-hero-tag',
        backgroundColor: appPrimaryColor,
        foregroundColor: Colors.white,
        elevation: 8.0,
        shape: CircleBorder(),
        children: [
          SpeedDialChild(
              child: Icon(Icons.date_range),
              backgroundColor: Colors.red,
              label: 'Manage Task',
              labelStyle: TextStyle(fontSize: 18.0),
              onTap: () {
                _taskButtonTapped();
              }),
          SpeedDialChild(
            child: Icon(Icons.check_box),
            backgroundColor: Colors.blue,
            label: 'To Do Task',
            labelStyle: TextStyle(fontSize: 18.0),
            onTap: () {
              Navigator.of(context).push(new MaterialPageRoute(
                builder: (BuildContext context) {
                  return Todo(
                    scaffoldKey: widget.scaffoldKey,
                    title: 'ToDo Task',
                  );
                },
              ));
            },
          ),
        ],
      ),
    );
  }

  Future _taskButtonTapped() async {
    Map results = await Navigator.of(context).push(new MaterialPageRoute(
      builder: (BuildContext context) {
        return HomeScreen(
          scaffoldKey: widget.scaffoldKey,
          title: 'Manage Task',
        );
      },
    ));

    apiCallForGetTaskList();
    }

  @override
  void screenUpdate() {}

  void apiCallForGetTaskList() async {
    showLoader(context);
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
      map['taskDate'] = selectedDate;

      _taskList = null;
      _networkUtil.post(apiGetTaskList, body: map).then((dynamic res) {
        //  _noDataFound = noDataFound;
        Navigator.pop(context);

        try {
          _taskList = TaskListApiCallBack.fromJson(res);
          if (_taskList?.status == unAuthorised) {
            logout(context);
          } else if (!_taskList!.success) {
            showBottomToast(_taskList!.message ?? "");
          }
        } catch (ex) {
          _taskList = null;
          setState(() {});
          Provider.of<ApiLoader>(context).hide();
          print(ex);
          Navigator.pop(context);
        }

        AppLog.showLog(res.toString());
        print(res.toString());
        Provider.of<ApiLoader>(context).hide();

        if (_taskList!.success) {
          setState(() {});
        }
      });
    } catch (e) {
      print(e.toString());
      Navigator.pop(context);

      //  _noDataFound = noDataFound;
    }
  }

  Widget buildList() {
    if (_taskList != null &&_taskList!.totalCount > 0) {
      return ListView.builder(
          shrinkWrap: true,
          itemCount:_taskList?.data.length,
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
                        Visibility(
                            child: (_taskList?.data[index].isNew == 1)
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
                        Container(
                          child: (_taskList?.data[index].isApproved == 0)
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
                              : Container(
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
                                ),
                        ),
                      ],
                    ),
                    SizedBox(
                      height: 8,
                    ),
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
                                ' ${_taskList?.data[index].projectName}',
                                style: TextStyle(
                                  fontSize: 14.0,
                                ),
                                maxLines: 2,
                              )
                            ],
                          ),
                        ),
                        Expanded(
                          child: Row(
                            children: <Widget>[
                              SizedBox(
                                width: 5,
                              ),
                              Icon(
                                Icons.people,
                                color: Colors.deepOrange,
                                size: 15,
                              ),
                              Text(
                                ' ${_taskList?.data[index].clientName}',
                                style: TextStyle(
                                  fontSize: 14.0,
                                ),
                                maxLines: 2,
                              )
                            ],
                          ),
                        ),
                      ],
                    ),
                    Padding(
                      padding: const EdgeInsets.only(left: 8, right: 8, top: 8),
                      child: Text(
                       _taskList!.data[index].task ?? "",
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
                                  '  ${_taskList?.data[index].minutes}:00',
                                  style: TextStyle(fontSize: 14.0),
                                ),
                              ],
                            ),
                          ),
                          Expanded(
                            flex: 3,
                            child: getProgressBar(
                                ('${((_taskList?.data[index].percentage ?? 1) > 100) ? 100 :_taskList?.data[index].percentage ?? 1}'),
                                (((_taskList?.data[index].percentage ?? 1) > 100)
                                    ? 100
                                    :_taskList?.data[index].percentage ?? 1)),
                          )
                        ],
                      ),
                    ),
                    Padding(
                      padding: EdgeInsets.only(left: 8, right: 8, top: 8),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: <Widget>[
                          Container(
                            padding: EdgeInsets.only(
                                top: 2, bottom: 2, left: 10, right: 10),
                            child: ElevatedButton(
                              style: ElevatedButton.styleFrom(
                                  backgroundColor: Colors.white, elevation: 0),
                              child: Row(
                                children: <Widget>[
                                  Icon(
                                    Icons.chat_bubble,
                                    color: appPrimaryColor,
                                    size: 15,
                                  ),
                                  SizedBox(
                                    width: 5,
                                  ),
                                  Text(
                                    '${_taskList?.data[index].commentCount} Comments',
                                    style: dateTimeTextStyle,
                                  ),
                                ],
                              ),
                              onPressed: () {
                                Navigator.of(context).push(
                                    new MaterialPageRoute(
                                        builder: (BuildContext context) =>
                                            new Comments(
                                              scaffoldKey: widget.scaffoldKey,
                                              title: 'Comments',
                                              id:_taskList!.data[index].id,
                                              client: _taskList!
                                                  .data[index].clientName ?? "",
                                              project: _taskList!
                                                  .data[index].projectName ?? "",
                                              task:_taskList!.data[index].task ?? "",
                                              minutes:
                                                 _taskList!.data[index].minutes ?? "",
                                              time: _taskList!
                                                  .data[index].updatedAt ?? "",
                                              // time: _taskList
                                              //     .data[index].updated_at
                                            )));
                              },
                            ),
                          ),

                          //Text(_taskList?.data[index].created_at),
                          // Text(DateFormat('hh:mm a, MMM yyyy').format(
                          //    DateTime.parse(_taskList?.data[index].created_at)),style: dateTimeTextStyle,),
                          Text(
                            '${DateFormat('hh:mm a, dd MMM yyyy').format(DateFormat("yyyy-MM-dd HH:mm:ss").parse(_taskList!.data[index].createdAt ?? "", true).toLocal())}',
                            style: dateTimeTextStyle,
                          )
                        ],
                      ),
                    ),
                    SizedBox(
                      height: 8,
                    )
                  ],
                ),
              ),
            );
          });
   } else {
    return Center(
      child: Text(
        '',
        style: TextStyle(fontSize: 16, color: Colors.grey),
      ),
    );
    }
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
                          child: (_taskList?.data[index].isNew == 1)
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
                      child: (_taskList?.data[index].isApproved == 0)
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
                          : (_taskList?.data[index].isApproved == 1)
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
                (_taskList?.data[index].clientName != '')
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
                                ' ${_taskList?.data[index].clientName}',
                                style: TextStyle(
                                  fontSize: 14.0,
                                ),
                                maxLines: 2,
                              )
                            ],
                          ),
                        ),
                        (_taskList?.data[index].isApproved == 0)
                            ? Container(
                                padding: const EdgeInsets.all(0.0),
                                width: 40,
                                height: 30,
                                child: ElevatedButton(
                                  style: ElevatedButton.styleFrom(
                                      backgroundColor: Colors.white,
                                      elevation: 0),
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
                                                                style: ElevatedButton.styleFrom(
                                                                    backgroundColor:
                                                                        Colors
                                                                            .white,
                                                                    elevation:
                                                                        0,
                                                                    textStyle: TextStyle(
                                                                        color: Colors
                                                                            .white),
                                                                    padding:
                                                                        const EdgeInsets.all(
                                                                            0.0),
                                                                    shape: RoundedRectangleBorder(
                                                                        borderRadius:
                                                                            BorderRadius.circular(20.0))),
                                                                child:
                                                                    Container(
                                                                  decoration:
                                                                      const BoxDecoration(
                                                                          gradient:
                                                                              LinearGradient(
                                                                            colors: <Color>[
                                                                              Color.fromRGBO(255, 81, 54, 1),
                                                                              Color.fromRGBO(255, 163, 54, 1),
                                                                            ],
                                                                          ),
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
                                                                  setState(
                                                                      () {});
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
                            ' ${_taskList?.data[index].projectName}',
                            style: TextStyle(
                              fontSize: 14.0,
                            ),
                            maxLines: 2,
                          )
                        ],
                      ),
                    ),
                    Visibility(
                        child: (_taskList?.data[index].isApproved == 0)
                            ? Container(
                                padding: const EdgeInsets.all(0.0),
                                width: 40,
                                height: 30,
                                child: ElevatedButton(
                                  style: ElevatedButton.styleFrom(
                                      backgroundColor: Colors.white,
                                      elevation: 0),
                                  child: const Icon(
                                    Icons.edit,
                                    color: Colors.teal,
                                    size: 20,
                                  ),
                                  onPressed: () {
                                    // getClientList();
                                    var time =_taskList?.data[index].minutes ?? ""
                                        .split(':');
                                    print(time);
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
                   _taskList!.data[index].task ?? "",
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
                              '  ${_taskList?.data[index].minutes}:00 ',
                              style: TextStyle(fontSize: 14.0),
                            ),
                          ],
                        ),
                      ),
                      Expanded(
                        flex: 3,
                        child: getProgressBar(
                            ('${((_taskList?.data[index].percentage ?? 1) > 100) ? 100 :_taskList?.data[index].percentage ?? 1}'),
                            (((_taskList?.data[index].percentage ?? 1) > 100)
                                ? 100
                                :_taskList?.data[index].percentage ?? 1)),
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
                          '${DateFormat('hh:mm a').format(DateFormat("yyyy-MM-dd HH:mm:ss").parse(_taskList!.data[index].createdAt ?? "", true).toLocal())}')
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
      itemCount:_taskList?.data.length,
    );
  }
}

/*
class TaskListApiCallBack {
  List<Data> data;
  String extra;
  int limit; // 10
  String message; // success
  int offset; // 10
  int status; // 200
  bool success; // true
  int taskApprovedCount=0; // 0
  int taskCount; // 5
  int taskNonApprovedCount; // 5
  int totalCount; // 180

  TaskListApiCallBack({this.data, this.extra, this.limit, this.message, this.offset, this.status, this.success, this.taskApprovedCount, this.taskCount, this.taskNonApprovedCount, this.totalCount});

  factory TaskListApiCallBack.fromJson(Map<String, dynamic> json) {
    return TaskListApiCallBack(
      data: json['data'] != null ? (json['data'] as List).map((i) => Data.fromJson(i)).toList() : null,
      extra: json['extra'],
      limit: json['limit'],
      message: json['message'],
      offset: json['offset'],
      status: json['status'],
      success: json['success'],
      taskApprovedCount: json['taskApprovedCount']??0,
      taskCount: json['taskCount']??0,
      taskNonApprovedCount: json['taskNonApprovedCount']??0,
      totalCount: json['totalCount'],
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
    data['taskApprovedCount'] = this.taskApprovedCount;
    data['taskCount'] = this.taskCount;
    data['taskNonApprovedCount'] = this.taskNonApprovedCount;
    data['totalCount'] = this.totalCount;
    if (this.data != null) {
      data['data'] = this.data.map((v) => v.toJson()).toList();
    }
    return data;
  }
}

class Data {
  int clientId; // 33
  String clientName; // Ascentia
  String created_at; // 2020-03-31 23:12:24
  int id; // 2338
  int isApproved; // 0
  int isNew; // 1
  String minutes; // 00:40
  int percentage; // 8
  int projectId; // 65
  String projectName; // Ascentia
  String task; // w
  String taskDate; // 2020-03-31
  String taskType;
  int taskTypeId;// Client Call
  String updated_at; // 2020-03-31 23:12:24
  int commentCount = 0;

  Data({this.clientId, this.clientName, this.created_at, this.id, this.isApproved, this.isNew, this.minutes, this.percentage, this.projectId, this.projectName, this.task, this.taskDate, this.taskType, this.taskTypeId, this.updated_at});

  factory Data.fromJson(Map<String, dynamic> json) {
    return Data(
      clientId: json['clientId'],
      clientName: json['clientName'],
      created_at: json['created_at'],
      id: json['id'],
      isApproved: json['isApproved'],
      isNew: json['isNew'],
      minutes: json['minutes'],
      percentage: json['percentage'],
      projectId: json['projectId'],
      projectName: json['projectName'],
      task: json['task'],
      taskDate: json['taskDate'],
      taskType: json['taskType'],
      taskTypeId: json['taskTypeId'],
      updated_at: json['updated_at'],
    );
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['clientId'] = this.clientId;
    data['clientName'] = this.clientName;
    data['created_at'] = this.created_at;
    data['id'] = this.id;
    data['isApproved'] = this.isApproved;
    data['isNew'] = this.isNew;
    data['minutes'] = this.minutes;
    data['percentage'] = this.percentage;
    data['projectId'] = this.projectId;
    data['projectName'] = this.projectName;
    data['task'] = this.task;
    data['taskDate'] = this.taskDate;
    data['taskType'] = this.taskType;
    data['taskTypeId'] = this.taskTypeId;
    data['updated_at'] = this.updated_at;
    return data;
  }
}
*/

class TaskListApiCallBack {
 late int status;
 late bool success;
 String? message;
 late int offset;
 late int totalCount;
 late int taskCount;
 late int taskApprovedCount;
 late int taskNonApprovedCount;
 String? extra;
 late int limit;
  List<Data> data = [];

  TaskListApiCallBack(
      {required this.status,
     required this.success,
     required this.message,
     required this.offset,
     required this.totalCount,
     required this.taskCount,
     required this.taskApprovedCount,
     required this.taskNonApprovedCount,
     required this.extra,
     required this.limit,
     required this.data});

  TaskListApiCallBack.fromJson(Map<String, dynamic> json) {
    status = json['status'];
    success = json['success'];
    message = json['message'];
    offset = json['offset'];
    totalCount = json['totalCount'];
    taskCount = json['taskCount'];
    taskApprovedCount = json['taskApprovedCount'];
    taskNonApprovedCount = json['taskNonApprovedCount'];
    extra = json['extra'];
    limit = json['limit'];
    if (json['data'] != null) {
      data = List<Data>.from(json['data'].map((v) => Data.fromJson(v)));
    }
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['status'] = this.status;
    data['success'] = this.success;
    data['message'] = this.message;
    data['offset'] = this.offset;
    data['totalCount'] = this.totalCount;
    data['taskCount'] = this.taskCount;
    data['taskApprovedCount'] = this.taskApprovedCount;
    data['taskNonApprovedCount'] = this.taskNonApprovedCount;
    data['extra'] = this.extra;
    data['limit'] = this.limit;
    data['data'] = this.data.map((v) => v.toJson()).toList();
      return data;
  }
}


class Data {
 late int id;
 String? task;
 String? minutes;
 String? taskDate;
 late int clientId;
 late int projectId;
 late int taskTypeId;
 String? taskType;
String? taskTypeName;
 String? projectName;
 String? clientName;
 late int percentage;
 late int commentCount;
 String? remark;
 late int isNew;
 late int isApproved;
 late int isComplete;
 String? createdAt;
 String? updatedAt;

  Data(
      {required this.id,
      required this.task,
      required this.minutes,
      required this.taskDate,
      required this.clientId,
      required this.projectId,
      required this.taskTypeId,
      required this.taskType,
      required this.taskTypeName,
      required this.projectName,
      required this.clientName,
      required this.percentage,
      required this.commentCount,
      required this.remark,
      required this.isNew,
      required this.isApproved,
      required this.isComplete,
      required this.createdAt,
      required this.updatedAt});

  Data.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    task = json['task'];
    minutes = json['minutes'];
    taskDate = json['taskDate'];
    clientId = json['clientId'];
    projectId = json['projectId'];
    taskTypeId = json['taskTypeId'];
    taskType = json['taskType'];
    taskTypeName = json['taskTypeName'];
    projectName = json['projectName'];
    clientName = json['clientName'];
    percentage = json['percentage'];
    commentCount = json['commentCount'];
    remark = json['remark'];
    isNew = json['isNew'];
    isApproved = json['isApproved'];
    isComplete = json['is_complete'];
    createdAt = json['created_at'];
    updatedAt = json['updated_at'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['id'] = this.id;
    data['task'] = this.task;
    data['minutes'] = this.minutes;
    data['taskDate'] = this.taskDate;
    data['clientId'] = this.clientId;
    data['projectId'] = this.projectId;
    data['taskTypeId'] = this.taskTypeId;
    data['taskType'] = this.taskType;
    data['taskTypeName'] = this.taskTypeName;
    data['projectName'] = this.projectName;
    data['clientName'] = this.clientName;
    data['percentage'] = this.percentage;
    data['commentCount'] = this.commentCount;
    data['remark'] = this.remark;
    data['isNew'] = this.isNew;
    data['isApproved'] = this.isApproved;
    data['is_complete'] = this.isComplete;
    data['created_at'] = this.createdAt;
    data['updated_at'] = this.updatedAt;
    return data;
  }
}
