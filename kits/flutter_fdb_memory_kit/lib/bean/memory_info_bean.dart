import 'package:vm_service/vm_service.dart' as vm;

import '../func/memory_calculate_util.dart';

class MemoryClassModel {
  vm.ClassRef classRef;
  String accumulatedSize;
}

class MemoryLibraryModel {
  vm.LibraryRef libraryRef;
  List<MemoryClassModel> classList;
}

class MemoryPackageModel {
  Map<String, List<MemoryLibraryModel>> libraryMap;
}

class MemoryInstanceModel {
  List<MemoryFieldsModel> fields;
  vm.InstanceRef instanceRef;
}

class MemoryFieldsModel {
  vm.FieldRef field;
  String name;
  String value;
}

class MemoryUsageWrapperModel {
  vm.MemoryUsage memoryUsage;

  MemoryUsageWrapperModel.fromUsage({this.memoryUsage});

  int get externalUsage => memoryUsage.externalUsage;

  int get heapCapacity => memoryUsage.heapCapacity;

  int get heapUsage => memoryUsage.heapUsage;

  String _allInfo;

  String get allInfo {
    if (_allInfo != null) {
      return _allInfo;
    }
    StringBuffer buffer = StringBuffer();
    buffer.writeln(
        "ExternalUsage:  ${MemoryCalculateUtil.byteToSizeString(memoryUsage.externalUsage)}");
    buffer.writeln(
        "HeapCapacity:  ${MemoryCalculateUtil.byteToSizeString(memoryUsage.heapCapacity)}");
    buffer.writeln(
        "HeapUsage:  ${MemoryCalculateUtil.byteToSizeString(memoryUsage.heapUsage)}");
    _allInfo = buffer.toString();
    return _allInfo;
  }
}
