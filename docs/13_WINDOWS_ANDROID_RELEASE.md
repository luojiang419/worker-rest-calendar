# Windows / Android 发布验收清单

## 当前发布范围

- 当前 Windows 开发环境只负责共享 Flutter、Windows 和 Android。
- iOS/macOS 由 Mac 端独立开发和签名，本清单不宣称 Apple 平台已验收。

## 自动化门槛

- [x] `dart format --output=none --set-exit-if-changed lib test integration_test`
- [x] `flutter analyze`
- [x] `flutter test`（202 项）
- [x] `flutter test integration_test -d windows`（1 项关键流程）
- [x] `flutter build windows --release`
- [x] `flutter build apk --release`
- [x] `flutter build appbundle --release`
- [x] Inno Setup 6 编译 Windows 安装程序

## Windows 人工验收

- [ ] 100%、125%、150% 显示缩放下，首次设置、今日、日历、统计和数据管理可用。
- [ ] 小、中、大桌面挂件均可拖动、锁定、置顶并恢复位置。
- [ ] 从本地 1080p 切换到远程 2K 并返回后，桌面摆件保持对应边缘距离或中间比例位置。
- [ ] 跟随系统、浅色、暗黑与 5 种视觉风格组合切换正确。
- [ ] 系统文件面板可完成导出和导入。
- [ ] 便携 Release 目录在一台未安装 Flutter 的 Windows 机器启动成功。
- [x] 生成未签名 Windows 安装包。
- [ ] 在干净 Windows 环境完成安装、卸载与覆盖安装测试。

## Android 人工验收

- [ ] 在至少一台 Android 真机或 AVD 完成首次设置和日期编辑。
- [ ] 小、中、大主屏小组件在浅色和暗黑桌面正确渲染。
- [ ] 修改排班、切换主题、跨天和重启后小组件刷新正确。
- [ ] 小组件日期和通知点击可打开对应日期。
- [ ] 通知授权、拒绝、系统关闭和开机恢复流程正确。
- [ ] 系统文件选择器可导出、清空、导入并恢复数据。
- [ ] 390dp 小屏和 130% 字体下无核心信息截断。

## 商店资产

- [x] 应用图标：Android launcher 各密度、Windows ICO。
- [ ] 浅色截图：今日、月历、首次设置、数据管理、三尺寸小组件。
- [ ] 暗黑截图：今日、月历、统计、三尺寸小组件。
- [ ] 简短说明、完整说明、版本说明和 `PRIVACY.md` 公网地址。
- [ ] Android 正式 keystore、alias 和密码通过本机安全配置提供，不进入仓库。
- [ ] Windows 安装包签名证书通过安全构建环境提供，不进入仓库。

## 当前已知发布阻塞

- 当前 Windows 主机没有 Android 真机或 AVD，Android 小组件、通知和系统文件选择器尚未完成人工验收。
- Android Gradle 当前 Release 构建使用 debug 签名，仅用于编译与内部 QA，不能上传商店。
- Windows 已生成 Inno Setup 安装包，但尚未完成代码签名和干净环境安装、覆盖、卸载验收。
- 商店截图需要在真实 Windows 缩放环境及 Android 启动器中补拍。

## 0.1.10+11 构建记录（2026-07-14）

### 版本与验证

- Flutter/Windows 文件版本：`0.1.10+11`。
- Windows 安装器：`0.1.10.0`。
- `dart format --output=none --set-exit-if-changed lib test integration_test`：170 个文件通过。
- `flutter analyze`：0 问题。
- `flutter test -r compact`：202 项通过。
- Windows 集成关键流程：1 项通过。
- Windows Release 与 Inno Setup 安装程序编译成功。
- 回归覆盖大小周中当前大周、手动排班覆盖、当天休息及首页实际文案；大周周二到周六显示“再上 3 天班”。

### 产物与 SHA-256

| 产物 | 字节数 | SHA-256 |
| --- | ---: | --- |
| `build/windows/x64/runner/Release/worker_rest_calendar.exe` | 167936 | `A17C4F3CE223F327FAD0F66C2793C4E68E92BAE9841A469BA7EECF90B37F2EE0` |
| `build/windows/x64/runner/Release/data/app.so` | 9274288 | `2A14CA22A103AD032393F8522D8805FEB3F464C80CE28A8ACC9FDD6D79C1001C` |
| `build/installer/工作日历-Setup-0.1.10.exe` | 12072585 | `8C36DFF52DAC37E161970F1777FC6FC00FC195D24BAA5E257431AADF95ECB548` |

### 签名与缓存

- Windows 主程序与安装程序的 Authenticode 状态均为 `NotSigned`。
- `.dart_tool` 与 `build` 合计约 6.10 GB，低于 20 GB 上限。

## 0.1.9+10 构建记录（2026-07-14）

### 版本与验证

- Flutter/Windows 文件版本：`0.1.9+10`。
- Windows 安装器：`0.1.9.0`。
- `dart format --output=none --set-exit-if-changed lib test integration_test`：169 个文件通过。
- `flutter analyze`：0 问题。
- `flutter test -r compact`：198 项通过。
- Windows 集成关键流程：1 项通过。
- Windows Release 与 Inno Setup 安装程序编译成功。
- 自动化覆盖 1080p→2K→1080p、远程虚拟显示器接入/断开、四角边距、中间比例、任务栏工作区和主窗口位置隔离。
- 真实桌面截图验收受当前 Windows 图形捕获接口 `0x80004002` 阻断，未勾选真实远程软件验收项；不得以自动化模拟替代该人工结论。

### 产物与 SHA-256

| 产物 | 字节数 | SHA-256 |
| --- | ---: | --- |
| `build/windows/x64/runner/Release/worker_rest_calendar.exe` | 167936 | `A9E9454A801D5817168C26B0B7556F62603D79ADB0F024F4E1467B120482401E` |
| `build/windows/x64/runner/Release/data/app.so` | 9274288 | `57C0410AD0E63C5230006D6E52049F4865D9DEE076B73F8D5CF290C12E46D7E8` |
| `build/installer/工作日历-Setup-0.1.9.exe` | 12072585 | `3BB9689CB67417B428F592AE068FF11C7A1560665FD519D9A6B624569890D082` |

### 签名与缓存

- Windows 主程序与安装程序的 Authenticode 状态均为 `NotSigned`。
- `.dart_tool` 与 `build` 合计约 6.40 GB，低于 20 GB 上限。

## 0.1.1+2 构建记录（2026-07-13）

### 版本与验证

- Flutter/Windows 文件版本：`0.1.1+2`。
- Android：`versionName=0.1.1`，`versionCode=2`，`minSdk=24`，`targetSdk=36`。
- Windows 安装器：`0.1.1.0`。
- `dart format --output=none --set-exit-if-changed lib test integration_test`：通过。
- `flutter analyze`：0 问题。
- `flutter test -r compact`：122 项通过。
- Windows 集成关键流程：1 项通过。

### 产物与 SHA-256

| 产物 | 字节数 | SHA-256 |
| --- | ---: | --- |
| `build/windows/x64/runner/Release/worker_rest_calendar.exe` | 117760 | `89DCD41FB2C6354FF5BDFAEFA9CA543DFBA3C806254789411F1F0D14FA68FB86` |
| `build/windows/x64/runner/Release/data/app.so` | 9110448 | `9AB23F6CEC0F126F4E4C322A259CEA8D7C5F119B4739C3D017D5779FC3281A4F` |
| `build/installer/工作日历-Setup-0.1.1.exe` | 12017631 | `11CC3EF5860E0A94C820408CAF27078F3D3DB08B9C23D75E3F389E63E951396E` |
| `build/app/outputs/flutter-apk/app-release.apk` | 63400432 | `72C5A146D5EEDDCD897FC57901CAA66FB8103DEE5C4C823850106053E4C001F0` |
| `build/app/outputs/bundle/release/app-release.aab` | 48599273 | `351414C45B070CD00BA7AAAD0846EFD878CC5A3BBB72700E95164CA0949D2524` |

### 签名与缓存

- APK 签名证书：`C=US, O=Android, CN=Android Debug`，仅用于内部 QA。
- Windows 主程序与安装程序的 Authenticode 状态均为 `NotSigned`。
- `.dart_tool` 约 1.15 GB，`build` 约 3.84 GB，合计约 4.99 GB，低于 20 GB 上限。
