# Phase 00 · 仓库初始化

## 目标

创建可在 iOS、Android、macOS、Windows 编译的 Flutter 工程，建立 feature-first 目录、主题入口、CI 基础和依赖锁定。

## 任务

- 检查本机 Flutter stable、Dart、Xcode、Android SDK、Visual Studio、CocoaPods 环境。
- 以 `starter/` 为参考初始化实际 Flutter 项目。
- 根据当前环境添加 Riverpod、go_router、Drift、通知、timezone、window_manager、home_widget 等依赖并生成 lockfile。
- 建立 `lib/core`、`lib/features`、`lib/platform` 目录。
- 配置严格 lint、测试目录和 CI 命令。
- 应用可显示占位首页，并能切换浅色/暗黑/跟随系统。

## 退出条件

- 四个平台目录存在。
- `flutter analyze` 通过。
- 基础测试通过。
- 记录实际 Flutter/Dart 与依赖版本。
