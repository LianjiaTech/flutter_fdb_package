import 'package:flutter/material.dart';
import 'package:flutter_fdb_package/kit/fdb_kit.dart';

class IconCache {
  static Map<String, Widget> _icons = Map();

  static Widget icon({
    FDBKit kitInfo,
  }) {
    if (!_icons.containsKey(kitInfo.name) && kitInfo.iconImageProvider != null) {
      final i = Image(image: kitInfo.iconImageProvider);
      _icons.putIfAbsent(kitInfo.name, () => i);
    } else if (!_icons.containsKey(kitInfo.name)) {
      return Container();
    }

    return _icons[kitInfo.name];
  }
}
