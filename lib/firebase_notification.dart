//import 'dart:io';
//
//import 'package:firebase_messaging/firebase_messaging.dart';
//import 'package:shared_preferences/shared_preferences.dart';
//
//import 'appUtil/app_util_config.dart';
//
//class FirebaseNotifications {
//  FirebaseMessaging _firebaseMessaging;
//  Future<SharedPreferences> _prefs = SharedPreferences.getInstance();
//
//  void setUpFirebase() {
//    _firebaseMessaging = FirebaseMessaging();
//    firebaseCloudMessaging_Listeners();
//  }
//
//  void firebaseCloudMessaging_Listeners() {
//    if (Platform.isIOS) iOS_Permission();
//
//    _firebaseMessaging.getToken().then((token) {
//      print('TOKEN : $token');
//      saveToken(token);
//    });
//
////    _firebaseMessaging.getToken().then((token) {
////      print(token);
////    });
//
//
//    _firebaseMessaging.configure(
//      onMessage: (Map<String, dynamic> message) async {
//        print('on message $message');
//      },
//    //  onBackgroundMessage: myBackgroundMessageHandler,
//      onResume: (Map<String, dynamic> message) async {
//        print('on resume $message');
//      },
//      onLaunch: (Map<String, dynamic> message) async {
//        print('on launch $message');
//      },
//    );
//  }
//
//  void iOS_Permission() {
//    _firebaseMessaging.requestNotificationPermissions(
//        IosNotificationSettings(sound: true, badge: true, alert: true));
//    _firebaseMessaging.onIosSettingsRegistered
//        .listen((IosNotificationSettings settings) {
//      print("Settings registered: $settings");
//    });
//  }
//
//  void saveToken(String token) async {
//    final SharedPreferences prefs = await _prefs;
//    prefs.setString(
//      SP_TOKEN,
//      token,
//    );
//  }
//
//Future<dynamic> myBackgroundMessageHandler(Map<String, dynamic> message) {
//  if (message.containsKey('data')) {
//    // Handle data message
//    final dynamic data = message['data'];
//  }
//
//  if (message.containsKey('notification')) {
//    // Handle notification message
//    final dynamic notification = message['notification'];
//  }
//
//  // Or do other work
//}
//
//}
