import 'package:community_material_icon/community_material_icon.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:hrms/app/mainApp/attendance/attendance_list.dart';
import 'package:hrms/app/mainApp/driver/driver.dart';
import 'package:hrms/app/mainApp/feedback/feedback.dart';
import 'package:hrms/app/mainApp/holiday/holiday.dart';
import 'package:hrms/app/mainApp/notification/notification.dart';
import 'package:hrms/app/mainApp/task_manager/team_lead/team_members.dart';
import 'package:hrms/app/mainApp/task_manager/view_task.dart';
import 'package:hrms/appUtil/app_util_config.dart';
import 'package:hrms/appUtil/global.dart' as global;
import 'package:hrms/appUtil/network_util.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:url_launcher/url_launcher.dart';

import 'mainApp/birthday/birthday_screen.dart';
import 'mainApp/document/document_list.dart';
import 'mainApp/homePage/home_page.dart';
import 'mainApp/leave/leave_list.dart';
import 'mainApp/meeting/meeting_list.dart';
import 'mainApp/setting/setting.dart';

class DashboardPage extends StatefulWidget {
  String name, email, image;
  String projectVersion = '';

  DashboardPage({
    Key? key,
    required this.name,
    required this.email,
    required this.image,
    required this.projectVersion,
  }) : super(key: key);

  @override
  _DashboardPageState createState() {
    return _DashboardPageState();
  }
}

class _DashboardPageState extends State<DashboardPage> {
  final scaffoldKey = GlobalKey<ScaffoldState>();
  Future<SharedPreferences> _prefs = SharedPreferences.getInstance();
  String _apiToken = "", _helpline = '';
  int _isSelfi = 0,
      _isGeofence = 0,
      _isGeotracking = 0,
      _distance = 0,
      _task_manager = 0,
      _driver_delivery = 0,
      _approve_task = 0;
 String? name, email, image;
  late int userId;
  String? apiToken;
  NetworkUtil _networkUtil = NetworkUtil();

  @override
  void initState() {
    super.initState();
    getSpData();
    getCredential();
    // print("version2--->" + 'App Version ${widget.projectVersion}');
  }

  @override
  void dispose() {
    super.dispose();
  }

  getCredential() async {
    final SharedPreferences prefs = await _prefs;

    if (prefs.getBool(SP_IS_LOGIN_BOOL) != null) {
      name = prefs.getString(SP_LAST_NAME)!;
      email = prefs.getString(SP_EMAIL)!;
      image = prefs.getString(SP_PROFILE_IMAGE)!;
    }
  }

  int _selectedIndexBottom = 2;
  int _selectedIndexSideDrawer = 0;
  static const TextStyle optionStyle =
      TextStyle(fontSize: 30, fontWeight: FontWeight.bold);

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndexBottom = index;
      _selectedIndexSideDrawer = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor:global.appBackground,
      key: scaffoldKey,
      body: Center(
        child: bodyContainer(),
      ),
      bottomNavigationBar: Container(
        height: 105,
        // width: MediaQuery.of(context).size.width - 90,
        decoration: BoxDecoration(
          color: appPrimaryColor, //Color.fromARGB(255, 241, 173, 121),
          borderRadius: new BorderRadius.only(
              topLeft: Radius.circular(40), topRight: Radius.circular(40)),
          // image: DecorationImage(
          //     image: AssetImage('assets/image/bottom_bgn.png'),
          //     fit: BoxFit.fill),
        ),
        padding: EdgeInsets.only(top: 1),
        child: BottomNavigationBar(
          elevation: 0,
          selectedIconTheme:
              const IconThemeData(size: 40.0, color: Colors.white),
          unselectedIconTheme: const IconThemeData(
              size: 20.0, color: Color.fromARGB(255, 247, 231, 231)),
          showUnselectedLabels: false,
          showSelectedLabels: false,
          selectedFontSize: 5.0,
          unselectedFontSize: 2.0,
          type: BottomNavigationBarType.fixed,
          // backgroundColor: appPrimaryColor,
          backgroundColor: Colors.transparent,
          items: const <BottomNavigationBarItem>[
            BottomNavigationBarItem(
              label: 'Meeting',
              icon: Icon(
                CommunityMaterialIcons.account_group_outline,
              ),
            ),
            BottomNavigationBarItem(
              label: 'Business',
              icon: Icon(CommunityMaterialIcons.gesture_tap),
            ),
            BottomNavigationBarItem(
              label: 'Business',
              icon: Icon(
                Icons.home,
              ),
            ),
            BottomNavigationBarItem(
              label: 'Business',
              icon: Icon(CommunityMaterialIcons.beach),
            ),
            BottomNavigationBarItem(
              label: 'Business',
              icon: Icon(Icons.settings),
            ),
          ],
          currentIndex: _selectedIndexBottom,
          onTap: _onItemTapped,
        ),
      ),
      drawer: Drawer(
        // Add a ListView to the drawer. This ensures the user can scroll
        // through the options in the drawer if there isn't enough vertical
        // space to fit everything.

        child: Column(
          // shrinkWrap: true,
          // Important: Remove any padding from the ListView.
          children: <Widget>[
            Container(
              color: colorTextDarkBlue,
              height: 160.0,
              child: Center(
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: <Widget>[
                    SizedBox(
                      height: 20.0,
                    ),
                    Padding(
                      padding: const EdgeInsets.only(
                          left: 10.0, right: 10.0, top: 25),
                      child: Container(
                          width: 60.0,
                          height: 60.0,
                          decoration: new BoxDecoration(
                              shape: BoxShape.circle,
                              image: new DecorationImage(
                                  fit: BoxFit.fill,
                                  image: new NetworkImage(widget.image)))),
                    ),
                    Padding(
                      padding: const EdgeInsets.only(
                          left: 10.0, right: 10.0, top: 55),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: <Widget>[
                          SizedBox(
                            height: 0.0,
                          ),
                          Container(
                            width: 200,
                            child: Text(
                              widget.name,
                              maxLines: 1,
                              style: TextStyle(
                                fontSize: 17,
                                color: Colors.white,
                                fontFamily: 'Montserrat-Regular"',
                                fontWeight: FontWeight.w800,
                              ),
                            ),
                          ),
                          SizedBox(
                            height: 5,
                          ),
                          Container(
                            width: 200,
                            child: Text(
                              // 'Akshada Musmade jhjkjh mgfuyhj uhojkhjfg',
                              widget.email,
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                              style: TextStyle(
                                fontSize: 14,
                                color: Colors.white,
                                fontFamily: font,
                              ),
                            ),
                          ),
                          SizedBox(
                            height: 5,
                          ),
                          Text(
                            'App Version ${widget.projectVersion}',
                            maxLines: 1,
                            style: TextStyle(
                              fontSize: 10,
                              color: Colors.white,
                              fontFamily: font,
                            ),
                          ),
                          Expanded(
                            child: Container(),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
            Container(
              height: 1.0,
              color: Colors.grey[400],
            ),
            Expanded(
              child: ListView(
                shrinkWrap: true,
                children: <Widget>[
                  InkWell(
                    child: Padding(
                      padding: EdgeInsets.all(15.0),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: <Widget>[
                          SizedBox(
                            width: 15.0,
                          ),
                          Icon(Icons.home, color: Colors.black),
                          SizedBox(
                            width: ScreenUtil().setSp(10),
                          ),
                          Text(
                            'Dashboard',
                          )
                        ],
                      ),
                    ),
                    onTap: () {
                      //TODO click  event handel to full area
                      if (scaffoldKey.currentState!.isDrawerOpen) {
                        scaffoldKey.currentState?.openEndDrawer();
                      } else {
                        scaffoldKey.currentState?.openDrawer();
                      }
                      _selectedIndexSideDrawer = 2;
                      _selectedIndexBottom = 2;
                      setState(() {});
                    },
                  ),
                  driver(),
                  Container(
                    height: 1.0,
                    color: Colors.grey[400],
                  ),
                  InkWell(
                    child: Padding(
                      padding: EdgeInsets.all(15.0),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: <Widget>[
                          SizedBox(
                            width: 15.0,
                          ),
                          Icon(CommunityMaterialIcons.gesture_tap_hold,
                              color: Colors.black),
                          SizedBox(
                            width: 10.0,
                          ),
                          Text(
                            'Attendance',
                          )
                        ],
                      ),
                    ),
                    onTap: () {
                      //TODO click  event handel to full area
                      if (scaffoldKey.currentState!.isDrawerOpen) {
                        scaffoldKey.currentState?.openEndDrawer();
                      } else {
                        scaffoldKey.currentState?.openDrawer();
                      }
                      _selectedIndexSideDrawer = 1;
                      _selectedIndexBottom = 1;
                      setState(() {});
                    },
                  ),
                  Container(
                    height: 1.0,
                    color: Colors.grey[400],
                  ),
                  InkWell(
                    child: Padding(
                      padding: EdgeInsets.all(15.0),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: <Widget>[
                          SizedBox(
                            width: 15.0,
                          ),
                          Icon(CommunityMaterialIcons.account_group_outline,
                              color: Colors.black),
                          SizedBox(
                            width: 10.0,
                          ),
                          Text('Meeting')
                        ],
                      ),
                    ),
                    onTap: () {
                      //TODO click  event handel to full area
                      if (scaffoldKey.currentState!.isDrawerOpen) {
                        scaffoldKey.currentState?.openEndDrawer();
                      } else {
                        scaffoldKey.currentState?.openDrawer();
                      }
                      _selectedIndexSideDrawer = 0;
                      _selectedIndexBottom = 0;
                      setState(() {});
                    },
                  ),
                  Container(
                    height: 1.0,
                    color: Colors.grey[400],
                  ),
                  InkWell(
                    child: Padding(
                      padding: EdgeInsets.all(15.0),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: <Widget>[
                          SizedBox(
                            width: 15.0,
                          ),
                          Icon(CommunityMaterialIcons.beach,
                              color: Colors.black),
                          SizedBox(
                            width: 10.0,
                          ),
                          Text('Leave')
                        ],
                      ),
                    ),
                    onTap: () {
                      //TODO click  event handel to full area
                      if (scaffoldKey.currentState!.isDrawerOpen) {
                        scaffoldKey.currentState?.openEndDrawer();
                      } else {
                        scaffoldKey.currentState?.openDrawer();
                      }
                      _selectedIndexSideDrawer = 3;
                      _selectedIndexBottom = 3;
                      setState(() {});
                    },
                  ),
                  Container(
                    height: 1.0,
                    color: Colors.grey[400],
                  ),
                  InkWell(
                    child: Padding(
                      padding: EdgeInsets.all(15.0),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: <Widget>[
                          SizedBox(
                            width: 15.0,
                          ),
                          Icon(Icons.folder, color: Colors.black),
                          SizedBox(
                            width: 10.0,
                          ),
                          Text('Document')
                        ],
                      ),
                    ),
                    onTap: () {
                      //TODO click  event handel to full area
                      if (scaffoldKey.currentState!.isDrawerOpen) {
                        scaffoldKey.currentState?.openEndDrawer();
                      } else {
                        scaffoldKey.currentState?.openDrawer();
                      }
                      _selectedIndexSideDrawer = 5;
                      Navigator.of(context).push(new MaterialPageRoute(
                          builder: (BuildContext context) => new DocumentList(
                              scaffoldKey: scaffoldKey,
                              title: 'Document List')));
                    },
                  ),
                  Container(
                    height: 1.0,
                    color: Colors.grey[400],
                  ),
                  InkWell(
                    child: Padding(
                      padding: EdgeInsets.all(15.0),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: <Widget>[
                          SizedBox(
                            width: 15.0,
                          ),
                          Icon(CommunityMaterialIcons.cake,
                              color: Colors.black),
                          SizedBox(
                            width: 10.0,
                          ),
                          Text(
                            'Birthday List',
                          )
                        ],
                      ),
                    ),
                    onTap: () {
                      if (scaffoldKey.currentState!.isDrawerOpen) {
                        scaffoldKey.currentState?.openEndDrawer();
                      } else {
                        scaffoldKey.currentState?.openDrawer();
                      }
                      Navigator.of(context).push(new MaterialPageRoute(
                          builder: (BuildContext context) => new BirthdayList(
                              scaffoldKey: scaffoldKey,
                              title: 'Birthday List')));
                      setState(() {});
                    },
                  ),
                  Container(
                    height: 1.0,
                    color: Colors.grey[400],
                  ),
                  InkWell(
                    child: Padding(
                      padding: EdgeInsets.all(15.0),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: <Widget>[
                          SizedBox(
                            width: 15.0,
                          ),
                          Icon(CommunityMaterialIcons.calendar_multiselect,
                              color: Colors.black),
                          SizedBox(
                            width: 10.0,
                          ),
                          Text(
                            'Holiday',
                          )
                        ],
                      ),
                    ),
                    onTap: () {
                      if (scaffoldKey.currentState!.isDrawerOpen) {
                        scaffoldKey.currentState?.openEndDrawer();
                      } else {
                        scaffoldKey.currentState?.openDrawer();
                      }
                      Navigator.of(context).push(new MaterialPageRoute(
                          builder: (BuildContext context) => new Holiday(
                              scaffoldKey: scaffoldKey, title: 'Holidays')));
                      setState(() {});
                    },
                  ),
                  taskManager(),
                  approveTask(),
                  // driver(),
                  Container(
                    height: 1.0,
                    color: Colors.grey[400],
                  ),
                  InkWell(
                    child: Padding(
                      padding: EdgeInsets.all(15.0),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: <Widget>[
                          SizedBox(
                            width: 15.0,
                          ),
                          Icon(Icons.settings, color: Colors.black),
                          SizedBox(
                            width: 10.0,
                          ),
                          Text('Settings')
                        ],
                      ),
                    ),
                    onTap: () {
                      if (scaffoldKey.currentState!.isDrawerOpen) {
                        scaffoldKey.currentState?.openEndDrawer();
                      } else {
                        scaffoldKey.currentState?.openDrawer();
                      }
                      _selectedIndexSideDrawer = 4;
                      _selectedIndexBottom = 4;
                      setState(() {});
                    },
                  ),
                  //emp

                  Container(
                    height: 1.0,
                    color: Colors.grey[400],
                  ),

                  // InkWell(
                  //   child: Padding(
                  //     padding: EdgeInsets.all(15.0),
                  //     child: Row(
                  //       crossAxisAlignment: CrossAxisAlignment.center,
                  //       children: <Widget>[
                  //         SizedBox(
                  //           width: 15.0,
                  //         ),
                  //         Icon(Icons.settings, color: Colors.black),
                  //         SizedBox(
                  //           width: 10.0,
                  //         ),
                  //         Text('Employee')
                  //       ],
                  //     ),
                  //   ),
                  //   onTap: () {
                  //     if (scaffoldKey.currentState.isDrawerOpen) {
                  //       scaffoldKey.currentState.openEndDrawer();
                  //     } else {
                  //       scaffoldKey.currentState.openDrawer();
                  //     }
                  //     _selectedIndexSideDrawer = 5;
                  //     Navigator.of(context).push(new MaterialPageRoute(
                  //         builder: (BuildContext context) => new Verify(
                  //             scaffoldKey: scaffoldKey, title: 'Verify ')));

                  //     // if (scaffoldKey.currentState.isDrawerOpen) {
                  //     //   scaffoldKey.currentState.openEndDrawer();
                  //     // } else {
                  //     //   scaffoldKey.currentState.openDrawer();
                  //     // }
                  //     // _selectedIndexSideDrawer = 4;
                  //     // _selectedIndexBottom = 4;
                  //     // setState(() {});
                  //   },
                  // ),

                  //end emp
                  // Container(
                  //   height: 1.0,
                  //   color: Colors.grey[400],
                  // ),
                  InkWell(
                    child: Padding(
                      padding: EdgeInsets.all(15.0),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: <Widget>[
                          SizedBox(
                            width: 15.0,
                          ),
                          Icon(Icons.notifications, color: Colors.black),
                          SizedBox(
                            width: 10.0,
                          ),
                          Text('Notification')
                        ],
                      ),
                    ),
                    onTap: () {
                      if (scaffoldKey.currentState!.isDrawerOpen) {
                        scaffoldKey.currentState?.openEndDrawer();
                      } else {
                        scaffoldKey.currentState?.openDrawer();
                      }
                      _selectedIndexSideDrawer = 6;
                      Navigator.of(context).push(new MaterialPageRoute(
                          builder: (BuildContext context) =>
                              new NotificationList(
                                  scaffoldKey: scaffoldKey,
                                  title: 'Notification')));
                    },
                  ),
                  Container(
                    height: 1.0,
                    color: Colors.grey[400],
                  ),

                  feedback(),
                  Container(
                    height: 1.0,
                    color: Colors.grey[400],
                  ),

                  InkWell(
                    child: Container(
                      color: Color(0x112762D8),
                      child: Padding(
                        padding: EdgeInsets.all(18.0),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: <Widget>[
                            SizedBox(
                              width: 15.0,
                            ),
                            Icon(Icons.open_in_browser, color: Colors.black),
                            SizedBox(
                              width: 10.0,
                            ),
                            Text('Log out')
                          ],
                        ),
                      ),
                    ),
                    onTap: () {
                      if (scaffoldKey.currentState!.isDrawerOpen) {
                        scaffoldKey.currentState?.openEndDrawer();
                      } else {
                        scaffoldKey.currentState?.openDrawer();
                      }
                      setState(() {});
                      showAlert();
                    },
                  ),
                  helpLine(),
                ],
              ),
            )
          ],
        ),
      ),
    );
  }

  void showAlert() {
    showDialog(
        context: context,
        builder: (BuildContext context) {
          return StatefulBuilder(builder: (context, setState) {
            return AlertDialog(
              contentPadding: EdgeInsets.all(0),
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.all(
                      Radius.circular(ScreenUtil().setSp(10)))),
              content: Container(
                decoration: new BoxDecoration(
                    borderRadius: new BorderRadius.all(
                        Radius.circular(ScreenUtil().setSp(10)))),
                padding: EdgeInsets.only(bottom: ScreenUtil().setSp(10)),
                child: Column(
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
                        child: Text(
                          'Logout',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                              fontSize: ScreenUtil().setSp(16),
                              fontWeight: FontWeight.bold,
                              color: appWhiteColor),
                        )),
                    Padding(
                      padding: EdgeInsets.only(
                          left: ScreenUtil().setSp(20),
                          top: ScreenUtil().setSp(20)),
                      child: Text('Are you sure want to logout?'),
                    ),
                  ],
                ),
              ),
              actions: <Widget>[
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: btnBgColor,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(25.0),
                    ),
                  ),
                  child: new Text(
                    "CANCEL",
                    style: TextStyle(color: appWhiteColor),
                  ),
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                ),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: btnBgColor,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(25.0),
                    ),
                  ),
                  child: new Text(
                    "YES, LOGOUT",
                    style: TextStyle(color: appWhiteColor),
                  ),
                  onPressed: () {
                    logout(context);
                  },
                ),
              ],
            );
          });
        });
  }

  bodyContainer() {
    if (_selectedIndexSideDrawer > 4) {
      switch (_selectedIndexSideDrawer) {
        case 6:
      }
    } else {
      switch (_selectedIndexBottom) {
        case 0:
          return MeetingList(
            scaffoldKey: scaffoldKey,
            title: 'Meeting',
          );
        case 1:
          return AttendanceList(
            scaffoldKey: scaffoldKey,
            title: 'Attendance List',
          );
        case 2:
          return HomePage(
            scaffoldKey: scaffoldKey,
            title: 'Dashboard',
          );
        case 3:
          return LeaveList(
            scaffoldKey: scaffoldKey,
            title: 'Leave List',
          );
        case 4:
          return AppSetting(
            scaffoldKey: scaffoldKey,
            title: 'Settings',
          );
      }
    }
    return HomePage(
      scaffoldKey: scaffoldKey,
      title: 'Dashboard',
    );
  }

  void getSpData() async {
    final SharedPreferences prefs = await _prefs;
    _apiToken = prefs.getString(SP_API_TOKEN)!;
    _isSelfi = prefs.getInt(SP_ATTENDANCE_SELFIE)!;

    _isGeofence = prefs.getInt(GEOFENCING)!;
    _distance = prefs.getInt(DISTANCE)!;

    _isGeotracking = prefs.getInt(SP_LOCATION_TRACKING)!;
    _task_manager = prefs.getInt(TASK_MANAGER)!;
    _driver_delivery = prefs.getInt(SP_DRIVER)!;
    _approve_task = prefs.getInt(APPROVE_TASK)!;
    _helpline = prefs.getString(SP_HELPLINE_NO)!;

    setState(() {});
  }

  taskManager() {
    return (_task_manager == 1)
        ? Column(
            children: <Widget>[
              Container(
                height: 1.0,
                color: Colors.grey[400],
              ),
              InkWell(
                child: Padding(
                  padding: EdgeInsets.all(15.0),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: <Widget>[
                      SizedBox(
                        width: 15.0,
                      ),
                      Icon(CommunityMaterialIcons.playlist_edit,
                          color: Colors.black),
                      SizedBox(
                        width: 10.0,
                      ),
                      Text(
                        'Task / ToDo Manager',
                      )
                    ],
                  ),
                ),
                onTap: () {
                  if (scaffoldKey.currentState!.isDrawerOpen) {
                        scaffoldKey.currentState?.openEndDrawer();
                      } else {
                        scaffoldKey.currentState?.openDrawer();
                      }
                  Navigator.of(context).push(new MaterialPageRoute(
                      builder: (BuildContext context) => new Tasks(
                          scaffoldKey: scaffoldKey, title: 'View Task')));
                  setState(() {});
                },
              ),
            ],
          )
        : Container();
  }

  approveTask() {
    return (_approve_task == 1)
        ? Column(
            children: <Widget>[
              Container(
                height: 1.0,
                color: Colors.grey[400],
              ),
              InkWell(
                child: Padding(
                  padding: EdgeInsets.all(15.0),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: <Widget>[
                      SizedBox(
                        width: 15.0,
                      ),
                      Icon(Icons.group, color: Colors.black),
                      SizedBox(
                        width: 10.0,
                      ),
                      Text(
                        'My Team',
                      )
                    ],
                  ),
                ),
                onTap: () {
                  if (scaffoldKey.currentState!.isDrawerOpen) {
                        scaffoldKey.currentState?.openEndDrawer();
                      } else {
                        scaffoldKey.currentState?.openDrawer();
                      }
                  Navigator.of(context).push(new MaterialPageRoute(
                      builder: (BuildContext context) => new TeamMember(
                          scaffoldKey: scaffoldKey, title: 'Team Members')));
                  setState(() {});
                },
              ),
            ],
          )
        : Container();
  }

  driver() {
    return (_driver_delivery == 1)
        ? Column(
            children: <Widget>[
              Container(
                height: 1.0,
                color: Colors.grey[400],
              ),
              InkWell(
                child: Padding(
                  padding: EdgeInsets.all(15.0),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: <Widget>[
                      SizedBox(
                        width: 15.0,
                      ),
                      Icon(CommunityMaterialIcons.car, color: Colors.black),
                      SizedBox(
                        width: 10.0,
                      ),
                      Text(
                        'Driver',
                      )
                    ],
                  ),
                ),
                onTap: () {
                  if (scaffoldKey.currentState!.isDrawerOpen) {
                        scaffoldKey.currentState?.openEndDrawer();
                      } else {
                        scaffoldKey.currentState?.openDrawer();
                      }
                  Navigator.of(context).push(new MaterialPageRoute(
                      builder: (BuildContext context) => new Driver(
                          scaffoldKey: scaffoldKey, title: 'Package List')));
                  setState(() {});
                },
              ),
            ],
          )
        : Container();
  }

  feedback() {
    return InkWell(
      child: Padding(
        padding: EdgeInsets.all(15.0),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: <Widget>[
            SizedBox(
              width: 15.0,
            ),
            Icon(Icons.feedback, color: Colors.black),
            SizedBox(
              width: 10.0,
            ),
            Text(
              'Feedback',
            )
          ],
        ),
      ),
      onTap: () {
        if (scaffoldKey.currentState!.isDrawerOpen) {
                        scaffoldKey.currentState?.openEndDrawer();
                      } else {
                        scaffoldKey.currentState?.openDrawer();
                      }
        Navigator.of(context).push(new MaterialPageRoute(
            builder: (BuildContext context) =>
                FeedBack(scaffoldKey: scaffoldKey, title: 'Feedback')));
        setState(() {});
      },
    );
  }

  helpLine() {
    return Column(
      children: <Widget>[
        Container(
          height: 1.0,
          color: Colors.grey[400],
        ),
        Container(
          color: Color(0x112762D8),
          child: InkWell(
            child: Padding(
              padding: EdgeInsets.all(15.0),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: <Widget>[
                  SizedBox(
                    width: 15.0,
                  ),
                  Icon(Icons.call, color: Colors.black),
                  SizedBox(
                    width: 10.0,
                  ),
                  Text(
                    'HelpLine',
                  )
                ],
              ),
            ),
            onTap: () {
             if (scaffoldKey.currentState!.isDrawerOpen) {
                        scaffoldKey.currentState?.openEndDrawer();
                      } else {
                        scaffoldKey.currentState?.openDrawer();
                      }
              setState(() {});
              showAlertForCall();
            },
          ),
        ),
      ],
    );
  }

  void showAlertForCall() {
    showDialog(
        context: context,
        builder: (BuildContext context) {
          return StatefulBuilder(builder: (context, setState) {
            return AlertDialog(
              contentPadding: EdgeInsets.all(0),
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.all(
                      Radius.circular(ScreenUtil().setSp(10)))),
              content: Container(
                decoration: new BoxDecoration(
                    borderRadius: new BorderRadius.all(
                        Radius.circular(ScreenUtil().setSp(10)))),
                padding: EdgeInsets.only(bottom: ScreenUtil().setSp(10)),
                child: Column(
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
                        child: Text(
                          'Call',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                              fontSize: ScreenUtil().setSp(16),
                              fontWeight: FontWeight.bold,
                              color: appWhiteColor),
                        )),
                    Padding(
                      padding: EdgeInsets.only(
                          left: ScreenUtil().setSp(20),
                          top: ScreenUtil().setSp(20)),
                      child: Column(
                        children: <Widget>[
                          Text('Are you sure want to Call?'),
                          Text(
                            _helpline,
                            style: TextStyle(
                                color: Colors.blue,
                                fontWeight: FontWeight.bold),
                          )
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              actions: <Widget>[
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: btnBgColor,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(25.0),
                    ),
                  ),
                  child: new Text(
                    "CANCEL",
                    style: TextStyle(color: appWhiteColor),
                  ),
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                ),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: btnBgColor,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(25.0),
                    ),
                  ),
                  child: new Text(
                    "CALL",
                    style: TextStyle(color: appWhiteColor),
                  ),
                  onPressed: () {
                    launch("tel://$_helpline");
                    Navigator.pop(context);
                  },
                ),
              ],
            );
          });
        });
  }
}
