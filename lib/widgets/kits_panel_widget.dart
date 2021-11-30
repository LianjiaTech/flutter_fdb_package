import 'package:flutter/material.dart';
import 'package:flutter_fdb_package/global/icon_cache.dart';
import 'package:flutter_fdb_package/kit/fdb_kit.dart';
import 'package:flutter_fdb_package/kit/fdb_kits_manager.dart';

class KitsPanelWidget extends StatefulWidget {
  KitsPanelWidget({Key key, this.kitOnTap}) : super(key: key);

  final Function(FDBKit) kitOnTap;

  @override
  _KitsPanelWidgetState createState() => _KitsPanelWidgetState();
}

const double _barHeight = 32;
const double _minHeight = 80;
const double _spaceTop = 50;

class _KitsPanelWidgetState extends State<KitsPanelWidget> {
  Size _windowSize = WidgetsBinding.instance.window.physicalSize /
      WidgetsBinding.instance.window.devicePixelRatio;

  double _dy;
  List<FDBKit> dataList = [];
  double _bottom = 0;

  @override
  void initState() {
    super.initState();
    dataList = FDBKitsManager.instance.fdbKitsMap.values.toList();
    _dy = _bottom;
  }

  void _dragEvent(DragUpdateDetails details) {
    _dy -= details.delta.dy;
    int count = (_windowSize.width / _minHeight).floor();
    int rows = (dataList.length / count).ceil();
    _dy = _dy.clamp(
        0.0, _windowSize.height - _barHeight - rows * _minHeight - _spaceTop);
    _bottom = _dy;
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return Positioned(
      left: 0,
      bottom: _dy,
      child: GestureDetector(
        onVerticalDragUpdate: (detail) {
          _dragEvent(detail);
        },
        child: Material(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              _KitsPanelTitle(),
              _KitsPanelContent(
                dataList: dataList,
                kitOnTap: widget.kitOnTap,
              )
            ],
          ),
        ),
      ),
    );
  }

  @override
  void dispose() {
    super.dispose();
  }
}

class _KitsPanelTitle extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      height: _barHeight,
      width: (WidgetsBinding.instance.window.physicalSize /
              WidgetsBinding.instance.window.devicePixelRatio)
          .width,
      color: Color(0xffd0d0d0),
      child: Center(
        child: Text(
          'Flutter debug tools',
          style: TextStyle(
              color: Color(0xff575757),
              fontSize: 14,
              fontWeight: FontWeight.w600),
        ),
      ),
    );
  }
}

class _ToolBarContent extends StatefulWidget {
  _ToolBarContent({Key key, this.kitOnTap, this.dragCallback})
      : super(key: key);

  final Function(FDBKit) kitOnTap;
  final Function dragCallback;

  @override
  __ToolBarContentState createState() => __ToolBarContentState();
}

class __ToolBarContentState extends State<_ToolBarContent> {
  List<FDBKit> _dataList = [];

  @override
  void initState() {
    super.initState();
    _dataList = FDBKitsManager.instance.fdbKitsMap.values.toList();
  }

  @override
  Widget build(BuildContext context) {
    const cornerRadius = Radius.circular(10);
    return Material(
      borderRadius:
          BorderRadius.only(topLeft: cornerRadius, topRight: cornerRadius),
      elevation: 20,
      child: Container(
        width: (WidgetsBinding.instance.window.physicalSize /
                WidgetsBinding.instance.window.devicePixelRatio)
            .width,
        decoration: BoxDecoration(
          borderRadius:
              BorderRadius.only(topLeft: cornerRadius, topRight: cornerRadius),
          color: Color(0xffd0d0d0),
        ),
        child: Column(
          children: [
            Container(
              height: _barHeight,
              child: Padding(
                padding: const EdgeInsets.only(left: 8, right: 8),
                child: GestureDetector(
                  onVerticalDragUpdate: (details) => _dragCallback(details),
                  child: Container(
                    height: _barHeight,
                    color: const Color(0xffd0d0d0),
                    child: Center(
                      child: Text(
                        'Flutter debug tools',
                        style: const TextStyle(
                            color: Color(0xff575757),
                            fontSize: 14,
                            fontWeight: FontWeight.w600),
                      ),
                    ),
                  ),
                ),
              ),
            ),
            _KitsPanelContent(
              dataList: _dataList,
              kitOnTap: widget.kitOnTap,
            ),
          ],
        ),
      ),
    );
  }

  _dragCallback(DragUpdateDetails details) {
    if (widget.dragCallback != null) widget.dragCallback(details);
  }
}

class _KitsPanelContent extends StatelessWidget {
  _KitsPanelContent({Key key, this.dataList, this.kitOnTap}) : super(key: key);

  final List<FDBKit> dataList;
  final Function(FDBKit) kitOnTap;

  @override
  Widget build(BuildContext context) {
    return Container(
        width: (WidgetsBinding.instance.window.physicalSize /
                WidgetsBinding.instance.window.devicePixelRatio)
            .width,
        alignment: Alignment.center,
        color: Colors.white,
        child: Wrap(
          children: dataList
              .map(
                (data) => _KitCell(
                  kitData: data,
                  kitOnTap: kitOnTap,
                ),
              )
              .toList(),
        ));
  }
}

class _KitCell extends StatefulWidget {
  _KitCell({Key key, this.kitData, this.kitOnTap}) : super(key: key);
  final FDBKit kitData;
  final Function(FDBKit) kitOnTap;

  @override
  __KitCellState createState() => __KitCellState();
}

class __KitCellState extends State<_KitCell> {
  @override
  Widget build(BuildContext context) {
    return IconButton(
      iconSize: _minHeight,
      onPressed: () {
        _kitPressed();
      },
      icon: Column(
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          Container(
            height: 28,
            width: 28,
            child: IconCache.icon(kitInfo: widget.kitData),
          ),
          Container(
              margin: const EdgeInsets.only(top: 4),
              child: Text(
                widget.kitData.name,
                style: const TextStyle(fontSize: 12, color: Colors.black),
                maxLines: 1,
              ))
        ],
      ),
    );
  }

  void _kitPressed() {
    if (widget.kitOnTap != null) {
      widget.kitOnTap(widget.kitData);
    }
  }
}
