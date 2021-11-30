import 'package:flutter/material.dart';
import 'package:flutter_fdb_package/flutter_fdb_package.dart';

import '../bean/memory_info_bean.dart';
import '../info/memory_info_detail_over.dart';
import '../services/memory_service.dart';

class MemoryInfoContentWidget extends StatefulWidget {
  @override
  _MemoryInfoContentWidgetState createState() =>
      _MemoryInfoContentWidgetState();
}

class _MemoryInfoContentWidgetState extends State<MemoryInfoContentWidget> {
  Future<MemoryPackageModel> _packageModelFuture;

  @override
  void initState() {
    super.initState();
    _packageModelFuture = MemoryService.instance.getAppLibraries();
  }

  @override
  Widget build(BuildContext context) {
    return FdbFutureWidget<MemoryPackageModel>(
      future: _packageModelFuture,
      isSliver: true,
      widgetBuilder: (context, data) {
        List<String> list = data.libraryMap?.keys?.toList() ?? [];
        if (list.isEmpty) {
          return SliverFillRemaining(
            child: Center(
              child: IconButton(
                onPressed: () {
                  _packageModelFuture =
                      MemoryService.instance.getAppLibraries();
                  setState(() {});
                },
                iconSize: 40,
                icon: Icon(Icons.refresh),
              ),
            ),
          );
        }
        return SliverList(
          delegate: SliverChildBuilderDelegate((context, index) {
            return MemoryInfoGroupItemWidget(
              group: list[index],
              libList: data.libraryMap[list[index]],
            );
          }, childCount: list.length),
        );
      },
    );
  }
}

class MemoryInfoGroupItemWidget extends StatefulWidget {
  final String group;
  final List<MemoryLibraryModel> libList;

  MemoryInfoGroupItemWidget({this.group, this.libList});

  @override
  _MemoryInfoGroupItemWidgetState createState() =>
      _MemoryInfoGroupItemWidgetState();
}

class _MemoryInfoGroupItemWidgetState extends State<MemoryInfoGroupItemWidget>
    with LastContext {
  OverlayEntry _overlayEntry;
  bool _isShow;
  ValueNotifier<MemoryClassModel> _valueNotifier;

  @override
  void initState() {
    super.initState();
    lastContextFromRoot();
    _isShow = false;

    FdbBroadcastManager.instance.register("CLOSE_CLASS", (value, _) {
      print('sssss');
      _overlayEntry?.remove();
      _isShow = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return ExpansionTile(
        title: Text(widget.group),
        backgroundColor: Colors.white,
        initiallyExpanded: false,
        children: _buildLibList());
  }

  List<Widget> _buildLibList() {
    return widget.libList.map((data) {
      return ExpansionTile(
          title: Text("    " + ((data.libraryRef.uri) ?? "--")),
          backgroundColor: Colors.white,
          initiallyExpanded: false,
          onExpansionChanged: (s) {},
          children: data.classList.map((data) {
            return GestureDetector(
              onTap: () {
                _enterDetailPage(data);
              },
              child: ListTile(
                title: Text("    " + "    " + data.classRef.name),
                trailing: data.accumulatedSize == null
                    ? Text('')
                    : Text(data.accumulatedSize),
              ),
            );
          }).toList());
    }).toList();
  }

  void _enterDetailPage(MemoryClassModel model) {
    if (_valueNotifier == null) {
      _valueNotifier = new ValueNotifier(model);
    }
    if (_overlayEntry == null) {
      _overlayEntry = OverlayEntry(builder: (context) {
        return GestureDetector(
          onTap: () {
            _overlayEntry.remove();
            _isShow = false;
          },
          child: MemoryClassDetail(
            classModel: _valueNotifier,
          ),
        );
      });
    }

    if (_isShow) {
      _valueNotifier.value = model;
    } else {
      Overlay.of(context).insert(_overlayEntry);
    }
    _isShow = true;
  }
}
