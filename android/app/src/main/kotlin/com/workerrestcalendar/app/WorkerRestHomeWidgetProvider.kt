package com.workerrestcalendar.app

import android.app.PendingIntent
import android.appwidget.AppWidgetManager
import android.content.ComponentName
import android.content.Context
import android.content.Intent
import android.content.SharedPreferences
import android.content.res.Configuration
import android.net.Uri
import android.os.Build
import android.os.Bundle
import android.view.View
import android.widget.RemoteViews
import androidx.core.content.ContextCompat
import es.antonborri.home_widget.HomeWidgetLaunchIntent
import es.antonborri.home_widget.HomeWidgetProvider
import org.json.JSONArray
import org.json.JSONObject
import java.time.LocalDate

class WorkerRestHomeWidgetProvider : HomeWidgetProvider() {
    override fun onUpdate(
        context: Context,
        appWidgetManager: AppWidgetManager,
        appWidgetIds: IntArray,
        widgetData: SharedPreferences,
    ) {
        val snapshot = parseSnapshot(widgetData.getString(SNAPSHOT_KEY, null))
        appWidgetIds.forEach { widgetId ->
            val options = appWidgetManager.getAppWidgetOptions(widgetId)
            val size = WidgetSize.fromOptions(options)
            val views = render(context, size, snapshot)
            appWidgetManager.updateAppWidget(widgetId, views)
        }
    }

    override fun onAppWidgetOptionsChanged(
        context: Context,
        appWidgetManager: AppWidgetManager,
        appWidgetId: Int,
        newOptions: Bundle,
    ) {
        super.onAppWidgetOptionsChanged(context, appWidgetManager, appWidgetId, newOptions)
        onUpdate(context, appWidgetManager, intArrayOf(appWidgetId))
    }

    override fun onReceive(context: Context, intent: Intent) {
        super.onReceive(context, intent)
        if (intent.action in DATE_CHANGE_ACTIONS) {
            val manager = AppWidgetManager.getInstance(context)
            val ids = manager.getAppWidgetIds(
                ComponentName(context, WorkerRestHomeWidgetProvider::class.java),
            )
            onUpdate(context, manager, ids)
        }
    }

    private fun render(
        context: Context,
        size: WidgetSize,
        snapshot: WidgetSnapshot?,
    ): RemoteViews {
        val views = RemoteViews(context.packageName, R.layout.worker_rest_home_widget)
        if (snapshot == null || snapshot.days.isEmpty()) {
            renderEmpty(context, views)
            return views
        }
        val today = LocalDate.now()
        val day = snapshot.days.firstOrNull { it.date == today } ?: snapshot.days.last()
        val palette = WidgetPalette.resolve(context, snapshot.theme)
        views.setInt(R.id.widget_root, "setBackgroundResource", palette.background)
        views.setViewVisibility(R.id.widget_small, if (size == WidgetSize.SMALL) View.VISIBLE else View.GONE)
        views.setViewVisibility(R.id.widget_medium, if (size == WidgetSize.MEDIUM) View.VISIBLE else View.GONE)
        views.setViewVisibility(R.id.widget_large, if (size == WidgetSize.LARGE) View.VISIBLE else View.GONE)
        views.setOnClickPendingIntent(R.id.widget_root, launchIntent(context, day.date))
        when (size) {
            WidgetSize.SMALL -> renderSmall(context, views, day, palette)
            WidgetSize.MEDIUM -> renderMedium(context, views, day, palette)
            WidgetSize.LARGE -> renderLarge(context, views, snapshot, day, palette)
        }
        return views
    }

    private fun renderEmpty(context: Context, views: RemoteViews) {
        val palette = WidgetPalette.resolve(context, "system")
        views.setInt(R.id.widget_root, "setBackgroundResource", palette.background)
        views.setViewVisibility(R.id.widget_small, View.VISIBLE)
        views.setViewVisibility(R.id.widget_medium, View.GONE)
        views.setViewVisibility(R.id.widget_large, View.GONE)
        views.setTextViewText(R.id.small_title, "●  等待排班")
        views.setTextViewText(R.id.small_status, "打开应用")
        views.setTextViewText(R.id.small_countdown_label, "完成班制设置后")
        views.setTextViewText(R.id.small_countdown, "自动同步")
        views.setTextViewText(R.id.small_week_type, "数据仅保存在本机")
        setTextColors(views, palette, intArrayOf(
            R.id.small_title,
            R.id.small_status,
            R.id.small_countdown_label,
            R.id.small_countdown,
            R.id.small_week_type,
        ))
        views.setOnClickPendingIntent(R.id.widget_root, launchIntent(context, LocalDate.now()))
    }

    private fun renderSmall(
        context: Context,
        views: RemoteViews,
        day: DaySnapshot,
        palette: WidgetPalette,
    ) {
        val statusColor = palette.kindColor(context, day.kind)
        views.setTextViewText(R.id.small_title, "●  今日状态")
        views.setTextViewText(R.id.small_status, day.kind.fullLabel)
        views.setTextViewText(R.id.small_countdown, "${day.daysToNextRest}天")
        views.setTextViewText(R.id.small_week_type, day.weekType.label)
        views.setTextColor(R.id.small_title, statusColor)
        views.setTextColor(R.id.small_status, statusColor)
        views.setTextColor(R.id.small_countdown, palette.adjustedRest(context))
        views.setTextColor(R.id.small_countdown_label, palette.secondary(context))
        views.setTextColor(R.id.small_week_type, palette.secondary(context))
    }

    private fun renderMedium(
        context: Context,
        views: RemoteViews,
        day: DaySnapshot,
        palette: WidgetPalette,
    ) {
        views.setTextViewText(R.id.medium_week_type, "本周：${day.weekType.label}")
        views.setTextViewText(
            R.id.medium_next_rest,
            "下次休息 ${day.nextRestDate.monthValue}月${day.nextRestDate.dayOfMonth}日",
        )
        views.setTextColor(R.id.medium_title, palette.primary(context))
        views.setTextColor(R.id.medium_week_type, palette.primary(context))
        views.setTextColor(R.id.medium_next_rest, palette.secondary(context))
        views.removeAllViews(R.id.medium_week_row)
        val monday = day.date.minusDays((day.date.dayOfWeek.value - 1).toLong())
        day.week.forEachIndexed { index, kind ->
            val cell = RemoteViews(context.packageName, R.layout.widget_week_day)
            cell.setTextViewText(R.id.week_day_label, WEEKDAY_LABELS[index])
            cell.setTextViewText(R.id.week_day_status, kind.shortLabel)
            cell.setTextColor(R.id.week_day_label, palette.secondary(context))
            cell.setTextColor(R.id.week_day_status, palette.kindColor(context, kind))
            cell.setInt(R.id.week_day_status, "setBackgroundResource", palette.cellBackground)
            cell.setOnClickPendingIntent(
                R.id.week_day_root,
                launchIntent(context, monday.plusDays(index.toLong())),
            )
            views.addView(R.id.medium_week_row, cell)
        }
    }

    private fun renderLarge(
        context: Context,
        views: RemoteViews,
        snapshot: WidgetSnapshot,
        day: DaySnapshot,
        palette: WidgetPalette,
    ) {
        val month = snapshot.months.firstOrNull {
            it.month.year == day.date.year && it.month.monthValue == day.date.monthValue
        } ?: snapshot.months.firstOrNull()
        views.setTextViewText(R.id.large_title, "${day.date.year}年${day.date.monthValue}月")
        views.setTextColor(R.id.large_title, palette.primary(context))
        views.setTextColor(R.id.large_legend, palette.secondary(context))
        views.removeAllViews(R.id.large_calendar_grid)
        if (month == null) return
        month.days.chunked(7).forEach { week ->
            val row = RemoteViews(context.packageName, R.layout.widget_calendar_row)
            week.forEach { calendarDay ->
                val cell = RemoteViews(context.packageName, R.layout.widget_calendar_day)
                cell.setTextViewText(R.id.calendar_day, calendarDay.date.dayOfMonth.toString())
                val isToday = calendarDay.date == LocalDate.now()
                val inMonth = calendarDay.date.monthValue == month.month.monthValue
                val color = when {
                    isToday -> ContextCompat.getColor(context, android.R.color.white)
                    !inMonth -> palette.secondary(context)
                    calendarDay.kind.isRest -> palette.kindColor(context, calendarDay.kind)
                    else -> palette.primary(context)
                }
                cell.setTextColor(R.id.calendar_day, color)
                if (isToday) {
                    cell.setInt(R.id.calendar_day, "setBackgroundResource", R.drawable.widget_today_background)
                }
                cell.setOnClickPendingIntent(
                    R.id.calendar_day,
                    launchIntent(context, calendarDay.date),
                )
                row.addView(R.id.calendar_row, cell)
            }
            views.addView(R.id.large_calendar_grid, row)
        }
    }

    private fun setTextColors(views: RemoteViews, palette: WidgetPalette, ids: IntArray) {
        ids.forEach { views.setTextColor(it, palette.primaryColor) }
    }

    private fun launchIntent(context: Context, date: LocalDate): PendingIntent {
        val uri = Uri.Builder()
            .scheme("workerrestcalendar")
            .authority("open")
            .appendQueryParameter("date", date.toString())
            .build()
        val intent = Intent(context, MainActivity::class.java).apply {
            action = HomeWidgetLaunchIntent.HOME_WIDGET_LAUNCH_ACTION
            data = uri
            flags = Intent.FLAG_ACTIVITY_CLEAR_TOP or Intent.FLAG_ACTIVITY_SINGLE_TOP
        }
        val flags = PendingIntent.FLAG_UPDATE_CURRENT or
            if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.M) PendingIntent.FLAG_IMMUTABLE else 0
        return PendingIntent.getActivity(context, date.toEpochDay().toInt(), intent, flags)
    }

    private fun parseSnapshot(source: String?): WidgetSnapshot? {
        if (source == null) return null
        return runCatching {
            val root = JSONObject(source)
            if (root.getInt("version") != 1) return null
            val days = root.getJSONArray("days").mapObjects { DaySnapshot.fromJson(it) }
            val months = root.getJSONArray("months").mapObjects { MonthSnapshot.fromJson(it) }
            WidgetSnapshot(root.optString("theme", "system"), days, months)
        }.getOrNull()
    }

    private fun <T> JSONArray.mapObjects(transform: (JSONObject) -> T): List<T> =
        (0 until length()).map { transform(getJSONObject(it)) }

    private data class WidgetSnapshot(
        val theme: String,
        val days: List<DaySnapshot>,
        val months: List<MonthSnapshot>,
    )

    private data class DaySnapshot(
        val date: LocalDate,
        val kind: DayKind,
        val weekType: String?,
        val daysToNextRest: Int,
        val nextRestDate: LocalDate,
        val week: List<DayKind>,
    ) {
        companion object {
            fun fromJson(json: JSONObject) = DaySnapshot(
                date = LocalDate.parse(json.getString("date")),
                kind = DayKind.valueOf(json.getString("kind")),
                weekType = json.optString("weekType").ifBlank { null },
                daysToNextRest = json.getInt("daysToNextRest"),
                nextRestDate = LocalDate.parse(json.getString("nextRestDate")),
                week = (json.getJSONArray("week").let { array ->
                    (0 until array.length()).map { DayKind.valueOf(array.getString(it)) }
                }),
            )
        }
    }

    private data class MonthSnapshot(
        val month: LocalDate,
        val days: List<CalendarDay>,
    ) {
        companion object {
            fun fromJson(json: JSONObject) = MonthSnapshot(
                month = LocalDate.parse(json.getString("month")),
                days = json.getJSONArray("days").let { array ->
                    (0 until array.length()).map { CalendarDay.fromJson(array.getJSONObject(it)) }
                },
            )
        }
    }

    private data class CalendarDay(val date: LocalDate, val kind: DayKind) {
        companion object {
            fun fromJson(json: JSONObject) = CalendarDay(
                LocalDate.parse(json.getString("date")),
                DayKind.valueOf(json.getString("kind")),
            )
        }
    }

    private enum class DayKind(val fullLabel: String, val shortLabel: String, val isRest: Boolean) {
        work("上班日", "班", false),
        rest("休息日", "休", true),
        adjustedWork("调休上班", "调班", false),
        adjustedRest("调休休息", "调休", true),
        leave("请假", "假", false),
    }

    private enum class WidgetSize {
        SMALL,
        MEDIUM,
        LARGE;

        companion object {
            fun fromOptions(options: Bundle): WidgetSize {
                val width = options.getInt(AppWidgetManager.OPTION_APPWIDGET_MIN_WIDTH)
                val height = options.getInt(AppWidgetManager.OPTION_APPWIDGET_MIN_HEIGHT)
                return when {
                    height >= 250 -> LARGE
                    width >= 250 -> MEDIUM
                    else -> SMALL
                }
            }
        }
    }

    private data class WidgetPalette(
        val background: Int,
        val cellBackground: Int,
        val primaryColor: Int,
        val primaryId: Int,
        val secondaryId: Int,
        val workId: Int,
        val restId: Int,
        val adjustedWorkId: Int,
        val adjustedRestId: Int,
        val leaveId: Int,
    ) {
        fun primary(context: Context) = ContextCompat.getColor(context, primaryId)
        fun secondary(context: Context) = ContextCompat.getColor(context, secondaryId)
        fun adjustedRest(context: Context) = ContextCompat.getColor(context, adjustedRestId)
        fun kindColor(context: Context, kind: DayKind) = ContextCompat.getColor(
            context,
            when (kind) {
                DayKind.work -> workId
                DayKind.rest -> restId
                DayKind.adjustedWork -> adjustedWorkId
                DayKind.adjustedRest -> adjustedRestId
                DayKind.leave -> leaveId
            },
        )

        companion object {
            fun resolve(context: Context, preference: String): WidgetPalette {
                val dark = preference == "dark" || (
                    preference == "system" &&
                        context.resources.configuration.uiMode and Configuration.UI_MODE_NIGHT_MASK ==
                        Configuration.UI_MODE_NIGHT_YES
                    )
                val suffix = if (dark) ThemeVariant.DARK else ThemeVariant.LIGHT
                return WidgetPalette(
                    background = if (preference == "system") R.drawable.widget_background else suffix.background,
                    cellBackground = if (preference == "system") R.drawable.widget_cell_background else suffix.cellBackground,
                    primaryColor = ContextCompat.getColor(context, suffix.primary),
                    primaryId = suffix.primary,
                    secondaryId = suffix.secondary,
                    workId = suffix.work,
                    restId = suffix.rest,
                    adjustedWorkId = suffix.adjustedWork,
                    adjustedRestId = suffix.adjustedRest,
                    leaveId = suffix.leave,
                )
            }
        }
    }

    private enum class ThemeVariant(
        val background: Int,
        val cellBackground: Int,
        val primary: Int,
        val secondary: Int,
        val work: Int,
        val rest: Int,
        val adjustedWork: Int,
        val adjustedRest: Int,
        val leave: Int,
    ) {
        LIGHT(
            R.drawable.widget_background_light,
            R.drawable.widget_cell_background_light,
            R.color.widget_text_primary_light,
            R.color.widget_text_secondary_light,
            R.color.widget_work_light,
            R.color.widget_rest_light,
            R.color.widget_adjusted_work_light,
            R.color.widget_adjusted_rest_light,
            R.color.widget_leave_light,
        ),
        DARK(
            R.drawable.widget_background_dark,
            R.drawable.widget_cell_background_dark,
            R.color.widget_text_primary_dark,
            R.color.widget_text_secondary_dark,
            R.color.widget_work_dark,
            R.color.widget_rest_dark,
            R.color.widget_adjusted_work_dark,
            R.color.widget_adjusted_rest_dark,
            R.color.widget_leave_dark,
        ),
    }

    private val String?.label: String
        get() = when (this) {
            "big" -> "大周 · 双休"
            "small" -> "小周 · 周日休"
            else -> "循环班制"
        }

    companion object {
        private const val SNAPSHOT_KEY = "worker_rest_widget_snapshot_v1"
        private val WEEKDAY_LABELS = listOf("一", "二", "三", "四", "五", "六", "日")
        private val DATE_CHANGE_ACTIONS = setOf(
            Intent.ACTION_DATE_CHANGED,
            Intent.ACTION_TIME_CHANGED,
            Intent.ACTION_TIMEZONE_CHANGED,
            Intent.ACTION_BOOT_COMPLETED,
            Intent.ACTION_MY_PACKAGE_REPLACED,
        )
    }
}
