
import 'package:flutter/material.dart';

String appName = 'LEAP HRMS';
String noInternet = 'No internet available';
String appDeviceId ='';

Color appBackground = Color.fromARGB(255, 235, 235, 236);
Color appAccentColor = Color(0xFF4caf50);
Color chartRed = Color(0xFFf30f00);
Color colorTextLightGray = Color(0xFF8B9390);
String screenName = '';
// theme set by api... G1
Color appPrimaryColor = Color(0xFFE79B62);
Color btnBgColor = Colors.black;
Color colorText = Color(0xFF212423);
Color colorTextDarkBlue = Color(0xFF2E4552);
Color appDarkPrimaryColor = Color(0xFFB88457);
Color appBottomNavColor = Color(0xFFE79B62);

String bg_IMAGE1 ='';
String bg_IMAGEDefault = 'assets/image/navigation_bg.png';
String bg_profile = 'assets/images/default_bg.png';
String bg_profileDefault = 'assets/image/btn_play_pause.png';

//theme second set by api... G1
// Color appPrimaryColor = Color(0xFF777DA9);
// Color appDarkPrimaryColor = Color(0xFF545989);
// Color btnBgColor = Colors.black;
// Color colorText = Color(0xFF222423);
// Color colorTextDarkBlue = Color(0xFF648A9C);
// Color appBottomNavColor = Color(0xFF648C9D);

//  image: global.bg_profile != null
//                         ? NetworkImage(global.bg_profile)
//                         : AssetImage(global.bg_profileDefault),Color appPrimaryColor = Color(0xFF777DA9);

//theme 3 set by api... G1
// Color appPrimaryColor = Color(0xFF79B695);
// Color appDarkPrimaryColor = Color(0xFF54938B);
// Color btnBgColor = Color(0xFF54938B);
// Color colorText = Color(0xFF212423);
// Color colorTextDarkBlue = Color(0xFF54938B);
// Color appBottomNavColor = Color(0xFF606461);

//theme 4 set by api... G1
// Color appPrimaryColor = Color(0xFFB295AE);
// Color appDarkPrimaryColor = Color(0xFF815B7C);
// Color btnBgColor = Color(0xFF815B7C);
// Color colorText = Color(0xFF212423);
// Color colorTextDarkBlue = Color(0xFF2E4552);
// Color appBottomNavColor = Color(0xFF49526A);

//theme 5 set by api... G1
// Color appPrimaryColor = Color(0xFFCDB4AF);
// Color appDarkPrimaryColor = Color(0xFFA1949F);
// Color btnBgColor = Color(0xFF5A5E76);
// Color colorText = Color(0xFF212423);
// Color colorTextDarkBlue = Color(0xFF2E4552);
// Color appBottomNavColor = Color(0xFF5A5E76);

//theme 5 set by api... G1
// Color appPrimaryColor = Color(0xFFCDB4AF);
// Color appDarkPrimaryColor = Color(0xFFA1949F);
// Color btnBgColor = Color(0xFF5A5E76);
// Color colorText = Color(0xFF212423);
// Color colorTextDarkBlue = Color(0xFF2E4552);
// Color appBottomNavColor = Color(0xFF5A5E76);

AppLifecycleState appLifecycleState = AppLifecycleState.detached;

Widget noRecordFound(String title) {
  return Center(
    child: Container(
      height: 170,
      width: 200,
      alignment: Alignment.center,
      child: Center(
        child: Column(
          children: [
            Image.asset(
              'assets/image/norecord.png',
              width: 150,
              height: 150,
              fit: BoxFit.fill,
              color: appBottomNavColor,
            ),
            Text(title),
          ],
        ),
      ),
    ),
  );
}
