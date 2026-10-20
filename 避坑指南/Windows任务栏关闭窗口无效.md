# Windows 任务栏“关闭窗口”无效

## 表现与根因

桌面摆件仍出现在任务栏中，点击“关闭窗口”没有反应。

`window_manager` 的 Windows 实现通过 `ITaskbarList::DeleteTab` 移除任务栏按钮；后续显示、恢复和激活窗口可能重新添加该按钮。原代码在显示窗口前调用 `setSkipTaskbar`，且控制器直接忽略摆件模式的关闭请求，导致残留按钮无法关闭。

## 解决方法

- 在 `showWidget` 的显示、最小化恢复与激活全部完成后调用 `setSkipTaskbar`。
- 已加载的摆件也响应关闭请求，重新应用摆件配置并清理任务栏按钮；退出过程中忽略关闭请求，避免重新显示窗口。
- 保持产品既定行为：关闭完整窗口返回摆件并驻留托盘，只有托盘“退出”结束进程。

## 验证（2026-10-20）

- 修改文件格式检查通过；`flutter analyze` 无问题。
- 全量单元/组件测试：249 项通过；关闭和窗口服务定向测试：13 项通过。
- `windows_taskbar_close_test.dart`：Windows 原生测试通过，覆盖普通窗口与最小化窗口的 `WM_SYSCOMMAND / SC_CLOSE`、摆件尺寸、窗口可见性与任务栏跳过状态。
- `windows_android_release_flow_test.dart`：原有 Windows 发布流程集成测试通过。
- 两个集成测试单独执行时临时使用各自独立的原生 mutex 和窗口属性名称，避开正在运行的安装版；每次结束均恢复源码标识。批量执行曾出现测试进程交接失败，因此最终分别运行验证。
- Windows Debug 与 Release 构建通过。当前安装版未替换。

全库格式检查另发现原有 `calendar_flow_test.dart` 需要格式化，本次保留其原文。
