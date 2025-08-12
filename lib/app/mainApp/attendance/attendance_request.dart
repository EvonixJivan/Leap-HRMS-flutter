import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:hrms/app/mainApp/driver/packageDetails.dart';
import 'package:hrms/app/mainApp/driver/vehicle_details.dart';
import 'package:hrms/app/mainApp/homePage/api_call_back.dart';
import 'package:hrms/app/uiComponent/custom_header.dart';
import 'package:hrms/appUtil/app_util_config.dart';
import 'package:hrms/appUtil/network_util.dart';
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:autocomplete_textfield/autocomplete_textfield.dart';

class AttendanceRequest extends StatefulWidget {
  var scaffoldKey;
  var title;
  var date;
  DateTime inTime;
  DateTime outTime;
  var reason = '';

  AttendanceRequest({
    Key? key,
    required this.scaffoldKey,
    required this.title,
    required this.date,
    required this.inTime,
    required this.outTime,
    required this.reason,
  }) : super(key: key);

  @override
  State<StatefulWidget> createState() {
    return AttendanceRequestState();
  }
}

NetworkUtil _networkUtil = NetworkUtil();
Future<SharedPreferences> _prefs = SharedPreferences.getInstance();
final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
TextEditingController meterController = TextEditingController();
TextEditingController vehicleController = TextEditingController();
TextEditingController mobileController = TextEditingController();
TextEditingController deliveredController = TextEditingController();
TextEditingController receivedController = TextEditingController();
TextEditingController commentController = TextEditingController();
TextEditingController wrongController = TextEditingController();
TextEditingController customerNotAvailController = TextEditingController();
TextEditingController rescheduledController = TextEditingController();
TextEditingController cancelledController = TextEditingController();
TextEditingController notAttemptedController = TextEditingController();
TextEditingController cashController = TextEditingController();
var _date = 'Select Date';
TimeOfDay? _inTime;
TimeOfDay? _outTime;
String _reason = "", currentText = "";

class AttendanceRequestState extends State<AttendanceRequest> {
 String? apiToken, dropDownValue;
 late int userId, companyId;
  List<String> suggestions = [];
  SimpleAutoCompleteTextField? textField;
  GlobalKey<AutoCompleteTextFieldState<String>> key = new GlobalKey();
  VehicleDetailsApicallBack? _vehicleDetailsApicallBack;
  WorkingTypeApiCallBack? _workingTypeApiCallBack;
  bool isCash = false, isCashVisible = false, isVisible = false;
  int isDriver = 0;
 late BuildContext _context;

  @override
  void initState() {
    super.initState();
    apiCallForGetWorkingType();
    checkIsDriver();
    _reason = widget.reason ?? '';
    _date = new DateFormat('yyyy-MM-dd').format(widget.date);
    _inTime = null;
    _outTime = null;
    // if (widget.isEdit == 0) {
    //   setNull();
    // }
    try {
      _inTime = new TimeOfDay.fromDateTime(widget.inTime);
      _outTime = new TimeOfDay.fromDateTime(widget.outTime);
    } catch (e) {}
  }

  Future checkIsDriver() async {
    final SharedPreferences prefs = await _prefs;
    if (prefs.getBool(SP_IS_LOGIN_BOOL) != null) {
      isDriver = prefs.getInt(SP_DRIVER)!;
      if (isDriver == 1) {
        isVisible = true;
        apiCallForVehicleType();
      } else {
        isVisible = false;
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final attendanceDate = Padding(
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
          child: ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.grey[100],
              elevation: 0,
            ),
            child: Row(
              children: <Widget>[
                Icon(
                  Icons.calendar_today,
                  color: Colors.grey,
                ),
                SizedBox(
                  width: ScreenUtil().setSp(5),
                ),
                Text(new DateFormat('dd, MMM yyyy').format(widget.date)),
              ],
            ),
            onPressed: () {
              // _selectFromDate();
            },
          ),
        ));

    final inTime = Padding(
        padding: EdgeInsets.only(
            left: ScreenUtil().setSp(10),
            top: ScreenUtil().setSp(10),
            right: ScreenUtil().setSp(10),
            bottom: ScreenUtil().setSp(10)),
        child: Container(
          //padding: EdgeInsets.all(2),
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
                  Icons.timer,
                  color: Colors.grey,
                ),
                SizedBox(
                  width: ScreenUtil().setSp(5),
                ),
                Text((_inTime != null
                    ? '${_inTime!.hour}:${_inTime!.minute}'
                    : 'HH:MM')),
              ],
            ),
            onPressed: () {
              setState(() {
                _startTime();
              });
            },
          ),
        ));

    final outTime = Padding(
        padding: EdgeInsets.only(
            left: ScreenUtil().setSp(10),
            top: ScreenUtil().setSp(10),
            right: ScreenUtil().setSp(10),
            bottom: ScreenUtil().setSp(10)),
        child: Container(
          //padding: EdgeInsets.all(2),
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
                  Icons.timer,
                  color: Colors.grey,
                ),
                SizedBox(
                  width: ScreenUtil().setSp(5),
                ),
                Text((_outTime != null
                    ? '${_outTime!.hour}:${_outTime!.minute}'
                    : 'HH:MM')),
              ],
            ),
            onPressed: () {
              setState(() {
                _endTime();
              });
            },
          ),
        ));

    final reason = Padding(
      padding: EdgeInsets.only(
          left: ScreenUtil().setSp(10),
          top: ScreenUtil().setSp(10),
          right: ScreenUtil().setSp(10),
          bottom: ScreenUtil().setSp(10)),
      child: Container(
          // padding: EdgeInsets.all(5),
          decoration: BoxDecoration(
            color: Colors.grey[100],
            border: Border.all(width: 1, color: Colors.grey),
            borderRadius: BorderRadius.circular(3),
          ),
          child: TextFormField(
            maxLines: 5,
            minLines: 2,
            initialValue: _reason,
            validator: (value) {
              if (value!.isEmpty) {
                return 'Reason is required';
              }
              return null;
            },
            decoration: InputDecoration(
                border: InputBorder.none,
                hintText: 'Reason',
                prefixIcon: Icon(
                  Icons.bookmark,
                  color: Colors.grey,
                )),
            onSaved: (String? value) {
              _reason = value!;
              print(value);
            },
          )),
    );

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
            // onChanged: (String value) {
            //   setState(() {
            //     _phoneNumber = value;
            //   });
            // },
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
            // onChanged: (String value) {
            //   setState(() {
            //     _meterReading = value;
            //   });
            // },
          )),
    );

    final receivedText = Padding(
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
            controller: receivedController,
            keyboardType: TextInputType.number,
            validator: (value) {
              if (value!.isEmpty) {
                return 'Received count is required';
              }
              return null;
            },
            decoration: InputDecoration(
                border: InputBorder.none,
                hintText: 'Enter Received Packages',
                prefixIcon: Icon(
                  Icons.business_center,
                  color: Colors.grey,
                )),
            onChanged: (String value) {
              setState(() {
                // _received = value;
                calculateRemainingCount(
                    receivedController.text, deliveredController.text);
              });
            },
          )),
    );

    final deliveredText = Padding(
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
            controller: deliveredController,
            keyboardType: TextInputType.number,
            validator: (value) {
              if (value!.isEmpty) {
                return 'Delivered count is required';
              }
              if (int.parse(receivedController.text) < int.parse(value)) {
                return 'Delivered value should be less than Received count';
              }
              return null;
            },
            decoration: InputDecoration(
                border: InputBorder.none,
                hintText: 'Enter Delivered Packages',
                prefixIcon: Icon(
                  Icons.business_center,
                  color: Colors.grey,
                )),
            onChanged: (String value) {
              setState(() {
                //_delivered = value;
                calculateRemainingCount(
                    receivedController.text, deliveredController.text);
              });
            },
          )),
    );

    final wrongText = Padding(
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
            controller: wrongController,
            keyboardType: TextInputType.number,
            validator: (value) {
              if (value!.isEmpty) {
                return 'Wrong customer details are required';
              }
              return null;
            },
            decoration: InputDecoration(
                border: InputBorder.none,
                hintText: 'Enter Wrong Customer Details Count',
                prefixIcon: Icon(
                  Icons.business_center,
                  color: Colors.grey,
                )),
            onChanged: (String value) {
              setState(() {
                // _wrong = value;
              });
            },
          )),
    );

    final customerNotAvailableText = Padding(
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
            controller: customerNotAvailController,
            keyboardType: TextInputType.number,
            validator: (value) {
              if (value!.isEmpty) {
                return 'Customer Not Available count is required';
              }
              return null;
            },
            decoration: InputDecoration(
                border: InputBorder.none,
                hintText: 'Enter Customer Not Available count',
                prefixIcon: Icon(
                  Icons.business_center,
                  color: Colors.grey,
                )),
            onChanged: (String value) {
              setState(() {
                //_notAvail = value;
              });
            },
          )),
    );

    final rescheduledText = Padding(
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
            controller: rescheduledController,
            keyboardType: TextInputType.number,
            validator: (value) {
              if (value!.isEmpty) {
                return 'rescheduled count is required';
              }
              return null;
            },
            decoration: InputDecoration(
                border: InputBorder.none,
                hintText: 'Enter Rescheduled Count',
                prefixIcon: Icon(
                  Icons.business_center,
                  color: Colors.grey,
                )),
            onChanged: (String value) {
              setState(() {
                //_rescheduled = value;
              });
            },
          )),
    );

    final cancelledText = Padding(
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
            controller: cancelledController,
            keyboardType: TextInputType.number,
            validator: (value) {
              if (value!.isEmpty) {
                return 'cancelled count is required';
              }
              return null;
            },
            decoration: InputDecoration(
                border: InputBorder.none,
                hintText: 'Enter Cancelled Count',
                prefixIcon: Icon(
                  Icons.business_center,
                  color: Colors.grey,
                )),
            onChanged: (String value) {
              setState(() {
                //_cancelled = value;
              });
            },
          )),
    );

    final notAttemptedText = Padding(
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
            controller: notAttemptedController,
            keyboardType: TextInputType.number,
            validator: (value) {
              if (value!.isEmpty) {
                return 'Not Attempted count is required';
              }
              return null;
            },
            decoration: InputDecoration(
                border: InputBorder.none,
                hintText: 'Enter Not Attempted Count',
                prefixIcon: Icon(
                  Icons.business_center,
                  color: Colors.grey,
                )),
            onChanged: (String value) {
              setState(() {
                // _notAttempt = value;
              });
            },
          )),
    );

    final commentText = Padding(
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
            controller: commentController,
            minLines: 2,
            maxLines: 5,
            decoration: InputDecoration(
              contentPadding: EdgeInsets.all(10),
              border: InputBorder.none,
              hintText: 'Add Comment',
            ),
            onSaved: (String? value) {
              setState(() {
                //_comment = value;
              });
            },
          )),
    );

    var remaining = Padding(
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
                  Icons.business_center,
                  color: Colors.grey,
                ),
                SizedBox(
                  width: ScreenUtil().setSp(5),
                ),
                Text(remainingCount),
              ],
            ),
          )),
    );

    final cashText = Visibility(
        visible: isCashVisible,
        child: Padding(
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
                controller: cashController,
                keyboardType: TextInputType.number,
                validator: (value) {
                  if (value!.isEmpty) {
                    return 'Collection amount is required';
                  }
                  if (value == 0.0.toString() || value == 0.toString()) {
                    return 'Collection amount cant be 0';
                  }
                  return null;
                },
                decoration: InputDecoration(
                    border: InputBorder.none,
                    hintText: 'Enter collection amount',
                    prefixIcon: Icon(
                      Icons.business_center,
                      color: Colors.grey,
                    )),
                onChanged: (String value) {
                  setState(() {
                    //_cash = value;
                  });
                },
              )),
        ));

    final workFrom = Padding(
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
              borderRadius: BorderRadius.circular(3),
            ),
            child: //(_workingTypeApiCallBack!.items.length > 0)
            (_workingTypeApiCallBack?.items?.isNotEmpty ?? false)
                ? DropdownButtonHideUnderline(
                    child: DropdownButton<String>(
                      hint: Text('Select work Type'),
                      items: _workingTypeApiCallBack!.items!.map((dataItem) {
                        return DropdownMenuItem<String>(
                          child: new Text(dataItem.name ?? ""),
                          value: dataItem.id.toString(),
                        );
                      }).toList(),
                      onChanged: (String? newValue) {
                        setState(() {
                          dropDownValue = newValue!;
                        });
                      },
                      isExpanded: true,
                      value: dropDownValue,
                    ),
                  )
                : DropdownButtonHideUnderline(
                    child: DropdownButton<String>(
                      hint: Text('Select Work Type'),
                      items: [],
                      onChanged: (String? newValue) {},
                      isExpanded: true,
                      value: dropDownValue,
                    ),
                  )));

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
                  borderRadius: BorderRadius.circular(20.0)),
            ),
            onPressed: () {
              if (isDriver == 1) {
                if (_inTime == null) {
                showBottomToast('In Time is required');
              } else if (_outTime == null) {
                showBottomToast('Out Time is required');
              } else              apiCallForSubmitVehicleDetails();
            
              } else {
                if (_inTime == null) {
                showBottomToast('In Time is required');
              } else if (_outTime == null) {
                showBottomToast('Out Time is required');
              } else              apiCallForAdd();
            
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

    Widget driverOptions() {
      return Visibility(
        visible: isVisible,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            SizedBox(
              height: 10,
            ),
            Container(
                child: Center(
                    child: Text(
              'Vehicle Details',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ))),
            headingText('Vehicle Number: '),
            vehicleAutocompleteNumber,
            headingText('Mobile Number : '),
            mobileNumber,
            headingText('Vehicle Meter : '),
            vehicleMeter,
            SizedBox(
              height: 10,
            ),
            Container(
                child: Center(
                    child: Text(
              'Package Details',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ))),
            headingText('Total Packages Received : '),
            receivedText,
            headingText('Total Packages Delivered : '),
            deliveredText,
            headingText('Packages Remaining : '),
            remaining,
            headingText('Wrong Customer Details : '),
            wrongText,
            headingText('Customer Not Available : '),
            customerNotAvailableText,
            headingText('Rescheduled : '),
            rescheduledText,
            headingText('Cancelled : '),
            cancelledText,
            headingText('Not Attempted : '),
            notAttemptedText,
            headingText('Comment : '),
            commentText,
            Container(
              child: CheckboxListTile(
                title: Text('Cash on delivery collection'),
                controlAffinity: ListTileControlAffinity.leading,
                value: isCash,
                onChanged: (bool? newValue) {
                  setState(() {
                    isCash = newValue!;
                    if (isCash == true) {
                      isCashVisible = true;
                    } else {
                      isCashVisible = false;
                    }
                  });
                },
              ),
            ),
            cashText,
          ],
        ),
      );
    }

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
                              headingText('Work Type : '),
                              workFrom,
                              headingText('Date : '),
                              attendanceDate,
                              headingText('In Time : '),
                              inTime,
                              headingText('Out Time : '),
                              outTime,
                              headingText('Reason'),
                              reason,
                              driverOptions(),
                              SizedBox(
                                height: ScreenUtil().setSp(10),
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
                      )
                    ],
                  ))
            ],
          ),
          onTap: () {
            FocusScope.of(context).requestFocus(new FocusNode());
          },
        ),
      ),
    );
  }

  Future _selectFromDate() async {
    DateTime? _picked = await showDatePicker(
        context: context,
        initialDate: new DateTime.now(),
        firstDate: new DateTime(2016),
        lastDate: new DateTime(2025));
    setState(() {
      _date = new DateFormat('yyyy-MM-dd').format(_picked!);
    });
  }

  Future _startTime() async {
//    _inTime = await showTimePicker(
//      context: context,
//      initialTime: (_inTime == null) ? TimeOfDay.now() : _inTime,
//    );
//    setState(() {
//      print('----');
//      print(_inTime);
//      validateTime();
//    });
    _inTime = await showTimePicker(
      context: context,
      initialTime: TimeOfDay(hour: 10, minute: 47),
      builder: (BuildContext context, Widget? child) {
        return MediaQuery(
          data: MediaQuery.of(context).copyWith(alwaysUse24HourFormat: true),
          child: child ?? Container(),
        );
      },
    );
  }

  Future _endTime() async {
    _outTime = await showTimePicker(
      context: context,
      initialTime: (_outTime == null) ? TimeOfDay.now() : _outTime!,
    );
    setState(() {
      validateTime();
    });
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
            logout(_context);
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
          );
        });
      });
    } catch (e) {
      showErrorLog(e.toString());
      showCenterToast(errorApiCall);
    }
  }

  Future apiCallForSubmitVehicleDetails() async {
    if (_formKey.currentState!.validate()) {
      _formKey.currentState!.save();
      if (vehicleController.text.length == 5) {
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
        map['createdAt'] = DateFormat('yyyy-MM-dd').format(widget.date.toUtc());
        BuildContext _context = context;

        print(map);
        try {
          showLoader(_context);
          _networkUtil
              .post(apiVehicleDetailsInsert, body: map)
              .then((dynamic res) {
            try {
              Navigator.pop(_context);
              AppLog.showLog(res.toString());
              UserVehicleDetailsApicallBack _userVehicleDetailsApicallBack =
                  UserVehicleDetailsApicallBack.fromJson(res);
              if (_userVehicleDetailsApicallBack.status == unAuthorised) {
                logout(context);
              } else if (_userVehicleDetailsApicallBack.success) {
                if (validateRemainingCount(
                    wrongController.text,
                    customerNotAvailController.text,
                    rescheduledController.text,
                    cancelledController.text,
                    notAttemptedController.text)) {
                  apiCallForAddPackage();
                } else {
                  showBottomToast(remainingPackage);
                }

                // currentDate = DateFormat('yyyy/MM/dd').format(
                //     DateTime.parse(_userVehicleDetailsApicallBack.currentTime));
                // prefs.setString(SP_VEHICLE_SELECTION_UPLOAD_DATE, currentDate);
                // showBottomToast(_userVehicleDetailsApicallBack!.message);
                // Navigator.of(context).pop({'reload': true});
              } else {
                showBottomToast(_userVehicleDetailsApicallBack.message);
              }
            } catch (es) {
              showErrorLog(es.toString());
              showCenterToast(errorApiCall);
              //Navigator.pop(_context);
            }
            setState(() {});
          });
        } catch (e) {
          Navigator.pop(_context);
          showErrorLog(e.toString());
          showCenterToast(errorApiCall);
        }
      } else {
        showCenterToast('Vehicle Number should be 5 digit only.');
      }
    }
  }

  Future apiCallForAddPackage() async {
    final SharedPreferences prefs = await _prefs;
    if (prefs.getBool(SP_IS_LOGIN_BOOL) != null) {
       userId = prefs.getInt(SP_ID)!;
      apiToken = prefs.getString(SP_API_TOKEN)!;
    }

    var map = new Map<String, dynamic>();
    map["appType"] = Platform.operatingSystem.toUpperCase();
    map["user_id"] = userId.toString();
    map["api_token"] = apiToken;
    map["date"] = DateFormat('yyyy/MM/dd').format(widget.date.toUtc());
    map["received"] = receivedController.text;
    map["delivered"] = deliveredController.text;
    map["remark"] = '';
    map["total_packages_received"] = '2';
    map["total_delivered"] = '2';
    map["wrong_customer_details"] = wrongController.text;
    map["customer_not_available"] = customerNotAvailController.text;
    map["rescheduled"] = rescheduledController.text;
    map["cancelled"] = cancelledController.text;
    map["not_attempted"] = notAttemptedController.text;
    map['isdeleted'] = '0';
    map["comment"] = commentController.text;
    map['status'] = '0';
    map['cash_on_delivery'] = (isCash) ? cashController.text : '0.0';

    BuildContext _context = context;

    print(map);
    try {
      showLoader(_context);
      _networkUtil.post(apiDriverDeliveryInsert, body: map).then((dynamic res) {
        try {
          Navigator.pop(_context);
          AppLog.showLog(res.toString());
          UpdatePackageApiCallBack _updatePackageApiCallBack =
              UpdatePackageApiCallBack.fromJson(res);
          if (_updatePackageApiCallBack.status == unAuthorised) {
            logout(context);
          } else if (_updatePackageApiCallBack.success) {
            apiCallForAdd();
            // currentDate = DateFormat('yyyy/MM/dd')
            //     .format(DateTime.parse(_updatePackageApiCallBack.currentTime));
            // prefs.setString(SP_DRIVER_PACKAGE_UPLOAD_DATE, currentDate);
            // showBottomToast(_updatePackageApiCallBack!.message);
            // Navigator.of(context).pop({'reload': true});
          } else {
            showBottomToast(_updatePackageApiCallBack.message);
          }
        } catch (es) {
          showErrorLog(es.toString());
          showCenterToast(errorApiCall);
          //Navigator.pop(_context);
        }
        setState(() {});
      });
    } catch (e) {
      Navigator.pop(_context);
      showErrorLog(e.toString());
      showCenterToast(errorApiCall);
    }
    // } else {
    //   showBottomToast(remainingPackage);
    // }
  }

  Future apiCallForAdd() async {
    final SharedPreferences prefs = await _prefs;
    if (prefs.getBool(SP_IS_LOGIN_BOOL) != null) {
       userId = prefs.getInt(SP_ID)!;
      apiToken = prefs.getString(SP_API_TOKEN)!;
    }

    var map = new Map<String, dynamic>();
    map["appType"] = Platform.operatingSystem.toUpperCase();
    map["userId"] = userId.toString();
    map["api_token"] = apiToken;
    map["reason"] = _reason;
    map["inTime"] = DateFormat('yyyy-MM-dd HH:mm:ss').format(
        DateFormat("yyyy-MM-dd HH:mm:ss")
            .parse('$_date ${_inTime!.hour}:${_inTime!.minute}:00')
            .toUtc());
    map["outTime"] = DateFormat('yyyy-MM-dd HH:mm:ss').format(
        DateFormat("yyyy-MM-dd HH:mm:ss")
            .parse('$_date ${_outTime!.hour}:${_outTime!.minute}:00')
            .toUtc());

    map["punchDate"] = _date;
    map['workFromId'] = dropDownValue;
    print(map);
    try {
      showLoader(context);
      _networkUtil.post(apiAttendanceRequest, body: map).then((dynamic res) {
        Navigator.pop(context);
        try {
          AppLog.showLog(res.toString());
          MarkAttendanceApiCallBack markAttendanceApiCallBack =
              MarkAttendanceApiCallBack.fromJson(res);
          if (markAttendanceApiCallBack.status == unAuthorised) {
            logout(_context);
          } else if (markAttendanceApiCallBack.success) {
            showBottomToast(markAttendanceApiCallBack.message);
            Navigator.of(context).pop({'reload': true});
          } else {
            showBottomToast(markAttendanceApiCallBack.message);
          }
        } catch (es) {
          showErrorLog(es.toString());
          showCenterToast(errorApiCall);
        }
        setState(() {});
      });
    } catch (e) {
      Navigator.pop(context);
      showErrorLog(e.toString());
      showCenterToast(errorApiCall);
    }
  }

  void validateTime() {
    if (_outTime != null) {
      int workingHours =
          DateTime.parse('$_date ${_outTime!.hour}:${_outTime!.minute}:00')
              .difference(
                  DateTime.parse('$_date ${_inTime!.hour}:${_inTime!.minute}:00'))
              .inMinutes;
      if (workingHours <= 0) {
        showCenterToast(
            'Out time must be after in Time ${_inTime!.hour}:${_inTime!.minute} ');
        _outTime = null;
        setState(() {});
      }
    }
  }

  Future apiCallForGetWorkingType() async {
    final SharedPreferences prefs = await _prefs;
    if (prefs.getBool(SP_IS_LOGIN_BOOL) != null) {
       userId = prefs.getInt(SP_ID)!;
      companyId = prefs.getInt(SP_COMPANY_ID)!;
      apiToken = prefs.getString(SP_API_TOKEN)!;
      isDriver = prefs.getInt(SP_DRIVER)!;
    }
    var map = new Map<String, dynamic>();
    map["api_token"] = apiToken;
    map["appType"] = Platform.operatingSystem.toUpperCase();
    map["userId"] = '$userId';
    map["companyId"] = '$companyId';
    map['isDiver'] = isDriver.toString();
    print('WORK: $map');
    try {
      //_noDataFound = 'Loading...';
      _networkUtil.post(apiGetWorkingTypeList, body: map).then((dynamic res) {
        //_noDataFound = noDataFound;
        try {
          AppLog.showLog(res.toString());
          _workingTypeApiCallBack = WorkingTypeApiCallBack.fromJson(res);
          if (_workingTypeApiCallBack!.status == unAuthorised) {
            logout(context);
          } else if (!(_workingTypeApiCallBack!.success ?? false)) {
            showBottomToast(_workingTypeApiCallBack!.message ?? "");
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
      //_noDataFound = noDataFound;
      setState(() {});
    }
  }
}

class MarkAttendanceApiCallBack {
  Items? items;
  String message;
  int status;
  bool success;
  int total_count;

  MarkAttendanceApiCallBack(
      {required this.message, required this.status, required this.success, required this.total_count, this.items});

  factory MarkAttendanceApiCallBack.fromJson(Map<String, dynamic> json) {
    return MarkAttendanceApiCallBack(
      items: json['items'] != null ? Items.fromJson(json['items']) : null,
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
    if (this.items != null) {
      data['items'] = this.items!.toJson();
    }
    return data;
  }
}

class Items {
  final String approval_status;
  final String created_at;
  final int id;
  final String inTime;
  final int isdeleted;
  final String outTime;
  final String punchDate;
  final String punchTypeId;
  final String? reason; // Nullable
  final String updated_at;
  final String userId;
  final String? endLongitute; // Add these if you need them
  final String? endLatitude;
  final String? attachment;
  final String? remark;
  final String? approvedBy;

  Items({
    required this.approval_status,
    required this.created_at,
    required this.id,
    required this.inTime,
    required this.isdeleted,
    required this.outTime,
    required this.punchDate,
    required this.punchTypeId,
    required this.userId,
    required this.updated_at,
    this.reason,
    this.endLongitute,
    this.endLatitude,
    this.attachment,
    this.remark,
    this.approvedBy,
  });

  factory Items.fromJson(Map<String, dynamic> json) {
    return Items(
      approval_status: json['approval_status'] ?? '',
      created_at: json['created_at'] ?? '',
      id: json['id'],
      inTime: json['inTime'] ?? '',
      isdeleted: json['isdeleted'],
      outTime: json['outTime'] ?? '',
      punchDate: json['punchDate'] ?? '',
      punchTypeId: '${json['punchTypeId']}',
      userId: '${json['userId']}',
      updated_at: json['updated_at'] ?? '',
      reason: json['reason'],
      endLongitute: json['endLongitute'],
      endLatitude: json['endLatitude'],
      attachment: json['attachment'],
      remark: json['remark'],
      approvedBy: json['approvedBy'],
    );
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = {};
    data['approval_status'] = approval_status;
    data['created_at'] = created_at;
    data['id'] = id;
    data['inTime'] = inTime;
    data['isdeleted'] = isdeleted;
    data['outTime'] = outTime;
    data['punchDate'] = punchDate;
    data['punchTypeId'] = punchTypeId;
    data['userId'] = userId;
    data['updated_at'] = updated_at;
    data['reason'] = reason;
    data['endLongitute'] = endLongitute;
    data['endLatitude'] = endLatitude;
    data['attachment'] = attachment;
    data['remark'] = remark;
    data['approvedBy'] = approvedBy;
    return data;
  }
}
