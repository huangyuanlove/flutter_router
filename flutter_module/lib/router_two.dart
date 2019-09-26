import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'bridge.dart';
class RouterTwoWidget extends StatefulWidget {
  Map<String, Object> params;

  RouterTwoWidget(this.params);

  @override
  _RouterTwoWidgetState createState() => _RouterTwoWidgetState();
}

class _RouterTwoWidgetState extends State<RouterTwoWidget> {

  @override
  void initState() {
    super.initState();
  }

  void _goBack() {
    Bridge.getInstance().pop({"result": true, "data": DateTime.now().toIso8601String()});
  }

  @override
  Widget build(BuildContext context) {
    print("RouterTwoWidget --> ${context}");
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
      body:
      Column(
        children: <Widget>[
          RaisedButton(
            child: Text("点击携带参数返回上一页"),
            onPressed: () {
              _goBack();
            },
          ),

          RaisedButton(
            child: Text("设置返回数据,然后点击物理返回键"),
            onPressed: () {
              Bridge.getInstance().setResultParam({"result":"返回数据"});
            },
          ),
        ],
      ),


    );
  }
}
