# Phase 01 · 排班引擎

## 目标

用纯 Dart 完成日期状态计算，不接数据库和复杂 UI。

## 任务

- 实现 DayKind、WeekType、SchedulePattern、DayOverride、ResolvedDay。
- 实现双休、单休、大小周、做六休一、做二休二、自定义循环。
- 实现数学 floor division 和正规范化取模。
- 实现覆盖优先级、下一休息日、连续工作天数。
- 按 `docs/03_SCHEDULE_ENGINE.md` 编写完整单元测试。

## 退出条件

- 大周周六休息；小周周六工作；周日均休息。
- 锚点前后、跨年、闰年测试通过。
- 领域模块不依赖 Flutter、数据库或插件。
