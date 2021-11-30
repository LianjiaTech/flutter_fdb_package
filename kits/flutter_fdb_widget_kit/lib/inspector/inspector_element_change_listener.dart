import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import '../common/UiUtils.dart';
import '../common/fdb_overlay.dart';
import 'inspector_bottom_edit_page.dart';

const Color _kHighlightedRenderObjectFillColor =
    Color.fromARGB(50, 128, 128, 255);
const String _kFileName = 'UiUtils.dart';
const Color _kTooltipBackgroundColor = Color.fromARGB(230, 60, 60, 60);
const Color _kTooltipBackgroundColor1 = Color.fromARGB(100, 60, 60, 60);
const double _kTooltipPadding = 5.0;
const TextStyle _messageStyle = TextStyle(
  color: Color(0xFFFFFFFF),
  fontSize: 15.0,
  height: 1.2,
);

abstract class InspectorElementChangeListener {
  void inspectorElementChangeListener(Element element, bool isUp);
}

const String kOverlayBackgroundType = 'background_type';
const String kOverlayInfoType = "info_type";

class InspectorElementChange extends InspectorElementChangeListener {
  BuildContext context;
  Element _element;
  ValueNotifier<Rect> _locationNotifier;
  ValueNotifier<Element> _infoNotifier;

  _InfoPanelWidget _infoPanelWidget;
  FdbOverlayBuilder _fdbOverlayBuilder;

  InspectorElementChange(this.context) {
    _locationNotifier = ValueNotifier(null);
  }

  String preFile;
  String preLine;
  double _showY;
  double _showX;

  @override
  void inspectorElementChangeListener(Element element, bool isUp) {
    showOverlayMaskShade(element);
    showOverlayInfo(element);
  }

  void showOverlayMaskShade(Element element) {
    if (element == null || getRectByElement(element) == null) {
      return;
    }
    Size size = element.size;
    Rect rect = getRectByElement(element);

    Widget background = IgnorePointer(
      ignoring: true,
      child: Container(
        width: size.width,
        height: size.height,
        color: _kHighlightedRenderObjectFillColor,
      ),
    );

    FdbOverlayBuilder builder =
        FdbOverlayBuilder().dx(rect.left).dy(rect.top).widget(background);
    FdbOverlay.getInstance().putBuilder(builder, kOverlayBackgroundType).show(
          context,
        );
  }

  void showOverlayInfo(Element element) {
    if (element == null || getRectByElement(element) == null) {
      return;
    }

    Size size = element.size;
    Rect rect = getRectByElement(element);

    double dx = rect.left;
    double dy = rect.top + size.height + 3;

    Rect locationRect = Rect.fromLTRB(_showX ?? dx, _showY ?? dy + 4, 0, 0);

    if (_fdbOverlayBuilder == null) {
      _infoNotifier = new ValueNotifier(_element);
      _locationNotifier.value = locationRect;
      _infoPanelWidget = _InfoPanelWidget(
        valueNotifier: _infoNotifier,
        submitCallback: inspectorElementChangeListener,
      );
      _fdbOverlayBuilder = FdbOverlayBuilder()
          .custom(true)
          .needWelt(false)
          .needFollow(true)
          .locationNotifier(_locationNotifier)
          .dy(_showY ?? dy + 4)
          .dx(_showX ?? dx)
          .dragCallback((offset) {
        _showX = offset.dx;
        _showY = offset.dy;
      }).widget(Material(
        type: MaterialType.transparency,
        child: _infoPanelWidget,
      ));
      FdbOverlay.getInstance()
          .putBuilder(_fdbOverlayBuilder, kOverlayInfoType)
          .show(
            context,
          );
    } else {
      _infoNotifier.value = element;
      _locationNotifier.value = locationRect;
    }
  }

  String getWidgetMessage(Element element) {
    String id = WidgetInspectorService.instance
        .toId(element.widget.toDiagnosticsNode(), 'selection');

    String widgetJson;
    try {
      widgetJson = WidgetInspectorService.instance
          .getSelectedSummaryWidget(id, "selection");
    } catch (e) {
      widgetJson = "{}";
    }
    Map<String, dynamic> json = jsonDecode(widgetJson);
    String description = json['description'] ?? "";
    String createFile = json['creationLocation']['file'] ?? "";
    String createLine = json['creationLocation']['line'].toString() ?? "";
    if (createFile.contains('lib')) {
      createFile = createFile.substring(createFile.indexOf('lib'));
    }

    String fileName;
    String fileLine;

    if (createFile.contains(_kFileName)) {
      fileName = preFile;
      fileLine = preLine;
    } else {
      fileName = createFile;
      fileLine = createLine;
      preFile = fileName;
      preLine = fileLine;
    }

    String message = '选中的元素：$description' +
        '\n' +
        '所在文件：$fileName' +
        '\n' +
        '文件行数：$fileLine';
    return message;
  }
}

extension ElementExt on Element {
  bool isImageOrText() {
    return this.isText() || this.isImage();
  }

  bool isText() {
    return this.widget is Text || this.widget is RichText;
  }

  bool isImage() {
    return this.widget is RawImage || this.widget is Image;
  }
}

class _InfoPanelWidget extends StatefulWidget {
  final ValueNotifier<Element> valueNotifier;
  final Function(Element, bool) submitCallback;

  _InfoPanelWidget({this.valueNotifier, this.submitCallback});

  @override
  __InfoPanelWidgetState createState() => __InfoPanelWidgetState();
}

class __InfoPanelWidgetState extends State<_InfoPanelWidget> {
  String preFile;
  String preLine;
  Element element;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    element = widget.valueNotifier.value;
    widget.valueNotifier.addListener(() {
      if (mounted)
        setState(() {
          element = widget.valueNotifier.value;
        });
    });
  }

  @override
  Widget build(BuildContext context) {
    return Material(
      key: Key(DateTime.now().toIso8601String()),
      type: MaterialType.transparency,
      child: Container(
        width: 250,
        padding: EdgeInsets.all(_kTooltipPadding),
        decoration: BoxDecoration(
          color: _kTooltipBackgroundColor.withOpacity(0.7),
          borderRadius: BorderRadius.all(
            Radius.circular(5),
          ),
          border: Border.all(color: Colors.transparent, width: 1),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Text(
              getWidgetMessage(element),
              style: TextStyle(color: Colors.white),
            ),
            Visibility(
              visible: element?.isText() ?? false,
              child: Padding(
                padding: const EdgeInsets.only(top: 10),
                child: GestureDetector(
                  onTap: () {
                    Future.delayed(Duration(milliseconds: 100)).then((data) {
                      showBottomModify(element);
                    });
                  },
                  child: Container(
                    decoration: BoxDecoration(
                      color: _kTooltipBackgroundColor1,
                      borderRadius: BorderRadius.all(
                        Radius.circular(3),
                      ),
                      border: Border.all(color: Colors.transparent, width: 1),
                    ),
                    width: 83,
                    height: 32,
                    padding: EdgeInsets.all(5),
                    child: Text(
                      '编辑文本',
                      style: _messageStyle,
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void executeUpdate(Element element, File file) {
    FileImage(file)
        .resolve(createLocalImageConfiguration(context, size: element.size))
        .addListener(_getListener());
  }

  ImageStreamListener _getListener([ImageLoadingBuilder loadingBuilder]) {
    return ImageStreamListener(
      _handleImageFrame,
    );
  }

  void _handleImageFrame(ImageInfo imageInfo, bool synchronousCall) {
    element.update(RawImage(
      image: imageInfo.image,
      width: element.size.width,
      height: element.size.height,
    ));
    element.markNeedsBuild();
    WidgetInspectorService.instance.selection.clear();
  }

  void showBottomModify(Element element) {
    Navigator.of(element)
        .push(PageRouteBuilder<String>(
            opaque: false,
            pageBuilder: (context, animation, second) {
              return BottomEditPage(
                preContent: getTextInfo(element),
              );
            }))
        .then((data) {
      if (data != null && data.isNotEmpty) {
        executeSubmit(element, data);
      }
    });
  }

  void executeSubmit(Element element, String text) {
    Widget old = element.widget;
    RichText rich = generateRichText(text, old);
    element.update(rich);
    element.markNeedsBuild();
    WidgetInspectorService.instance.selection.clear();

    Future.delayed((Duration(milliseconds: 100))).then((data) {
      print(getRectByElement(element));
      widget.submitCallback(element, false);
    });
  }

  String getWidgetMessage(Element element) {
    String id = WidgetInspectorService.instance
        .toId(element?.widget?.toDiagnosticsNode(), 'selection');

    String widgetJson;
    try {
      widgetJson = WidgetInspectorService.instance
              .getSelectedSummaryWidget(id, "selection") ??
          "{}";
    } catch (e) {
      widgetJson = "{}";
    }
    Map<String, dynamic> json = jsonDecode(widgetJson) ?? {};
    String description = json['description'] ?? "";
    String createFile = (json['creationLocation'] ?? {})['file'] ?? "";
    String createLine =
        (json['creationLocation'] ?? {})['line'].toString() ?? "";
    if (createFile.contains('lib')) {
      createFile = createFile.substring(createFile.indexOf('lib'));
    }

    String fileName;
    String fileLine;

    if (createFile.contains(_kFileName)) {
      fileName = preFile;
      fileLine = preLine;
    } else {
      fileName = createFile;
      fileLine = createLine;
      preFile = fileName;
      preLine = fileLine;
    }

    String message = '选中的元素：$description' +
        '\n' +
        '所在文件：$fileName' +
        '\n' +
        '文件行数：$fileLine';
    return message;
  }
}
