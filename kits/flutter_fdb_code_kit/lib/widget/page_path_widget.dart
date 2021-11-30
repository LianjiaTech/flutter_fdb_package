import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter_fdb_code_kit/bean/page_info_bean.dart';

class PagePathItemWidget extends StatelessWidget {
  final SimilarityPathBean bean;
  final Function(SimilarityPathBean bean) itemOnTap;

  PagePathItemWidget({this.bean, this.itemOnTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        itemOnTap(bean);
      },
      child: Container(
        padding: EdgeInsets.only(top: 10, bottom: 10, left: 20, right: 20),
        child: Container(
          constraints: BoxConstraints(
              maxWidth:
                  (window.physicalSize / window.devicePixelRatio).width * 0.8),
          child: Text(
            bean.path,
            maxLines: 1,
          ),
        ),
      ),
    );
  }
}

class PagePathColumnWidget extends StatelessWidget {
  final ValueNotifier<List<SimilarityPathBean>> similarityList;
  final Function(SimilarityPathBean bean) itemOnTap;

  PagePathColumnWidget({this.similarityList, this.itemOnTap,Key key}):super(key:key);

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: similarityList.value.map((data) {
          return PagePathItemWidget(
            bean: data,
            itemOnTap: (bean) {
              itemOnTap(bean);
            },
          );
        }).toList(),
      ),
    );
  }
}
