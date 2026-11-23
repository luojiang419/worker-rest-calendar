# 06 · 数据模型

## schedule_profiles

- `id` UUID
- `name`
- `pattern_type`
- `anchor_date`
- `anchor_week_type` nullable
- `cycle_days_json`
- `holiday_overrides_enabled`
- `is_active`
- `created_at`
- `updated_at`
- `deleted_at` nullable

## day_overrides

- `id` UUID
- `date` YYYY-MM-DD，唯一索引可与 profile 组成复合键
- `profile_id`
- `kind`
- `overtime_minutes`
- `note`
- `source` manual/imported
- `created_at`
- `updated_at`
- `deleted_at` nullable

## holiday_overrides

- `date`
- `kind` adjustedWork/adjustedRest
- `title`
- `region`
- `data_version`
- `updated_at`

## reminder_settings

- `daily_next_day_enabled`
- `daily_next_day_time`
- `adjusted_work_enabled`
- `adjusted_work_lead_days`
- `weekly_preview_enabled`
- `weekly_preview_weekday`
- `weekly_preview_time`
- `countdown_enabled`

## app_settings

- `theme_mode` system/light/dark
- `visual_style`
- `locale`
- `first_launch_completed`
- `desktop_widget_size`
- `desktop_widget_large_date_shape`
- `desktop_widget_today_highlight_style`
- `desktop_widget_opacity`
- `desktop_widget_always_on_top`
- `desktop_widget_locked`
- `desktop_launch_at_startup`
- `calendar_scroll_axis` horizontal/vertical

## sync_queue

- `id`
- `entity_type`
- `entity_id`
- `operation`
- `payload_json`
- `created_at`
- `attempt_count`
- `last_error`

## 日期处理规则

- 数据库中日历日期只保存 `YYYY-MM-DD`，不保存午夜 UTC 时间戳。
- 时间提醒保存本地时分与时区标识。
- UI 进入领域层前先规范化为 date-only 值。
