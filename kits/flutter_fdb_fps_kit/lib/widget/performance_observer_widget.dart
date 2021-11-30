import 'dart:math';
import 'dart:ui';

import 'package:flutter/material.dart';
import '../bean/fps_info.dart';
import '../util/collection_util.dart';
import 'fps_page.dart';

class PerformanceObserverWidget extends StatefulWidget {
  const PerformanceObserverWidget(this.onDragEnd, this.onDragUpdate, {Key key})
      : super(key: key);
  final void Function(DragEndDetails details) onDragEnd;
  final void Function(DragUpdateDetails details) onDragUpdate;

  @override
  _PerformanceObserverWidgetState createState() =>
      _PerformanceObserverWidgetState();
}

class _PerformanceObserverWidgetState extends State<PerformanceObserverWidget> {
  bool startRecording = false;
  bool fpsPageShowing = false;

  ValueNotifier controller;
  Function(List<FrameTiming>) monitor;
  OverlayEntry fpsInfoPage;
  OverlayEntry performancePage;

  @override
  void initState() {
    super.initState();
    controller = ValueNotifier("");
    monitor = (timings) {
      double duration = 0;
      timings.forEach((element) {
        FrameTiming frameTiming = element;
        duration = frameTiming.totalSpan.inMilliseconds.toDouble();
        FpsInfo fpsInfo = new FpsInfo();
        fpsInfo.totalSpan = max(16.7, duration);
        CommonStorage.instance.save(fpsInfo);
      });
    };
  }

  @override
  void dispose() {
    stop();
    super.dispose();
  }

  void start() {
    WidgetsBinding.instance.addTimingsCallback(monitor);
  }

  void stop() {
    WidgetsBinding.instance.removeTimingsCallback(monitor);
  }

  @override
  Widget build(BuildContext context) {
    return Material(
      child: Column(
        children: <Widget>[
          GestureDetector(
            child: RepaintBoundary(
              child: ValueListenableBuilder(
                  valueListenable: controller,
                  builder: (context, snapshot, _) {
                    return Container(
                      decoration: new BoxDecoration(
                        color: Colors.white,
                        //设置四周圆角 角度
                        borderRadius: BorderRadius.all(Radius.circular(4.0)),
                        //设置四周边框
                        border: new Border.all(width: 3, color: Colors.black),
                      ),
                      padding: EdgeInsets.fromLTRB(5, 3, 5, 3),
                      child: !startRecording
                          ? Row(
                              children: <Widget>[
                                Text('开始监听FPS',
                                    style: TextStyle(
                                        fontSize: 16,
                                        color: Colors.red,
                                        fontWeight: FontWeight.bold,
                                        fontStyle: FontStyle.italic)),
                                Icon(Icons.play_arrow)
                              ],
                            )
                          : fpsPageShowing
                              ? Row()
                              : Row(
                                  children: <Widget>[
                                    Text('结束监听FPS',
                                        style: TextStyle(
                                            fontSize: 16,
                                            color: Colors.red,
                                            fontWeight: FontWeight.bold,
                                            fontStyle: FontStyle.italic)),
                                    Icon(Icons.pause)
                                  ],
                                ),
                    );
                  }),
            ),
            onTap: () {
              fpsMonitor();
            },
            onVerticalDragEnd: this.widget.onDragEnd,
            onHorizontalDragEnd: this.widget.onDragEnd,
            onHorizontalDragUpdate: this.widget.onDragUpdate,
            onVerticalDragUpdate: this.widget.onDragUpdate,
          )
        ],
      ),
    );
  }

  void fpsMonitor() {
    if (!startRecording) {
      setState(() {
        start();
        startRecording = true;
        controller.value = startRecording;
      });
    } else {
      if (!fpsPageShowing) {
        stop();
        if (fpsInfoPage == null) {
          fpsInfoPage = OverlayEntry(builder: (c) {
            return MediaQuery(
              data: MediaQueryData.fromWindow(window),
              child: Scaffold(
                body: Column(
                  children: <Widget>[
                    Expanded(
                        child: GestureDetector(
                      onTap: () {
                        fpsInfoPage.remove();
                        fpsPageShowing = false;
                        start();
                      },
                      child: Container(
                        color: Color(0x33999999),
                      ),
                    )),
                    Container(
                        color: Colors.white,
                        child: Column(
                          children: <Widget>[
                            FpsPage(),
                            Divider(),
                            Container(
                              padding: const EdgeInsets.only(
                                  left: 20, top: 20, bottom: 20),
                              child: GestureDetector(
                                child: Text(
                                  '返回',
                                  style: TextStyle(color: Colors.blue),
                                ),
                                onTap: () {
                                  startRecording = false;
                                  fpsInfoPage.remove();
                                  fpsPageShowing = false;
                                  CommonStorage.instance.clear();
                                  controller.value = startRecording;
                                  // setState(() {});
                                },
                              ),
                              alignment: Alignment.bottomLeft,
                            ),
                          ],
                        )),
                  ],
                ),
                backgroundColor: Color(0x33999999),
              ),
            );
          });
        }
        fpsPageShowing = true;
        Overlay.of(context).insert(fpsInfoPage);
      }
    }
  }
}
