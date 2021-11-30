import 'dart:async';
import 'dart:convert';
import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:flutter_fdb_package/flutter_fdb_package.dart';

typedef SuccessWidgetBuilder<T> = Function(BuildContext context, T data);

class FdbFutureWidget<T> extends StatefulWidget {
  final Future<T> future;
  final SuccessWidgetBuilder<T> widgetBuilder;
  final bool isSliver;
  final bool showLoading;

  const FdbFutureWidget(
      {Key key,
      this.future,
      this.widgetBuilder,
      this.isSliver = false,
      this.showLoading = true})
      : super(key: key);

  @override
  _FdbFutureWidgetState<T> createState() => _FdbFutureWidgetState<T>();
}

class _FdbFutureWidgetState<T> extends State<FdbFutureWidget<T>> {
  Uint8List icon;

  @override
  void initState() {
    super.initState();
    icon = base64Decode(errorIcon);
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<T>(
      future: widget.future,
      builder: (BuildContext context, AsyncSnapshot<T> snapshot) {
        if (snapshot.hasData) {
          return widget.widgetBuilder(context, snapshot.data);
        }
        if (snapshot.connectionState == ConnectionState.waiting) {
          Widget indicator = widget.showLoading
              ? Center(
                  child: CircularProgressIndicator(),
                )
              : Container(
                  height: 0,
                  width: 0,
                );
          if (widget.isSliver) {
            indicator = SliverToBoxAdapter(
              child: indicator,
            );
          }
          return indicator;
        }

        if (snapshot.hasError) {
          Widget error = Image.memory(
            icon,
            width: 128,
            height: 128,
          );
          if (widget.isSliver) {
            error = SliverToBoxAdapter(
              child: error,
            );
          }
          return error;
        }

        if (widget.isSliver) {
          return SliverToBoxAdapter(
            child: Container(
              height: 0,
              width: 0,
            ),
          );
        } else
          return Container(
            height: 0,
            width: 0,
          );
      },
    );
  }
}
