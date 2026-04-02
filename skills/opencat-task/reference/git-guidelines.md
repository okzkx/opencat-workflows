# Git 使用规范

本文件定义 `/opencat-task` 在 branch、commit、rebase、merge 和异常 Git 场景中的统一约束。目标是保证 task 历史清晰、主干历史稳定、异常变更可收口。

## 分支规则

- `base_branch` / `trunk` 是唯一主干基线
- 任务分支固定为 `opencat/<change-name>`
- 若 `task_branch` 已存在且状态兼容，优先复用
- 若命名冲突且状态不兼容，可自动派生带后缀的新任务分支
- **严禁**直接改写 `base_branch` 历史

## 提交规范

### 三个检查点提交

| 提交 | 格式 |
|------|------|
| Purpose | `[propose] <name>: <描述>` |
| Apply | `[apply] <name>: <描述>` |
| Archive | `[archive] <name>: <中文标题>` |

### 提交前检查

- 检查 `git status`
- 检查 `git diff`
- 检查 `git log`
- 只暂存当前阶段相关文件
- 不提交构建产物、缓存、密钥

## Rebase 规则

- 在 apply 开始前，**必须**先把 `task_branch` rebase 到最新 `<base_branch>`
- 在 merge 回主干前，**必须**再次 rebase 到最新 `<base_branch>`
- 遇到主干推进、分支分叉或常规冲突时，默认先 rebase，再自行解决冲突
- 若冲突仍可安全处理，**严禁**因常规冲突暂停等待确认

## Merge 规则

回主干时使用：

```text
git checkout <base_branch>
git merge --no-ff "<task_branch>"
```

要求：

- merge 前必须确保 `task_branch` 已基于最新主干
- merge 完成后必须交由 `opencat-cleanup` 删除任务分支并归还闲置态
- 未 merge 到主干前，任务不得标记为完成

## 异常变更收口

若执行中出现当前流程未创建的新 TODO 或不明来源变更：

- **严禁**暂停等待
- **必须**先把异常变更做成独立提交收口
- 然后再继续原任务阶段

## 推送边界

- `/opencat-task` 默认**不自动推送**
- 只有上层流程或用户明确要求时，才执行 `git push`
- 若需要最终统一 push，应交由 `opencat-work` 在整个队列结束后处理
