import 'dart:developer';
import 'dart:isolate';
import 'package:vm_service/utils.dart';
import 'package:vm_service/vm_service.dart' as vm;
import 'package:vm_service/vm_service_io.dart';

int _key = 0;

String generateNewKey() {
  return "${++_key}";
}

Map<String, dynamic> _objCache = Map();

dynamic keyToObj(String key) {
  return _objCache[key];
}

class VmServiceWrapper {
  vm.VmService service;

  String _isolateId;

  String get isolateId {
    if (_isolateId != null) {
      return _isolateId;
    }
    _isolateId = Service.getIsolateID(Isolate.current);
    return _isolateId;
  }

  VmServiceWrapper() {
    connectVMService();
  }

  connectVMService() async {
    if (service != null) {
      return service;
    }
    ServiceProtocolInfo info = await Service.getInfo();
    String url = info.serverUri.toString();
    Uri uri = Uri.parse(url);
    Uri socketUri = convertToWebSocketUrl(serviceProtocolUrl: uri);
    service = await vmServiceConnectUri(socketUri.toString());
  }

  Future<List<vm.ClassHeapStats>> getClassHeapStats() async {
    if (service == null) {
      await connectVMService();
    }
    vm.AllocationProfile profile =
        await service.getAllocationProfile(isolateId);
    List<vm.ClassHeapStats> list = profile.members
        .where((element) =>
            element.bytesCurrent > 0 || element.instancesCurrent > 0)
        .toList();
    return list;
  }

  Future<vm.Obj> getObject(String objectId) async {
    if (service == null) {
      await connectVMService();
    }
    return service.getObject(isolateId, objectId);
  }

  Future<List<vm.LibraryRef>> getLibraries() async {
    if (service == null) {
      await connectVMService();
    }
    vm.Isolate isolate = await service.getIsolate(isolateId);
    List<vm.LibraryRef> listLib = isolate.libraries;
    return listLib;
  }

  Future<String> convertObj2Id(dynamic obj) async {
    if (service == null) {
      await connectVMService();
    }
    List<vm.LibraryRef> listLib = await getLibraries();

    String libId = "";

    for (int i = 0; i < listLib.length; i++) {
      if (listLib[i].uri.contains('service_wrapper.dart')) {
        libId = listLib[i].id;
        break;
      }
    }

    vm.InstanceRef keyRef =
        await service.invoke(isolateId, libId, "generateNewKey", []);

    String key = keyRef.valueAsString;
    _objCache[key] = obj;
    try {
      vm.InstanceRef valueRef =
          await service.invoke(isolateId, libId, "keyToObj", [keyRef.id]);
      return valueRef.id;
    } finally {
      _objCache.remove(key);
    }
  }
}
