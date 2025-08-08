import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_downloader/flutter_downloader.dart';
import 'package:hrms/appUtil/app_providers.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

//import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'appUtil/app_util_config.dart';
import 'app_splash_screen.dart';
import 'package:provider/provider.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  FlutterDownloader.initialize(
      debug: true // optional: set false to disable printing logs to console
      );
  runApp(MyApp());
  //initializeNotification();
}



class MyApp extends StatefulWidget {
  @override
  _MyAppState createState() => _MyAppState();
}

class Counter with ChangeNotifier, DiagnosticableTreeMixin {
  int _count = 0;

  int get count => _count;

  void increment() {
    _count++;
    notifyListeners();
  }

  /// Makes `Counter` readable inside the devtools by listing all of its properties
  @override
  void debugFillProperties(DiagnosticPropertiesBuilder properties) {
    super.debugFillProperties(properties);
    properties.add(IntProperty('count', count));
  }
}

class _MyAppState extends State<MyApp> {
  //  MethodChannel('crossingthestreams.io/resourceResolver');

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
        providers: [
//          ChangeNotifierProvider(builder: (_) => Counter()),
          ChangeNotifierProvider<ApiLoader>(
            create: (_) => ApiLoader(),
          ),
        ],
        child: ScreenUtilInit(
            designSize: Size(375, 812),
            builder: (context, _) => MaterialApp(
                  title: 'HRMS',
                  debugShowCheckedModeBanner: false,
                  theme: new ThemeData(
                    primarySwatch: Colors.grey,
                    canvasColor: Colors.white,
                    brightness: Brightness.light,
                    primaryColor: appPrimaryColor,
                    primaryColorDark: appPrimaryDarkColor,
                    hintColor: appPrimaryDarkColor,
                    fontFamily: 'Montserrat',
                  ),
                  home: new AppSplashScreen(),
                )));
  }

  @override
  void initState() {
    super.initState();
//    new FirebaseNotifications().setUpFirebase();
    //_showNotification();
  }



  @override
  void dispose() {
    super.dispose();
  }
}
