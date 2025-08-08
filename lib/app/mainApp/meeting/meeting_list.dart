import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:hrms/appUtil/app_util_config.dart';
import 'package:hrms/appUtil/network_util.dart';
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:community_material_icon/community_material_icon.dart';
import '../../uiComponent/custom_header.dart';
import 'add_meeting.dart';
import 'package:url_launcher/url_launcher.dart';

class MeetingList extends StatefulWidget {
  var scaffoldKey;
  var title;

  MeetingList({Key? key, required this.scaffoldKey, required this.title})
      : super(key: key);

  @override
  _MeetingListState createState() {
    return _MeetingListState();
  }
}

class _MeetingListState extends State<MeetingList> {
  MeetingListApiCallBack? _meetingListApiCallBack;
  NetworkUtil _networkUtil = NetworkUtil();
  Future<SharedPreferences> _prefs = SharedPreferences.getInstance();
 String? apiToken;
 late int userId;
  var date = new DateFormat('yyyy-MM-dd').format(DateTime.now());
  var _date = '';
  var _noDataFound = 'Loading...';

  @override
  void initState() {
    super.initState();
    apiCallForGetMeeting();
  }

  @override
  void dispose() {
    super.dispose();
  }

  Future apiCallForGetMeeting() async {
    final SharedPreferences prefs = await _prefs;
    if (prefs.getBool(SP_IS_LOGIN_BOOL) != null) {
       userId = prefs.getInt(SP_ID)!;
      apiToken = prefs.getString(SP_API_TOKEN)!;
    }
    var map = new Map<String, dynamic>();
    map["appType"] = Platform.operatingSystem.toUpperCase();
    map["userId"] = userId.toString();
    map["api_token"] = apiToken;
    if (_date.isEmpty) {
      map['meetingDate'] = date;
    } else {
      map['meetingDate'] = _date;
    }
    try {
      _noDataFound = 'Loading...';
      _networkUtil.post(apiMeetingList, body: map).then((dynamic res) {
        _noDataFound = noDataFound;
        try {
          AppLog.showLog(res.toString());
          _meetingListApiCallBack = MeetingListApiCallBack.fromJson(res);
          if (_meetingListApiCallBack!.status == unAuthorised) {
            logout(context);
          } else if (!_meetingListApiCallBack!.success) {
            showBottomToast(_meetingListApiCallBack!.message);
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

  Future _buttonTapped() async {
    Map results = await Navigator.of(context).push(new MaterialPageRoute(
      builder: (BuildContext context) {
        return AddMeeting(
          scaffoldKey: widget.scaffoldKey,
          title: 'Add Meeting',
        );
      },
    ));

    if (results.containsKey('reload')) {
      apiCallForGetMeeting();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: appBackgroundDashboard,
      body: Stack(
        children: <Widget>[
          CustomHeader(scaffoldKey: widget.scaffoldKey, title: widget.title),
          // getCustomHeader(),
          Container(
            margin: EdgeInsets.only(top: ScreenUtil().setSp(90)),
            child: //(_meetingListApiCallBack!.items.length > 0)
            (_meetingListApiCallBack?.items.isNotEmpty ?? false)
                ? ListView.builder(
                    itemBuilder: (BuildContext context, int index) {
                      return Padding(
                        padding: EdgeInsets.only(
                            left: ScreenUtil().setSp(10),
                            right: ScreenUtil().setSp(10),
                            top: ScreenUtil().setSp(5),
                            bottom: ScreenUtil().setSp(5)),
                        child: GestureDetector(
                          child: Card(
                            shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(8.0)),
                            elevation: 5,
                            child: Column(
                              children: <Widget>[
                                Card(
                                  shape: RoundedRectangleBorder(
                                    borderRadius: const BorderRadius.only(
                                      topLeft: Radius.circular(8.0),
                                      topRight: Radius.circular(8.0),
                                    ),
                                  ),
                                  margin: EdgeInsets.all(0.0),
                                  color: appPrimaryColor,
                                  child: Padding(
                                    padding:
                                        EdgeInsets.all(ScreenUtil().setSp(8)),
                                    child: Row(
                                      children: <Widget>[
                                        Flexible(
                                            flex: 3,
                                            fit: FlexFit.tight,
                                            child: Row(
                                              children: <Widget>[
                                                Icon(
                                                  Icons.domain,
                                                  color: Colors.white,
                                                  size: 20.0,
                                                ),
                                                SizedBox(
                                                  width: 5.0,
                                                ),
                                                Text(
                                                  _meetingListApiCallBack!
                                                      .items[index].clientName,
                                                  style: TextStyle(
                                                      color: Colors.white),
                                                ),
                                              ],
                                            )),
                                        Container(
                                          width: 1,
                                          height: 30.0,
                                          color: Colors.grey[300],
                                        ),
                                        SizedBox(
                                          width: 5.0,
                                        ),
                                        Flexible(
                                            flex: 3,
                                            fit: FlexFit.tight,
                                            child: Row(
                                              children: <Widget>[
                                                Icon(
                                                  Icons.calendar_today,
                                                  color: Colors.white,
                                                  size: 20.0,
                                                ),
                                                SizedBox(
                                                  width: 5.0,
                                                ),
                                                Text(
                                                  '${DateTime.parse("${_meetingListApiCallBack!.items[index].meetingDate}").toLocal().day.toString().padLeft(2, '0')}/'
                                                  '${DateTime.parse("${_meetingListApiCallBack!.items[index].meetingDate}").toLocal().month.toString().padLeft(2, '0')}/'
                                                  '${DateTime.parse("${_meetingListApiCallBack!.items[index].meetingDate}").toLocal().year.toString().padLeft(2, '0')}',
                                                  style: TextStyle(
                                                      color: Colors.white),
                                                ),
                                              ],
                                            )),
                                      ],
                                    ),
                                  ),
                                ),
                                Padding(
                                  padding: EdgeInsets.only(
                                      left: ScreenUtil().setSp(8),
                                      right: ScreenUtil().setSp(8),
                                      top: ScreenUtil().setSp(8)),
                                  child: Row(
                                    children: <Widget>[
                                      Icon(
                                        Icons.bookmark,
                                        size: 15,
                                        color: colorTextDarkBlue,
                                      ),
                                      Text(
                                        ' ${_meetingListApiCallBack!.items[index].title}',
                                        maxLines: null,
                                      ),
                                    ],
                                  ),
                                ),
                                Padding(
                                  padding:
                                      EdgeInsets.all(ScreenUtil().setSp(8)),
                                  child: Container(
                                    width: double.infinity,
                                    child: Row(
                                      children: <Widget>[
                                        Flexible(
                                            flex: 3,
                                            fit: FlexFit.tight,
                                            child: Row(
                                              children: <Widget>[
                                                Icon(
                                                  Icons.person,
                                                  size: 15,
                                                  color: colorTextDarkBlue,
                                                ),
                                                Text(
                                                  ' ${_meetingListApiCallBack!.items[index].contactPerson}',
                                                  style: TextStyle(
                                                      color: Colors.black,
                                                      fontSize: ScreenUtil()
                                                          .setSp(10)),
                                                ),
                                              ],
                                            )),
                                        SizedBox(
                                          width: 5.0,
                                        ),
                                        Flexible(
                                            flex: 3,
                                            fit: FlexFit.tight,
                                            child: Row(
                                              children: <Widget>[
                                                Icon(
                                                  Icons.call,
                                                  size: 15,
                                                  color: colorTextDarkBlue,
                                                ),
                                                SizedBox(
                                                  width: 5.0,
                                                ),
                                                InkWell(
                                                  child: Text(
                                                    '${_meetingListApiCallBack!.items[index].clientContactNo}',
                                                    style: TextStyle(
                                                        color: Colors.black,
                                                        fontSize: ScreenUtil()
                                                            .setSp(10)),
                                                  ),
                                                  onTap: () {
                                                    launch(
                                                        "tel:${_meetingListApiCallBack!.items[index].clientContactNo}");
                                                  },
                                                ),
                                              ],
                                            )),
                                      ],
                                    ),
                                  ),
                                ),
                                Padding(
                                  padding: EdgeInsets.only(
                                      left: ScreenUtil().setSp(8),
                                      right: ScreenUtil().setSp(8),
                                      bottom: ScreenUtil().setSp(8)),
                                  child: Container(
                                    width: double.infinity,
                                    child: Row(
                                      children: <Widget>[
                                        Flexible(
                                            flex: 3,
                                            fit: FlexFit.tight,
                                            child: Row(
                                              children: <Widget>[
                                                Icon(
                                                  Icons.mail,
                                                  size: 15,
                                                  color: colorTextDarkBlue,
                                                ),
                                                InkWell(
                                                  child: Text(
                                                    ' ${_meetingListApiCallBack!.items[index].clientEmail}',
                                                    style: TextStyle(
                                                        color: Colors.black,
                                                        fontSize: ScreenUtil()
                                                            .setSp(10)),
                                                  ),
                                                  onTap: () {
                                                    launch(
                                                        'mailto:${_meetingListApiCallBack!.items[index].clientEmail}');
                                                  },
                                                ),
                                              ],
                                            )),
                                        SizedBox(
                                          width: 5.0,
                                        ),
                                        Flexible(
                                            flex: 3,
                                            fit: FlexFit.tight,
                                            child: Row(
                                              children: <Widget>[],
                                            )),
                                      ],
                                    ),
                                  ),
                                ),
                                Padding(
                                  padding: EdgeInsets.only(
                                      left: ScreenUtil().setSp(8),
                                      right: ScreenUtil().setSp(8),
                                      bottom: ScreenUtil().setSp(8)),
                                  child: Container(
                                    width: double.infinity,
                                    child: Row(
                                      children: <Widget>[
                                        Flexible(
                                            flex: 3,
                                            fit: FlexFit.tight,
                                            child: Row(
                                              children: <Widget>[
                                                Icon(
                                                  Icons.timer,
                                                  size: 15,
                                                  color: colorTextDarkBlue,
                                                ),
                                                Text(' Start : '),
                                                Text(
                                                  //'Meeting start '
                                                  '${DateTime.parse("${_meetingListApiCallBack!.items[index].meetingStart}").toLocal().hour.toString().padLeft(2, '0')}:'
                                                  '${DateTime.parse("${_meetingListApiCallBack!.items[index].meetingStart}").toLocal().minute.toString().padLeft(2, '0')}:'
                                                  '${DateTime.parse("${_meetingListApiCallBack!.items[index].meetingStart}").toLocal().second.toString().padLeft(2, '0')}',
//                                                  'In Time  Hours ',
                                                  style: TextStyle(
                                                      color: Colors.black,
                                                      fontSize: ScreenUtil()
                                                          .setSp(10)),
                                                ),
                                              ],
                                            )),
                                        SizedBox(
                                          width: 5.0,
                                        ),
                                        Flexible(
                                            flex: 3,
                                            fit: FlexFit.tight,
                                            child: Row(
                                              children: <Widget>[
                                                Icon(
                                                  Icons.timer,
                                                  size: 15,
                                                  color: colorTextDarkBlue,
                                                ),
                                                Text(' End : '),
                                                Text(
                                                  //'Meeting End '
                                                  '${DateTime.parse("${_meetingListApiCallBack!.items[index].meetingEnd}").hour.toString().padLeft(2, '0')}:'
                                                  '${DateTime.parse("${_meetingListApiCallBack!.items[index].meetingEnd}").minute.toString().padLeft(2, '0')}:'
                                                  '${DateTime.parse("${_meetingListApiCallBack!.items[index].meetingEnd}").second.toString().padLeft(2, '0')}',
                                                  style: TextStyle(
                                                      color: Colors.black,
                                                      fontSize: ScreenUtil()
                                                          .setSp(10)),
                                                ),
                                              ],
                                            )),
                                      ],
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      );
                    },
                    itemCount: _meetingListApiCallBack!.items.length,
                  )
                : Center(
                    child: Text(_noDataFound),
                  ),
          )
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          _buttonTapped();
        },
        child: Icon(Icons.add, color: Colors.white),
        backgroundColor: colorTextDarkBlue,
      ),
    );
  }

  Widget getCustomHeader() {
    return PreferredSize(
      preferredSize:
          Size(MediaQuery.of(context).size.width, ScreenUtil().setSp(250)),
      child: Container(
        width: MediaQuery.of(context).size.width,
        height: ScreenUtil().setSp(120),
        child: ClipRRect(
          borderRadius: BorderRadius.only(
            bottomLeft: Radius.circular(50),
          ),
          child: Container(
            color: appColorFour,
            child: Column(
              children: <Widget>[
                Container(
                  margin: EdgeInsets.fromLTRB(ScreenUtil().setSp(10),
                      ScreenUtil().setSp(50), ScreenUtil().setSp(10), 0),
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
                          CommunityMaterialIcons.filter,
                          size: ScreenUtil().setSp(30),
                          color: Colors.white,
                        ),
                        onTap: () {
                          _showFilterDialog();
                        },
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

  Future _selectDate() async {
    DateTime? _picked = await showDatePicker(
        context: context,
        initialDate: new DateTime.now(),
        firstDate: new DateTime(2016),
        lastDate: new DateTime(2025));
    setState(() {
      _date = new DateFormat('yyyy-MM-dd').format(_picked!);
      Navigator.of(context).pop();
      _showFilterDialog();
    });
  }

  void _showFilterDialog() {
    showDialog(
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
                        child: Text(
                          'Select date to filter.',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                              fontSize: ScreenUtil().setSp(16),
                              fontWeight: FontWeight.bold,
                              color: appWhiteColor),
                        )),
                    Padding(
                      padding: EdgeInsets.only(
                          left: ScreenUtil().setSp(20),
                          top: ScreenUtil().setSp(20)),
                      child: Text('Select Date : '),
                    ),
                    Container(
                      padding: EdgeInsets.only(
                          left: ScreenUtil().setSp(20),
                          right: ScreenUtil().setSp(20)),
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.grey[100],
                            elevation: 0,
                            shape: RoundedRectangleBorder(
                                borderRadius: new BorderRadius.circular(5)),
                            side: BorderSide(color: Colors.black)),
                        child: Row(
                          children: <Widget>[
                            Icon(
                              Icons.calendar_today,
                              color: Colors.black,
                              size: ScreenUtil().setSp(15),
                            ),
                            SizedBox(
                              width: ScreenUtil().setSp(5),
                            ),
                            Text(_date),
                          ],
                        ),
                        onPressed: () {
                          _selectDate();
                        },
                      ),
                    ),
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
                          'Submit',
                          style: TextStyle(
                              color: appWhiteColor,
                              fontSize: ScreenUtil().setSp(15),
                              fontWeight: FontWeight.bold),
                        ),
                        onPressed: () {
                          setState(() {
                            if (_date.isEmpty) {
                              showCenterToast('Please Selete Date');
                            } else {
                              apiCallForGetMeeting();
                              Navigator.of(context).pop();
                            }
                          });
                        },
                      ),
                    ),
                  ],
                ),
              ),
            );
          });
        });
  }
}

class MeetingListApiCallBack {
  String current_time;
  List<Item> items;
  String message;
  int status;
  bool success;
  int total_count;

  MeetingListApiCallBack(
      {required this.current_time,
     required this.items,
     required this.message,
     required this.status,
     required this.success,
     required this.total_count});

  factory MeetingListApiCallBack.fromJson(Map<String, dynamic> json) {
    return MeetingListApiCallBack(
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
    data['items'] = this.items.map((v) => v.toJson()).toList();
      return data;
  }
}

class Item {
  String attachment;
  String attachmentPath;
  String clientContactNo;
  String clientEmail;
  String clientName;
  String contactPerson;
  String created_at;
  String description;
  int id;
  int isdeleted;
  String meetingDate;
  String meetingEnd;
  String meetingStart;
  String nextMeetingDate;
  int sendCopyToClient;
  int status;
  String title;
  String updated_at;
  int userId;

  Item(
      {required this.attachment,
     required this.attachmentPath,
     required this.clientContactNo,
     required this.clientEmail,
     required this.clientName,
     required this.contactPerson,
     required this.created_at,
     required this.description,
     required this.id,
     required this.isdeleted,
     required this.meetingDate,
     required this.meetingEnd,
     required this.meetingStart,
     required this.nextMeetingDate,
     required this.sendCopyToClient,
     required this.status,
     required this.title,
     required this.updated_at,
     required this.userId});

  factory Item.fromJson(Map<String, dynamic> json) {
    return Item(
      attachment: json['attachment'],
      attachmentPath: json['attachmentPath'],
      clientContactNo: json['clientContactNo'],
      clientEmail: json['clientEmail'],
      clientName: json['clientName'],
      contactPerson: json['contactPerson'],
      created_at: json['created_at'],
      description: json['description'],
      id: json['id'],
      isdeleted: json['isdeleted'],
      meetingDate: json['meetingDate'],
      meetingEnd: json['meetingEnd'],
      meetingStart: json['meetingStart'],
      nextMeetingDate: json['nextMeetingDate'],
      sendCopyToClient: json['sendCopyToClient'],
      status: json['status'],
      title: json['title'],
      updated_at: json['updated_at'],
      userId: json['userId'],
    );
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['attachment'] = this.attachment;
    data['attachmentPath'] = this.attachmentPath;
    data['clientContactNo'] = this.clientContactNo;
    data['clientEmail'] = this.clientEmail;
    data['clientName'] = this.clientName;
    data['contactPerson'] = this.contactPerson;
    data['created_at'] = this.created_at;
    data['description'] = this.description;
    data['id'] = this.id;
    data['isdeleted'] = this.isdeleted;
    data['meetingDate'] = this.meetingDate;
    data['meetingEnd'] = this.meetingEnd;
    data['meetingStart'] = this.meetingStart;
    data['nextMeetingDate'] = this.nextMeetingDate;
    data['sendCopyToClient'] = this.sendCopyToClient;
    data['status'] = this.status;
    data['title'] = this.title;
    data['updated_at'] = this.updated_at;
    data['userId'] = this.userId;
    return data;
  }
}
