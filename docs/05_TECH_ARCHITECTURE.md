# 05 · 技术架构

## 1. 总体选择

使用一个 Flutter 仓库覆盖 iOS、Android、macOS、Windows。Flutter 负责业务层、数据层和主要 UI；平台原生代码仅用于主屏小组件、系统通知细节和桌面窗口特性。

## 2. 分层

```text
presentation -> application -> domain <- data
                              <- platform adapters
```

- `presentation`：页面、组件、主题、路由。
- `application`：Riverpod providers、用例编排、状态机。
- `domain`：排班规则、日期状态、统计算法；纯 Dart。
- `data`：Drift 数据库、repository 实现、导入导出、同步队列。
- `platform`：通知、桌面窗口、原生小组件桥接、开机启动。

## 3. 推荐目录

```text
lib/
  app/
  core/
    date/
    errors/
    theme/
    widgets/
  features/
    onboarding/
    schedule/
      domain/
      application/
      data/
      presentation/
    calendar/
    reminders/
    statistics/
    settings/
    sync/
  platform/
    notifications/
    desktop_window/
    home_widgets/
```

## 4. 依赖策略

Phase 00 由 Codex 使用当前 Flutter stable 解析并锁定兼容版本。候选包：

- Riverpod、go_router。
- Drift + SQLite。
- intl、timezone、flutter_local_notifications。
- window_manager。
- home_widget；iOS WidgetKit 与 Android 原生小组件仍需要平台代码。
- Supabase Flutter，仅在启用云同步阶段加入。

每个外部包必须通过一层 adapter 使用，业务层不得直接依赖插件 API。

## 5. 本地优先

- 首屏只读取本地数据库与缓存。
- 所有编辑先本地提交，再异步刷新小组件与通知。
- 云同步失败不阻塞本地使用。
- 数据变更使用 UUID、`updatedAt` 和软删除字段支持冲突处理。

## 6. 错误处理

领域错误使用 sealed 类型，例如：

- `InvalidPattern`
- `MissingAnchorDate`
- `NoRestDayFound`
- `ImportSchemaMismatch`
- `SyncConflict`

UI 将错误映射为可理解文案，不展示堆栈。
