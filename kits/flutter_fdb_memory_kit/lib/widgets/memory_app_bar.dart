import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class MemoryAppBar extends StatefulWidget implements PreferredSizeWidget {
  final String title;
  final VoidCallback backOnTap;

  MemoryAppBar({this.title, this.backOnTap});

  @override
  _MemoryAppBarState createState() => _MemoryAppBarState();

  @override
  Size get preferredSize =>
      Size.fromHeight(44 + (window.padding.top / window.devicePixelRatio));
}

class _MemoryAppBarState extends State<MemoryAppBar> {
  @override
  Widget build(BuildContext context) {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      SystemChrome.setSystemUIOverlayStyle(SystemUiOverlayStyle.light);
    });
    return Container(
        color: Colors.white,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: <Widget>[
            Padding(
              padding: EdgeInsets.only(top: 5, bottom: 5),
              child: _buildTitle(),
            ),
            Container(
              height: 1,
              color: Colors.black12,
            )
          ],
        ));
  }

  Widget _buildTitle() {
    Widget title = Text(
      widget.title,
      style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
    );

    if (widget.backOnTap != null) {
      return Stack(
        children: <Widget>[
          IconButton(
            icon: Icon(
              Icons.arrow_back,
            ),
            onPressed: () {
              widget.backOnTap();
            },
          ),
          Container(height: 44, alignment: Alignment.center, child: title)
        ],
      );
    }
    return title;
  }
}
