# 09 · 提醒、统计与同步

## 提醒调度

建立 `ReminderScheduler`，输入未来 60 天有效日历，输出系统通知计划。任何影响日历的操作完成后重新计算受影响区间，避免重复通知。

通知 ID 必须可由“提醒类型 + 日期”稳定推导，便于更新和取消。

### 示例文案

- “明天是调休上班日｜7 月 18 日 周六，别被周末骗了。”
- “再上 2 天班｜下一休息日是 7 月 20 日 周一。”
- “下周是小周｜周六上班，周日休息。”

## 统计口径

- 计划工作：planned kind 为 work。
- 实际工作：effective kind 为 work 或 adjustedWork。
- 休息：effective kind 为 rest 或 adjustedRest。
- 请假：effective kind 为 leave。
- 调休分类独立统计，避免与正常工作/休息混淆。

## 导入导出

导出一个版本化 JSON：

- schemaVersion
- profiles
- overrides
- reminderSettings
- appSettings 中可迁移字段
- exportedAt

导入前必须预览：将新增、覆盖和冲突多少条；用户确认后在事务中写入。

## 云同步

云同步为可选功能：

- 本地优先，离线可用。
- 每条记录有 UUID、updatedAt、deletedAt。
- 首版冲突策略：同实体最后更新时间优先；重要冲突展示给用户。
- 密钥和后端配置使用环境变量或平台安全配置。
