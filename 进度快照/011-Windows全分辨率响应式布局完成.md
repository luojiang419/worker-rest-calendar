# 进度快照 011 · Windows 全分辨率响应式布局完成

## 用户反馈

- Windows 完整窗口约 1086×713 时仍使用手机纵向单列布局。
- 底部导航占用垂直空间，“本月概览”等内容需要向下滚动，视觉上像被隐藏。
- 用户要求所有分辨率下内容完整可达，不能被导航或窗口边界裁切。

## 已完成修改

### 1. 响应式导航

- 完整应用宽度达到 840px 时使用左侧 `NavigationRail`。
- 今天、日历、统计三项均保留文字和选中状态，不只依赖图标。
- 宽度低于 840px 时继续使用移动端底部 `NavigationBar`。
- 两种导航都从设计令牌读取表面色、边框、投影和主色。

### 2. 今日页桌面双列

- TodayPage 根据自身可用宽度判断布局，不依赖平台字符串。
- 内容宽度达到 900px 时：
  - 左列：今日状态、下次休息。
  - 右列：本周节奏、本月概览。
- 截图对应的 1086×680 Flutter 视口中，四块核心内容均在首屏完整显示。
- 页面仍保留统一 ListView，遇到更低窗口高度或更大系统字体时可以纵向滚动，不会裁切。

### 3. 小屏与极窄屏

- 小于 900px 时继续使用单列布局。
- 所有内容处于同一个滚动容器，底部使用设计令牌安全间距。
- 320px 宽度时，本周七天从一行改为四列换行，避免 44px 点击区域互相挤压。
- 320×568、暗黑模式和 130% 字体下，本月概览可滚动到完整显示并位于底部导航上方。

## 关键代码前后对比

### 修改前

- 所有平台都固定使用单列 `ListView`。
- 所有宽度都固定使用底部 `NavigationBar`。
- 本周七天固定在一个 `Row` 中。

### 修改后

- `HomePage` 在 840px 处切换侧边/底部导航。
- `TodayPage` 在 900px 处切换双列/单列内容。
- `WeekRhythmStrip` 在可用宽度小于 360px 时使用四列 `Wrap`。
- 任意高度不足时均通过滚动完整访问，不用缩小字体或隐藏卡片。

## 修改文件

- `lib/features/home/presentation/home_page.dart`
- `lib/features/home/presentation/today_page.dart`
- `lib/features/home/presentation/widgets/week_rhythm_strip.dart`
- `test/features/home/presentation/today_page_test.dart`
- `PROGRESS.md`
- `CHANGELOG.md`

## 验证记录

- 1086×680 桌面用例：NavigationRail 存在，四块核心内容首屏完整可见。
- 320×568 + 130% 字体用例：NavigationBar 存在，全部内容可滚动且本月概览不被遮挡。
- `dart format --output=none --set-exit-if-changed lib test integration_test`：通过，0 文件待格式化。
- `flutter analyze`：0 问题。
- `flutter test -r compact`：111 项全部通过。
- `flutter build windows --release`：通过；`data/app.so` 8.59 MB，更新时间 2026-07-13 09:00:54。
- `flutter build apk --release`：通过；60.19 MB。
- 缓存约 4.33 GB，低于 20 GB 上限。

## 用户复验步骤

1. 完全关闭旧 Windows 程序。
2. 使用完整 `build/windows/x64/runner/Release` 目录启动，不能只复制 EXE。
3. 默认 1100×720 下应看到左侧导航和双列今日页面，四块卡片首屏可见。
4. 缩窄窗口时应自动切换为底部导航和单列；缩短窗口时可滚动到本月概览，内容不会被导航遮挡。
5. 首次设置完成后进入挂件属于独立的挂件模式，仍保持小/中/大固定尺寸。

## 仍存发布阻塞

- Android 真机/AVD、正式签名、Windows 安装包签名及 Apple 端发布工作不受本轮布局修复影响。
