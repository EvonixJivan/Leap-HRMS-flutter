import 'dart:async';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:hrms/app/uiComponent/custom_header.dart';
import 'package:hrms/appUtil/app_util_config.dart';
import 'package:hrms/appUtil/network_util.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:flutter_screenutil/flutter_screenutil.dart';

class Holiday extends StatefulWidget {
  var scaffoldKey;
  var title;

  Holiday({Key? key, @required this.scaffoldKey, @required this.title})
      : super(key: key);

  @override
  _HolidayState createState() {
    return _HolidayState();
  }
}

class _HolidayState extends State<Holiday> {
  NetworkUtil _networkUtil = NetworkUtil();
  Future<SharedPreferences> _prefs = SharedPreferences.getInstance();
  final GlobalKey<ScaffoldState> _scaffoldKey = new GlobalKey<ScaffoldState>();
  final GlobalKey<RefreshIndicatorState> _refreshIndicatorKey =
      new GlobalKey<RefreshIndicatorState>();
  HolidayCallBack? _holidayCallBack;
 String? apiToken;
 late int userId, companyId;
  var _noDataFound = 'Loading...';

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

  Future apiCallForHolidayList() async {
    final SharedPreferences prefs = await _prefs;
    if (prefs.getBool(SP_IS_LOGIN_BOOL) != null) {
       userId = prefs.getInt(SP_ID)!;
      apiToken = prefs.getString(SP_API_TOKEN)!;
      companyId = prefs.getInt(SP_COMPANY_ID)!;
    }
    var map = new Map<String, dynamic>();
    map["appType"] = Platform.operatingSystem.toUpperCase();
    map["userId"] = userId.toString();
    map["api_token"] = apiToken;
    map['companyId'] = companyId.toString();

    print(map);
    try {
      _noDataFound = 'Loading...';
      _networkUtil.post(apiGetHoliday, body: map).then((dynamic res) {
        _noDataFound = noDataFound;

        try {
          AppLog.showLog(res.toString());
          _holidayCallBack = HolidayCallBack.fromJson(res);
          if (_holidayCallBack!.status == unAuthorised) {
            logout(context);
          }
          if (!_holidayCallBack!.success!) {
            showBottomToast(_holidayCallBack!.message ?? "");
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

  bool fromText = true;
  var matchText = "jivan";
  @override
  void initState() {
    super.initState();
    apiCallForHolidayList();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
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
                      child: (_holidayCallBack?.items!.holidays!.isNotEmpty ?? false)
                          ? getHolidayListView()
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

  Widget getHolidayListView() {
    return ListView.builder(
      shrinkWrap: true,
      physics: const BouncingScrollPhysics(),
      itemBuilder: (BuildContext context, int index) {
        return Padding(
          padding: EdgeInsets.only(
              left: ScreenUtil().setSp(20),
              right: ScreenUtil().setSp(20),
              bottom: ScreenUtil().setSp(15)),
          child: Card(
            color: appWhiteColor,
            shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10.0)),
            // elevation: 5,
            child: Padding(
              padding: EdgeInsets.all(ScreenUtil().setSp(12)),
              child: Column(
                children: <Widget>[
                  Row(
                    children: <Widget>[
                      Expanded(
                        child: Row(
                          children: <Widget>[
                            Icon(
                              Icons.calendar_today,
                              color: appPrimaryColor,
                              size: ScreenUtil().setSp(15),
                            ),
                            SizedBox(width: ScreenUtil().setSp(10)),
                            Text(
                              _holidayCallBack!.items!.holidays![index].date ?? "",
                              // Text(
                              //   DateFormat('yyyy-MM-dd').format(DateTime.parse(
                              //       _holidayCallBack
                              //           .items.holidays[index].date)),
                              // _holidayCallBack.items.holidays[index].date +
                              //     "  |  ",
                              style: const TextStyle(fontFamily: font),
                            ),
                            const Text(
                              '  |',
                              style: TextStyle(color: Colors.red),
                            ),
                            SizedBox(width: ScreenUtil().setSp(10)),
                            Expanded(
                              child: Text(
                                _holidayCallBack!
                                    .items!.holidays![index].holidayName ?? "",
                                style: const TextStyle(
                                    color: Colors.red, fontFamily: font),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(
                    height: 5,
                  ),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      if (_holidayCallBack!.items!.holidays![index].branch!
                              .toLowerCase() ==
                          ('UAE,'.toLowerCase()))
                        const Text('\u{1F1E6}\u{1F1EA}')
                      else if (_holidayCallBack!.items!.holidays![index].branch!
                              .toLowerCase() ==
                          ('INDIA,'.toLowerCase()))
                        const Text('\u{1F1EE}\u{1F1F3}')
                      else if (_holidayCallBack!.items!.holidays![index].branch!
                              .toLowerCase() ==
                          ('UAE,INDIA,'.toLowerCase()))
                        const Text('\u{1F1E6}\u{1F1EA}' '\u{1F1EE}\u{1F1F3}')
                      else
                        Align(
                            alignment: Alignment.centerLeft,
                            child: Text(
                              _holidayCallBack!.items!.holidays![index].branch ?? "",
                              style: const TextStyle(fontFamily: font),
                            )),
                    ],
                  )
                ],
              ),
            ),

            // child: Container(
            //   height: MediaQuery.of(context).size.height / 08,
            //   child: Padding(
            //     padding: EdgeInsets.all(ScreenUtil().setSp(12)),
            //     child: Column(
            //       children: <Widget>[
            //         Row(
            //           children: <Widget>[
            //             Expanded(
            //               child: Row(
            //                 children: <Widget>[
            //                   Icon(
            //                     Icons.calendar_today,
            //                     color: appPrimaryColor,
            //                     size: ScreenUtil().setSp(15),
            //                   ),
            //                   SizedBox(width: ScreenUtil().setSp(10)),
            //                   Text(
            //                     _holidayCallBack.items.holidays[index].date,
            //                     // Text(
            //                     //   DateFormat('yyyy-MM-dd').format(DateTime.parse(
            //                     //       _holidayCallBack
            //                     //           .items.holidays[index].date)),
            //                     // _holidayCallBack.items.holidays[index].date +
            //                     //     "  |  ",
            //                     style: const TextStyle(fontFamily: font),
            //                   ),
            //                   const Text(
            //                     '  |',
            //                     style: TextStyle(color: Colors.red),
            //                   ),
            //                   SizedBox(width: ScreenUtil().setSp(10)),
            //                   Expanded(
            //                     child: Text(
            //                       _holidayCallBack
            //                           .items.holidays[index].holidayName,
            //                       style: const TextStyle(
            //                           color: Colors.red, fontFamily: font),
            //                     ),
            //                   ),
            //                 ],
            //               ),
            //             ),
            //           ],
            //         ),
            //         const SizedBox(
            //           height: 5,
            //         ),
            //         Expanded(
            //             child: Column(
            //           crossAxisAlignment: CrossAxisAlignment.start,
            //           children: [
            //             if (_holidayCallBack.items.holidays[index].branch
            //                     .toLowerCase() ==
            //                 ('UAE,'.toLowerCase()))
            //               const Text('\u{1F1E6}\u{1F1EA}')
            //             else if (_holidayCallBack.items.holidays[index].branch
            //                     .toLowerCase() ==
            //                 ('INDIA,'.toLowerCase()))
            //               const Text('\u{1F1EE}\u{1F1F3}')
            //             else if (_holidayCallBack.items.holidays[index].branch
            //                     .toLowerCase() ==
            //                 ('UAE,INDIA,'.toLowerCase()))
            //               const Text('\u{1F1E6}\u{1F1EA}' '\u{1F1EE}\u{1F1F3}')
            //             else
            //               Align(
            //                   alignment: Alignment.centerLeft,
            //                   child: Text(
            //                     _holidayCallBack.items.holidays[index].branch,
            //                     style: const TextStyle(fontFamily: font),
            //                   )),
            //           ],
            //         ))
            //       ],
            //     ),
            //   ),
            // ),
          ),
        );
      },
      itemCount: _holidayCallBack!.items!.holidays!.length,
    );
  }

  // Widget getHolidayListView() {
  //   return ListView.builder(
  //     itemBuilder: (BuildContext context, int index) {
  //       return Padding(
  //         padding: EdgeInsets.only(
  //             left: ScreenUtil().setSp(10),
  //             right: ScreenUtil().setSp(10),
  //             bottom: ScreenUtil().setSp(5)),
  //         child: Card(
  //           elevation: 5,
  //           child: Padding(
  //             padding: EdgeInsets.all(ScreenUtil().setSp(10)),
  //             child: Column(
  //               children: <Widget>[
  //                 Row(
  //                   children: <Widget>[
  //                     Expanded(
  //                       child: Row(
  //                         children: <Widget>[
  //                           Icon(
  //                             Icons.calendar_today,
  //                             color: appPrimaryColor,
  //                             size: ScreenUtil().setSp(15),
  //                           ),
  //                           SizedBox(width: ScreenUtil().setSp(10)),
  //                           Text(_holidayCallBack.items.holidays[index].date),
  //                           SizedBox(width: ScreenUtil().setSp(50)),
  //                           Expanded(
  //                             child: Text(
  //                               _holidayCallBack.items.holidays[index].holidayName,
  //                               maxLines: null,
  //                             ),
  //                           ),
  //                           // Icon(
  //                           //   Icons.emoji_,
  //                           //   color: appPrimaryColor,
  //                           //   size: ScreenUtil().setSp(15),
  //                           // ),
  //                           //fromText ? Text('\u{1F1EE}') : Text('No Data'),
  //                           // _holidayCallBack.items.holidays[index].branch.toLowerCase().contains('UAE'.toLowerCase()) ? Text('\u{1F1EE}\u{1F1F3}') : Text('\u{1F1E6}\u{1F1EA}'),
  //                           // _holidayCallBack.items.holidays[index].branch.toLowerCase().contains('UAE'.toLowerCase()) ? Text('\u{1F1E6}\u{1F1EA}') : Text('\u{1F1EE}\u{1F1F3}'),
  //                          // print(_holidayCallBack.items.holidays[index].branch);
  //                           if(_holidayCallBack.items.holidays[index].branch.toLowerCase() == ('UAE,'.toLowerCase()))
  //                             Text('\u{1F1E6}\u{1F1EA}')
  //                           else if(_holidayCallBack.items.holidays[index].branch.toLowerCase() == ('INDIA,'.toLowerCase()))
  //                             Text('\u{1F1EE}\u{1F1F3}')
  //                           else if(_holidayCallBack.items.holidays[index].branch.toLowerCase() == ('UAE,INDIA,'.toLowerCase()))
  //                             Text('\u{1F1E6}\u{1F1EA}' +' '+ '\u{1F1EE}\u{1F1F3}')
  //                           else
  //                             Text(_holidayCallBack.items.holidays[index].branch)
  //                           // _holidayCallBack.items.holidays[index].branch.toLowerCase() == ('UAE'.toLowerCase()) ? Text('\u{1F1E6}\u{1F1EA}') : Text('\u{1F1EE}\u{1F1F3}'),

  //                           // isLast! ? Container(height: SizeConfig.heightMultiplier * 2,) : (isCompleted ? Container(margin: EdgeInsets.only(left: 8),height: 10, width: 0.8, color: AppColors.green,) : Container(margin: EdgeInsets.only(left: 8), height: 10, width: 0.5, color: Colors.black,))
  //                         ],
  //                       ),
  //                     ),

  //                   ],
  //                 ),
  //               ],
  //             ),
  //           ),
  //         ),
  //       );
  //     },
  //     itemCount: _holidayCallBack.items.holidays.length,
  //   );
  // }
}

class HolidayCallBack {
   int? totalCount;
  bool? success;
  Items? items;
 String? message;
  int? status;
 String? currentTime;
 String? currentUtcTime;

  HolidayCallBack(
      {required this.totalCount,
      required this.success,
     required this.items,
     required this.message,
     required this.status,
     required this.currentTime,
     required this.currentUtcTime});

  HolidayCallBack.fromJson(Map<String, dynamic> json) {
    totalCount = json['total_count'];
    success = json['success'];
    items = json['items'] != null ? new Items.fromJson(json['items']) : null;
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

class Items {
  int? id;
  int? parentId;
 String? companyName;
 String? companyEmail;
 String? companyLocation;
 String? companyAddress;
 String? companyNumber;
 String? companyLogo;
 String? fulldayWorkingHours;
 String? halfdayWorkingHours;
 String? weekendDays;
  int? isdeleted;
  int? status;
 String? createdAt;
 String? updatedAt;
  int? createdBy;
  List<Holidays>? holidays;

  Items(
      {required this.id,
     required this.parentId,
     required this.companyName,
     required this.companyEmail,
     required this.companyLocation,
     required this.companyAddress,
     required this.companyNumber,
     required this.companyLogo,
     required this.fulldayWorkingHours,
     required this.halfdayWorkingHours,
     required this.weekendDays,
     required this.isdeleted,
     required this.status,
     required this.createdAt,
     required this.updatedAt,
     required this.createdBy,
     required this.holidays});

  Items.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    parentId = json['parent_id'];
    companyName = json['company_name'];
    companyEmail = json['company_email'];
    companyLocation = json['company_location'];
    companyAddress = json['company_address'];
    companyNumber = json['company_number'];
    companyLogo = json['company_logo'];
    fulldayWorkingHours = json['fullday_working_hours'];
    halfdayWorkingHours = json['halfday_working_hours'];
    weekendDays = json['weekend_days'];
    isdeleted = json['isdeleted'];
    status = json['status'];
    createdAt = json['created_at'];
    updatedAt = json['updated_at'];
    createdBy = json['created_by'];
    if (json['holidays'] != null) {
  holidays = <Holidays>[]; // initialize the list first!
  json['holidays'].forEach((v) {
    holidays!.add(Holidays.fromJson(v));
  });
}
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['id'] = this.id;
    data['parent_id'] = this.parentId;
    data['company_name'] = this.companyName;
    data['company_email'] = this.companyEmail;
    data['company_location'] = this.companyLocation;
    data['company_address'] = this.companyAddress;
    data['company_number'] = this.companyNumber;
    data['company_logo'] = this.companyLogo;
    data['fullday_working_hours'] = this.fulldayWorkingHours;
    data['halfday_working_hours'] = this.halfdayWorkingHours;
    data['weekend_days'] = this.weekendDays;
    data['isdeleted'] = this.isdeleted;
    data['status'] = this.status;
    data['created_at'] = this.createdAt;
    data['updated_at'] = this.updatedAt;
    data['created_by'] = this.createdBy;
    data['holidays'] = this.holidays!.map((v) => v.toJson()).toList();
      return data;
  }
}

class Holidays {
  int? id;
  int? companyId;
 String? holidayName;
 String? date;
  int? createdBy;
  int? isdeleted;
 String? createdAt;
String? updatedAt;
 String? branch;

  Holidays(
      {required this.id,
     required this.companyId,
     required this.holidayName,
     required this.date,
     required this.createdBy,
     required this.isdeleted,
     required this.createdAt,
     required this.updatedAt,
     required this.branch});

  Holidays.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    companyId = json['companyId'];
    holidayName = json['holiday_name'];
    date = json['date'];
    createdBy = json['createdBy'];
    isdeleted = json['isdeleted'];
    createdAt = json['created_at'];
    updatedAt = json['updated_at'];
    branch = json["branchNamelatest"];
    // branch = "IND";
    // json['holidays'].forEach((v) {
    //   holidays.add(new Holidays.fromJson(v));
    // });
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['id'] = this.id;
    data['companyId'] = this.companyId;
    data['holiday_name'] = this.holidayName;
    data['date'] = this.date;
    data['createdBy'] = this.createdBy;
    data['isdeleted'] = this.isdeleted;
    data['created_at'] = this.createdAt;
    data['updated_at'] = this.updatedAt;
    data['branchNamelatest'] = this.branch;
    return data;
  }
}
