# Git Worktree 使用规则

本文件定义 `/opencat-task` 的 worktree 槽位模型、命名约定和生命周期。worktree 的命名、状态机和配对关系以本文件为唯一权威来源。

## 核心概念

| 术语 | 说明 |
|------|------|
| `trunk` | 基础分支，通常是 `main` 或 `master` |
| `worktree slot` | 一个可复用的保留 worktree 路径，例如 `../<repo-name>-worktree-2` |
| `idle branch` | 与某个 worktree slot 一一对应的闲置分支，例如 `opencat/idle/<slot-name>` |
| `task branch` | 当前任务对应的工作分支，命名为 `opencat/<change-name>` |
| `idle state` | worktree 当前位于自己的 `idle branch`，且 `git status --short` 为空 |
| `task state` | worktree 当前不在 `idle branch` 上，而是在某个明确的 `task branch` 上 |

## 命名约定

- 主 worktree：项目根目录
- worktree slot：`../<repo-name>-worktree`、`../<repo-name>-worktree-2`、`../<repo-name>-worktree-3` ...
- slot 对应闲置分支：`opencat/idle/<slot-name>`
- 任务分支：`opencat/<change-name>`

## 状态机约束

1. 创建或首次发现一个保留 worktree slot 时，**必须**同时存在它的配对 `idle branch`。
2. worktree 处于闲置态时，**必须**同时满足：
   - 当前分支是该 slot 的 `idle branch`
   - 所有任务变更都已提交并合并回 `trunk`
   - `git status --short` 为空
3. worktree 领到任务后，**必须**切换到该任务的 `task branch`；此时它进入 task state。
4. 保留 worktree **严禁**长期处于以下状态：
   - detached HEAD
   - 直接停留在 `trunk`
   - 在 `idle branch` 上但工作区脏
   - 停在无法解释的匿名提交上
5. 任务结束后的标准收尾不是留在任务分支或主干，而是：
   - merge 回 `trunk`
   - 删除 `task branch`
   - 切回配对的 `idle branch`
   - 让 `idle branch` 对齐最新 `trunk`
   - 确认 worktree 干净

## 领取规则

查找 slot 时，按以下顺序优先：

1. `../<repo-name>-worktree`
2. `../<repo-name>-worktree-2`
3. `../<repo-name>-worktree-3`
4. 依次递增

### 可复用条件

- 路径存在，或这是将要新建的下一个 slot
- 配对的 `idle_branch` 已存在，或本次会同时创建
- 当前 worktree 处于 `idle_branch`
- `git status --short` 为空

### 不可复用时

若 slot 已存在但不满足可复用条件：

- **严禁**在 `opencat-task` 内硬修复
- **必须**转交 `opencat-cleanup`
- 只有 cleanup 把该 slot 恢复到 idle state 后，才允许继续领取

## 生命周期映射

```text
claim slot
→ switch to task_branch
→ apply / archive / merge
→ cleanup
→ return to idle_branch
```

## 保留规则

- worktree 目录是长期可复用槽位，**绝不删除**
- 允许新增下一个 slot，但新增后必须立即建立配对 `idle branch`
- 任何时刻都不应把“删除保留 worktree”当作默认收尾策略
