import 'dart:convert';
import 'dart:ui';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_fdb_code_kit/widget/page_path_widget.dart';
import 'package:flutter_fdb_package/flutter_fdb_package.dart';
import 'package:syntax_highlighter/syntax_highlighter.dart';
import '../bean/page_info_bean.dart';

import '../common/icon.dart';
import '../func/search_code_util.dart';
import 'code_bar.dart';

class DisplayCodeKit implements FDBKit {
  ChangeNotifier changeNotifier;

  DisplayCodeKit() {
    changeNotifier = ChangeNotifier();
  }

  @override
  Widget buildWidget(BuildContext context) => MediaQuery(
      data: MediaQueryData.fromWindow(window),
      child: _DisPlayCodeWidget(
        changeNotifier: changeNotifier,
      ));

  @override
  ImageProvider<Object> get iconImageProvider =>
      MemoryImage(base64Decode(iconData));

  @override
  String get name => "页面代码";

  @override
  void onTrigger() {}

  @override
  void contentWidgetVisibilityChange(bool visibility) {
    changeNotifier.notifyListeners();
  }
}

class _DisPlayCodeWidget extends StatefulWidget {
  final ChangeNotifier changeNotifier;

  _DisPlayCodeWidget({this.changeNotifier});

  @override
  __DisPlayCodeWidgetState createState() => __DisPlayCodeWidgetState();
}

class __DisPlayCodeWidgetState extends State<_DisPlayCodeWidget>
    with WidgetsBindingObserver {
  SearchCodeUtil pageInfoHelper;
  String code;
  String filePath = "";
  bool showCodeList;
  bool isSearching;
  TextEditingController textEditingController;
  SimilarityPathBean _selectedBean;

  SyntaxHighlighterStyle _style;
  WillPopCallback _willPopCallback;
  GlobalKey _globalKey;
  OverlayEntry _overlayEntry;
  ValueNotifier<List<SimilarityPathBean>> _valueNotifier;
  bool _showEntry;
  Offset _offset;

  @override
  void initState() {
    _globalKey = GlobalKey();
    _showEntry = false;
    pageInfoHelper = SearchCodeUtil();

    widget.changeNotifier.addListener((){
      _overlayEntry?.remove();
      _showEntry = false;
    });
    showCodeList = false;
    isSearching = false;
    _style = Theme.of(context).brightness == Brightness.dark
        ? SyntaxHighlighterStyle.darkThemeStyle()
        : SyntaxHighlighterStyle.lightThemeStyle();

    _willPopCallback = () async {
      FdbBroadcastManager.instance.broadcast("CLOSE");
      return false;
    };
    ModalRoute.of(pageInfoHelper.last)
        ?.removeScopedWillPopCallback(_willPopCallback);
    ModalRoute.of(pageInfoHelper.last)
        ?.addScopedWillPopCallback(_willPopCallback);
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        _overlayEntry.remove();
        _showEntry = false;
      },
      child: Material(
        child: Scaffold(
          appBar: CodeAppbar(),
          body: FdbFutureWidget<PageInfoBean>(
            widgetBuilder: (context, bean) {
              textEditingController = TextEditingController(text: bean.path)
                ..addListener(() {
                  _searchPath();
                });
              return Column(
                children: <Widget>[
                  _buildSearchWidget(bean.path),
                  Expanded(
                    child: SingleChildScrollView(
                      child: _buildCodeWidget(bean.code),
                    ),
                  ),
                ],
              );
            },
            future: _createFuture(_selectedBean),
          ),
        ),
      ),
    );
  }

  Widget _buildCodeWidget(String code) {
    return RichText(
        text: TextSpan(
      style: const TextStyle(fontFamily: 'monospace', fontSize: 15.0),
      children: <TextSpan>[
        DartSyntaxHighlighter(_style).format(code),
      ],
    ));
  }

  void _searchPath() {
    if (textEditingController.text.isEmpty) {
      _overlayEntry?.remove();
    }
    List<SimilarityPathBean> keyList =
        pageInfoHelper.searchKeyWord(textEditingController.text).sublist(0, 4);

    if (_offset == null) {
      RenderBox renderBox = _globalKey.currentContext.findRenderObject();
      _offset = renderBox.localToGlobal(Offset.zero);
    }
    if (_valueNotifier == null) {
      _valueNotifier = ValueNotifier(List()..addAll(keyList));
    }
    if (_overlayEntry == null) {
      _overlayEntry = OverlayEntry(builder: (context) {
        return Positioned(
          top: _offset.dy + 25,
          child: PagePathColumnWidget(
            key: Key(DateTime.now().toIso8601String()),
            similarityList: _valueNotifier,
            itemOnTap: (bean) {
              print(bean);
              _overlayEntry.remove();
              _showEntry = false;
              if (bean.path != textEditingController.text) {
                _selectedBean = bean;
                setState(() {});
              }
            },
          ),
        );
      });
    }

    if (_showEntry) {
      _valueNotifier.value = List()..addAll(keyList);
    } else {
      Overlay.of(context).insert(_overlayEntry);
      _showEntry = true;
    }
  }

  Widget _buildSearchWidget(String path) {
    return CupertinoTextField(
      key: _globalKey,
      controller: textEditingController,
      style: TextStyle(color: Colors.teal, fontSize: 14),
      maxLines: 5,
      minLines: 1,
      placeholder: "请输入文件路径",
      clearButtonMode: OverlayVisibilityMode.editing,
      textInputAction: TextInputAction.done,
    );
  }

  @override
  void dispose() {
    ModalRoute.of(pageInfoHelper.lastContextFromRoot())
        ?.removeScopedWillPopCallback(_willPopCallback);
    super.dispose();
  }

  Future<PageInfoBean> _createFuture(SimilarityPathBean bean) {
    if (bean == null) {
      return pageInfoHelper.getCurrentPage();
    }
    return pageInfoHelper.getTargetPage(bean.libraryRef);
  }
}
