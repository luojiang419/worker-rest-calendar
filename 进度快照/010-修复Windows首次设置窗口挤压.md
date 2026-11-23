# 进度快照 010 · 修复 Windows 首次设置窗口挤压

## 问题现象

- 用户提供的 Windows 截图显示“选择你的班制”页面被压在约 180×220 的窗口内。
- 标题被迫换行、班制列表不可见，只剩底部“下一步”按钮。
- 这不是页面本身的自适应缺陷，而是完整应用错误使用了小号桌面挂件窗口尺寸。

## 根因

- `bootstrapDesktopWindow()` 在读取首次设置状态前，无条件使用 `DesktopWidgetSize.small` 对应的 180×220 启动窗口。
- 首次设置未完成时，路由会显示完整 onboarding 页面，但窗口没有切换到完整应用尺寸。
- `showFullApp()` 也没有在 Windows 恢复原生标题栏。

## 已完成修改

### Windows 启动策略

- Windows 默认以 1100×720 启动完整应用。
- Windows 完整应用最小尺寸为 900×600，并允许用户缩放。
- Windows 完整应用使用原生标题栏，标题为“打工人休息日历”。
- Windows 首次启动居中，不再套用可能位于屏幕边缘的挂件坐标。

### 挂件模式保持

- 首次设置完成并进入 `DesktopWidgetShell` 后，控制器仍按保存设置缩到小/中/大挂件。
- Windows 切换为挂件时恢复保存的显示器位置。
- 返回完整应用时恢复 1100×720、最小 900×600、原生标题栏并居中。
- macOS bootstrap 分支保持原有 180×220 隐藏标题栏和位置恢复行为，不修改 Mac 开发线。

## 关键代码前后对比

### 修改前

```dart
WindowOptions(
  size: desktopWidgetWindowSize(DesktopWidgetSize.small),
  titleBarStyle: TitleBarStyle.hidden,
)
```

### 修改后

```dart
WindowOptions(
  size: isWindows ? const Size(1100, 720) : const Size(180, 220),
  minimumSize: isWindows ? const Size(900, 600) : null,
  titleBarStyle: isWindows ? TitleBarStyle.normal : TitleBarStyle.hidden,
)
```

## 修改文件

- `lib/features/desktop_widget/application/desktop_window_service.dart`
- `lib/features/desktop_widget/data/desktop_window_bootstrap.dart`
- `lib/features/desktop_widget/data/window_manager_desktop_window_service.dart`
- `test/features/desktop_widget/data/desktop_window_bootstrap_test.dart`
- `PROGRESS.md`
- `CHANGELOG.md`

## 验证结果

- Windows 启动参数测试：2 项通过。
- 桌面挂件控制器回归测试：1 项通过。
- `dart format --output=none --set-exit-if-changed lib test integration_test`：通过。
- `flutter analyze`：0 问题。
- `flutter test -r compact`：109 项全部通过。
- `flutter build windows --release`：通过，`data/app.so` 更新时间为 2026-07-13 08:51:37。
- `flutter build apk --release`：通过，60.12 MB。
- 缓存约 4.33 GB，低于 20 GB 上限。

## 待用户复验

1. 关闭当前正在运行的旧版程序。
2. 从 `build/windows/x64/runner/Release/worker_rest_calendar.exe` 重新启动完整 Release 目录。
3. 首次设置页面应以居中的完整窗口显示，班制卡片列表可滚动，窗口可缩放并具有 Windows 原生标题栏。
4. 首次设置完成后，应用应自动切换到桌面挂件尺寸；双击挂件应重新打开完整窗口。

## 仍存发布阻塞

- Android 真机/AVD、正式签名、Windows 安装包签名及 Apple 端发布工作不受本次修复影响，仍按快照 009 的清单执行。
