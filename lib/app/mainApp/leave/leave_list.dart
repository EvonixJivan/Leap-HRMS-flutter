import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:hrms/app/mainApp/leave/add_leave_request.dart';
import 'package:hrms/app/mainApp/task_manager/team_lead/approve_task.dart';
import 'package:hrms/app/uiComponent/custom_header.dart';
import 'package:hrms/appUtil/app_util_config.dart';
import 'package:hrms/appUtil/network_util.dart';
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';

class LeaveList extends StatefulWidget {
  var scaffoldKey;
  var title;

  LeaveList({Key? key, required this.scaffoldKey, required this.title})
      : super(key: key);

  @override
  _LeaveListState createState() {
    return _LeaveListState();
  }
}

class _LeaveListState extends State<LeaveList> {
  NetworkUtil _networkUtil = NetworkUtil();
  Future<SharedPreferences> _prefs = SharedPreferences.getInstance();
  UserLeaveCallBack? _userLeaveCallBack;
  EmployeeListApiCallBack ?_employeeListApiCallBack;
  ChangeLeaveStatusApiCallBack? _changeLeaveStatusApiCallBack;
 String? apiToken, today;
 String? _teamDropdownValue, _id, lead;
 late int userId, companyId, teamLeadId, role;
  List<DateTime> days = [];
  //List<String> items = ['Item 1', 'Item 2', 'Item 3'];
  List<DateTime> isChecked = [];

  var startDate = new DateFormat('yyyy-MM-dd')
      .format(DateTime.now().subtract(Duration(days: 7)));
  var endDate = new DateFormat('yyyy-MM-dd').format(DateTime.now());
  var _fromDate = '';
  var _toDate = '';
  bool isVisibleStatusBtn = false,
      isVisibleDropDown = false,
      isVisibleCount = false,
      isVisibleEditLeave = false;
  String _noDataFound = 'Loading...', _avialableLeaves = '00';
  TotalLeaveCountApiCallBack? _totalLeaveCountApiCallBack;

  @override
  void initState() {
    super.initState();
    getSpData();
    today = new DateFormat('yyyy/MM/dd').format(DateTime.now());
    // apiCallForTeamMembers();
  }

  @override
  void dispose() {
    super.dispose();
  }

  Future getSpData() async {
    final SharedPreferences prefs = await _prefs;
    if (prefs.getBool(SP_IS_LOGIN_BOOL) != null) {
       userId = prefs.getInt(SP_ID)!;
      role = prefs.getInt(SP_ROLE)!;
      companyId = prefs.getInt(SP_COMPANY_ID)!;
    }
    if (role == 4 || role == 2) {
      _id = userId.toString();
      lead = _id;
      isVisibleStatusBtn = false;
      isVisibleDropDown = true;
      if (companyId == 120) {
        isVisibleEditLeave = true;
      }
      apiCallForTeamMembers();
      _id = _teamDropdownValue;
        } else {
      _id = userId.toString();
      isVisibleStatusBtn = false;
      isVisibleDropDown = false;
      isVisibleEditLeave = false;
    }

    apiCallForGetLeave('All', _id ?? "");
    apiCallForAvailableLeave(_id ?? "");
  }

  Future apiCallForGetLeave(String status, String user) async {
    final SharedPreferences prefs = await _prefs;
    if (prefs.getBool(SP_IS_LOGIN_BOOL) != null) {
       userId = prefs.getInt(SP_ID)!;
      apiToken = prefs.getString(SP_API_TOKEN)!;
    }
    var map = new Map<String, dynamic>();
    map["appType"] = Platform.operatingSystem.toUpperCase();
    map["id"] = user;
    map["api_token"] = apiToken;
    map['flag'] = status;
    if (_fromDate.isEmpty) {
      map['startDate'] = startDate;
    } else {
      map['startDate'] = _fromDate;
    }
    if (_toDate.isEmpty) {
      map['endDate'] = endDate;
    } else {
      map['endDate'] = _toDate;
    }
    print(map.toString());
    try {
      print(map.toString());
      _noDataFound = 'Loading...';
      _networkUtil.post(apiUserLeave, body: map).then((dynamic res) {
        _noDataFound = noDataFound;
        try {
          AppLog.showLog(res.toString());
          _userLeaveCallBack = UserLeaveCallBack.fromJson(res);
          if (_userLeaveCallBack!.status == unAuthorised) {
            logout(context);
          } else if (!_userLeaveCallBack!.success!) {
            showBottomToast(_userLeaveCallBack!.message ?? "");
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

  Future apiCallForTeamMembers() async {
    final SharedPreferences prefs = await _prefs;
    if (prefs.getBool(SP_IS_LOGIN_BOOL) != null) {
       userId = prefs.getInt(SP_ID)!;
      companyId = prefs.getInt(SP_COMPANY_ID)!;
      teamLeadId = prefs.getInt(SP_ID)!;
      apiToken = prefs.getString(SP_API_TOKEN)!;
    }
    int _role = prefs.getInt(SP_ROLE)!;
    var map = new Map<String, dynamic>();
    map["api_token"] = apiToken;
    map["appType"] = Platform.operatingSystem.toUpperCase();
    map["userId"] = userId.toString();
    map["companyId"] = companyId.toString();
    map["roleId"] = _role.toString();
    map["teamLeadId"] = teamLeadId.toString();
    map['taskDate'] = today;
    print('PARAMS FOr Employeelist $map');
    try {
      _noDataFound = 'Loading...';
      _networkUtil
          .post(apigetEmployeelistWithTeamLead, body: map)
          .then((dynamic res) {
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

  ///Api pending need to change parameters as per api
  Future apiCallForChangeLeaveStatus(
      int leaveId, String _status, String _remark, List<DateTime> dates) async {
    final SharedPreferences prefs = await _prefs;
    var map = new Map<String, dynamic>();
    String _apiToken = prefs.getString(SP_API_TOKEN)!;
    int _userId = prefs.getInt(SP_ID)!;
    map['userId'] = _userId.toString();
    map["appType"] = Platform.operatingSystem.toUpperCase();
    map["api_token"] = _apiToken;
    map["leaveId"] = leaveId;
    map["approvalStatus"] = _status;
    map["remark"] = _remark;
    map["approveLeaveByTL"] = _status;
    map['approvedDates'] = dates;

    showLoader(context);

    print(map);
    try {
      _noDataFound = 'Loading...';
      _networkUtil.post(apiLeaveUpdate, body: map).then((dynamic res) {
        _noDataFound = noDataFound;

        try {
          Navigator.pop(context);
          AppLog.showLog(res.toString());
          //_changeLeaveStatusApiCallBack =
          //    ChangeLeaveStatusApiCallBack.fromJson(res);
          //  if (_changeLeaveStatusApiCallBack!.status == unAuthorised) {
          //    logout(context);
          //   }
          //  if (!_changeLeaveStatusApiCallBack!.success) {
          //    showBottomToast(_changeLeaveStatusApiCallBack!.message);
          //  }
        } catch (es) {
          showErrorLog(es.toString());
          showCenterToast(errorApiCall);
        }
        setState(() {});
        Navigator.of(context).pop();
        apiCallForGetLeave('All', _teamDropdownValue ?? "");
      });
    } catch (e) {
      showErrorLog(e.toString());
      showCenterToast(errorApiCall);
      _noDataFound = noDataFound;
      setState(() {});
    }
  }

  @override
  void screenUpdate() {
    setState(() {});
  }

  Future _buttonTapped() async {
    Map results = await Navigator.of(context).push(new MaterialPageRoute(
      builder: (BuildContext context) {
        return AddLeave(
          scaffoldKey: widget.scaffoldKey,
          title: 'Add Leave',
          toDate: null,
          approvalStatus: 0,
          formDate: null,
          id: 0,
          leaveType: null,
          noDays: null,
          reason: null,
          remark: null, sandwich_flag: 0,
        );
      },
    ));

    if (results.containsKey('reload')) {
      apiCallForGetLeave('All', userId.toString());
    }
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
              color: Colors.white,
              border: Border.all(width: 1, color: Colors.grey),
              borderRadius: BorderRadius.circular(5),
            ),
            child: (_employeeListApiCallBack?.data!.isNotEmpty ?? false)
                ? DropdownButtonHideUnderline(
                    child: DropdownButton(
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
                          // if (_teamDropdownValue == lead) {
                          //   isVisibleStatusBtn = false;
                          // } else {
                          //   isVisibleStatusBtn = true;
                          // }
                          apiCallForGetLeave('All', _teamDropdownValue ?? "");
                          apiCallForAvailableLeave(_teamDropdownValue ?? "");
                        });
                      },
                      isExpanded: true,
                      value: _teamDropdownValue,
                    ),
                  )
                : DropdownButtonHideUnderline(
                    child: DropdownButton<String>(
          hint: Text('Select Leave Type'),
          items: [],
          onChanged: (String? newValue) {},
          isExpanded: true,
          value: _teamDropdownValue,
        )
                  )));

    return Scaffold(
      backgroundColor: appBackground,
      body: Stack(
        children: <Widget>[
          // getCustomHeader(),
          CustomHeader(scaffoldKey: widget.scaffoldKey, title: widget.title),

          Container(
              margin: EdgeInsets.only(
                  top: ScreenUtil().setSp(90),
                  left: ScreenUtil().setSp(10),
                  right: ScreenUtil().setSp(10)),
              child: Column(
                children: <Widget>[
                  Visibility(visible: isVisibleDropDown, child: teamMember),
                  SizedBox(
                    height: 20,
                  ),
                  Visibility(
                    visible: isVisibleCount,
                    child: Container(
                      child: (_totalLeaveCountApiCallBack?.items!.isNotEmpty ?? false)//(_totalLeaveCountApiCallBack!.items.length > 0)
                          ? _loadLeaveCountList()
                          : Container(),
                      height: 80.0,
                    ),
                  ),
               Row(
  mainAxisAlignment: MainAxisAlignment.spaceBetween,
  children: [
    _buildLeaveButton(
      label: 'Approved',
      icon: Icons.thumb_up,
      color: Colors.green,
      onTap: () {
        apiCallForGetLeave('Approved', _id ?? "");
        apiCallForAvailableLeave(_id ?? "");
      },
    ),
    SizedBox(width: 5,),
    _buildLeaveButton(
      label: 'Pending',
      icon: Icons.info,
      color: Colors.grey,
      onTap: () {
        apiCallForGetLeave('Pending', _id ?? "");
        apiCallForAvailableLeave(_id ?? "");
      },
    ),
     SizedBox(width: 5,),
    _buildLeaveButton(
      label: 'Rejected',
      icon: Icons.close,
      color: Colors.red,
      onTap: () {
        apiCallForGetLeave('Disapproved', _id ?? "");
        apiCallForAvailableLeave(_id ?? "");
      },
    ),
  ],
),

                  // SizedBox(
                  //   height: 30,
                  // ),
                  Expanded(
                    child: (_userLeaveCallBack?.items?.isNotEmpty ?? false)
                        ? getLeaveListView()
                        : Container(
                            child: Center(
                              child: Text(
                                _noDataFound,
                              ),
                            ),
                          ),
                  ),
                ],
              ))
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          _buttonTapped();
        },
        child: Icon(Icons.add, color: Colors.white,),
        backgroundColor: colorTextDarkBlue,
      ),
    );
  }
Widget _buildLeaveButton({
  required String label,
  required IconData icon,
  required Color color,
  required VoidCallback onTap,
}) {
  return Expanded(
    child: ElevatedButton(
      style: ElevatedButton.styleFrom(
        backgroundColor: Colors.white,
        padding: EdgeInsets.symmetric(horizontal:5),
        shape: RoundedRectangleBorder(
          side: BorderSide(color: Colors.green, width: 2),
          borderRadius: BorderRadius.circular(10),
        ),
      ),
      onPressed: onTap,
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, color: color, size: ScreenUtil().setSp(18)),
          SizedBox(width: 4),
          Text(
            label,
            style: TextStyle(
              fontSize: ScreenUtil().setSp(12),
              fontWeight: FontWeight.w600,
              color: color,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    ),
  );
}

  Widget getLeaveListView() {
    return ListView.builder(
      shrinkWrap: true,
      itemBuilder: (BuildContext context, int index) {
        return Card(
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(8.0)),
          elevation: 5,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: <Widget>[
              Container(
                  height: 30,
                  decoration: new BoxDecoration(
                      color: appPrimaryColor,
                      borderRadius: new BorderRadius.only(
                          topLeft: Radius.circular(10),
                          topRight: Radius.circular(10))),
                  padding: EdgeInsets.all(4),
                  child: Center(
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          '${_userLeaveCallBack!.items![index].leaveType} - ${_userLeaveCallBack!.items![index].noDays} days',
                          textAlign: TextAlign.left,
                          style: TextStyle(
                              fontSize: ScreenUtil().setSp(15),
                              fontWeight: FontWeight.bold,
                              color: Colors.white),
                        ),
                        Expanded(child: Text('')),
                        SizedBox(
                          child: Visibility(
                            visible: isVisibleEditLeave,
                            child: IconButton(
                              padding: EdgeInsets.all(0),
                              icon: const Icon(
                                Icons.remove_red_eye,
                              ),
                              color: Colors.white,
                              onPressed: () async {
                                Map results = await Navigator.of(context)
                                    .push(new MaterialPageRoute(
                                  builder: (BuildContext context) {
                                    return AddLeave(
                                      scaffoldKey: widget.scaffoldKey,
                                      title: 'Edit Leave',
                                      leaveType: _userLeaveCallBack!
                                          .items![index].leaveType,
                                      formDate: _userLeaveCallBack!
                                          .items![index].fromDate,
                                      toDate: _userLeaveCallBack!
                                          .items![index].toDate,
                                      reason: _userLeaveCallBack!
                                          .items![index].reason,
                                      remark: _userLeaveCallBack!
                                          .items![index].remark,
                                      noDays: _userLeaveCallBack!
                                          .items![index].noDays,
                                      approvalStatus: _userLeaveCallBack!
                                          .items![index].approvalStatus!,
                                      id: _userLeaveCallBack!.items![index].id!,
                                      sandwich_flag: _userLeaveCallBack!
                                          .items![index].sandwich_flag!,
                                    );
                                  },
                                )).then((value) => apiCallForGetLeave(
                                        'All', _teamDropdownValue ?? "") as dynamic);
                              },
                            ),
                          ),
                        ),
                        SizedBox(
                          width: 0.0,
                        )
                      ],
                    ),
                  )),
              Container(
                  decoration: new BoxDecoration(
                      borderRadius: new BorderRadius.only(
                          bottomLeft: Radius.circular(10),
                          bottomRight: Radius.circular(10))),
                  padding: EdgeInsets.all(10),
                  child: Row(
                    children: <Widget>[
                      Expanded(
                        flex: 4,
                        child: Column(
                          children: <Widget>[
                            Row(
                              children: <Widget>[
                                Text('From Date :',
                                    style: TextStyle(
                                        fontWeight: FontWeight.bold,
                                        fontFamily: font,
                                        color: colorTextDarkBlue)),
                                SizedBox(
                                  width: ScreenUtil().setSp(5),
                                ),
                                Text(
                                    DateFormat('dd MMM yyyy').format(
                                        DateTime.parse(_userLeaveCallBack!
                                            .items![index].fromDate ?? "")),
                                    style: TextStyle(
                                      fontFamily: font,
                                    )),
                              ],
                            ),
                            SizedBox(
                              height: ScreenUtil().setSp(5),
                            ),
                            Row(
                              children: <Widget>[
                                Text('To Date      :',
                                    style: TextStyle(
                                        fontWeight: FontWeight.bold,
                                        fontFamily: font,
                                        color: colorTextDarkBlue)),
                                SizedBox(
                                  width: ScreenUtil().setSp(5),
                                ),
                                Text(
                                    DateFormat('dd MMM yyyy').format(
                                        DateTime.parse(_userLeaveCallBack!
                                            .items![index].toDate ?? "")),
                                    style: TextStyle(
                                      fontFamily: font,
                                    )),
                              ],
                            ),
                            SizedBox(
                              height: ScreenUtil().setSp(5),
                            ),
                            Row(
                              children: <Widget>[
                                Text('Reason      :',
                                    style: TextStyle(
                                        fontWeight: FontWeight.bold,
                                        fontFamily: font,
                                        color: colorTextDarkBlue)),
                                SizedBox(
                                  width: ScreenUtil().setSp(5),
                                ),
                                Flexible(
                                  child: Text(
                                      _userLeaveCallBack!.items![index].reason ?? "",
                                      maxLines: 2,
                                      overflow: TextOverflow.ellipsis,
                                      style: TextStyle(
                                        fontFamily: font,
                                      )),
                                ),
                              ],
                            ),
                            SizedBox(
                              height: ScreenUtil().setSp(5),
                            ),
                            Row(
                              children: <Widget>[
                                Text('Remark     :',
                                    style: TextStyle(
                                        fontWeight: FontWeight.bold,
                                        fontFamily: font,
                                        color: colorTextDarkBlue)),
                                SizedBox(
                                  width: ScreenUtil().setSp(5),
                                ),
                                Text(
                                    (_userLeaveCallBack!.items![index].remark !=
                                            null)
                                        ? _userLeaveCallBack!.items![index].remark ?? ""
                                        : ' - ',
                                    style: TextStyle(
                                      fontFamily: font,
                                    )),
                              ],
                            ),
                            SizedBox(
                              height: ScreenUtil().setSp(5),
                            ),
                            Visibility(
                              visible: companyId == 120,
                              child: Row(
                                children: <Widget>[
                                  Text('Sandwich Leave :',
                                      style: TextStyle(
                                          fontWeight: FontWeight.bold,
                                          fontFamily: font,
                                          color: colorTextDarkBlue)),
                                  SizedBox(
                                    width: ScreenUtil().setSp(5),
                                  ),
                                  if (_userLeaveCallBack!
                                          .items![index].sandwich_flag ==
                                      1)
                                    Text('Yes')
                                  else
                                    Text('No')
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                      Expanded(
                        flex: 1,
                        child: Container(
                          child: Column(
                            children: <Widget>[
                              (_userLeaveCallBack!.items![index].approvalStatus ==
                                      0)
                                  ? Icon(
                                      Icons.info,
                                      color: colorTextDarkBlue,
                                      size: 30,
                                    )
                                  : (_userLeaveCallBack!
                                              .items![index].approvalStatus ==
                                          1)
                                      ? Icon(
                                          Icons.thumb_up,
                                          color:
                                              appPrimaryColor, //appColorFour,
                                          size: 30,
                                        )
                                      : Icon(
                                          Icons.close,
                                          color: appPrimaryColor, // Colors.red,
                                          size: 30,
                                        ),
                              Visibility(
                                  visible: isVisibleStatusBtn,
                                  child: Container(
                                    decoration: BoxDecoration(
                                        borderRadius: BorderRadius.all(
                                            Radius.circular(10))),
                                    padding: EdgeInsets.only(
                                        top: 2, bottom: 2, left: 10, right: 10),
                                    child: (_userLeaveCallBack!.items![index]
                                                    .approvalStatus ==
                                                0 ||
                                            _userLeaveCallBack!.items![index]
                                                    .approvalStatus ==
                                                2)
                                        ? ElevatedButton(
                                            style: ElevatedButton.styleFrom(
                                                backgroundColor:
                                                    Colors.deepOrange),
                                            child: Text(
                                              'Approve',
                                              style: TextStyle(
                                                  color: Colors.white,
                                                  fontSize: 13.0,
                                                  fontWeight: FontWeight.bold),
                                            ),
                                            onPressed: () {
                                              getDaysInBeteween(
                                                  _userLeaveCallBack!
                                                      .items![index].fromDate ?? "",
                                                  _userLeaveCallBack!
                                                      .items![index].toDate ?? "");
                                              popDialog(index);
                                            },
                                          )
                                        : ElevatedButton(
                                            style: ElevatedButton.styleFrom(
                                                backgroundColor:
                                                    Colors.deepOrange),
                                            child: Text(
                                              'Reject',
                                              style: TextStyle(
                                                  color: Colors.white,
                                                  fontSize: 13.0,
                                                  fontWeight: FontWeight.bold),
                                            ),
                                            onPressed: () {
                                              popDialog(index);
                                            },
                                          ),
                                  )),
                            ],
                          ),
                        ),
                      )
                    ],
                  )),
            ],
          ),
        );
      },
      itemCount: _userLeaveCallBack!.items!.length,
    );
  }

  Future popDialog(int index) {
    String _remark = '-';
    final myController = TextEditingController();
    return showDialog(
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
                        child: Row(
                          children: <Widget>[
                            Expanded(
                              child: Text(
                                'Approve',
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                    fontSize: ScreenUtil().setSp(16),
                                    fontWeight: FontWeight.bold,
                                    color: appWhiteColor),
                              ),
                            ),
                            GestureDetector(
                              child: Icon(
                                Icons.close,
                                color: Colors.white,
                                size: 20,
                              ),
                              onTap: () {
                                Navigator.pop(context);
                              },
                            ),
                          ],
                        )),
                    Padding(
                      padding: EdgeInsets.only(
                          left: ScreenUtil().setSp(20),
                          top: ScreenUtil().setSp(20),
                          right: ScreenUtil().setSp(20)),
                      child: Text('Do you want to approve the Leave?'),
                    ),
                    ListView(
                      shrinkWrap: true,
                      children: <Widget>[
                        ...days
                            .map(
                              (item) => CheckboxListTile(
                                title: Text(DateFormat('dd MMM yyyy')
                                    .format(DateTime.parse(item.toString()))),
                                value: isChecked.contains(item),
                                onChanged: (bool? value) {
                                  if (value ?? false) {
                                    setState(() {
                                      isChecked.add(item);
                                    });
                                  } else {
                                    setState(() {
                                      isChecked.remove(item);
                                    });
                                  }
                                  print('SELECTED: $isChecked');
                                },
                              ),
                            )
                            .toList()
                      ],
                    ),
                    Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Container(
                        decoration: BoxDecoration(
                          color: Colors.grey[100],
                          border: Border.all(width: 1, color: Colors.grey),
                          borderRadius: BorderRadius.circular(3),
                        ),
                        child: TextFormField(
                          controller: myController,
                          minLines: 1,
                          maxLines: 2,
                          keyboardType: TextInputType.text,
                          decoration: InputDecoration(
                              border: InputBorder.none,
                              hintText: 'Remark',
                              prefixIcon: Icon(
                                Icons.rate_review,
                                color: Colors.grey,
                              )),
                          onSaved: (String? value) {
                            _remark = value!;
                            print(value);
                          },
                        ),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Row(
                        children: <Widget>[
                          Expanded(
                            child: ElevatedButton(
                              style: ElevatedButton.styleFrom(
                                  elevation: 5, backgroundColor: Colors.red),
                              child: Text(
                                'Reject',
                                style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 13.0,
                                    fontWeight: FontWeight.bold),
                              ),
                              onPressed: () {
                                if (myController.text != '') {
                                  apiCallForChangeLeaveStatus(
                                      _userLeaveCallBack!.items![index].id!,
                                      '2',
                                      myController.text,
                                      isChecked);
                                } else {
                                  showCenterToast('Remark is mandatory');
                                }
                              },
                            ),
                          ),
                          SizedBox(
                            width: 15.0,
                          ),
                          Expanded(
                            child: ElevatedButton(
                              style: ElevatedButton.styleFrom(
                                  elevation: 5, backgroundColor: Colors.green),
                              child: Text(
                                'Approve',
                                style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 13.0,
                                    fontWeight: FontWeight.bold),
                              ),
                              onPressed: () {
                                apiCallForChangeLeaveStatus(
                                    _userLeaveCallBack!.items![index].id!,
                                    '1',
                                    myController.text,
                                    isChecked);
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
  }

  Widget getCustomHeader() {
    return PreferredSize(
      preferredSize: Size(MediaQuery.of(context).size.width, 250),
      child: Container(
        width: MediaQuery.of(context).size.width,
        height: 120,
        child: ClipRRect(
          borderRadius: BorderRadius.only(
            bottomLeft: Radius.circular(50),
          ),
          child: Container(
            color: appColorFour,
            child: Column(
              children: <Widget>[
                Container(
                  margin: EdgeInsets.fromLTRB(10, 50, 10, 0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      GestureDetector(
                        child: Icon(
                          Icons.subject,
                          size: 30,
                          color: Colors.white,
                        ),
                        onTap: () {
                          print('click ');
                          if (widget.scaffoldKey.currentState.isDrawerOpen) {
                            widget.scaffoldKey.currentState.openEndDrawer();
                          } else {
                            widget.scaffoldKey.currentState.openDrawer();
                          }
                        },
                      ),
                      Text(
                        widget.title,
                        style: TextStyle(
                            fontSize: ScreenUtil().setSp(22),
                            color: Colors.white),
                      ),
                      GestureDetector(
                        child: Icon(
                          Icons.assistant_photo,
                          size: ScreenUtil().setSp(30),
                          color: appColorFour,
                        ),
                        onTap: () {},
                      ),
                    ],
                  ),
                ),
                SizedBox(
                  height: 20.0,
                )
              ],
            ),
          ),
        ),
      ),
    );
  }

  Future _selectFromDateLeave() async {
    DateTime? _picked = await showDatePicker(
        context: context,
        initialDate: new DateTime.now(),
        firstDate: new DateTime(2016),
        lastDate: new DateTime(2025));
    setState(() {
      _fromDate = new DateFormat('yyyy-MM-dd').format(_picked!);
    });
  }

  Future _selectToDateLeave() async {
    DateTime? _picked = await showDatePicker(
        context: context,
        initialDate: new DateTime.now(),
        firstDate: new DateTime(2016),
        lastDate: new DateTime(2025));
    setState(() {
      _toDate = new DateFormat('yyyy-MM-dd').format(_picked!);
    });
  }

  Future apiCallForAvailableLeave(String user) async {
    final SharedPreferences prefs = await _prefs;
    if (prefs.getBool(SP_IS_LOGIN_BOOL) != null) {
       userId = prefs.getInt(SP_ID)!;
      companyId = prefs.getInt(SP_COMPANY_ID)!;
      apiToken = prefs.getString(SP_API_TOKEN)!;
    }
    var map = new Map<String, dynamic>();
    map["appType"] = Platform.operatingSystem.toUpperCase();
    map["userId"] = user;
    //userId.toString();
    map["api_token"] = apiToken;
    map['leaveTypeId'] = '0'; //raghu
    print(map);
    try {
      showLoader(context);
      _networkUtil.post(getTotalLeaveCount, body: map).then((dynamic res) {
        Navigator.pop(context);
        try {
          AppLog.showLog(res.toString());
          _totalLeaveCountApiCallBack =
              TotalLeaveCountApiCallBack.fromJson(res);
          if (_totalLeaveCountApiCallBack!.success!) {
            _avialableLeaves = _totalLeaveCountApiCallBack!
                .items![0].available_count
                .toString()
                .padLeft(2, '0');
            setState(() {
              isVisibleCount = true;
            });
          }
        } catch (es) {
          // showErrorLog(es.toString());
          // showCenterToast(errorApiCall);
        }
        setState(() {});
      });
    } catch (e) {
      showErrorLog(e.toString());
      // showCenterToast(errorApiCall);
    }
  }

  void showLeaveCountDialog() {
    showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            contentPadding: EdgeInsets.all(0),
            shape: RoundedRectangleBorder(
                borderRadius:
                    BorderRadius.all(Radius.circular(ScreenUtil().setSp(10)))),
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
                        'Leave count.',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                            fontSize: ScreenUtil().setSp(16),
                            fontWeight: FontWeight.bold,
                            color: appWhiteColor),
                      )),
                  _loadLeaveCount(),
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
                        'Ok',
                        style: TextStyle(
                            color: appWhiteColor,
                            fontSize: ScreenUtil().setSp(15),
                            fontWeight: FontWeight.bold),
                      ),
                      onPressed: () {
                        setState(() {
                          Navigator.of(context).pop();
                        });
                      },
                    ),
                  ),
                ],
              ),
            ),
          );
          //  });
        });
  }

  _loadLeaveCount() {
    if (_totalLeaveCountApiCallBack!.items!.length > 0) {
      List<Widget> children = <Widget>[];
      for (int i = 0; i < _totalLeaveCountApiCallBack!.items!.length; i++) {
        children.add(Card(
          elevation: 10.0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(5.0),
          ),
          child: Padding(
            padding: const EdgeInsets.all(8.0),
            child: Column(
              children: <Widget>[
                Text(' ${_totalLeaveCountApiCallBack!.items![i].leaveType}',
                    style: TextStyle(
                      fontSize: 10.0,
                      fontWeight: FontWeight.bold,
                    )),
                Text('${_totalLeaveCountApiCallBack!.items![i].short_name}',
                    style: TextStyle(
                      color: appColorTwo,
                      fontSize: 20.0,
                      fontWeight: FontWeight.bold,
                    )),
                Text(
                    'Available ${_totalLeaveCountApiCallBack!.items![i].available_count} / ${_totalLeaveCountApiCallBack!.items![i].total_count}',
                    style: TextStyle(fontSize: 10.0)),
              ],
            ),
          ),
        ));
        children.add(SizedBox(width: 5.0));
      }

      return Card(
        shape: RoundedRectangleBorder(
          side: BorderSide(
              color: Colors.white, width: 2, style: BorderStyle.solid),
          borderRadius: new BorderRadius.circular(10.0),
        ),
        child: Container(
          width: MediaQuery.of(context).size.width - 20,
          child: Column(
            children: <Widget>[
              Center(
                child: Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Wrap(
                    children: children,
                  ),
                ),
              ),
              Center(
                child: Icon(
                  Icons.arrow_drop_down_circle,
                  color: Colors.grey,
                  size: ScreenUtil().setSp(30),
                ),
              )
            ],
          ),
        ),
      );
    }
    return Container();
  }

  _loadLeaveCountList() {
    if (_totalLeaveCountApiCallBack!.items!.length > 0) {
      return ListView.builder(
        scrollDirection: Axis.horizontal,
        shrinkWrap: true,
        itemBuilder: (BuildContext context, int index) {
          return Card(
            elevation: 10.0,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(5.0),
            ),
            child: Padding(
              padding: const EdgeInsets.all(8.0),
              child: Column(
                children: <Widget>[
                  // Text(' ${_totalLeaveCountApiCallBack.items[index].leaveType}',
                  //     style: TextStyle(
                  //       fontSize: 10.0,
                  //       fontWeight: FontWeight.bold,
                  //     )),
                  SizedBox(
                    height: 10,
                  ),
                  Text('${_totalLeaveCountApiCallBack!.items![index].leaveType}',
                      style: TextStyle(
                        color: appColorTwo,
                        fontSize: 20.0,
                        fontWeight: FontWeight.bold,
                      )),
                  Text(
                      'Available ' +
                          '${_totalLeaveCountApiCallBack!.items![index].available_count}' +
                          ' / ' +
                          '${_totalLeaveCountApiCallBack!.items![index].total_count}',
                      style: TextStyle(fontSize: 10.0)),
                ],
              ),
            ),
          );
        },
        itemCount: _totalLeaveCountApiCallBack!.items!.length,
      );
    }
    return Container();
  }

  // List<DateTime> getDaysInBeteween(DateTime startDate, DateTime endDate) {
  List<DateTime> getDaysInBeteween(String fromDate, String toDate) {
    days = [];
    DateTime startDate = DateTime.parse(fromDate);
    DateTime endDate = DateTime.parse(toDate);

    // List<DateTime> days = [];
    for (int i = 0; i <= endDate.difference(startDate).inDays; i++) {
      days.add(startDate.add(Duration(days: i)));
    }
    print('DAYS:$days');
    return days;
  }
}

class UserLeaveCallBack {
   int? totalCount;
  bool? success;
  List<Items>? items;
 String? message;
  int? status;

  UserLeaveCallBack(
      {required this.totalCount, required this.success, required this.items, required this.message, required this.status});

  UserLeaveCallBack.fromJson(Map<String, dynamic> json) {
    totalCount = json['total_count'];
    success = json['success'];
    if (json['items'] != null) {
     items = [];
      json['items'].forEach((v) {
        items!.add(new Items.fromJson(v));
      });
    }
    message = json['message'];
    status = json['status'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['total_count'] = this.totalCount;
    data['success'] = this.success;
    data['items'] = this.items!.map((v) => v.toJson()).toList();
      data['message'] = this.message;
    data['status'] = this.status;
    return data;
  }
}

class Items {
  int? id;
  int? userId;
 String? leaveType;
 String? reason;
 String? fromDate;
 String? toDate;
 String? noDays;
  int? approvalStatus;
 String? remark;
  int? approvedBy;
  int? isdeleted;
  int? status;
 String? createdAt;
 String? updatedAt;
 String? firstName;
 String? lastName;
  int? sandwich_flag;

  Items(
      {required this.id,
     required this.userId,
     required this.leaveType,
     required this.reason,
     required this.fromDate,
     required this.toDate,
     required this.noDays,
     required this.approvalStatus,
     required this.remark,
     required this.approvedBy,
     required this.isdeleted,
     required this.status,
     required this.createdAt,
     required this.updatedAt,
     required this.firstName,
     required this.lastName,
     required this.sandwich_flag});

  Items.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    userId = json['userId'];
    leaveType = json['leaveType'];
    reason = json["reason"] == null ? "" : json["reason"];
    // reason = json['reason'];
    fromDate = json['fromDate'];
    toDate = json['toDate'];
    noDays = '${json['noDays']}';
    approvalStatus = json['approvalStatus'];
    // remark = json['remark'];
    remark = json["remark"] == null ? "N.A." : json["remark"];
    approvedBy = json['approvedBy'];
    isdeleted = json['isdeleted'];
    status = json['status'];
    createdAt = json['created_at'];
    updatedAt = json['updated_at'];
    firstName = json['first_name'];
    lastName = json['last_name'];
    sandwich_flag = json['sandwich_flag'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['id'] = this.id;
    data['userId'] = this.userId;
    data['leaveType'] = this.leaveType;
    data['reason'] = this.reason;
    data['fromDate'] = this.fromDate;
    data['toDate'] = this.toDate;
    data['noDays'] = this.noDays;
    data['approvalStatus'] = this.approvalStatus;
    data['remark'] = this.remark;
    data['approvedBy'] = this.approvedBy;
    data['isdeleted'] = this.isdeleted;
    data['status'] = this.status;
    data['created_at'] = this.createdAt;
    data['updated_at'] = this.updatedAt;
    data['first_name'] = this.firstName;
    data['last_name'] = this.lastName;
    return data;
  }
}

class ChangeLeaveStatusApiCallBack {}
