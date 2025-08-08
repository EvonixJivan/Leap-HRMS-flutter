import 'dart:math' as mt;
import 'dart:math';

// import 'package:flat_icons_flutter/icon_data.dart';
import 'package:flutter_vector_icons/flutter_vector_icons.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:hrms/appUtil/network_util.dart';
import 'package:percent_indicator/linear_percent_indicator.dart';

//App Color
const Color appPrimaryDarkColor = Color(0xFF000000);
const Color appAccentColor = Color(0xFF4caf50);
// const Color appPrimaryColor = Color(0xFFFE6819);
const Color appPrimaryColor = Color(0xFFE79B62);
const Color tfBackgroundColor = Colors.white;
const Color btnBgColor = Colors.black;
const Color colorText = Color(0xFF212423);
const Color colorTextDarkBlue = Color(0xFF2E4552);
const Color appBackgroundColor = Color(0xFFFAFAFA);
const Color appDarkPrimaryColor = Color.fromARGB(255, 184, 132, 87);

const String font = 'Montserrat-Regular"';
const String fontmedium = 'Montserrat - Medium';

//App color list
const Color chartGreen = Color(0xFF4caf50);
const Color chartGray = Color(0xFF808b97);
const Color chartRed = Color(0xFFf30f00);
const Color appNavigationHeader = Color(0xFFCC2815);
const Color chartYellow = Color(0xFFfb9900);
const Color appWhiteColor = Colors.white;
const Color appColorOne = Color(0xFFEA5A61);
const Color appColorTwo = Color(0xFF2FBD80);
const Color appColorThree = Color(0xFFED9C2F);
const Color appColorFour = Color(0xFF57C98A);
const Color appColorFive = Color(0xFF5AA5F2);
const Color appColorBlueProgressBar = Color(0xFF2762D8);
const Color appColorRedIcon = Color(0xFFCC2815);
const Color appColorBlackText = Color(0xFF707070);
const Color appColorStartAttendance = Color(0xFFBCB0B0);
// const Color appBackground = Color(0xFFfff1e3);
const Color appBackground = Color.fromARGB(255, 235, 235, 236);

const Color appBackgroundDark = Color(0xFFE0E0E0);
const Color appBackgroundDashboard = Color(0x11720629);
const Color appColorRADIO = Color(0xFA009DA0);

/// for share preference
const PROJECT_VERSION = '1.6'; //'1.3.0';Change by g1
const SP_IS_LOGIN_BOOL = 'spIsLoginBool';
const SP_ID = 'id';
const spLoginStatusInt = 'spLoginStatusInt';
const SP_API_TOKEN = 'api_token';
const SP_LAST_NAME = 'last_name';
const SP_EMAIL = 'email';
const SP_CONTACT_NO = 'contact_no';
const SP_PROFILE_IMAGE = 'profileImage';
const SP_FIRST_NAME = 'first_name';
const SP_version = 'projectversion';
const SP_ROLE = 'role';
const SP_TOKEN = 'sp_token';
const SP_ATTENDANCE_SELFIE = 'attendance_selfie';
const SP_COMPANY_ID = 'company_id';
const SP_COMPANY_NAME = 'company_name';
const SP_LOCATION_TRACKING = 'location_tracking';
const SP_LOCATION_TRACKING_DURATION = 'location_tracking_duration';
const TASK_MANAGER = 'task_manager';
const SP_DRIVER = 'driver_delivery';
const GEOFENCING = 'geofencing';
const LATITUDE = 'latitude';
const LONGITUDE = 'longitude';
const DISTANCE = 'distance';
const DEVICE_ID = 'deviceId';
const APPROVE_TASK = 'approve_task';
const TEAM_LEAD_ID = 'team_lead_id';
const SP_COMPANY_LOGO = 'company_logo';

const SP_BUFFER_LEAVE = 'no_of_days_limit_for_leave';
const SP_BUFFER_ATTENDANCE = 'no_of_days_limit_for_mark_attendance';
const SP_GOOGLE_SECRATE_CODE = 'google_secrate_code';
const SP_HELPLINE_NO = 'items.helpline_no';

///for Attendance
//0 =not stated/ 1 stated /2 pause /3 resume /4 stop
const SP_ATTENDANCE_STATUS = 'atd_status';
const SP_ATTENDANCE_DATE = 'atd_date';
const SP_ATTENDANCE_IN_TIME = 'atd_in_time';
const SP_ATTENDANCE_IN_TIME_DATE = 'atd_in_time_date';
const SP_ATTENDANCE_OUT_TIME_DATE = 'atd_out_time_date';
const SP_ATTENDANCE_OUT_TIME = 'atd_out_time';
const SP_ATTENDANCE_ID = 'atd_server_id';
const SP_TRACKER_IN_TIME = 'tracker_in_time';
const SP_TRACKER_OUT_TIME = 'tracker_out_time';
//atd_status 2 break stated / atd_status 3 break stop
const SP_ATTENDANCE_BREAK_ID = 'atd_break_server_id';

const SP_NEWS_ID = 'id';
const SP_NEWS_TITLE = 'title';
const SP_NEWS_MESSAGE = 'message';
const SP_NEWS_URL = 'image_url';
const SP_NEWS_VIDEOCODE = 'youtube_video_code';
const SP_NEWS_START = 'news_start_time';
const SP_NEWS_END = 'news_end_time';

const SP_VEHICLE_SELECTION_UPLOAD_DATE = 'vehicle_selection_upload_date';
const SP_DRIVER_PACKAGE_UPLOAD_DATE = 'driver_package_upload_date';

///end

const spUserName = 'spUserName';

const TextStyle splashTitle = TextStyle(
    fontWeight: FontWeight.bold, fontSize: 30.0, color: appPrimaryColor);
const TextStyle titleStyle =
    TextStyle(color: Colors.black, fontWeight: FontWeight.bold, fontSize: 18.0);
const TextStyle singleLabel =
    TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 30.0);
const TextStyle subTitleStyle =
    TextStyle(color: Colors.black, fontWeight: FontWeight.bold, fontSize: 15.0);
const TextStyle labelStyle = TextStyle(
    color: Colors.black, fontWeight: FontWeight.normal, fontSize: 13.0);
const TextStyle smallStyle = TextStyle(
    color: Colors.black, fontWeight: FontWeight.normal, fontSize: 10.0);
const TextStyle cartTitleStyle = TextStyle(
    color: appPrimaryColor, fontWeight: FontWeight.bold, fontSize: 24.0);
const TextStyle cartSubTitleStyle = TextStyle(
    color: appPrimaryColor, fontWeight: FontWeight.bold, fontSize: 18.0);
const TextStyle cardBodyTextStyle = TextStyle(
    color: Color(0xFF616161), fontWeight: FontWeight.normal, fontSize: 13.0);
const TextStyle dateTimeTextStyle = TextStyle(
    color: Color(0xFF616161), fontWeight: FontWeight.normal, fontSize: 11.0);
const TextStyle chatText = TextStyle(color: Colors.black, fontSize: 15.0);
const TextStyle cardLinkTextStyle = TextStyle(
    color: Colors.blueAccent, fontWeight: FontWeight.normal, fontSize: 13.0);
const TextStyle flatIconMenu = TextStyle(
    fontFamily: 'Flaticon', fontWeight: FontWeight.normal, fontSize: 24.0);
// const IconData flat_dashboard = const FlatIconsArrows(0xf109);
// const IconData flat_source_analytics = const FlatIconsArrows(0xf109);
// const IconData flat_in_depth_analytics = const FlatIconsArrows(0xf109);
// const IconData flat_forensic_view = const FlatIconsArrows(0xf109);
// const IconData flat_domain_info = const FlatIconsArrows(0xf109);
const IconData flat_dashboard = MaterialCommunityIcons.view_dashboard;
const IconData flat_source_analytics = MaterialCommunityIcons.chart_box_outline;
const IconData flat_in_depth_analytics = MaterialCommunityIcons.chart_timeline_variant;
const IconData flat_forensic_view = MaterialCommunityIcons.file_search_outline;
const IconData flat_domain_info = MaterialCommunityIcons.domain;

class AppBaseConfig {
  static Color getColor() {
    mt.Random rnd = new mt.Random();
    int min = 0, max = 4;
    int r = min + rnd.nextInt(max - min);
    switch (r) {
      case 0:
        return appColorOne;
      case 1:
        return appColorThree;
      case 2:
        return appColorTwo;
      case 3:
        return appColorFour;
      case 4:
        return appColorFive;
    }

    return appPrimaryColor;
  }

//
//  static const IconData flat_dashboard = const FlatIconsArrows(0xf109);
//  static const IconData flat_source_analytics = const FlatIconsArrows(0xf109);
//  static const IconData flat_in_depth_analytics = const FlatIconsArrows(0xf109);
//  static const IconData flat_forensic_view = const FlatIconsArrows(0xf109);
//  static const IconData flat_domain_info = const FlatIconsArrows(0xf109);

  static TextStyle title = TextStyle(
      color: appPrimaryColor, fontWeight: FontWeight.bold, fontSize: 22.0);
  static TextStyle titleNew = TextStyle(
      color: appPrimaryColor, fontWeight: FontWeight.bold, fontSize: 20.0);
  static TextStyle flatIcon =
      TextStyle(color: appPrimaryColor, fontFamily: 'Flaticon', fontSize: 30.0);
  static TextStyle customFlatIcon = TextStyle(
      color: appPrimaryColor, fontFamily: 'FlaticonEmail', fontSize: 30.0);
  static TextStyle flatIconMenu = TextStyle(
      fontFamily: 'Flaticon', fontWeight: FontWeight.normal, fontSize: 24.0);
}

 class AppLog {
  static bool showLog(String data) {
    print(data);
    return true;
  }

}

class AppToast {
   static void showCenterToast(String data) {
    print(data);
    Fluttertoast.showToast(
      msg: data,
      toastLength: Toast.LENGTH_SHORT,
      gravity: ToastGravity.CENTER,
      backgroundColor: Colors.red,
      textColor: Colors.white,
      fontSize: 16.0,
    );
  }
}

showErrorLog(String data) {
  print(data);
}

showCenterToast(String data) {
  Fluttertoast.showToast(
      msg: data,
      toastLength: Toast.LENGTH_SHORT,
      gravity: ToastGravity.CENTER,
//      timeInSecForIos: 1,
      backgroundColor: Colors.orange,
      textColor: Colors.white,
      fontSize: 16.0);
}

showBottomToast(String data) {
  print(data);
  showCenterToast(data);
}

class AppUtil {
  static bool _isDev = true;
  static bool _isSearch = false;

  static bool isEmail(String em) {
    if (em.isEmpty) return false;
    String p =
        r'^(([^<>()[\]\\.,;:\s@\"]+(\.[^<>()[\]\\.,;:\s@\"]+)*)|(\".+\"))@((\[[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\])|(([a-zA-Z\-0-9]+\.)+[a-zA-Z]{2,}))$';

    RegExp regExp = new RegExp(p);

    return regExp.hasMatch(em);
  }

  static String getBasePath() {
    return (_isDev) ? "http://dev.mg360.io/api/" : "http://dev.mg360.io/api/";
  }

  static bool getIsSearch() {
    return _isSearch;
  }

  static setIsSearch(bool isSearch) {
    _isSearch = isSearch;
  }

  static Color getColor() {
    mt.Random rnd = new mt.Random();
    int min = 0, max = 4;
    int r = min + rnd.nextInt(max - min);
    switch (r) {
      case 0:
        return appColorOne;
      case 1:
        return appColorThree;
      case 2:
        return appColorTwo;
      case 3:
        return appColorFour;
      case 4:
        return appColorFive;
    }

    return appPrimaryColor;
  }
}

String getDateTime(String strDate, String format) {
  if (format == 'H:m:s') {
    return '${DateTime.parse(strDate).hour.toString().padLeft(2, '0')}:'
        '${DateTime.parse(strDate).minute.toString().padLeft(2, '0')}:'
        '${DateTime.parse(strDate).second.toString().padLeft(2, '0')}';
  } else if (format == 'yyyy-MM-dd') {
    return '${DateTime.parse(strDate).year.toString()}-'
        '${DateTime.parse(strDate).month.toString().padLeft(2, '0')}-'
        '${DateTime.parse(strDate).day.toString().padLeft(2, '0')}';
  }
  return '${DateTime.parse(strDate).hour.toString().padLeft(2, '0')}:'
      '${DateTime.parse(strDate).minute.toString().padLeft(2, '0')}:'
      '${DateTime.parse(strDate).second.toString().padLeft(2, '0')}';
  return '';
}

class UniqueColorGenerator {
  static Random random = new Random();

  static Color getColor() {
    return Color.fromARGB(
        255, random.nextInt(255), random.nextInt(255), random.nextInt(255));
  }
}

Widget getProgressBar(String percent, var per) {
  double percentInDouble = per / 100;
  return LinearPercentIndicator(
    animation: true,
    lineHeight: 12.0,
    animationDuration: 2500,
    percent: percentInDouble,
    center: Text(
      percent,
      style: TextStyle(fontSize: 10),
    ),
    linearStrokeCap: LinearStrokeCap.roundAll,
    progressColor: Colors.green,
    clipLinearGradient: true,
  );
}

/// Calendar
monthNameWidget(monthName) {
  return Container(
    child: Text(monthName,
        style: TextStyle(
            fontSize: 15,
            fontWeight: FontWeight.w600,
            color: Colors.black87,
            fontStyle: FontStyle.italic)),
    padding: EdgeInsets.only(top: 4, bottom: 2),
  );
}

dateTileBuilder(
    date, selectedDate, rowIndex, dayName, isDateMarked, isDateOutOfRange) {
  bool isSelectedDate = date.compareTo(selectedDate) == 0;
  Color fontColor =
      isDateOutOfRange ? Color.fromRGBO(255, 81, 54, 0.5) : Colors.black87;
  TextStyle normalStyle =
      TextStyle(fontSize: 14, fontWeight: FontWeight.w500, color: fontColor);
  TextStyle selectedStyle =
      TextStyle(fontSize: 14, fontWeight: FontWeight.w500, color: Colors.white);
  TextStyle dayNameStyle = TextStyle(
      fontSize: 14.5, color: !isSelectedDate ? Colors.black87 : Colors.white);
  List<Widget> _children = [
    Text(dayName, style: dayNameStyle),
    Text(date.day.toString(),
        style: !isSelectedDate ? normalStyle : selectedStyle),
  ];

  return AnimatedContainer(
    duration: Duration(milliseconds: 150),
    alignment: Alignment.center,
    padding: EdgeInsets.only(top: 8, left: 5, right: 5, bottom: 5),
    decoration: BoxDecoration(
      color: !isSelectedDate ? Colors.transparent : Colors.green,
      borderRadius: BorderRadius.all(Radius.circular(60)),
    ),
    child: Column(
      children: _children,
    ),
  );
}

//Loader
void showLoader(BuildContext context) {
  showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return StatefulBuilder(builder: (context, setState) {
          return AlertDialog(
            contentPadding: EdgeInsets.all(0),
            shape: RoundedRectangleBorder(
                borderRadius:
                    BorderRadius.all(Radius.circular(ScreenUtil().setSp(10)))),
            content: Column(
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
                    child: Row(
                      children: <Widget>[
                        Text(
                          'Loading....',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                              fontSize: ScreenUtil().setSp(16),
                              fontWeight: FontWeight.bold,
                              color: appWhiteColor),
                        ),
                        Expanded(
                          child: Container(),
                        ),
                      ],
                    )),
                SizedBox(
                  height: 5.0,
                ),
                Row(
                  children: <Widget>[
                    SizedBox(
                      width: 10.0,
                    ),
                    Padding(
                      padding: const EdgeInsets.all(10.0),
                      child: new CircularProgressIndicator(),
                    ),
                    Padding(
                      padding: const EdgeInsets.only(left: 10.0, right: 50.0),
                      child: Text('Please wait....'),
                    ),
                  ],
                ),
                SizedBox(
                  height: 15.0,
                ),
              ],
            ),
          );
        });
      });
}

String remainingCount = '0';
calculateRemainingCount(String received, String delivered) {
  remainingCount = '';
  int rec = int.parse(received);
  int del = int.parse(delivered);
  int rem;
  if (del > rec) {
    showBottomToast('Delivered should be less than received');
    rem = 0;
  } else {
    rem = rec - del;
  }
  remainingCount = rem.toString();
  print(remainingCount);
  return remainingCount;
}

bool validateRemainingCount(String wrong, String notAvail, String rescheduled,
    String cancelled, String notAttempt) {
  int rem = int.parse(remainingCount);
  int wrongInt = int.parse(wrong);
  int notAvailable = int.parse(notAvail);
  int res = int.parse(rescheduled);
  int cancel = int.parse(cancelled);
  int notAttemptInt = int.parse(notAttempt);
  int pending = wrongInt + notAvailable + res + cancel + notAttemptInt;
  if (rem < pending) {
    showBottomToast(remainingPackage);
    return false;
  } else {
    return true;
  }
}

Widget headingText(String name) {
  return Padding(
    padding: EdgeInsets.only(
        left: ScreenUtil().setSp(10),
        top: ScreenUtil().setSp(10),
        right: ScreenUtil().setSp(10)),
    child: Text(
      name,
      style: TextStyle(
          fontWeight: FontWeight.w500, fontSize: ScreenUtil().setSp(15)),
    ),
  );
}
