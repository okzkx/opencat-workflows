---
name: opencat-task
description: OpenSpec 单任务分阶段执行器。**最高守则**：AI 在已授权单任务范围内**必须**默认自动决策并持续推进，**严禁**因常规不确定性暂停等待；**必须**先判定执行模式，只有参数显式带 `worktree` 时才走 worktree 工作流，否则默认仅创建任务分支；开始和结束都**必须**调用 `opencat-cleanup`，且**严禁**接管 `opencat-work` 的队列调度或最终统一 push。
compatibility: Requires `opencat-cleanup`, `openspec-propose`, `openspec-apply-change`, and `openspec-archive-change` skills to be available. 环境检查入口由 `opencat-work` 统一处理。
---

# OpenCat Task - OpenSpec 单任务工作流

端到端执行单个 OpenSpec change：从 propose 到 apply，再到 archive 和 merge。默认使用“任务分支模式”完成全部流程；只有调用参数、上游注入提示或结构化参数中显式带 `worktree` 时，才切换到“worktree 模式”。环境入口检查由 `opencat-work` 负责，工程清理与 worktree 闲置态恢复由 `opencat-cleanup` 负责。

## 触发条件

- 用户明确调用 `/opencat-task`
- `opencat-work` 的任务 SubAgent 在内部执行单个 OpenSpec 任务
- 用户要求以 OpenSpec 的 propose / apply / archive 三阶段完成单个 change

## 🚨 最高准则

1. **最高守则**：AI 在已授权单任务范围内**必须**自动决策、自动推进；除非仓库已无法继续任何有效动作，否则**严禁**暂停等待确认。
2. **必须**把本技能视为“单任务执行器”；**严禁**擅自新增任务、激活 backlog、改写上游授权范围，或接管 `opencat-work` 的任务编排职责。
3. **必须**在开始和结束时各调用一次 `opencat-cleanup`；开始用于清理残留，结束用于归还闲置态或完成分支收尾。
4. **必须**先判定执行模式：只有参数显式带 `worktree` 时才使用 worktree；未带 `worktree` 时**严禁**强行创建或领取 worktree，默认只创建并使用 `task_branch`。
5. **必须**把任务变更 merge 回 `trunk`；若是 worktree 模式，还**必须**把承接任务的 slot 归还到自己的 `idle_branch`；若是分支模式，还**必须**让当前工作区回到 `<base_branch>` 且保持干净。
6. **必须**在 apply 前和 merge 前 rebase 到最新主干；遇到常规 rebase / merge 冲突时默认自行解决并继续，**严禁**把常规冲突当作暂停理由。
7. 若执行中发现当前流程未创建的新 TODO、不明来源变更、异常任务态 worktree 或无法解释的 Git 状态，**严禁**暂停；**必须**先独立收口，再继续当前流程。
8. **严禁**删除保留 worktree 目录、改写主干历史、擅自执行队列级最终 `git push`，除非上层流程或用户已明确要求。

### 核心目标

- **必须**完成完整的 OpenSpec purpose / apply / archive / merge 任务链
- **必须**正确执行已选中的 Git 模式：默认分支模式，显式 `worktree` 时才启用 worktree 模式
- **必须**把最终结果安全合并回 `trunk`
- **必须**把当前仓库状态视为现实输入，而不是默认暂停理由

### 职责边界

#### `opencat-task` 负责

- 单个 change 的 mode classify / purpose / apply / archive / merge 主链路
- 创建、复用和收尾 `task_branch`
- 固定调用 `opencat-cleanup` 做起始清理与最终收尾
- 在任务内处理常规异常收口、rebase、merge、阶段提交与归档报告
- 当且仅当启用 worktree 模式时，领取并归还 worktree slot

#### `opencat-task` 不负责

- 任务队列选择、章节激活、`TODO.md` / `DONE.md` 队列维护
- 队列入口环境检查与是否领取下一任务的判断
- 最终统一 `git push`
- 替用户扩大授权范围，或把一个模糊需求扩展成多个任务并行推进
- 删除长期保留的 worktree 槽位

### 冲突裁决顺序

1. 本 `SKILL.md` 中的最高准则
2. 本 `SKILL.md` 中的工作流与规则章节
3. 输出格式和模板示例

若某条说明会导致“暂停等待确认”，而另一条说明允许“继续推进并记录问题”，则**必须**选择后者。

### 何时允许停止

只有同时满足以下条件时，才允许停止本技能：

- 关键命令真实失败
- 已尝试可行的 rebase / cleanup / 收口 / 绕行步骤
- 当前仓库状态已无法继续任何有效动作
- 当前已不存在任何可继续的记录、归档、提交、合并、清理或汇报动作

若仍能继续记录、归档、清理、提交或推进下一步，就不应停止。

## 执行模式

### 模式判定规则

只要满足以下任一条件，就视为 **worktree 模式**：

- 调用参数显式带 `worktree`
- 上游 Prompt 明确要求“使用 worktree”
- 结构化参数中出现 `worktree: true` 或等价开关

若以上条件均不满足，则一律视为 **分支模式**：

- **默认**只创建并使用 `task_branch`
- **严禁**因为仓库里存在保留 worktree，就自动改走 worktree 流程
- **严禁**为了“更隔离一些”擅自加上 `worktree`

### 分支模式

- 使用当前工作区创建并切换到 `task_branch`
- purpose / apply / archive 全部在当前工作区的 `task_branch` 上完成
- merge 完成后切回 `<base_branch>`，删除 `task_branch`，保持工作区干净

### Worktree 模式

- 先在当前工作区完成 purpose 并提交到 `task_branch`
- 再领取保留 worktree slot，在该 slot 中完成 apply / archive
- merge 完成后删除 `task_branch`，并把 slot 归还到配对的 `idle_branch`

## 工作流

### 阶段概览

```text
cleanup
→ classify request
→ decide mode
→ prepare git plan
→ create or reuse task branch
→ purpose
→ validate
→ propose commit
→ branch mode: continue on task branch
→ worktree mode: claim idle slot and enter task state
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

### 0. 起始清理

开始前固定调用一次 `opencat-cleanup`，把工程收敛到“当前单任务可安全继续”的状态。若 cleanup 后仍存在无法解释的任务态 worktree、脏改动或分支异常，**必须**继续做收口、记录和绕行，而不是停下来等待。

### 1. 分类请求并决定模式

必须先明确以下信息：

- `change-name`
- `base_branch` / `trunk`
- 当前是否显式带 `worktree`
- 当前模式是 `branch` 还是 `worktree`

输出进度时必须明确写出本次模式，避免后续流程擅自切换。

### 2. 准备 Git 计划

必须先检查：

- `git status --short`
- `git branch --all`
- 当前分支与主干关系
- 若为 worktree 模式，再额外检查 `git worktree list --porcelain`

然后派生：

- `task_branch = opencat/<change-name>`
- 若为 worktree 模式，再派生 `worktree_path`
- 若为 worktree 模式，再派生 `idle_branch = opencat/idle/<slot-name>`

### 3. 创建或复用任务分支

共同规则：

- `task_branch` 基线**必须**来自最新 `<base_branch>`
- 若 `task_branch` 已存在且状态兼容，优先复用
- 若命名冲突且状态不兼容，可自动派生带后缀的新任务分支

分支模式：

- **必须**在当前工作区切换到 `task_branch`
- 后续 purpose / apply / archive 全部在当前工作区继续

worktree 模式：

- **必须**在当前工作区切换到 `task_branch` 完成 purpose
- purpose 提交完成后，当前工作区应回到 `<base_branch>`，再去领取 slot

### 4. Purpose 阶段

**必须**先调用 `openspec-propose`，并确保 purpose 内容落在 `task_branch` 上。

验证命令：

```text
openspec validate --change "<name>"
```

验证失败则修复后重试，**严禁**把未通过校验的 purpose 直接推进到下一步。

Purpose 提交要求：

- 基线必须来自最新 `<base_branch>`
- 只暂存 purpose 相关文件
- 提交格式：`[propose] <change-name>: <描述>`

### 5. 仅在 worktree 模式下领取 Slot

只有当本次模式为 `worktree` 时，才执行本节；分支模式**直接跳过**。

按优先级查找可复用 slot：

1. `../<repo-name>-worktree`
2. `../<repo-name>-worktree-2`
3. `../<repo-name>-worktree-3`
4. 依次递增

可复用条件：

- 路径存在，或这是将要新建的下一个 slot
- 配对的 `idle_branch` 已存在，或本次会同时创建
- 当前 worktree 位于自己的 `idle_branch`
- `git status --short` 为空

若 slot 路径不存在，则先基于最新 `<base_branch>` 创建配对的 `idle_branch`，再创建 worktree 并直接检出到这个 `idle_branch`。

若 slot 已存在但不满足可复用条件：

- **严禁**在本技能里硬修复
- **必须**立刻转交 `opencat-cleanup`
- 只有 cleanup 把该 slot 恢复到 idle state 后，才允许继续领取它

### 6. 进入执行位置

分支模式：

- 当前工作区保持在 `task_branch`
- 从这一刻起，当前工作区就是唯一执行位置

worktree 模式：

- 在主工作区刷新 `<base_branch>`
- 确认 `<task_branch>` 已包含最新 purpose commit
- 在目标 worktree 中从 `idle_branch` 切换到 `<task_branch>`
- 从这一刻起，该 worktree 进入 task state

### 7. Apply 阶段

在正式开始 apply 前，**必须**先把执行位置上的 `task_branch` rebase 到最新 `<base_branch>`：

```text
git fetch
git pull --ff-only
git rebase <base_branch>
```

若有冲突，默认自行解决并继续；除非仓库状态已无法安全恢复，不因常规冲突暂停等待。

随后 **必须**在当前执行位置调用 `openspec-apply-change`。

验证命令：

```text
openspec validate --change "<name>"
```

Apply 提交要求：

- 只暂存 apply 阶段相关文件
- 提交格式：`[apply] <change-name>: <描述>`

### 8. Archive 阶段

1. 准备 merge 回主干前，**必须**再次 rebase 到最新 `<base_branch>`。
2. 随后 **必须**在当前执行位置调用 `openspec-archive-change`
3. 并在项目指定目录 `.claude/docs/opencat/<timestamp(分钟)>-<change-name>.md` 下生成中文报告

归档报告至少包含：

- 基本信息
- 执行者身份信息（字段与写法以上游注入及 `opencat-agent` 当前定义为准；本技能不假定固定人设或物种）
- 变更动机
- 变更范围
- 规格影响
- 任务完成情况

Archive 提交要求：

- 只暂存 archive 阶段相关文件
- 提交格式：`[archive] <change-name>: <中文标题>`

### 9. 合并回主干

在主工作区中执行：

```text
git checkout <base_branch>
git merge --no-ff "<task_branch>"
```

若 rebase 或 merge 有冲突，默认自行解决并继续；**严禁**因常规冲突停下来等待确认。

未 merge 到主干前，任务不得标记为完成。

### 10. 结束清理

任务 merge 回主干后，**必须**再次调用 `opencat-cleanup`。cleanup 完成后：

共同要求：

- `<task_branch>` 已删除
- 主工作区位于 `<base_branch>`
- 工作区干净

若本次是 worktree 模式，还必须满足：

- 相关 worktree 已回到自己的 `idle_branch`
- worktree 目录仍然保留

## Git 模式规则

### 共同 Git 规则

- `base_branch` / `trunk` 是唯一主干基线
- 任务分支固定为 `opencat/<change-name>`
- **严禁**直接改写 `base_branch` 历史

三个检查点提交格式：

| 提交 | 格式 |
|------|------|
| Purpose | `[propose] <name>: <描述>` |
| Apply | `[apply] <name>: <描述>` |
| Archive | `[archive] <name>: <中文标题>` |

提交前**必须**检查 `git status`、`git diff`、`git log`，并且只暂存当前阶段相关文件，不提交构建产物、缓存、密钥。

若执行中出现当前流程未创建的新 TODO 或不明来源变更：

1. **必须**先记录异常
2. **必须**把异常变更做成独立提交或明确清理收口
3. 必要时**必须**重新执行一次 `opencat-cleanup`
4. **必须**回到原任务链继续推进

### 分支模式规则

1. 分支模式是默认模式；只要没有显式 `worktree` 参数，就**必须**使用分支模式。
2. 分支模式下**严禁**创建、领取或依赖保留 worktree slot。
3. 分支模式下，当前工作区上的 `task_branch` 就是唯一执行位置。
4. 分支模式收尾必须完成：merge 回 `trunk`、删除 `task_branch`、切回 `<base_branch>`、确认工作区干净。

### Worktree 模式规则

| 术语 | 说明 |
|------|------|
| `worktree slot` | 一个可复用的保留 worktree 路径，例如 `../<repo-name>-worktree-2` |
| `idle branch` | 与某个 worktree slot 一一对应的闲置分支，例如 `opencat/idle/<slot-name>` |
| `task state` | worktree 当前不在 `idle branch` 上，而是在某个明确的 `task_branch` 上 |

1. 只有显式带 `worktree` 参数时，才允许进入本模式。
2. 创建或首次发现一个保留 worktree slot 时，**必须**同时存在它的配对 `idle_branch`。
3. worktree 处于闲置态时，**必须**同时满足：当前分支是该 slot 的 `idle_branch`、所有任务变更都已提交并合并回 `trunk`、`git status --short` 为空。
4. worktree 领到任务后，**必须**切换到该任务的 `task_branch`；此时它进入 task state。
5. 保留 worktree **严禁**长期处于 detached HEAD、直接停留在 `trunk`、在 `idle_branch` 上但工作区脏、或停在无法解释的匿名提交上。
6. 任务结束后的标准收尾是：merge 回 `trunk`、删除 `task_branch`、切回配对的 `idle_branch`、让 `idle_branch` 对齐最新 `trunk`、确认 worktree 干净。
7. 只要 worktree 还未回到自己的 `idle_branch` 且工作区未恢复干净，就**严禁**宣告本技能已完成。
8. worktree 目录是长期可复用槽位，**绝不删除**。

### 推送边界

- `/opencat-task` 默认**不自动推送**
- 只有上层流程或用户明确要求时，才执行 `git push`
- 若当前上下文来自 `opencat-work` 子任务执行，默认把“是否 push”视为上层流程职责，**严禁**擅自越权

## 文档解析和生成

允许两类输入：

- 已存在的变更名称（kebab-case）
- 自然语言任务描述

若输入是自然语言描述，**必须**先收敛成稳定的 `change-name`：

- 使用英文 kebab-case
- 尽量短但保留业务含义
- 避免使用时间戳、随机串或一次性噪音后缀
- 后续 purpose / apply / archive 全流程必须使用同一个名称

Purpose 阶段由 `openspec-propose` 生成，通常包含 `proposal`、`design`、`specs`、`tasks`；必须先生成，再校验，校验通过后才能创建 `[propose]` 提交。

Archive 阶段除调用 `openspec-archive-change` 外，还**必须**生成中文报告：

```text
.claude/docs/opencat/<timestamp(分钟)>-<change-name>.md
```

执行者身份信息建议字段（按需取舍，以当次任务执行者档案为准）：

- 展示名 / Git `user.name`
- Git `user.email`
- 角色或专长标签（若上游档案有提供）
- 其余档案字段（经历、性格、习惯用语等）若存在则可摘录，**不得**由本技能凭空补全为某种固定形象

## 输出格式

### 执行中

```text
## OpenCat Task

**Change:** <name>
**Mode:** branch|worktree
**Complexity:** simple|complex
**Base:** <base-branch>
**Task Branch:** <task-branch>
**Worktree Slot:** <worktree-path or n/a>
**Idle Branch:** <idle-branch or n/a>
**Stage:** purpose|apply|archive|merge|cleanup

<进度说明>
```

### 完成后

- 变更名称
- 执行模式
- 基础分支
- 任务分支
- 使用的 worktree 路径（若无则写 `n/a`）
- 配对的闲置分支（若无则写 `n/a`）
- 各阶段提交是否成功
- 验证是否通过
- 归档是否完成
- 中文报告是否生成
- 合并是否成功
- 任务分支是否删除
- worktree 是否回到闲置态（仅 worktree 模式）
- 当前工作区是否回到主干且干净
- 剩余问题（如有）

## Success / Failure

- SUCCESS: 三个检查点提交全部创建，验证通过，变更合并到主干，中文归档报告生成，`task_branch` 已删除；若为 worktree 模式，关联 slot 已回到配对的 `idle_branch`；若为分支模式，当前工作区已回到 `<base_branch>` 且干净
- FAILURE: 未合并到主干直接结束流程、混入无关更改、分支模式下强行创建 worktree、worktree 模式下 `idle_branch` 缺失或无法恢复、任务完成后工作区仍停在任务分支/主干外/detached 状态、越权接管 `opencat-work` 的队列职责或最终统一 push

## 关键文件

- `.claude/docs/opencat/`

## 注意事项

- 自动决策能力只用于“当前已授权 change 如何推进”，不用来“替上游流程扩大授权范围”
- 断点恢复时，**必须**优先依据仓库状态、change 文档和归档文档判断当前位置
- 当前未提交改动默认视为允许自动收口的工作流残留；但若判定为不明来源异常，仍要先独立提交收口
- 请求范围模糊时，先收敛为最小可执行 change；若存在重大设计权衡，优先采用最小改动、最小行为变化方案
- 如果验证结果不完全自信，先做最可能正确的修复并补充验证
- 若无法完全剥离无关更改，优先缩小暂存范围；仍无法剥离时，记录风险后提交最小安全集合
- 不因“看起来已经差不多”就跳过 merge、cleanup 或模式收尾
- 不使用 bash heredoc `$(cat <<'EOF' ...)`
- 使用 PowerShell here-string 或多个 `-m` 参数
- 不用 `&&` 链接命令，用分步执行或 `$LASTEXITCODE`
- 文档维护时，若规则继续扩展，应优先直接更新本 `SKILL.md`，避免再把运行规则拆散到额外引用文件