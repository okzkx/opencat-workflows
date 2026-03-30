# OpenCat Workflows 中文说明

`OpenCat Workflows` 为 `Claude Code` 和 `Cursor` 提供了 4 个可复用的仓库操作技能包。

> [!IMPORTANT]
> 核心卖点：
> 只要先把任务写进 `TODO.md`，再执行 `opencat-work`，它就会从 `TODO.md` 中一次读取一个任务，为每个任务启动一个子 agent，创建或复用独立的 `git worktree`，并通过 OpenSpec 工作流完成任务。
> 任务完成后会写入 `DONE.md`，然后继续循环处理下一条。
> 由于真正干活的是子 agent，主 agent 可以长时间保持更稳定、不易变形的上下文。

它面向希望围绕以下流程建立可重复工作方式的团队：

- Agent 执行前的前置检查
- 借助 OpenSpec 的交付流程
- 基于可复用 `git worktree` 的任务隔离
- 清理并恢复到可复用的空闲仓库状态
- 基于 `TODO.md` 的任务队列执行

## 内置技能

- `opencat-check`：校验前置依赖、包管理器选择、OpenSpec 可用性，以及可复用 worktree 槽位
- `opencat-cleanup`：将中断的 OpenCat/OpenSpec 工作收敛回安全的空闲状态
- `opencat-task`：按 purpose、apply、archive、merge、return-to-idle 的流程执行单个变更
- `opencat-work`：从 `TODO.md` 中一次读取一个任务，在子 agent 和独立 worktree 中完成后写入 `DONE.md`，再继续循环

## 适用场景

如果你的团队已经具备以下基础，这个插件会比较适合：

- 使用 Git 仓库，并且接受 `git worktree` 工作方式
- 希望 AI Agent 严格遵循任务隔离流程
- 可选地使用 OpenSpec 来定义和归档变更
- 愿意维护轻量级的 `TODO.md` / `DONE.md` 约定

它不是通用型项目管理插件，也不会内置 OpenSpec 本身。

## 仓库结构

```text
opencat-workflows/
├── .claude-plugin/plugin.json
├── skills/
├── .cursor/skills/
├── references/
├── scripts/
├── README.md
└── LICENSE
```

`skills/` 是事实来源，`.cursor/skills/` 是从它生成的兼容镜像。

## 前置依赖

在使用 `opencat-task` 或 `opencat-work` 之前，请确认目标仓库具备以下条件：

- `PATH` 中可以直接使用 Git
- `PATH` 中可以直接使用 Node.js
- 已安装该仓库首选的包管理器
- 可直接使用 OpenSpec CLI，或可通过 `npx openspec@latest` 调用
- 如果你希望完整运行 purpose/apply/archive 编排流程，还需要安装外部 OpenSpec 技能

详细说明见：`references/install-claude-code.md`、`references/install-cursor.md` 和 `skills/opencat-task/references/dependency-openspec.md`。

## 在 Claude Code 中安装

1. 将 `opencat-workflows/` 直接放到 `custom-plugins` marketplace 根目录下。
2. 确保 `custom-plugins/.claude-plugin/marketplace.json` 中包含 `"source": "./opencat-workflows"`。
3. 通过 `claude plugin install opencat-workflows@custom-plugins` 安装或启用插件。
4. 确认带命名空间的技能已经出现，例如 `/opencat-workflows:opencat-task`。

更多说明见：`references/install-claude-code.md`。

## 在 Cursor 中安装

1. 将本包中的 `.cursor/skills/` 复制到目标仓库的 `.cursor/skills/` 下。
2. 如果你修改了 `skills/` 里的标准技能，请运行 `scripts/sync-cursor-skills.ps1` 同步刷新镜像。
3. 如果技能列表没有自动刷新，请重新打开或重新加载 Cursor。

更多说明见：`references/install-cursor.md`。

## 当前这套本地用法

按当前这类本地 `Claude Code` marketplace 的接入方式，通常会这样使用本包：

- 将 `plugins/marketplaces/custom-plugins/` 作为目录型 marketplace 根目录
- 将 `opencat-workflows/` 放在这个 marketplace 根目录下
- 在 `custom-plugins/.claude-plugin/marketplace.json` 里登记 `"source": "./opencat-workflows"`
- 以 `opencat-workflows@custom-plugins` 的形式安装或启用插件
- 如果修改了标准技能内容，先以 `skills/` 为准，再同步刷新 Cursor 的镜像技能

首次安装或刷新时，常用命令是：

```text
claude plugin install opencat-workflows@custom-plugins
```

安装完成后，可以先确认 `Claude Code` 中已经出现这些命名空间命令：

- `/opencat-workflows:opencat-check`
- `/opencat-workflows:opencat-cleanup`
- `/opencat-workflows:opencat-task`
- `/opencat-workflows:opencat-work`

## OpenSpec 依赖说明

本包有意将 OpenSpec 视为外部前置依赖，而不是内置组成部分。

当 `opencat-task` 使用 purpose/apply/archive 阶段时，它预期以下外部能力已经存在：

- `openspec-propose`
- `openspec-apply-change`
- `openspec-archive-change`

如果这些能力缺失，`opencat-check` 应该会报告当前环境尚未完全就绪。

## 使用示例

- 安全地开始一次仓库会话：`/opencat-workflows:opencat-check`
- 恢复一段未完成的执行流程：`/opencat-workflows:opencat-cleanup`
- 端到端执行一次变更：`/opencat-workflows:opencat-task my-change-name`
- 处理 `TODO.md` 中的下一条任务：`/opencat-workflows:opencat-work`

## 长时间串行任务模式

这个插件最值得强调的用法，其实就是下面这条主线：

1. 先把任务写进 `TODO.md`
2. 启动 `opencat-work`
3. 让它从 `TODO.md` 里一次读取一个任务
4. 每个任务都由一个子 agent 接手，并创建或复用一个独立的 `git worktree`
5. 子 agent 在这个隔离环境里按 OpenSpec 工作流完成该任务
6. 做完后把结果写入或移动到 `DONE.md`
7. 然后继续循环，处理下一条任务

也就是说，只要维护好 `TODO.md`，再启动 `opencat-work`，它就可以长期稳定地按串行方式一个一个处理任务，而不需要主 agent 每次都重新手动推进整个过程。

这样设计的关键好处是：真正执行任务的是子 agent，不是把所有实现细节都堆进同一个主 agent 上下文里。主 agent 因此可以长期保持更稳定、不易变形的上下文，而每个具体任务都有自己独立的执行上下文、分支和 worktree。

## 推荐日常流程

结合上面的本地接入方式，日常使用顺序建议写成固定流程：

1. 开始处理仓库前，先运行 `/opencat-workflows:opencat-check`
2. 如果检查结果表明仓库还没有回到完全可复用的空闲状态，就运行 `/opencat-workflows:opencat-cleanup`
3. 如果你已经明确本次要做的变更名称，就运行 `/opencat-workflows:opencat-task <change-name>`
4. 如果你是按任务队列长期推进，就维护 `TODO.md`，然后运行 `/opencat-workflows:opencat-work`，让它把任务一条条处理到 `DONE.md`
5. 如果这次改的是插件本身，验证前先重新安装或刷新插件，确保加载到的是最新版本

简单说：已知具体变更时用 `opencat-task`，按任务队列串行推进时用 `opencat-work`。

## 故障排查

如果技能已经加载，但执行流程不完整，常见原因通常包括：

- OpenSpec CLI 未安装
- 配套的 OpenSpec 技能未安装
- 保留的 worktree 处于 detached、dirty，或仍挂在 `trunk` 上
- 仓库没有遵循预期的 idle-branch / task-branch 约定
- `TODO.md` / `DONE.md` 不符合预期的轻量格式

更多运行细节请参考 `references/compatibility-matrix.md` 以及各技能目录下的 `references/` 文档。

## 兼容性说明

- 主要目标：`Claude Code` 目录型 marketplace 加载
- 次要目标：`Cursor` 技能兼容
- `0.1.1` 版本未包含：MCP 分发能力或内置 OpenSpec 技能
