# OpenCat Workflows 中文说明

```text
 /\_/\___________________________________________________________ __
( o.o )___________________________________________________________)
```

`OpenCat Workflows` 为 `Claude Code` 和 `Cursor` 提供一组可复用的工作流技能。
从 `0.1.14` 开始，项目以 5 个技能组成当前稳定执行模型：

- `opencat-check` 负责环境与拓扑就绪检查
- `opencat-cleanup` 负责残留收尾与空闲态归还
- `opencat-task` 负责单个 OpenSpec 变更流程
- `opencat-work` 负责 `TODO.md` 串行任务队列
- `opencat-agent` 负责为任务子 Agent 生成并复用猫咪身份

本包不内置 OpenSpec。完整任务执行仍然依赖目标环境中已经可用的 OpenSpec CLI 与相关 OpenSpec 技能。

## 内置技能

| 技能 | `0.1.14` 中的职责 |
|------|------|
| `opencat-check` | 检查 Git、Node.js、包管理器、OpenSpec 可用性，以及保留 worktree 拓扑是否健康 |
| `opencat-cleanup` | 收尾中断任务，并把保留 worktree 恢复到各自配对的 `opencat/idle/<slot-name>` 分支 |
| `opencat-task` | 在独立 worktree 中执行单个 OpenSpec 任务的 propose、apply、archive、merge 和最终 cleanup |
| `opencat-work` | 读取 `TODO.md` 中已激活的任务，串行创建任务子 Agent，把真实执行委托给 `opencat-task`，并在队列结束后统一做 cleanup 与仓库发布 |
| `opencat-agent` | 生成或复用猫咪身份，持久化为 Agent 文件，并为任务子 Agent 提供 Git 身份 |

## 执行模型

### 独立执行单个任务

当你已经知道明确的变更名称时，使用这一模式。

1. 先运行 `opencat-check`
2. 再运行 `opencat-task <change-name>`
3. 让 `opencat-task` 在流程开始和结束时自行调用 `opencat-cleanup`

`opencat-task` 是执行器，`opencat-check` 是就绪入口。

### 从 TODO 队列串行执行

当任务要从 `TODO.md` 中领取时，使用这一模式。

1. 运行 `opencat-work`
2. `opencat-work` 先执行 `opencat-check`
3. `opencat-work` 再执行 `opencat-cleanup`
4. `opencat-work` 选择一个已激活任务
5. `opencat-work` 调用 `opencat-agent` 生成或复用猫咪身份
6. 任务子 Agent 运行 `opencat-task`
7. `opencat-work` 回写 `TODO.md` 与 `DONE.md`
8. 全流程结束后，`opencat-work` 再执行一次 `opencat-cleanup`
9. 最终 cleanup 之后，`opencat-work` 会在需要时统一执行最终的仓库 `git commit` 与 `git push`

同一时刻只允许存在一个任务子 Agent，队列执行始终是串行的。

## 前置依赖

在使用 `opencat-task` 或 `opencat-work` 之前，目标仓库应满足：

- `PATH` 中可以直接使用 Git
- `PATH` 中可以直接使用 Node.js
- 已安装该仓库首选的包管理器
- 可直接使用 OpenSpec CLI，或可通过 `npx openspec@latest` 调用
- 已安装任务流程所需的 OpenSpec 技能
- 能识别出 `trunk` 分支，例如 `main` 或 `master`

为了获得更稳定的行为，仓库最好还遵循以下约定：

- 存在可复用的保留 worktree 槽位
- 闲置分支命名为 `opencat/idle/<slot-name>`
- 任务分支命名为 `opencat/<change-name>`
- 使用 `opencat-work` 时提供轻量的 `TODO.md` 与 `DONE.md`

## 安装

### Claude Code

1. 将 `opencat-workflows/` 放到本地 `custom-plugins` marketplace 根目录下
2. 在 `custom-plugins/.claude-plugin/marketplace.json` 中加入或确认 `"source": "./opencat-workflows"`
3. 运行 `claude plugin install opencat-workflows@custom-plugins`
4. 确认 `/opencat-workflows:opencat-check`、`/opencat-workflows:opencat-cleanup`、`/opencat-workflows:opencat-task`、`/opencat-workflows:opencat-work` 和 `/opencat-workflows:opencat-agent` 都已可见

详细说明见：`references/install-claude-code.md`

### Cursor

1. 先运行 `scripts/sync-cursor-skills.ps1`，从标准 `skills/` 生成 `.cursor/skills/` 镜像
2. 将生成出的 `.cursor/skills/` 复制到目标仓库
3. 如果技能没有立即出现，重新加载 Cursor
4. 确认 `opencat-check`、`opencat-cleanup`、`opencat-task`、`opencat-work` 和 `opencat-agent` 都已可发现

详细说明见：`references/install-cursor.md`

## 基本命令

```text
/opencat-workflows:opencat-check
/opencat-workflows:opencat-cleanup
/opencat-workflows:opencat-task my-change-name
/opencat-workflows:opencat-work
```

`opencat-agent` 通常作为 `opencat-work` 的内部依赖运行，而不是给用户单独作为主入口使用。

## TODO 与 DONE 约定

`opencat-work` 只执行显式激活的任务。

- `## P1 >` 表示整个章节已激活
- `- > 任务A` 表示单个任务已激活
- 没有 `>` 的条目仍然只是 backlog
- backlog 条目不能被自动补 `>`，也不能被自动执行
- 对 `opencat-work` 来说，章节激活标记是只读的；它不能改写章节标题上的 `>`
- 任务行上的 `>` 可由 `opencat-work` 在已激活章节内维护，用来标记当前执行任务

示例：

```markdown
# TODO

## P1 >
- 任务A
- 任务B

## P2
- 积压任务C
```

在这个例子里，`任务A` 和 `任务B` 可执行，`积压任务C` 不可执行。

`DONE.md` 会记录由 `opencat-agent` 生成的执行者身份：

```markdown
- [2026-03-31 14:20] 任务A — 已完成 — 🐱 像素猫（界面魔法师·布偶猫）
```

## 推荐流程

### 单个明确变更

1. 运行 `opencat-check`
2. 运行 `opencat-task <change-name>`
3. 等待任务流程自行完成 cleanup

### 串行执行 TODO 队列

1. 先在 `TODO.md` 中标记激活章节或任务
2. 运行 `opencat-work`
3. 等待串行队列执行完成
4. 查看 `DONE.md`

如果改动了标准技能文件，验证 Cursor 前请先重新生成镜像。

## 仓库结构

```text
opencat-workflows/
├── .claude-plugin/
├── doc/
├── references/
├── scripts/
├── skills/
├── README.md
└── LICENSE
```

- `skills/` 是事实来源
- `.cursor/skills/` 是按需生成的兼容镜像
- `skills/opencat-work/template/` 中提供参考用的 `TODO.md` 与 `DONE.md` 模板

## 故障排查

执行不完整或无法开始时，常见原因包括：

- OpenSpec CLI 未安装
- 依赖的 OpenSpec 技能未安装
- 保留 worktree 处于 dirty、detached，或仍停在 `trunk`
- 仓库没有遵循预期的 idle-branch 或 task-branch 约定
- `TODO.md` 中只有 backlog，没有任何已激活任务
- `DONE.md` 没有遵循轻量追加记录格式

更多说明见：

- `references/install-claude-code.md`
- `references/install-cursor.md`
- `references/compatibility-matrix.md`
