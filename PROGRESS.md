# 项目进度

- [x] Phase 00：仓库初始化与依赖锁定
- [x] Phase 01：排班引擎与测试
- [x] Phase 02：本地数据库与仓储层
- [x] Phase 03：设计系统、浅色与暗黑模式
- [x] Phase 04：首次设置与班制模板
- [x] Phase 05：首页、日历与日期编辑
- [x] Phase 06：提醒与统计
- [x] Phase 07：Windows/macOS 桌面挂件
- [ ] Phase 08：iOS/Android 主屏小组件（Android 已完成；iOS/macOS 由 Mac 端独立开发）
- [x] Phase 09：导入导出与可选云同步
- [ ] Phase 10：集成测试、可访问性、打包发布（Windows/Android 自动化与 Release 编译已完成；人工验收、正式签名及 Apple 端待完成）
- [x] Phase 11：精致桌面摆件套件（排班、时钟、记事本、专注计时）
- [ ] Phase 12：桌面信息摆件扩展（代码、静态分析、244 项测试与 Windows 原生编译已完成；运行时集成测试需先退出当前已安装的单实例应用）

## 当前阻塞

Windows 首次设置、响应式布局、低高度月历、2026 中国法定节假日离线数据和未签名安装包均已完成，Windows/Android 代码与自动化无阻塞。发布仍需 Android 真机/AVD 验收小组件、通知和系统文件选择器，提供 Android 正式 keystore，并完成 Windows 安装包签名及干净环境安装、覆盖、卸载验收。iOS/macOS 由 Mac 端独立开发，不在当前 Windows 任务修改。

Phase 12 新增倒数日、待办、月相、系统状态、天气和拟物圆钟。Windows Debug 原生构建已通过；由于当前已安装版正在运行且应用强制单实例，Flutter 集成测试无法建立调试连接，待用户退出托盘常驻进程后复跑。
