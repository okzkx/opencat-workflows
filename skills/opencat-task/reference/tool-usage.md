# 工具使用规范

本文件定义 `/opencat-task` 与 `opencat` / `openspec` 相关工具的职责边界。原则是：本技能负责编排 purpose / apply / archive / merge 主流程，不重复实现已经由专门工具负责的检查、清理和归档逻辑。

## 职责边界

### `opencat-work`

负责：

- 在整个任务队列入口统一执行环境检查
- 启动带猫咪身份的任务 SubAgent
- 决定何时调用 `/opencat-task`

不负责：

- 接管单个 task 的实现细节

### `opencat-task`

负责：

- 固定在开始与结束时调用 `opencat-cleanup`
- 驱动 purpose / apply / archive / merge 主链路
- 在任务内处理常规异常收口、rebase、merge 与阶段提交

不负责：

- 队列级环境检查入口
- 最终统一 `git push`

### `opencat-cleanup`

负责：

- 清理残留任务态 worktree
- 恢复保留 worktree 到配对 `idle branch`
- 删除已完成任务分支
- 收敛异常工程状态

调用规则：

- **必须**在流程开始前调用一次
- **必须**在 merge 回主干后再次调用一次
- 若发现 retained worktree 异常、残留任务或闲置槽位异常，也应重新调用

### `openspec-propose`

负责：

- 生成 change 的 purpose 文档
- 产出 proposal / design / specs / tasks 等 OpenSpec 变更材料

调用规则：

- **必须**在主 worktree 中调用
- purpose 完成并验证通过前，**严禁**先领取 worktree slot

### `openspec-apply-change`

负责：

- 根据 `tasks.md` 执行实现阶段代码修改
- 推进任务从“文档已定义”到“代码已落地”

调用规则：

- **必须**在目标 worktree 中调用
- 调用前**必须**先把 `task_branch` rebase 到最新 `base_branch`

### `openspec-archive-change`

负责：

- 归档 OpenSpec 变更
- 收束阶段性产出，为最终合并和文档记录提供基础

调用规则：

- **必须**在目标 worktree 中调用
- 调用后**必须**补充中文归档报告并创建 `[archive]` 提交

## 验证命令

Purpose 与 Apply 两个阶段都**必须**使用以下命令验证：

```text
openspec validate --change "<name>"
```

若校验失败，默认先修复再重试；**严禁**把未通过校验的阶段直接推进到下一步。

## 使用原则

- 已有工具能负责的事情，**不要**在 `opencat-task` 中重复发明一套规则
- 工具的职责边界不清时，优先保持“本技能负责编排，专用技能负责具体动作”
- 如果工具运行中暴露出异常仓库状态，默认先收口、再重试，而不是暂停等待确认
