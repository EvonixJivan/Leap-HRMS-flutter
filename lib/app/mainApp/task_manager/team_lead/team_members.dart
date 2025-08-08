import 'dart:async';
import 'dart:io';

//import 'package:calendar_strip/calendar_strip.dart' as cs;
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:hrms/app/mainApp/task_manager/team_lead/approve_task.dart';
import 'package:hrms/app/uiComponent/custom_header.dart';
import 'package:hrms/appUtil/app_util_config.dart';
import 'package:hrms/appUtil/calendar_strip.dart';
import 'package:hrms/appUtil/network_util.dart';
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';

class TeamMember extends StatefulWidget {
  var scaffoldKey;
  var title;

  TeamMember({Key? key, @required this.scaffoldKey, @required this.title})
      : super(key: key);

  @override
  State<StatefulWidget> createState() {
    return TeamMemberState();
  }
}

class TeamMemberState extends State<TeamMember> {
  NetworkUtil _networkUtil = NetworkUtil();
  Future<SharedPreferences> _prefs = SharedPreferences.getInstance();
  final GlobalKey<ScaffoldState> _scaffoldKey = new GlobalKey<ScaffoldState>();
  final GlobalKey<RefreshIndicatorState> _refreshIndicatorKey =
      new GlobalKey<RefreshIndicatorState>();
  EmployeeListApiCallBack? _employeeListApiCallBack;
 String? _apiToken;
 late int companyId, userId;
 late int teamLeadId;
  var _noDataFound = 'Loading...';
  DateTime startDate = DateTime.now().subtract(Duration(days: 30));
  DateTime endDate = DateTime.now().add(Duration(days: 30));
  var now = new DateTime.now();
 String? formatted;
  var formatter = new DateFormat('yyyy-MM-dd');
 String? selectedDate;
late  DateTime nDate;
  @override
  void initState() {
    super.initState();
    formatted = formatter.format(now);
    selectedDate = formatted;
    apiCallForTeamMembers();
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

    return Scaffold(
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
                      onDateSelected: (date) {
                        setState(() {
                          this.selectedDate = formatter.format(date);
                          nDate = date;
                          apiCallForTeamMembers();
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
                  Expanded(
                    child: RefreshIndicator(
                      key: _refreshIndicatorKey,
                      onRefresh: _handleRefresh,
                      child: (_employeeListApiCallBack!.data!.length > 0)
                          ? buildListView()
                          : Container(
                              child: Center(
                                child: Text(_noDataFound),
                              ),
                            ),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.only(left: 8.0, right: 8.0),
                    child: Card(
                      child: Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Container(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: <Widget>[
                              Row(
                                children: <Widget>[
                                  SizedBox(
                                    width: 10.0,
                                  ),
                                  Expanded(
                                    child: Row(
                                      children: <Widget>[
                                        Container(
                                          margin: EdgeInsets.symmetric(
                                              horizontal: 1.0),
                                          color: Colors.green,
                                          height: 8,
                                          width: 8,
                                        ),
                                        SizedBox(
                                          width: 5.0,
                                        ),
                                        Text('Present'),
                                      ],
                                    ),
                                  ),
                                  Expanded(
                                    child: Row(
                                      children: <Widget>[
                                        Container(
                                          margin: EdgeInsets.symmetric(
                                              horizontal: 1.0),
                                          color: Colors.red,
                                          height: 8,
                                          width: 8,
                                        ),
                                        SizedBox(
                                          width: 5.0,
                                        ),
                                        Text('Absent'),
                                      ],
                                    ),
                                  ),
                                  Expanded(
                                    child: Row(
                                      children: <Widget>[
                                        Container(
                                          margin: EdgeInsets.symmetric(
                                              horizontal: 1.0),
                                          color: Colors.indigo,
                                          height: 8,
                                          width: 8,
                                        ),
                                        SizedBox(
                                          width: 5.0,
                                        ),
                                        Text('On Leave'),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                              Row(
                                children: <Widget>[
                                  SizedBox(
                                    width: 10.0,
                                  ),
                                  Expanded(
                                    child: Row(
                                      children: <Widget>[
                                        Container(
                                          margin: EdgeInsets.symmetric(
                                              horizontal: 1.0),
                                          color: Colors.yellow,
                                          height: 8,
                                          width: 8,
                                        ),
                                        SizedBox(
                                          width: 5.0,
                                        ),
                                        Text('Holiday'),
                                      ],
                                    ),
                                  ),
                                  Expanded(
                                    child: Row(
                                      children: <Widget>[
                                        Container(
                                          margin: EdgeInsets.symmetric(
                                              horizontal: 1.0),
                                          color: Colors.blueGrey,
                                          height: 8,
                                          width: 8,
                                        ),
                                        SizedBox(
                                          width: 5.0,
                                        ),
                                        Text('Weekoff'),
                                      ],
                                    ),
                                  ),
                                  Expanded(
                                    child: Row(
                                      children: <Widget>[
                                        Container(
                                          margin: EdgeInsets.symmetric(
                                              horizontal: 1.0),
                                          color: Colors.lightGreen,
                                          height: 8,
                                          width: 8,
                                        ),
                                        SizedBox(
                                          width: 5.0,
                                        ),
                                        Text('Half day'),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            )
          ],
        ));
  }

  Widget buildListView() {
    return ListView.builder(
        itemCount: _employeeListApiCallBack!.data!.length,
        itemBuilder: (BuildContext context, int index) {
          return Padding(
            padding: EdgeInsets.only(
                left: ScreenUtil().setSp(8),
                right: ScreenUtil().setSp(8),
                bottom: ScreenUtil().setSp(2)),
            child: InkWell(
              child: Card(
                color: getColorCode(
                    _employeeListApiCallBack!.data![index].attendance!),
                elevation: 5,
                child: Row(
                  children: <Widget>[
                    Container(
                      child: Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Text(
                          _employeeListApiCallBack!.data![index].attendance!,
                          style: singleLabel,
                        ),
                      ),
                    ),
                    Expanded(
                      child: Container(
                        color: Colors.white,
                        child: Padding(
                          padding: EdgeInsets.all(ScreenUtil().setSp(8)),
                          child: Column(
                            children: <Widget>[
                              Row(
                                children: <Widget>[
//                      Icon(Icons.person, color: Colors.deepOrange,size: ScreenUtil().setSp(15)),
                                  Expanded(
                                    child: Text(
                                      '${_employeeListApiCallBack!.data![index].firstName} ${_employeeListApiCallBack!.data![index].lastName}',
                                      style: titleStyle,
                                      maxLines: 2,
                                    ),
                                  ),
//                                  Expanded(
//                                    child: Container(),
//                                  ),
                                  Icon(Icons.playlist_add_check,
                                      color: appPrimaryColor,
                                      size: ScreenUtil().setSp(25)),
                                  SizedBox(
                                    width: ScreenUtil().setSp(8),
                                  ),
                                  Text(
                                      '${_employeeListApiCallBack!.data![index].taskApprovedCount} / ${_employeeListApiCallBack!.data![index].taskCount}')
                                ],
                              ),
                              Row(
                                children: <Widget>[
                                  Text(getInOutTime(
                                      _employeeListApiCallBack!.data![index])),
                                  Expanded(
                                    child: Container(),
                                  ),
                                  (_employeeListApiCallBack!
                                              .data![index].minutes !=
                                          '')
                                      ? Icon(Icons.watch_later,
                                          color: appPrimaryColor,
                                          size: ScreenUtil().setSp(18))
                                      : Container(),
                                  SizedBox(
                                    width: ScreenUtil().setSp(8),
                                  ),
                                  (_employeeListApiCallBack!
                                              .data![index].minutes !=
                                          '')
                                      ? Text(
                                          '${_employeeListApiCallBack!.data![index].minutes} mins')
                                      : Container()
                                ],
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              onTap: () {
                print('DATE ${selectedDate}');
                String name =
                    ('${_employeeListApiCallBack!.data![index].firstName} ${_employeeListApiCallBack!.data![index].middleName} ${_employeeListApiCallBack!.data![index].lastName}');
                Navigator.of(context).push(new MaterialPageRoute(
                    builder: (BuildContext context) => new ApproveTask(
                          scaffoldKey: widget.scaffoldKey,
                          title: 'Team Task',
                          id: _employeeListApiCallBack!.data![index].id!,
                          name: name,
                          date: selectedDate ?? "",
                        )));
              },
            ),
          );
        });
  }

  ///API call
  Future apiCallForTeamMembers() async {
    final SharedPreferences prefs = await _prefs;
    if (prefs.getBool(SP_IS_LOGIN_BOOL) != null) {
      companyId = prefs.getInt(SP_COMPANY_ID)!;
      teamLeadId = prefs.getInt(SP_ID)!;
      _apiToken = prefs.getString(SP_API_TOKEN)!;
    }
    var map = new Map<String, dynamic>();
    map["appType"] = Platform.operatingSystem.toUpperCase();
    map["companyId"] = companyId.toString();
    map["api_token"] = _apiToken;
    map["teamLeadId"] = teamLeadId.toString();
    map['taskDate'] = selectedDate;
    print('-----');
    print(map);
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

  Color getColorCode(String attendance) {
    switch (attendance) {
      case 'P':
        return Colors.green;
      case 'H':
        return Colors.yellow;
      case 'L':
        return Colors.indigo;
      case 'W':
        return Colors.blueGrey;
      case 'A':
        return Colors.red;
      case 'S':
        return Colors.lightGreen;
    }
    return Colors.green;
  }

  String getInOutTime(Data data) {
    String inTime = '';
    String outTime = '';
    inTime = (data.inTime != '')
        ? '${DateFormat('hh:mm a').format(DateFormat("yyyy-MM-dd HH:mm:ss").parse(data.inTime!,true).toLocal())}'
        : '';
    outTime = (data.outTime != '')
        ? '${DateFormat('hh:mm a').format(DateFormat("yyyy-MM-dd HH:mm:ss").parse(data.outTime!, true).toLocal())}'
        : '';

    return '$inTime  $outTime';
  }
}
