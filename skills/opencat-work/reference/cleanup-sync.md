# 工程清理与同步

本文件定义 `/opencat-work` 如何与 `opencat-check`、`opencat-cleanup` 和最终 Git 收口协作。

## 职责边界

### `opencat-check`

负责：

- 工具链与依赖可用性检查
- worktree 拓扑健康性检查
- 基础环境是否具备继续执行的条件

### `opencat-cleanup`

负责：

- 清理残留任务态 worktree
- 恢复保留 worktree 到各自的 `idle branch`
- 删除已完成任务分支
- 收敛异常工程状态

### `opencat-work`

负责：

- 把 `check + cleanup` 作为任务闸门
- 在异常变更出现时先做独立收口
- 在全流程末尾执行统一 `git commit` / `git push`

## 新任务前闸门

领取新任务前，必须满足：

- `opencat-check` 已完成
- `opencat-cleanup` 已完成
- 所有保留 worktree 都已处于闲置态
- 主 worktree 处于可继续推进状态

只要有一个条件不满足，就不得领取新任务。

## 执行中异常处理

若运行中出现以下情况：

- 不明来源脏改动
- 当前流程未创建的新 TODO
- 新出现的任务态 worktree
- 无法解释的分支或提交状态

处理顺序固定为：

1. 先记录异常
2. 用独立 Git 提交收口
3. 必要时重新执行一次 `opencat-cleanup`
4. 回到原任务链继续推进

## 每任务后的清理

- 每完成一个任务后，都应再次执行一次 `opencat-cleanup`
- 只有 cleanup 确认所有保留 worktree 闲置后，才允许继续下一项

## 最终同步

当所有可执行任务处理完毕后：

1. 再执行一次最终 `opencat-cleanup`
2. 回到主 worktree
3. 若有未提交改动，执行最终提交
4. 若分支 ahead > 0，执行 `git push`
5. 若无改动且已同步，明确记录“无需额外 commit / push”

## 停止条件

若最终 cleanup 或 push 失败：

- 先输出明确阻塞原因
- 若仍存在任何可继续的收尾动作，则继续
- 只有在无法继续任何有效步骤时，才允许停止流程
