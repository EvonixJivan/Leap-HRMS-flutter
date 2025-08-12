import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:hrms/app/mainApp/task_manager/team_lead/insert_task_call_back.dart';
import 'package:hrms/app/uiComponent/custom_header.dart';
import 'package:hrms/appUtil/app_providers.dart';
import 'package:hrms/appUtil/app_util_config.dart';
import 'package:hrms/appUtil/network_util.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

class Comments extends StatefulWidget {
  var scaffoldKey;
  var title;
  int id;
  String client;
  String project;
  String task;
  String minutes;
  String time;

  Comments(
      {Key? key,
      required this.scaffoldKey,
      required this.title,
      required this.id,
      required this.client,
      required this.project,
      required this.task,
      required this.minutes,
      required this.time})
      : super(key: key);

  @override
  State<StatefulWidget> createState() {
    return CommentsState();
  }
}

class CommentsState extends State<Comments> {
  Future<SharedPreferences> _prefs = SharedPreferences.getInstance();
  NetworkUtil _networkUtil = NetworkUtil();
  GetCommentCallback? _getCommentCallback;
  InsertTaskCallback? _insertTaskCallback;
  var now = new DateTime.now();
 String? formatted;
  var formatter = new DateFormat('yyyy-MM-dd hh:mm a');
  late int userId;
  String _apiToken = '';
  var _noDataFound = 'Loading...';
  TextEditingController commentController = TextEditingController();

  @override
  void initState() {
    super.initState();
    formatted = formatter.format(now);
    apiCallForGetCommentList();
  }

  @override
  Widget build(BuildContext context) {


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
                    margin: EdgeInsets.only(
                        top: ScreenUtil().setSp(10),
                        left: ScreenUtil().setSp(10),
                        right: ScreenUtil().setSp(10)),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: <Widget>[
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
                                    ' ${widget.project}',
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
                                    ' ${widget.client}',
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
                          padding: const EdgeInsets.only(
                              left: 8, right: 8, top: 8, bottom: 8),
                          child: Text(
                            widget.task,
                            style: TextStyle(fontSize: 14.0),
                            maxLines: null,
                          ),
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
                                    Icons.access_time,
                                    color: Colors.deepOrange,
                                    size: 15,
                                  ),
                                  Text(
                                    '  ${widget.minutes}:00',
                                    style: TextStyle(
                                      fontSize: 14.0,
                                    ),
                                    maxLines: 2,
                                  )
                                ],
                              ),
                            ),
                            Text(
                              DateFormat('hh:mm a, dd MMM').format(
                                DateTime.parse(widget.time),
                              ),
                              style: dateTimeTextStyle,
                            ),
                            SizedBox(
                              width: 8,
                            )
                          ],
                        ),
                      ],
                    ),
                  ),
                  Expanded(
                    child: Container(
                        child: (_getCommentCallback?.items?.isNotEmpty ?? false)
                            ? buildListView()
                            : Container(
                                child: Center(
                                  child: Text(_noDataFound),
                                ),
                              )),
                  ),
                  Card(
                    elevation: 5,
                    margin: EdgeInsets.only(
                        top: ScreenUtil().setSp(10),
                        left: ScreenUtil().setSp(10),
                        right: ScreenUtil().setSp(10),
                        bottom: ScreenUtil().setSp(10)),
                    child: Row(
                      children: <Widget>[
                        Expanded(
                            child: Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: TextField(
                            controller: commentController,
                            decoration: InputDecoration(
                              hintText: 'Add comment',
                              contentPadding: EdgeInsets.only(
                                  left: 8, right: 8, top: 2, bottom: 2),
                              border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(10.0)),
                            ),
                            maxLines: null,
                          ),
                        )),
                        IconButton(
                          icon: Icon(
                            Icons.send,
                            color: Colors.deepOrange,
                            size: 25,
                          ),
                          onPressed: () {
                            apiCallForPostComment();
                          },
                        )
                      ],
                    ),
                  )
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  void apiCallForGetCommentList() async {
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
      map['taskId'] = widget.id.toString();

      _noDataFound = 'Loading...';
      _networkUtil.post(apiTaskCommentsGet, body: map).then((dynamic res) {
        _noDataFound = noDataFound;
        try {
          _getCommentCallback = GetCommentCallback.fromJson(res);
          if (_getCommentCallback!.status == unAuthorised) {
            logout(context);
          } else if (!_getCommentCallback!.success!) {
            showBottomToast(_getCommentCallback!.message ?? "");
          }
        } catch (ex) {
          _getCommentCallback = null;
          setState(() {});
           Provider.of<ApiLoader>(context, listen: false).hide();
          print(ex);
        }
        AppLog.showLog(res.toString());
        print(res.toString());
        // Provider.of<ApiLoader>(context).hide();
        Provider.of<ApiLoader>(context, listen: false).hide();
          setState(() {});
      });
    } catch (e) {
      print(e.toString());
      _noDataFound = noDataFound;
    }
  }

  void apiCallForPostComment() async {
    BuildContext _context = context;
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
      map['taskId'] = widget.id.toString();
      map['comment'] = commentController.text;
      map['deviceDateTime'] = DateFormat('yyyy-MM-dd hh:mm a').format(DateTime.now().toUtc());
      //formatted;
      map['isSeen'] = '0';
      showLoader(_context);
      _noDataFound = 'Loading...';
      _networkUtil.post(apiTaskCommentsInsert, body: map).then((dynamic res) {
        _noDataFound = noDataFound;
        _getCommentCallback = null;
        Navigator.pop(_context);
        try {
          _insertTaskCallback = InsertTaskCallback.fromJson(res);
          if (_insertTaskCallback!.status == unAuthorised) {
            logout(context);
          } else if (!_insertTaskCallback!.success) {
            showBottomToast(_insertTaskCallback!.message ?? "");
          }
          apiCallForGetCommentList();
          commentController.text = '';

        } catch (ex) {
          setState(() {});
          print(ex);
        }
        AppLog.showLog(res.toString());
        print(res.toString());
        if (_insertTaskCallback!.success) {
          setState(() {});
        }
      });
    } catch (e) {
      print(e.toString());
      _noDataFound = noDataFound;
    }
  }

  Widget cardOne(int index) {
    return Padding(
      padding: EdgeInsets.only(left: 8, right: 100, top: 4, bottom: 4),
      child: Container(
        width: MediaQuery.of(context).size.width - 100,
        child: Card(
          elevation: 5,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Padding(
                padding: EdgeInsets.all(8.0),
                child: Row(
                  children: <Widget>[
                    Icon(
                      Icons.person,
                      color: Colors.deepOrange,
                      size: 15,
                    ),
                    Text(_getCommentCallback!.items![index].userName ?? ""),
                  ],
                ),
              ),
              Padding(
                padding: EdgeInsets.only(left: 8, right: 8, bottom: 8),
                child: Text(
                  _getCommentCallback!.items![index].comment ?? "",
                  maxLines: null,
                  style: chatText,
                ),
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: <Widget>[
                  Text('${DateFormat('hh:mm a, MMM yyyy').format(DateFormat("yyyy-MM-dd HH:mm:ss").parse(_getCommentCallback!.items![index].createdAt ?? "", true).toLocal())}', style: dateTimeTextStyle,),
                  // Text(
                  //   DateFormat('hh:mm a, dd MMM').format(DateTime.parse(
                  //       _getCommentCallback!.items[index].createdAt)),
                  //   style: dateTimeTextStyle,
                  // ),
                  SizedBox(
                    width: 8,
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget cardTwo(int index) {
    return Padding(
      padding: EdgeInsets.only(left: 100, right: 8, top: 4, bottom: 4),
      child: Container(
        width: MediaQuery.of(context).size.width - 100,
        child: Card(
          elevation: 5,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Padding(
                padding: EdgeInsets.only(left: 8, right: 8, bottom: 8, top: 8),
                child: Text(
                  _getCommentCallback!.items![index].comment ?? "",
                  maxLines: null,
                  style: chatText,
                ),
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: <Widget>[
                  Text('${DateFormat('hh:mm a, MMM yyyy').format(DateFormat("yyyy-MM-dd HH:mm:ss").parse(_getCommentCallback!.items![index].createdAt ?? "", true).toLocal())}', style: dateTimeTextStyle,),
                  // Text(
                  //   DateFormat('hh:mm a, dd MMM').format(DateTime.parse(
                  //       _getCommentCallback!.items[index].createdAt)),
                  //   style: dateTimeTextStyle,
                  // ),
                  SizedBox(
                    width: 8,
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget buildListView() {
    return ListView.builder(
        itemCount: _getCommentCallback!.items!.length,
        itemBuilder: (BuildContext context, int index) {
          return (_getCommentCallback!.items![index].userId == userId)
              ? cardTwo(index)
              : cardOne(index);
        });
  }
}

class GetCommentCallback {
  int? totalCount;
  bool? success;
  List<Items>? items;
 String? message;
  int? status;
 String? currentTime;
 String? currentUtcTime;

  GetCommentCallback(
      {required this.totalCount,
     required this.success,
     required this.items,
     required this.message,
     required this.status,
     required this.currentTime,
     required this.currentUtcTime});

  GetCommentCallback.fromJson(Map<String, dynamic> json) {
  totalCount = json['total_count'];
  success = json['success'];

  if (json['items'] != null) {
    items = <Items>[]; // ✅ Initialize the list
    json['items'].forEach((v) {
      items!.add(Items.fromJson(v));
    });
  }

  message = json['message'];
  status = json['status'];
  currentTime = json['current_time'];
  currentUtcTime = json['current_utc_time'];
}


  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['total_count'] = this.totalCount;
    data['success'] = this.success;
    data['items'] = this.items!.map((v) => v.toJson()).toList();
      data['message'] = this.message;
    data['status'] = this.status;
    data['current_time'] = this.currentTime;
    data['current_utc_time'] = this.currentUtcTime;
    return data;
  }
}

class Items {
  int? id;
  int? taskId;
  int? userId;
 String? comment;
 String? deviceDateTime;
 int? isSeen;
  int? isdeleted;
 String? createdAt;
 String? updatedAt;
 String? userName;

  Items(
      {required this.id,
     required this.taskId,
     required this.userId,
     required this.comment,
     required this.deviceDateTime,
     required this.isSeen,
     required this.isdeleted,
     required this.createdAt,
     required this.updatedAt,
     required this.userName});

  Items.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    taskId = json['taskId'];
    userId = json['userId'];
    comment = json['comment'];
    deviceDateTime = json['deviceDateTime'];
    isSeen = json['isSeen'];
    isdeleted = json['isdeleted'];
    createdAt = json['created_at'];
    updatedAt = json['updated_at'];
    userName = json['userName'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['id'] = this.id;
    data['taskId'] = this.taskId;
    data['userId'] = this.userId;
    data['comment'] = this.comment;
    data['deviceDateTime'] = this.deviceDateTime;
    data['isSeen'] = this.isSeen;
    data['isdeleted'] = this.isdeleted;
    data['created_at'] = this.createdAt;
    data['updated_at'] = this.updatedAt;
    data['userName'] = this.userName;
    return data;
  }
}
