import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class Bridge {
  Bridge._() {
    _init();
  }

  static Bridge _instance = Bridge._();
  MethodChannel _methodChannel;

  //保存BuildContext
  BuildContext _buildContextRecord;
  Map<String, Function> _methodHandles = Map();

  //保存返回上一页用的信息
  Map<String, dynamic> _resultParam;

  static Bridge getInstance() {
    return _instance;
  }

  void _init() {
    print("Bridge 初始化");

    _methodChannel = new MethodChannel("my_flutter/plugin");

    _methodChannel.setMethodCallHandler((MethodCall call) {
      print("调用flutter方法${call.method}");

      //原生点击物理返回键时调用`pop`方法
      if ("pop" == call.method) {
        print("flutter 处理pop");
        if (call.arguments is Map) {
          _resultParam = call.arguments;
        }

        return _handlePop();
      } else {
        Function fn = _methodHandles[call.method];
        if (fn != null) {
          return fn(call.arguments);
        }else{
          throw Exception("找不到对应的方法${call.method}");
        }


      }
    });
  }

  void registerBuildContext(BuildContext context) {
    _buildContextRecord = context;
  }

  void unRegisterBuildContext(BuildContext context) {
    _buildContextRecord = null;
  }

  void registerMethodAndHandler(String method, Function handler) {
    _methodHandles[method] = handler;
  }

  void unRegisterMethodAndHandler(String method, Function handler) {
    _methodHandles.remove(method);
  }

  void setResultParam(Map<String, dynamic> params) {
    _resultParam = params;
  }



  void closeNative([Map<String, dynamic> params]){
    _methodChannel.invokeMethod("close", params);
    _resultParam = null;
  }


  //处理pop方法，先判断是否可以pop，如果不可以，则调用原生close方法
  Future<dynamic> _handlePop() async {
    var result;

    if (_buildContextRecord != null &&
        Navigator.of(_buildContextRecord).canPop()) {
      result = Navigator.of(_buildContextRecord).pop(_resultParam);
    } else {
      result = _methodChannel.invokeMethod("close", _resultParam);
    }
    _resultParam = null;
    return result;
  }

  void invoke(String method, [dynamic arguments]) {
    _methodChannel.invokeMethod(method, arguments);
  }

  //flutter 要pop页面时调用此方法
  void pop(Map<String, dynamic> params) {
    _resultParam = params;
    _handlePop();
  }


  void openNative(String url,[int requestCode]){
    _methodChannel.invokeMethod("openOther",{"url":url,"code":requestCode});
  }



  String getOpenNativeUrl(String suffixUrl,Map<String,dynamic> params){
   return  Uri(scheme: "router",host: "flutter",path: suffixUrl,queryParameters: params).toString();
  }



}
