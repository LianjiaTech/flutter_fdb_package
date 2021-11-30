import 'dart:convert';
import 'dart:typed_data';
import 'dart:ui';
import 'dart:ui' as tet show TextStyle;

import 'package:flutter/material.dart';
import 'package:path_drawing/path_drawing.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../common/fdb_overlay.dart';
import '../common/icon.dart';

const String CHECK_OVERLAY_TYPE = "INSPECTOR_CHECK_TYPE";

class FdbRulerPointer extends StatefulWidget {
  @override
  _FdbRulerPointerState createState() => _FdbRulerPointerState();

  void stopTask() {
    FdbOverlay.getInstance().remove(CHECK_OVERLAY_TYPE);
  }
}

class _FdbRulerPointerState extends State<FdbRulerPointer> {
  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance.addPostFrameCallback((t) {
      print('end frame');
      FdbOverlayBuilder builder = FdbOverlayBuilder();
      builder.widget(InspectorCheckTaskWidget());
      FdbOverlay.getInstance()
          .putBuilder(builder, CHECK_OVERLAY_TYPE)
          .show(context);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 0,
      height: 0,
    );
  }
}

class InspectorCheckTaskWidget extends StatefulWidget {
  @override
  _InspectorCheckTaskWidgetState createState() =>
      _InspectorCheckTaskWidgetState();
}

class _InspectorCheckTaskWidgetState extends State<InspectorCheckTaskWidget> {
  Offset _a;
  Offset _b;
  Uint8List _uint8list;

  @override
  void initState() {
    super.initState();
    _a = Offset(200, 200);
    _b = Offset(200, 400);
    _uint8list = base64Decode(checkIcon);

    SharedPreferences.getInstance().then((sp) {
      double _aX = sp.getDouble("ruler_A_X") ?? 200;
      double _aY = sp.getDouble("ruler_A_Y") ?? 200;
      double _bX = sp.getDouble("ruler_B_X") ?? 200;
      double _bY = sp.getDouble("ruler_B_Y") ?? 400;
      _a = Offset(_aX, _aY);
      _b = Offset(_bX, _bY);

      setState(() {});
    });
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: <Widget>[
        Positioned(
          left: _b.dx + 15,
          child: CustomPaint(
            painter: DashPainter(
              true,
              Offset(0, 0),
              Offset(0, 10000),
            ),
          ),
        ),
        Positioned(
          top: _b.dy + 15,
          child: CustomPaint(
            painter: DashPainter(
              false,
              Offset(0, 0),
              Offset(10000, 0),
            ),
          ),
        ),
        Positioned(
          top: _a.dy,
          left: _a.dx,
          child: GestureDetector(
            onPanUpdate: (detail) {
              _a += Offset(detail.delta.dx, detail.delta.dy);
              setState(() {});
            },
            child: Image.memory(
              _uint8list,
              width: 30,
              color: Colors.red,
            ),
          ),
        ),
        Positioned(
          top: _b.dy,
          left: _b.dx,
          child: GestureDetector(
            onPanUpdate: (detail) {
              _b += Offset(detail.delta.dx, detail.delta.dy);
              setState(() {});
            },
            child: Image.memory(
              _uint8list,
              width: 30,
              color: Colors.red,
            ),
          ),
        ),
        Positioned(
          top: _a.dy + 15,
          left: _a.dx + 15,
          child: CustomPaint(
            painter: CheckPainter(_b.translate(-_a.dx, -_a.dy)),
          ),
        ),
      ],
    );
  }

  @override
  void dispose() {
    super.dispose();
    SharedPreferences.getInstance().then((sp) {
      sp.setDouble("ruler_A_X", _a.dx);
      sp.setDouble("ruler_A_Y", _a.dy);
      sp.setDouble("ruler_B_X", _b.dx);
      sp.setDouble("ruler_B_Y", _b.dy);
    });
  }
}

class CheckPainter extends CustomPainter {
  Offset desOffset;
  Paint _paint;

  CheckPainter(this.desOffset) {
    _paint = Paint();
    _paint.strokeWidth = 1;
    _paint.color = Colors.red;
    _paint.style = PaintingStyle.stroke;
  }

  @override
  void paint(Canvas canvas, Size size) {
    _paintHor(canvas);
    _paintVer(canvas);
  }

  void _paintHor(Canvas canvas) {
    if (desOffset.dx == 0 || desOffset.dx.toInt() == 0) {
      return;
    }
    if (desOffset.dy != 0) {
      Path path = Path();
      path.lineTo(desOffset.dx, 0);
      canvas.drawPath(path, _paint);
    }

    Offset offset = Offset(0, 0);
    if (desOffset.dx < 0) {
      offset = Offset(desOffset.dx, 0);
    }

    double tetWidth =
        desOffset.dx.abs() < 25.toDouble() ? 25.toDouble() : desOffset.dx.abs();
    TextAlign align =
        tetWidth == 25.toDouble() ? TextAlign.start : TextAlign.center;

    canvas.drawParagraph(
        getParagraph(desOffset.dx.abs().toInt().toString(), tetWidth,
            textAlign: align),
        offset);
  }

  void _paintVer(Canvas canvas) {
    if (desOffset.dy.toInt() == 0) {
      return;
    }
    Path path = Path();
    if (desOffset.dx != 0) {
      path.lineTo(0, desOffset.dy);
      canvas.drawPath(path, _paint);
    }

    Offset offset = Offset(0, desOffset.dy / 2 - 7);

    canvas.drawParagraph(
        getParagraph(desOffset.dy.abs().toInt().toString(), 14 * 4.toDouble(),
            textAlign: TextAlign.start),
        offset);
  }

  Paragraph getParagraph(String text, double width, {TextAlign textAlign}) {
    var pb = ParagraphBuilder(ParagraphStyle(
        textAlign: textAlign ?? TextAlign.center,
        fontSize: 14.toDouble(),
        maxLines: 1));

    pb.pushStyle(tet.TextStyle(
      color: Colors.red,
    ));
    pb.addText(text);
    var paragraph = pb.build()..layout(ParagraphConstraints(width: width));
    return paragraph;
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) {
    return true;
  }
}

class DashPainter extends CustomPainter {
  Paint _paint;
  bool isVertical;
  Offset originOffset;
  Offset desOffset;

  DashPainter(this.isVertical, this.originOffset, this.desOffset) {
    _paint = Paint();
    _paint.strokeWidth = 1;
    _paint.color = Colors.red;
    _paint.style = PaintingStyle.stroke;
  }

  @override
  void paint(Canvas canvas, Size size) {
    Path path = Path();
    if (isVertical) {
      path.moveTo(originOffset.dx, 0);
      path.lineTo(originOffset.dx, desOffset.dy);
    } else {
      path.moveTo(0, originOffset.dy);
      path.lineTo(desOffset.dx, originOffset.dy);
    }
    canvas.drawPath(
      dashPath(
        path,
        dashArray: CircularIntervalList<double>(<double>[5.0, 5.5]),
      ),
      _paint,
    );
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) {
    // TODO: implement shouldRepaint
    return true;
  }
}
