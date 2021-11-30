import 'dart:async';
import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter_fdb_package/flutter_fdb_package.dart';

void main() {
  FDBKitsManager.instance.register(CustomKit());
  return runApp(fdbEnterWidget(
      child: MyApp(
        key: Key(""),
      ),
      enable: true));
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: MyHomePage(title: 'Flutter Demo Home Page'),
    );
  }

  MyApp({Key key}) : super(key: key);
}

class MyHomePage extends StatefulWidget {
  MyHomePage({Key key, this.title}) : super(key: key);

  final String title;

  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  int _counter = 0;

  void _incrementCounter() {
    // print(ModalRoute.of(context));
    // Navigator.of(context).push(MaterialPageRoute(builder: (context) {
    //   return MyWidget();
    // }));
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Text(
              'You have pushed the button this many times:',
            ),
            Text(
              '$_counter',
              style: Theme.of(context).textTheme.display1,
            ),
            RichText(
              textScaleFactor: MediaQuery.of(context).textScaleFactor,
              text: TextSpan(
                  text: "我是",
                  style: TextStyle(fontSize: 11, color: Colors.black),
                  children: <InlineSpan>[
                    TextSpan(
                      text: "查看更多",
                      style: TextStyle(fontSize: 11, color: Colors.red),
                    ),
                    WidgetSpan(
                        alignment: PlaceholderAlignment.middle,
                        child: Icon(
                          Icons.details,
                          size: 8,
                        ))
                  ]),
            )
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _incrementCounter,
        tooltip: 'Increment',
        child: Icon(Icons.add),
      ),
    );
  }
}

class MyWidget extends StatefulWidget {
  @override
  _MyWidgetState createState() => _MyWidgetState();
}

class _MyWidgetState extends State<MyWidget> {
  int i;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
        onTap: () {
          Timer.periodic(Duration(seconds: 3), (data) {
            this.i;
          });
          Navigator.of(context).pop();
        },
        child: Text("我是状态Widget，可以根据数据显示UI"));
  }
}
