# 进度快照 005 · Phase 07 桌面挂件完成，进入 Phase 08

## 当前状态

- Phase 00–07 已完成，`PROGRESS.md` 已勾选 Phase 07。
- 全量测试 99 项通过，`flutter analyze` 0 问题。
- Windows Debug 与 Android Debug 已重新构建；Windows 可执行文件完成 4 秒冷启动存活冒烟。
- 当前阶段只实现 Windows/macOS 桌面挂件，未提前实现 Phase 08 的 iOS/Android 主屏小组件。

## Phase 07 已完成内容

### 1. 桌面挂件数据

- 新增 `DesktopWidgetSnapshot`，从唯一共享的 `ActiveScheduleState` 生成今日状态、下次休息、本周 7 天和月历 42 天数据。
- 挂件直接 watch `activeScheduleControllerProvider`，手动覆盖或排班重载后自动刷新，不复制第二套排班算法。

### 2. 三种参考图布局

- 小号 `180×220`：今日状态、距离下次休息天数、下次休息日期。
- 中号 `360×220`：大小周/循环班制说明、周一至周日七天节奏和状态图例。
- 大号 `420×360`：周一起始的 6 周月历、今日高亮、工作/休息/调休/请假图例。
- 大号点击任意日期会打开完整应用并进入该日期详情。
- 浅色、暗黑模式均读取 `AppTokens`，已验证 130% 字体无溢出。

### 3. 桌面窗口与交互

- 新增 `DesktopWindowService` 接口及 `window_manager` 实现，平台判断集中在 adapter/bootstrap。
- 桌面端首次设置完成后默认显示无边框透明挂件；双击打开完整应用，完整应用可返回挂件。
- 支持拖动、锁定、窗口置顶、70%/80%/90%/100% 透明度和小/中/大尺寸切换。
- 使用 `screen_retriever` 按显示器 ID 保存位置，并在冷启动时校验显示器可见区域后恢复。
- 右键菜单包含尺寸、锁定、置顶、透明度、主题、开机启动、完整应用和退出。
- Windows 开机启动通过当前用户启动项实现；macOS 13+ 通过 `SMAppService.mainApp` 原生通道实现。

### 4. 持久化与迁移

- `AppPreferences` 新增 `desktopLaunchAtStartup`。
- Drift schema 从 v2 升级到 v3，提供 v2→v3 增列迁移，v1→最新版本路径仍通过测试。
- 设置仓储和备份 JSON 编解码已同步；旧备份缺少该字段时默认关闭。
- 主题选择会同步更新桌面挂件和完整应用。

## 关键代码前后对比

### 应用启动

修改前：`main()` 直接 `runApp`，首次设置完成后所有平台都进入 `HomePage`。

修改后：桌面平台先执行 `bootstrapDesktopWindow()` 配置透明无边框窗口；首次设置完成后 Windows/macOS 进入 `DesktopWidgetShell`，移动端仍进入 `HomePage`。

### 桌面设置

修改前：数据库已有尺寸、透明度、置顶、锁定字段，但没有桌面实现，也没有开机启动字段。

修改后：设置由 `DesktopWidgetController` 统一保存并立即调用 `DesktopWindowService`；schema v3 新增开机启动字段，右键操作与下次启动保持一致。

### 排班刷新

修改前：桌面挂件不存在。

修改后：挂件快照直接由 `ActiveScheduleState` 构建；日历编辑完成后共享 controller 更新，挂件随 Riverpod 状态自动重建。

## 主要修改文件

- `lib/main.dart`
- `lib/app/app_startup_page.dart`
- `lib/features/desktop_widget/application/desktop_widget_controller.dart`
- `lib/features/desktop_widget/application/desktop_window_service.dart`
- `lib/features/desktop_widget/data/desktop_window_bootstrap.dart`
- `lib/features/desktop_widget/data/desktop_window_position_store.dart`
- `lib/features/desktop_widget/data/window_manager_desktop_window_service.dart`
- `lib/features/desktop_widget/domain/desktop_widget_snapshot.dart`
- `lib/features/desktop_widget/presentation/desktop_widget_card.dart`
- `lib/features/desktop_widget/presentation/desktop_widget_shell.dart`
- `lib/features/home/presentation/home_page.dart`
- `lib/features/settings/domain/app_preferences.dart`
- `lib/features/settings/data/drift_settings_repository.dart`
- `lib/features/sync/data/backup_codec.dart`
- `lib/core/database/tables.dart`
- `lib/core/database/app_database.dart`
- `lib/core/database/app_database.g.dart`
- `macos/Runner/MainFlutterWindow.swift`
- `pubspec.yaml`、`pubspec.lock`
- `test/features/desktop_widget/**`
- `test/core/database/app_database_test.dart`
- `test/features/settings/data/drift_settings_repository_test.dart`
- `test/app_test.dart`
- `PROGRESS.md`、`CHANGELOG.md`

## 验证记录

- `D:\flutter\bin\dart.bat format lib test`：通过，0 个待格式化文件。
- `D:\flutter\bin\flutter.bat analyze`：通过，0 问题。
- `D:\flutter\bin\flutter.bat test -r compact`：通过，99 项。
- `D:\flutter\bin\flutter.bat build windows --debug`：通过。
- `D:\flutter\bin\flutter.bat build apk --debug`：通过。
- Windows Debug 可执行文件冷启动 4 秒保持运行：通过。

## 平台限制与风险

- 当前 Windows 环境无法执行 macOS 实机构建；Swift 原生通道需在 macOS 13+ 构建机补做编译、登录项授权和多显示器拖动验收。
- macOS 12 及更低版本的开机启动会返回明确不支持错误；其余桌面挂件能力仍由 `window_manager` 支持。
- 自动化测试覆盖窗口控制调用顺序和 UI 布局，但真实多显示器拔插、不同 DPI 混排仍需 Phase 10 做人工矩阵验收。

## 下一步（Phase 08）

1. 按根目录 `AGENTS.md` 顺序重新读取必读文档和 `codex/08_MOBILE_WIDGET.md`。
2. 只实现 iOS/Android 主屏小组件，不返工 Phase 00–07。
3. 复用当前共享排班快照/刷新链路，原生端只消费序列化后的最小数据。
4. 完成 Phase 08 后继续执行格式化、静态检查、全量测试与可用平台构建。
