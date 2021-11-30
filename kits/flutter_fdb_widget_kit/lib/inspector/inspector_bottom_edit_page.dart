import 'package:flutter/material.dart';

class BottomEditPage extends StatefulWidget {
  final String preContent;

  BottomEditPage({this.preContent});

  @override
  __BottomEditPageState createState() => __BottomEditPageState();
}

class __BottomEditPageState extends State<BottomEditPage>
    with TickerProviderStateMixin {
  AnimationController _controller;
  Animation _animation;

  @override
  void initState() {
    super.initState();
    //用于动画
    _controller =
        AnimationController(duration: Duration(milliseconds: 300), vsync: this);
    _animation =
        Tween(end: Offset.zero, begin: Offset(0.0, 1.0)).animate(_controller);
    _controller.forward();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0x80000000).withOpacity(0.3),
      body: Column(
        mainAxisSize: MainAxisSize.max,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Expanded(
            child: _buildTopWidget(),
          ),
          Container(
            color: Colors.white,
            child: TextField(
              autofocus: true,
              controller: TextEditingController(text: widget.preContent ?? ""),
              textInputAction: TextInputAction.done,
              onSubmitted: (string) {
                Navigator.of(context).pop(string);
              },
            ),
          )
        ],
      ),
    );
  }

  @override
  void dispose() {
    _controller?.dispose();
    super.dispose();
  }

  Widget _buildTopWidget() {
    return GestureDetector(
      onTap: () {
        _closeDialog();
      },
      child: Container(
        color: Color(0x80000000).withOpacity(0.3),
      ),
    );
  }

  void _closeDialog() {
    _controller.reverse();
    Navigator.of(context).maybePop();
  }
}
