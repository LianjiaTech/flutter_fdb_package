import 'package:flutter/material.dart';
import 'package:flutter_fdb_memory_kit/func/memory_calculate_util.dart';
import 'package:flutter_fdb_package/flutter_fdb_package.dart';
import '../bean/memory_info_bean.dart';
import '../services/memory_service.dart';
import 'memory_usage_chart.dart';

const String ExternalUsage =
    "Dart对象所持有的非Dart的内存，比如Dart_NewFinalizableHandle。这些内存一般是VM embedder or native extensions";

class MemoryInfoTitleWidget extends StatefulWidget {
  @override
  _MemoryInfoTitleWidgetState createState() => _MemoryInfoTitleWidgetState();
}

class _MemoryInfoTitleWidgetState extends State<MemoryInfoTitleWidget> {
  Future<MemoryUsageWrapperModel> memoryUsageWrapperFuture;

  bool _showOther;

  @override
  void initState() {
    super.initState();
    _showOther = false;
    memoryUsageWrapperFuture = MemoryService.instance.getMemoryUsageWrapper();
  }

  @override
  Widget build(BuildContext context) {
    return FdbFutureWidget<MemoryUsageWrapperModel>(
      future: memoryUsageWrapperFuture,
      showLoading: false,
      widgetBuilder: (context, data) {
        return Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Container(
                padding: EdgeInsets.only(left: 10, top: 10),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    _buildSizeInfo(
                        'ExternalUsage', data.externalUsage, ExternalUsage),
                    _buildSizeInfo('HeapCapacity', data.heapCapacity, ""),
                    _buildSizeInfo('HeapUsage', data.heapUsage, ""),
                  ],
                )),
            MemoryInfoChart(
              memoryUsage: data,
            )
          ],
        );
      },
    );
  }

  Widget _buildSizeInfo(String key, int value, String otherInfo) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        RichText(
          text: TextSpan(children: <InlineSpan>[
            TextSpan(text: '$key:  ', style: TextStyle(color: Colors.black87)),
            TextSpan(
                style: TextStyle(color: Colors.black87),
                text: '  ${MemoryCalculateUtil.byteToSizeString(value)}'),
            WidgetSpan(
                child: otherInfo.isEmpty
                    ? Container()
                    : GestureDetector(
                        onTap: () {
                          setState(() {
                            _showOther = !_showOther;
                          });
                        },
                        child: Icon(
                          Icons.help_outline,
                          color: Colors.black54,
                          size: 15,
                        ),
                      ),
                alignment: PlaceholderAlignment.middle),
          ]),
        ),
        otherInfo.isEmpty
            ? Container()
            : Visibility(
                visible: _showOther,
                child: Text(
                  otherInfo,
                  style: TextStyle(color: Colors.black54),
                ),
              )
      ],
    );
  }
}
