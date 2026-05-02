package com.example.app_movil

import android.content.Context
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel

class MainActivity : FlutterActivity() {
    private val CHANNEL = "bibu.app/widget"

    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)

        MethodChannel(flutterEngine.dartExecutor.binaryMessenger, CHANNEL).setMethodCallHandler { call, result ->
            if (call.method == "updateWidget") {
                val prefs = getSharedPreferences("FlutterSharedPreferences", Context.MODE_PRIVATE)
                val editor = prefs.edit()
                val args = call.arguments as Map<*, *>
                editor.putString("flutter.widget_pet_name", args["petName"] as? String ?: "Bibu")
                editor.putInt("flutter.widget_pet_level", (args["level"] as? Int) ?: 1)
                editor.putString("flutter.widget_pet_emoji", args["emoji"] as? String ?: "🐣")
                editor.putString("flutter.widget_pet_mood", args["mood"] as? String ?: "neutral")
                editor.putInt("flutter.widget_pet_streak", (args["streak"] as? Int) ?: 0)
                editor.putInt("flutter.widget_pet_coins", (args["coins"] as? Int) ?: 0)
                editor.apply()

                // Trigger widget update
                val intent = android.content.Intent(this, BibuWidgetProvider::class.java).apply {
                    action = android.appwidget.AppWidgetManager.ACTION_APPWIDGET_UPDATE
                }
                sendBroadcast(intent)

                result.success(true)
            } else {
                result.notImplemented()
            }
        }
    }
}
