# 文档解析和生成

本文件定义 `/opencat-task` 对输入、change 名称、OpenSpec 文档校验和 archive 报告生成的协议。目标是让 purpose / apply / archive 的文档边界清晰、可重复、可追溯。

## 输入

允许两类输入：

- 已存在的变更名称（kebab-case）
- 自然语言任务描述

## `change-name` 生成规则

若输入是自然语言描述，**必须**先收敛成稳定的 `change-name`：

- 使用英文 kebab-case
- 尽量短但保留业务含义
- 避免使用时间戳、随机串或一次性噪音后缀
- 后续 purpose / apply / archive 全流程必须使用同一个名称

## Purpose 文档

Purpose 阶段由 `openspec-propose` 生成，通常包含：

- proposal
- design
- specs
- tasks

要求：

- 先生成，再校验
- 校验通过后才能创建 `[propose]` 提交

## 阶段校验

Purpose 与 Apply 两个阶段都**必须**执行：

```text
openspec validate --change "<name>"
```

若校验失败：

- 默认先修复文档或实现
- 修复后重新校验
- **严禁**跳过失败校验直接推进下一阶段

## Archive 报告

Archive 阶段除调用 `openspec-archive-change` 外，还**必须**生成中文报告：

```text
.claude/docs/opencat/<timestamp(分钟)>-<change-name>.md
```

文件名只包含时间和 `change-name`，避免不同任务相互覆盖。

## Archive 报告最少字段

报告至少包含：

- 基本信息
- 执行者身份信息
- 变更动机
- 变更范围
- 规格影响
- 任务完成情况

### 执行者身份信息建议字段

- 姓名
- 品种
- 职业
- 经历
- 性格
- 口头禅
- 邮箱

## 生成原则

- 归档文档默认使用中文叙述
- 一次 task 生成一份独立 archive 报告
- 文档应精炼但完整，能支撑后续回溯
- 文档内容应与实际 Git 结果、OpenSpec 变更和任务完成状态保持一致
