# Phase 03 · 设计系统

## 目标

实现浅色、暗黑、跟随系统及统一组件库，包含优雅投影。

## 任务

- 将 `config/design_tokens.json` 映射为 Dart tokens 和 ThemeExtension。
- 实现 AppCard、三类按钮、分段控件、状态标签、日期胶囊、弹层、Toast、空/错/加载状态。
- 投影按主题分别实现；禁止散落 BoxShadow 常量。
- 建立组件展示页，覆盖所有状态和禁用状态。
- 编写关键组件 golden/widget 测试。

## 退出条件

- 组件展示页在浅色和暗黑模式均完整。
- 字体放大 130% 无核心 overflow。
- 控件点击区域不少于 44x44。
