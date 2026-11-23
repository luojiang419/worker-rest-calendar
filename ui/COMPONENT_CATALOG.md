# UI 控件与模块目录

## 基础控件

- `AppPrimaryButton`
- `AppSecondaryButton`
- `AppDangerButton`
- `AppIconButton`
- `AppSegmentedControl`
- `AppSwitchTile`
- `AppStatusChip`
- `AppDatePill`
- `AppCard`
- `AppBottomSheet`
- `AppToast`
- `AppEmptyState`
- `AppErrorState`
- `AppSkeleton`

## 业务组件

- `TodayStatusCard`
- `NextRestCountdownCard`
- `WeekRhythmStrip`
- `MonthSummaryCard`
- `CalendarDayCell`
- `WeekTypeBadge`
- `ScheduleTemplateCard`
- `CycleDayEditor`
- `DayEditorSheet`
- `DesktopWidgetSmall/Medium/Large`

## 状态语义

所有业务组件接收 `DayPresentation`，不要在组件内部重新计算排班：

```text
DayPresentation {
  date
  plannedKind
  effectiveKind
  label
  shortLabel
  weekType?
  overtimeMinutes
  note?
}
```
