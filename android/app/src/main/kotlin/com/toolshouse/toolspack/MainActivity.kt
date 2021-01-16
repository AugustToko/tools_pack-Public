/*
 * Project: tools_pack Public
 * Module: toolspack_android
 * Last Modified: 21-1-16 下午12:40
 * Copyright (c) 2021 August https://blog.geek-cloud.top/
 */

package com.toolshouse.toolspack

import android.content.ComponentName
import android.content.Context
import android.content.Intent
import android.content.ServiceConnection
import android.net.Uri
import android.os.Build
import android.os.IBinder
import android.os.PowerManager
import android.provider.Settings
import android.widget.Toast
import androidx.annotation.NonNull
import androidx.annotation.RequiresApi
import androidx.core.content.ContextCompat
import com.toolshouse.toolspack.notification.ToolspackNotificationServer
import com.toolshouse.toolspack.notification.ToolspackNotificationServer.JWebSocketClientBinder
import com.toolshouse.toolspack.notification.TpWebSocketClient
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodCall
import io.flutter.plugin.common.MethodChannel
import io.flutter.plugins.GeneratedPluginRegistrant


class MainActivity : FlutterActivity() {
    private val flutterChannel = "com.toolshouse.toolspack/tp"

    private var client: TpWebSocketClient? = null
    private var binder: JWebSocketClientBinder? = null
    private var jWebSClientService: ToolspackNotificationServer? = null

    private var bindService: Boolean = false

    private val serviceConnection: ServiceConnection = object : ServiceConnection {
        override fun onServiceConnected(componentName: ComponentName?, iBinder: IBinder) {
            // 服务与活动成功绑定
            binder = iBinder as JWebSocketClientBinder
            jWebSClientService = binder!!.service
            client = jWebSClientService!!.client
        }

        override fun onServiceDisconnected(componentName: ComponentName?) {
            // 服务与活动断开
        }
    }

    private fun startService(startForeground: Boolean) {
        val i = Intent(this@MainActivity, ToolspackNotificationServer::class.java)
        i.putExtra("startF", startForeground)

        if (bindService) {
            unbindService(serviceConnection)
            bindService = false
            stopService(i)
        }

        if (startForeground) {
            ContextCompat.startForegroundService(this@MainActivity, i)
        } else {
            startService(i)
        }

        bindService = bindService(i, serviceConnection, Context.BIND_AUTO_CREATE)
    }

    private fun stopService() {
        val i = Intent(this@MainActivity, ToolspackNotificationServer::class.java)
        bindService = false
        unbindService(serviceConnection)
        stopService(i)
    }

    override fun configureFlutterEngine(@NonNull flutterEngine: FlutterEngine) {
        // TODO: 开启、绑定服务位置
        val startF = getSharedPreferences("FlutterSharedPreferences", Context.MODE_PRIVATE).getBoolean("flutter.startF", false)
        startService(startForeground = startF)

        GeneratedPluginRegistrant.registerWith(flutterEngine)
        MethodChannel(getFlutterEngine()!!.dartExecutor.binaryMessenger, flutterChannel).setMethodCallHandler { call: MethodCall, result: MethodChannel.Result? ->
            when (call.method) {
                "testActivity" -> {
                    if (MyALiPayUtil.hasInstalledAlipayClient(this)) {
                        MyALiPayUtil.startAlipayClient(this, call.arguments.toString())
                    } else {
                        Toast.makeText(this, "未安装支付宝!", Toast.LENGTH_SHORT).show()
                    }
                }
                "gotoTaoBao" -> {
                    try {
                        val i = packageManager.getLaunchIntentForPackage("com.taobao.taobao")
                        startActivity(i)
                    } catch (e: Exception) {
                        Toast.makeText(this, "未安装淘宝!", Toast.LENGTH_SHORT).show()
                    }
                }
                "showToast" -> {
                    Toast.makeText(this, call.arguments.toString(), Toast.LENGTH_LONG).show()
                }
                "canInstall" -> {
                    if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.O) {
                        result?.success(packageManager.canRequestPackageInstalls());
                    } else {
                        result?.success(true)
                    }
                }
                "requestInstallPermission" -> {
                    if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.O) {
                        val haveInstallPermission: Boolean = packageManager.canRequestPackageInstalls()
                        if (!haveInstallPermission) {
                            //权限没有打开则提示用户去手动打开
                            val packageURI: Uri = Uri.parse("package:$packageName")
                            val i = Intent(Settings.ACTION_MANAGE_UNKNOWN_APP_SOURCES, packageURI)
                            startActivityForResult(i, 0)
                        } else {
                            result?.success(true)
                        }
                    } else {
                        result?.success(true)
                    }
                }
//                "nativePost" -> {
//                    val executorService: ExecutorService = Executors.newCachedThreadPool()
//                    val future = executorService.submit(Callable {
//                        return@Callable NetTools.nativePost(call.argument("url"), call.argument("body"))
//                    })
//                    result?.success(future.get())
//                }
                "signRequest" -> {
                    val data = TaoBaoKeSignTool.signTopRequest(call.argument("params"), call.argument("secret"), call.argument("signMethod"))
                    result?.success(data)
                }
                "getOAID" -> {
                    result?.success(MyApplication.OAID)
                }
                "enableForeground" -> {
                    startService(startForeground = true)
                }
                "disableForeground" -> {
                    startService(startForeground = false)
                }
            }

            if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.M) {
                if (!isIgnoringBatteryOptimizations()) {
                    requestIgnoreBatteryOptimizations();
                }
            }
        }
    }


    /**
     * 电池优化
     * */
    @RequiresApi(api = Build.VERSION_CODES.M)
    private fun isIgnoringBatteryOptimizations(): Boolean {
        val isIgnoring: Boolean
        val powerManager: PowerManager = getSystemService(Context.POWER_SERVICE) as PowerManager
        isIgnoring = powerManager.isIgnoringBatteryOptimizations(packageName)
        return isIgnoring
    }

    /**
     * 电池优化
     * */
    @RequiresApi(api = Build.VERSION_CODES.M)
    fun requestIgnoreBatteryOptimizations() {
        try {
            val intent = Intent(Settings.ACTION_REQUEST_IGNORE_BATTERY_OPTIMIZATIONS)
            intent.data = Uri.parse("package:$packageName")
            startActivity(intent)
        } catch (e: java.lang.Exception) {
            e.printStackTrace()
        }
    }

    override fun onDestroy() {
        stopService()
        super.onDestroy()
    }
}