import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:hrms/app/uiComponent/custom_header.dart';
import 'package:hrms/appUtil/app_util_config.dart';
import 'package:image_picker/image_picker.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:hrms/appUtil/network_util.dart';
import 'package:intl/intl.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:file_picker/file_picker.dart';

class AddDocument extends StatefulWidget {
  var scaffoldKey;
  var title;
  var selectedDocName;

  // AddDocument({Key key}) : super(key: key);
  AddDocument(
      {Key? key,
      required this.scaffoldKey,
      required this.title,
      required this.selectedDocName})
      : super(key: key);

  @override
  _AddDocumentState createState() {
    return _AddDocumentState();
  }
}

class _AddDocumentState extends State<AddDocument> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  File? _imageFile = null;
  final imagePicker = ImagePicker();
  var selectedFileName = "";
  int _radioSelected = 1;
  String _radioVal = "1";
  String apiToken = "", deviceId = "";
  late int userId, companyId, bufferDays;
  NetworkUtil _networkUtil = NetworkUtil();
  Future<SharedPreferences> _prefs = SharedPreferences.getInstance();
  AddDocCallBack? addDocCallBack;
  TextEditingController txtDes = TextEditingController();

  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // TODO: implement build
    return Scaffold(
      body: Stack(
        children: [
          Container(
            color: appBackgroundColor,
            child: Stack(
              children: <Widget>[
                CustomHeader(
                    scaffoldKey: widget.scaffoldKey, title: widget.title),
                // CustomHeaderHeightWithBack(
                //     scaffoldKey: widget.scaffoldKey, title: widget.title),
                SingleChildScrollView(
                  child: Container(
                    margin: EdgeInsets.only(top: 40.0, left: 30, right: 30),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
                      children: <Widget>[
                        // IconButton(
                        //   icon: Icon(Icons.arrow_back_ios,
                        //       size: 25, color: Colors.white),
                        //   onPressed: () {
                        //     print('Back Pressed');
                        //     Navigator.pop(context);
                        //   },
                        // ),
                        SizedBox(
                          height: 180,
                        ),
                        Text(
                          widget.selectedDocName,
                          style: TextStyle(
                              color: Colors.black,
                              fontWeight: FontWeight.bold,
                              fontSize: 19),
                        ),
                        SizedBox(
                          height: 20,
                        ),
                        Text(
                          'FILE',
                          style: TextStyle(
                            color: Colors.black,
                            fontSize: 15,
                            fontWeight: FontWeight.w600,
                            fontFamily: font,
                          ),
                        ),
                        Container(
                          width: double.infinity,
                          child: Row(
                            children: [
                              OutlinedButton(
                                onPressed: () {
                                  showModalBottomSheet<void>(
                                      backgroundColor: Colors.transparent,
                                      context: context,
                                      builder: (BuildContext context) {
                                        return Container(
                                          height: 180,
                                          decoration: new BoxDecoration(
                                            color: Colors.white,
                                            borderRadius: new BorderRadius.only(
                                              topLeft:
                                                  const Radius.circular(30.0),
                                              topRight:
                                                  const Radius.circular(30.0),
                                            ),
                                          ),
                                          margin:
                                              EdgeInsets.fromLTRB(0, 0, 0, 0),
                                          // color: Colors.white,
                                          child: Form(
                                            key: _formKey,
                                            child: Column(
                                              crossAxisAlignment:
                                                  CrossAxisAlignment.center,
                                              //mainAxisSize: MainAxisSize.min,
                                              children: <Widget>[
                                                Row(
                                                  children: [
                                                    SizedBox(
                                                      width: 20.0,
                                                    ),
                                                    Text(
                                                      'Choose file',
                                                      style: TextStyle(
                                                          color: Colors.black,
                                                          fontSize: 15),
                                                    ),
                                                    Expanded(
                                                      child: Text(''),
                                                    ),
                                                    IconButton(
                                                        icon: Icon(
                                                          Icons.cancel,
                                                          color: Colors.grey,
                                                        ),
                                                        onPressed: () =>
                                                            Navigator.pop(
                                                                context)),
                                                  ],
                                                ),
                                                SizedBox(
                                                  height: 20,
                                                ),
                                                Row(
                                                  children: [
                                                    // SizedBox(
                                                    //   width: 15,
                                                    // ),
                                                    Expanded(child: Text('')),
                                                    Column(
                                                      children: [
                                                        Container(
                                                            height: 70,
                                                            width: 70,
                                                            decoration:
                                                                BoxDecoration(
                                                              shape: BoxShape
                                                                  .circle,
                                                              border:
                                                                  Border.all(
                                                                width: 1,
                                                                color: Theme.of(
                                                                        context)
                                                                    .scaffoldBackgroundColor,
                                                              ),
                                                              color:
                                                                  appPrimaryColor,
                                                            ),
                                                            child: IconButton(
                                                                icon: Icon(
                                                                  Icons
                                                                      .camera_alt,
                                                                  color: Colors
                                                                      .white,
                                                                  size: 30,
                                                                ),
                                                                onPressed:
                                                                    () async {
                                                                  try {
                                                                    //_imageFile =
                                                                    
                                                                     final ImagePicker picker = ImagePicker();

                                  XFile? file = await picker.pickImage(
                                    source: ImageSource.camera,
                                    maxWidth: 200.0,
                                    maxHeight: 500.0,
                                    imageQuality: 70,
                                  );

                                  if (file != null) {
                                    print("Image Path: ${file.path}");
                                    _imageFile = File(file.path);
                                  } else {  print("No image selected");
                                  }
                                    
                                                                    // selectedFileName =
                                                                    //     file.path
                                                                    //         .toString();

                                                                    _imageFile =
                                                                        File(file!
                                                                            .path);

                                                                    // var fileName = File(file
                                                                    //     .path.split('/').last);
                                                                    //
                                                                    // print('Jivan-->  $fileName');
                                                                    // String dir = path.dirname(file.path);
                                                                    // selectedFileName =  path.join(dir, 'case01wd03id01.png');
                                                                    selectedFileName = File(
                                                                            file.path)
                                                                        .uri
                                                                        .pathSegments
                                                                        .last;
                                                                    print(
                                                                        'NewPath: ${selectedFileName}');
                                                                    // print(selectedFileName);

                                                                    Navigator.pop(
                                                                        context);
                                                                    setState(
                                                                        () {});
                                                                  } catch (e) {
                                                                    // _pickImageError = e;
                                                                    // showBottomToast(
                                                                    //     "Image picker error: $e");
                                                                  }
                                                                })),
                                                        Text(
                                                          'Camera',
                                                          style: TextStyle(
                                                              color:
                                                                  Colors.black,
                                                              fontWeight:
                                                                  FontWeight
                                                                      .w600,
                                                              fontSize: 16),
                                                        )
                                                      ],
                                                    ),
                                                    SizedBox(
                                                      width: 30,
                                                    ),
                                                    Column(
                                                      children: [
                                                        Container(
                                                            height: 70,
                                                            width: 70,
                                                            decoration:
                                                                BoxDecoration(
                                                              shape: BoxShape
                                                                  .circle,
                                                              border:
                                                                  Border.all(
                                                                width: 1,
                                                                color: Theme.of(
                                                                        context)
                                                                    .scaffoldBackgroundColor,
                                                              ),
                                                              color:
                                                                  appPrimaryColor,
                                                            ),
                                                            child: IconButton(
                                                                icon: Icon(
                                                                  Icons.camera,
                                                                  color: Colors
                                                                      .white,
                                                                  size: 30,
                                                                ),
                                                                onPressed:
                                                                    () async {
                                                                  try {
                                                                    //_imageFile =
                                                                    final ImagePicker picker = ImagePicker();

                                  XFile? file = await picker.pickImage(
                                    source: ImageSource.camera,
                                    maxWidth: 200.0,
                                    maxHeight: 500.0,
                                    imageQuality: 70,
                                  );

                                  if (file != null) {
                                    print("Image Path: ${file.path}");
                                    _imageFile = File(file.path);
                                  } else {  print("No image selected");
                                  }
                                                                    // selectedFileName =
                                                                    //     file.toString();
                                                                    // _imageFile =
                                                                    //     File(file.path);
                                                                    _imageFile =
                                                                        File(file!
                                                                            .path);
                                                                    // String dir = path.dirname(file.path);
                                                                    // selectedFileName =  path.join(dir, 'case01wd03id01.png');

                                                                    selectedFileName = File(
                                                                            file.path)
                                                                        .uri
                                                                        .pathSegments
                                                                        .last;

                                                                    print(
                                                                        'NewPath: ${selectedFileName}');
                                                                    Navigator.pop(
                                                                        context);
                                                                    setState(
                                                                        () {});
                                                                  } catch (e) {
                                                                    // _pickImageError = e;
                                                                    //   showBottomToast(
                                                                    //       "Image picker error: $e");
                                                                  }
                                                                })),
                                                        Text(
                                                          'Gallery',
                                                          style: TextStyle(
                                                              color:
                                                                  Colors.black,
                                                              fontWeight:
                                                                  FontWeight
                                                                      .w600,
                                                              fontSize: 16),
                                                        )
                                                      ],
                                                    ),
                                                    SizedBox(
                                                      width: 30,
                                                    ),
                                                    Column(
                                                      children: [
                                                        Container(
                                                            height: 70,
                                                            width: 70,
                                                            decoration:
                                                                BoxDecoration(
                                                              shape: BoxShape
                                                                  .circle,
                                                              border:
                                                                  Border.all(
                                                                width: 1,
                                                                color: Theme.of(
                                                                        context)
                                                                    .scaffoldBackgroundColor,
                                                              ),
                                                              color:
                                                                  appPrimaryColor,
                                                            ),
                                                            child: IconButton(
                                                                icon: Icon(
                                                                  FontAwesomeIcons
                                                                      .filePdf,
                                                                  color: Colors
                                                                      .white,
                                                                  size: 30,
                                                                ),
                                                                onPressed:
                                                                    () async {
                                                                  try {
                                                                    //_imageFile =
                                                                    FilePickerResult?
                                                                        result =
                                                                        await FilePicker
                                                                            .platform
                                                                            .pickFiles();
                                                                    setState(
                                                                        () {
                                                                      _imageFile = File(result!
                                                                          .files
                                                                          .single
                                                                          .path
                                                                          .toString());

                                                                      //selectedFileName = File(file.path).uri.pathSegments.last;
                                                                      print(
                                                                          'NewPath: ${_imageFile!.absolute.path.toString()}');
                                                                                                                                        });

                                                                    //_imageFile = File(file.path);
                                                                    // String dir = path.dirname(file.path);
                                                                    // selectedFileName =  path.join(dir, 'case01wd03id01.png');
                                                                    // print(selectedFileName);

                                                                    Navigator.pop(
                                                                        context);
                                                                    setState(
                                                                        () {});
                                                                  } catch (e) {
                                                                    // _pickImageError = e;

                                                                  }
                                                                })),
                                                        Text(
                                                          'Document',
                                                          style: TextStyle(
                                                              color:
                                                                  Colors.black,
                                                              fontWeight:
                                                                  FontWeight
                                                                      .w600,
                                                              fontSize: 16),
                                                        )
                                                      ],
                                                    ),
                                                    Expanded(child: Text('')),
                                                  ],
                                                )
                                              ],
                                            ),
                                          ),
                                        );
                                      });
                                },
                                style: OutlinedButton.styleFrom(
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(4.0),
                                  ),
                                  backgroundColor: Colors.grey,
                                  side: BorderSide(
                                      width: 0.5, color: Colors.black),
                                ),
                                child: Text(
                                  'Choose file',
                                  style: TextStyle(
                                      color: Colors.black, fontSize: 15),
                                ),
                              ),
                              SizedBox(
                                width: 5.0,
                              ),
                            ],
                          ),
                        ),
                        _imageFile != null
                            ? Text(
                                getFileExtension(_imageFile!.path.toString()),
                                // _imageFile.path.toString(),
                                style: TextStyle(
                                    color: Colors.black, fontSize: 17),
                                overflow: TextOverflow.ellipsis,
                                softWrap: false,
                              )
                            : Text(
                                'No file choosen',
                                style: TextStyle(
                                    color: Colors.black,
                                    fontSize: 15,
                                    fontFamily: font),
                              ),
                        SizedBox(
                          height: 20,
                        ),
                        Text(
                          'DESCRIPTION',
                          style: TextStyle(
                            color: Colors.black,
                            fontSize: 15,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        SizedBox(
                          height: 5,
                        ),
                        Container(
                            padding: EdgeInsets.only(left: 10),

                            // decoration: BoxDecoration(
                            //   color: Colors.grey[100],
                            //   border: Border.all(width: 1, color: Colors.grey),
                            //   borderRadius: BorderRadius.circular(3),
                            // ),
                            child: TextFormField(
                              controller: txtDes,
                              maxLines: null,
                              validator: (value) {
                                if (value!.isEmpty) {
                                  return 'Description is required';
                                }
                                return null;
                              },
                              decoration: InputDecoration(
                                hintStyle: TextStyle(color: colorText),
                                hintText: '  Enter Description',
                                filled: true,
                                fillColor: tfBackgroundColor,
                                contentPadding:
                                    EdgeInsets.fromLTRB(10.0, 5.0, 10.0, 5.0),
                                focusedBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(25.0),
                                  borderSide: BorderSide.none,
                                ),
                                enabledBorder: UnderlineInputBorder(
                                  borderSide: BorderSide.none,
                                  borderRadius: BorderRadius.circular(25.7),
                                ),
                              ),
                              // decoration: InputDecoration(
                              //   border: InputBorder.none,
                              //   hintText: 'Enter Description',
                              // ),
                              onSaved: (String? value) {
                                print(value);
                              },
                            )),
                        SizedBox(
                          height: 20,
                        ),
                        Text(
                          'STATUS',
                          style: TextStyle(
                            color: Colors.black,
                            fontSize: 15,
                            fontWeight: FontWeight.w600,
                            fontFamily: font,
                          ),
                        ),
                        SizedBox(
                          height: 5,
                        ),
                        Row(
                          children: [
                            Radio(
                              value: 1,
                              groupValue: _radioSelected,
                              // activeColor: appColorRADIO,
                              activeColor: colorTextDarkBlue,
                              onChanged: (value) {
                                setState(() {
                                  _radioSelected = value as int;
                                  // _radioVal = 'Active';
                                  _radioVal = '1';
                                });
                              },
                            ),
                            Text('Active'),
                            Radio(
                              value: 2,
                              groupValue: _radioSelected,
                              // activeColor: appColorRADIO,
                              activeColor: colorTextDarkBlue,
                              onChanged: (value) {
                                setState(() {
                                  _radioSelected = value as int;
                                  // _radioVal = 'Inactive';
                                  _radioVal = '0';
                                });
                              },
                            ),
                            Text('Inactive'),
                          ],
                        ),
                        SizedBox(
                          height: 5,
                        ),
                        InkWell(
                            onTap: () {
                              //  if (_formKey.currentState.validate()) {
                              if (txtDes.text.isEmpty) {
                              showBottomToast("Please enter description");
                            } else {
                              FocusScope.of(context)
                                  .requestFocus(FocusNode());
                              apiCallForAddDocument();
                            }
                              //  }
                            },
                            child: Container(
                              height: 30,
                              decoration: BoxDecoration(
                                color: btnBgColor,
                                // border: Border.all(width: 1, color: Colors.grey),
                                borderRadius: BorderRadius.circular(6),
                              ),
                              alignment: Alignment.center,
                              child: Text("Submit",
                                  style: TextStyle(
                                      color: Colors.white, fontSize: 17)),
                            )),
                        SizedBox(
                          height: 50,
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  String getFileExtension(String fileName) {
    // return "." + fileName.split('.').last;
    // _imageFile.absolute.path.toString().split('.').last;

    return _imageFile!.absolute.path.toString();
  }

  Future apiCallForAddDocument() async {
    // if (_formKey.currentState.validate()) {
    //   _formKey.currentState.save();
    final SharedPreferences prefs = await _prefs;
    if (prefs.getBool(SP_IS_LOGIN_BOOL) != null) {
       userId = prefs.getInt(SP_ID)!;
      companyId = prefs.getInt(SP_COMPANY_ID)!;
      apiToken = prefs.getString(SP_API_TOKEN)!;
      deviceId = prefs.getString(DEVICE_ID)!;
    }
    var map = new Map<String, dynamic>();
    map["appType"] = Platform.operatingSystem.toUpperCase();
    map["api_token"] = apiToken;
    map["deviceId"] = deviceId;
    map["userId"] = userId.toString();
    map["created_by"] =
        DateFormat('yyyy-MM-dd HH:mm:ss').format(DateTime.now().toLocal());
    String _imageData =
        "data:image/jpeg;base64,${base64Encode(_imageFile!.readAsBytesSync()).toString()}";

    // print(_imageData);
    map['attachment'] = '$_imageData';
    map["documentType"] = '16';
    map["company_id"] = companyId.toString();
    // map["userFile"] = '$_imageData';//'document_1641620800.pdf';//selectedFileName;
    // map["document"] = '$_imageData';//'document_1641620800.pdf';//selectedFileName;
    map["departments"] =
        '63,62,61,60,59,58,57,56,55,53,34,22,11,10,9,7,6,5,4,1';
    map["branches"] = '2,13';
    map["designations"] =
        '110,109,107,106,105,104,103,102,101,100,99,98,97,59,58,57,56,55,54,53,52,51,50,49,48,47,46,45,44,43,42,41,40,26,18,5,4,3,2,1';
    map["description"] = txtDes.text;
    map["isEnabled"] = _radioVal.toString();
    map["isdeleted"] = '0';
    map["file_extension"] = _imageFile!.absolute.path.toString().split('.').last;
    print('Add Document:---> $map');
    try {
      showLoader(context);
      _networkUtil.post(apiAddDoc, body: map).then((dynamic res) {
        Navigator.pop(context);
        try {
          AppLog.showLog(res.toString());
          addDocCallBack = AddDocCallBack.fromJson(res);
          if (addDocCallBack!.status == unAuthorised) {
            // logout(context);
          } else if (addDocCallBack!.success) {
            showBottomToast(addDocCallBack!.message ?? "");
            Navigator.of(context).pop({'reload': true});
          } else {
            showBottomToast(addDocCallBack!.message ?? "");
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
// }
}

class AddDocCallBack {
  late int totalCount;
  late bool success;

  // docItems items;
  String? message;
  late int status;
  String? currentTime;
  String? currentUtcTime;

  AddDocCallBack({
    required this.totalCount,
    required this.success,
    // this.items,
    required this.message,
    required this.status,
    required this.currentTime,
    required this.currentUtcTime,
  });

  AddDocCallBack.fromJson(Map<String, dynamic> json) {
    totalCount = json['total_count'];
    success = json['success'];
    // items =
    // json['items'] != null ? new docItem.fromJson(json['items']) : null;
    message = json['message'];
    status = json['status'];
    currentTime = json['current_time'];
    currentUtcTime = json['current_utc_time'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['total_count'] = this.totalCount;
    data['success'] = this.success;
    // if (this.items != null) {
    //   data['items'] = this.items.toJson();
    // }
    data['message'] = this.message;
    data['status'] = this.status;
    data['current_time'] = this.currentTime;
    data['current_utc_time'] = this.currentUtcTime;
    return data;
  }
}
