import 'package:flutter/widgets.dart';

typedef ContentWidgetVisibilityChange = void Function(bool);
typedef StreamFilter = bool Function(dynamic);

/// FDB工具的抽象类
abstract class FDBKit {
  /// 工具在面板上的名字
  String get name;

  /// 工具点击的回调
  void onTrigger();

  /// 工具点击之后 在程序上显示的widget 比如是检测类型的、拖动类型的
  Widget buildWidget(BuildContext context);

  /// 工具在面板上展示的图片
  ImageProvider get iconImageProvider;

  /// 面板隐藏和展示的回调
  void contentWidgetVisibilityChange(bool visibility) {}
}

class CustomKit extends FDBKit{
  @override
  Widget buildWidget(BuildContext context) {
    return null;
  }

  @override
  ImageProvider get iconImageProvider => null;

  @override
  String get name => null;

  @override
  void onTrigger() {
  }

}
