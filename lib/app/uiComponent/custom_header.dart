import 'package:flutter/material.dart';
import 'package:hrms/app/mainApp/notification/notification.dart';
import 'package:hrms/appUtil/app_util_config.dart';
import 'package:community_material_icon/community_material_icon.dart';

class CustomHeader extends StatefulWidget {
  var scaffoldKey;
  var title;

  CustomHeader({
    Key? key,
    @required this.scaffoldKey,
    @required this.title,
  }) : super(key: key);

  @override
  _CustomHeaderState createState() {
    return _CustomHeaderState();
  }
}

class _CustomHeaderState extends State<CustomHeader> {
  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // TODO: implement build
    return PreferredSize(
      preferredSize: Size(MediaQuery.of(context).size.width, 250),
      child: Container(
        width: MediaQuery.of(context).size.width,
        height: widget.title == "Leave List" ? 300 : 250,
        child: ClipRRect(
          borderRadius: BorderRadius.only(
            bottomLeft: Radius.circular(50),
          ),
          child: Container(
            decoration: BoxDecoration(
              color: Colors.transparent,
              image: DecorationImage(
                  image: AssetImage('assets/image/navigation_bg.png'),
                  fit: BoxFit.fill),
            ),
            child: Column(
              children: <Widget>[
                Container(
                  margin: EdgeInsets.fromLTRB(10, 50, 10, 0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      GestureDetector(
                        child: Icon(
                          Icons.menu, //subject,
                          size: 30,
                          color: Colors.white,
                        ),
                        onTap: () {
                          print('click ');
                          if (widget.scaffoldKey.currentState.isDrawerOpen) {
                            widget.scaffoldKey.currentState.openEndDrawer();
                          } else {
                            widget.scaffoldKey.currentState.openDrawer();
                          }
                        },
                      ),
                      Text(
                        widget.title,
                        style: TextStyle(
                            fontSize: 22,
                            color: Colors.white,
                            fontFamily: font),
                      ),
                      GestureDetector(
                        child: Icon(
                          Icons.notifications,
                          size: 30,
                          color: Colors.white,
                        ),
                        onTap: () {
                          Navigator.of(context).push(new MaterialPageRoute(
                              builder: (BuildContext context) =>
                                  new NotificationList(
                                      scaffoldKey: null,
                                      title: 'Notification')));
                        },
                      ),
                    ],
                  ),
                ),
                SizedBox(
                  height: 20.0,
                )
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class CustomTinyHeader extends StatefulWidget {
  var scaffoldKey;
  var title;

  CustomTinyHeader({
    Key? key,
    @required this.scaffoldKey,
    @required this.title,
  }) : super(key: key);

  @override
  _CustomTinyHeaderState createState() {
    return _CustomTinyHeaderState();
  }
}

class _CustomTinyHeaderState extends State<CustomTinyHeader> {
  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // TODO: implement build
    return PreferredSize(
      preferredSize: Size(MediaQuery.of(context).size.width, 250),
      child: Container(
        width: MediaQuery.of(context).size.width,
        height: 120,
        child: ClipRRect(
          borderRadius: BorderRadius.only(
            bottomLeft: Radius.circular(50),
          ),
          child: Container(
            color: appColorFour,
            child: Column(
              children: <Widget>[
                Container(
                  margin: EdgeInsets.fromLTRB(10, 50, 10, 0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      GestureDetector(
                        child: Icon(
                          Icons.subject,
                          size: 30,
                          color: Colors.white,
                        ),
                        onTap: () {
                          print('click ');
                          if (widget.scaffoldKey.currentState.isDrawerOpen) {
                            widget.scaffoldKey.currentState.openEndDrawer();
                          } else {
                            widget.scaffoldKey.currentState.openDrawer();
                          }
                        },
                      ),
                      Text(
                        widget.title,
                        style: TextStyle(fontSize: 22, color: Colors.white),
                      ),
                      GestureDetector(
                        child: Icon(
                          CommunityMaterialIcons.filter,
                          size: 30,
                          color: Colors.white,
                        ),
                        onTap: () {
                          showDialog(
                              context: context,
                              builder: (BuildContext context) {
                                return Dialog(
                                  shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(
                                          20.0)), //this right here
                                  child: Container(
                                    height: 200,
                                    child: Padding(
                                      padding: const EdgeInsets.all(12.0),
                                      child: Column(
                                        mainAxisAlignment:
                                            MainAxisAlignment.center,
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          TextField(
                                            decoration: InputDecoration(
                                                border: InputBorder.none,
                                                hintText:
                                                    'What do you want to remember?'),
                                          ),
                                          SizedBox(
                                            width: 320.0,
                                            child: ElevatedButton(
                                              onPressed: () {},
                                              child: Text(
                                                "Save",
                                                style: TextStyle(
                                                    color: Colors.white),
                                              ),
                                              //color: const Color(0xFF1BC0C5),
                                            ),
                                          )
                                        ],
                                      ),
                                    ),
                                  ),
                                );
                              });
                        },
                      ),
                    ],
                  ),
                ),
                SizedBox(
                  height: 20.0,
                )
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class SimpleHeader extends StatefulWidget {
  SimpleHeader({Key? key}) : super(key: key);

  @override
  _SimpleHeaderState createState() {
    return _SimpleHeaderState();
  }
}

class _SimpleHeaderState extends State<SimpleHeader> {
  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // TODO: implement build
    return PreferredSize(
      preferredSize: Size(MediaQuery.of(context).size.width, 250),
      child: Container(
        width: MediaQuery.of(context).size.width,
        height: 250,
        child: ClipRRect(
          borderRadius: BorderRadius.only(
            bottomLeft: Radius.circular(50),
          ),
          child: Container(
            color: appPrimaryColor,
            child: Column(
              children: <Widget>[
                Container(
                  margin: EdgeInsets.fromLTRB(10, 50, 10, 0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      GestureDetector(
                        child: Icon(
                          Icons.arrow_back_ios,
                          size: 25,
                          color: Colors.transparent,
                        ),
                        onTap: () {
                          // Navigator.pop(context);
                        },
                      ),
                      Text(
                        '',
                        style: TextStyle(fontSize: 22, color: Colors.white),
                      ),
                      GestureDetector(
                        child: Icon(
                          Icons.notifications,
                          size: 30,
                          color: Colors.transparent,
                        ),
                        onTap: () {},
                      ),
                    ],
                  ),
                ),
                SizedBox(
                  height: 20.0,
                )
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class CustomHeaderWithBack extends StatefulWidget {
  var scaffoldKey;
  var title;

  CustomHeaderWithBack({
    Key? key,
    @required this.scaffoldKey,
    @required this.title,
  }) : super(key: key);

  @override
  _CustomHeaderWithBackState createState() {
    return _CustomHeaderWithBackState();
  }
}

class _CustomHeaderWithBackState extends State<CustomHeaderWithBack> {
  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return PreferredSize(
      preferredSize: Size(MediaQuery.of(context).size.width, 250),
      child: Container(
        width: MediaQuery.of(context).size.width,
        decoration: BoxDecoration(
          color: Colors.transparent,
          image: DecorationImage(
              image: AssetImage('assets/image/navigation_bg.png'),
              fit: BoxFit.fill),
        ),
        height: 300,
        child: ClipRRect(
          borderRadius: BorderRadius.only(
            bottomLeft: Radius.circular(50),
          ),
          child: Container(
            // color: appPrimaryColor,
            child: Column(
              children: <Widget>[
                Container(
                  margin: EdgeInsets.fromLTRB(10, 50, 10, 0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      GestureDetector(
                        child: Icon(
                          Icons.arrow_back_ios,
                          size: 25,
                          color: Colors.white,
                        ),
                        onTap: () {
                          print('click ');
                          Navigator.pop(context);
                        },
                      ),
                      Text(
                        widget.title,
                        style: TextStyle(fontSize: 22, color: Colors.white),
                      ),
                      SizedBox(
                        width: 30,
                      )
                      // Icon(
                      //   Icons.notifications,
                      //   size: 30,
                      //   color: appWhiteColor,
                      // ),
                    ],
                  ),
                ),
                SizedBox(
                  height: 20.0,
                )
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class CustomHeaderWithReloadBack extends StatefulWidget {
  var scaffoldKey;
  var title;

  CustomHeaderWithReloadBack({
    Key? key,
    @required this.scaffoldKey,
    @required this.title,
  }) : super(key: key);

  @override
  _CustomHeaderWithRelaodBackState createState() {
    return _CustomHeaderWithRelaodBackState();
  }
}

class _CustomHeaderWithRelaodBackState
    extends State<CustomHeaderWithReloadBack> {
  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return PreferredSize(
      preferredSize: Size(MediaQuery.of(context).size.width, 250),
      child: Container(
        width: MediaQuery.of(context).size.width,
        height: 150,
        child: ClipRRect(
          borderRadius: BorderRadius.only(
            bottomLeft: Radius.circular(50),
          ),
          child: Container(
            color: appPrimaryColor,
            child: Column(
              children: <Widget>[
                Container(
                  margin: EdgeInsets.fromLTRB(10, 50, 10, 0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      GestureDetector(
                        child: Icon(
                          Icons.arrow_back_ios,
                          size: 25,
                          color: Colors.white,
                        ),
                        onTap: () {
                          print('click ');
                          //Navigator.pop(context);
                          Navigator.of(context).pop({'reload': true});
                        },
                      ),
                      Text(
                        widget.title,
                        style: TextStyle(fontSize: 22, color: Colors.white),
                      ),
                      Icon(
                        Icons.notifications,
                        size: 30,
                        color: appPrimaryColor,
                      ),
                    ],
                  ),
                ),
                SizedBox(
                  height: 20.0,
                )
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class CustomHeaderWithBackGreen extends StatefulWidget {
  var scaffoldKey;
  var title;

  CustomHeaderWithBackGreen({
    Key? key,
    @required this.scaffoldKey,
    @required this.title,
  }) : super(key: key);

  @override
  _CustomHeaderWithBackGreenState createState() {
    return _CustomHeaderWithBackGreenState();
  }
}

class _CustomHeaderWithBackGreenState extends State<CustomHeaderWithBackGreen> {
  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return PreferredSize(
      preferredSize: Size(MediaQuery.of(context).size.width, 250),
      child: Container(
        width: MediaQuery.of(context).size.width,
        height: 250,
        decoration: BoxDecoration(
          color: Colors.transparent,
          image: DecorationImage(
              image: AssetImage('assets/image/navigation_bg.png'),
              fit: BoxFit.fill),
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.only(
            bottomLeft: Radius.circular(50),
          ),
          child: Container(
            // color: appColorFour,
            child: Column(
              children: <Widget>[
                Container(
                  margin: EdgeInsets.fromLTRB(10, 50, 10, 0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      GestureDetector(
                        child: Icon(
                          Icons.arrow_back_ios,
                          size: 25,
                          color: Colors.white,
                        ),
                        onTap: () {
                          print('click ');
                          Navigator.pop(context);
                        },
                      ),
                      Text(
                        widget.title,
                        style: TextStyle(fontSize: 22, color: Colors.white),
                      ),
                      SizedBox(
                        width: 30,
                      ),
                      // Icon(
                      //   Icons.notifications,
                      //   size: 30,
                      //   color: appColorFour,
                      // ),
                    ],
                  ),
                ),
                SizedBox(
                  height: 20.0,
                )
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class CustomHeaderHeightWithBack extends StatefulWidget {
  var scaffoldKey;
  var title;

  CustomHeaderHeightWithBack({
    Key? key,
    @required this.scaffoldKey,
    @required this.title,
  }) : super(key: key);

  @override
  _CustomHeaderHeightWithBackState createState() {
    return _CustomHeaderHeightWithBackState();
  }
}

class _CustomHeaderHeightWithBackState
    extends State<CustomHeaderHeightWithBack> {
  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return PreferredSize(
      preferredSize: Size(MediaQuery.of(context).size.width, 100),
      child: Container(
        width: MediaQuery.of(context).size.width,
        height: 100,
        child: ClipRRect(
          borderRadius: BorderRadius.only(
            bottomLeft: Radius.circular(50),
          ),
          child: Container(
            color: appPrimaryColor,
            child: Column(
              children: <Widget>[
                Container(
                  margin: EdgeInsets.fromLTRB(10, 50, 10, 0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(''),
                      Text(
                        widget.title,
                        style: TextStyle(fontSize: 22, color: Colors.white),
                      ),
                      Icon(
                        Icons.notifications,
                        size: 30,
                        color: appPrimaryColor,
                      ),
                    ],
                  ),
                ),
                SizedBox(
                  height: 20.0,
                )
              ],
            ),
          ),
        ),
      ),
    );
  }
}
