# 进度快照 006 · Phase 08 Android 主屏小组件完成，iOS 待开发

## 当前状态

- Phase 00–07 已完成。
- Phase 08 的 Android 部分已完成；因用户本轮明确指定“开发安卓”，iOS WidgetKit 尚未实现，`PROGRESS.md` 未勾选整个 Phase 08。
- `flutter analyze` 0 问题，全量 104 项测试通过。
- Windows Debug 与 Android Debug 已重新构建。
- 本机没有 Android 真机或 AVD，已完成 APK 编译与打包结构验收，真实启动器截图待设备补验。

## 已完成内容

### 1. 共享快照协议

- 新增版本化 `HomeWidgetSnapshot v1` 纯 Dart 协议。
- 默认写入未来 62 天：日期、最终状态、大小周、距下次休息、下次休息日期和本周 7 天状态。
- 默认写入未来 3 个月、每月 42 格周一起始月历。
- 原生端只选择并渲染对应日期，不重新实现基础班制、节假日或手动覆盖算法。
- JSON 往返与未知版本拒绝已有纯 Dart 测试。

### 2. Flutter 同步链路

- 新增 `HomeWidgetService` 接口及 `PluginHomeWidgetService` adapter。
- 快照保存键：`worker_rest_widget_snapshot_v1`。
- Android provider 全限定名：`com.workerrestcalendar.app.WorkerRestHomeWidgetProvider`。
- `HomeWidgetSyncController` watch 共享 `activeScheduleControllerProvider` 和主题状态。
- 以下场景会刷新：首次进入完整应用、排班编辑、主题变化、应用恢复前台、显式刷新。
- Android 以外平台不会调用插件，也不会加载无关排班状态。

### 3. Android 原生 AppWidget

- 使用 Kotlin `HomeWidgetProvider` + `RemoteViews`，不依赖 Flutter 引擎持续运行。
- 单个可缩放小组件按系统尺寸自动切换：
  - 小号：今日状态、距休息天数、大小周/循环标签。
  - 中号：本周七日节奏、大小周标签、下次休息日期。
  - 大号：当前月 6 周月历、今日高亮和状态图例。
- 支持系统/固定浅色/固定暗黑；Android 颜色资源与 Flutter `AppTokens` 状态色一致。
- 使用 24dp 圆角表面、边框和 8dp 日期状态格，信息结构延续桌面参考图方向。
- 无快照时显示“打开应用/完成班制设置后自动同步”的安全空状态。

### 4. 离线跨天与深链

- AppWidget provider 配置 `updatePeriodMillis=1800000`。
- 监听日期变化、系统时间变化、时区变化、开机完成和应用更新广播。
- Flutter 未运行时，原生端从 SharedPreferences 最后快照选择当天条目；可覆盖未来 62 天和未来 3 个月月历。
- 点击小组件整体打开当天；点击中号周日期或大号月历日期打开指定日期。
- 深链格式：`workerrestcalendar://open?date=YYYY-MM-DD`。
- Flutter 冷启动通过 `initiallyLaunchedFromHomeWidget`，热启动通过 `widgetClicked` 接收；`HomePage` 会切换日历并打开日期详情。

## 关键代码前后对比

### 数据同步

修改前：项目已有 `home_widget` 依赖，但没有任何快照写入、刷新或原生实现。

修改后：`HomeWidgetSyncController` 从唯一共享排班状态构建 v1 快照，经 `HomeWidgetService` 保存并广播刷新，编辑和主题变化自动重建。

### Android 主屏

修改前：Manifest 没有 AppWidget receiver，Android 资源中没有 widget 布局和 provider 配置。

修改后：APK 包含 `WorkerRestHomeWidgetProvider`、小/中/大响应式布局、浅暗色资源、30 分钟更新和系统日期广播。

### 点击行为

修改前：完整应用只处理通知日期目标。

修改后：主屏小组件可通过独立 `homeWidgetTargetDateProvider` 传递日期；冷/热启动均打开对应日期详情，不复用通知语义。

## 主要修改文件

- `lib/app/app_startup_page.dart`
- `lib/features/home/presentation/home_page.dart`
- `lib/features/home_widget/application/home_widget_service.dart`
- `lib/features/home_widget/application/home_widget_sync_controller.dart`
- `lib/features/home_widget/data/plugin_home_widget_service.dart`
- `lib/features/home_widget/domain/home_widget_snapshot.dart`
- `lib/features/home_widget/presentation/home_widget_lifecycle_sync.dart`
- `android/app/src/main/AndroidManifest.xml`
- `android/app/src/main/kotlin/com/workerrestcalendar/app/WorkerRestHomeWidgetProvider.kt`
- `android/app/src/main/res/layout/worker_rest_home_widget.xml`
- `android/app/src/main/res/layout/widget_week_day.xml`
- `android/app/src/main/res/layout/widget_calendar_row.xml`
- `android/app/src/main/res/layout/widget_calendar_day.xml`
- `android/app/src/main/res/xml/worker_rest_home_widget_info.xml`
- `android/app/src/main/res/values*/widget_colors.xml`
- `android/app/src/main/res/values/widget_styles.xml`
- `android/app/src/main/res/values/strings.xml`
- `android/app/src/main/res/drawable*/widget_*.xml`
- `test/features/home_widget/**`
- `test/features/home/presentation/today_page_test.dart`
- `PROGRESS.md`、`CHANGELOG.md`

## 验证记录

- `D:\flutter\bin\dart.bat format lib test`：通过，0 个文件待格式化。
- `D:\flutter\bin\flutter.bat analyze`：通过，0 问题。
- `D:\flutter\bin\flutter.bat test -r compact`：通过，104 项。
- `D:\flutter\bin\flutter.bat build windows --debug`：通过。
- `D:\flutter\bin\flutter.bat build apk --debug`：通过。
- `aapt2 dump xmltree/resources`：确认 provider、APPWIDGET_UPDATE、DATE_CHANGED、深链 action、布局和 XML provider 配置均在 APK 中。
- `flutter devices` / `flutter emulators`：无 Android 设备、无可用 AVD。

## 未完成与风险

- Phase 08 的 iOS WidgetKit/SwiftUI 小、中、大组件尚未开发。
- 未在真实 Android Launcher 上完成添加、拖拽缩放、系统暗黑切换和截图验收；代码已编译并完成 APK 结构验收。
- Android 厂商可能延迟 30 分钟周期刷新；日期变化广播可补充跨天刷新，但系统仍有最终调度权。
- 离线快照覆盖未来 62 天与未来 3 个月；超过范围且应用一直未打开时会回退显示最后一个可用日条目，重新打开应用后立即补齐。

## 下一步

1. 若继续完成 Phase 08：在 macOS 构建机开发 iOS WidgetKit/SwiftUI 小、中、大组件，复用同一 v1 JSON 协议。
2. 在 Android 真机或 AVD 上添加小组件，截取小/中/大及浅色/暗黑截图，并验证日期点击。
3. iOS 与 Android 均通过后再勾选 Phase 08，然后进入 Phase 09。
