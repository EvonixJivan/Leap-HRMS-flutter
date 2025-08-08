import 'dart:async';
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:hrms/app/auth/login.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

/// for network
const isProd = true;

// const basePath = (isProd)
//     ? 'http://aipex.co/hrmsApi/api/v2/'
//     : 'http://hrmsdevelopment.aipex.co/hrms_web_backend/api/v2/'; //for dev
// const basePath = (isProd)
//     ? 'http://aipex.co/hrmsApi/api/v2/'
//     : 'http://aipex.co/hrmsDev/api/v2/'; //for dev

const basePath = (isProd)
    ? 'http://aipex.co/hrmsApi/api/v2/'
    // :'http://aipex.co/hrmsApi/api/v2/';
    : 'https://leaphrms.com/backend/api/v2/';
// : 'http://aipex.co/hrmsDev/api/v2/'; //for dev

/// for error messages
const errorApiCall = 'Error to process. Please try again.'; //for Prod
const noDataFound = 'Record not found'; //for Prod
const remainingPackage =
    'The remaining packages and sum of Others (Wrong Customer Details, Customer Not available, Rescheduled, Cancelled & Not Attempted) are not equal'; //for Prod
const unAuthorised = 401;
const bufferTime = 3;
const androidVersion = '10'; //app_version_code compare with api
const iosVersion = 1.5; //app_build_version compare with api
const appVersionName = '1.0.8';

const String getAppVersion = basePath + 'getAppVersion';

/// api list
const String apiLogin = basePath + 'login';
const String apiLoginWithFlag = basePath + 'loginwithFlag';
const String apiForgotPassword = basePath + 'forgotPassword';

//Leave
const String apiLeaveType = basePath + 'leave-type';
const String apiLeaveTypeNew = basePath + 'leave-type';
const String apiAddLeave = basePath + 'leave-add';
const String apiUserLeave = basePath + 'userLeave';
const String getTotalLeaveCount = basePath + 'getTotalLeaveCount';
const String apigetEmployeelistWithTeamLead =
    basePath + 'getEmployeelistWithTeamLead';
const String apiLeaveUpdate = basePath + 'leave-update';

//Meeting
const String apiMeetingList = basePath + 'meeting-getByDate';
const String apiAddMeeting = basePath + 'meeting-add';

//Attendance
const String apiAttendanceList = basePath + 'attendance-get';
const String apiAttendanceListNew = basePath + 'attendance-get-with-flag';
const String apiAttendanceSingle = basePath + 'attendance-single';
const String apiGetWorkingTypeList = basePath + 'getWorkingTypeList';

///Start 1 pause 2, resume 3 & stop 4
const String apiAttendanceMark = basePath + 'attendance-app';
const String apiAttendanceRequest = basePath + 'mark-attendance';
const String apiTrackingAdd = basePath + 'geoTraking-add';
const String apiTrackingAddNew = basePath + 'geoTraking-add-single';

///Birthday
const String apiGetBirthdayData = basePath + 'get-birthday-data';
const String apiGetTodaysBirthday = basePath + 'get-Todays-birthday';

///Profile
const String apiUserInformation = basePath + 'userInformation';
const String apiResetPassword = basePath + 'resetPassword';

///Document
const String apiGetDocumentCategory = basePath + 'get-document-category';
const String apiDocumentGet = basePath + 'document-get';
const String apiOrganizationDocumentGet =
    basePath + 'organization_document-get';

///Notification
const String apiGetNotification = basePath + 'get_notification';

///Holiday
const String apiGetHoliday = basePath + 'holiday-get';

///TaskManager
const String apiGetTaskList = basePath + 'getTaskList';
const String apiDeleteTask = basePath + 'deleteTask';
const String apiEditTask = basePath + 'editTask';
const String apiGetClientList = basePath + 'getClientList';
const String apiGetProjectList = basePath + 'getProjectList';
const String apiAddTask = basePath + 'addTask';
const String apiAddToDoTask = basePath + 'addToDoTask';
const String apiGetTodoList = basePath + 'getToDoList';
const String apiDeleteToDoTask = basePath + 'deleteToDoTask';
const String apiChangeToDoTaskStatus = basePath + 'changeTaskStatus';
const String apiGetEmployeelist = basePath + 'getEmployeelist';
const String apiGetEmployeeTask = basePath + 'getEmployeeTask';
const String apiChangeTaskStatus = basePath + 'changeTaskStatus';
const String apiGetTaskType = basePath + 'getTaskType';
const String apiTaskCommentsGet = basePath + 'task-comments-get';
const String apiTaskCommentsInsert = basePath + 'task-comments-insert';

///Driver
const String apiGetDeliveryList = basePath + 'get_delivery_list';
const String apiDriverDeliveryUpdate = basePath + 'driver_delivery_update';
const String apiDriverDeliveryInsert = basePath + 'driver_delivery_insert';
const String apiGetVehicleDetails = basePath + 'get_vehicle_details';
const String apiVehicleDetailsInsert = basePath + 'user_vehicle_log_insert';

///Feedback
const String apiAddFeedback = basePath + 'addFeedback';
const String apiGetMyFeedbackList = basePath + 'getMyFeedbackList';
const String apiUpdateFeedbackstatus = basePath + 'updateFeedbackstatus';
const String apiTracking =
    'http://52.66.104.246/track/api/external/v1/events?imei=0355172100480688&key=4179a52b4e997e24645b79ecee6fee05&utcoffset=19800&startdate=2021-07-26 13:00&enddate=2021-07-26 16:20';

///G1...
const String apiAddDoc = basePath + 'organization-document-insert';
const String apiSingleLeave = basePath + 'leave-single';

class NetworkUtil {
  // next three lines makes this class a Singleton
  static NetworkUtil _instance = new NetworkUtil.internal();

  NetworkUtil.internal();

  factory NetworkUtil() => _instance;

  final JsonDecoder _decoder = new JsonDecoder();

  Future<dynamic> get(String url) {
    Uri myUri = Uri.parse(url);
    return http.get(myUri).then((http.Response response) {
      final String res = response.body;
      final int statusCode = response.statusCode;

      if (statusCode < 200 || statusCode > 400) {
        throw new Exception("Error while fetching data");
      }
      return _decoder.convert(res);
    });
  }

  Future<dynamic> post( String url, {  Map<String, String>? headers, Object? body,Encoding? encoding,
  }) async {
    Uri myUri = Uri.parse(url);
    print('URL --> $url');
    print('Body --> $body');

    try {
      final response = await http.post(
        myUri,
        headers: headers,
        body: body,
        encoding: encoding,
      );

      final statusCode = response.statusCode;
      print("StatusCode --> $statusCode");

      if (statusCode == 500) {
        return null;
      }

      if (statusCode < 200 || statusCode > 400) {
        throw Exception("Error while fetching data: $statusCode");
      }

      print('$url API Response: ${response.body}');
      return jsonDecode(response.body);

    } catch (e) {
      print("HTTP Post Error: $e");
      rethrow;
    }
  }
}

Future<SharedPreferences> _prefs = SharedPreferences.getInstance();

void logout(BuildContext context) async {
  final SharedPreferences prefs = await _prefs;
  prefs.clear();
  Navigator.pushAndRemoveUntil(
      context,
      PageRouteBuilder(pageBuilder: (BuildContext context, Animation animation,
          Animation secondaryAnimation) {
        return LoginScreen();
      }, transitionsBuilder: (BuildContext context, Animation<double> animation,
          Animation<double> secondaryAnimation, Widget child) {
        return new SlideTransition(
          position: new Tween<Offset>(
            begin: const Offset(1.0, 0.0),
            end: Offset.zero,
          ).animate(animation),
          child: child,
        );
      }),
      (Route route) => false);
}
