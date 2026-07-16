# 进度快照 012 · 修复 Windows 低高度月历越界

## 用户反馈

- 用户在约 886×593 的 Windows 外部窗口中打开月历。
- Flutter 实际内容视口约 886×563，月历只显示到第四行，后两行和卡片底边位于窗口下方。
- 首页响应式导航已经生效，本次问题限定在月历的固定日期格高度。

## 根因

- 月视图固定生成 42 个日期，即 7 列×6 行。
- 日期格高度固定为 `44 + 32 = 76px`，6 行加间距约占 476px。
- 页面标题、月/周切换、月份栏和卡片星期标题占用约 200px，低高度 Windows 视口无法同时容纳。

## 修复内容

- 当 CalendarPage 可用宽度至少 700px 且高度低于 700px 时启用低高度桌面模式。
- 页面上下留白从 16/32px 调整为 8px。
- 标题、切换器、月份栏之间使用 8px/4px 紧凑间距。
- 日历卡片内边距和星期标题纵向间距改为 4px。
- 日期格基础高度改为 52px，仍高于 44px 最小点击区域。
- 日期数字、班/休/调/假状态文字、选中边框和今日标记全部保留。
- 正常高度、移动端和 130% 字体逻辑保持原有尺寸；确实不足时页面仍可安全滚动。

## 修改文件

- `lib/features/calendar/presentation/calendar_page.dart`
- `test/features/calendar/presentation/calendar_flow_test.dart`
- `PROGRESS.md`
- `CHANGELOG.md`

## 验证记录

- 新增 886×563 暗黑桌面测试。
- 测试确认 2026 年 7 月月历的最后一个格子（2026-08-09）存在。
- 测试确认第 42 个日期格底边不超过日历卡片底边。
- 测试确认日历卡片底边不超过窗口高度。
- `dart format --output=none --set-exit-if-changed lib test integration_test`：通过。
- `flutter analyze`：0 问题。
- `flutter test -r compact`：112 项全部通过。
- `flutter build windows --release`：通过；`data/app.so` 更新时间 2026-07-13 09:07:48。
- `flutter build apk --release`：通过；60.19 MB。
- 缓存约 4.33 GB，低于 20 GB 上限。

## 用户复验

1. 完全退出旧版 Windows 程序。
2. 从完整 `build/windows/x64/runner/Release` 目录启动。
3. 打开“日历”，保持窗口在最小允许高度。
4. 月视图应完整显示 6 行日期及卡片圆角底边，不再在窗口底部截断。
5. 月/周切换、日期点击、长按编辑和左右切换月份应保持可用。

## 仍存发布阻塞

- Android 真机/AVD、正式签名、Windows 安装包签名及 Apple 端发布工作不受本轮修复影响。
