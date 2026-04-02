# 执行工作流

本文件提供 `/opencat-task` 的详细执行路径。主 `SKILL.md` 负责给出摘要，这里负责展开顺序、阶段边界和收尾要求。除非已无法继续任何有效动作，否则本工作流**必须**持续自动推进，**严禁**因常规不确定性暂停等待确认。

## 阶段总览

```text
cleanup
→ classify request
→ prepare git plan
→ purpose
→ validate
→ propose commit
→ claim idle slot
→ enter task state
→ rebase
→ apply
→ validate
→ apply commit
→ rebase
→ archive
→ archive commit
→ merge
→ cleanup
```

## 0. 开始时清理残留

本技能在 SubAgent 内执行，开始前固定调用一次 `opencat-cleanup`：

- 清理可能残留的未提交变更
- 清理未合并的残留分支
- 确保保留 worktree 处于正确闲置态
- 只有 cleanup 确认工程状态可继续后，才允许进入主流程

这一步防止 SubAgent 在脏状态下启动，同时确保闲置分支已对齐到最新主干。

## 1. 分类请求

### 简单变更

满足多数条件即可：

- 小修复、小功能、文档或配置修改
- 单一明确目标
- 模块影响有限

### 复杂变更

满足任一条件即可：

- 跨模块工作
- 涉及设计权衡
- 范围模糊

不确定时归类为“复杂”。

## 2. 准备 Git 计划（主 worktree）

必须先在主 worktree 中记录并检查：

- `base_branch` / `trunk`
- `git status --short`
- `git branch --all`
- `git worktree list --porcelain`

派生：

- `task_branch`: `opencat/<change-name>`
- `worktree_path`: 将要承接本任务的 slot 路径
- `idle_branch`: 该 slot 配对的闲置分支，固定为 `opencat/idle/<slot-name>`

## 3. Purpose 阶段（主 worktree）

**必须**在主 worktree 中调用 `openspec-propose`。

此时**严禁**先把某个保留 worktree 抢占为任务态；先完成 purpose 文档与验证。

## 4. 验证 Purpose

```text
openspec validate --change "<name>"
```

失败则修复后重试。

## 5. 创建 Purpose 提交

验证通过后：

- 创建或更新 `<task_branch>`，基线必须来自最新 `<base_branch>`
- 暂存 purpose 相关文件
- 提交：`[propose] <change-name>: <描述>`
- 主 worktree 切回 `<base_branch>`

## 6. 领取 Worktree Slot

按优先级查找可复用的 worktree slot：

1. `../<repo-name>-worktree`
2. `../<repo-name>-worktree-2`
3. `../<repo-name>-worktree-3`
4. 依次递增

每个 slot 都必须满足“路径 + 闲置分支”配对关系：

- `worktree_path = ../<slot-name>`
- `idle_branch = opencat/idle/<slot-name>`

### 可复用条件

- 路径存在，或这是将要新建的下一个 slot
- 配对的 `idle_branch` 已存在，或本次会同时创建
- 当前 worktree 处于 `idle_branch`
- `git status --short` 为空

### 若 slot 路径不存在

- 先基于最新 `<base_branch>` 创建配对的 `idle_branch`
- 再创建 worktree，并让它直接检出到这个 `idle_branch`

### 若 slot 已存在但不满足可复用条件

- **严禁**在本技能里硬修复
- **必须**立刻转交 `opencat-cleanup`
- 只有 cleanup 把该 slot 恢复到 idle state 后，才允许继续领取它

## 7. 让 Slot 进入任务态

选定 slot 后：

- 在主 worktree 刷新 `<base_branch>`
- 确认 `<task_branch>` 已包含最新 purpose commit
- 在目标 worktree 中从 `idle_branch` 切换到 `<task_branch>`
- 从这一刻起，该 worktree 进入 task state

## 8. 开发前先 Rebase 到主干

在 worktree 中正式开始 apply 阶段前，**必须**先把 `task_branch` rebase 到最新 `<base_branch>`：

```text
# 主 worktree 中刷新 trunk
git fetch
git pull --ff-only

# 目标 worktree 中
git rebase <base_branch>
```

若有冲突，AI 默认自行解决并继续 rebase；除非仓库状态已无法安全恢复，不因常规冲突暂停等待。

## 9. Apply 阶段（Worktree）

**必须**在目标 worktree 中调用 `openspec-apply-change`。

## 10. 验证 Apply

```text
openspec validate --change "<name>"
```

验证失败则修复后重试。

## 11. 创建 Apply 提交

```text
git add <相关文件>
git commit -m "[apply] <change-name>: <描述>"
```

## 12. 合并前再次刷新主干并 Rebase

```text
# 主 worktree 中刷新 trunk
git fetch
git pull --ff-only

# 目标 worktree 中
git rebase <base_branch>
```

无论是否观察到主干推进，只要准备合并回 `<base_branch>`，都要先保证 `<task_branch>` 已 rebase 到最新 `<base_branch>`。

## 13. Archive 阶段（Worktree）

**必须**调用 `openspec-archive-change`。

同时在项目目录下生成中文报告：

```text
.claude/docs/opencat/<timestamp(分钟)>-<change-name>.md
```

文件名只包含时间和 `change-name`，避免不同任务互相覆盖。

## 14. 创建 Archive 提交

```text
git add <archive 相关文件>
git commit -m "[archive] <change-name>: <中文标题>"
```

## 15. 合并回主干（主 worktree）

```text
git checkout <base_branch>
git merge --no-ff "<task_branch>"
```

若 rebase 或 merge 有冲突，AI 默认自行解决并继续；**严禁**因常规冲突停下来等待确认。

## 16. 结束时调用 `opencat-cleanup`

任务 merge 回主干后，不在本技能里重复实现工程清理细节，而是**统一调用 `opencat-cleanup`**：

- 删除已完成的任务分支
- 把承接任务的 worktree 归还到自己的 `idle_branch`
- 确认 retained worktree 全部回到干净、可复用状态
- 收尾任何中途遗留的工程残留

cleanup 完成后，必须满足以下结果：

- `<task_branch>` 已删除
- 相关 worktree 已回到自己的 `idle_branch`
- 工作区干净
- worktree 目录仍然保留
