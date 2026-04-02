---
name: opencat-work
description: OpenCat 任务列表连续执行器。**最高守则**：AI 在已授权任务范围内**必须**全自动决策并持续推进，**严禁**因常规不确定性暂停等待；开始前**必须**先运行 `opencat-check` 与 `opencat-cleanup`，任务实现**必须**通过 `opencat-task`，结束后**必须**统一 cleanup 与 git 收口。
compatibility: Requires `opencat-check`, `opencat-cleanup`, `opencat-task`, and `opencat-agent` skills to be available in the project.
---

# /opencat-work - 任务列表连续执行器

执行 `TODO.md` 中已显式激活的任务，通过带猫咪身份的 SubAgent 串行调用 `opencat-task` 逐个完成。**最高工作守则是 AI 全自动决策并持续推进**：只要任务仍在已授权范围内且仓库仍可继续操作，就**必须**继续执行、记录、收口和推进，**严禁**因常规不确定性、短时静默、局部异常或“想先确认一下”而暂停等待用户。环境检查统一交给 `opencat-check`，工程清理统一交给 `opencat-cleanup`，最终 Git 收口由本技能负责。

## 结构总览

- `${CLAUDE_SKILL_DIR}/reference/highest-principles.md`: 最高准则与冲突裁决顺序
- `${CLAUDE_SKILL_DIR}/reference/workflow.md`: 完整执行工作流
- `${CLAUDE_SKILL_DIR}/reference/todo-done-protocol.md`: `TODO.md` / `DONE.md` 文本协议
- `${CLAUDE_SKILL_DIR}/reference/agent-management.md`: 猫咪身份与 SubAgent 管理规则
- `${CLAUDE_SKILL_DIR}/reference/cleanup-sync.md`: 工程清理、异常收口与最终同步
- `${CLAUDE_SKILL_DIR}/reference/notes.md`: 补充注意事项与边界说明

运行本技能时，凡涉及规则细节、文本协议、智能体约束、cleanup 策略或边界说明，**必须**按需读取上述文件；不得仅凭主 `SKILL.md` 的摘要自行补全细节。

## 触发条件

- 用户明确调用 `/opencat-work`
- 用户要求连续处理项目内 `TODO.md` 中已激活的任务
- 用户希望在不中断、少确认或零确认的前提下完成整个 OpenCat Work 队列

## 🚨 最高准则

1. **最高守则**：AI 在已授权任务范围内**必须**全自动决策、全自动推进；除非仓库已无法继续任何有效动作，否则**严禁**暂停等待用户确认。
2. **必须**先执行一次 `opencat-check`，再执行一次 `opencat-cleanup`；只要任意保留 worktree 未回到 `idle branch`，就**严禁**领取新任务。
3. **必须**只执行项目内 `TODO.md` 中显式激活的章节或任务；未激活内容一律视为 backlog。自动决策的边界是“已授权范围内自主推进”，**严禁**擅自扩大执行范围。
4. **必须**通过 SubAgent 调用 `opencat-task` 完成具体任务；主 Agent **严禁**直接接管实现工作，除非已确认 SubAgent 无法继续且主流程仍可通过收口动作推进。
5. **必须**串行运行任务 SubAgent；同一时刻只能存在一个活跃任务执行者。
6. `TODO.md` 章节标题上的 `>` 是显式授权信号，除非用户明确要求，**严禁**新增、删除或改写；任务行上的 `>` 仅可在已激活章节内按流程维护。
7. 对“修复”类任务，**必须**重新验证当前现状；**严禁**仅凭项目内 `DONE.md`、archive 或历史记录直接判定完成。
8. 若执行中出现不明来源变更、未预期新 TODO 或残留任务态 worktree，**严禁**暂停等待；必须先独立收口，再继续原流程。
9. 全流程结束后，**必须**再次执行 `opencat-cleanup`，然后统一完成主 worktree 的 `git commit` / `git push` 收口。

## 工作流

### 1. 初始化

- 读取`TODO.md` 与 `DONE.md`
- 识别活跃章节、活跃任务、普通 backlog
- 建立本轮任务视图，但此时**尚未**领取任务

### 2. 闸门检查

- 固定先运行 `opencat-check`
- 再运行 `opencat-cleanup`
- 只有当仓库收敛到“主 worktree 可继续 + 所有保留 worktree 闲置”时，才允许进入任务选择

### 3. 选择候选任务

- 若存在活跃任务，**必须**优先选择该任务
- 否则按 `P1 > P2 > P3` **必须**寻找第一个活跃章节中的首个未完成任务
- 若没有活跃章节且没有活跃任务，**必须**直接结束并报告“仅剩 backlog，无可执行任务”，**严禁**擅自激活 backlog

### 4. 领取并启动执行者

- 若候选任务尚未带任务级 `>`，**必须**在其所属活跃章节内将其标记为当前任务
- **必须**调用 `opencat-agent` 生成本轮唯一猫咪身份，并记录已使用姓名
- **必须**以猫咪 Prompt 片段启动 SubAgent
- SubAgent **必须**在内部调用 `opencat-task` 完成完整工作流

### 5. 等待、归档与推进

- 主 Agent **必须**只负责等待、轮询、记录状态和必要收口，**严禁**因为一时想加快而接管实现
- 只要没有明确失败证据，连续 20 分钟无新回应仍**必须**视为正常执行，**严禁**仅因静默判定卡死
- 任务成功后，**必须**从 `TODO.md` 删除已完成任务，并在 `DONE.md` 追加精简记录
- 每完成一个任务后，**必须**再执行一次 `opencat-cleanup`，确认可继续领取下一项

### 6. 最终收口

- 当所有活跃任务完成，或确认无更多可执行任务时，**必须**再执行一次最终 `opencat-cleanup`
- 若主 worktree 仍有未提交改动，**必须**执行最终提交
- 若当前分支存在未推送提交，**必须**执行 `git push`
- **必须**输出最终状态报告

## 文本解析和生成

- `TODO.md` 与 `DONE.md` 是权威来源
- 章节优先级固定为 `P1 > P2 > P3`
- 章节标题上的 `>` 表示“该章节被显式授权可进入执行队列”
- 任务行上的 `>` 表示“该任务是当前执行项”
- 回写 `TODO.md` 时只允许：
  - 删除已完成任务行
  - 在已激活章节内维护任务行上的 `>`
  - 在失败任务行后追加失败注释
- 保存前**必须**对章节标题做逐字快照比对；若标题发生任何变化，必须放弃该次写回并改用更小粒度编辑
- 具体协议细节**必须**读取 `${CLAUDE_SKILL_DIR}/reference/todo-done-protocol.md`
- `${CLAUDE_SKILL_DIR}/template/TODO.md` 与 `${CLAUDE_SKILL_DIR}/template/DONE.md` 仅用于格式参考，不参与运行时读写

## 智能体管理

- 每个任务**必须**使用一只新的猫咪执行者，**严禁**复用同一身份
- 猫咪身份统一由 `opencat-agent` 生成；本技能**严禁**内联造猫逻辑
- SubAgent **必须**在 worktree 中设置猫咪身份的 Git 用户信息
- 主 Agent **必须**只做队列编排、状态维护、异常收口和最终汇总
- 子 Agent **必须**自主决策；遇到常规不确定性时，**必须**选择最保守且可继续的方案并记录问题，**严禁**把常规决策回抛给用户
- 详细角色边界与等待规则**必须**读取 `${CLAUDE_SKILL_DIR}/reference/agent-management.md`

## 工程清理和同步

- `opencat-check` 负责环境与拓扑健康检查
- `opencat-cleanup` 负责残留任务、异常 worktree、闲置分支恢复与工程收尾
- 任何非预期变更都**必须**先收口，再继续流程；**严禁**把异常当作暂停理由
- `opencat-task` 不负责最终自动 push；真正的 push **必须**只在 `opencat-work` 全流程末尾统一执行
- cleanup 闸门、异常收口与最终同步策略**必须**读取 `${CLAUDE_SKILL_DIR}/reference/cleanup-sync.md`

## 输出格式

```text
## OpenCat Run Task

**当前任务:** <任务名称>
**优先级:** P1|P2|P3
**猫咪执行者:** <猫咪姓名>（<职业>·<品种>）
**Cleanup:** ready|continuing|blocked
**状态:** 执行中|完成|失败

<进度说明>
```

## Success / Failure

- SUCCESS: 已显式激活的任务被按顺序执行完成， `TODO.md` / `DONE.md` 正确更新，所有 worktree 回到闲置态，主分支完成最终 Git 收口
- FAILURE: `check + cleanup` 后仍无法进入可执行状态，或最终 cleanup / push 失败且已无任何可继续步骤

## 关键文件

- `TODO.md`
- `DONE.md`
- `${CLAUDE_SKILL_DIR}/reference/highest-principles.md`
- `${CLAUDE_SKILL_DIR}/reference/workflow.md`
- `${CLAUDE_SKILL_DIR}/reference/todo-done-protocol.md`
- `${CLAUDE_SKILL_DIR}/reference/agent-management.md`
- `${CLAUDE_SKILL_DIR}/reference/cleanup-sync.md`
- `${CLAUDE_SKILL_DIR}/reference/notes.md`
- `${CLAUDE_SKILL_DIR}/template/TODO.md`（只读模板）
- `${CLAUDE_SKILL_DIR}/template/DONE.md`（只读模板）

## 注意事项

- 默认自主决策并继续推进，不因常规不确定性暂停追问
- 自动决策不是可选策略，而是本技能的最高工作守则
- 当前未提交改动默认视为允许自动收口的工作流残留；继续执行时不单独因此中断
- 断点恢复时，**必须**优先以 `TODO.md`、`DONE.md` 与仓库状态共同判断当前位置
- 若细节冲突，以 `最高准则` 优先，其次是 `工作流`，最后才参考补充说明文档
