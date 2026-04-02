---
name: opencat-task
description: OpenSpec 分阶段工作流执行器。**最高守则**：AI **必须**默认自动决策并持续推进；**必须**使用 worktree 隔离实现并合并回主干，且在开始与结束时各调用一次 `opencat-cleanup`。
compatibility: Requires `opencat-cleanup`, `openspec-propose`, `openspec-apply-change`, and `openspec-archive-change` skills to be available. 环境检查入口由 `opencat-work` 统一处理。
---

# OpenCat Task - OpenSpec 分阶段工作流

端到端执行 OpenSpec 变更：从提案到归档，使用“可复用 worktree 槽位 + 闲置分支 / 任务分支”两态模型隔离实现工作。环境检查入口由 `opencat-work` 负责，收尾与工程清理由 `opencat-cleanup` 负责。

## 结构总览

- `${CLAUDE_SKILL_DIR}/reference/highest-principles.md`: 以 AI 自动化为首的最高原则与冲突裁决
- `${CLAUDE_SKILL_DIR}/reference/workflow.md`: 从 purpose 到 cleanup 的完整工作流
- `${CLAUDE_SKILL_DIR}/reference/tool-usage.md`: `opencat` / `openspec` 工具职责边界与调用规范
- `${CLAUDE_SKILL_DIR}/reference/cleanup-sync.md`: 工程清理、异常收口与同步方案
- `${CLAUDE_SKILL_DIR}/reference/git-worktree-rules.md`: worktree 槽位、闲置分支与任务态规则
- `${CLAUDE_SKILL_DIR}/reference/git-guidelines.md`: branch / commit / rebase / merge 的 Git 规范
- `${CLAUDE_SKILL_DIR}/reference/document-protocol.md`: 输入、命名、校验与归档文档生成协议
- `${CLAUDE_SKILL_DIR}/reference/notes.md`: 补充注意事项与平台细节

运行本技能时，凡涉及最高准则、阶段步骤、工具职责、cleanup 策略、worktree 状态机、Git 规则、文档生成或边界说明，**必须**按需读取上述文件；不得只凭主 `SKILL.md` 的摘要自行补全细节。

## 触发条件

- 用户明确调用 `/opencat-task`
- `opencat-work` 的任务 SubAgent 在内部执行具体 OpenSpec 任务
- 用户要求以 OpenSpec 的 propose / apply / archive 三阶段完成单个 change

## 🚨 最高准则

1. **最高守则**：AI 在已授权任务范围内**必须**自动决策、自动推进；除非已无法继续任何有效动作，否则**严禁**暂停等待确认。
2. **必须**使用 worktree 隔离执行 apply / archive 阶段，严禁直接在主 worktree 中完成整条任务链。
3. **必须**把任务变更合并回 `trunk`；严禁停留在未合并任务分支就把流程视为完成。
4. **必须**在流程开始和结束时各调用一次 `opencat-cleanup`；开始时清理残留，结束时归还闲置态并做工程收尾。
5. **必须**在开发前与合并前先 rebase 到最新主干；遇到常规冲突时默认自行解决并继续。
6. 若执行中发现当前流程未创建的新 TODO 或不明来源变更，**严禁**暂停；必须先独立提交收口，再继续当前流程。

## 工作流

### 阶段概览

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

### 核心阶段摘要

1. 开始时固定先调用一次 `opencat-cleanup`
2. 在主 worktree 完成 purpose、验证和 purpose commit
3. 领取或创建可复用的 worktree slot，并切入 `task_branch`
4. 在目标 worktree 完成 apply、验证、apply commit、archive 与 archive commit
5. 回到主 worktree 合并 `task_branch`
6. 结束时再次调用 `opencat-cleanup`，恢复所有相关资源到可复用状态

具体步骤、分支切换和失败处理**必须**读取 `${CLAUDE_SKILL_DIR}/reference/workflow.md`。

## 工具使用约定

- `opencat-cleanup` 负责开始/结束清理、闲置分支恢复与异常收敛
- `openspec-propose` 负责 purpose 阶段文档
- `openspec-apply-change` 负责 apply 阶段实现
- `openspec-archive-change` 负责 archive 阶段归档
- `openspec validate --change "<name>"` 负责 purpose / apply 阶段校验

具体工具职责边界与调用时机**必须**读取 `${CLAUDE_SKILL_DIR}/reference/tool-usage.md`。

## Git Worktree 规则

- worktree slot 命名、`idle_branch` 配对关系与 task / idle 两态模型，以 `${CLAUDE_SKILL_DIR}/reference/git-worktree-rules.md` 为唯一权威来源
- 绝不删除保留 worktree 目录；但也绝不允许它长期停在 detached / `trunk` / 脏状态

## Git 使用规范

- 三个检查点提交格式固定为 `[propose]` / `[apply]` / `[archive]`
- 提交前必须检查 `git status`、`git diff`、`git log`
- 只暂存当前阶段相关文件，不提交构建产物、缓存或密钥
- 不自动推送；除非上层流程或用户明确要求

细节**必须**读取 `${CLAUDE_SKILL_DIR}/reference/git-guidelines.md`。

## 文档解析和生成

- 输入可以是 kebab-case 的 change 名称，也可以是自然语言描述
- 自然语言输入时，必须先收敛成稳定的 `change-name`
- archive 阶段**必须**生成中文报告 `.claude/docs/opencat/<timestamp>-<change-name>.md`
- 报告至少覆盖基本信息、猫咪身份、动机、范围、规格影响与完成情况

具体命名、文档字段和解析规则**必须**读取 `${CLAUDE_SKILL_DIR}/reference/document-protocol.md`。

---

## 输出格式

### 执行中

```text
## OpenCat Task

**Change:** <name>
**Complexity:** simple|complex
**Base:** <base-branch>
**Task Branch:** <task-branch>
**Worktree Slot:** <worktree-path>
**Idle Branch:** <idle-branch>
**Stage:** purpose|apply|archive|merge|return-to-idle

<进度说明>
```

### 完成后

- 变更名称
- 基础分支
- 任务分支
- 使用的 worktree 路径
- 配对的闲置分支
- 各阶段提交是否成功
- 验证是否通过
- 归档是否完成
- 中文报告是否生成
- 合并是否成功
- 任务分支是否删除
- worktree 是否回到闲置态
- 剩余问题（如有）

---

## 护栏规则

| 规则 | 说明 |
|------|------|
| 环境检查入口外置 | 环境检查只在 `opencat-work` 刚开始执行时统一进行，不由本技能直接调用 |
| 工程清理外置 | 任务结束后的分支删除、归还闲置态和工程收尾统一交给 `opencat-cleanup` |
| worktree 保留 | 合并后保留 worktree 目录，供下次复用 |
| 必须有闲置分支 | 每个保留 worktree slot 都必须有自己的 `idle_branch` |
| 闲置必须干净 | worktree 空闲时，必须在 `idle_branch` 且 `git status --short` 为空 |
| 非闲置即任务态 | 只要不在 `idle_branch`，该 worktree 就必须是在明确的 `task_branch` 上 |
| 禁止 detached/trunk 待命 | 保留 worktree 不允许以 detached HEAD 或直接停在 `trunk` 的方式待命 |
| 默认自主决断 | 遇到不确定情况时，不暂停问用户，优先选择最保守且可继续的方案 |
| 先记录再继续 | 无法完美处理的问题先记录到输出中，再继续后续可执行步骤 |
| 未提交改动可自动收口 | 当前未提交改动默认视为允许自动收口的工作流残留，不因其单独中断 `opencat-task` |
| 调用现有技能 | 直接调用 `openspec-propose` / `openspec-apply-change` / `openspec-archive-change` |
| 开发前先 rebase | 在 `task_branch` 开始 apply 开发前，先 rebase 到最新 `<base_branch>` |
| 永远先 rebase | 遇到主干推进、分支分叉、rebase/merge 冲突时，先 rebase 到最新提交，再自行解决冲突 |
| 冲突自解 | 默认自行解决 rebase/merge 冲突，不因常规冲突暂停 |
| 不重写历史 | 不修改 `<base_branch>` 历史 |
| 不自动推送 | 除非用户明确要求 |
| 异常变更先提交 | 遇到未预期新 TODO 或不明来源变更时，不暂停，先独立提交收口再继续 |

---

## 成功 / 失败条件

### 成功 (SUCCESS)

- ✅ 三个检查点提交全部创建
- ✅ 验证全部通过
- ✅ 变更合并到主干
- ✅ worktree 目录保留
- ✅ 中文归档报告生成
- ✅ `task_branch` 已删除
- ✅ worktree 已回到配对的 `idle_branch`

### 失败 (FAILURE)

- ❌ worktree 目录被删除
- ❌ 未合并到主干直接结束流程
- ❌ 混入无关更改到提交
- ❌ 任务完成后 worktree 仍停在任务分支、主干或 detached 状态
- ❌ `idle_branch` 缺失或无法恢复

---

## 关键文件

- `${CLAUDE_SKILL_DIR}/reference/highest-principles.md`
- `${CLAUDE_SKILL_DIR}/reference/workflow.md`
- `${CLAUDE_SKILL_DIR}/reference/tool-usage.md`
- `${CLAUDE_SKILL_DIR}/reference/cleanup-sync.md`
- `${CLAUDE_SKILL_DIR}/reference/git-worktree-rules.md`
- `${CLAUDE_SKILL_DIR}/reference/git-guidelines.md`
- `${CLAUDE_SKILL_DIR}/reference/document-protocol.md`
- `${CLAUDE_SKILL_DIR}/reference/notes.md`

## 注意事项

- 默认自主决策并继续推进，不因常规不确定性暂停追问
- 断点恢复时，**必须**优先依据仓库状态、change 文档和归档文档判断当前位置
- 若细节冲突，以 `highest-principles` 优先，其次是主 `SKILL.md` 的工作流摘要，最后才参考其他 `reference/` 文件
- Windows PowerShell 细节、异常边界和补充说明统一维护在 `${CLAUDE_SKILL_DIR}/reference/notes.md`