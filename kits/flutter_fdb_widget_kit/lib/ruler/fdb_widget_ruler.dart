import 'dart:convert';
import 'dart:ui';

import 'package:flutter/cupertino.dart';
import 'package:flutter_fdb_package/flutter_fdb_package.dart';

import '../common/icon.dart';
import 'fdb_ruler_pointer.dart';

class FdbRulerKit implements FDBKit {
  FdbRulerPointer fdbInspectorPointer;

  @override
  Widget buildWidget(BuildContext context) {
    if (fdbInspectorPointer == null) {
      fdbInspectorPointer = FdbRulerPointer();
    }
    return fdbInspectorPointer;
  }

  @override
  ImageProvider get iconImageProvider => ResizeImage.resizeIfNeeded(
      120,
      120,
      MemoryImage(
        base64Decode(rulerIcon),
      ));

  @override
  String get name => "UI标尺";

  @override
  void onTrigger() {
    print('ded');
  }

  @override
  void contentWidgetVisibilityChange(bool visibility) {
    if (!visibility) {
      fdbInspectorPointer.stopTask();
    }
  }
}
