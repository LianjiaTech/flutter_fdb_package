import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';

class FdbOverlay {
  static FdbOverlay _instance;

  FdbOverlay._() {
    mapEntry = {};
    mapBuilder = {};
  }

  Map<String, OverlayEntry> mapEntry;
  Map<String, FdbOverlayBuilder> mapBuilder;

  static FdbOverlay getInstance() {
    if (_instance == null) {
      _instance = FdbOverlay._();
    }
    return _instance;
  }

  String currentTag;

  FdbOverlay putBuilder(FdbOverlayBuilder overlayBuilder, String tag) {
    mapBuilder[tag] = overlayBuilder;
    this.currentTag = tag;
    return this;
  }

  void show(BuildContext context, {String tag}) {
    if (tag == null) {
      tag = currentTag;
    }
    if (tag == null) {
      return;
    }
    remove(tag);

    FdbOverlayBuilder builder = mapBuilder.putIfAbsent(tag, () {
      return FdbOverlayBuilder();
    });

    mapEntry[tag] = builder.build(context);

    Overlay.of(context).insert(mapEntry[tag]);
  }

  bool isShow(BuildContext context, {String tag}) {
    return Overlay.of(context).debugIsVisible(mapEntry[tag]);
  }

  void remove(String tag) {
    OverlayEntry entry = mapEntry.remove(tag);
    if (entry != null) {
      entry.remove();
      entry = null;
    }
  }
}

class FdbOverlayBuilder {
  double _dx;
  double _dy;
  bool _isFollow;
  bool _isWelt;
  bool _isCustomize;
  Widget _floatWidget;
  Function(Offset offset) _dragEndCallback;
  ValueNotifier<Rect> _locationNotifier;

  bool get _follow => _isFollow ?? false;

  bool get _welt => _isWelt ?? false;

  bool get _customize => _isCustomize ?? false;
  VoidCallback callback;

  FdbOverlayBuilder();

  FdbOverlayBuilder widget(Widget widget) {
    this._floatWidget = widget;
    return this;
  }

  FdbOverlayBuilder dx(double dx) {
    this._dx = dx;
    return this;
  }

  FdbOverlayBuilder dy(double dy) {
    this._dy = dy;
    return this;
  }

  FdbOverlayBuilder custom(bool customize) {
    this._isCustomize = customize;
    return this;
  }

  FdbOverlayBuilder needFollow(bool follow) {
    this._isFollow = follow;
    return this;
  }

  FdbOverlayBuilder needWelt(bool welt) {
    this._isWelt = welt;
    return this;
  }

  FdbOverlayBuilder locationNotifier(ValueNotifier<Rect> notifier) {
    this._locationNotifier = notifier;
    return this;
  }

  FdbOverlayBuilder dragCallback(Function(Offset offset) back) {
    this._dragEndCallback = back;
    return this;
  }

  OverlayEntry build(BuildContext context) {
    return OverlayEntry(builder: (context) {
      if (_customize) {
        if (_follow) {
          return _FDKFollowWidget(
            floatWidget: _floatWidget,
            initX: _dx,
            initY: _dy,
            locationNotifier: _locationNotifier,
            dragCallBack: _dragEndCallback,
          );
        }
        return _floatWidget;
      }

      if (_dy == null && _dx == null) {
        return Center(
          child: _floatWidget,
        );
      }
      return Positioned(
        top: _dy == null ? 0 : _dy,
        left: _dx == null ? 0 : _dx,
        child: _follow ? _floatWidget : _floatWidget,
      );
    });
  }
}

class _FDKFollowWidget extends StatefulWidget {
  final Widget floatWidget;
  final bool isWelt;
  final double initX;
  final double initY;
  final void Function(Offset offset) dragCallBack;
  final ValueNotifier<Rect> locationNotifier;

  _FDKFollowWidget(
      {this.floatWidget,
      this.isWelt = false,
      this.initX = 0,
      this.initY = 0,
      this.locationNotifier,
      this.dragCallBack});

  @override
  __FDKFollowWidgetState createState() => __FDKFollowWidgetState();
}

class __FDKFollowWidgetState extends State<_FDKFollowWidget> {
  double left;
  double top;

  @override
  void initState() {
    super.initState();
    left = widget.initX ?? 0;
    top = widget.initY ?? 0;

    widget.locationNotifier?.addListener(() {
      updateLocation();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Positioned(
      top: top,
      left: left,
      child: GestureDetector(
          onPanUpdate: (detail) {
            setState(() {
              top += detail.delta.dy;
              left += detail.delta.dx;
            });
          },
          onPanEnd: (detail) {
            if (widget.dragCallBack != null) {
              widget.dragCallBack(Offset(left, top));
            }
          },
          child: widget.floatWidget),
    );
  }

  void updateLocation() {
    Rect rect = widget.locationNotifier.value;
    setState(() {
      top = rect.top;
      left = rect.left;
    });
  }
}
