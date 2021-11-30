import 'dart:math';

import 'package:vm_service/vm_service.dart';

/// code : "data"
/// path : "location"
class PageInfoBean {
  String code;
  String path;

  PageInfoBean() {
    path = "暂无数据";
    code = '暂无数据';
  }

  static PageInfoBean fromMap(Map<String, dynamic> map) {
    if (map == null) return null;
    PageInfoBean pageInfoBeanBean = PageInfoBean();
    pageInfoBeanBean.code = map['code'];
    pageInfoBeanBean.path = map['path'];
    return pageInfoBeanBean;
  }

  Map toJson() => {
        "code": code,
        "path": path,
      };

  @override
  String toString() {
    return 'PageInfoBean1{path: $path}';
  }
}

/// path : "data"
/// similarity : 0.3
class SimilarityPathBean {
  String path;
  double similarity;
  LibraryRef libraryRef;

  static SimilarityPathBean fromMap(Map<String, dynamic> map) {
    if (map == null) return null;
    SimilarityPathBean dddBean = SimilarityPathBean();
    dddBean.path = map['path'];
    dddBean.similarity = map['similarity'];
    return dddBean;
  }

  Map toJson() => {
        "path": path,
        "similarity": similarity,
      };

  @override
  String toString() {
    return 'SimilarityPathBean{path: $path, similarity: $similarity}';
  }

  void compareKeyWordAndPath(String str2) {
    //计算两个字符串的长度。
    int len1 = path.length;
    int len2 = str2.length;
    //建立上面说的数组，比字符长度大一个空间
    List<List<int>> dif = List.generate(len1 + 1, (index) {
      return List(len2 + 1);
    });

    //赋初值，步骤B。
    for (int a = 0; a <= len1; a++) {
      dif[a][0] = a;
    }
    for (int a = 0; a <= len2; a++) {
      dif[0][a] = a;
    }

    int temp;
    for (int i = 1; i <= len1; i++) {
      for (int j = 1; j <= len2; j++) {
        if (path[i - 1] == str2[j - 1]) {
          temp = 0;
        } else {
          temp = 1;
        }
        //取三个值中最小的
        dif[i][j] =
            min(dif[i - 1][j - 1] + temp, dif[i][j - 1] + 1, dif[i - 1][j] + 1);
      }
    }
    //计算相似度
    double similarity = 1 - dif[len1][len2] / max(path.length, str2.length);
    this.similarity = similarity;
  }

  //得到最小值

  int min(int a, int b, int c) {
    int min = double.maxFinite.toInt();
    min = ((a < b) ? a : b) < c ? ((a < b) ? a : b) : c;
    return min;
  }
}
