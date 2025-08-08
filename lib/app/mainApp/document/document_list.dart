import 'dart:async';
import 'dart:convert';
import 'dart:developer';
import 'dart:io';
import 'dart:isolate';
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:hrms/app/mainApp/document/AddDocument.dart';
import 'package:hrms/app/mainApp/document/document_category_apicallback.dart';
import 'package:hrms/appUtil/network_util.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../../appUtil/app_util_config.dart';
import '../../uiComponent/custom_header.dart';
import 'package:intl/intl.dart';
import 'package:flutter_downloader/flutter_downloader.dart';
import 'package:path_provider/path_provider.dart';
import 'package:dio/dio.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:open_file/open_file.dart';
import 'package:path/path.dart' as path;

class DocumentList extends StatefulWidget {
  var scaffoldKey;
  var title;

  DocumentList({Key? key, required this.scaffoldKey, required this.title})
      : super(key: key);

  @override
  _DocumentListState createState() {
    return _DocumentListState();
  }
}

class _DocumentListState extends State<DocumentList> {
  int progress = 0;

  ReceivePort _receivePort = ReceivePort();

  NetworkUtil _networkUtil = NetworkUtil();
  Future<SharedPreferences> _prefs = SharedPreferences.getInstance();
  final GlobalKey<ScaffoldState> _scaffoldKey = new GlobalKey<ScaffoldState>();
  final GlobalKey<RefreshIndicatorState> _refreshIndicatorKey =
      new GlobalKey<RefreshIndicatorState>();
  DocumentCategoryApiCallBack? documentCategoryApiCallBack;
  DocumentTypeApiCallBack? _documentTypeApiCallBack;
  TodoListApiCallBack? _assignmentListModel;
  String? _docCategoryDropdownValue;
  String? _docSubCategoryDropdownValue;
  String? apiToken, selectedDocName;
  late List subCat;
  int? userId, roleId, companyId, docType, accessLevel;
  var _noDataFound = 'Loading...';
  var _isVisible = false;
  final Dio _dio = Dio();
  String _progress = "-";
  late FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin;
  final Permission _permission = Permission.location;
  PermissionStatus _permissionStatus = PermissionStatus.denied;
  String _fileUrl = "";

  static downloadingCallback(id, status, progress) {
    ///Looking up for a send port
    SendPort? sendPort = IsolateNameServer.lookupPortByName("downloading");

    ///ssending the data
    sendPort!.send([id, status, progress]);
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
  void initState() {
    // TODO: implement initState
    super.initState();
    // WidgetsFlutterBinding.ensureInitialized();
    // FlutterDownloader.initialize(
    //     debug: true // optional: set false to disable printing logs to console
    // );
    setupNotification();

    ///register a send port for the other isolates
    IsolateNameServer.registerPortWithName(
        _receivePort.sendPort, "downloading");

    ///Listening for the data is comming other isolataes
    _receivePort.listen((message) {
      setState(() {
        progress = message[2];
      });

      print(progress + 1110);
    });

    FlutterDownloader.registerCallback(downloadingCallback);
    apiCallForDocumentCategory();
  }

  setupNotification() async {
    flutterLocalNotificationsPlugin = FlutterLocalNotificationsPlugin();

    const android = AndroidInitializationSettings('@mipmap/ic_launcher');

    const iOS = DarwinInitializationSettings(
      requestAlertPermission: true,
      requestBadgePermission: true,
      requestSoundPermission: true,
    );

    const initSettings = InitializationSettings(android: android, iOS: iOS);

    await flutterLocalNotificationsPlugin.initialize(
      initSettings,
      onDidReceiveNotificationResponse: (NotificationResponse response) {
        _onSelectNotification(response.payload!);
      },
    );
  }

  Future<void> _onSelectNotification(String json) async {
    final obj = jsonDecode(json);

    if (obj['isSuccess']) {
      OpenFile.open(obj['filePath']);
    } else {
      showDialog(
        context: context,
        builder: (_) => AlertDialog(
          title: Text('Error'),
          content: Text('${obj['error']}'),
        ),
      );
    }
  }

  Future<void> _showNotification(Map<String, dynamic> downloadStatus) async {
    const android = AndroidNotificationDetails(
      'channel_id',
      'channel_name',
      channelDescription: 'channel_description',
      priority: Priority.high,
      importance: Importance.max,
    );

    const iOS = DarwinNotificationDetails();

    const platform = NotificationDetails(android: android, iOS: iOS);

    final jsonPayload = jsonEncode(downloadStatus);
    final isSuccess = downloadStatus['isSuccess'] == true;

    await flutterLocalNotificationsPlugin.show(
      0, // notification ID
      isSuccess ? 'Success' : 'Failure',
      isSuccess
          ? 'File has been downloaded successfully!'
          : 'There was an error while downloading the file.',
      platform,
      payload: jsonPayload,
    );
  }

  Future<Directory?> _getDownloadDirectory() async {
    if (Platform.isAndroid) {
      //  var DownloadsPathProvider;
      return await getDownloadsDirectory();
    } else {
      // in this example we are using only Android and iOS so I can assume
      // that you are not trying it for other platforms and the if statement
      // for iOS is unnecessary
      // iOS directory visible to user
      return await getApplicationDocumentsDirectory();
    }
  }

  void _onReceiveProgress(int received, int total) {
    if (total != -1) {
      setState(() {
        _progress = (received / total * 100).toStringAsFixed(0) + "%";
      });
    }
  }

  Future<void> _startDownload(String savePath, String _pathFile) async {
    Map<String, dynamic> result = {
      'isSuccess': false,
      'filePath': null,
      'error': null,
    };

    try {
      final response = await _dio.download(_pathFile, savePath,
          onReceiveProgress: _onReceiveProgress);
      result['isSuccess'] = response.statusCode == 200;
      result['filePath'] = savePath;
    } catch (ex) {
      result['error'] = ex.toString();
    } finally {
      await _showNotification(result);
    }
  }

  Future<void> _download(String _fileName, String pathFile) async {
    final dir = await _getDownloadDirectory();
    // final isPermissionStatusGranted = await _requestPermissions();

    // if (isPermissionStatusGranted) {
    final savePath = path.join(dir!.path, pathFile);
    await _startDownload(savePath, pathFile);
    // } else {
    //   // handle the scenario when user declines the permissions
    // }
  }

  @override
  void dispose() {
    super.dispose();
  }

  Future apiCallForDocumentCategory() async {
    final SharedPreferences prefs = await _prefs;
    if (prefs.getBool(SP_IS_LOGIN_BOOL) != null) {
      userId = prefs.getInt(SP_ID)!;
      apiToken = prefs.getString(SP_API_TOKEN)!;
      roleId = prefs.getInt(SP_ROLE)!;
      companyId = prefs.getInt(SP_COMPANY_ID)!;
    }
    var map = new Map<String, dynamic>();
    map["appType"] = Platform.operatingSystem.toUpperCase();
    map["id"] = userId.toString();
    map["api_token"] = apiToken;
    map['role_id'] = roleId.toString();
    map['company_id'] = companyId.toString();
    print(map);
    try {
      _noDataFound = 'Loading...';
      _networkUtil.post(apiGetDocumentCategory, body: map).then((dynamic res) {
        _noDataFound = noDataFound;
        try {
          AppLog.showLog(res.toString());
          documentCategoryApiCallBack =
              DocumentCategoryApiCallBack.fromJson(res);
          if (documentCategoryApiCallBack!.status == unAuthorised) {
            logout(context);
          } else if (!documentCategoryApiCallBack!.success!) {
            showBottomToast(documentCategoryApiCallBack!.message ?? "");
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

  Future apiCallForDocumentList(int _accessLevel) async {
    final SharedPreferences prefs = await _prefs;
    if (prefs.getBool(SP_IS_LOGIN_BOOL) != null) {
      userId = prefs.getInt(SP_ID)!;
      apiToken = prefs.getString(SP_API_TOKEN)!;
      roleId = prefs.getInt(SP_ROLE)!;
      companyId = prefs.getInt(SP_COMPANY_ID)!;
    }
    var map = new Map<String, dynamic>();
    map["appType"] = Platform.operatingSystem.toUpperCase();
    map["user_id"] = userId.toString();
    map["api_token"] = apiToken;
    map['role_id'] = roleId.toString();
    map['company_id'] = companyId.toString();
    map['documentType'] = _docSubCategoryDropdownValue;
    map['accessLevel'] = _accessLevel.toString();
    print(map);
    try {
      _noDataFound = 'Loading...';
      _networkUtil
          .post(apiOrganizationDocumentGet, body: map)
          .then((dynamic res) {
        _noDataFound = noDataFound;
        try {
          AppLog.showLog(res.toString());
          _assignmentListModel = TodoListApiCallBack.fromJson(res);
          print(_assignmentListModel.toString());
          if (_assignmentListModel!.status == unAuthorised) {
            logout(context);
          } else if (_assignmentListModel!.message.isNotEmpty) {
            //   showBottomToast(_assignmentListModel.message);
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

/*
  Future apiCallForDocumentList() async {
    final SharedPreferences prefs = await _prefs;
    if (prefs.getBool(SP_IS_LOGIN_BOOL) != null) {
       userId = prefs.getInt(SP_ID)!;
      apiToken = prefs.getString(SP_API_TOKEN)!;
    }
    var map = new Map<String, dynamic>();
    map["appType"] = Platform.operatingSystem.toUpperCase();
    map["userId"] = userId.toString();
    map["api_token"] = apiToken;
    map['documentType'] = _docCategoryDropdownValue;

    print(map);
    try {
      _noDataFound = 'Loading...';
      _networkUtil.post(apiDocumentGet, body: map).then((dynamic res) {
        _noDataFound = noDataFound;

        try {
          AppLog.showLog(res.toString());
          documentListApiCallBack = DocumentListApiCallBack.fromJson(res);
          if (documentListApiCallBack!.status == unAuthorised) {
            logout(context);
          }
          if (!documentListApiCallBack!.success) {
            showBottomToast(documentListApiCallBack!.message);
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
*/

  @override
  Widget build(BuildContext context) {
    final TextTheme textTheme = Theme.of(context).textTheme;

    final documentCategoryType = Padding(
      padding: EdgeInsets.only(
        left: ScreenUtil().setSp(10),
        top: ScreenUtil().setSp(10),
        right: ScreenUtil().setSp(10),
      ),
      child: Container(
          padding: EdgeInsets.only(left: ScreenUtil().setSp(10)),
          // decoration: BoxDecoration(
          //   color: Colors.grey[100],
          //   border: Border.all(width: 1, color: Colors.grey),
          //   borderRadius: BorderRadius.circular(3),
          // ),
          decoration: BoxDecoration(
            color: tfBackgroundColor,
            border: Border.all(
              width: 1,
              color: tfBackgroundColor,
            ),
            borderRadius: BorderRadius.circular(25.0),
          ),
          child: (documentCategoryApiCallBack?.items?.isNotEmpty ?? false)
              ? DropdownButton(
                  underline: SizedBox(),
                  hint: Text('Select Document Category'),
                  items: documentCategoryApiCallBack!.items!.map((dataItem) {
                    return DropdownMenuItem(
                      child: new Text(dataItem.categoryName ?? ""),
                      value: dataItem.id.toString(),
                    );
                  }).toList(),
                  onChanged: (newValue) {
                    _docSubCategoryDropdownValue = "null";
                    setState(() {
                      _docCategoryDropdownValue = newValue.toString();
                      loadSubTypeList(int.parse(newValue.toString()));
                      print('----------');
                      print(newValue);
                      // print(documentCategoryApiCallBack!.items[int.parse(newValue)-1].subCategory[0].parentId);
                      // apiCallForDocumentType(2);
                    });
                  },
                  isExpanded: true,
                  value: _docCategoryDropdownValue,
                )
              : DropdownButton<String>(
                  hint: Text('Select Task Type'),
                  items: [],
                  onChanged: (String? newValue) {},
                  isExpanded: true,
                  value: _docCategoryDropdownValue,
                )),
    );

final documentSubCategory = Padding(
  padding: EdgeInsets.only(
    left: ScreenUtil().setSp(10),
    top: ScreenUtil().setSp(10),
    right: ScreenUtil().setSp(10),
  ),
  child: Container(
    padding: EdgeInsets.only(left: ScreenUtil().setSp(10)),
    decoration: BoxDecoration(
      color: tfBackgroundColor,
      border: Border.all(
        width: 1,
        color: tfBackgroundColor,
      ),
      borderRadius: BorderRadius.circular(25.0),
    ),
    child: (subCategoryList?.isNotEmpty ?? false)
        ? DropdownButton<String>(
            hint: Text('Select Document Subcategory'),
            items: subCategoryList!.map((dataItem) {
              return DropdownMenuItem<String>(
                value: dataItem.id.toString(),
                child: Text(dataItem.categoryName ?? ""),
              );
            }).toList(),
            value: subCategoryList!
                        .any((item) => item.id.toString() == _docSubCategoryDropdownValue)
                    ? _docSubCategoryDropdownValue
                    : null, // fallback to null if value not found
            onChanged: (String? newValue) {
              setState(() {
                _docSubCategoryDropdownValue = newValue;
                setData(int.parse(newValue!));
              });
            },
            isExpanded: true,
          )
        : DropdownButton<String>(
            hint: Text('No Subcategory Found'),
            items: [], // No items available
            onChanged: null, // disabled
            isExpanded: true,
            value: null,
          ),
  ),
);

    return Scaffold(
        body: Stack(
          children: [
            Container(
              color: appBackgroundDashboard,
              child: Stack(
                children: <Widget>[
                  CustomHeaderWithBack(
                      scaffoldKey: widget.scaffoldKey, title: widget.title),

                  // CustomHeader(
                  //     scaffoldKey: widget.scaffoldKey, title: widget.title),

                  Container(
                    margin: EdgeInsets.only(top: 90.0),
                    child: Column(
                      children: <Widget>[
                        documentCategoryType,
                        documentSubCategory,
                        Expanded(
                          child: RefreshIndicator(
                            key: _refreshIndicatorKey,
                            onRefresh: _handleRefresh,
                            child: (_assignmentListModel?.data!.isNotEmpty ?? false)
                                ? getDocumentListView()
                                : Container(
                                    child: Center(
                                      child: Text(_noDataFound),
                                    ),
                                  ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
        floatingActionButton: new Visibility(
          visible: _isVisible,
          child: new FloatingActionButton(
            onPressed: () async {
              // Navigator.push(
              //     context,
              //     MaterialPageRoute(builder: (context) => AddDocument())
              // );
              Map results =
                  await Navigator.of(context).push(new MaterialPageRoute(
                builder: (BuildContext context) {
                  return AddDocument(
                    scaffoldKey: widget.scaffoldKey,
                    title: 'Add Document',
                    selectedDocName: selectedDocName,
                  );
                },
              ));
              if (results.containsKey('reload')) {
                // apiCallForGetLeave('All');
                apiCallForDocumentList(accessLevel!);
              }
            },
            child: Icon(Icons.add),
            backgroundColor: colorTextDarkBlue,
          ),
        ));
  }

  Widget getDocumentListView() {
    return ListView.builder(
        shrinkWrap: true,
        itemBuilder: (BuildContext context, int index) {
          return Card(
              margin: EdgeInsets.only(
                  left: ScreenUtil().setSp(10),
                  right: ScreenUtil().setSp(10),
                  bottom: 10),
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8.0)),
              elevation: 5,
              child: GestureDetector(
                onTap: () async {
                  final status = await Permission.storage.request();
                  if (_permissionStatus != PermissionStatus.granted) {
                    requestPermission(_permission);
                  } else {
                    // showBottomToast('granted');
                    if (Platform.isAndroid) {
                      _fileUrl =
                          _assignmentListModel!.data![index].documentPath ?? "";
                      _download(
                          _assignmentListModel!.data![index].documentName ?? "",
                          _fileUrl);
                    } else {
                      _download(
                          _assignmentListModel!.data![index].documentName ?? "",
                          _assignmentListModel!.data![index].documentPath ?? "");
                    }
                  }
                },
                child: Container(
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
                            padding: EdgeInsets.all(8),
                            child: Text(
                              _assignmentListModel!.data![index].documentName ??
                                  "",

                              // _assignmentListModel!.data[index].firstName +
                              //     " " +
                              //     _assignmentListModel!.data[index].lastName,
                              textAlign: TextAlign.left,
                              style: TextStyle(
                                  fontSize: ScreenUtil().setSp(15),
                                  fontWeight: FontWeight.bold,
                                  color: Colors.white),
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
                                          Text('File Name : ',
                                              style: TextStyle(
                                                  fontWeight: FontWeight.bold)),
                                          SizedBox(
                                            width: ScreenUtil().setSp(5),
                                          ),
                                          Text(
                                            _assignmentListModel!
                                                    .data![index].documentName ??
                                                "",
                                          ),
                                        ],
                                      ),
                                      Row(
                                        children: <Widget>[
                                          Text('Description : ',
                                              style: TextStyle(
                                                  fontWeight: FontWeight.bold)),
                                          SizedBox(
                                            width: ScreenUtil().setSp(5),
                                          ),
                                          Text(
                                            _assignmentListModel!.data![index]
                                                        .description !=
                                                    null
                                                ? _assignmentListModel!
                                                    .data![index].description!
                                                : "",
                                          ),
                                        ],
                                      ),
                                      SizedBox(
                                        height: ScreenUtil().setSp(5),
                                      ),
                                      Row(
                                        children: <Widget>[
                                          Text('Document Type : ',
                                              style: TextStyle(
                                                  fontWeight: FontWeight.bold)),
                                          SizedBox(
                                            width: ScreenUtil().setSp(5),
                                          ),
                                          Text(
                                            // _assignmentListModel
                                            //     .data[index].documentType,
                                            _assignmentListModel!
                                                .data![index].categoryName,
                                          )
                                        ],
                                      ),
                                      SizedBox(
                                        height: ScreenUtil().setSp(5),
                                      ),
                                      Row(
                                        children: <Widget>[
                                          Icon(
                                            Icons.file_download,
                                            size: ScreenUtil().setSp(20),
                                          ),
                                          SizedBox(
                                            width: ScreenUtil().setSp(5),
                                          ),
                                          Text(
                                            _assignmentListModel!
                                                    .data![index].documentName ??
                                                "",
                                          ),
                                        ],
                                      ),
                                      SizedBox(
                                        height: ScreenUtil().setSp(5),
                                      ),
                                      Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.end,
                                        children: <Widget>[
                                          // Text( DateFormat('yyyy-MM-dd HH:mm:ss').format(DateTime.now().toLocal()),2022-02-01 09:39:45
                                          // Text(_assignmentListModel.data[index].createdAt),
                                          Text(convertDateFormat(
                                              _assignmentListModel!
                                                  .data![index].createdAt,
                                              "yyyy-MM-dd HH:mm:ss",
                                              "MMM dd, yyyy")),
                                        ],
                                      ),
                                      SizedBox(
                                        height: ScreenUtil().setSp(5),
                                      ),
                                    ],
                                  )),
                            ],
                          ),
                        ),
                      ]),
                ),
              ));
        },
        itemCount: _assignmentListModel!.data!.length);
  }

  Future<void> requestPermission(Permission permission) async {
    final status = await permission.request();

    setState(() {
      print(status);
      _permissionStatus = status;
      if (_permissionStatus == PermissionStatus.permanentlyDenied &&
          Platform.isAndroid) {
        showDialog(
            context: context,
            builder: (BuildContext context) {
              return StatefulBuilder(builder: (context, setState) {
                return AlertDialog(
                  contentPadding: EdgeInsets.all(0),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.all(Radius.circular(20))),
                  content: Container(
                    decoration: new BoxDecoration(
                        borderRadius:
                            new BorderRadius.all(Radius.circular(20))),
                    padding: EdgeInsets.only(bottom: 10),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: <Widget>[
                        Container(
                            decoration: new BoxDecoration(
                                color: appPrimaryColor,
                                borderRadius: new BorderRadius.only(
                                    topLeft: Radius.circular(20),
                                    topRight: Radius.circular(20))),
                            padding: EdgeInsets.all(15),
                            child: Text(
                              'Permission',
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
                            'Allow permission to download pdf file. Please enable it from the app setting.',
                            textAlign: TextAlign.center,
                          ),
                        ),
                        Row(
                          children: <Widget>[
                            Expanded(
                              child: Container(
                                  padding: EdgeInsets.only(left: 25, right: 25),
                                  decoration: BoxDecoration(
                                      borderRadius: BorderRadius.all(
                                          Radius.circular(20))),
                                  child: ElevatedButton(
                                    style: ElevatedButton.styleFrom(
                                        backgroundColor: Colors.green,
                                        textStyle:
                                            TextStyle(color: Colors.white),
                                        shape: RoundedRectangleBorder(
                                            borderRadius:
                                                BorderRadius.circular(20.0))),
                                    child: Text('Ok'),
                                    onPressed: () {
                                      setState(() {
                                        Navigator.pop(context);
                                      });
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
      }
      print(_permissionStatus);
    });
  }

  void downloadFile(String url1) async {
    final taskId = await FlutterDownloader.enqueue(
      url: url1,
      savedDir: 'the path of directory where you want to save downloaded files',
      showNotification:
          true, // show download progress in status bar (for Android)
      openFileFromNotification: true,
      // click on notification to open downloaded file (for Android)
    );
    print("G1 file dl");
  }

  List<SubCategory>? subCategoryList;

  static String convertDateFormat(
      String dateTimeString, String oldFormat, String newFormat) {
    DateFormat newDateFormat = DateFormat(newFormat);
    DateTime dateTime = DateFormat(oldFormat).parse(dateTimeString);
    String selectedDate = newDateFormat.format(dateTime);
    return selectedDate;
  }

  void loadSubTypeList(int id) {
    subCategoryList = [];
    for (int i = 0; i < documentCategoryApiCallBack!.items!.length; i++) {
      if (documentCategoryApiCallBack!.items![i].id == id) {
        subCategoryList = documentCategoryApiCallBack!.items![i].subCategory!;
        i = documentCategoryApiCallBack!.items!.length + 1;
      }
    }
  }

  void setData(int id) async {
    final SharedPreferences prefs = await _prefs;
    var companyID;
    if (prefs.getBool(SP_IS_LOGIN_BOOL) != null) {
      companyId = prefs.getInt(SP_COMPANY_ID)!;
    }
    for (int i = 0; i < subCategoryList!.length; i++) {
      if (subCategoryList![i].id == id) {
        selectedDocName = subCategoryList![i].categoryName;
        if (selectedDocName == 'Personal Document' && companyID == 120) {
          _isVisible = true;
        } else {
          _isVisible = false;
        }
        accessLevel = subCategoryList![i].accessLevel!;
        i = subCategoryList!.length + 1;
        log('dataAccessLevel: $accessLevel');
      }
    }
    apiCallForDocumentList(accessLevel!);
  }
}

class ModelNotification {
  String title, details, dateTime;

  ModelNotification(this.title, this.details, this.dateTime);
}

class DocumentListApiCallBack {
  List<Item> items;
  String message;
  int status;
  bool success;
  int total_count;

  DocumentListApiCallBack(
      {required this.items,
      required this.message,
      required this.status,
      required this.success,
      required this.total_count});

  factory DocumentListApiCallBack.fromJson(Map<String, dynamic> json) {
    return DocumentListApiCallBack(
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
    data['message'] = this.message;
    data['status'] = this.status;
    data['success'] = this.success;
    data['total_count'] = this.total_count;
    data['items'] = this.items.map((v) => v.toJson()).toList();
    return data;
  }
}

class Item {
  String created_at;
  int created_by;
  String documentName;
  String documentPath;
  String documentType;
  int id;
  int isdeleted;
  String updated_at;
  int userId;

  Item(
      {required this.created_at,
      required this.created_by,
      required this.documentName,
      required this.documentPath,
      required this.documentType,
      required this.id,
      required this.isdeleted,
      required this.updated_at,
      required this.userId});

  factory Item.fromJson(Map<String, dynamic> json) {
    return Item(
      created_at: json['created_at'],
      created_by: json['created_by'],
      documentName: json['documentName'],
      documentPath: json['documentPath'],
      documentType: json['documentType'],
      id: json['id'],
      isdeleted: json['isdeleted'],
      updated_at: json['updated_at'],
      userId: json['userId'],
    );
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['created_at'] = this.created_at;
    data['created_by'] = this.created_by;
    data['documentName'] = this.documentName;
    data['documentPath'] = this.documentPath;
    data['documentType'] = this.documentType;
    data['id'] = this.id;
    data['isdeleted'] = this.isdeleted;
    data['updated_at'] = this.updated_at;
    data['userId'] = this.userId;
    return data;
  }
}

class DocumentTypeApiCallBack {
  int? totalCount;
  late bool success;
  late List<Items> items;
  String? message;
  int? status;
  String? currentTime;
  late String currentUtcTime;

  DocumentTypeApiCallBack(
      {required this.totalCount,
      required this.success,
      required this.items,
      required this.message,
      required this.status,
      required this.currentTime,
      required this.currentUtcTime});

  DocumentTypeApiCallBack.fromJson(Map<String, dynamic> json) {
    totalCount = json['total_count'];
    //success = json['success'];
    if (json['items'] != null) {
      json['items'].forEach((v) {
        items.add(new Items.fromJson(v));
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
    data['items'] = this.items.map((v) => v.toJson()).toList();
    data['message'] = this.message;
    data['status'] = this.status;
    data['current_time'] = this.currentTime;
    data['current_utc_time'] = this.currentUtcTime;
    return data;
  }
}

class Items {
  int? id;
  int? userId;
  String? documentName;
  String? documentType;
  String? documentPath;
  String? monthYear;
  String? description;
  int? createdBy;
  int? isdeleted;
  int? companyId;
  var departments;
  var branches;
  var designations;
  var isEnabled;
  var createdAt;
  var updatedAt;
  var categoryName;
  var firstName;
  var lastName;

  Items(
      {required this.id,
      required this.userId,
      required this.documentName,
      required this.documentType,
      required this.documentPath,
      required this.monthYear,
      required this.description,
      required this.createdBy,
      required this.isdeleted,
      required this.companyId,
      this.departments,
      this.branches,
      this.designations,
      this.isEnabled,
      this.createdAt,
      this.updatedAt,
      this.categoryName});

  Items.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    userId = json['userId'];
    documentName = json['documentName'];
    documentType = json['documentType'];
    documentPath = json['documentPath'];
    monthYear = json['monthYear'];
    description = json['description'];
    createdBy = json['created_by'];
    isdeleted = json['isdeleted'];
    companyId = json['company_id'];
    departments = json['departments'];
    branches = json['branches'];
    designations = json['designations'];
    isEnabled = json['isEnabled'];
    createdAt = json['created_at'];
    updatedAt = json['updated_at'];
    categoryName = json['category_name'];
    firstName = json['first_name'];
    lastName = json['last_name'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['id'] = this.id;
    data['userId'] = this.userId;
    data['documentName'] = this.documentName;
    data['documentType'] = this.documentType;
    data['documentPath'] = this.documentPath;
    data['monthYear'] = this.monthYear;
    data['description'] = this.description;
    data['created_by'] = this.createdBy;
    data['isdeleted'] = this.isdeleted;
    data['company_id'] = this.companyId;
    data['departments'] = this.departments;
    data['branches'] = this.branches;
    data['designations'] = this.designations;
    data['isEnabled'] = this.isEnabled;
    data['created_at'] = this.createdAt;
    data['updated_at'] = this.updatedAt;
    data['category_name'] = this.categoryName;
    data['first_name'] = this.categoryName;
    data['category_name'] = this.categoryName;
    data['first_name'] = this.firstName;
    data['last_name'] = this.lastName;
    return data;
  }
}

class TodoListApiCallBack {
   int? status;
   var message;
   List<Data>? data;

  TodoListApiCallBack({
    required this.status,
    required this.data,
    this.message,
  });

  TodoListApiCallBack.fromJson(Map<String, dynamic> json) {
    status = json['success'];
    message = json['status'];
    if (json['total_count'] != null) {
      data = [];
      json['total_count'].forEach((v) {
        data!.add(new Data.fromJson(v));
      });
    }
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['success'] = this.status;
    data['status'] = this.message;
    data['total_count'] = this.data!.map((v) => v.toJson()).toList();
    return data;
  }
}

class Data {
  int? id;
  var userId;
  String? documentName;
  String? documentType;
  String? documentPath;
  String? monthYear;
   String? description;
  int? createdBy;
  int? isdeleted;
  int? companyId;
  var departments;
  var branches;
  var designations;
  var isEnabled;
  var createdAt;
  var updatedAt;
  var categoryName;
  var firstName;
  var lastName;

  Data(
      {required this.id,
      required this.userId,
      required this.documentName,
      required this.documentType,
      required this.documentPath,
      required this.monthYear,
      required this.description,
      required this.createdBy,
      required this.isdeleted,
      required this.companyId,
      this.departments,
      this.branches,
      this.designations,
      this.isEnabled,
      this.createdAt,
      this.updatedAt,
      this.categoryName});

  Data.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    userId = json['userId'];
    documentName = json['documentName'];
    documentType = json['documentType'];
    documentPath = json['documentPath'];
    monthYear = json['monthYear'];
    description = json['description'];
    createdBy = json['created_by'];
    isdeleted = json['isdeleted'];
    companyId = json['company_id'];
    departments = json['departments'];
    branches = json['branches'];
    designations = json['designations'];
    isEnabled = json['isEnabled'];
    createdAt = json['created_at'];
    updatedAt = json['updated_at'];
    categoryName = json['category_name'];
    firstName = json['first_name'];
    lastName = json['last_name'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['id'] = this.id;
    data['userId'] = this.userId;
    data['documentName'] = this.documentName;
    data['documentType'] = this.documentType;
    data['documentPath'] = this.documentPath;
    data['monthYear'] = this.monthYear;
    data['description'] = this.description;
    data['created_by'] = this.createdBy;
    data['isdeleted'] = this.isdeleted;
    data['company_id'] = this.companyId;
    data['departments'] = this.departments;
    data['branches'] = this.branches;
    data['designations'] = this.designations;
    data['isEnabled'] = this.isEnabled;
    data['created_at'] = this.createdAt;
    data['updated_at'] = this.updatedAt;
    data['category_name'] = this.categoryName;
    data['first_name'] = this.categoryName;
    data['category_name'] = this.categoryName;
    data['first_name'] = this.firstName;
    data['last_name'] = this.lastName;

    return data;
  }
}
