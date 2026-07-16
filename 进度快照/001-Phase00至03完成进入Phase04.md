# 进度快照 001 · Phase 00–03 完成，准备进入 Phase 04

记录时间：2026-07-13（Asia/Shanghai）

## 已完成内容

- Phase 00：Flutter 四端工程、依赖锁定、严格 lint、CI、三态主题入口、Windows/Android 构建基线。
- Phase 01：纯 Dart 排班领域，支持双休、单休、大小周、六休一、二休二、自定义循环、覆盖优先级、下一休息日和连续工作统计。
- Phase 02：Drift schema v2、v1→v2 迁移与备份、班制/覆盖/节假日/设置/同步队列仓储、版本化 JSON 导入导出核心。
- Phase 03：`AppTokens`、浅色/暗黑主题、统一组件库、组件展示页、130% 字体和 golden 测试。

## 当前模块状态

- 当前应执行：`codex/04_ONBOARDING_PATTERNS.md`。
- 当前应用根页面：组件展示页，仅用于 Phase 03 内部预览。
- 数据库尚未接入应用启动流程；Phase 04 需要接入首次启动状态、active profile 创建和草稿恢复。
- `PROGRESS.md` 已勾选 Phase 00–03，Phase 04 尚未勾选。

## 关键代码前后对比

| 模块 | 蓝图初始状态 | 当前状态 |
| --- | --- | --- |
| Flutter 工程 | 只有 `starter/` 参考 | 根目录拥有 Android/iOS/macOS/Windows 正式工程 |
| 排班计算 | starter 示例规则 | 无时区 `CalendarDate` + 完整纯 Dart `ScheduleEngine` |
| 本地数据 | 无数据库 | Drift schema v2、仓储、迁移、事务与备份 |
| 主题 | 页面内硬编码浅/暗颜色 | `design_tokens.json` 对应 `AppTokens ThemeExtension` |
| 组件 | Flutter 默认控件 | AppCard、三类按钮、分段控件、状态标签、日期胶囊、弹层、Toast、状态视图 |
| 测试 | starter 少量示例 | 全量 52 项通过，包含领域、数据、迁移、组件、golden |

## 固定约定

- 大周：周六、周日休息；小周：周六上班、周日休息。
- 周一为排班周起点。
- 手动覆盖 > 节假日覆盖 > 基础班制。
- 日期在领域和数据库中使用 date-only / `YYYY-MM-DD`。
- UI 颜色、阴影、圆角、间距和动效必须从 `AppTokens` 读取。
- 每次只完成一个 Phase；Phase 04 完成前不得进入首页/日历正式业务实现。

## Phase 04 待办

- 欢迎、班制选择、锚点/起始日、自定义循环、30 天预览、完成流程。
- 大小周明确询问本周大周/小周并保存周一锚点。
- 自定义循环支持 1–56 天且至少一个休息日。
- 草稿持久化，应用中断后恢复。
- 完成后创建 active profile、更新首次启动状态并进入今日占位首页。
- 8 周大小周预览、流程恢复与 Widget 测试。

## 下一步

按必读顺序复核 Phase 04 相关蓝图，规划 onboarding application/domain/data/presentation 边界后实施。
