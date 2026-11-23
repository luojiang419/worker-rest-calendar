# 进度快照 007 · Windows/Android 职责边界确认，准备 Phase 09

## 当前状态

- Phase 00–07 已完成。
- Phase 08 Android 主屏小组件已完成：共享快照、原生小/中/大布局、浅暗色、离线跨天和日期深链均已实现。
- iOS/macOS 明确由用户在 Mac 端独立开发；当前 Windows 任务不再创建或修改 WidgetKit、App Group、Xcode target、Podfile 或 Apple 签名配置。
- 本轮曾开始接入 iOS，但在用户明确职责边界后，所有本轮 iOS 新增和 Xcode 工程修改均已完整撤回。
- Flutter adapter 已恢复为仅在 Android 平台启用主屏小组件插件。
- 当前基线仍为全量 104 项测试、`flutter analyze` 0 问题、Windows/Android Debug 构建通过。

## 职责边界

### 当前 Windows 任务负责

- Flutter 共享业务、Windows 桌面版本。
- Android 完整应用与 Android AppWidget。
- 可在 Windows 环境执行的测试、静态检查、Windows 构建与 Android 构建。
- Phase 09 及后续中与 Windows/Android 相关的功能。

### Mac 端独立负责

- macOS 特有代码与实际构建。
- iOS WidgetKit、App Group、Xcode Extension target 和 Apple 签名。
- iOS/macOS 模拟器、真机和发布验收。

## 撤回确认

- `PluginHomeWidgetService.isSupported` 已恢复为仅 Android。
- 未保留 `ios/Podfile`。
- 未保留 `ios/Runner/Runner.entitlements`。
- 未保留 `ios/WorkerRestHomeWidget/*`。
- `ios/Runner/Info.plist` 未保留本轮新增 URL Scheme。
- `ios/Runner.xcodeproj/project.pbxproj` 未保留 Widget Extension target、App Group 或 iOS 14 修改。
- 未保留 iOS Widget 工程测试。
- Xcode project 静态花括号数量恢复一致，未残留本轮自定义对象 ID。

## 下一步

1. 当前 Windows/Android 开发线读取 `codex/09_SYNC_EXPORT_IMPORT.md`。
2. 只实现 Phase 09，不触碰 Mac 端负责的 iOS/macOS 专属工程。
3. Phase 09 完成后继续格式化、静态检查、全量测试、Windows/Android 构建和递增快照。
