import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_fdb_package/flutter_fdb_package.dart';
import 'package:vm_service/vm_service.dart';
import '../service/code_display_service.dart';

import 'package:flutter_fdb_code_kit/bean/page_info_bean.dart';

class SearchCodeUtil with LastContext {
  List<SimilarityPathBean> _similarityList;

  List<SimilarityPathBean> get similarityList => _similarityList;

  SearchCodeUtil() {
    lastContextFromRoot();
    _findCurrentRouteWidget();
    _initSimilarityList();
  }

  dynamic _findCurrentRouteWidget() {
    List<OverlayEntry> list = Navigator.of(last)
        .overlay
        .toDiagnosticsNode()
        .getProperties()
        .firstWhere((data) {
      return data is DiagnosticsProperty<List<OverlayEntry>>;
    }).value;
    OverlayEntry entry = list.lastWhere((data) {
      return Navigator.of(last).overlay.debugIsVisible(data);
    });
    dynamic widget = entry.builder(last);
    dynamic page;
    try {
      page = widget?.route?.builder(last);
    } catch (e) {
      page = widget?.route?.pageRoute?.builder(last);
    }
    return page;
  }

  Future<PageInfoBean> getCurrentPage() async {
    PageInfoBean pageInfoBean = PageInfoBean();
    dynamic page = _findCurrentRouteWidget();

    if (page != null) {
      String id = await VmServiceWrapper().convertObj2Id(page);
      String classId = await VmServiceWrapper().getObject(id).then((data) {
        return data.classRef.id;
      });
      String locationPath =
          await CodeFindService.instance.findLocationUriById(classId);
      pageInfoBean.path = locationPath;
    }

    if (page != null) {
      String id = await CodeFindService.instance
          .findIdByName(page.runtimeType.toString());
      String code = await CodeFindService.instance.findSourceByClassId(id);
      pageInfoBean.code = code;
    }

    return pageInfoBean;
  }

  void _initSimilarityList() {
    _similarityList = [];
    CodeFindService.instance.getLibraries().then((data) {
      data.forEach((lib) {
        SimilarityPathBean similarityPathBean = SimilarityPathBean();
        similarityPathBean.path = lib.uri;
        similarityPathBean.libraryRef = lib;
        _similarityList.add(similarityPathBean);
      });
    });
  }

  List<SimilarityPathBean> searchKeyWord(String keyword) {
    if (_similarityList == null || _similarityList.isEmpty) {
      _initSimilarityList();
    }
    _similarityList.forEach((data) {
      data.compareKeyWordAndPath(keyword);
    });

    _similarityList.sort((a, b) {
      return b.similarity.compareTo(a.similarity);
    });
    return _similarityList;
  }

  Future<PageInfoBean> getTargetPage(LibraryRef lib) async {
    String id = await CodeFindService.instance.findScriptIdByFileName(lib.uri);
    Script script = await CodeFindService.instance.getObject(id);
    PageInfoBean pageInfoBean1 = PageInfoBean();
    pageInfoBean1.path = lib.uri;
    pageInfoBean1.code = script.source.toString();
    return pageInfoBean1;
  }
}
