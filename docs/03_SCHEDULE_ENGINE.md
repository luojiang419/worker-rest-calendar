# 03 · 排班引擎规范

排班引擎必须写成不依赖 Flutter UI 的纯 Dart 模块，并通过单元测试覆盖跨年、闰年、负向日期和覆盖优先级。

## 1. 术语

- `base pattern`：基础班制生成的计划状态。
- `holiday override`：节假日数据包提供的调休上班或休息覆盖。
- `manual override`：用户对某一天的手动修改，优先级最高。
- `planned kind`：基础班制计算结果。
- `effective kind`：应用节假日和手动覆盖后的最终结果。
- `overtime minutes`：加班附加数据，不改变基础状态。

## 2. 日期状态

- `work`：正常工作。
- `rest`：正常休息。
- `adjustedWork`：因调休需要上班。
- `adjustedRest`：因调休获得休息。
- `leave`：请假。

UI 可将 `rest` 与 `adjustedRest`都理解为休息，但颜色和标签不同。

## 3. 覆盖优先级

从高到低：

1. 手动单日覆盖。
2. 节假日数据覆盖。
3. 基础班制。

伪代码：

```text
planned = basePattern.resolve(date)
holiday = holidayOverrides[date]
manual = manualOverrides[date]
effective = manual ?? holiday ?? planned
```

## 4. 大小周算法

### 固定定义

- 周一为一周第一天。
- 大周：周一至周五工作，周六、周日休息。
- 小周：周一至周六工作，周日休息。

### 锚点

保存：

- `anchorMonday`：一个已知周的周一。
- `anchorWeekType`：`big` 或 `small`。

### 计算

```text
dateMonday = mondayOf(date)
weekOffset = floor(daysBetween(anchorMonday, dateMonday) / 7)
weekType = weekOffset 为偶数 ? anchorWeekType : opposite(anchorWeekType)
```

注意不能用向零截断除法处理锚点之前日期，必须使用数学意义上的 floor division。

### 日状态

```text
if weekType == big:
  Saturday/Sunday => rest
  otherwise => work
if weekType == small:
  Sunday => rest
  otherwise => work
```

## 5. 其他班制

### 双休

周六、周日为 rest，其余为 work。

### 单休

周日为 rest，其余为 work。

### 自定义循环

```text
cycleIndex = floor(daysBetween(anchorDate, date) / 1) mod cycleLength
kind = cycleDays[cycleIndex]
```

取模必须规范到 `0..cycleLength-1`，支持锚点之前日期。

## 6. 下一休息日

- 若今天最终状态属于 `rest` 或 `adjustedRest`，返回 0 天。
- 否则从明天开始向后扫描，默认上限 366 天。
- 找不到时返回可诊断错误，不能无限循环。

## 7. 连续工作天数

- 计划连续工作：依据 `planned kind`。
- 实际连续工作：依据 `effective kind`，`work` 与 `adjustedWork`计入；`leave`、`rest`、`adjustedRest`中断。
- 加班分钟数不额外增加天数。

## 8. 必测边界

- 锚点前一周、前两周。
- 跨 12 月/1 月。
- 闰年 2 月 29 日。
- 大周周六为休息，小周周六为工作。
- 手动覆盖节假日，节假日覆盖基础班制。
- 删除 override 后恢复下层状态。
- 自定义周期锚点前日期。
- 夏令时地区不得因本地时间差导致日期偏移；领域层只处理无时区的本地日期值。
