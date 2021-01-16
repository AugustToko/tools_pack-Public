/*
 * Project: tools_pack Public
 * Module: toolspack_android
 * Last Modified: 21-1-16 下午12:40
 * Copyright (c) 2021 August https://blog.geek-cloud.top/
 */
package com.toolshouse.toolspack.notification

import android.app.*
import android.content.Context
import android.content.Intent
import android.graphics.BitmapFactory
import android.os.*
import android.util.Log
import androidx.annotation.RequiresApi
import androidx.core.app.NotificationCompat
import com.toolshouse.toolspack.MainActivity
import com.toolshouse.toolspack.MyApplication
import com.toolshouse.toolspack.NetTools
import com.toolshouse.toolspack.R
import java.net.URI
import kotlin.concurrent.thread

class ToolspackNotificationServer : Service() {
    var client: TpWebSocketClient? = null
    private val mBinder = JWebSocketClientBinder()

    //获取电源锁，保持该服务在屏幕熄灭时仍然获取CPU时，保持运行
    //锁屏唤醒
    var wakeLock: PowerManager.WakeLock? = null

    @RequiresApi(api = Build.VERSION_CODES.M)
    private fun acquireWakeLock() {
        if (null == wakeLock) {
            val pm = this.getSystemService(Context.POWER_SERVICE) as PowerManager
            wakeLock = pm.newWakeLock(PowerManager.PARTIAL_WAKE_LOCK, "toolspack:ToolspackNotificationServer")
            if (null != wakeLock) {
                wakeLock!!.acquire()
            }
        }
    }

    //用于Activity和service通讯
    inner class JWebSocketClientBinder : Binder() {
        val service: ToolspackNotificationServer
            get() = this@ToolspackNotificationServer
    }

    override fun onBind(intent: Intent): IBinder? {
        return mBinder
    }

    override fun onStartCommand(intent: Intent, flags: Int, startId: Int): Int {
        closeConnect()
        mHandler.removeCallbacks(heartBeatRunnable)
        initSocketClient()
        mHandler.postDelayed(heartBeatRunnable, HEART_BEAT_RATE)
        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.M) {
            acquireWakeLock()
        }
        if (intent.getBooleanExtra("startF", false)) {
            startF()
        }
        return START_NOT_STICKY
    }

    private fun startF() {
        val notifyManager = getSystemService(Context.NOTIFICATION_SERVICE) as NotificationManager

        // 兼容 android8.0
        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.O) {
            val channel = NotificationChannel("ChannelID B", "TpForeground", NotificationManager.IMPORTANCE_HIGH)
            // 是否在桌面icon右上角展示小红点
            channel.enableLights(false)
            // 是否在久按桌面图标时显示此渠道的通知
            channel.setShowBadge(false)
            channel.enableVibration(false)
            channel.setSound(null, null)
            channel.description = MyApplication.appName + "的前台通知频道"
            notifyManager.createNotificationChannel(channel)
        }
        val fIntent = Intent()
        fIntent.setClass(this, MainActivity::class.java)
        val pendingIntent = PendingIntent.getActivity(this, 0, fIntent, PendingIntent.FLAG_UPDATE_CURRENT)
        val notification = NotificationCompat.Builder(this, "ChannelID B")
                .setAutoCancel(true) // 设置该通知优先级
                .setPriority(NotificationCompat.PRIORITY_MAX)
                .setSmallIcon(R.drawable.notification_icon)
                .setContentTitle("${MyApplication.appName}通知守护进程")
                .setVisibility(NotificationCompat.VISIBILITY_PUBLIC)
                .setWhen(System.currentTimeMillis())
                .setDefaults(Notification.DEFAULT_ALL)
                .setContentIntent(pendingIntent)
                .build()
        startForeground(1, notification)
    }

    override fun onDestroy() {
        Log.d(TAG, "onDestroy: ")
        stopForeground(true)
        wakeLock!!.release()
        closeConnect()
        super.onDestroy()
    }

    /**
     * 初始化 WebSocket 连接
     */
    private fun initSocketClient() {
        val uri = URI.create("ws://47.94.206.110:2342/ws")
        client = object : TpWebSocketClient(uri) {
            override fun onMessage(message: String) {
                Log.d(TAG, "onMessage: $message")
                checkLockAndShowNotification(message)
            }
        }
        connect()
    }

    /**
     * 连接 websocket
     */
    private fun connect() {
        object : Thread() {
            override fun run() {
                try {
                    // connectBlocking 多出一个等待操作，会先连接再发送，否则未连接发送会报错
                    client!!.connectBlocking()
                } catch (e: InterruptedException) {
                    e.printStackTrace()
                    client = null
                    initSocketClient()
                }
            }
        }.start()
    }
    //    /**
    //     * 发送消息
    //     *
    //     * @param msg msg
    //     */
    //    public void sendMsg(String msg) {
    //        if (null != client) {
    //            Log.e("JWebSocketClientService", "发送的消息：" + msg);
    //            client.send(msg);
    //        }
    //    }
    /**
     * 断开连接
     */
    private fun closeConnect() {
        try {
            if (null != client) {
                client!!.close()
            }
        } catch (e: Exception) {
            e.printStackTrace()
        } finally {
            client = null
        }
    }
    //    -----------------------------------消息通知--------------------------------------------------------
    /**
     * 检查锁屏状态，如果锁屏先点亮屏幕
     *
     * @param content content
     */
    private fun checkLockAndShowNotification(content: String) {
        val data = content.split("&AND&".toRegex()).toTypedArray()
        if (data.size < 4) return

        //管理锁屏的一个服务
        val km = getSystemService(Context.KEYGUARD_SERVICE) as KeyguardManager
        if (km.isKeyguardLocked) { //锁屏
            //获取电源管理器对象
            val pm = this.getSystemService(Context.POWER_SERVICE) as PowerManager
            if (!pm.isScreenOn) {
                val wl = pm.newWakeLock(PowerManager.SCREEN_DIM_WAKE_LOCK or PowerManager.ACQUIRE_CAUSES_WAKEUP or PowerManager.ON_AFTER_RELEASE, "toolspack:ToolspackNotificationServer bright")
                wl.acquire(1000) //点亮屏幕
            }
        }

        val notificationType = data[1]
        val notificationTitle = data[2]
        val notificationContent = data[3]

        val otherData = if (data.size == 5) data[4] else ""

        sendNotification(notificationTitle, notificationContent, notificationType, otherData)
    }

    /**
     * 发送通知
     */
    private fun sendNotification(title: String, content: String, type: String, otherData: String) {

        thread(start = true) {
            val notifyManager = getSystemService(Context.NOTIFICATION_SERVICE) as NotificationManager

            // 兼容 android8.0
            if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.O) {
                val channel = NotificationChannel("ChannelID A", "TpNotification", NotificationManager.IMPORTANCE_HIGH)
                // 是否在桌面icon右上角展示小红点
                channel.enableLights(true)
                // 是否在久按桌面图标时显示此渠道的通知
                channel.setShowBadge(true)
                channel.enableVibration(false)
                channel.description = MyApplication.appName + "的通知频道"
                notifyManager.createNotificationChannel(channel)
            }

            val style: NotificationCompat.Style?
            style = when (type) {
                "Normal" -> null
                "Image" -> {
                    val tempStyle = NotificationCompat.BigPictureStyle()
                    val bitmap = NetTools.getImageBitmap(otherData)
                    if (bitmap != null) {
                        tempStyle.bigPicture(bitmap)
                    } else {
                        tempStyle.bigPicture(BitmapFactory.decodeResource(resources, R.drawable.notification_icon))
                    }
                    tempStyle
                }
                "LargeText" -> {
                    val tempStyle = NotificationCompat.BigTextStyle()
                    tempStyle.bigText(otherData)
                    tempStyle
                }
                else -> null
            }
            val intent = Intent()
            intent.setClass(this, MainActivity::class.java)
            val pendingIntent = PendingIntent.getActivity(this, 0, intent, PendingIntent.FLAG_UPDATE_CURRENT)
            val notification = NotificationCompat.Builder(this, "ChannelID A")
                    .setAutoCancel(true) // 设置该通知优先级
                    .setPriority(NotificationCompat.PRIORITY_MAX)
                    .setSmallIcon(R.drawable.notification_icon)
                    .setContentTitle(title)
                    .setContentText(content)
                    .setVisibility(NotificationCompat.VISIBILITY_PUBLIC)
                    .setWhen(System.currentTimeMillis())
                    .setDefaults(Notification.DEFAULT_ALL)
                    .setContentIntent(pendingIntent)
                    .setStyle(style)
                    .build()
            notifyManager.notify(2, notification) //id要保证唯一
        }
    }

    private val mHandler = Handler()

    private val heartBeatRunnable: Runnable = object : Runnable {
        override fun run() {
            if (client != null) {
                if (client!!.isClosed) {
                    reconnectWs()
                }
            } else {
                // 如果client已为空，重新初始化连接
                initSocketClient()
            }
            // 每隔一定的时间，对长连接进行一次心跳检测
            mHandler.postDelayed(this, HEART_BEAT_RATE)
        }
    }

    /**
     * 开启重连
     */
    private fun reconnectWs() {
        mHandler.removeCallbacks(heartBeatRunnable)
        object : Thread() {
            override fun run() {
                try {
                    Log.e("JWebSocketClientService", "开启重连")
                    client!!.reconnectBlocking()
                } catch (e: InterruptedException) {
                    e.printStackTrace()
                }
            }
        }.start()
    }

    companion object {
        private val TAG = ToolspackNotificationServer::class.java.simpleName

        //    -------------------------------------websocket心跳检测------------------------------------------------
        private const val HEART_BEAT_RATE = 10 * 1000 //每隔10秒进行一次对长连接的心跳检测
                .toLong()
    }

    init {
        Log.d(TAG, "JWebSocketClientService: JWebSocketClientService()")
    }
}