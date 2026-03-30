# OpenCat Workflows 中文说明

`OpenCat Workflows` 为 `Claude Code` 和 `Cursor` 提供了 4 个可复用的仓库操作技能包。

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
- `opencat-work`：从 `TODO.md` / `DONE.md` 中提取任务，并通过 `opencat-task` 串行执行

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
- `0.1.0` 版本未包含：MCP 分发能力或内置 OpenSpec 技能
