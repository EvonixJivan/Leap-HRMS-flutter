import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:hrms/app/uiComponent/custom_header.dart';
import 'package:hrms/appUtil/app_util_config.dart';
import 'package:hrms/appUtil/network_util.dart';
import 'package:intl/intl.dart';
import 'package:autocomplete_textfield/autocomplete_textfield.dart';
import 'package:shared_preferences/shared_preferences.dart';

class Vehicle extends StatefulWidget {
  var scaffoldKey;
  var title;
  var companyName;

  Vehicle(
      {Key? key,
      required this.scaffoldKey,
      required this.title,
      required this.companyName})
      : super(key: key);

  @override
  State<StatefulWidget> createState() {
    return _VehicleState();
  }
}

class _VehicleState extends State<Vehicle> {
  NetworkUtil _networkUtil = NetworkUtil();
  Future<SharedPreferences> _prefs = SharedPreferences.getInstance();
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  VehicleDetailsApicallBack? _vehicleDetailsApicallBack;

  UserVehicleDetailsApicallBack? _userVehicleDetailsApicallBack;
 String? _meterReading, _vehicleNumber, _phoneNumber;
  TextEditingController meterController = TextEditingController();
  TextEditingController vehicleController = TextEditingController();
  TextEditingController mobileController = TextEditingController();
 late int userId, companyId;
 String? apiToken, currentDate;
  List<String> suggestions = [];
 late SimpleAutoCompleteTextField textField;
  GlobalKey<AutoCompleteTextFieldState<String>> key = new GlobalKey();
  // List<String> added = [];
  String currentText = "";
  String selectedVehicle = "";
  @override
  void initState() {
    super.initState();
    apiCallForVehicleType();
  }

  Future apiCallForVehicleType() async {
    final SharedPreferences prefs = await _prefs;
    if (prefs.getBool(SP_IS_LOGIN_BOOL) != null) {
       userId = prefs.getInt(SP_ID)!;
      companyId = prefs.getInt(SP_COMPANY_ID)!;
      apiToken = prefs.getString(SP_API_TOKEN)!;
    }
    var map = new Map<String, dynamic>();
    map["appType"] = Platform.operatingSystem.toUpperCase();
    map["userId"] = userId.toString();
    map["company_id"] = companyId.toString();
    map["api_token"] = apiToken;
    print(map);
    try {
      _networkUtil.post(apiGetVehicleDetails, body: map).then((dynamic res) {
        try {
          AppLog.showLog(res.toString());
          _vehicleDetailsApicallBack = VehicleDetailsApicallBack.fromJson(res);
          if (_vehicleDetailsApicallBack!.status == unAuthorised) {
            logout(context);
          } else if (!_vehicleDetailsApicallBack!.success) {
            showBottomToast(_vehicleDetailsApicallBack!.message);
          }
        } catch (es) {
          showErrorLog(es.toString());
          showCenterToast(errorApiCall);
        }
        setState(() {
          for (var i = 0; i < _vehicleDetailsApicallBack!.items.length; i++) {
            suggestions.add(_vehicleDetailsApicallBack!.items[i].vehicleNo);
          }
          textField = SimpleAutoCompleteTextField(
            key: key,
            decoration: InputDecoration(
                border: InputBorder.none,
                hintText: 'Enter Vehicle Number',
                prefixIcon: Icon(
                  Icons.directions_car,
                  color: Colors.grey,
                )),
            controller: vehicleController,
            keyboardType: TextInputType.number,
            suggestions: suggestions,
            textChanged: (text) => currentText = text,
            clearOnSubmit: true,
            // textSubmitted: (text) => setState(() {
            //   // print(text);
            //   // selectedVehicle = text;
            // }),
          );
        });
      });
    } catch (e) {
      showErrorLog(e.toString());
      showCenterToast(errorApiCall);
    }
  }

  Future submitButtonTapped() async {
    final SharedPreferences prefs = await _prefs;
    if (prefs.getBool(SP_IS_LOGIN_BOOL) != null) {
       userId = prefs.getInt(SP_ID)!;
      companyId = prefs.getInt(SP_COMPANY_ID)!;
      apiToken = prefs.getString(SP_API_TOKEN)!;
    }

    var map = new Map<String, dynamic>();
    map["appType"] = Platform.operatingSystem.toUpperCase();
    map["user_id"] = userId.toString();
    map["api_token"] = apiToken;
    map['vehicle_id'] = vehicleController.text;
    map['contact_number'] = mobileController.text;
    map['company_id'] = companyId.toString();
    map['start_meter_reading'] = meterController.text;
    map['createdAt'] = DateFormat('yyyy-MM-dd').format(DateTime.now().toUtc());
    BuildContext _context = context;

    print(map);
    try {
      showLoader(_context);
      _networkUtil.post(apiVehicleDetailsInsert, body: map).then((dynamic res) {
        try {
          Navigator.pop(_context);
          AppLog.showLog(res.toString());
          _userVehicleDetailsApicallBack =
              UserVehicleDetailsApicallBack.fromJson(res);
          if (_userVehicleDetailsApicallBack!.status == unAuthorised) {
            logout(context);
          } else if (_userVehicleDetailsApicallBack!.success) {
            currentDate = DateFormat('yyyy/MM/dd').format(
                DateTime.parse(_userVehicleDetailsApicallBack!.currentTime));
            prefs.setString(SP_VEHICLE_SELECTION_UPLOAD_DATE, currentDate ?? "");
            showBottomToast(_userVehicleDetailsApicallBack!.message);
            Navigator.of(context).pop({'reload': true});
          } else {
            showBottomToast(_userVehicleDetailsApicallBack!.message);
          }
        } catch (es) {
          showErrorLog(es.toString());
          showCenterToast(errorApiCall);
          Navigator.pop(_context);
        }
        setState(() {});
      });
    } catch (e) {
      Navigator.pop(_context);
      showErrorLog(e.toString());
      showCenterToast(errorApiCall);
    }
  }

  @override
  Widget build(BuildContext context) {
    final vehicleAutocompleteNumber = Padding(
      padding: EdgeInsets.only(
          left: ScreenUtil().setSp(10),
          top: ScreenUtil().setSp(10),
          right: ScreenUtil().setSp(10),
          bottom: ScreenUtil().setSp(10)),
      child: Container(
        decoration: BoxDecoration(
          color: Colors.grey[100],
          border: Border.all(width: 1, color: Colors.grey),
          borderRadius: BorderRadius.circular(3),
        ),
        child: textField,
      ),
    );

    final mobileNumber = Padding(
      padding: EdgeInsets.only(
          left: ScreenUtil().setSp(10),
          top: ScreenUtil().setSp(10),
          right: ScreenUtil().setSp(10),
          bottom: ScreenUtil().setSp(10)),
      child: Container(
          decoration: BoxDecoration(
            color: Colors.grey[100],
            border: Border.all(width: 1, color: Colors.grey),
            borderRadius: BorderRadius.circular(3),
          ),
          child: TextFormField(
            controller: mobileController,
            maxLength: 9,
            keyboardType: TextInputType.phone,
            validator: (value) {
              if (value!.isEmpty) {
                return 'Phone Number is required';
              } else if (value.length > 9 || value.length < 9) {
                return 'Please add correct Phone Number';
              }
              return null;
            },
            decoration: InputDecoration(
                border: InputBorder.none,
                hintText: 'Enter Phone Number',
                prefixIcon: Icon(
                  Icons.phone_android,
                  color: Colors.grey,
                )),
            onChanged: (String value) {
              setState(() {
                _phoneNumber = value;
              });
            },
          )),
    );

    final vehicleMeter = Padding(
      padding: EdgeInsets.only(
          left: ScreenUtil().setSp(10),
          top: ScreenUtil().setSp(10),
          right: ScreenUtil().setSp(10),
          bottom: ScreenUtil().setSp(10)),
      child: Container(
          decoration: BoxDecoration(
            color: Colors.grey[100],
            border: Border.all(width: 1, color: Colors.grey),
            borderRadius: BorderRadius.circular(3),
          ),
          child: TextFormField(
            controller: meterController,
            keyboardType: TextInputType.number,
            validator: (value) {
              if (value!.isEmpty) {
                return 'Start Meter Reading is required';
              }
              return null;
            },
            decoration: InputDecoration(
                border: InputBorder.none,
                hintText: 'Start Enter Meeting Reading',
                prefixIcon: Icon(
                  Icons.departure_board,
                  color: Colors.grey,
                )),
            onChanged: (String value) {
              setState(() {
                _meterReading = value;
              });
            },
          )),
    );

    final submitButton = Row(
      children: <Widget>[
        SizedBox(
          width: ScreenUtil().setSp(30),
        ),
        Expanded(
          child: ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: appPrimaryColor,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10.0)),
            ),
            onPressed: () {
              if (_formKey.currentState!.validate()) {
                _formKey.currentState!.save();
                if (vehicleController.text.length == 5) {
                  submitButtonTapped();
                } else {
                  showCenterToast('Vehicle Number should be 5 digit only.');
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

    return SafeArea(
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
                                DateFormat('dd MMM, yyyy')
                                    .format(DateTime.now()),
                                style: TextStyle(
                                    color: appAccentColor,
                                    fontSize: ScreenUtil().setSp(18),
                                    fontWeight: FontWeight.w800),
                              ),
                            ),
                            SizedBox(
                              height: 10,
                            ),
                            Center(
                              child: Text(
                                widget.companyName,
                                style: TextStyle(
                                    color: appPrimaryColor,
                                    fontSize: ScreenUtil().setSp(19),
                                    fontWeight: FontWeight.w800),
                              ),
                            ),
                            SizedBox(height: 10),
                            vehicleAutocompleteNumber,
                            // SizedBox(
                            //   height: 10,
                            // ),
                            // Center(
                            //   child: Text(
                            //     'Selected Vehicle No : $selectedVehicle',
                            //     style: TextStyle(
                            //         color: appPrimaryColor,
                            //         fontSize: ScreenUtil().setSp(19),
                            //         fontWeight: FontWeight.w800),
                            //   ),
                            // ),
                            //vehicleNumber,
                            mobileNumber,
                            vehicleMeter,
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
}
class VehicleDetailsApicallBack {
  final int totalCount;
  final bool success;
  final List<VehicleItems> items;
  final String message;
  final int status;
  final String currentTime;
  final String currentUtcTime;

  VehicleDetailsApicallBack({
    required this.totalCount,
    required this.success,
    required this.items,
    required this.message,
    required this.status,
    required this.currentTime,
    required this.currentUtcTime,
  });

  factory VehicleDetailsApicallBack.fromJson(Map<String, dynamic> json) {
    return VehicleDetailsApicallBack(
      totalCount: json['total_count'],
      success: json['success'],
      items: json['items'] != null
          ? List<VehicleItems>.from(json['items'].map((v) => VehicleItems.fromJson(v)))
          : <VehicleItems>[],
      message: json['message'],
      status: json['status'],
      currentTime: json['current_time'],
      currentUtcTime: json['current_utc_time'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'total_count': totalCount,
      'success': success,
      'items': items.map((v) => v.toJson()).toList(),
      'message': message,
      'status': status,
      'current_time': currentTime,
      'current_utc_time': currentUtcTime,
    };
  }
}

class VehicleItems {
  final int id;
  final int companyId;
  final String vehicleRegistrationNo;
  final String vehicleNo;
  final String vehicleName;
  final String vehicleModel;
  final String documentUrl;
  final String createdBy;
  final String isActive;
  final int isdeleted;
  final String createdAt;
  final String updatedAt;

  VehicleItems({
    required this.id,
    required this.companyId,
    required this.vehicleRegistrationNo,
    required this.vehicleNo,
    required this.vehicleName,
    required this.vehicleModel,
    required this.documentUrl,
    required this.createdBy,
    required this.isActive,
    required this.isdeleted,
    required this.createdAt,
    required this.updatedAt,
  });

  factory VehicleItems.fromJson(Map<String, dynamic> json) {
    return VehicleItems(
      id: json['id'],
      companyId: json['company_id'],
      vehicleRegistrationNo: json['vehicle_registration_no'],
      vehicleNo: json['vehicle_no'],
      vehicleName: json['vehicle_name'],
      vehicleModel: json['vehicle_model'],
      documentUrl: json['document_url'],
      createdBy: json['created_by'],
      isActive: json['is_active'],
      isdeleted: json['isdeleted'],
      createdAt: json['created_at'],
      updatedAt: json['updated_at'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'company_id': companyId,
      'vehicle_registration_no': vehicleRegistrationNo,
      'vehicle_no': vehicleNo,
      'vehicle_name': vehicleName,
      'vehicle_model': vehicleModel,
      'document_url': documentUrl,
      'created_by': createdBy,
      'is_active': isActive,
      'isdeleted': isdeleted,
      'created_at': createdAt,
      'updated_at': updatedAt,
    };
  }
}

class UserVehicleDetailsApicallBack {
  final int totalCount;
  final bool success;
  final Item? items;
  final String message;
  final int status;
  final String currentTime;
  final String currentUtcTime;

  UserVehicleDetailsApicallBack({
    required this.totalCount,
    required this.success,
    required this.items,
    required this.message,
    required this.status,
    required this.currentTime,
    required this.currentUtcTime,
  });

  factory UserVehicleDetailsApicallBack.fromJson(Map<String, dynamic> json) {
    return UserVehicleDetailsApicallBack(
      totalCount: json['total_count'],
      success: json['success'],
      items: json['items'] != null ? Item.fromJson(json['items']) : null,
      message: json['message'],
      status: json['status'],
      currentTime: json['current_time'],
      currentUtcTime: json['current_utc_time'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'total_count': totalCount,
      'success': success,
      'items': items?.toJson(),
      'message': message,
      'status': status,
      'current_time': currentTime,
      'current_utc_time': currentUtcTime,
    };
  }
}

class Item {
  final int id;
  final int userId;
  final int vehicleId;
  final int companyId;
  final String startMeterReading;
  final String startMeterReadingUrl;
  final int isdeleted;
  final String createdAt;
  final String updatedAt;

  Item({
    required this.id,
    required this.userId,
    required this.vehicleId,
    required this.companyId,
    required this.startMeterReading,
    required this.startMeterReadingUrl,
    required this.isdeleted,
    required this.createdAt,
    required this.updatedAt,
  });

  factory Item.fromJson(Map<String, dynamic> json) {
    return Item(
      id: json['id'],
      userId: json['user_id'],
      vehicleId: json['vehicle_id'],
      companyId: json['company_id'],
      startMeterReading: json['start_meter_reading'],
      startMeterReadingUrl: json['start_meter_reading_url'],
      isdeleted: json['isdeleted'],
      createdAt: json['created_at'],
      updatedAt: json['updated_at'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'user_id': userId,
      'vehicle_id': vehicleId,
      'company_id': companyId,
      'start_meter_reading': startMeterReading,
      'start_meter_reading_url': startMeterReadingUrl,
      'isdeleted': isdeleted,
      'created_at': createdAt,
      'updated_at': updatedAt,
    };
  }
}