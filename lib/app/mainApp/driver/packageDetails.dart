import 'dart:async';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:hrms/app/uiComponent/custom_header.dart';
import 'package:hrms/appUtil/app_util_config.dart';
import 'package:hrms/appUtil/network_util.dart';
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';

class PackageDetails extends StatefulWidget {
  var scaffoldKey;
  var title;
  int id;
  String delivered;
  String received;
  String date;
  int wrongCust;
  int custNotAvail;
  int rescheduled;
  int cancelled;
  int notAttempted;
  String cash;
  String comment;

  PackageDetails(
      {Key? key,
      required this.scaffoldKey,
      required this.title,
      required this.id,
    required this.delivered,
      required this.received,
      required this.date,
      required this.wrongCust,
      required this.custNotAvail,
      required this.rescheduled,
      required this.cancelled,
      required this.notAttempted,
      required this.cash,
      required this.comment})
      : super(key: key);

  @override
  _PackageDetailsState createState() {
    return _PackageDetailsState();
  }
}

class _PackageDetailsState extends State<PackageDetails> {
  NetworkUtil _networkUtil = NetworkUtil();
  Future<SharedPreferences> _prefs = SharedPreferences.getInstance();
  final GlobalKey<ScaffoldState> _scaffoldKey = new GlobalKey<ScaffoldState>();
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  UpdatePackageApiCallBack? _updatePackageApiCallBack;
  var _noDataFound = 'Loading...';
  //String _remainingCount;
 String? _received,
      _delivered,
      _comment,
      _wrong,
      _notAvail,
      _rescheduled,
      _cancelled,
      _cash,
      _notAttempt;
 String? apiToken;
  String? formatted;
 late int userId, id;
  bool isCash = false, isVisible = false;
  var formatter = new DateFormat('yyyy-MM-dd');
  var formatterForApi = new DateFormat('yyyy/MM/dd');
 String? today, currentDate;
 String? datePara;
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
    formatted = formatter.format(DateTime.now());
    today = formatted;
    datePara = formatterForApi.format(DateTime.now());
    deliveredController.text = widget.delivered;
    receivedController.text = widget.received;
    wrongController.text = '${widget.wrongCust}';
    customerNotAvailController.text = '${widget.custNotAvail}';
    rescheduledController.text = '${widget.rescheduled}';
    cancelledController.text = '${widget.cancelled}';
    notAttemptedController.text = '${widget.notAttempted}';
    cashController.text = (widget.cash == null) ? '0.0' : '${widget.cash}';
    commentController.text = widget.comment;
    calculateRemainingCount(widget.received, widget.delivered);
  }

  @override
  void dispose() {
    super.dispose();
  }

  isEdit() {
    if (widget.date == today) {
      return true;
    } else {
      return false;
    }
  }

  Future apiCallForUpdatePackage() async {
    final SharedPreferences prefs = await _prefs;
    if (prefs.getBool(SP_IS_LOGIN_BOOL) != null) {
       userId = prefs.getInt(SP_ID)!;
      apiToken = prefs.getString(SP_API_TOKEN)!;
    }

    var map = new Map<String, dynamic>();
    map["appType"] = Platform.operatingSystem.toUpperCase();
    map["user_id"] = userId.toString();
    map["api_token"] = apiToken;
    map['id'] = widget.id.toString();
    map["date"] = datePara;
    map["received"] = receivedController.text;
    map["delivered"] = deliveredController.text;
    map["remark"] = '';
    map["total_packages_received"] = receivedController.text;
    map["total_delivered"] = deliveredController.text;
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
      _networkUtil.post(apiDriverDeliveryUpdate, body: map).then((dynamic res) {
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
            keyboardType: TextInputType.number,
            controller: receivedController,
            validator: (value) {
              if (value!.isEmpty) {
                return 'Received count is required';
              }
              return null;
            },
            decoration: InputDecoration(
                border: InputBorder.none,
                hintText: widget.received,
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

    var received = Padding(
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
                Text(widget.received),
              ],
            ),
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
            validator: (String? value) {
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
                hintText: widget.delivered,
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

    var delivered = Padding(
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
                Text(widget.delivered),
              ],
            ),
          )),
    );

    var remaining = Padding(
      padding: EdgeInsets.only(
          left: ScreenUtil().setSp(12),
          top: ScreenUtil().setSp(10),
          right: ScreenUtil().setSp(10),
          bottom: ScreenUtil().setSp(10)),
      child: Row(
        children: <Widget>[
          Text(
            'Packages Remaining : ',
            style: TextStyle(
                fontWeight: FontWeight.w500, fontSize: ScreenUtil().setSp(15)),
          ),
          SizedBox(
            width: ScreenUtil().setSp(5),
          ),
          Text(
            remainingCount,
            style: TextStyle(
                fontWeight: FontWeight.w500, fontSize: ScreenUtil().setSp(15)),
          ),
        ],
      ),
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
                hintText: widget.delivered,
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

    var wrong = Padding(
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
                Text('${widget.wrongCust}'),
              ],
            ),
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
                hintText: widget.delivered,
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

    var customerNotAvailable = Padding(
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
                Text('${widget.custNotAvail}'),
              ],
            ),
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
                hintText: widget.delivered,
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

    var rescheduled = Padding(
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
                Text('${widget.rescheduled}'),
              ],
            ),
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
                hintText: widget.delivered,
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

    var cancelled = Padding(
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
                Text('${widget.cancelled}'),
              ],
            ),
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
                hintText: widget.delivered,
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

    var notAttempted = Padding(
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
                Text('${widget.notAttempted}'),
              ],
            ),
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

    var comment = Padding(
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
                Text('${widget.comment}'),
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

    var cash = Padding(
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
                Text('0')
                //'${widget.cash}'),
              ],
            ),
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
                if (validateRemainingCount(
                    wrongController.text,
                    customerNotAvailController.text,
                    rescheduledController.text,
                    cancelledController.text,
                    notAttemptedController.text)) {
                  apiCallForUpdatePackage();
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

    final okButton = Row(
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
              Navigator.pop(context);
            },
            child: Text('Ok',
                style: TextStyle(
                    color: Colors.white, fontWeight: FontWeight.bold)),
          ),
        ),
        SizedBox(
          width: ScreenUtil().setSp(30),
        ),
      ],
    );

    return Scaffold(
        body: GestureDetector(
      child: Container(
          color: appBackgroundDashboard,
          child: Stack(children: <Widget>[
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
                        widget.date,
                        style: TextStyle(
                            color: Color.fromRGBO(255, 81, 54, 1),
                            fontSize: 20.0),
                        textAlign: TextAlign.center,
                      ),
                    ),
                  ),
                  isEdit()
                      ? Card(
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
                      : Card(
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
                                received,
                                headingText('Total Packages Delivered : '),
                                delivered,
                                headingText('Packages Remaining : '),
                                remaining,
                                headingText('Wrong Customer Details : '),
                                wrong,
                                headingText('Customer Not Available : '),
                                customerNotAvailable,
                                headingText('Rescheduled : '),
                                rescheduled,
                                headingText('Cancelled : '),
                                cancelled,
                                headingText('Not Attempted : '),
                                notAttempted,
                                headingText('Comment : '),
                                comment,
                                headingText('Cash on delivery collection : '),
                                cash,
                                okButton,
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
          ])),
      onTap: () {
        FocusScope.of(context).requestFocus(new FocusNode());
      },
    ));
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

class UpdatePackageApiCallBack {
  final int totalCount;
  final bool success;
  final String message;
  final int status;
  final String currentTime;
  final String currentUtcTime;

  UpdatePackageApiCallBack({
    required this.totalCount,
    required this.success,
    required this.message,
    required this.status,
    required this.currentTime,
    required this.currentUtcTime,
  });

  factory UpdatePackageApiCallBack.fromJson(Map<String, dynamic> json) {
    return UpdatePackageApiCallBack(
      totalCount: json['total_count'],
      success: json['success'],
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
      'message': message,
      'status': status,
      'current_time': currentTime,
      'current_utc_time': currentUtcTime,
    };
  }
}

class Items {
  final int id;
  final int userId;
  final String date;
  final String received;
  final String delivered;
  final String comment;
  final String remark;
  final int status;
  final int totalPackagesReceived;
  final int totalDelivered;
  final int wrongCustomerDetails;
  final int customerNotAvailable;
  final int rescheduled;
  final int cancelled;
  final int notAttempted;
  final int isdeleted;
  final String createdAt;
  final String updatedAt;

  Items({
    required this.id,
    required this.userId,
    required this.date,
    required this.received,
    required this.delivered,
    required this.comment,
    required this.remark,
    required this.status,
    required this.totalPackagesReceived,
    required this.totalDelivered,
    required this.wrongCustomerDetails,
    required this.customerNotAvailable,
    required this.rescheduled,
    required this.cancelled,
    required this.notAttempted,
    required this.isdeleted,
    required this.createdAt,
    required this.updatedAt,
  });

  factory Items.fromJson(Map<String, dynamic> json) {
    return Items(
      id: json['id'],
      userId: json['user_id'],
      date: json['date'],
      received: json['received'],
      delivered: json['delivered'],
      comment: json['comment'],
      remark: json['remark'],
      status: json['status'],
      totalPackagesReceived: json['total_packages_received'],
      totalDelivered: json['total_delivered'],
      wrongCustomerDetails: json['wrong_customer_details'],
      customerNotAvailable: json['customer_not_available'],
      rescheduled: json['rescheduled'],
      cancelled: json['cancelled'],
      notAttempted: json['not_attempted'],
      isdeleted: json['isdeleted'],
      createdAt: json['created_at'],
      updatedAt: json['updated_at'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'user_id': userId,
      'date': date,
      'received': received,
      'delivered': delivered,
      'comment': comment,
      'remark': remark,
      'status': status,
      'total_packages_received': totalPackagesReceived,
      'total_delivered': totalDelivered,
      'wrong_customer_details': wrongCustomerDetails,
      'customer_not_available': customerNotAvailable,
      'rescheduled': rescheduled,
      'cancelled': cancelled,
      'not_attempted': notAttempted,
      'isdeleted': isdeleted,
      'created_at': createdAt,
      'updated_at': updatedAt,
    };
  }
}
