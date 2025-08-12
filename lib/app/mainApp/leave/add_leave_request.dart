import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:hrms/app/uiComponent/custom_header.dart';
import 'package:hrms/appUtil/app_util_config.dart';
import 'package:hrms/appUtil/network_util.dart';
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';

enum SingingCharacter { Active, Deactive }

class AddLeave extends StatefulWidget {
  var scaffoldKey;
  var title;
  var leaveType;
  var formDate, toDate, reason, remark, noDays;
  int approvalStatus, id;
  int sandwich_flag = 0;
  AddLeave(
      {Key? key,
      required this.scaffoldKey,
      required this.title,
      required this.leaveType,
      required this.formDate,
      required this.toDate,
      required this.reason,
      required this.remark,
      required this.noDays,
      required this.approvalStatus,
      required this.id,
      required this.sandwich_flag})
      : super(key: key);

  @override
  _AddLeaveState createState() {
    return _AddLeaveState();
  }
}

class _AddLeaveState extends State<AddLeave> {
  NetworkUtil _networkUtil = NetworkUtil();
  Future<SharedPreferences> _prefs = SharedPreferences.getInstance();
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  LeaveTypeCallBack? leaveTypeCallBack;
  LeaveCallBack? addLeaveCallBack;
  TotalLeaveCountApiCallBack? _totalLeaveCountApiCallBack;
  String? _leaveTypeDropdownValue;
  String _numberOfDays = '0', _reasonForLeave = '', _remark = "";
  String apiToken = "", _avialableLeaves = '00';
  int? userId, companyId, bufferDays, selectedLeaveID;
  bool fromDateHalfDay = false,
      toDateHalfDay = false,
      isVisibleCount = false,
      sandwichISVisible = false,
      isEditActive = false;
  String selectedValue = "";
  SingingCharacter _character = SingingCharacter.Active;
  var _fromDate = 'From Date';
  var _toDate = 'To Date';
  String strHalfDay = '';
  var sandwichLeave, approveDate;
  var approvedStatusflg, sandwichflg = 0;
  int? radioApprovedStatus;
  TextEditingController txtRemark = TextEditingController();
  TextEditingController reasonRequired = TextEditingController();

  SingleLeaveCallBack? addSingleLeaveCallBack;

  @override
  void initState() {
    super.initState();
    apiCallForLeaveType();
    apiCallForAvailableLeave();
    txtRemark = TextEditingController(text: _remark);
    if (widget.title == "Edit Leave") {
      apiCallForSingleLeave();
      isEditActive = true;
      _fromDate = convertDateFormat(
          widget.formDate, "yyyy-MM-dd HH:mm:ss", "yyyy-MM-dd");
      _toDate =
          convertDateFormat(widget.toDate, "yyyy-MM-dd HH:mm:ss", "yyyy-MM-dd");
      _numberOfDays = widget.noDays;
      _reasonForLeave = widget.reason;
      print("g11..." + widget.approvalStatus.toString());
      radioApprovedStatus = widget.approvalStatus;
      sandwichflg = widget.sandwich_flag;
      approvedStatusflg = widget.approvalStatus;
      if (widget.remark != null && widget.remark != "null")
        txtRemark.text = widget.remark;
      else
        txtRemark.text = "";
      // if (widget.approvalStatus == "1") {
      //   sandwichISVisible = true;
      // } else {
      //   sandwichISVisible = false;
      // }
    } else
      isEditActive = false;
    selectedValue = 'Select Leave Type';
  }

  @override
  void dispose() {
    super.dispose();
  }

  static String convertDateFormat(
      String dateTimeString, String oldFormat, String newFormat) {
    DateFormat newDateFormat = DateFormat(newFormat);
    DateTime dateTime = DateFormat(oldFormat).parse(dateTimeString);
    String selectedDate = newDateFormat.format(dateTime);
    return selectedDate;
  }

  Future apiCallForLeaveType() async {
    final SharedPreferences prefs = await _prefs;
    if (prefs.getBool(SP_IS_LOGIN_BOOL) != null) {
      userId = prefs.getInt(SP_ID)!;
      companyId = prefs.getInt(SP_COMPANY_ID)!;
      apiToken = prefs.getString(SP_API_TOKEN)!;
    }
    var map = new Map<String, dynamic>();
    map["appType"] = Platform.operatingSystem.toUpperCase();
    map["userId"] = userId.toString();
    map["companyId"] = companyId.toString();
    map["api_token"] = apiToken;
    print(map);
    try {
      _networkUtil.post(apiLeaveTypeNew, body: map).then((dynamic res) {
        try {
          // AppLog.showLog(res.toString());
          leaveTypeCallBack = LeaveTypeCallBack.fromJson(res);
          if (leaveTypeCallBack!.status == unAuthorised) {
            logout(context);
          } else if (!leaveTypeCallBack!.success!) {
            showBottomToast(leaveTypeCallBack!.message ?? "");
          }
        } catch (es) {
          showErrorLog(es.toString());
          showCenterToast(errorApiCall);
        }
        setState(() {
          if (leaveTypeCallBack?.items!.isNotEmpty ?? false) {
            for (var model in leaveTypeCallBack!.items!) {
              String str = model.leaveType ?? "";
              if (str == widget.leaveType) {
                selectedValue = str;
                print('value matched $selectedValue');
                // _leaveTypeDropdownValue = model.id as String;
                // selectedLeaveID = model.id;
                break;
              }
            }
          }
        });
      });
    } catch (e) {
      showErrorLog(e.toString());
      showCenterToast(errorApiCall);
    }
  }

  Future apiCallForAvailableLeave() async {
    final SharedPreferences prefs = await _prefs;
    if (prefs.getBool(SP_IS_LOGIN_BOOL) != null) {
      userId = prefs.getInt(SP_ID)!;
      companyId = prefs.getInt(SP_COMPANY_ID)!;
      apiToken = prefs.getString(SP_API_TOKEN)!;
    }
    var map = new Map<String, dynamic>();
    map["appType"] = Platform.operatingSystem.toUpperCase();
    map["userId"] = userId.toString();
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
          showErrorLog(es.toString());
          // showCenterToast(errorApiCall);
        }
        setState(() {});
      });
    } catch (e) {
      showErrorLog(e.toString());
      // showCenterToast(errorApiCall);
    }
  }

  Future apiCallForAddLeave() async {
    if (_formKey.currentState!.validate()) {
      _formKey.currentState!.save();
      final SharedPreferences prefs = await _prefs;
      if (prefs.getBool(SP_IS_LOGIN_BOOL) != null) {
        userId = prefs.getInt(SP_ID)!;
        companyId = prefs.getInt(SP_COMPANY_ID)!;
        apiToken = prefs.getString(SP_API_TOKEN)!;
      }
      var map = new Map<String, dynamic>();

      map["appType"] = Platform.operatingSystem.toUpperCase();
      map["userId"] = userId.toString();
      map["api_token"] = apiToken;
      map["leaveType"] = selectedValue;
      map["reason"] = _reasonForLeave;
      map["fromDate"] = _fromDate;
      map["halfdayDates"] = strHalfDay;
      map["toDate"] = _toDate;
      map["noDays"] = _numberOfDays;
      map["approvalStatus"] = '0';
      map["remark"] = txtRemark.text.toString();
      map["description"] = '';

      print('LEAVES PARAM $map');
      try {
        showLoader(context);
        _networkUtil.post(apiAddLeave, body: map).then((dynamic res) {
          Navigator.pop(context);
          try {
            AppLog.showLog(res.toString());
            addLeaveCallBack = LeaveCallBack.fromJson(res);
            if (addLeaveCallBack!.status == unAuthorised) {
              logout(context);
            } else if (addLeaveCallBack!.success!) {
              showBottomToast(addLeaveCallBack!.message ?? "");
              Navigator.of(context).pop({'reload': true});
            } else {
              showBottomToast(addLeaveCallBack!.message ?? "");
            }
          } catch (es) {
            showErrorLog(es.toString());
            //showCenterToast(errorApiCall);
          }
          setState(() {});
        });
      } catch (e) {
        Navigator.pop(context);
        showErrorLog(e.toString());
        //showCenterToast(errorApiCall);
      }
    }
  }

  Future apiCallForSingleLeave() async {
    // if (_formKey.curre ntState.validate()) {
    //   _formKey.currentState.save();
    final SharedPreferences prefs = await _prefs;
    if (prefs.getBool(SP_IS_LOGIN_BOOL) != null) {
      userId = prefs.getInt(SP_ID)!;
      companyId = prefs.getInt(SP_COMPANY_ID)!;
      apiToken = prefs.getString(SP_API_TOKEN)!;
    }
    var map = new Map<String, dynamic>();

    map["appType"] = Platform.operatingSystem.toUpperCase();
    map["api_token"] = apiToken;
    map["id"] = widget.id.toString();

    print('LEAVES PARAM $map');
    try {
      showLoader(context);
      _networkUtil.post(apiSingleLeave, body: map).then((dynamic res) {
        Navigator.pop(context);
        try {
          AppLog.showLog(res.toString());
          addSingleLeaveCallBack = SingleLeaveCallBack.fromJson(res);
          if (addSingleLeaveCallBack!.status == unAuthorised) {
            logout(context);
          } else if (addSingleLeaveCallBack!.success!) {
            showBottomToast(addSingleLeaveCallBack!.message ?? "");
          } else {
            showBottomToast(addSingleLeaveCallBack!.message ?? "");
          }
        } catch (es) {
          showErrorLog(es.toString());
          //showCenterToast(errorApiCall);
        }
        setState(() {
          if (addSingleLeaveCallBack!.items!.holidaystatus == 1 ||
              addSingleLeaveCallBack!.items!.pholidaystatus == 1 ||
              addSingleLeaveCallBack!.items!.pstatus == 1 ||
              addSingleLeaveCallBack!.items!.dstatus == 1)
            sandwichISVisible = true;
          else
            sandwichISVisible = false;

          // if (addSingleLeaveCallBack.items.holidaystatus == 1) {
          //   sandwichISVisible = true;
          // } else if (addSingleLeaveCallBack.items.pholidaystatus == 1) {
          //   sandwichISVisible = true;
          // } else if (addSingleLeaveCallBack.items.pstatus == 1) {
          //   sandwichISVisible = true;
          // } else if (addSingleLeaveCallBack.items.dstatus == 1) {
          //   sandwichISVisible = true;
          // } else {
          //   sandwichISVisible = false;
          // }
        });
      });
    } catch (e) {
      Navigator.pop(context);
      showErrorLog(e.toString());
      //showCenterToast(errorApiCall);
    }
    // }
  }

  ///Api pending need to change parameters as per api
  Future apiCallForUpdatedLeave() async {
    final SharedPreferences prefs = await _prefs;
    var map = new Map<String, dynamic>();
    String _apiToken = prefs.getString(SP_API_TOKEN)!;
    int _userId = prefs.getInt(SP_ID)!;
    // map['userId'] = _userId.toString();
    map["appType"] = Platform.operatingSystem.toUpperCase();
    map["api_token"] = _apiToken;
    map["id"] = widget.id.toString();
    map['approvedDates'] = _fromDate.toString();
    map["approvalStatus"] = approvedStatusflg.toString();
    map["remark"] = txtRemark.text.toString();
    map["approvedBy"] = _userId.toString();
    map["sandwich_flag"] = sandwichflg.toString();
    map["isdeleted"] = "0";

    // 'approvedDates' = , 2022-02-01
    // 'approvalStatus' =1,
    // 'remark' = test,
    // 'approvedBy' = 1763,
    // 'sandwich_flag' = 1,
    // 'isdeleted' = 0,
    showLoader(context);

    print(map);
    try {
      // _noDataFound = 'Loading...';
      _networkUtil.post(apiLeaveUpdate, body: map).then((dynamic res) {
        // _noDataFound = noDataFound;

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
        Navigator.pop(context, true);
        // apiCallForGetLeave('All', _teamDropdownValue);
      });
    } catch (e) {
      showErrorLog(e.toString());
      showCenterToast(errorApiCall);
      // _noDataFound = noDataFound;
      setState(() {});
    }
  }

  @override
  Widget build(BuildContext context) {
    final leaveType = Padding(
        padding: EdgeInsets.only(
            left: ScreenUtil().setSp(10),
            top: ScreenUtil().setSp(10),
            right: ScreenUtil().setSp(10),
            bottom: ScreenUtil().setSp(10)),
        child: IgnorePointer(
          ignoring: isEditActive,
          child: Container(
              padding: EdgeInsets.only(left: ScreenUtil().setSp(10)),
              decoration: BoxDecoration(
                color: Colors.grey[100],
                border: Border.all(width: 1, color: Colors.grey),
                borderRadius: BorderRadius.circular(3),
              ),
              child: (leaveTypeCallBack?.items!.isNotEmpty ?? false)
                  ? DropdownButton(
                      hint: Text(selectedValue),
                      value: _leaveTypeDropdownValue,
                      onChanged: (newValue) {
                        setState(() {
                          selectedValue = newValue.toString();
                          _leaveTypeDropdownValue = newValue.toString();
//                        apiCallForAvailableLeave(newValue);
                        });
                      },
                      items: leaveTypeCallBack!.items!.map((dataItem) {
                        return DropdownMenuItem(
                          child: new Text(dataItem.leaveType ?? ""),
                          value: dataItem.id.toString(),
                        );
                      }).toList(),
                      isExpanded: true,
                    )
                  : DropdownButton<String>(
                      hint: Text('Select Leave Type'),
                      items: [],
                      onChanged: (String? newValue) {},
                      isExpanded: true,
                      value: _leaveTypeDropdownValue,
                    )),
        ));

    final fromDate = Padding(
        padding: EdgeInsets.only(
            left: ScreenUtil().setSp(10),
            top: ScreenUtil().setSp(10),
            right: ScreenUtil().setSp(10),
            bottom: ScreenUtil().setSp(10)),
        child: IgnorePointer(
          ignoring: isEditActive,
          child: Container(
            decoration: BoxDecoration(
              color: Colors.grey[100],
              border: Border.all(width: 1, color: Colors.grey),
              borderRadius: BorderRadius.circular(3),
            ),
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.grey[100], elevation: 0),
              child: Row(
                children: <Widget>[
                  Icon(
                    Icons.calendar_today,
                    color: Colors.grey,
                  ),
                  SizedBox(
                    width: ScreenUtil().setSp(5),
                  ),
                  Expanded(child: Text(_fromDate)),
                  (_fromDate == 'From Date')
                      ? Container()
                      : Container(
                          width: 180,
                          child: CheckboxListTile(
                            title: Text('Half Day'),
                            controlAffinity: ListTileControlAffinity.leading,
                            value: fromDateHalfDay,
                            onChanged: (bool? newValue) {
                              setState(() {
                                fromDateHalfDay = newValue!;
                                calculateNoOfDays();
                              });
                            },
                          ),
                        ),
                ],
              ),
              onPressed: () {
                _selectFromDate();
              },
            ),
          ),
        ));

    final toDate = Padding(
        padding: EdgeInsets.only(
            left: ScreenUtil().setSp(10),
            top: ScreenUtil().setSp(10),
            right: ScreenUtil().setSp(10),
            bottom: ScreenUtil().setSp(10)),
        child: IgnorePointer(
          ignoring: isEditActive,
          child: Container(
            decoration: BoxDecoration(
              color: Colors.grey[100],
              border: Border.all(width: 1, color: Colors.grey),
              borderRadius: BorderRadius.circular(3),
            ),
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.grey[100], elevation: 0),
              child: Row(
                children: <Widget>[
                  Icon(
                    Icons.calendar_today,
                    color: Colors.grey,
                  ),
                  SizedBox(
                    width: ScreenUtil().setSp(5),
                  ),
                  Expanded(child: Text(_toDate)),
                  (_numberOfDays == '01' || _toDate == 'To Date')
                      ? Container()
                      : Container(
                          width: 180,
                          child: CheckboxListTile(
                            title: Text('Half Day'),
                            controlAffinity: ListTileControlAffinity.leading,
                            value: toDateHalfDay,
                            onChanged: (bool? newValue) {
                              setState(() {
                                // toDateHalfDay = newValue;
                                // calculateNoOfDays();
                                if (_fromDate != _toDate) {
                                  //  toDateHalfDay =false;
                                  toDateHalfDay = newValue!;
                                  calculateNoOfDays();
                                }
                              });
                            },
                          ),
                        ),
                ],
              ),
              onPressed: () {
                _selectToDate();
              },
            ),
          ),
        ));

    var noOfDays = Padding(
      padding: EdgeInsets.only(
          left: ScreenUtil().setSp(12),
          top: ScreenUtil().setSp(10),
          right: ScreenUtil().setSp(10),
          bottom: ScreenUtil().setSp(10)),
      child: Container(
          decoration: BoxDecoration(
            color: Colors.grey[100],
            border: Border.all(width: 1, color: Colors.grey),
            borderRadius: BorderRadius.circular(3),
          ),
          child: Padding(
            padding: EdgeInsets.only(
                left: ScreenUtil().setSp(12),
                top: ScreenUtil().setSp(10),
                right: ScreenUtil().setSp(10),
                bottom: ScreenUtil().setSp(10)),
            child: Row(
              children: <Widget>[
                Icon(
                  Icons.calendar_today,
                  color: Colors.grey,
                ),
                SizedBox(
                  width: ScreenUtil().setSp(5),
                ),
                Text(_numberOfDays),
              ],
            ),
          )),
    );

    final reasonForLeave = Padding(
      padding: EdgeInsets.only(
          left: ScreenUtil().setSp(10),
          top: ScreenUtil().setSp(10),
          right: ScreenUtil().setSp(10),
          bottom: ScreenUtil().setSp(10)),
      child: IgnorePointer(
        ignoring: isEditActive,
        child: Container(
            decoration: BoxDecoration(
              color: Colors.grey[100],
              border: Border.all(width: 1, color: Colors.grey),
              borderRadius: BorderRadius.circular(3),
            ),
            child: TextFormField(
              controller: reasonRequired,
              maxLines: null,
              validator: (value) {
                if (value!.isEmpty) {
                  return 'Reason is required';
                }
                return null;
              },
              decoration: InputDecoration(
                  border: InputBorder.none,
                  hintText: 'Reason For Leave',
                  prefixIcon: Icon(
                    Icons.event_note,
                    color: Colors.grey,
                  )),
              onSaved: (String? value) {
                _reasonForLeave = value!;
                print(value);
              },
            )),
      ),
    );

    final submitButton = Row(
      children: <Widget>[
        SizedBox(
          width: ScreenUtil().setSp(30),
          height: 20,
        ),
        Expanded(
          child: ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: appPrimaryColor,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10.0)),
            ),
            onPressed: () {
              if (selectedValue.toString().contains("Select Leave Type")) {
                showBottomToast('Leave Type is required');
              } else if (isEditActive) {
                apiCallForUpdatedLeave();
              } else {
                if (_fromDate == 'From Date') {
                  showBottomToast('From Date is required');
                } else if (_toDate == 'To Date') {
                  showBottomToast('To Date is required');
                } else if (reasonRequired.text.isEmpty) {
                  showBottomToast('Reason is required');
                } else {
                  apiCallForAddLeave();
                }
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

    final loadPendingStatus = Visibility(
        visible: isEditActive,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Padding(
              padding: const EdgeInsets.only(left: 10, right: 10, top: 10),
              child: Text(
                'Approved Status',
                style: TextStyle(
                    color: Colors.black,
                    fontSize: ScreenUtil().setSp(18),
                    fontWeight: FontWeight.w600),
              ),
            ),
            Row(
              children: [
                Radio(
                  value: 1,
                  groupValue: approvedStatusflg,
                  activeColor: appColorRADIO,
                  onChanged: (value) {
                    setState(() {
                      approvedStatusflg = value;
                      // // _radioVal = 'Active';
                      // "_radioVal" = '1';
                      //approvedStatusflg = "1";
                    });
                  },
                ),
                Text('Approved'),
                Radio(
                  value: 2,
                  groupValue: approvedStatusflg,
                  activeColor: appColorRADIO,
                  onChanged: (value) {
                    setState(() {
                      approvedStatusflg = value;
                      // // _radioVal = 'Inactive';
                      // "_radioVal" = '0';
                      //approvedStatusflg = "2";
                    });
                  },
                ),
                Text('Disapproved'),
                Radio(
                  value: 0,
                  groupValue: approvedStatusflg,
                  activeColor: appColorRADIO,
                  onChanged: (value) {
                    setState(() {
                      approvedStatusflg = value;
                      // // _radioVal = 'Inactive';
                      // "_radioVal" = '0';
                      //approvedStatusflg = "0";
                    });
                  },
                ),
                Text('Pending'),
              ],
            ),
            Visibility(
              visible: sandwichISVisible,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Padding(
                    padding: const EdgeInsets.only(left: 10, right: 10),
                    child: Text(
                      'Sandwich Leave',
                      style: TextStyle(
                          color: Colors.black,
                          fontSize: ScreenUtil().setSp(18),
                          fontWeight: FontWeight.w600),
                    ),
                  ),
                  Row(
                    children: [
                      Radio(
                        value: 1,
                        groupValue: sandwichflg,
                        activeColor: appColorRADIO,
                        onChanged: (value) {
                          setState(() {
                            //sandwichLeave = value;
                            // // _radioVal = 'Active';
                            // "_radioVal" = '1';
                            sandwichflg = value.toString() as int;
                          });
                        },
                      ),
                      Text('Yes'),
                      Radio(
                        value: 2,
                        groupValue: sandwichflg,
                        activeColor: appColorRADIO,
                        onChanged: (value) {
                          setState(() {
                            //sandwichLeave = value;
                            // // _radioVal = 'Inactive';
                            // "_radioVal" = '0';
                            sandwichflg = value.toString() as int;
                          });
                        },
                      ),
                      Text('No'),
                    ],
                  ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.only(left: 10, right: 10, bottom: 5),
              child: Text(
                'Approved Date',
                style: TextStyle(
                    color: Colors.black,
                    fontSize: ScreenUtil().setSp(18),
                    fontWeight: FontWeight.w600),
              ),
            ),
            Row(
              children: [
                Padding(
                  padding: const EdgeInsets.only(left: 10, right: 10),
                  child: Icon(Icons.check_box_outlined),
                ),
                Text(_fromDate),
              ],
            ),
            Padding(
                padding: const EdgeInsets.only(
                    left: 10, right: 10, top: 10, bottom: 5),
                child: Text(
                  'Remark',
                  style: TextStyle(
                      color: Colors.black,
                      fontSize: ScreenUtil().setSp(18),
                      fontWeight: FontWeight.w600),
                )),
            Padding(
              padding: const EdgeInsets.only(left: 10, right: 10, bottom: 30),
              child: Container(
                decoration: BoxDecoration(
                  color: Colors.grey[100],
                  border: Border.all(width: 1, color: Colors.grey),
                  borderRadius: BorderRadius.circular(3),
                ),
                child: TextFormField(
                  controller: txtRemark,
                  maxLines: null,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Remark is required';
                    }
                    return null;
                  },
                  decoration: InputDecoration(
                    border: InputBorder.none,
                    hintText: 'Remark For Leave',
                    prefixIcon: Icon(
                      Icons.event_note,
                      color: Colors.grey,
                    ),
                  ),
                  onSaved: (value) {
                    _remark = value ?? '';
                    print(_remark);
                  },
                ),
              ),
            ),
          ],
        ));

    return SafeArea(
       top: false,
        bottom: true,
      child: Scaffold(
        body: GestureDetector(
          child: Stack(
            children: <Widget>[
              CustomHeaderWithBack(
                  scaffoldKey: widget.scaffoldKey, title: widget.title),
              Container(
                margin: EdgeInsets.only(top: 90.0),
                child: ListView(
                  children: <Widget>[
                    Card(
                      margin: EdgeInsets.only(
                          left: ScreenUtil().setSp(10),
                          //top: ScreenUtil().setSp(80),
                          right: ScreenUtil().setSp(10),
                          bottom: ScreenUtil().setSp(30)),
                      elevation: 5,
                      child: Form(
                        key: _formKey,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: <Widget>[
                            SizedBox(
                              height: ScreenUtil().setSp(20),
                            ),
                            Center(
                              child: Text(
                                'Leave Application',
                                style: TextStyle(
                                    color: appAccentColor,
                                    fontSize: ScreenUtil().setSp(18),
                                    fontWeight: FontWeight.w800),
                              ),
                            ),
                            Visibility(
                              visible: isVisibleCount,
                              child: _loadLeaveCount(),
                            ),
                            leaveType,
                            fromDate,
                            toDate,
                            noOfDays,
                            reasonForLeave,
                            Visibility(
                              visible: isVisibleCount,
                              child: loadPendingStatus,
                            ),
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
            //Navigator.of(context).pop();
            FocusScope.of(context).requestFocus(new FocusNode());
          },
        ),
      ),
    );
  }

Future _selectFromDate() async {
  DateTime? _picked = await showDatePicker(
    context: context,
    initialDate: DateTime.now(),
    firstDate: DateTime(DateTime.now().year),
    lastDate: DateTime(DateTime.now().year + 1),
  );

  if (_picked != null) {
    setState(() {
      _fromDate = DateFormat('yyyy-MM-dd').format(_picked);
      calculateNoOfDays();
    });
  }
}


Future _selectToDate() async {
  DateTime now = DateTime.now();
  DateTime initial = (_fromDate != 'From Date')
      ? DateTime.parse('$_fromDate 00:00:00')
      : now;

  DateTime? _picked = await showDatePicker(
    context: context,
    initialDate: initial,
    firstDate: initial,
    lastDate: DateTime(2025, 12, 31), // ✅ Fix here
  );

  if (_picked != null) {
    setState(() {
      print(_picked);
      _toDate = DateFormat('yyyy-MM-dd').format(_picked);
      toDateHalfDay = false;
      calculateNoOfDays();
    });
  }
}


  _loadLeaveCount() {
    List colors = [
      Colors.red,
      Colors.green,
      Colors.yellow,
    ];

    if (_totalLeaveCountApiCallBack?.items!.isNotEmpty ?? false) {
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
                // Text(' ${_totalLeaveCountApiCallBack.items[i].leaveType}',
                //     style: TextStyle(
                //       fontSize: 10.0,
                //       fontWeight: FontWeight.bold,
                //     )),
                Text('${_totalLeaveCountApiCallBack!.items![i].leaveType}',
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
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Wrap(
            children: children,
          ),
        ),
      );
    }

    return Container();
  }

  void calculateNoOfDays() {
    try {
      if (DateTime.parse(_toDate).difference(DateTime.parse(_fromDate)).inDays <
          0) {
        _toDate = 'To Date';
        _numberOfDays = '00';
        toDateHalfDay = false;
      } else {
        var days = (DateTime.parse(_toDate)
                .difference(DateTime.parse(_fromDate))
                .inDays) +
            1 -
            ((fromDateHalfDay) ? 0.5 : 0) -
            ((toDateHalfDay) ? 0.5 : 0);
        _numberOfDays = days.toString();
      }
      strHalfDay = (fromDateHalfDay) ? '$_fromDate,' : '';
      strHalfDay = (toDateHalfDay) ? '$strHalfDay $_toDate' : '$strHalfDay';
      print(strHalfDay);
    } catch (e) {
      print(e.toString());
    }
  }
}

class LeaveTypeCallBack {
   int? totalCount;
   bool? success;
   List<Items>? items;
  String? message;
   int? status;

  LeaveTypeCallBack(
      {required this.totalCount,
      required this.success,
      required this.items,
      required this.message,
      required this.status});

  LeaveTypeCallBack.fromJson(Map<String, dynamic> json) {
    totalCount = json['total_count'];
    success = json['success'];
   if (json['items'] != null) {
  items = []; 
  json['items'].forEach((v) {
    items!.add(Items.fromJson(v));
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
  String? leaveType;
   int? status;
   int? srNo;

  Items(
      {required this.id,
      required this.leaveType,
      required this.status,
      required this.srNo});

  Items.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    leaveType = json['leaveType'];
    status = json['status'];
    srNo = json['srNo'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['id'] = this.id;
    data['leaveType'] = this.leaveType;
    data['status'] = this.status;
    data['srNo'] = this.srNo;
    return data;
  }
}

class LeaveCallBack {
   int? totalCount;
   bool? success;
   LeaveItems? items;
  String? message;
   int? status;
  String? currentTime;
  String? currentUtcTime;

  LeaveCallBack(
      {required this.totalCount,
      required this.success,
      required this.items,
      required this.message,
      required this.status,
      required this.currentTime,
      required this.currentUtcTime});

  LeaveCallBack.fromJson(Map<String, dynamic> json) {
    totalCount = json['total_count'];
    success = json['success'];
    items =
        json['items'] != null ? new LeaveItems.fromJson(json['items']) : null;
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

class LeaveItems {
   int? id;
   int? userId;
   int? leaveType;
  String? reason;
  String? fromDate;
  String? toDate;
   int? noDays;
  String? halfdayDates;
  String? approvedDates;
   int? approvalStatus;
  String? remark;
  String? approvedBy;
   int? isdeleted;
   int? status;
  String? createdAt;
  String? updatedAt;

  LeaveItems(
      {required this.id,
      required this.userId,
      required this.leaveType,
      required this.reason,
      required this.fromDate,
      required this.toDate,
      required this.noDays,
      required this.halfdayDates,
      required this.approvedDates,
      required this.approvalStatus,
      required this.remark,
      required this.approvedBy,
      required this.isdeleted,
      required this.status,
      required this.createdAt,
      required this.updatedAt});

  LeaveItems.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    userId = json['userId'];
    leaveType = json['leaveType'];
    reason = json['reason'];
    fromDate = json['fromDate'];
    toDate = json['toDate'];
    noDays = json['noDays'];
    halfdayDates = json['halfdayDates'];
    approvedDates = json['approvedDates'];
    approvalStatus = json['approvalStatus'];
    remark = json['remark'];
    approvedBy = json['approvedBy'];
    isdeleted = json['isdeleted'];
    status = json['status'];
    createdAt = json['created_at'];
    updatedAt = json['updated_at'];
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
    data['halfdayDates'] = this.halfdayDates;
    data['approvedDates'] = this.approvedDates;
    data['approvalStatus'] = this.approvalStatus;
    data['remark'] = this.remark;
    data['approvedBy'] = this.approvedBy;
    data['isdeleted'] = this.isdeleted;
    data['status'] = this.status;
    data['created_at'] = this.createdAt;
    data['updated_at'] = this.updatedAt;
    return data;
  }
}

class TotalLeaveCountApiCallBack {
  String? current_time;
   List<Item>? items;
  String? message;
   int? status;
   bool? success;
   int? total_count;

  TotalLeaveCountApiCallBack(
      {required this.current_time,
      required this.items,
      required this.message,
      required this.status,
      required this.success,
      required this.total_count});

  factory TotalLeaveCountApiCallBack.fromJson(Map<String, dynamic> json) {
    return TotalLeaveCountApiCallBack(
      current_time: json['current_time'],
      items: json['items'] != null
          ? (json['items'] as List).map((i) => Item.fromJson(i)).toList()
          : [],
      message: json['message'],
      status: json['status'],
      success: json['success'],
      total_count: json['total_count'],
    );
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['current_time'] = this.current_time;
    data['message'] = this.message;
    data['status'] = this.status;
    data['success'] = this.success;
    data['total_count'] = this.total_count;
    data['items'] = this.items!.map((v) => v.toJson()).toList();
    return data;
  }
}

class Item {
  String available_count;
  String leaveType;
  String short_name;
  String total_count;

  Item(
      {required this.available_count,
      required this.leaveType,
      required this.short_name,
      required this.total_count});

  factory Item.fromJson(Map<String, dynamic> json) {
    return Item(
      available_count: '${json['available_count']}',
      leaveType: json['leaveType'],
      short_name: json['short_name'],
      total_count: '${json['total_count']}',
    );
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['available_count'] = this.available_count;
    data['leaveType'] = this.leaveType;
    data['short_name'] = this.short_name;
    data['total_count'] = this.total_count;
    return data;
  }
}

class SingleLeaveCallBack {
  int? totalCount;
  bool? success;
  SingleLeaveItems? items;
  String? message;
  int? status;
  String? currentTime;
  String? currentUtcTime;

  SingleLeaveCallBack(
      {required this.totalCount,
      required this.success,
      required this.items,
      required this.message,
      required this.status,
      required this.currentTime,
      required this.currentUtcTime});

  SingleLeaveCallBack.fromJson(Map<String, dynamic> json) {
    totalCount = json['total_count'];
    success = json['success'];
    items = json['items'] != null
        ? new SingleLeaveItems.fromJson(json['items'])
        : null;
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

class SingleLeaveItems {
  int? id;
  int? userId;
  int? holidaystatus;
  int? pholidaystatus;
  int? dstatus;
  int? pstatus;

  SingleLeaveItems({
    required this.id,
    required this.userId,
    required this.holidaystatus,
    required this.pholidaystatus,
    required this.dstatus,
    required this.pstatus,
  });

  SingleLeaveItems.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    userId = json['userId'];
    holidaystatus = json['holidaystatus'];
    pholidaystatus = json['pholidaystatus'];
    dstatus = json['dstatus'];
    pstatus = json['pstatus'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['id'] = this.id;
    data['userId'] = this.userId;
    data['holidaystatus'] = this.holidaystatus;
    data['pholidaystatus'] = this.pholidaystatus;
    data['dstatus'] = this.dstatus;
    data['pstatus'] = this.pstatus;
    return data;
  }
}
