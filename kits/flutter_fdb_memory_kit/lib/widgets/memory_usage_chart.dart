import 'dart:math';

import 'package:flutter/material.dart';
import 'package:vm_service/vm_service.dart';

import '../bean/memory_info_bean.dart';

class MemoryInfoChart extends StatelessWidget {
  final MemoryUsageWrapperModel memoryUsage;

  MemoryInfoChart({this.memoryUsage});

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      painter: MemoryInfoPainter(memoryUsage: memoryUsage),
      size: Size(100, 100),
    );
  }
}

class MemoryInfoPainter extends CustomPainter {
  MemoryUsageWrapperModel memoryUsage;
  Paint _paint;

  MemoryInfoPainter({this.memoryUsage}) {
    _paint = Paint();
  }

  @override
  void paint(Canvas canvas, Size size) {
    _paint.color = Colors.red;
    _paint.strokeWidth = 2;
    _paint.style = PaintingStyle.fill;

    canvas.save();
    canvas.translate(size.height / 2, size.width / 2);
    var rect = Rect.fromCenter(
        center: Offset(0, 0), height: size.width, width: size.height);

    var rect1 = Rect.fromCenter(
        center: Offset(0, 0), height: size.width - 4, width: size.height - 4);
    var a = (memoryUsage.heapUsage / memoryUsage.heapCapacity) * 360 / 180 * pi;

    canvas.drawArc(
        rect, a, 2 * pi - a.abs() * 2, true, _paint..color = Colors.redAccent);
    var b = (360 - (memoryUsage.heapUsage / memoryUsage.heapCapacity) * 360) /
        180 *
        pi;
    canvas.drawArc(rect1, -b, b * 2, true, _paint..color = Colors.greenAccent);

    canvas.drawRect(Rect.fromPoints(Offset(70, -30), Offset(100, -10)),
        _paint..color = Colors.redAccent);
    _drawText(canvas, "已使用", Offset(110, -30), color: Colors.redAccent);

    canvas.drawRect(Rect.fromPoints(Offset(70, 10), Offset(100, 30)),
        _paint..color = Colors.greenAccent);
    _drawText(canvas, "未使用", Offset(110, 10), color: Colors.greenAccent);
    canvas.restore();
  }

  void _drawText(
    Canvas canvas,
    String str,
    Offset offset, {
    Color color = Colors.black,
  }) {
    final TextPainter textPainter =
        TextPainter(textDirection: TextDirection.ltr);
    TextSpan text =
        TextSpan(text: str, style: TextStyle(fontSize: 11, color: color));
    textPainter.text = text;
    textPainter.layout(); // 进行布局
    textPainter.paint(canvas, offset);
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) {
    return true;
  }
}
