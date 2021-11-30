import 'dart:ui';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';

/// 根据element获取元素的四角 在屏幕中的位置
/// 如果element为null 则返回null
Rect getRectByElement(Element element) {
  if (element == null) {
    return null;
  }
  RenderBox renderBox = element.renderObject;
  if (!renderBox.attached) {
    return null;
  }
  Offset offset = renderBox.localToGlobal(Offset.zero);
  return Rect.fromLTRB(offset.dx, offset.dy, offset.dx + renderBox.size.width,
      offset.dy + renderBox.size.height);
}

///找到横向上的重叠区域的中间点
/// ------
///    -------
double findMiddleForHorizontalArea(Rect rect, Rect rect2) {
  double a = rect.left;
  double b = rect.right;
  double a1 = rect2.left;
  double b1 = rect2.right;
  List<double> list = [a, b, a1, b1];
  list.sort((test, test1) {
    return (test - test1).toInt();
  });
  double tmp = list[1] + (list[2] - list[1]) / 2;
  return list[1] + ((list[2] - list[1]) / 2);
}

///找到纵向上的重叠区域的中间点
///   |
///   |   |
///   |   |
///       |
double findMiddleForVerticalArea(Rect rect, Rect rect2) {
  double a = rect.top;
  double b = rect.bottom;
  double a1 = rect2.top;
  double b1 = rect2.bottom;
  List<double> list = [a, b, a1, b1];
  list.sort((test, test1) {
    return (test - test1).toInt();
  });
  double tmp = list[1] + (list[2] - list[1]) / 2;
  return list[1] + ((list[2] - list[1]) / 2);
}

Offset getElementLocationInfo(Element element) {
  RenderBox box = element.renderObject;
  Offset location = box.localToGlobal(Offset.zero);
  return location;
}

Size getElementSizeInfo(Element element) {
  RenderBox box = element.renderObject;
  return box.size;
}

double toLogicalPixels(double physicalPixels) =>
    physicalPixels == null ? null : physicalPixels / window.devicePixelRatio;

bool isImageAndText(Element element) {
  return element.widget is Text ||
      element.widget is RichText ||
      element.widget is RawImage ||
      element.widget is Image;
}

bool isText(Element element) {
  return element.widget is Text || element.widget is RichText;
}

///获取文本信息
String getTextInfo(Element element) {
  Widget widget = element.widget;

  String info = '';
  if (widget == null) {
    return info;
  }
  List<DiagnosticsNode> nodes = widget.toDiagnosticsNode().getProperties();

  nodes.forEach((node) {
    if (node is StringProperty && node.name == 'text') {
      info += "${node.value}";
    }
  });
  return info;
}

///生成文本信息
RichText generateRichText(String modify, Widget oldWidget) {
  TextStyle oldStyle;
  int maxLines = 1;
  if (oldWidget is Text) {
    oldStyle = oldWidget.style;
    maxLines = oldWidget.maxLines;
  } else if (oldWidget is RichText) {
    oldStyle = oldWidget.text.style;
    maxLines = oldWidget.maxLines;
  }
  return RichText(
    text: TextSpan(
      text: modify,
      style: oldStyle,
    ),
    maxLines: maxLines,
  );
}
