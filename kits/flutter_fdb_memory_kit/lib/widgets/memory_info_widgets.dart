import 'dart:io';
import 'dart:ui';

import 'package:flutter/material.dart';

class MemoryInstanceTitle extends StatelessWidget {
  final String title;

  final Widget accessoryWidget;

  final EdgeInsetsGeometry padding;

  const MemoryInstanceTitle(
      {Key key,
      @required this.title,
      this.accessoryWidget,
      this.padding =
          const EdgeInsets.only(top: 16, bottom: 12, left: 0, right: 0)})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return _rowWidget(context);
  }

  Widget _rowWidget(context) {
    List<Widget> children = List<Widget>();
    children.add(Expanded(child: this._titleWidget()));

    Widget accessory = Container(
      height: 0,
      width: 0,
    );
    // 左侧的文本的行高是25，那么右侧的widget最大为25
    if (this.accessoryWidget != null) {
      accessory = Container(
        height: 25,
        alignment: Alignment.center,
        padding: EdgeInsets.only(left: 4),
        child: accessoryWidget,
      );
    }
    children.add(accessory);

    return Padding(
      padding: this.padding ??
          const EdgeInsets.only(
            top: 16,
            bottom: 16,
          ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: children,
      ),
    );
  }

  ///标题widget
  Widget _titleWidget() {
    Widget subWidget = Container(
      height: 0,
      width: 0,
    );
    var titleWidget = RichText(
      text: TextSpan(
          text: this.title ?? "",
          style: TextStyle(
              fontSize: 18,
              height: 25 / 18,
              fontWeight: FontWeight.w600,
              color: Color(0xFF222222)),
          children: <InlineSpan>[
            WidgetSpan(child: subWidget),
          ]),
    );

    List<Widget> colChildren = List<Widget>();
    colChildren.add(titleWidget);
    Column column = Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: colChildren,
    );

    return column;
  }
}

class MemoryInstanceFieldWidget extends StatelessWidget {
  final List<InfoModal> children;

  MemoryInstanceFieldWidget({this.children});

  @override
  Widget build(BuildContext context) {
    return _buildRowWidget(context);
  }

  //不对齐的时候 使用column+row实现
  Widget _buildRowWidget(BuildContext context) {
    int index = -1;
    double screen;
    return LayoutBuilder(
      builder: (context, con) {
        screen = con.maxWidth;
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: children.map((data) {
            index++;
            return Padding(
              padding: EdgeInsets.only(top: (index == 0) ? 0 : 4),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    constraints: BoxConstraints(maxWidth: screen / 2),
                    child: _finalKeyWidget(data),
                  ),
                  Flexible(
                    child: _finalValueWidget(data),
                  )
                ],
              ),
            );
          }).toList(),
        );
      },
    );
  }

  Widget _finalKeyWidget(InfoModal data) {
    Widget keyWidget = _keyOrValueTitleText(true, data.keyPart + "：");
    return keyWidget;
  }

  Widget _finalValueWidget(InfoModal data, {double itemSpacing}) {
    Widget valueWidget;

    if (data.valuePart is String) {
      valueWidget = _keyOrValueTitleText(false, data.valuePart);
    }
    return Padding(
      padding: EdgeInsets.only(left: 4),
      child: valueWidget,
    );
  }

  Widget _keyOrValueTitleText(bool isKey, String text) {
    bool isSingle = false;

    String show;
    if (text.isEmpty) {
      if (isKey) {
        show = '--：';
      } else {
        show = '--';
      }
    } else {
      show = text;
    }

    RegExp regExp = RegExp("[\u4e00-\u9fa5]");
    bool noContainsChinese = !regExp.hasMatch(show);
    double height;
    if (noContainsChinese) {
      if (Platform.isAndroid) {
        height = 1.4;
      } else {
        height = 1.3;
      }
    }

    Widget keyOrValue = Text(
      show,
      overflow: isSingle ? TextOverflow.ellipsis : TextOverflow.clip,
      maxLines: isSingle ? 1 : null,
      style: TextStyle(
        color: isKey ? Color(0xFF999999) : Color(0xFF222222),
        fontWeight: FontWeight.normal,
        height: height,
        fontSize: 14,
      ),
    );
    return keyOrValue;
  }
}

class InfoModal {
  String keyPart;

  String valuePart;

  InfoModal({
    this.keyPart,
    this.valuePart,
  });
}

class OutlineButtonWidget extends StatelessWidget {
  final String title; //按钮显示文案,默认'确认'
  final VoidCallback onTap; //点就回调

  OutlineButtonWidget({
    this.title = '确认',
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        if (this.onTap != null) {
          this.onTap();
        }
      },
      child: Container(
          constraints: BoxConstraints(
            minWidth: 84,
            maxWidth: double.infinity,
          ),
          height: 32,
          padding: EdgeInsets.only(
            left: 8,
            right: 8,
          ),
          decoration: BoxDecoration(
            color: Colors.white,
            border: Border.all(color: Color(0xffF0F0F0), width: 1.0),
            borderRadius: BorderRadius.all(
              Radius.circular(4),
            ),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: <Widget>[
              Flexible(
                child: Text(
                  this.title ?? "",
                  textAlign: TextAlign.center,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                      fontSize: 14,
                      color: Color(0xFF222222),
                      fontWeight: FontWeight.w600),
                ),
              ),
            ],
          )),
    );
  }
}
