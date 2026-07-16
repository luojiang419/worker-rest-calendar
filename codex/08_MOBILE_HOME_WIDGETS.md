# Phase 08 · iOS/Android 主屏小组件

## 目标

实现原生小组件，不依赖 Flutter 引擎持续运行。

## 任务

- 定义共享 WidgetSnapshot 数据协议。
- Flutter 写入数据并触发刷新。
- iOS 用 WidgetKit/SwiftUI 实现小/中/大。
- Android 用原生 AppWidget 或 Glance 实现小/中/大。
- 点击打开今天或指定日期深链。
- 支持浅色/暗黑和系统主题。

## 退出条件

- 应用未打开时小组件仍可展示最后快照。
- 跨天与编辑后能刷新。
- 两个平台关键布局截图测试或人工验收完成。
