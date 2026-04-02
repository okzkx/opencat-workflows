---
name: opencat-task
description: OpenSpec 单任务分阶段执行器。**最高守则**：AI 在已授权单任务范围内**必须**默认自动决策并持续推进，**严禁**因常规不确定性暂停等待；**必须**使用 worktree 隔离完成 propose/apply/archive/merge，并在开始与结束时各调用一次 `opencat-cleanup`；**严禁**接管 `opencat-work` 的队列级调度、环境入口检查或最终统一 push。
compatibility: Requires `opencat-cleanup`, `openspec-propose`, `openspec-apply-change`, and `openspec-archive-change` skills to be available. 环境检查入口由 `opencat-work` 统一处理。
---

# OpenCat Task - OpenSpec 分阶段工作流

端到端执行单个 OpenSpec 变更：从提案到归档，使用“可复用 worktree 槽位 + 闲置分支 / 任务分支”两态模型隔离实现工作。环境检查入口由 `opencat-work` 负责，收尾与工程清理由 `opencat-cleanup` 负责。

本技能只负责“一个已授权 change 的完整落地与收口”，**不负责**任务队列调度、章节激活、跨任务裁决、主流程最终统一 `git push`，也**不能**把保留 worktree 当作一次性临时目录来随意销毁或重建。

本 `SKILL.md` 是 `/opencat-task` 的**单文件权威运行规范**。运行时不得依赖额外 `reference/` 文档才能理解核心规则；如历史目录下仍保留同名参考文件，仅视为维护期备份材料，不是运行前置条件。

## 触发条件

- 用户明确调用 `/opencat-task`
- `opencat-work` 的任务 SubAgent 在内部执行具体 OpenSpec 任务
- 用户要求以 OpenSpec 的 propose / apply / archive 三阶段完成单个 change

## 🚨 最高准则

1. **最高守则**：AI 在已授权单任务范围内**必须**自动决策、自动推进；除非当前仓库已无法继续任何有效动作，否则**严禁**暂停等待确认。
2. **必须**把本技能视为“单任务执行器”而不是“队列调度器”；**严禁**擅自新增任务、激活 backlog、改写上游授权范围，或接管 `opencat-work` 的任务编排职责。
3. **必须**使用 worktree 隔离执行 apply / archive 阶段；**严禁**直接在主 worktree 中完成整条任务链，也**严禁**绕过保留 slot 直接在随机目录实现任务。
4. **必须**把任务变更合并回 `trunk` 并把承接任务的 slot 归还到 `idle branch`；**严禁**停留在未合并任务分支、detached HEAD、直接停在 `trunk` 或脏工作区就把流程视为完成。
5. **必须**在流程开始和结束时各调用一次 `opencat-cleanup`；开始时清理残留，结束时归还闲置态并做工程收尾。
6. **必须**在开发前与合并前先 rebase 到最新主干；遇到常规冲突时默认自行解决并继续，**严禁**把常规 rebase / merge 冲突直接上抛为暂停理由。
7. 若执行中发现当前流程未创建的新 TODO、不明来源变更、异常任务态 worktree 或无法解释的 Git 状态，**严禁**暂停；**必须**先独立提交或清理收口，再继续当前流程。
8. **严禁**删除保留 worktree 目录、改写主干历史、擅自执行队列级最终 `git push`，除非上层流程或用户已明确要求。

### 核心目标

- **必须**完成完整的 OpenSpec purpose / apply / archive 任务链
- **必须**维持 `worktree slot + idle branch + task branch` 状态机完整
- **必须**把最终结果合并回 `trunk`
- **必须**把当前仓库状态视为现实输入，而不是默认暂停理由

### 本技能的明确边界

#### 负责

- 单个 change 的 purpose / apply / archive / merge 主链路
- 在主 worktree 与目标 worktree 之间切换并维持正确分工
- 固定在开始和结束时调用 `opencat-cleanup`
- 在任务内处理常规异常收口、rebase、merge、阶段提交与归档报告
- 把任务结果安全合并回 `trunk` 并归还 slot 到闲置态

#### 不负责

- 任务队列选择、章节激活、`TODO.md` / `DONE.md` 队列维护
- 队列入口环境检查与是否领取下一任务的判断
- 最终统一 `git push`
- 替用户扩大授权范围，或把一个模糊需求扩展成多个任务并行推进
- 删除长期保留的 worktree 槽位

### 自主决策原则

发生不确定性时，按以下顺序裁决：

1. 选择最保守、最不破坏主干历史的继续路径
2. 优先保持 worktree 目录、分支承载关系与已有提交不被破坏
3. 若有多个可行方案，优先选择更容易回到“任务完成并归还闲置态”的方案
4. 若当前步骤无法完美完成，也先记录问题并推进后续仍可执行的步骤

### 冲突裁决顺序

当不同说明出现冲突时，使用以下顺序裁决：

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

### 边界冲突裁决

若“单任务完整收口”与“多任务并行推进”发生冲突，**必须**优先前者。

若“继续推进当前 change”与“替上游流程决定下一任务”发生冲突，**必须**优先前者。

若“保留 worktree 槽位复用”与“为了省事直接删除/重建目录”发生冲突，**必须**优先前者。

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

### 0. 开始时清理残留

本技能在 SubAgent 内执行，开始前固定调用一次 `opencat-cleanup`：

- 清理可能残留的未提交变更
- 清理未合并的残留分支
- 确保保留 worktree 处于正确闲置态
- 只有 cleanup 确认工程状态可继续后，才允许进入主流程

这一步防止 SubAgent 在脏状态下启动，同时确保闲置分支已对齐到最新主干。

### 1. 分类请求

**简单变更**：

- 小修复、小功能、文档或配置修改
- 单一明确目标
- 模块影响有限

**复杂变更**：

- 跨模块工作
- 涉及设计权衡
- 范围模糊

不确定时归类为“复杂”。

### 2. 准备 Git 计划（主 worktree）

必须先在主 worktree 中记录并检查：

- `base_branch` / `trunk`
- `git status --short`
- `git branch --all`
- `git worktree list --porcelain`

派生：

- `task_branch`: `opencat/<change-name>`
- `worktree_path`: 将要承接本任务的 slot 路径
- `idle_branch`: 该 slot 配对的闲置分支，固定为 `opencat/idle/<slot-name>`

### 3. Purpose 阶段（主 worktree）

**必须**在主 worktree 中调用 `openspec-propose`。

此时**严禁**先把某个保留 worktree 抢占为任务态；先完成 purpose 文档与验证。

### 4. 验证 Purpose

```text
openspec validate --change "<name>"
```

失败则修复后重试。

### 5. 创建 Purpose 提交

验证通过后：

- 创建或更新 `<task_branch>`，基线必须来自最新 `<base_branch>`
- 暂存 purpose 相关文件
- 提交：`[propose] <change-name>: <描述>`
- 主 worktree 切回 `<base_branch>`

### 6. 领取 Worktree Slot

按优先级查找可复用的 worktree slot：

1. `../<repo-name>-worktree`
2. `../<repo-name>-worktree-2`
3. `../<repo-name>-worktree-3`
4. 依次递增

每个 slot 都必须满足“路径 + 闲置分支”配对关系：

- `worktree_path = ../<slot-name>`
- `idle_branch = opencat/idle/<slot-name>`

**可复用条件**：

- 路径存在，或这是将要新建的下一个 slot
- 配对的 `idle_branch` 已存在，或本次会同时创建
- 当前 worktree 处于 `idle_branch`
- `git status --short` 为空

**若 slot 路径不存在**：

- 先基于最新 `<base_branch>` 创建配对的 `idle_branch`
- 再创建 worktree，并让它直接检出到这个 `idle_branch`

**若 slot 已存在但不满足可复用条件**：

- **严禁**在本技能里硬修复
- **必须**立刻转交 `opencat-cleanup`
- 只有 cleanup 把该 slot 恢复到 idle state 后，才允许继续领取它

### 7. 让 Slot 进入任务态

选定 slot 后：

- 在主 worktree 刷新 `<base_branch>`
- 确认 `<task_branch>` 已包含最新 purpose commit
- 在目标 worktree 中从 `idle_branch` 切换到 `<task_branch>`
- 从这一刻起，该 worktree 进入 task state

### 8. 开发前先 Rebase 到主干

在 worktree 中正式开始 apply 阶段前，**必须**先把 `task_branch` rebase 到最新 `<base_branch>`：

```text
# 主 worktree 中刷新 trunk
git fetch
git pull --ff-only

# 目标 worktree 中
git rebase <base_branch>
```

若有冲突，AI 默认自行解决并继续 rebase；除非仓库状态已无法安全恢复，不因常规冲突暂停等待。

### 9. Apply 阶段（Worktree）

**必须**在目标 worktree 中调用 `openspec-apply-change`。

### 10. 验证 Apply

```text
openspec validate --change "<name>"
```

验证失败则修复后重试。

### 11. 创建 Apply 提交

```text
git add <相关文件>
git commit -m "[apply] <change-name>: <描述>"
```

### 12. 合并前再次刷新主干并 Rebase

```text
# 主 worktree 中刷新 trunk
git fetch
git pull --ff-only

# 目标 worktree 中
git rebase <base_branch>
```

无论是否观察到主干推进，只要准备合并回 `<base_branch>`，都要先保证 `<task_branch>` 已 rebase 到最新 `<base_branch>`。

### 13. Archive 阶段（Worktree）

**必须**调用 `openspec-archive-change`。

同时在项目目录下生成中文报告：

```text
.claude/docs/opencat/<timestamp(分钟)>-<change-name>.md
```

文件名只包含时间和 `change-name`，避免不同任务互相覆盖。

### 14. 创建 Archive 提交

```text
git add <archive 相关文件>
git commit -m "[archive] <change-name>: <中文标题>"
```

### 15. 合并回主干（主 worktree）

```text
git checkout <base_branch>
git merge --no-ff "<task_branch>"
```

若 rebase 或 merge 有冲突，AI 默认自行解决并继续；**严禁**因常规冲突停下来等待确认。

### 16. 结束时调用 `opencat-cleanup`

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

## 工具使用规范

### 职责边界

#### `opencat-work`

负责：

- 在整个任务队列入口统一执行环境检查
- 启动带猫咪身份的任务 SubAgent
- 决定何时调用 `/opencat-task`

不负责：

- 接管单个 task 的实现细节

#### `opencat-task`

负责：

- 固定在开始与结束时调用 `opencat-cleanup`
- 驱动 purpose / apply / archive / merge 主链路
- 在任务内处理常规异常收口、rebase、merge 与阶段提交

不负责：

- 队列级环境检查入口
- 任务队列调度、章节授权维护
- 最终统一 `git push`
- 最终决定是否领取下一任务

#### `opencat-cleanup`

负责：

- 清理残留任务态 worktree
- 恢复保留 worktree 到配对 `idle branch`
- 删除已完成任务分支
- 收敛异常工程状态

调用规则：

- **必须**在流程开始前调用一次
- **必须**在 merge 回主干后再次调用一次
- 若发现 retained worktree 异常、残留任务或闲置槽位异常，也应重新调用

#### `openspec-propose`

负责：

- 生成 change 的 purpose 文档
- 产出 proposal / design / specs / tasks 等 OpenSpec 变更材料

调用规则：

- **必须**在主 worktree 中调用
- purpose 完成并验证通过前，**严禁**先领取 worktree slot

#### `openspec-apply-change`

负责：

- 根据 `tasks.md` 执行实现阶段代码修改
- 推进任务从“文档已定义”到“代码已落地”

调用规则：

- **必须**在目标 worktree 中调用
- 调用前**必须**先把 `task_branch` rebase 到最新 `base_branch`

#### `openspec-archive-change`

负责：

- 归档 OpenSpec 变更
- 收束阶段性产出，为最终合并和文档记录提供基础

调用规则：

- **必须**在目标 worktree 中调用
- 调用后**必须**补充中文归档报告并创建 `[archive]` 提交

### 验证命令

Purpose 与 Apply 两个阶段都**必须**使用以下命令验证：

```text
openspec validate --change "<name>"
```

若校验失败，默认先修复再重试；**严禁**把未通过校验的阶段直接推进到下一步。

### 使用原则

- 已有工具能负责的事情，**不要**在 `opencat-task` 中重复发明一套规则
- 工具的职责边界不清时，优先保持“本技能负责编排，专用技能负责具体动作”
- 如果工具运行中暴露出异常仓库状态，默认先收口、再重试，而不是暂停等待确认

## 工程清理和同步

本技能开始执行时，固定先调用一次 `opencat-cleanup`：

- 清理可能残留的未提交变更
- 清理未合并分支或异常 worktree
- 确保保留 worktree 已回到可继续推进的状态

若 cleanup 后仍存在无法解释的任务态 worktree、脏改动或分支异常，**严禁**直接继续主流程；必须继续执行收口动作，直到仓库进入可继续状态，或确认已无法继续任何有效步骤。

开始时的 cleanup 只负责把工程收敛到“当前单任务可安全继续”的状态，**不等于**接管 `opencat-work` 的队列级入口检查；若上游没有先完成环境入口检查，本技能也**不能**擅自改写成队列调度器。

若运行中出现以下情况：

- 不明来源脏改动
- 当前流程未创建的新 TODO
- 新出现的任务态 worktree
- 无法解释的分支或提交状态

处理顺序固定为：

1. **必须**先记录异常
2. **必须**用独立 Git 提交收口
3. 必要时**必须**重新执行一次 `opencat-cleanup`
4. **必须**回到原任务链继续推进

merge 回主干后，**必须**再次调用 `opencat-cleanup`，由它统一完成：

- 删除 `task_branch`
- 把承接任务的 worktree 归还到自己的 `idle_branch`
- 让相关 retained worktree 恢复成干净、可复用状态
- 收尾中途遗留的工程残留

`opencat-task` 与上层流程的同步边界如下：

- `opencat-task` **必须**完成 merge 与本地 cleanup 收口
- `opencat-task` **不负责**最终自动 `git push`
- 最终队列级 push 应由 `opencat-work` 或用户明确指令触发
- `opencat-task` **不负责**更新上游任务队列文档，也**不负责**决定下一任务是否开始

若 cleanup 自身失败：

- **必须**先输出明确阻塞原因
- 若仍存在任何可继续的收尾动作，则**必须**继续
- 只有在无法继续任何有效步骤时，才允许停止流程

## Git Worktree 使用规则

### 核心概念

| 术语 | 说明 |
|------|------|
| `trunk` | 基础分支，通常是 `main` 或 `master` |
| `worktree slot` | 一个可复用的保留 worktree 路径，例如 `../<repo-name>-worktree-2` |
| `idle branch` | 与某个 worktree slot 一一对应的闲置分支，例如 `opencat/idle/<slot-name>` |
| `task branch` | 当前任务对应的工作分支，命名为 `opencat/<change-name>` |
| `idle state` | worktree 当前位于自己的 `idle branch`，且 `git status --short` 为空 |
| `task state` | worktree 当前不在 `idle branch` 上，而是在某个明确的 `task branch` 上 |

### 命名约定

- 主 worktree：项目根目录
- worktree slot：`../<repo-name>-worktree`、`../<repo-name>-worktree-2`、`../<repo-name>-worktree-3` ...
- slot 对应闲置分支：`opencat/idle/<slot-name>`
- 任务分支：`opencat/<change-name>`

### 状态机约束

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
6. 只要 worktree 还未回到自己的 `idle branch` 且工作区未恢复干净，就**严禁**宣告本技能已完成。

### 保留规则

- worktree 目录是长期可复用槽位，**绝不删除**
- 允许新增下一个 slot，但新增后必须立即建立配对 `idle branch`
- 任何时刻都不应把“删除保留 worktree”当作默认收尾策略
- 若某个 slot 当前不健康，**必须**优先调用 `opencat-cleanup` 恢复，而不是跳过规则临时借用成未配对 worktree

## Git 使用规范

### 分支规则

- `base_branch` / `trunk` 是唯一主干基线
- 任务分支固定为 `opencat/<change-name>`
- 若 `task_branch` 已存在且状态兼容，优先复用
- 若命名冲突且状态不兼容，可自动派生带后缀的新任务分支
- **严禁**直接改写 `base_branch` 历史

### 提交规范

#### 三个检查点提交

| 提交 | 格式 |
|------|------|
| Purpose | `[propose] <name>: <描述>` |
| Apply | `[apply] <name>: <描述>` |
| Archive | `[archive] <name>: <中文标题>` |

#### 提交前检查

- 检查 `git status`
- 检查 `git diff`
- 检查 `git log`
- 只暂存当前阶段相关文件
- 不提交构建产物、缓存、密钥

### Rebase 规则

- 在 apply 开始前，**必须**先把 `task_branch` rebase 到最新 `<base_branch>`
- 在 merge 回主干前，**必须**再次 rebase 到最新 `<base_branch>`
- 遇到主干推进、分支分叉或常规冲突时，默认先 rebase，再自行解决冲突
- 若冲突仍可安全处理，**严禁**因常规冲突暂停等待确认

### Merge 规则

回主干时使用：

```text
git checkout <base_branch>
git merge --no-ff "<task_branch>"
```

要求：

- merge 前必须确保 `task_branch` 已基于最新主干
- merge 完成后必须交由 `opencat-cleanup` 删除任务分支并归还闲置态
- 未 merge 到主干前，任务不得标记为完成

### 异常变更收口

若执行中出现当前流程未创建的新 TODO 或不明来源变更：

- **严禁**暂停等待
- **必须**先把异常变更做成独立提交收口
- 然后再继续原任务阶段

### 推送边界

- `/opencat-task` 默认**不自动推送**
- 只有上层流程或用户明确要求时，才执行 `git push`
- 若需要最终统一 push，应交由 `opencat-work` 在整个队列结束后处理
- 若当前上下文来自 `opencat-work` 子任务执行，默认把“是否 push”视为上层流程职责，**严禁**擅自越权

## 文档解析和生成

### 输入

允许两类输入：

- 已存在的变更名称（kebab-case）
- 自然语言任务描述

### `change-name` 生成规则

若输入是自然语言描述，**必须**先收敛成稳定的 `change-name`：

- 使用英文 kebab-case
- 尽量短但保留业务含义
- 避免使用时间戳、随机串或一次性噪音后缀
- 后续 purpose / apply / archive 全流程必须使用同一个名称

### Purpose 文档

Purpose 阶段由 `openspec-propose` 生成，通常包含：

- proposal
- design
- specs
- tasks

要求：

- 先生成，再校验
- 校验通过后才能创建 `[propose]` 提交

### Archive 报告

Archive 阶段除调用 `openspec-archive-change` 外，还**必须**生成中文报告：

```text
.claude/docs/opencat/<timestamp(分钟)>-<change-name>.md
```

文件名只包含时间和 `change-name`，避免不同任务相互覆盖。

### Archive 报告最少字段

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
| 单任务边界 | 本技能只处理一个已授权 change，不能扩展成队列调度器 |
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
- ❌ 越权接管 `opencat-work` 的队列调度、章节授权或最终统一 push

---

## 关键文件

- `.claude/docs/opencat/`

## 注意事项

- 默认自主决策并继续推进，不因常规不确定性暂停追问
- 自动决策能力只用于“当前已授权 change 如何推进”，不用来“替上游流程扩大授权范围”
- 断点恢复时，**必须**优先依据仓库状态、change 文档和归档文档判断当前位置
- 当前未提交改动默认视为允许自动收口的工作流残留，不因这类改动单独中断 `opencat-task`
- 但若判定为不明来源异常，仍要先独立提交收口
- 请求范围模糊时，先收敛为最小可执行 change；若存在重大设计权衡，优先采用最小改动、最小行为变化方案
- 如果验证结果不完全自信，先做最可能正确的修复并补充验证
- 若无法完全剥离无关更改，优先缩小暂存范围；仍无法剥离时，记录风险后提交最小安全集合
- 不因“看起来已经差不多”就跳过 merge、cleanup 或 idle state 恢复
- 不使用 bash heredoc `$(cat <<'EOF' ...)`
- 使用 PowerShell here-string 或多个 `-m` 参数
- 不用 `&&` 链接命令，用分步执行或 `$LASTEXITCODE`
- 文档维护时，若规则继续扩展，应优先直接更新本 `SKILL.md`，避免再把运行规则拆散到额外引用文件