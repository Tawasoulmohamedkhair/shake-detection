package com.example.shakedetection

import android.content.Context
import android.hardware.Sensor
import android.hardware.SensorEvent
import android.hardware.SensorEventListener
import android.hardware.SensorManager
import android.media.MediaPlayer
import android.os.VibrationEffect
import android.os.Vibrator
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.EventChannel
import kotlin.math.sqrt




class MainActivity : FlutterActivity() {

    private val SHAKE_CHANNEL = "com.example.shake_channel"

    private var sensorManager: SensorManager? = null
    private var accelerometer: Sensor? = null
    private var shakeListener: SensorEventListener? = null

    private val shakeSound = R.raw.shake1

    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)
        EventChannel(flutterEngine.dartExecutor.binaryMessenger, SHAKE_CHANNEL)
            .setStreamHandler(object : EventChannel.StreamHandler {
                override fun onListen(arguments: Any?, events: EventChannel.EventSink?) {
                    startShakeDetection(events)
                }
                override fun onCancel(arguments: Any?) { stopShakeDetection() }
            })
    }

    private fun startShakeDetection(events: EventChannel.EventSink?) {
        sensorManager = getSystemService(Context.SENSOR_SERVICE) as SensorManager
        accelerometer = sensorManager?.getDefaultSensor(Sensor.TYPE_ACCELEROMETER)

        shakeListener = object : SensorEventListener {
            override fun onSensorChanged(event: SensorEvent) {
                val x = event.values[0]
                val y = event.values[1]
                val z = event.values[2]
                val acceleration = sqrt((x * x + y * y + z * z).toDouble()) - 9.8

                if (acceleration > 12) {
                    val vibrator = getSystemService(Context.VIBRATOR_SERVICE) as Vibrator
                    vibrator.vibrate(VibrationEffect.createOneShot(150, VibrationEffect.DEFAULT_AMPLITUDE))

                    val mediaPlayer = MediaPlayer.create(this@MainActivity, shakeSound)
                    mediaPlayer.start()
                    mediaPlayer.setOnCompletionListener { mp -> mp.release() }

                    events?.success("SHAKE")
                }
            }
            override fun onAccuracyChanged(sensor: Sensor?, accuracy: Int) {}
        }

        sensorManager?.registerListener(shakeListener, accelerometer, SensorManager.SENSOR_DELAY_NORMAL)
    }

    private fun stopShakeDetection() { sensorManager?.unregisterListener(shakeListener) }
}
