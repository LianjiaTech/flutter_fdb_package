import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter_fdb_package/global/constants.dart';
import 'package:flutter_fdb_package/service/store/kit_store_manager.dart';

class FdbLogoEntryWidget extends StatefulWidget {
  final LogoModel modelNotifier;
  final VoidCallback logoOnTap;

  FdbLogoEntryWidget({this.modelNotifier, this.logoOnTap});

  @override
  _FdbLogoEntryWidgetState createState() => _FdbLogoEntryWidgetState();
}

class _FdbLogoEntryWidgetState extends State<FdbLogoEntryWidget> {
  LogoModel model;
  Size _windowSize;

  @override
  void initState() {
    super.initState();
    model = widget.modelNotifier;
    _windowSize = window.physicalSize / window.devicePixelRatio;
    KitStoreManager.instance.fetchFloatingDotPos().then((value) {
      if (value == null || value.split(',').length != 2) {
        return;
      }
      model.xy(double.parse(value.split(',').first),
          double.parse(value.split(',').last));
    });

    widget.modelNotifier.addListener(() {
      setState(() {});
    });
  }

  @override
  void didUpdateWidget(FdbLogoEntryWidget oldWidget) {
    super.didUpdateWidget(oldWidget);
    model = widget.modelNotifier;
    widget.modelNotifier.addListener(() {
      setState(() {});
    });
  }

  @override
  Widget build(BuildContext context) {
    return Positioned(
      left: model._x ?? _windowSize.width - kEntrySize.width - margin * 4,
      top: model._y ?? _windowSize.height - kEntrySize.height - bottomDistance,
      child: GestureDetector(
        onTap: widget.logoOnTap,
        onPanUpdate: _panUpdate,
        onPanEnd: _panEnd,
        child: _buildEntryWidget(),
      ),
    );
  }

  void _panUpdate(DragUpdateDetails details) {
    Offset offset = details.delta;
    model.xy(model._x + offset.dx, model._y + offset.dy);
  }

  void _panEnd(DragEndDetails details) {
    if (model._x + kEntrySize.width / 2 < _windowSize.width / 2) {
      model.x = margin;
    } else {
      model.x = _windowSize.width - kEntrySize.width - margin;
    }
    if (model._y + kEntrySize.height > _windowSize.height) {
      model.y = _windowSize.height - kEntrySize.height - margin;
    } else if (model._y < 0) {
      model.y = margin;
    }

    KitStoreManager.instance.storeFloatingDotPos(model._x, model._x);
  }

  Widget _buildEntryWidget() {
    return Container(
      decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: Colors.white,
          boxShadow: [
            BoxShadow(
                color: Colors.black12,
                offset: Offset(0.0, 0.0),
                blurRadius: 2.0,
                spreadRadius: 1.0)
          ]),
      width: kEntrySize.width,
      height: kEntrySize.height,
      child: Center(
        child: _logoWidget(),
      ),
    );
  }

  Widget _logoWidget() {
    if (model.imageProvider == null) {
      return FlutterLogo(size: 40, colors: model.color);
    }
    return Container(
        child: Image(image: model.imageProvider), height: 40, width: 40);
  }
}

class LogoModel extends ChangeNotifier {
  double _x;
  double _y;
  Color color;
  ImageProvider imageProvider;

  set x(double x) {
    this._x = x;
    notifyListeners();
  }

  set y(double y) {
    this._y = y;
    notifyListeners();
  }

  void xy(double x, double y) {
    this._y = y;
    this._x = x;
    notifyListeners();
  }

  set logoColor(Color color) {
    this.color = color;
    notifyListeners();
  }

  set logoImage(ImageProvider imageProvider) {
    this.imageProvider = imageProvider;
    notifyListeners();
  }
}
