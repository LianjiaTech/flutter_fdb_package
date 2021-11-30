import 'package:flutter/cupertino.dart';
import 'package:flutter_fdb_package/flutter_fdb_package.dart';

abstract class BackState<T extends StatefulWidget> extends State<T>
    with LastContext {
  WillPopCallback _willPopCallback;
  VoidCallback backCallback;

  @override
  void initState() {
    super.initState();
    lastContextFromRoot();

    _willPopCallback = () async {
      FdbBroadcastManager.instance.broadcast("CLOSE");
      if (backCallback != null) {
        backCallback();
      }
      return false;
    };
    ModalRoute.of(last)?.removeScopedWillPopCallback(_willPopCallback);
    ModalRoute.of(last)?.addScopedWillPopCallback(_willPopCallback);
  }

  @override
  void dispose() {
    super.dispose();
    ModalRoute.of(last)?.addScopedWillPopCallback(_willPopCallback);
  }
}
