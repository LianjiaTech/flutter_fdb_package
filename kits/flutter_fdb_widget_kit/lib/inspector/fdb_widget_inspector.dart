import 'dart:convert';

import 'package:flutter/cupertino.dart';
import 'package:flutter_fdb_package/flutter_fdb_package.dart';
import '../common/icon.dart';
import 'fdb_widget_inspector_pointer.dart';

class FdbInspectorKit implements FDBKit {
  FdbInspectorPointer fdbInspectorPointer;

  @override
  Widget buildWidget(BuildContext context) {
    if (fdbInspectorPointer == null) {
      fdbInspectorPointer = FdbInspectorPointer();
    }
    return fdbInspectorPointer;
  }

  @override
  ImageProvider get iconImageProvider => ResizeImage.resizeIfNeeded(
      120, 120, MemoryImage(base64Decode(paintIcon)));

  @override
  String get name => "UI拾取";

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
