import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_fdb_package/flutter_fdb_package.dart';

import 'performance_observer_widget.dart';
import 'icon.dart' as icon;

class FdbFpsDetectKit extends StatefulWidget implements FDBKit {
  /// 展示性能监控数据
  static bool debugShowPerformanceMonitor = true;

  /// Creates a widget that enables inspection for the child.
  ///
  /// The [child] argument must not be null.
  const FdbFpsDetectKit({Key key}) : super(key: key);

  @override
  _FdbFpsDetectKitState createState() => _FdbFpsDetectKitState();

  @override
  Widget buildWidget(BuildContext context) => this;

  @override
  ImageProvider<Object> get iconImageProvider =>
      MemoryImage(base64Decode(icon.iconData));

  @override
  String get name => 'FPS';

  @override
  void onTrigger() {}

  @override
  void contentWidgetVisibilityChange(bool visibility) {
  }
}

class _FdbFpsDetectKitState extends State<FdbFpsDetectKit> {
  /// Distance from the edge of the bounding box for an element to consider
  /// as selecting the edge of the bounding box.

  final InspectorSelection selection =
      WidgetInspectorService.instance.selection;

  double _dx = 10.0;
  double _dy = 40.0;
  Size _windowSize = WidgetsBinding.instance.window.physicalSize /
      WidgetsBinding.instance.window.devicePixelRatio;
  Size _dotSize = Size(130.0, 65.0);
  @override
  void initState() {
    super.initState();
    _windowSize = WidgetsBinding.instance.window.physicalSize /
        WidgetsBinding.instance.window.devicePixelRatio;
    _dx = _windowSize.width - _dotSize.width - margin;
    _dy = _windowSize.height - _dotSize.height - bottomDistance;
  }

  @override
  Widget build(BuildContext context) {
    Widget performanceObserver =
        PerformanceObserverWidget(this.dragEnd, this.dragEvent);
    return Stack(
      alignment: AlignmentDirectional.topStart,
      children: <Widget>[
        Positioned(
          left: _dx,
          top: _dy,
          child: performanceObserver,
        )
      ],
    );
  }

  void dragEvent(DragUpdateDetails details) {
    _dx = details.globalPosition.dx - _dotSize.width / 2;
    _dy = details.globalPosition.dy - _dotSize.height / 2;
    setState(() {});
  }

  void dragEnd(DragEndDetails details) {
    if (_dx + _dotSize.width / 2 < _windowSize.width / 2) {
      _dx = margin;
    } else {
      _dx = _windowSize.width - _dotSize.width - margin;
    }
    if (_dy + _dotSize.height > _windowSize.height) {
      _dy = _windowSize.height - _dotSize.height - margin;
    } else if (_dy < 0) {
      _dy = margin;
    }
    setState(() {});
  }

  @override
  void dispose() {
    super.dispose();
  }
}
