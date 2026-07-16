# 进度快照 008 · Phase 09 数据迁移完成，进入 Phase 10

## 当前状态

- Windows/Android 开发线已完成 Phase 00–07、Phase 08 Android 部分和 Phase 09。
- iOS/macOS 由用户在 Mac 端独立开发，当前任务未修改其专属工程。
- `PROGRESS.md` 已勾选 Phase 09。
- `flutter analyze` 0 问题，全量 107 项测试通过。
- Windows Debug 与 Android Debug 已重新构建成功。

## Phase 09 完成内容

### 1. 系统文件 adapter

- 新增 Flutter 官方 `file_selector 1.1.0`。
- `BackupFileGateway` 隔离业务层和插件 API。
- Windows/Android 使用系统文件打开与保存界面。
- 导出文件名格式：`worker-rest-calendar-yyyyMMdd-HHmm.json`。
- 文件类型限制为 JSON，Android 使用系统 SAF，不增加宽泛存储权限。

### 2. 数据管理状态机与界面

- 新增 `DataManagementController` 和 `DataManagementPage`。
- 今日首页右上角新增“数据与同步”入口。
- 支持导出、选择导入、预览、确认导入、取消和清空数据。
- 预览显示新增、覆盖、冲突和设置变更数量。
- 页面使用设计令牌，支持暗黑模式、390px 和 130% 字体。
- 操作结果通过可访问性 live region 文案反馈。

### 3. 事务导入与冲突

- 继续使用版本化 `BackupBundle.currentSchemaVersion = 1.0.0`。
- 保留 5MB 输入上限、字段类型校验和 schema 校验。
- 导入在 Drift transaction 内完成，任一写入失败会整体回滚。
- profile 和 override 使用更新时间优先策略。
- 同日期不同 UUID：传入记录较新时替换；本地记录较新时跳过并保留本地。
- 设置作为明确的整体变更导入。

### 4. 清空与恢复

- `BackupRepository` 新增 `clearAllData`。
- 清空顺序遵守外键：同步队列→单日覆盖→班制→设置。
- 清空后重新创建 reminder/app settings 单例默认行。
- 自动测试验证导出后清空，再导入可恢复 profile、override、主题与首次启动设置。
- 导入/清空后刷新排班、提醒、Android 主屏小组件和 onboarding controller。

### 5. 可选云同步

- `cloudSyncEnabledProvider` 使用 `--dart-define=ENABLE_CLOUD_SYNC=true` 控制。
- 默认 false，与 `config/feature_flags.json` 一致。
- 默认状态不创建网络客户端、不要求登录、不依赖 Supabase。
- 开启时展示本地 sync_queue 待处理数量和重试入口。
- 当前未配置服务端；点击重试会重新读取本地队列并明确提示未发送网络请求。

## 主要修改文件

- `pubspec.yaml`、`pubspec.lock`
- `lib/app/app_dependencies.dart`
- `lib/features/home/presentation/home_page.dart`
- `lib/features/home/presentation/today_page.dart`
- `lib/features/sync/application/backup_file_gateway.dart`
- `lib/features/sync/application/backup_repository.dart`
- `lib/features/sync/application/data_management_controller.dart`
- `lib/features/sync/data/file_selector_backup_gateway.dart`
- `lib/features/sync/data/local_backup_repository.dart`
- `lib/features/sync/presentation/data_management_page.dart`
- `test/features/sync/data/local_backup_repository_test.dart`
- `test/features/sync/presentation/data_management_page_test.dart`
- `PROGRESS.md`、`CHANGELOG.md`

## 验证记录

- `D:\flutter\bin\dart.bat format lib test`：通过，0 个文件待格式化。
- `D:\flutter\bin\flutter.bat analyze`：通过，0 问题。
- `D:\flutter\bin\flutter.bat test -r compact`：通过，107 项。
- `D:\flutter\bin\flutter.bat build windows --debug`：通过。
- `D:\flutter\bin\flutter.bat build apk --debug`：通过。

## 已知限制

- 云同步为可选功能且默认关闭，本阶段没有加入 Supabase SDK、密钥或服务端地址。
- Android AppWidget 的真实启动器截图仍需真机或 AVD 补验。
- Windows/Android 系统文件选择器已完成编译和 fake gateway UI 测试；真实交互仍建议 Phase 10 人工走查一次。
- iOS/macOS 不属于当前 Windows 任务职责。

## 下一步（Phase 10）

1. 按规则读取 `codex/10_QA_RELEASE.md` 和测试/隐私/发布文档。
2. 只完成 Windows/Android 集成测试、可访问性、错误恢复、Release 构建与发布前检查。
3. 补做 Android 设备/AVD 小组件与系统文件选择器人工验收；若仍无设备，记录为发布阻塞而非虚报通过。
4. 完成后更新最终进度、变更日志和递增快照。
