/*
 * Project: tools_pack Public
 * Module: toolspack_android
 * Last Modified: 21-1-16 下午12:40
 * Copyright (c) 2021 August https://blog.geek-cloud.top/
 */

package com.toolshouse.toolspack;

import com.bun.miitmdid.core.ErrorCode;
import com.bun.miitmdid.core.JLibrary;
import com.bun.miitmdid.core.MdidSdkHelper;

import io.flutter.app.FlutterApplication;

public class MyApplication extends FlutterApplication {

    public static String OAID = "";

    public static String appName = "课程助手";

    @Override
    public void onCreate() {
        super.onCreate();
        JLibrary.InitEntry(this);
        int errorCode = MdidSdkHelper.InitSdk(this, true, (b, idSupplier) -> {
            if (idSupplier == null) {
                return;
            }
            OAID = idSupplier.getOAID();
        });

        if (errorCode == ErrorCode.INIT_ERROR_DEVICE_NOSUPPORT) {
            OAID = "ErrorCode.INIT_ERROR_DEVICE_NOSUPPORT";
        } else if (errorCode == ErrorCode.INIT_ERROR_LOAD_CONFIGFILE) {
            OAID = "ErrorCode.INIT_ERROR_LOAD_CONFIGFILE";
        } else if (errorCode == ErrorCode.INIT_ERROR_MANUFACTURER_NOSUPPORT) {
            OAID = "ErrorCode.INIT_ERROR_MANUFACTURER_NOSUPPORT";
        } else if (errorCode == ErrorCode.INIT_ERROR_RESULT_DELAY) {
            OAID = "ErrorCode.INIT_ERROR_RESULT_DELAY";
        } else if (errorCode == ErrorCode.INIT_HELPER_CALL_ERROR) {
            OAID = "ErrorCode.INIT_HELPER_CALL_ERROR";
        } else {
//            OAID = "获取成功";
        }
    }
}
