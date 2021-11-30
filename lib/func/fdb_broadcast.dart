import 'package:fbroadcast/fbroadcast.dart';

class FdbBroadcastManager {
  static FdbBroadcastManager _instance;

  static FdbBroadcastManager get instance {
    if (_instance == null) {
      _instance = FdbBroadcastManager._();
    }
    return _instance;
  }

  FdbBroadcastManager._();

  FBroadcast register(
    String key,
    ResultCallback receiver, {
    Object context,
    Map<String, ResultCallback> more,
  }) {
    return FBroadcast.instance().register(key, receiver);
  }

  void broadcast(String key,
      {dynamic value, ValueCallback callback, bool persistence = false}) {
    FBroadcast.instance().broadcast(key);
  }
}
