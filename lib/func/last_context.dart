import 'package:flutter/material.dart';
import 'package:flutter_fdb_package/flutter_fdb_package.dart';

mixin LastContext {
  Element last;

  Element lastContextFromRoot() {
    _findAllElement(rootKey.currentContext);
    return last;
  }

  void _findAllElement(Element element) {
    if (element != null) {
      last = element;
    }
    List<DiagnosticsNode> nodes = element.debugDescribeChildren();
    nodes.forEach((data) {
      if (data.value is Element) {
        _findAllElement(data.value);
      }
    });
  }
}
