/*
 * Project: tools_pack Public
 * Module: toolspack_android
 * Last Modified: 21-1-16 下午12:40
 * Copyright (c) 2021 August https://blog.geek-cloud.top/
 */

package com.toolshouse.toolspack;

import android.graphics.Bitmap;
import android.graphics.BitmapFactory;

import java.io.IOException;
import java.io.InputStream;
import java.net.HttpURLConnection;
import java.net.MalformedURLException;
import java.net.URL;

public class NetTools {
    //    //    public static String getStudentInfo(String schoolName, String account, String password, int type) {
//    @WorkerThread
//    public static String nativePost(final String url, String bodyData) {
//        OkHttpClient client = new OkHttpClient().newBuilder()
//                .build();
//        MediaType mediaType = MediaType.parse("application/x-www-form-urlencoded");
//        RequestBody body = RequestBody.create(mediaType, bodyData);
//        Request request = new Request.Builder()
//                .url(url)
//                .method("POST", body)
//                .addHeader("Content-Type", "application/x-www-form-urlencoded")
//                .build();
//        try {
//            Response response = client.newCall(request).execute();
//            ResponseBody responseBody = response.body();
//            if (responseBody != null) return responseBody.string();
//            else return "";
//        } catch (IOException e) {
//            e.printStackTrace();
//            return "";
//        }
//    }
    public static Bitmap getImageBitmap(String url) {
        URL imgUrl = null;
        Bitmap bitmap = null;
        try {
            imgUrl = new URL(url);
            HttpURLConnection conn = (HttpURLConnection) imgUrl
                    .openConnection();
            conn.setDoInput(true);
            conn.connect();
            InputStream is = conn.getInputStream();
            bitmap = BitmapFactory.decodeStream(is);
            is.close();
        } catch (MalformedURLException e) {
            e.printStackTrace();
        } catch (IOException e) {
            e.printStackTrace();
        }
        return bitmap;
    }
}
