# 进度快照 009 · Phase 10 Windows/Android 自动化完成，待人工发布验收

## 当前状态

- Phase 00–07、Phase 09 已完成。
- Phase 08 Android 代码已完成，iOS 主屏小组件由用户在 Mac 端独立开发。
- Phase 10 的 Windows/Android 代码、自动化测试和 Release 编译已完成。
- Phase 10 总项未勾选，因为 Android 真机验收、正式签名、Windows 安装包签名和 Apple 端 QA 尚未完成。
- 本轮没有新增或修改 iOS/macOS 专属工程代码。

## 本轮完成内容

### 1. 发布关键流程集成测试

- 新增 `integration_test/windows_android_release_flow_test.dart`。
- 使用真实 Drift 内存数据库和 Riverpod 跨模块状态机。
- 流程覆盖：首次设置大小周→本周设为小周→校验周六工作/周日休息→周六改为调休休息→Android 小组件快照刷新→提醒重排→导出→清空→导入恢复。
- Windows 桌面测试宿主实际启动并通过 1 项集成测试。

### 2. 隐私与错误恢复

- 新增根目录 `PRIVACY.md`，说明本地数据、网络、权限、用户控制和安全边界。
- 数据管理页面增加可见隐私说明，并使用设计令牌同步支持浅色/暗黑模式。
- 将操作结果 live region 移到列表顶部，修复卡片增加后“备份已保存”反馈在小屏中未构建的问题。
- 保留既有恢复机制：首次设置草稿恢复、启动错误重试、导入事务回滚、清空二次确认。

### 3. 发布资料与元数据

- 新增 `docs/13_WINDOWS_ANDROID_RELEASE.md`。
- 清单覆盖自动化门槛、Windows/Android 人工验收、截图资产、签名和当前发布阻塞。
- Windows `Runner.rc` 的产品名和文件说明改为“打工人休息日历”。
- Android 仍使用现有 debug 签名 Release 配置，仅用于内部 QA；没有把 keystore 或密码写入仓库。

### 4. 审计结果

- 业务代码无 `print`、`debugPrint` 或日志输出备注/令牌/完整 payload。
- 未发现密钥、密码或服务端 URL。
- 颜色扫描仅命中设计令牌、透明背景及主色圆点上的白色对比文字，无页面浅色背景写死。
- 测试中已有 50 处小屏、暗黑、字体缩放或语义相关覆盖。
- Apple 临时代码残留扫描结果为 `none`。

## 主要修改文件

- `pubspec.yaml`、`pubspec.lock`
- `integration_test/windows_android_release_flow_test.dart`
- `lib/features/sync/presentation/data_management_page.dart`
- `test/features/sync/presentation/data_management_page_test.dart`
- `windows/runner/Runner.rc`
- `PRIVACY.md`
- `docs/13_WINDOWS_ANDROID_RELEASE.md`
- `PROGRESS.md`、`CHANGELOG.md`

## 关键代码前后对比

### 测试

- 修改前：只有单元和 Widget 测试，没有 `integration_test` 目录。
- 修改后：有 1 条跨 onboarding、schedule、reminder、home widget、sync 的 Windows 集成流程。

### 隐私反馈

- 修改前：数据管理页仅解释备份和云同步，操作结果位于长列表底部。
- 修改后：页面顶部显示 live-region 操作结果，并新增本地存储与不联网隐私说明。

### Windows 元数据

- 修改前：文件说明和产品名为 `worker_rest_calendar`。
- 修改后：文件说明和产品名为“打工人休息日历”。

## 最终验证记录

- `dart format --output=none --set-exit-if-changed lib test integration_test`：通过，0 文件待格式化。
- `flutter analyze`：通过，0 问题。
- `flutter test -r compact`：通过，107 项。
- `flutter test integration_test/windows_android_release_flow_test.dart -d windows -r compact`：通过，1 项。
- `flutter build windows --release`：通过。
- `flutter build apk --release`：通过，60.12 MB。
- `flutter build appbundle --release`：通过，46.11 MB。
- 构建与 Dart 缓存合计约 4.33 GB，低于 20 GB 上限。

## 当前发布阻塞

1. 当前主机没有 Android 真机或 AVD，无法验收三尺寸主屏小组件、通知权限/点击、跨天刷新和系统文件选择器。
2. Android APK/AAB 使用 debug 签名，只能内部 QA，不能上传商店。
3. Windows 仅生成便携 Release 目录，尚未生成并签名安装包。
4. Windows 100%/125%/150% 显示缩放和未安装 Flutter 的干净机器仍需人工验收。
5. 商店浅色/暗黑截图尚未在真实设备环境补齐。
6. iOS/macOS QA、签名和发布由用户在 Mac 端处理。

## 下一步

- 若继续当前 Windows/Android 开发线，应先准备 Android 真机或创建 AVD，按 `docs/13_WINDOWS_ANDROID_RELEASE.md` 完成人工验收。
- 用户提供 Android 正式签名配置后，再生成可上架 AAB；签名材料不得进入仓库。
- 选择 Windows 安装包方案并提供代码签名证书后，完成安装、升级和卸载验收。
- 与 Mac 端合并 Apple 平台成果后，再统一勾选 Phase 08 和 Phase 10。
