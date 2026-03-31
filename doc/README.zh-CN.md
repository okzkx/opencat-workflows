# OpenCat Workflows 中文说明

```
 /\_/\___________________________________________________________ __
( o.o )___________________________________________________________) 
```

`OpenCat Workflows` 为 `Claude Code` 和 `Cursor` 提供一组可复用的工作流技能，核心目标只有三件事：

- 在执行前检查仓库和工具链是否就绪
- 用可复用的 `git worktree` 槽位隔离每个任务
- 在任务结束后把仓库收敛回可继续复用的空闲状态

本包不内置 OpenSpec。`opencat-task` 和 `opencat-work` 依赖目标环境中已经可用的 OpenSpec CLI 和相关 OpenSpec 技能。

## 内置技能

| 技能 | 作用 |
|------|------|
| `opencat-check` | 检查工具链、包管理器、OpenSpec 可用性和 worktree 拓扑 |
| `opencat-cleanup` | 回收中断任务，把保留 worktree 恢复到安全的空闲态 |
| `opencat-task` | 执行单个变更的 purpose、apply、archive、merge 和 cleanup 流程 |
| `opencat-work` | 按顺序执行 `TODO.md` 中已激活的任务，并交给子 agent 与独立 worktree 处理 |

## 前置依赖

在使用 `opencat-task` 或 `opencat-work` 之前，请确认目标仓库具备以下条件：

- `PATH` 中可以直接使用 Git
- `PATH` 中可以直接使用 Node.js
- 已安装该仓库首选的包管理器
- 可直接使用 OpenSpec CLI，或可通过 `npx openspec@latest` 调用
- 已安装 `opencat-task` 所需的外部 OpenSpec 技能

## 安装

### Claude Code

1. 将 `opencat-workflows/` 放到本地 `custom-plugins` marketplace 根目录下
2. 在 `custom-plugins/.claude-plugin/marketplace.json` 中加入或确认 `"source": "./opencat-workflows"`
3. 运行 `claude plugin install opencat-workflows@custom-plugins`
4. 确认 `/opencat-workflows:opencat-check` 等命名空间技能已经可见

详细说明见：`references/install-claude-code.md`

### Cursor

1. 先运行 `scripts/sync-cursor-skills.ps1`，从 `skills/` 生成 `.cursor/skills/` 镜像
2. 将生成出的 `.cursor/skills/` 复制到目标仓库
3. 如果技能没有立即出现，重新加载 Cursor
4. 确认 `opencat-check`、`opencat-cleanup`、`opencat-task`、`opencat-work` 已可发现

详细说明见：`references/install-cursor.md`

## 基本用法

```text
/opencat-workflows:opencat-check
/opencat-workflows:opencat-cleanup
/opencat-workflows:opencat-task my-change-name
/opencat-workflows:opencat-work
```

- 开始处理仓库前先运行 `opencat-check`
- 遇到残留 worktree、旧任务分支或未收尾状态时运行 `opencat-cleanup`
- 已知具体变更名称时使用 `opencat-task`
- 想从 `TODO.md` 驱动串行任务队列时使用 `opencat-work`

## TODO 激活规则

`opencat-work` 只执行显式激活的任务。

- `## P1 >` 表示该章节已被授权进入执行队列
- `- > 任务A` 表示该任务已被显式指定为当前任务
- 如果章节标题后没有 `>`，且任务行前也没有 `>`，该条目只是 backlog
- backlog 条目不能被 `opencat-work` 自动补 `>` 或自动执行

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

## 推荐流程

1. 先运行 `opencat-check`
2. 如果仓库还没有回到空闲态，再运行 `opencat-cleanup`
3. 做单个变更时运行 `opencat-task <change-name>`，做任务队列时先激活 `TODO.md` 再运行 `opencat-work`
4. 如果改了标准技能文件，验证 Cursor 前先重新生成镜像

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
- `.cursor/skills/` 不是常驻源文件，而是通过 `scripts/sync-cursor-skills.ps1` 按需生成的兼容镜像

## 故障排查

执行不完整时，常见原因包括：

- OpenSpec CLI 未安装
- 依赖的 OpenSpec 技能未安装
- 保留 worktree 处于 detached、dirty 或仍挂在 `trunk`
- 仓库没有遵循预期的 idle-branch 或 task-branch 约定
- `TODO.md` 和 `DONE.md` 没有遵循预期的轻量格式

更多说明见：

- `references/install-claude-code.md`
- `references/install-cursor.md`
- `references/compatibility-matrix.md`
