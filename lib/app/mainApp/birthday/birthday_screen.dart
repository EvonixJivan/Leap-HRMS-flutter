import 'dart:async';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:hrms/app/uiComponent/custom_header.dart';
import 'package:hrms/appUtil/app_util_config.dart';
import 'package:hrms/appUtil/network_util.dart';
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:url_launcher/url_launcher.dart';

class BirthdayList extends StatefulWidget {
  var scaffoldKey;
  var title;

  BirthdayList({Key? key, required this.scaffoldKey, required this.title})
      : super(key: key);

  @override
  _BirthdayListState createState() {
    return _BirthdayListState();
  }
}

class _BirthdayListState extends State<BirthdayList> {
  NetworkUtil _networkUtil = NetworkUtil();
  Future<SharedPreferences> _prefs = SharedPreferences.getInstance();
  final GlobalKey<ScaffoldState> _scaffoldKey = new GlobalKey<ScaffoldState>();
  final GlobalKey<RefreshIndicatorState> _refreshIndicatorKey =
      new GlobalKey<RefreshIndicatorState>();
 String? apiToken;
  late int userId, companyId;
  var _noDataFound = 'Loading...';
  BirthdayDataApiCallBack? _birthdayDataApiCallBack;

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
  void initState() {
    super.initState();
    apiCallForBirthdayData();
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
       top: false,
        bottom: true,
      child: Scaffold(
        body: Container(
          color: appBackgroundDashboard,
          child: Stack(
            children: <Widget>[
              CustomHeaderWithBack(
                  scaffoldKey: widget.scaffoldKey, title: widget.title),
              Container(
                margin: EdgeInsets.only(top: 90.0),
                child: Column(
                  children: <Widget>[
                    Expanded(
                      child: RefreshIndicator(
                        key: _refreshIndicatorKey,
                        onRefresh: _handleRefresh,
                        child: (_birthdayDataApiCallBack?.items.isNotEmpty ?? false)
                            ? getBirthdayPageView()
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
      ),
    );
  }

  @override
  void dispose() {
    super.dispose();
  }

  Widget getBirthdayPageView() {
    return ListView.builder(
        itemCount: _birthdayDataApiCallBack!.items.length,
        itemBuilder: (BuildContext context, int index) {
          return Padding(
            padding: const EdgeInsets.only(
                top: 0.0, bottom: 8.0, left: 10, right: 10),
            child: Stack(
              children: <Widget>[
                Container(
                  width: MediaQuery.of(context).size.width,
                  // height: 135,
                  margin: const EdgeInsets.only(top: 35.0),
                  child: Card(
                    margin: EdgeInsets.only(left: 5, right: 5),
                    elevation: 5,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: <Widget>[
                        SizedBox(
                          height: ScreenUtil().setSp(15),
                        ),
                        Row(
                          children: <Widget>[
                            Expanded(flex: 1, child: Text('')),
                            Expanded(
                              flex: 2,
                              child: Text(
                                  "${_birthdayDataApiCallBack!.items[index].firstName ?? ''} ${_birthdayDataApiCallBack!.items[index].lastName ?? ''}",
                                  style: TextStyle(
                                      fontSize: ScreenUtil().setSp(18),
                                      color: appPrimaryColor,
                                      fontWeight: FontWeight.bold)),
                            ),
                          ],
                        ),
                        SizedBox(
                          height: ScreenUtil().setSp(17),
                        ),
                        Row(
                          children: <Widget>[
                            SizedBox(
                              width: 20,
                            ),
                            Text('HAPPY BIRTHDAY',
                                style: TextStyle(
                                  fontSize: ScreenUtil().setSp(11),
                                )),
                          ],
                        ),
                        Row(
                          children: <Widget>[
                            Expanded(
                              child: Row(
                                children: <Widget>[
                                  SizedBox(
                                    width: 15,
                                  ),
                                  Icon(
                                    Icons.calendar_today,
                                    color: appPrimaryColor,
                                    size: 15,
                                  ),
                                  SizedBox(
                                    width: 10,
                                  ),
                                  Text(
                                    DateFormat('dd, MMM yyyy').format(
                                        DateTime.parse(_birthdayDataApiCallBack!
                                            .items[index].birthDate)),
                                  ),
                                ],
                              ),
                            ),
                            Expanded(
                              child: Row(
                                children: <Widget>[
                                  Icon(
                                    Icons.call,
                                    color: appPrimaryColor,
                                    size: 15,
                                  ),
                                  SizedBox(width: 3),
                                  TextButton(
                                      style: ElevatedButton.styleFrom(
                                          backgroundColor: Colors.white),
                                      onPressed: () => launch(
                                          "tel://${_birthdayDataApiCallBack!.items[index].contactNo}"),
                                      child: new Text(
                                        _birthdayDataApiCallBack!
                                            .items[index].contactNo,
                                        style: TextStyle(
                                            decoration:
                                                TextDecoration.underline,
                                            color: Colors.blue),
                                    
                                      )),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(20.0)),
                  ),
                ),
                Container(
                  alignment: Alignment.topLeft,
                  child: Container(
                    margin: EdgeInsets.only(left: 20, top: 10),
                    height: 80,
                    width: 80,
                    decoration: new BoxDecoration(
                      borderRadius: new BorderRadius.circular(40),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(4.0),
                      child: Container(
                        height: 76,
                        width: 76,
                        decoration: new BoxDecoration(
                          borderRadius: new BorderRadius.circular(38),
                        ),
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(38.0),
                          child: FadeInImage.assetNetwork(
                            placeholder: 'assets/image/default.png',
                            image: _birthdayDataApiCallBack!
                                .items[index].profileImage,
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          );
        });
  }

  Future apiCallForBirthdayData() async {
    String _apiToken = '', _noDataFound = '';
    int _userId = 0, _companyId = 0;
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
    try {
      _noDataFound = 'Loading...';
      _networkUtil.post(apiGetBirthdayData, body: map).then((dynamic res) {
        _noDataFound = noDataFound;
        try {
          AppLog.showLog(res.toString());
          _birthdayDataApiCallBack = BirthdayDataApiCallBack.fromJson(res);
          if (_birthdayDataApiCallBack!.status == unAuthorised) {
            logout(context);
          }
          if (_birthdayDataApiCallBack!.success) {
            //showBottomToast(_driverPackageApiCallBack!.message);
          } else {
            showBottomToast(_birthdayDataApiCallBack!.message);
          }
        } catch (es) {
          showErrorLog(es.toString());
          showCenterToast(errorApiCall);
        }
        setState(() {});
      });
    } catch (e) {
      // showErrorLog(e.toString());
      _noDataFound = noDataFound;
      setState(() {});
    }
  }
}

class BirthdayDataApiCallBack {
  final int totalCount;
  final bool success;
  final List<BitrhItems> items;
  final String message;
  final int status;
  final String currentTime;
  final String currentUtcTime;

  BirthdayDataApiCallBack({
    required this.totalCount,
    required this.success,
    required this.items,
    required this.message,
    required this.status,
    required this.currentTime,
    required this.currentUtcTime,
  });
  factory BirthdayDataApiCallBack.fromJson(Map<String, dynamic> json) {
    return BirthdayDataApiCallBack(
      totalCount: json['total_count'] ?? 0,
      success: json['success'] ?? false,
      items: json['items'] != null
          ? List<BitrhItems>.from(json['items'].map((v) => BitrhItems.fromJson(v)))
          : <BitrhItems>[],
      message: json['message'] ?? '',
      status: json['status'] ?? 0,
      currentTime: json['current_time'] ?? '',
      currentUtcTime: json['current_utc_time'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['total_count'] = this.totalCount;
    data['success'] = this.success;
    data['items'] = this.items.map((v) => v.toJson()).toList();
    data['message'] = this.message;
    data['status'] = this.status;
    data['current_time'] = this.currentTime;
    data['current_utc_time'] = this.currentUtcTime;
    return data;
  }
}

class BitrhItems {
  int id;
  String profileImage;
  String contactNo;
  int companyId;
  String firstName;
  String lastName;
  String birthDate;

  BitrhItems({
    required this.id,
    required this.profileImage,
    required this.contactNo,
    required this.companyId,
    required this.firstName,
    required this.lastName,
    required this.birthDate,
  });

  BitrhItems.fromJson(Map<String, dynamic> json)
      : id = json['id'] ?? 0,
        profileImage = json['profileImage'] ?? '',
        contactNo = json['contact_no'] ?? '',
        companyId = json['company_id'] ?? 0,
        firstName = json['first_name'] ?? '',
        lastName = json['last_name'] ?? '',
        birthDate = json['birth_date'] ?? '';

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['id'] = this.id;
    data['profileImage'] = this.profileImage;
    data['contact_no'] = this.contactNo;
    data['company_id'] = this.companyId;
    data['first_name'] = this.firstName;
    data['last_name'] = this.lastName;
    data['birth_date'] = this.birthDate;
    return data;
  }
}
