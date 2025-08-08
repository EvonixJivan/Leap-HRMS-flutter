import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:hrms/appUtil/app_providers.dart';
import 'package:provider/provider.dart';

class AppLoaderView extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final apiLoader = Provider.of<ApiLoader>(context);
    return new Align(
      child: apiLoader.load
          ? new Container(
//              color: Colors.white,
              width: 120.0,
              height: 120.0,
              child: new Padding(
                  padding: const EdgeInsets.all(1.0),
                  child: new Center(
                      child: Image.asset('assets/gif/app_loader.gif'))),
            )
          : new Container(),
      alignment: FractionalOffset.center,
    );
  }
}


class CenterLoaderView extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return new Align(
      child:  new Container(
//              color: Colors.white,
        width: 120.0,
        height: 120.0,
        child: new Padding(
            padding: const EdgeInsets.all(1.0),
            child: new Center(
                child: Image.asset('assets/gif/app_loadre_new.gif'))),
      ),
      alignment: FractionalOffset.center,
    );
  }
}