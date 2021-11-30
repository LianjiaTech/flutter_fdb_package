import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_fdb_code_kit/widget/display_code_kit.dart';
import 'package:flutter_fdb_memory_kit/info/memory_info_kit.dart';
import 'package:flutter_fdb_package/global/constants.dart';
import 'package:flutter_fdb_package/kit/fdb_kit.dart';
import 'package:flutter_fdb_package/kit/fdb_kits_manager.dart';
import 'package:flutter_fdb_package/widgets/fdb_logo_widget.dart';
import 'package:flutter_fdb_package/widgets/kits_panel_widget.dart';
import 'package:flutter_fdb_package/flutter_fdb_package.dart';
import 'package:flutter_fdb_widget_kit/flutter_fdb_widget_kit.dart';
import 'package:flutter_fdb_memory_kit/flutter_fdb_memory_kit.dart';
import 'package:flutter_fdb_fps_kit/flutter_fdb_fps_kit.dart';


Widget fdbEnterWidget({
  Widget child,
  bool enable,
}) {
  if (kReleaseMode || !enable) {
    return child;
  }
  if (enable) {
    FDBKitsManager.instance
      ..register(FdbInspectorKit())
      ..register(FdbRulerKit())
      ..register(FdbColorPickKit())
      ..register(MemoryInfoKit())
      ..register(FdbFpsDetectKit())
      ..register(DisplayCodeKit());
  }
  return _EntryWidget(
    child: child,
  );
}

class _EntryWidget extends StatelessWidget {
  final Widget child;

  _EntryWidget({
    Key key,
    this.child,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Stack(alignment: Alignment.center, children: [
      RepaintBoundary(
        child: this.child,
        key: rootKey,
      ),
      Directionality(
          textDirection: TextDirection.ltr, child: _ContentOrEmptyEntry())
    ]);
  }
}

class _ContentOrEmptyEntry extends StatefulWidget {
  _ContentOrEmptyEntry({
    Key key,
  }) : super(key: key);

  @override
  _ContentOrEmptyEntryState createState() => _ContentOrEmptyEntryState();
}

class _ContentOrEmptyEntryState extends State<_ContentOrEmptyEntry> {
  Size _windowSize = WidgetsBinding.instance.window.physicalSize /
      WidgetsBinding.instance.window.devicePixelRatio;

  bool _showedPanel = false;
  FDBKit _currentSelected;
  Widget _empty;
  Widget _currentWidget;
  Widget _panelWidget;
  LogoModel _logoModel;

  @override
  void initState() {
    super.initState();
    initWidget();
    FdbBroadcastManager.instance.register("CLOSE", (value, callback) {
      closeCurrentFun();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Overlay(initialEntries: [
      OverlayEntry(builder: (context) {
        return Container(
          width: _windowSize.width,
          height: _windowSize.height,
          child: Stack(
            alignment: Alignment.center,
            children: <Widget>[
              _currentWidget,
              FdbLogoEntryWidget(
                modelNotifier: _logoModel,
                logoOnTap: _onLogoTap,
              )
            ],
          ),
        );
      }),
    ]);
  }

  void initWidget() {
    _empty = Container(
      width: 0,
    );
    _logoModel = LogoModel();
    _panelWidget = KitsPanelWidget(
      kitOnTap: _itemOnTap,
    );
    _currentWidget = _empty;
  }

  void _onLogoTap() {
    if (!_showedPanel) {
      _openPanel();
    } else {
      _closePanel();
    }
  }

  void _itemOnTap(FDBKit kitData) {
    _currentSelected = kitData;
    _currentWidget = kitData.buildWidget(context);
    setState(() {
      _showedPanel = false;
    });
    kitData.contentWidgetVisibilityChange(true);
    if (kitData.onTrigger != null) {
      kitData.onTrigger();
    }
    _logoModel.imageProvider = _currentSelected.iconImageProvider;
  }

  void closeCurrentFun() {
    if (_currentSelected != null) {
      _currentWidget = _panelWidget;
      _showedPanel = true;
      _currentSelected?.contentWidgetVisibilityChange(false);
      _currentSelected = null;
      setState(() {});
    }
  }

  void _openPanel() {
    _showedPanel = true;
    _currentWidget = _panelWidget;

    _currentSelected?.contentWidgetVisibilityChange(false);
    _currentSelected = null;
    _logoModel.imageProvider = null;

    _logoModel.color = Colors.red;
    setState(() {});
  }

  void _closePanel() {
    _currentWidget = _empty;
    _showedPanel = false;
    _currentWidget = _empty;
    _logoModel.imageProvider = null;
    _logoModel.color = null;
    _currentSelected?.contentWidgetVisibilityChange(false);
    setState(() {});
  }
}
