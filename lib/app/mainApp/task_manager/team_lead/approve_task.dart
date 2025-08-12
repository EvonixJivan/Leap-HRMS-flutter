import 'dart:async';
import 'dart:io';

//import 'package:calendar_strip/calendar_strip.dart' as cs;
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:hrms/app/mainApp/task_manager/employee_tasks_call_back.dart';
import 'package:hrms/app/mainApp/task_manager/team_lead/comments.dart';
import 'package:hrms/app/uiComponent/custom_header.dart';
import 'package:hrms/appUtil/app_util_config.dart';
import 'package:hrms/appUtil/calendar_strip.dart';
import 'package:hrms/appUtil/network_util.dart';
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ApproveTask extends StatefulWidget {
  var scaffoldKey;
  var title;
  int id;
  String date;
  String name;

  ApproveTask(
      {Key? key,
      required this.scaffoldKey,
      required this.title,
      required this.id,
      required this.date,
      required this.name})
      : super(key: key);

  @override
  State<StatefulWidget> createState() {
    return ApproveTaskState();
  }
}

class ApproveTaskState extends State<ApproveTask> {
  NetworkUtil _networkUtil = NetworkUtil();
  Future<SharedPreferences> _prefs = SharedPreferences.getInstance();
  final GlobalKey<ScaffoldState> _scaffoldKey = new GlobalKey<ScaffoldState>();
  final GlobalKey<RefreshIndicatorState> _refreshIndicatorKey =
      new GlobalKey<RefreshIndicatorState>();
  EmployeeListApiCallBack? _employeeListApiCallBack;
  EmployeeTaskApiCallBack? _employeeTaskApiCallBack;
  ChangeStatusApiCallBack? _changeStatusApiCallBack;
 String? _teamDropdownValue;
 late int companyId, userId, taskCount, approvedTask;

 late int teamLeadId;
  var _noDataFound = 'Loading...';
  var now = new DateTime.now();
 String? formatted;
  var formatter = new DateFormat('yyyy-MM-dd');
 String? _apiToken;
 String? selectedDate;
 late DateTime selected;
 late DateTime nDate;

  Future apiCallForTeamMembers() async {
    final SharedPreferences prefs = await _prefs;
    if (prefs.getBool(SP_IS_LOGIN_BOOL) != null) {
       userId = prefs.getInt(SP_ID)!;
      companyId = prefs.getInt(SP_COMPANY_ID)!;
      teamLeadId = prefs.getInt(SP_ID)!;
      _apiToken = prefs.getString(SP_API_TOKEN)!;
    }
    int _role = prefs.getInt(SP_ROLE)!;
    var map = new Map<String, dynamic>();
    map["api_token"] = _apiToken;
    map["appType"] = Platform.operatingSystem.toUpperCase();
    map["userId"] = userId.toString();
    map["companyId"] = companyId.toString();
    map["roleId"] = _role.toString();
    map["teamLeadId"] = teamLeadId.toString();
    map['taskDate'] = selectedDate;
    print('PARAMS FOr Employeelist${map}');
    try {
      _noDataFound = 'Loading...';
      _networkUtil.post(apiGetEmployeelist, body: map).then((dynamic res) {
        _noDataFound = noDataFound;
        try {
          AppLog.showLog(res.toString());
          _employeeListApiCallBack = EmployeeListApiCallBack.fromJson(res);
          if (_employeeListApiCallBack!.status == unAuthorised) {
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

  Future apiCallForTeamTaskList() async {
    final SharedPreferences prefs = await _prefs;

    var map = new Map<String, dynamic>();
    _apiToken = prefs.getString(SP_API_TOKEN)!;
    int _role = prefs.getInt(SP_ROLE)!;
    map["appType"] = Platform.operatingSystem.toUpperCase();
    map["api_token"] = _apiToken;
    map["userId"] = _teamDropdownValue;
    map["roleId"] = _role.toString();
    map["companyId"] = companyId.toString();
    map["taskDate"] = selectedDate;

    print(map);
    try {
      _noDataFound = 'Loading...';
      _networkUtil.post(apiGetEmployeeTask, body: map).then((dynamic res) {
        _noDataFound = noDataFound;

        try {
          AppLog.showLog(res.toString());
          _employeeTaskApiCallBack = EmployeeTaskApiCallBack.fromJson(res);
          if (_employeeTaskApiCallBack!.status == unAuthorised) {
            logout(context);
          }
          if (!_employeeTaskApiCallBack!.suceess) {
            showBottomToast(_employeeTaskApiCallBack!.message ?? "");
          }
//          taskCount = _employeeTaskApiCallBack.taskCount;
//          approvedTask = _employeeTaskApiCallBack.taskApprovedCount;
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

  Future apiCallForChangeStatus(
      int taskId, String _status, String _remark) async {
    final SharedPreferences prefs = await _prefs;
    var map = new Map<String, dynamic>();
    String _apiToken = prefs.getString(SP_API_TOKEN)!;
    int _role = prefs.getInt(SP_ROLE)!;
    int _userId = prefs.getInt(SP_ID)!;
    map["appType"] = Platform.operatingSystem.toUpperCase();
    map["api_token"] = _apiToken;
    map["userId"] = _userId.toString();
    map["roleId"] = _role.toString();
    map["taskId"] = taskId.toString();
    map["status"] = _status;
    map["remark"] = _remark;
    showLoader(context);

    print(map);
    try {
      _noDataFound = 'Loading...';
      _networkUtil.post(apiChangeTaskStatus, body: map).then((dynamic res) {
        _noDataFound = noDataFound;

        try {
          Navigator.pop(context);
          AppLog.showLog(res.toString());
          _changeStatusApiCallBack = ChangeStatusApiCallBack.fromJson(res);
          if (_changeStatusApiCallBack!.status == unAuthorised) {
            logout(context);
          }
          if (!_changeStatusApiCallBack!.success) {
            showBottomToast(_changeStatusApiCallBack!.message ?? "");
          }
        } catch (es) {
          showErrorLog(es.toString());
          showCenterToast(errorApiCall);
        }
        setState(() {});
        Navigator.of(context).pop();
        apiCallForTeamTaskList();
      });
    } catch (e) {
      showErrorLog(e.toString());
      showCenterToast(errorApiCall);
      _noDataFound = noDataFound;
      setState(() {});
    }
  }

  @override
  void initState() {
    super.initState();
    _teamDropdownValue = widget.id.toString();
    apiCallForTeamMembers();
    selectedDate = widget.date;
    selected = DateTime.parse(widget.date);

    apiCallForTeamTaskList();
    print(widget.date);
  }

  Future<Null> _handleRefresh() {
    final Completer<Null> completer = new Completer<Null>();
    new Timer(const Duration(seconds: 3), () {
      completer.complete(null);
    });
    return completer.future.then((_) {
      // _scaffoldKey.currentState?.showSnackBar(new SnackBar(
      //     content: const Text('Refresh complete'),
      //     action: new SnackBarAction(
      //         label: 'RETRY',
      //         onPressed: () {
      //           _refreshIndicatorKey.currentState.show();
      //         })));
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text(("Refresh complete").toString()),
          action: new SnackBarAction(
              label: 'RETRY',
              onPressed: () {
                _refreshIndicatorKey.currentState!.show();
              })));
    });
  }

  @override
  Widget build(BuildContext context) {
    final teamMember = Padding(
        padding: EdgeInsets.only(
          left: ScreenUtil().setSp(10),
          top: ScreenUtil().setSp(10),
          right: ScreenUtil().setSp(10),
        ),
        child: Container(
            padding: EdgeInsets.only(left: ScreenUtil().setSp(10)),
            decoration: BoxDecoration(
              color: Colors.grey[100],
              border: Border.all(width: 1, color: Colors.grey),
              borderRadius: BorderRadius.circular(3),
            ),
            child: 
            (_employeeListApiCallBack?.data?.isNotEmpty ?? false)
                ? DropdownButton(
                    hint: Text('Select Team Member'),
                    items: _employeeListApiCallBack!.data!.map((dataItem) {
                      return DropdownMenuItem(
                        child: new Text(
                            '${dataItem.firstName} ${dataItem.lastName}'),
                        value: dataItem.id.toString(),
                      );
                    }).toList(),
                    onChanged: (newValue) {
                      setState(() {
                        _teamDropdownValue = newValue.toString();
                        apiCallForTeamTaskList();
                      });
                    },
                    isExpanded: true,
                    value: _teamDropdownValue,
                  )
                : DropdownButton<String>(
          hint: Text('Select Task Type'),
          items: [],
          onChanged: (String? newValue) {},
          isExpanded: true,
          value: _teamDropdownValue,
        )));

    DateTime startDate = DateTime.now().subtract(Duration(days: 5000));
    DateTime endDate = DateTime.now().add(Duration(days: 5000));

    return SafeArea(
       top: false,
        bottom: true,
      child: Scaffold(
        backgroundColor: Colors.grey[100],
        body: Stack(
          children: <Widget>[
            CustomHeaderWithBack(
                scaffoldKey: widget.scaffoldKey, title: widget.title),
            Container(
              margin: EdgeInsets.only(top: ScreenUtil().setSp(90.0)),
              child: Column(
                children: <Widget>[
                  Card(
                    elevation: 5,
                    child: CalendarStrip(
                      containerHeight: 80,
                      startDate: startDate,
                      endDate: endDate,
                      // selectedDate: selected,
                      onDateSelected: (date) {
                        setState(() {
                          this.selectedDate = formatter.format(date);
                          nDate = date;
                          apiCallForTeamTaskList();
                        });
                      },
                      selectedDate: nDate,
                      dateTileBuilder: dateTileBuilder,
                      iconColor: Colors.black87,
                      monthNameWidget: monthNameWidget,
                      containerDecoration: BoxDecoration(color: Colors.white),
                       markedDates: [],
                       leftIcon: Icon(Icons.chevron_left),
                      rightIcon: Icon(Icons.chevron_right),  onWeekSelected: (start, end) {
                        print('Week selected: $start - $end');
                      },
                    ),
                  ),
                  Container(
                    width: MediaQuery.of(context).size.width - 10,
                    child: new Card(
                      elevation: 2,
                      child: Padding(
                        padding: EdgeInsets.fromLTRB(7, 7, 7, 7),
                        child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: <Widget>[
                              (_employeeTaskApiCallBack!.data.length > 0)
                                  ? Text(
                                      'Total Working Minutes : ${_employeeTaskApiCallBack!.totalCount}',
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
                              (_employeeTaskApiCallBack!.data.length > 0)
                                  ? Text(
                                      '${_employeeTaskApiCallBack!.taskApprovedCount ?? '0'} / ${_employeeTaskApiCallBack!.taskCount ?? '0'}')
                                  : Text('0'),
                            ]),
                      ),
                    ),
                  ),
                  teamMember,
                  Expanded(
                    child: RefreshIndicator(
                      key: _refreshIndicatorKey,
                      onRefresh: _handleRefresh,
                      child: (_employeeTaskApiCallBack!.data.length > 0)
                          ? buildList()
                          : Container(
                              child: Center(
                                child: Text(_noDataFound),
                              ),
                            ),
                    ),
                  ),
                ],
              ),
            )
          ],
        ),
      ),
    );
  }

  Widget buildList() {
    String _remark = '-';
    final myController = TextEditingController();
    return ListView.builder(
        shrinkWrap: true,
        itemCount: _employeeTaskApiCallBack!.data.length,
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
                          child:
                              (_employeeTaskApiCallBack!.data[index].isNew == 1)
                                  ? Container(
                                      decoration: BoxDecoration(
                                          color: Colors.green,
                                          borderRadius: BorderRadius.only(
                                              topLeft: Radius.circular(3))),
                                      padding: EdgeInsets.only(
                                          top: 2,
                                          bottom: 2,
                                          left: 10,
                                          right: 10),
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
                        child:
                            (_employeeTaskApiCallBack!.data[index].isApproved ==
                                    0)
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
                                : (_employeeTaskApiCallBack!
                                            .data[index].isApproved ==
                                        1)
                                    ? Container(
                                        decoration: BoxDecoration(
                                            color: Colors.green,
                                            borderRadius: BorderRadius.only(
                                                topRight: Radius.circular(3))),
                                        padding: EdgeInsets.all(2),
                                        child: Text(
                                          'Approved',
                                          style: TextStyle(
                                              color: Colors.white,
                                              fontSize: 8.0),
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
                                              color: Colors.white,
                                              fontSize: 8.0),
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
                            Flexible(
                              child: Text(
                                ' ${_employeeTaskApiCallBack!.data[index].projectName}',
                                style: TextStyle(
                                  fontSize: 14.0,
                                ),
                                maxLines: 2,
                              ),
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
                            Flexible(
                              child: Text(
                                ' ${_employeeTaskApiCallBack!.data[index].clientName}',
                                style: TextStyle(
                                  fontSize: 14.0,
                                ),
                                maxLines: 2,
                              ),
                            )
                          ],
                        ),
                      ),
                    ],
                  ),
                  Padding(
                    padding: const EdgeInsets.only(left: 8, right: 8, top: 8),
                    child: Text(
                      _employeeTaskApiCallBack!.data[index].task ?? "",
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
                                '  ${_employeeTaskApiCallBack!.data[index].minutes}:00',
                                style: TextStyle(fontSize: 14.0),
                              ),
                            ],
                          ),
                        ),
                        Expanded(
                          flex: 3,
                          child: getProgressBar(
                              ('${((_employeeTaskApiCallBack!.data[index].percentage ?? 1) > 100) ? 100 : _employeeTaskApiCallBack!.data[index].percentage ?? 1}%'),
                              (((_employeeTaskApiCallBack!
                                              .data[index].percentage ??
                                          1) >
                                      100)
                                  ? 100
                                  : _employeeTaskApiCallBack!
                                          .data[index].percentage ??
                                      1)),
                        )
                      ],
                    ),
                  ),
                  SizedBox(
                    height: 8,
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: <Widget>[
                      // SizedBox(width: ScreenUtil().setSp(10),),
                      Padding(
                          padding: EdgeInsets.only(
                              left: ScreenUtil().setSp(10),
                              bottom: ScreenUtil().setSp(10)),
                          child: Text(
                            '${DateFormat('hh:mm a, dd MMM yyyy').format(DateFormat("yyyy-MM-dd HH:mm:ss").parse(_employeeTaskApiCallBack!.data[index].createdAt ?? "", true).toLocal())}',
                            style: dateTimeTextStyle,
                          )
                          // Text(
                          //   DateFormat('hh:mm a, dd MMM').format(DateTime.parse(
                          //       _employeeTaskApiCallBack!.data[index].createdAt)),
                          //   style: dateTimeTextStyle,
                          // ),
                          ),
                      Container(
                        padding: EdgeInsets.only(
                            top: 2, bottom: 2, left: 1, right: 1),
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
                                '${_employeeTaskApiCallBack!.data[index].commentCount} Comments',
                                style: dateTimeTextStyle,
                              ),
                            ],
                          ),
                          onPressed: () {
                            Navigator.of(context).push(new MaterialPageRoute(
                                builder: (BuildContext context) => new Comments(
                                    scaffoldKey: widget.scaffoldKey,
                                    title: 'Comments',
                                    id: _employeeTaskApiCallBack!.data[index].id,
                                    client: _employeeTaskApiCallBack!
                                        .data[index].clientName ?? "",
                                    project: _employeeTaskApiCallBack!
                                        .data[index].projectName ?? "",
                                    task: _employeeTaskApiCallBack!
                                        .data[index].task ?? "",
                                    minutes: _employeeTaskApiCallBack!
                                        .data[index].minutes ?? "",
                                    time: _employeeTaskApiCallBack!
                                        .data[index].createdAt ?? "")));
                          },
                        ),
                      ),
                      Visibility(
                          child: (_employeeTaskApiCallBack!
                                      .data[index].isApproved ==
                                  0)
                              ? Container(
                                  decoration: BoxDecoration(
                                      borderRadius: BorderRadius.all(
                                          Radius.circular(10))),
                                  padding: EdgeInsets.only(
                                      top: 2, bottom: 2, left: 5, right: 5),
                                  child: ElevatedButton(
                                    style: ElevatedButton.styleFrom(
                                        backgroundColor: Colors.deepOrange),
                                    child: Text(
                                      'Approve',
                                      style: TextStyle(
                                          color: Colors.white,
                                          fontSize: 13.0,
                                          fontWeight: FontWeight.bold),
                                    ),
                                    onPressed: () {
                                      showDialog(
                                          context: context,
                                          builder: (BuildContext context) {
                                            return StatefulBuilder(
                                                builder: (context, setState) {
                                              return AlertDialog(
                                                contentPadding:
                                                    EdgeInsets.all(0),
                                                shape: RoundedRectangleBorder(
                                                    borderRadius: BorderRadius
                                                        .all(Radius.circular(
                                                            ScreenUtil()
                                                                .setSp(10)))),
                                                content: Container(
                                                  decoration: new BoxDecoration(
                                                      borderRadius:
                                                          new BorderRadius.all(
                                                              Radius.circular(
                                                                  ScreenUtil()
                                                                      .setSp(
                                                                          10)))),
                                                  padding: EdgeInsets.only(
                                                      bottom: ScreenUtil()
                                                          .setSp(10)),
                                                  child: Column(
                                                    mainAxisSize:
                                                        MainAxisSize.min,
                                                    crossAxisAlignment:
                                                        CrossAxisAlignment
                                                            .stretch,
                                                    children: <Widget>[
                                                      Container(
                                                          decoration: new BoxDecoration(
                                                              color:
                                                                  appPrimaryColor,
                                                              borderRadius: new BorderRadius.only(
                                                                  topLeft: Radius
                                                                      .circular(
                                                                          10),
                                                                  topRight: Radius
                                                                      .circular(
                                                                          10))),
                                                          padding:
                                                              EdgeInsets.all(
                                                                  15),
                                                          child: Row(
                                                            children: <Widget>[
                                                              Expanded(
                                                                child: Text(
                                                                  'Approve',
                                                                  textAlign:
                                                                      TextAlign
                                                                          .center,
                                                                  style: TextStyle(
                                                                      fontSize: ScreenUtil()
                                                                          .setSp(
                                                                              16),
                                                                      fontWeight:
                                                                          FontWeight
                                                                              .bold,
                                                                      color:
                                                                          appWhiteColor),
                                                                ),
                                                              ),
                                                              GestureDetector(
                                                                child: Icon(
                                                                  Icons.close,
                                                                  color: Colors
                                                                      .white,
                                                                  size: 20,
                                                                ),
                                                                onTap: () {
                                                                  Navigator.pop(
                                                                      context);
                                                                },
                                                              ),
                                                            ],
                                                          )),
                                                      Padding(
                                                        padding: EdgeInsets.only(
                                                            left: ScreenUtil()
                                                                .setSp(20),
                                                            top: ScreenUtil()
                                                                .setSp(20),
                                                            right: ScreenUtil()
                                                                .setSp(20)),
                                                        child: Text(
                                                            'Do you want to approve the task?'),
                                                      ),
                                                      SizedBox(
                                                        height: 20.0,
                                                      ),
                                                      Padding(
                                                        padding:
                                                            const EdgeInsets
                                                                .all(8.0),
                                                        child: Container(
                                                          decoration:
                                                              BoxDecoration(
                                                            color: Colors
                                                                .grey[100],
                                                            border: Border.all(
                                                                width: 1,
                                                                color: Colors
                                                                    .grey),
                                                            borderRadius:
                                                                BorderRadius
                                                                    .circular(
                                                                        3),
                                                          ),
                                                          child: TextFormField(
                                                            controller:
                                                                myController,
                                                            minLines: 1,
                                                            maxLines: 2,
                                                            keyboardType:
                                                                TextInputType
                                                                    .text,
                                                            decoration:
                                                                InputDecoration(
                                                                    border:
                                                                        InputBorder
                                                                            .none,
                                                                    hintText:
                                                                        'Remark',
                                                                    prefixIcon:
                                                                        Icon(
                                                                      Icons
                                                                          .rate_review,
                                                                      color: Colors
                                                                          .grey,
                                                                    )),
                                                            onSaved:
                                                                (String? value) {
                                                              _remark = value!;
                                                              print(value);
                                                            },
                                                          ),
                                                        ),
                                                      ),
                                                      Padding(
                                                        padding:
                                                            const EdgeInsets
                                                                .all(8.0),
                                                        child: Row(
                                                          children: <Widget>[
                                                            Expanded(
                                                              child:
                                                                  ElevatedButton(
                                                                style: ElevatedButton.styleFrom(
                                                                    elevation:
                                                                        5,
                                                                    backgroundColor:
                                                                        Colors
                                                                            .red),
                                                                child: Text(
                                                                  'Reject',
                                                                  style: TextStyle(
                                                                      color: Colors
                                                                          .white,
                                                                      fontSize:
                                                                          13.0,
                                                                      fontWeight:
                                                                          FontWeight
                                                                              .bold),
                                                                ),
                                                                onPressed: () {
                                                                  if (myController
                                                                          .text !=
                                                                      '') {
                                                                    apiCallForChangeStatus(
                                                                        _employeeTaskApiCallBack!
                                                                            .data[
                                                                                index]
                                                                            .id,
                                                                        '-1',
                                                                        myController
                                                                            .text);
                                                                  } else {
                                                                    showCenterToast(
                                                                        'Remark is mandatory');
                                                                  }
                                                                },
                                                              ),
                                                            ),
                                                            SizedBox(
                                                              width: 15.0,
                                                            ),
                                                            Expanded(
                                                              child:
                                                                  ElevatedButton(
                                                                    style: ElevatedButton.styleFrom(
                                                                        elevation:
                                                                        5,
                                                                        backgroundColor:
                                                                        Colors
                                                                            .green),
                                                                child: Text(
                                                                  'Approve',
                                                                  style: TextStyle(
                                                                      color: Colors
                                                                          .white,
                                                                      fontSize:
                                                                          13.0,
                                                                      fontWeight:
                                                                          FontWeight
                                                                              .bold),
                                                                ),
                                                                onPressed: () {
                                                                  apiCallForChangeStatus(
                                                                      _employeeTaskApiCallBack!
                                                                          .data[
                                                                              index]
                                                                          .id,
                                                                      '1',
                                                                      myController
                                                                          .text);
                                                                },
                                                              ),
                                                            ),
                                                          ],
                                                        ),
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
                              : Visibility(
                                  visible: false,
                                  child: Text(''),
                                )),
                    ],
                  ),
                ],
              ),
            ),
          );
        });
  }
}

class ChangeStatusApiCallBack {
 late int status;
 late bool success;
 String? message;
 late int offset;
 String? extra;
 late int total;
 String? limit;
late  String data;

  ChangeStatusApiCallBack(
      {required this.status,
     required this.success,
     required this.message,
      required this.offset,
     required this.extra,
     required this.total,
     required this.limit,
     required this.data});

  ChangeStatusApiCallBack.fromJson(Map<String, dynamic> json) {
    status = json['status'];
    success = json['success'];
    message = json['message'];
    offset = json['offset'];
    extra = json['extra'];
    total = json['total'];
    limit = json['limit'];
    data = json['data'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['status'] = this.status;
    data['success'] = this.success;
    data['message'] = this.message;
    data['offset'] = this.offset;
    data['extra'] = this.extra;
    data['total'] = this.total;
    data['limit'] = this.limit;
    data['data'] = this.data;
    return data;
  }
}

class EmployeeListApiCallBack {
  List<Data>? data;
  int? count; // 0
  int? limit; // 10
  String? message; // success
  int? offset; // 0
  int? status; // 200
  bool? success; // true
  int? totalCount; // 0

  EmployeeListApiCallBack(
      {required this.data,
     required this.count,
     required this.limit,
     required this.message,
     required this.offset,
     required this.status,
     required this.success,
     required this.totalCount});

  factory EmployeeListApiCallBack.fromJson(Map<String, dynamic> json) {
    return EmployeeListApiCallBack(
      data: json['data'] != null
          ? (json['data'] as List).map((i) => Data.fromJson(i)).toList()
          : [],
      count: json['count'],
      limit: json['limit'],
      message: json['message'],
      offset: json['offset'],
      status: json['status'],
      success: json['success'],
      totalCount: json['totalCount'],
    );
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['count'] = this.count;
    data['limit'] = this.limit;
    data['message'] = this.message;
    data['offset'] = this.offset;
    data['status'] = this.status;
    data['success'] = this.success;
    data['totalCount'] = this.totalCount;
    data['data'] = this.data!.map((v) => v.toJson()).toList();
      return data;
  }
}

class Data {
  String? attendance; // H
  String? firstName; // pallvi
  int? id; // 341
  String? inTime;
  String? lastName; // fegade
  String? middleName; // null
  String? minutes;
  String? outTime;
  int? taskApprovedCount; // 0
  int? taskCount; // 0
  int? taskNonApprovedCount; // 0
  String? userName; // pallavi.fegade@evonix.co

  Data(
      {required this.attendance,
     required this.firstName,
     required this.id,
     required this.inTime,
      required this.lastName,
      required this.middleName,
      required this.minutes,
      required this.outTime,
      required this.taskApprovedCount,
      required this.taskCount,
      required this.taskNonApprovedCount,
      required this.userName});

  factory Data.fromJson(Map<String, dynamic> json) {
    return Data(
      attendance: json['attendance'],
      firstName: json['firstName'],
      id: json['id'],
      inTime: json['inTime'],
      lastName: json['lastName'],
      middleName: json['middleName'],
      minutes: json['minutes'],
      outTime: json['outTime'],
      taskApprovedCount: json['taskApprovedCount'],
      taskCount: json['taskCount'],
      taskNonApprovedCount: json['taskNonApprovedCount'],
      userName: json['userName'],
    );
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['attendance'] = this.attendance;
    data['firstName'] = this.firstName;
    data['id'] = this.id;
    data['inTime'] = this.inTime;
    data['lastName'] = this.lastName;
    data['middleName'] = this.middleName;
    data['minutes'] = this.minutes;
    data['outTime'] = this.outTime;
    data['taskApprovedCount'] = this.taskApprovedCount;
    data['taskCount'] = this.taskCount;
    data['taskNonApprovedCount'] = this.taskNonApprovedCount;
    data['userName'] = this.userName;
    return data;
  }
}
