package com.huangyuanlove.flutterandandroid;


import android.app.Activity;
import android.content.Intent;
import android.content.pm.PackageManager;
import android.content.pm.ResolveInfo;
import android.net.Uri;
import android.os.Bundle;
import android.support.annotation.Nullable;
import android.support.v7.app.AppCompatActivity;
import android.util.Log;

import org.json.JSONObject;

import java.util.List;
import io.flutter.facade.Flutter;
import io.flutter.plugin.common.MethodCall;
import io.flutter.plugin.common.MethodChannel;
import io.flutter.view.FlutterView;

public class MainActivity extends AppCompatActivity {


    MethodChannel methodChannel;

    @Override
    protected void onCreate(Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);


        FlutterView flutterView = Flutter.createView(this, getLifecycle(), getRouter());
        setContentView(flutterView);
        initChannel(flutterView);
    }


    String getRouter() {
        if (getIntent() != null && getIntent().getData() != null) {
            return getIntent().getData().toString();

        }
        return "main";
    }


    private void initChannel(FlutterView flutterView) {
        methodChannel = new MethodChannel(flutterView, "my_flutter/plugin");

        methodChannel.setMethodCallHandler(new MethodChannel.MethodCallHandler() {
            @Override
            public void onMethodCall(MethodCall methodCall, MethodChannel.Result result) {

                Log.e("调用原生", methodCall.method + ":--" + methodCall.arguments);

                switch (methodCall.method) {
                    case "close":
                        if (methodCall.arguments != null) {
                            Intent intent = new Intent();
                            intent.putExtra("result",  methodCall.arguments.toString());
                            setResult(Activity.RESULT_OK, intent);
                        }
                        finish();
                        break;


                    case "openOther":
                        if (methodCall.arguments != null) {

                            Object uriString = methodCall.argument("url");
                            Object requestCode = methodCall.argument("code");

                            if(uriString!=null){
                                Intent intent = new Intent();
                                intent.setData(Uri.parse(uriString.toString()));

                                final PackageManager packageManager = getPackageManager();
                                List<ResolveInfo> list =
                                        packageManager.queryIntentActivities(intent,
                                                PackageManager.MATCH_DEFAULT_ONLY);
                                if (list.size() > 0) {
                                    if (requestCode != null) {
                                        startActivityForResult(intent, Integer.valueOf(requestCode.toString()));
                                    } else {
                                        startActivity(intent);
                                        result.success(true);
                                    }

                                } else {
                                    result.error("找不到对应处理的activity", methodCall.arguments.toString(), "");
                                }
                            }else {
                                result.error("路径为空", "", methodCall.arguments);
                            }
                        } else{
                            result.error("参数为空", "", "");
                        }
                        break;
                    default:
                        break;
                }
            }
        });
    }


    @Override
    public void onBackPressed() {
        methodChannel.invokeMethod("pop", null);
    }


    @Override
    protected void onActivityResult(int requestCode, int resultCode, @Nullable Intent data) {
        if (resultCode == Activity.RESULT_OK) {


            String result = "";
            if (data != null) {
                result = data.getStringExtra("result");
            }

            methodChannel.invokeMethod("on_result", make(result,requestCode).toString());
        }
    }

    private JSONObject make(String result, int requestCode) {


        JSONObject r = new JSONObject();
        try {
            if (result != null) {
                r.put("data",new JSONObject(result));
            }
            r.put("requestCode",requestCode);

        } catch (Exception e) {
            e.printStackTrace();
        }


        return r;
    }


}
