
import 'package:flutter/foundation.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:hrms/appUtil/app_util_config.dart';
// import 'package:webview_flutter/webview_flutter.dart';
import 'package:flutter_inappwebview/flutter_inappwebview.dart';

class EditProfile extends StatefulWidget {
  // EditProfile({Key key}) : super(key: key);
  String url;
  String title;
  EditProfile({Key? key, required this.title, required this.url, scaffoldKey}) : super(key: key);

  @override
  _EditProfileState createState() {
    return _EditProfileState();
  }
}

class _EditProfileState extends State<EditProfile> {
  // final Completer<WebViewController> _controller =
  // Completer<WebViewController>();
  late InAppWebViewController _webViewController;
  String url = "";
  double progress = 0;

  @override
  void initState() {
    super.initState();
    print(widget.url);
    // WebView.platform = SurfaceAndroidWebView();
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // // TODO: implement build
    return SafeArea(
       top: false,
        bottom: true,
      child: Scaffold(
        appBar: AppBar(
          backgroundColor: appPrimaryColor,
          title: Text(widget.title, style: TextStyle(color: Colors.white, fontWeight: FontWeight.w600),),
          centerTitle: true,
          leading: IconButton(
            icon: Icon(Icons.arrow_back, color: Colors.white,),
            onPressed: (){
              Navigator.pop(context);
            },
          ),
        ),
      
        body: InAppWebView(
            gestureRecognizers: Set()..add(Factory<VerticalDragGestureRecognizer>(() => VerticalDragGestureRecognizer())),
            // initialUrlRequest: URLRequest(url: Uri.parse(widget.url))
            ),
      ),
    );
    // return Scaffold(
    //   appBar: AppBar(
    //     backgroundColor: appPrimaryColor,
    //     title: Text(widget.title, style: TextStyle(color: Colors.white, fontWeight: FontWeight.w600),),
    //     centerTitle: true,
    //     leading: IconButton(
    //       icon: Icon(Icons.arrow_back, color: Colors.white,),
    //       onPressed: (){
    //         Navigator.pop(context);
    //       },
    //     ),
    //   ),
    //
    //   body: SafeArea(
    //     child:Text('Jivan'),
    //     // WebView(
    //     //   initialUrl: widget.url,
    //     //   javascriptMode: JavascriptMode.unrestricted,
    //     //   // javascriptChannels: Set.from([
    //     //   //   JavascriptChannel(
    //     //   //       name: 'Jivan',
    //     //   //       onMessageReceived: (JavascriptMessage message) {
    //     //   //         //This is where you receive message from
    //     //   //         //javascript code and handle in Flutter/Dart
    //     //   //         //like here, the message is just being printed
    //     //   //         //in Run/LogCat window of android studio
    //     //   //         print(message.message);
    //     //   //       })
    //     //   // ]),
    //     //
    //     // )
    //
    //     // WebView(
    //     //   initialUrl: widget.url,
    //     // ),
    //   ),
    // );
  }
}