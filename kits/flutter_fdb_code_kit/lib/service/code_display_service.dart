import 'package:vm_service/vm_service.dart';
import 'package:flutter_fdb_package/flutter_fdb_package.dart';

class CodeFindService extends VmServiceWrapper {
  static CodeFindService get instance => _getInstance();

  static CodeFindService _instance;

  CodeFindService._() : super();

  static _getInstance() {
    if (_instance == null) {
      _instance = CodeFindService._();
    }
    return _instance;
  }

  Future<ClassList> getClassList() async {
    if (service == null) {
      connectVMService();
    }
    return service.getClassList(isolateId);
  }

  Future<ScriptList> getScriptList() async {
    if (service == null) {
      connectVMService();
    }
    return service.getScripts(isolateId);
  }

  Future<String> findIdByName(String className) async {
    String classId = '';
    final classList = await getClassList();
    classList.classes.forEach((c) {
      if (c != null && c.name != null && c.name == className) {
        classId = c.id;
        return;
      }
    });
    return classId;
  }

  Future<String> findScriptIdByFileName(String fileName) async {
    ScriptList scriptList = await getScriptList();
    String scriptId;
    scriptList.scripts.forEach((script) {
      if (script.uri.contains(fileName)) {
        scriptId = script.id;
        return;
      }
    });
    return scriptId;
  }

  Future<String> findSourceByClassId(String classId) async {
    SourceLocation location = await findLocationId(classId);
    Script script = await getObject(location.script.id);
    return script.source;
  }
  Future<String> findLocationUriById(String classId) async {
    SourceLocation location = await findLocationId(classId);
    return location.script.uri;
  }

  Future<SourceLocation> findLocationId(String classId) async {
    Class cls = await getObject(classId) as Class;
    return cls.location;
  }
}
