import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:vm_service/vm_service.dart';

import '../bean/memory_info_bean.dart';
import '../services/memory_service.dart';
import '../widgets/memory_info_widgets.dart';

class MemoryClassDetail extends StatefulWidget {
  final ValueNotifier<MemoryClassModel> classModel;

  MemoryClassDetail({this.classModel});

  @override
  _MemoryClassDetailState createState() => _MemoryClassDetailState();
}

class _MemoryClassDetailState extends State<MemoryClassDetail> {
  Future<List<MemoryInstanceModel>> future;

  @override
  void initState() {
    super.initState();
    future = MemoryService.instance
        .getClassInstances(widget.classModel.value.classRef.id);
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.black54,
      child: UnconstrainedBox(
        child: Card(
          color: Colors.white,
          child: Container(
            constraints: BoxConstraints.tight(Size(
                (window.physicalSize / window.devicePixelRatio).width * 0.8,
                (window.physicalSize / window.devicePixelRatio).height * 0.5)),
            child: FutureBuilder<List<MemoryInstanceModel>>(
                future: future,
                builder: (BuildContext context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return Center(child: CircularProgressIndicator());
                  }
                  if (snapshot.hasData) {
                    if (snapshot.data.isEmpty) {
                      return Center(
                        child: Text("暂无数据～～"),
                      );
                    }
                    return ListView.builder(
                      itemBuilder: (context, index) {
                        InstanceRef instance = snapshot.data[index].instanceRef;
                        return _instanceWidget(instance, snapshot.data[index]);
                      },
                      itemCount: snapshot.data.length,
                    );
                  }
                  return Container(
                    height: 0,
                    width: 0,
                  );
                }),
          ),
        ),
      ),
    );
  }

  Widget _instanceWidget(InstanceRef ref, MemoryInstanceModel model) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        MemoryInstanceTitle(
          padding:
              const EdgeInsets.only(top: 16, bottom: 12, left: 20, right: 20),
          title: ref.id,
        ),
        Padding(
          padding: const EdgeInsets.only(left: 25, right: 25),
          child: MemoryInstanceFieldWidget(
            children: model.fields.map((data) {
              return InfoModal(keyPart: data.name, valuePart: data.value);
            }).toList(),
          ),
        )
      ],
    );
  }
}
