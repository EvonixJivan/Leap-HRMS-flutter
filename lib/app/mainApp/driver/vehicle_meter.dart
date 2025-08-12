import 'dart:io';
import 'package:flutter/material.dart';
import 'package:hrms/app/uiComponent/custom_header.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:hrms/appUtil/app_util_config.dart';
import 'package:hrms/appUtil/network_util.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:intl/intl.dart';

class Vehicle extends StatefulWidget {
  var scaffoldKey;
  var title;

  Vehicle({Key? key, required this.scaffoldKey, required this.title})
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
  VehicleApicallBack? _vehicleApicallBack;
  String? _vehicleNumberDropdownValue, today, _meterReading;
  var formatter = new DateFormat('yyyy-MM-dd');
  TextEditingController meterController = TextEditingController();
  late int userId;
 String? apiToken;

  @override
  void initState() {
    super.initState();
    today = formatter.format(DateTime.now());
  }

  @override
  Widget build(BuildContext context) {
    Future startButtonTapped() async {
      final SharedPreferences prefs = await _prefs;
      if (prefs.getBool(SP_IS_LOGIN_BOOL) != null) {
         userId = prefs.getInt(SP_ID)!;
        apiToken = prefs.getString(SP_API_TOKEN)!;
      }

      var map = new Map<String, dynamic>();
      map["appType"] = Platform.operatingSystem.toUpperCase();
      map["user_id"] = userId.toString();
      map["api_token"] = apiToken;
      map["date"] = today;
      ;

      BuildContext _context = context;

      print(map);
      try {
        showLoader(_context);
        _networkUtil
            .post(apiDriverDeliveryInsert, body: map)
            .then((dynamic res) {
          try {
            Navigator.pop(_context);
            AppLog.showLog(res.toString());
            // _updatePackageApiCallBack = UpdatePackageApiCallBack.fromJson(res);
            // if (_updatePackageApiCallBack!.status == unAuthorised) {
            //   logout(context);
            // } else if (_updatePackageApiCallBack!.success) {
            //   prefs.setString(SP_VEHICLE_SELECTION_UPLOAD_DATE, today);
            //   showBottomToast(_updatePackageApiCallBack!.message);
            //   Navigator.of(context).pop({'reload': true});
            // } else {
            //   showBottomToast(_updatePackageApiCallBack!.message);
            // }
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

    final vehicleNumber = Padding(
        padding: EdgeInsets.only(
            left: ScreenUtil().setSp(10),
            top: ScreenUtil().setSp(10),
            right: ScreenUtil().setSp(10),
            bottom: ScreenUtil().setSp(10)),
        child: Container(
            padding: EdgeInsets.only(left: ScreenUtil().setSp(10)),
            decoration: BoxDecoration(
              color: Colors.grey[100],
              border: Border.all(width: 1, color: Colors.grey),
              borderRadius: BorderRadius.circular(3),
            ),
            child:
                // (_vehicleApicallBack != null &&
                //         _vehicleApicallBack.items.length > 0)
                //     ?
                DropdownButton(
              hint: Text('Select Vehicle Number'),
              items:
                  //_vehicleApicallBack.items.map((dataItem) {
                  <String>['A', 'B', 'C', 'D'].map((String dataItem) {
                return DropdownMenuItem(
                  child: new Text(dataItem),
                  value: dataItem,
                  //.id.toString(),
                );
              }).toList(),
              onChanged: (newValue) {
                setState(() {
                  _vehicleNumberDropdownValue = newValue.toString();
                });
              },
              isExpanded: true,
              value: _vehicleNumberDropdownValue,
            )
            // : DropdownButton(
            //     hint: Text('Select Leave Type'),
            //     items: [],
            //     onChanged: (newValue) {},
            //     isExpanded: true,
            //     value: _vehicleNumberDropdownValue,
            //   )
            ));

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
                return 'Meter Reading is required';
              }
              return null;
            },
            decoration: InputDecoration(
                border: InputBorder.none,
                hintText: 'Enter Meeting Reading',
                prefixIcon: Icon(
                  Icons.business_center,
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
              startButtonTapped();
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
                                today ?? "",
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
                                'Company Name',
                                style: TextStyle(
                                    color: appPrimaryColor,
                                    fontSize: ScreenUtil().setSp(19),
                                    fontWeight: FontWeight.w800),
                              ),
                            ),
                            SizedBox(height: 10),
                            vehicleNumber,
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

class VehicleApicallBack {}
