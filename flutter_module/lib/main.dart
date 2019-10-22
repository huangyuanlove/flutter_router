import 'dart:async';

import 'package:flutter/material.dart';
import 'router_one.dart';
import 'dart:ui';
import 'router_two.dart';
import 'bridge.dart';

void main() {
  runApp(getHomeWidget(window.defaultRouteName));
}

Widget getHomeWidget(String router) {
  Bridge bridge = Bridge.getInstance();

  print(router);
  Uri uri = Uri.parse(router);
  Map params = uri.queryParameters;

  String tempRouter = uri.path;

  if (tempRouter.startsWith("/") && tempRouter.length > 1) {
    print("以 / 开头");
    tempRouter = tempRouter.substring(1);
  }
  if (tempRouter.endsWith("/") && tempRouter.length > 1) {
    print("以 / 结尾");
    tempRouter = tempRouter.substring(0, tempRouter.length - 1);
  }
  print(tempRouter);
  print(params);

  Widget body;

  switch (tempRouter) {
    case 'main':
    case '/':
      body = Home();
      break;
    case "router_one":
      body = RouterOneWidget(params);
      break;
    case "router_two":
      body = RouterTwoWidget(params);
      break;
    default:
      body = Center(
        child: Text('Unknown route: $router', textDirection: TextDirection.ltr),
      );
  }

  return MaterialApp(
    home: body,
  );
}

class Home extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    return _MyAppState();
  }
}

class _MyAppState extends State<Home> {
  @override
  Widget build(BuildContext context) {
    print("Home --> ${context}");
    Bridge.getInstance().registerBuildContext(context);

    return Scaffold(
      appBar: AppBar(
        title: Text("测试"),
      ),
      body: Column(
        children: <Widget>[
          RaisedButton(
            onPressed: () {
              Navigator.of(context)
                  .push(MaterialPageRoute(builder: (BuildContext context) {
                return RouterOneWidget({"title": "传值"});
              }));
            },
            child: Text("跳转"),
          ),
        ],
      ),
    );
  }
}
