import 'dart:convert';
import 'dart:ui';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_fdb_package/flutter_fdb_package.dart';

import '../common/icon.dart';
import '../widgets/memory_app_bar.dart';
import '../widgets/memory_info_content.dart';
import '../widgets/memory_info_title.dart';

class MemoryInfoKit implements FDBKit {
  @override
  Widget buildWidget(BuildContext context) => MediaQuery(
      data: MediaQueryData.fromWindow(window), child: _MemoryWidget());

  @override
  ImageProvider get iconImageProvider => MemoryImage(base64Decode(iconData));

  @override
  String get name => '内存信息';

  @override
  void onTrigger() {}

  @override
  void contentWidgetVisibilityChange(bool visibility) {}
}

class _MemoryWidget extends StatefulWidget {
  _MemoryWidget({Key key}) : super(key: key);

  @override
  _MemoryWidgetState createState() => _MemoryWidgetState();
}

class _MemoryWidgetState extends BackState<_MemoryWidget> {
  @override
  void initState() {
    super.initState();
    backCallback = () {
      FdbBroadcastManager.instance.broadcast("CLOSE_CLASS");
    };
  }

  @override
  Widget build(BuildContext context) {
    return Material(
      child: SafeArea(
        child: Scaffold(
          backgroundColor: Colors.white,
          appBar: MemoryAppBar(
            title: '内存信息',
            backOnTap: () {},
          ),
          body: CustomScrollView(
            slivers: <Widget>[
              SliverToBoxAdapter(child: MemoryInfoTitleWidget()),
              MemoryInfoContentWidget()
            ],
          ),
        ),
      ),
    );
  }
}
