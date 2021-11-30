import 'dart:convert';

import 'package:flutter/widgets.dart';
import 'package:flutter_fdb_package/flutter_fdb_package.dart';

import '../common/icon.dart';
import 'fdb_color_picker.dart';

class FdbColorPickKit extends FDBKit {
  @override
  Widget buildWidget(BuildContext context) {
    return ColorPickerWidget();
  }

  @override
  ImageProvider get iconImageProvider => ResizeImage.resizeIfNeeded(
      120,
      120,
      MemoryImage(
        base64Decode(colorIcon),
      ));

  @override
  String get name => '取色器';

  @override
  void onTrigger() {}

  @override
  void contentWidgetVisibilityChange(bool visibility) {
    super.contentWidgetVisibilityChange(visibility);
    if (!visibility) {
      FdbBroadcastManager.instance.broadcast(kColorClose);
    }
  }
}
