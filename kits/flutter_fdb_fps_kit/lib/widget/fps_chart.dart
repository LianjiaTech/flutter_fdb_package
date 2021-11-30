import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import '../bean/fps_info.dart';

double kPerBarHeightRatio = 2.5;

class BarChartPainter extends CustomPainter {
  List<FpsInfo> datas;

  BarChartPainter({@required this.datas});

  @override
  bool shouldRepaint(BarChartPainter oldDelegate) => true;

  @override
  bool shouldRebuildSemantics(BarChartPainter oldDelegate) => false;

  void _drawAxis(Canvas canvas, Size size) {
    final double sw = size.width;
    final double sh = size.height;

    // 使用 Paint 定义路径的样式
    final Paint paint = Paint()
      ..color = Colors.red
      ..style = PaintingStyle.stroke
      ..strokeWidth = 0.5;

    // 使用 Path 定义绘制的路径，从画布的左上角到左下角在到右下角
    final Path path = Path()
      ..moveTo(0, 0)
      ..lineTo(0, sh)
      ..lineTo(sw, sh);

    // 使用 drawPath 方法绘制路径
    canvas.drawPath(path, paint);
  }

  void _drawLabels(Canvas canvas, Size size) {
    double labelFontSize = 10;
    final double sh = size.height;
    final List<double> yAxisLabels = [];

    yAxisLabels.add(16);
    yAxisLabels.add(33);
    yAxisLabels.add(66);
    yAxisLabels.add(100);

    yAxisLabels.asMap().forEach(
      (index, label) {
        // 标识的高度为画布高度减去标识的值
        final double top = sh - label * kPerBarHeightRatio;
        // final rect = Rect.fromLTWH(0, top, 4, 1);
        final Offset textOffset = Offset(
          0 - (label.toInt().toString().length == 3 ? 26 : 30).toDouble(),
          top - labelFontSize / 2,
        );

        // 绘制文字需要用 `TextPainter`，最后调用 paint 方法绘制文字
        TextPainter(
          text: TextSpan(
            text: label.toStringAsFixed(0),
            style: TextStyle(fontSize: labelFontSize, color: Color(0xff4a4b5b)),
          ),
          textAlign: TextAlign.right,
          textDirection: TextDirection.ltr,
          textWidthBasis: TextWidthBasis.longestLine,
        )
          ..layout(minWidth: 0, maxWidth: 24)
          ..paint(canvas, textOffset);
      },
    );
  }

  void _drawBars(Canvas canvas, Size size) {
    int A = 0;
    int B = 0;
    int C = 0;
    int D = 0;
    for (int i = 0; i < datas.length; i++) {
      int value = datas[i].getValue().toInt();
      if (value > 66) {
        D++;
      } else if (value > 33) {
        C++;
      } else if (value > 18) {
        B++;
      } else {
        A++;
      }
    }
    TextPainter(
      text: TextSpan(
        text: "流畅：$A 良好：$B 轻微卡顿：$C 卡顿：$D",
        style: TextStyle(fontSize: 10, color: Color(0xff4a4b5b)),
      ),
      textAlign: TextAlign.right,
      textDirection: TextDirection.ltr,
      textWidthBasis: TextWidthBasis.longestLine,
    )
      ..layout(
        minWidth: 0,
      )
      ..paint(canvas, Offset.zero);
  }

  @override
  void paint(Canvas canvas, Size size) {
    _drawAxis(canvas, size);
    _drawLabels(canvas, size);
    _drawBars(canvas, size);
  }
}

class FpsBarChart extends StatefulWidget {
  final List<FpsInfo> data;

  const FpsBarChart({
    @required this.data,
  });

  @override
  _FpsBarChartState createState() => _FpsBarChartState();
}

class _FpsBarChartState extends State<FpsBarChart>
    with TickerProviderStateMixin {
  @override
  Widget build(BuildContext context) {
    double width = MediaQuery.of(context).orientation == Orientation.portrait
        ? MediaQuery.of(context).size.width - 56
        : MediaQuery.of(context).size.width - 30;
    double height = MediaQuery.of(context).orientation == Orientation.portrait
        ? MediaQuery.of(context).size.height - 500
        : MediaQuery.of(context).size.height - 200;
    return Container(
      width: width,
      height: height,
      margin: EdgeInsets.only(top: 40, left: 24),
      child: Stack(
        children: <Widget>[
          CustomPaint(
            size: Size(width, height),
            foregroundPainter: BarChartPainter(datas: widget.data),
          ),
          Align(
            alignment: Alignment.bottomLeft,
            child: _histogramWidget(width, height),
          )
        ],
      ),
    );
  }

  Widget _histogramWidget(double width, double height) {
    return Container(
      width: width - 40,
      height: height - 24,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemBuilder: (BuildContext context, int index) {
          int value = widget.data[index].getValue().toInt();
          return Container(
            width: 10,
            padding: EdgeInsets.fromLTRB(
                0, height - 24 - value * kPerBarHeightRatio.toDouble(), 0, 0),
            child: Container(
              color: value <= 18
                  ? Color(0xff55a8fd)
                  : value <= 33
                      ? Color(0xfffad337)
                      : value <= 66 ? Color(0xFFF48FB1) : Color(0xFFD32F2F),
            ),
          );
        },
        itemCount: widget.data.length,
        // itemExtent: 20,
      ),
    );
  }
}
