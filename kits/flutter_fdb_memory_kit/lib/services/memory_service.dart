import 'package:vm_service/vm_service.dart';
import 'package:flutter_fdb_package/flutter_fdb_package.dart';

import '../bean/memory_info_bean.dart';
import '../func/memory_calculate_util.dart';

class MemoryService extends VmServiceWrapper {
  static MemoryService get instance => _getInstance();

  static MemoryService _instance;

  MemoryService._();

  static MemoryService _getInstance() {
    if (_instance == null) {
      _instance = MemoryService._();
    }
    return _instance;
  }

  Future<MemoryUsage> getMemoryUsage() async {
    if (service == null) {
      await connectVMService();
    }
    return service.getMemoryUsage(isolateId);
  }

  Future<InstanceSet> getInstances(String objectId, int limit) async {
    if (service == null) {
      await connectVMService();
    }
    return service.getInstances(isolateId, objectId, limit);
  }

  Future<MemoryUsageWrapperModel> getMemoryUsageWrapper() async {
    MemoryUsage memoryUsage = await getMemoryUsage();
    MemoryUsageWrapperModel memoryUsageWrapperModel =
        MemoryUsageWrapperModel.fromUsage(memoryUsage: memoryUsage);
    return memoryUsageWrapperModel;
  }

  Future<MemoryPackageModel> getAppLibraries() async {
    List<LibraryRef> list = await getLibraries();
    List<ClassHeapStats> classHeapStatsList = await getClassHeapStats();
    MemoryPackageModel model = MemoryPackageModel();
    Map<String, List<MemoryLibraryModel>> map = {};

    if (list != null) {
      list.forEach((data) async {
        MemoryLibraryModel model = MemoryLibraryModel();
        model.libraryRef = data;
        model.classList = [];
        Uri uri = Uri.parse(data.uri);
        String key = uri.scheme ?? "";
        if (uri.toString().contains("/")) {
          key = uri.toString().substring(0, uri.toString().indexOf("/"));
        }
        List<ClassRef> classRefs = await getClasses(data.id);
        if (classRefs != null) {
          model.classList = classRefs.map((data) {
            ClassHeapStats classHeapStats =
                classHeapStatsList.firstWhere((clz) {
              return clz.classRef.hashCode == data.hashCode;
            }, orElse: () {
              return null;
            });
            return MemoryClassModel()
              ..classRef = data
              ..accumulatedSize = classHeapStats == null
                  ? null
                  : MemoryCalculateUtil.byteToSizeString(
                      classHeapStats.accumulatedSize);
          }).toList();
          model.classList.removeWhere((clz) {
            return clz.accumulatedSize == null;
          });
        }

        if (model.classList.isNotEmpty) {
          if (map.containsKey(key)) {
            map[key].add(model);
          } else {
            map[key] = List()..add(model);
          }
        }
      });
    }
    map.removeWhere((key, value) {
      return value.isEmpty;
    });
    model.libraryMap = map;
    return model;
  }

  Future<List<ClassRef>> getClasses(String libId) async {
    Library library = await getObject(libId);
    return library.classes ?? [];
  }

  Future<List<MemoryInstanceModel>> getClassInstances(String clzId) async {
    List<MemoryInstanceModel> instances = [];
    InstanceSet instanceSet = await getInstances(clzId, 300);
    List<ObjRef> objRefList = instanceSet.instances;

    objRefList.forEach((ref) async {
      if (ref != null) {
        MemoryInstanceModel memoryInstanceModel = new MemoryInstanceModel();
        memoryInstanceModel.instanceRef = ref;
        instances.add(memoryInstanceModel);

        List<MemoryFieldsModel> fields = [];
        memoryInstanceModel.fields = fields;

        Instance instance = await getObject(ref.id);

        instance.fields.forEach((field) async {
          MemoryFieldsModel memoryFieldsModel = MemoryFieldsModel();
          memoryFieldsModel.field = field.decl;
          memoryFieldsModel.name = field.decl.name;
          if (field.value is InstanceRef) {
            Instance instance = await getObject(field.value.id);
            if (memoryFieldsModel.name == "_location") {
              String file;
              String line;
              instance.fields.forEach((data) {
                if (data.decl.name == "file") {
                  file = data?.value?.valueAsString ?? "";
                }
                if (data.decl.name == "line") {
                  line = data?.value?.valueAsString ?? "";
                }
              });
              memoryFieldsModel.value = file + "-" + line;
            } else {
              memoryFieldsModel.value = instance.valueAsString;
              if (memoryFieldsModel.value == null) {
                memoryFieldsModel.value = instance?.classRef?.name ?? "null";
              }
            }
          } else if (field.value is Sentinel) {
            memoryFieldsModel.value = field.value;
          }
          fields.add(memoryFieldsModel);
        });
      }
    });
    return instances;
  }
}
