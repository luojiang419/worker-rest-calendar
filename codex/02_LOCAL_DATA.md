# Phase 02 · 本地数据库与仓储

## 目标

使用 Drift/SQLite 保存设置、班制、单日覆盖、提醒和同步队列。

## 任务

- 按 `docs/06_DATA_MODEL.md` 建表和迁移。
- 定义 repository 接口与 Drift 实现。
- 建立 active profile 流。
- 单日编辑使用事务。
- 实现版本化 JSON 导出/导入的核心解析器，UI 后做。
- 测试 CRUD、迁移、软删除和事务回滚。

## 退出条件

- 重启后排班设置与覆盖仍存在。
- 数据层测试通过。
- domain 不直接引用 Drift 类型。
