# Phase 00 · 环境与依赖基线

记录日期：2026-07-12（Asia/Shanghai）

## 工具链

- Flutter：3.38.8 stable
- Dart：3.10.7
- DevTools：2.51.1
- Windows：10 22H2，64 位
- Android SDK：36.0.0，platform android-36，build-tools 36.0.0
- Java：OpenJDK 17.0.18
- Visual Studio Build Tools：2022 17.14.27
- Windows SDK：10.0.26100.0
- Visual C++ ATL/MFC：Phase 00 构建时补装
- Android NDK：28.2.13676358（Phase 00 构建时补装）
- Android CMake：3.22.1（Phase 00 构建时补装）

## 平台验证范围

- Android 工具链可用，licenses 已接受。
- Windows 桌面工具链可用。
- 当前主机为 Windows，无法安装或执行 Xcode、CocoaPods，也无法在本机编译 iOS/macOS。两个平台工程目录在 Phase 00 生成，实际构建留待 macOS 构建机补验。
- `D:\flutter\bin` 未加入系统 PATH；项目命令显式使用 `D:\flutter\bin\flutter.bat`，不影响构建。

## 应用标识

- Dart package：`worker_rest_calendar`
- Android/iOS/macOS bundle id：`com.workerrestcalendar.app`

依赖精确版本以根目录 `pubspec.lock` 为准。

## 直接依赖锁定结果

- `flutter_riverpod` 3.3.1、`go_router` 17.3.0
- `drift` / `drift_dev` 2.31.0、`build_runner` 2.7.1
- `flutter_local_notifications` 22.0.1、`timezone` 0.11.1
- `window_manager` 0.5.2、`home_widget` 0.9.3
- `shared_preferences` 2.5.5、`path_provider` 2.1.6
- `intl` 0.20.2、`uuid` 4.5.3
- `flutter_lints` 6.0.0

最新 Riverpod/Drift 开发工具链要求高于 Dart 3.10.7 的 SDK/Analyzer 组合，因此锁定到上述可解析版本。Phase 02 使用 `sqlite3` 2.9.4 与 `sqlite3_flutter_libs` 0.5.41；当前 SDK 无法与 Drift 2.31 的代码生成器一起升级到 sqlite3 3.x native assets。`build_runner` 锁定 2.7.1，以兼容项目中平台插件的 build hook。
