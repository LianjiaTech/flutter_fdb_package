import 'dart:async';
import 'dart:typed_data';
import 'dart:ui';
import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'package:flutter_fdb_package/flutter_fdb_package.dart';
import 'package:image/image.dart' as _image;

import '../common/fdb_overlay.dart';

class ColorPickerWidget extends StatefulWidget {
  @override
  _ColorPickerWidgetState createState() => _ColorPickerWidgetState();
}

const double _kLineWidth = 1;
const double _kCircleWidth = 3;
const double _kCircleSize = 100;
const String _kColorInfo = "_kColorInfo";
const String kColorClose = "_kColorClose";

class _ColorPickerWidgetState extends State<ColorPickerWidget> {
  double _dy;
  double _dx;
  _image.Image _screen;
  FdbOverlayBuilder _fdbOverlayBuilder;
  ValueNotifier<Color> _pickerColor;

  @override
  void initState() {
    super.initState();
    _dy = (window.physicalSize / window.devicePixelRatio).height / 2;
    _dx = (window.physicalSize / window.devicePixelRatio).width / 2;
    _captureScreen(true);

    FdbBroadcastManager.instance.register(kColorClose, (value, _) {
      FdbOverlay.getInstance().remove(_kColorInfo);
    });
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {},
      onPanStart: (detail) async {
        _captureScreen(false);
      },
      onPanUpdate: (detail) {
        _panUpdate(detail);
      },
      child: Stack(
        children: <Widget>[
          Positioned(
            top: _dy - _kCircleSize / 2,
            left: _dx - _kCircleSize / 2,
            child: Container(
              height: _kCircleSize,
              width: _kCircleSize,
              decoration: BoxDecoration(
                  border: Border.all(
                      color: Color(0xffff6666), width: _kCircleWidth),
                  shape: BoxShape.circle,
                  color: Colors.transparent),
            ),
          ),
          Positioned(
            top: _dy - _kCircleSize / 2 + _kCircleWidth / 2,
            left: _dx,
            child: Container(
              width: _kLineWidth,
              height: _kCircleSize - _kCircleWidth,
              color: Color(0xff0000cc),
            ),
          ),
          Positioned(
            top: _dy,
            left: _dx - _kCircleSize / 2 + _kCircleWidth / 2,
            child: Container(
              width: _kCircleSize - _kCircleWidth,
              height: _kLineWidth,
              color: Color(0xff0000cc),
            ),
          ),
        ],
      ),
    );
  }

  void _panUpdate(DragUpdateDetails details) {
    _dy += details.delta.dy;
    _dx += details.delta.dx;
    setState(() {});
    _pickColorFromXY();
  }

  void _pickColorFromXY() {
    if (_screen == null) {
      return;
    }
    int _color = _screen.getPixel(_dx.toInt(), _dy.toInt());
    Color temp = Color(_color);
    Color color = Color.fromARGB(temp.alpha, temp.blue, temp.green, temp.red);
    if (_pickerColor == null) {
      _pickerColor = ValueNotifier(color);
    }
    _pickerColor.value = color;
    _showColorInfo();
  }

  void _captureScreen(bool init) async {
    RenderObject rootRender = rootKey.currentContext.findRenderObject();
    RenderRepaintBoundary repaintBoundary;
    if (rootRender is RenderRepaintBoundary) {
      repaintBoundary = rootRender;
    } else {
      repaintBoundary = rootKey.currentContext
          .findAncestorRenderObjectOfType<RenderRepaintBoundary>();
    }
    if (repaintBoundary == null) {
      return Future.value(null);
    }
    ui.Image screen = await repaintBoundary.toImage();
    ByteData imageByte = await screen.toByteData(format: ImageByteFormat.png);
    Uint8List int32list = imageByte.buffer.asUint8List();
    _screen = _image.decodeImage(int32list);
    screen.dispose();
    if (init) {
      _pickColorFromXY();
    }
  }

  void _showColorInfo() {
    if (_fdbOverlayBuilder == null) {
      _fdbOverlayBuilder = FdbOverlayBuilder()
          .custom(true)
          .needWelt(false)
          .dx(100)
          .dy(50)
          .needFollow(true)
          .widget(Material(
            type: MaterialType.transparency,
            child: _PickedColor(
              color: _pickerColor,
            ),
          ));
      FdbOverlay.getInstance().putBuilder(_fdbOverlayBuilder, _kColorInfo).show(
            context,
          );
    }
  }
}

class _PickedColor extends StatelessWidget {
  final ValueNotifier<Color> color;

  _PickedColor({this.color});

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<Color>(
      valueListenable: color,
      builder: (context, color, child) {
        return Card(
          shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.all(Radius.circular(6))),
          child: Container(
            padding: EdgeInsets.only(top: 10, bottom: 10, right: 5),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: <Widget>[
                SizedBox(
                  width: 10,
                ),
                Container(
                  height: 50,
                  width: 50,
                  child: ClipOval(
                    child: AnimatedContainer(
                      duration: Duration(milliseconds: 30),
                      color: color,
                    ),
                  ),
                ),
                SizedBox(
                  width: 10,
                ),
                Text(
                  color.toString(),
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                )
              ],
            ),
          ),
        );
      },
    );
  }
}
