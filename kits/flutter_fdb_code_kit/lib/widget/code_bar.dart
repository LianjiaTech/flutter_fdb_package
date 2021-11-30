import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class CodeAppbar extends StatefulWidget implements PreferredSizeWidget {
  @override
  _CodeAppbarState createState() => _CodeAppbarState();

  @override
  Size get preferredSize =>
      Size.fromHeight(44 + (window.padding.top / window.devicePixelRatio));
}

class _CodeAppbarState extends State<CodeAppbar> {
  @override
  Widget build(BuildContext context) {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      SystemChrome.setSystemUIOverlayStyle(SystemUiOverlayStyle.light);
    });
    return Container(
        margin:
            EdgeInsets.only(top: window.padding.top / window.devicePixelRatio),
        color: Colors.white,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: <Widget>[
            Padding(
              padding: EdgeInsets.only(top: 10, bottom: 10),
              child: Text(
                "页面代码",
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
            ),
            Container(
              height: 1,
              color: Colors.black12,
            )
          ],
        ));
  }
}
