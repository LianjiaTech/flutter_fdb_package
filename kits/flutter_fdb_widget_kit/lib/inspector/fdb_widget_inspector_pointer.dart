import 'dart:convert';
import 'dart:typed_data';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_fdb_package/flutter_fdb_package.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../common/fdb_overlay.dart';
import '../common/icon.dart';
import 'inspector_element_change_listener.dart';

const String CHECK_INFO_TYPE = "INSPECTOR_INFO_TYPE";
const String ICON_OFFSET_X = "ICON_OFFSET_X";
const String ICON_OFFSET_Y = "ICON_OFFSET_Y";

class FdbInspectorPointer extends StatefulWidget {
  @override
  _FdbInspectorPointerState createState() => _FdbInspectorPointerState();

  void stopTask() {
    FdbOverlay.getInstance().remove(CHECK_INFO_TYPE);
    FdbOverlay.getInstance().remove(kOverlayBackgroundType);
    FdbOverlay.getInstance().remove(kOverlayInfoType);
  }
}

class _FdbInspectorPointerState extends State<FdbInspectorPointer> {
  double _top = 200;
  double _left = 200;

  InspectorSelection selection;
  Element currentSelectionElement;
  InspectorElementChange _inspectorElementChange;
  Uint8List _uint8list;

  @override
  void initState() {
    super.initState();
    selection = WidgetInspectorService.instance.selection;
    _uint8list = base64Decode(pointerIcon);
    _inspectorElementChange = new InspectorElementChange(context);
    _getIconOffset().then((data) {
      _top = data.dy;
      _left = data.dx;
      setState(() {});
    });
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: <Widget>[
        Positioned(
          top: _top,
          left: _left,
          child: GestureDetector(
            onPanEnd: (details) {
              _inspectAt(Offset(_left + 15, _top + 15), true);
              _storeIconOffset(Offset(_left, _top));
              setState(() {});
            },
            onPanUpdate: (detail) {
              _top += detail.delta.dy;
              _left += detail.delta.dx;
              setState(() {});
              _inspectAt(Offset(_left + 15, _top + 15), false);
            },
            child: Image.memory(
              _uint8list,
              height: 40,
            ),
          ),
        )
      ],
    );
  }

  void _storeIconOffset(Offset offset) async {
    SharedPreferences sharedPreferences = await SharedPreferences.getInstance();
    sharedPreferences.setString(ICON_OFFSET_X, offset.dx.toString());
    sharedPreferences.setString(ICON_OFFSET_Y, offset.dy.toString());
  }

  Future<Offset> _getIconOffset() async {
    Offset offset = Offset(200, 200);

    SharedPreferences sharedPreferences = await SharedPreferences.getInstance();
    String x = sharedPreferences.getString(ICON_OFFSET_X);
    String y = sharedPreferences.getString(ICON_OFFSET_Y);
    if (x == null || y == null) {
      return offset;
    }
    offset = Offset(double.tryParse(x), double.tryParse(y));
    return offset;
  }

  void _inspectAt(Offset position, bool isUp) {
    final RenderBox ignorePointer = rootKey.currentContext.findRenderObject();
    final List<RenderObject> selected = hitTest(position, ignorePointer);

    selection.candidates = selected;
    if (!isUp) {
      if (selection.currentElement == currentSelectionElement) {
        return;
      }
    }
    currentSelectionElement = selection.currentElement;
    _inspectorElementChange.inspectorElementChangeListener(
        currentSelectionElement, isUp);
  }

  List<RenderObject> hitTest(Offset position, RenderObject root) {
    final List<RenderObject> regularHits = <RenderObject>[];
    final List<RenderObject> edgeHits = <RenderObject>[];

    _hitTestHelper(
        regularHits, edgeHits, position, root, root.getTransformTo(null));
    double _area(RenderObject object) {
      final Size size = object.semanticBounds?.size;
      return size == null ? double.maxFinite : size.width * size.height;
    }

    regularHits
        .sort((RenderObject a, RenderObject b) => _area(a).compareTo(_area(b)));
    final Set<RenderObject> hits = <RenderObject>{
      ...edgeHits,
      ...regularHits,
    };
    return hits.toList();
  }

  bool _hitTestHelper(
    List<RenderObject> hits,
    List<RenderObject> edgeHits,
    Offset position,
    RenderObject object,
    Matrix4 transform,
  ) {
    bool hit = false;
    final Matrix4 inverse = Matrix4.tryInvert(transform);
    if (inverse == null) {
      return false;
    }
    final Offset localPosition = MatrixUtils.transformPoint(inverse, position);

    final List<DiagnosticsNode> children = object.debugDescribeChildren();

    for (int i = children.length - 1; i >= 0; i -= 1) {
      final DiagnosticsNode diagnostics = children[i];
      assert(diagnostics != null);
      if (diagnostics.style == DiagnosticsTreeStyle.offstage ||
          diagnostics.value is! RenderObject) continue;
      final RenderObject child = diagnostics.value;
      final Rect paintClip = object.describeApproximatePaintClip(child);
      if (paintClip != null && !paintClip.contains(localPosition)) continue;

      final Matrix4 childTransform = transform.clone();
      object.applyPaintTransform(child, childTransform);
      if (_hitTestHelper(hits, edgeHits, position, child, childTransform))
        hit = true;
    }

    final Rect bounds = object.semanticBounds;
    if (bounds.contains(localPosition)) {
      hit = true;
      if (!bounds.deflate(20).contains(localPosition)) edgeHits.add(object);
    }
    if (hit) hits.add(object);
    return hit;
  }

  void showBackground() {}
}
