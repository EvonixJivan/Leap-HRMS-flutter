import 'dart:io';

import 'package:flutter/material.dart';
import 'package:hrms/app/mainApp/driver/packageDetails.dart';
import 'package:hrms/app/uiComponent/custom_header.dart';
import 'package:hrms/appUtil/app_util_config.dart';
import 'package:hrms/appUtil/network_util.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:intl/intl.dart';

class AddPackage extends StatefulWidget {
  var scaffoldKey;
  var title;

  AddPackage({Key? key, required this.scaffoldKey, required this.title})
      : super(key: key);

  @override
  _AddPackageState createState() {
    return _AddPackageState();
  }
}

class _AddPackageState extends State<AddPackage> {
  NetworkUtil _networkUtil = NetworkUtil();
  Future<SharedPreferences> _prefs = SharedPreferences.getInstance();
  final GlobalKey<ScaffoldState> _scaffoldKey = new GlobalKey<ScaffoldState>();
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  UpdatePackageApiCallBack? _updatePackageApiCallBack;
 String? _received,
      _delivered,
      _comment,
      _wrong,
      _notAvail,
      _rescheduled,
      _cancelled,
      _notAttempt,
      _cash;
 String? formatted;
  //String _remainingCount = '0';
 String? apiToken, today, datePara;
 late int userId;
  bool isCash = false, isVisible = false;

 String? currentDate;
  var formatter = new DateFormat('yyyy-MM-dd');
  var formatterForApi = new DateFormat('yyyy/MM/dd');

  TextEditingController deliveredController = TextEditingController();
  TextEditingController receivedController = TextEditingController();
  TextEditingController commentController = TextEditingController();
  TextEditingController wrongController = TextEditingController();
  TextEditingController customerNotAvailController = TextEditingController();
  TextEditingController rescheduledController = TextEditingController();
  TextEditingController cancelledController = TextEditingController();
  TextEditingController notAttemptedController = TextEditingController();
  TextEditingController cashController = TextEditingController();

  @override
  void initState() {
    super.initState();
    formatted = formatter.format(DateTime.now().toUtc());
    today = formatted;
    datePara = formatterForApi.format(DateTime.now().toUtc());
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
    map["date"] = DateFormat('yyyy/MM/dd').format(DateTime.now().toUtc());
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
          _updatePackageApiCallBack = UpdatePackageApiCallBack.fromJson(res);
          if (_updatePackageApiCallBack!.status == unAuthorised) {
            logout(context);
          } else if (_updatePackageApiCallBack!.success) {
            currentDate = DateFormat('yyyy/MM/dd')
                .format(DateTime.parse(_updatePackageApiCallBack!.currentTime));
            prefs.setString(SP_DRIVER_PACKAGE_UPLOAD_DATE, currentDate ?? "");
            showBottomToast(_updatePackageApiCallBack!.message);
            Navigator.of(context).pop({'reload': true});
          } else {
            showBottomToast(_updatePackageApiCallBack!.message);
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
                _received = value;
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
                _delivered = value;
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
                _wrong = value;
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
                _notAvail = value;
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
                _rescheduled = value;
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
                _cancelled = value;
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
                _notAttempt = value;
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
                _comment = value!;
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
        visible: isVisible,
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
                    _cash = value;
                  });
                },
              )),
        ));

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
       top: false,
        bottom: true,
      child: Scaffold(
        body: GestureDetector(
          child: Container(
            color: appBackgroundDashboard,
            child: Stack(
              children: <Widget>[
                CustomHeaderWithBackGreen(
                    scaffoldKey: widget.scaffoldKey, title: widget.title),
                Container(
                  padding: EdgeInsets.only(left: 8, right: 8),
                  margin: EdgeInsets.only(top: 90),
                  child: ListView(
                    children: <Widget>[
                      new Card(
                        elevation: 2,
                        child: Padding(
                          padding: EdgeInsets.fromLTRB(7, 7, 7, 7),
                          child: Text(
                            DateFormat('dd MMM, yyyy')
                                .format(DateTime.now().toUtc()),
                            style: TextStyle(
                                color: Color.fromRGBO(255, 81, 54, 1),
                                fontSize: 20.0),
                            textAlign: TextAlign.center,
                          ),
                        ),
                      ),
                      Card(
                        margin: EdgeInsets.only(
                            top: ScreenUtil().setSp(10),
                            left: ScreenUtil().setSp(8),
                            right: ScreenUtil().setSp(8),
                            bottom: ScreenUtil().setSp(30)),
                        elevation: 5,
                        child: Form(
                          key: _formKey,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: <Widget>[
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
                                  controlAffinity:
                                      ListTileControlAffinity.leading,
                                  value: isCash,
                                  onChanged: (bool? newValue) {
                                    setState(() {
                                      isCash = newValue!;
                                      if (isCash == true) {
                                        isVisible = true;
                                      } else {
                                        isVisible = false;
                                      }
                                    });
                                  },
                                ),
                              ),
                              cashText,
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
                  ),
                )
              ],
            ),
          ),
          onTap: () {
            FocusScope.of(context).requestFocus(new FocusNode());
          },
        ),
      ),
    );
  }

  // Widget headingText(String name) {
  //   return Padding(
  //     padding: EdgeInsets.only(
  //         left: ScreenUtil().setSp(10),
  //         top: ScreenUtil().setSp(10),
  //         right: ScreenUtil().setSp(10)),
  //     child: Text(
  //       name,
  //       style: TextStyle(
  //           fontWeight: FontWeight.w500, fontSize: ScreenUtil().setSp(15)),
  //     ),
  //   );
  // }

  // calculateRemainingCount(String received, String delivered) {
  //   _remainingCount = '';
  //   int rec = int.parse(received);
  //   int del = int.parse(delivered);
  //   int rem;
  //   if (del > rec) {
  //     showBottomToast('Delivered should be less than received');
  //     rem = 0;
  //   } else {
  //     rem = rec - del;
  //   }
  //   _remainingCount = rem.toString();
  //   print(_remainingCount);
  //   return _remainingCount;
  // }

  // bool validateRemainingCount(String wrong, String notAvail, String rescheduled,
  //     String cancelled, String notAttempt) {
  //   int rem = int.parse(_remainingCount);
  //   int wrongInt = int.parse(wrong);
  //   int notAvailable = int.parse(notAvail);
  //   int res = int.parse(rescheduled);
  //   int cancel = int.parse(cancelled);
  //   int notAttemptInt = int.parse(notAttempt);
  //   int pending = wrongInt + notAvailable + res + cancel + notAttemptInt;
  //   if (rem < pending) {
  //     showBottomToast(remainingPackage);
  //     return false;
  //   } else {
  //     return true;
  //   }
  // }
}
