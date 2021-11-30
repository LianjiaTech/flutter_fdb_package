import 'package:flutter_fdb_package/kit/fdb_kit.dart';

class FDBKitsManager {
  static FDBKitsManager _instance;

  Map<String, FDBKit> get fdbKitsMap => _fdbKitsMap;

  Map<String, FDBKit> _fdbKitsMap;

  static FDBKitsManager get instance {
    if (_instance == null) {
      _instance = FDBKitsManager._();
    }
    return _instance;
  }

  FDBKitsManager._() {
    if (_fdbKitsMap == null) {
      _fdbKitsMap = {};
    }
  }

  void register(FDBKit fdbKit) {
    if (fdbKit.name.isEmpty) {
      return;
    }
    _fdbKitsMap[fdbKit.name] = fdbKit;
  }
}
