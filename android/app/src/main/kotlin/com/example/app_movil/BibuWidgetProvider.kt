package com.example.app_movil

import android.app.PendingIntent
import android.appwidget.AppWidgetManager
import android.appwidget.AppWidgetProvider
import android.content.Context
import android.content.Intent
import android.content.SharedPreferences
import android.widget.RemoteViews

class BibuWidgetProvider : AppWidgetProvider() {
    companion object {
        private const val PREFS_NAME = "FlutterSharedPreferences"
        private const val PET_NAME_KEY = "flutter.widget_pet_name"
        private const val PET_LEVEL_KEY = "flutter.widget_pet_level"
        private const val PET_EMOJI_KEY = "flutter.widget_pet_emoji"
        private const val PET_MOOD_KEY = "flutter.widget_pet_mood"
        private const val PET_STREAK_KEY = "flutter.widget_pet_streak"
        private const val PET_COINS_KEY = "flutter.widget_pet_coins"
    }

    override fun onUpdate(
        context: Context,
        appWidgetManager: AppWidgetManager,
        appWidgetIds: IntArray
    ) {
        for (appWidgetId in appWidgetIds) {
            updateAppWidget(context, appWidgetManager, appWidgetId)
        }
    }

    private fun updateAppWidget(
        context: Context,
        appWidgetManager: AppWidgetManager,
        appWidgetId: Int
    ) {
        val prefs = context.getSharedPreferences(PREFS_NAME, Context.MODE_PRIVATE)
        val petName = prefs.getString(PET_NAME_KEY, "Bibu") ?: "Bibu"
        val petLevel = prefs.getInt(PET_LEVEL_KEY, 1)
        val petEmoji = prefs.getString(PET_EMOJI_KEY, "🐣") ?: "🐣"
        val petMood = prefs.getString(PET_MOOD_KEY, "neutral") ?: "neutral"
        val streak = prefs.getInt(PET_STREAK_KEY, 0)
        val coins = prefs.getInt(PET_COINS_KEY, 0)

        val views = RemoteViews(context.packageName, R.layout.bibu_widget)

        views.setTextViewText(R.id.widget_pet_emoji, petEmoji)
        views.setTextViewText(R.id.widget_pet_name, petName)
        views.setTextViewText(R.id.widget_pet_level, "Nv. $petLevel")
        views.setTextViewText(R.id.widget_streak, "$streak")

        val intent = Intent(context, MainActivity::class.java).apply {
            flags = Intent.FLAG_ACTIVITY_NEW_TASK or Intent.FLAG_ACTIVITY_CLEAR_TOP
        }
        val pendingIntent = PendingIntent.getActivity(
            context, 0, intent,
            PendingIntent.FLAG_UPDATE_CURRENT or PendingIntent.FLAG_IMMUTABLE
        )
        views.setOnClickPendingIntent(R.id.widget_root, pendingIntent)

        appWidgetManager.updateAppWidget(appWidgetId, views)
    }
}
