# 自动更新与发布契约

## 当前固定项

- 平台：Windows x64。
- 正式版本：三段 SemVer，标签为 `vMAJOR.MINOR.PATCH`。
- 当前版本来源：云端发布任务计算的 `VERSION`；同一值注入 Flutter build name、Inno Setup、标签和资产名。Windows 文件 `ProductVersion` 按 Flutter 规则显示为 `{VERSION}+{buildNumber}`，客户端比较只使用 `VERSION`。
- 公开源码与 Release 仓库：`luojiang419/worker-rest-calendar`。
- Latest API：`https://api.github.com/repos/luojiang419/worker-rest-calendar/releases/latest`。
- 安装包：`worker-rest-calendar-Setup-Windows-x64-v{version}.exe`。
- 校验文件：安装包文件名追加 `.sha256`，内容为安装包 SHA-256 和文件名。
- 安装范围：当前用户的 `%LOCALAPPDATA%\\Programs\\工作日历`，无需管理员权限。
- 静默参数：Inno Setup `/SP- /VERYSILENT /SUPPRESSMSGBOXES /NORESTART /NOCANCEL /CLOSEAPPLICATIONS /FORCECLOSEAPPLICATIONS /DIR=... /LOG=...`。
- 完整性：客户端必须同时验证 Release 声明大小和 `.sha256`；不精确、不唯一、空地址、零大小或摘要不一致时拒绝安装。
- 签名：当前无 Authenticode 证书，CI 明确记录 `NotSigned`，不会将其描述为公共可信安装包。

## 远端策略

用户已确认使用公开仓库。当前本地仓库尚无 Git remote；实现和本地测试通过后创建 `luojiang419/worker-rest-calendar`，源码、Actions 与公开 Release 使用同一仓库。客户端不得内置 GitHub 令牌。

## 首次真实升级顺序

1. 云端发布首个具备更新能力的版本。
2. 用该云端安装包覆盖本机现有无更新能力版本。
3. 云端发布更高补丁版本。
4. 由已安装客户端通过 Latest API 检测、下载、校验、提示、静默覆盖并重启。
5. 验证新版运行时版本、安装器版本、标签、资产和提交完全一致。
