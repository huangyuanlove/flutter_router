import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/material.dart' as prefix0;
import 'package:flutter/services.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'router_two.dart';
import 'bridge.dart';

class RouterOneWidget extends StatefulWidget {
  Map params;

  RouterOneWidget(this.params);

  @override
  _RouterOneWidgetState createState() => _RouterOneWidgetState();
}

class _RouterOneWidgetState extends State<RouterOneWidget> {
  String resultParams;

  @override
  void initState() {
    super.initState();
    Bridge.getInstance().registerMethodAndHandler("on_result", (result) {
      setState(() {
        Map<String, dynamic> jsonResult = json.decode(result);
        resultParams = jsonResult["data"].toString();
      });
    });
  }


void _goBack() {
    Bridge.getInstance().pop({"result": true, "data": DateTime.now().toIso8601String()});
  }
  @override
  Widget build(BuildContext context) {
    print("RouterOneWidget --> ${context}");
    Bridge.getInstance().registerBuildContext(context);

    return Scaffold(
      appBar: AppBar(
        title: Text(widget.params['title']),
        leading: IconButton(
          onPressed: () {
            _goBack();
          },
          icon: Icon(Icons.arrow_back),
        ),
      ),

      body: Column(
        children: <Widget>[
          Text(widget.params['title']),
          RaisedButton(
            onPressed: () {

              Fluttertoast.showToast(
                  msg: "This is Center Short Toast",
                  toastLength: Toast.LENGTH_SHORT,
                  gravity: ToastGravity.CENTER,
                  timeInSecForIos: 1,
                  backgroundColor: Colors.red,
                  textColor: Colors.white,
                  fontSize: 16.0
              );

              Navigator.of(context)
                  .push(MaterialPageRoute(builder: (BuildContext context) {
                return RouterTwoWidget({"title": "参数标题"});
              })).then((result) {
                print("返回时带的值${result.toString()}");
                setState(() {
                  resultParams = result.toString();
                });
              });
            },
            child: Text("go to router_two"),
          ),
//          WillPopScope(),

          Text("返回时携带的值${resultParams}"),
          RaisedButton(
            child: Text("打开原生"),
            onPressed: () {
              Bridge.getInstance()
                  .openNative("router://flutter/router_one?title=标题参数", 10001);
            },
          ),
          RaisedButton(
            child: Text("关闭当前页 并返回数据"),
            onPressed: () {
              Bridge.getInstance().closeNative(
                  {"timestamp": DateTime.now().millisecondsSinceEpoch});
            },
          ),
        ],
      ),
    );
  }
}
