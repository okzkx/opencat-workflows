# Changelog

本文件参考 [Keep a Changelog](https://keepachangelog.com/en/1.0.0/) 组织版本记录，并按语义化版本的常见写法维护。

说明：

- 仓库中最早可追溯的发布版本是 `0.1.0`，未发现 `1.0.0` 历史版本
- `0.1.10` 与 `0.1.13` 未出现在当前 Git 历史中，因此没有独立条目
- 条目内容依据版本提交、版本文件变更和相邻发布区间内的实际改动整理

## [Unreleased]

- 暂无

## [0.1.18] - 2026-04-01

### Changed

- 将插件版本提升到 `0.1.18`
- 同步更新中英文说明中的稳定执行模型版本标识到 `0.1.18`
- 补充 `opencat-work` 对执行完成后结果汇报的要求，明确必须向用户返回结果、异常与 `DONE.md` 更新说明

## [0.1.17] - 2026-04-01

### Changed

- 将插件版本提升到 `0.1.17`
- 同步更新中英文说明中的稳定执行模型版本标识到 `0.1.17`
- 在中英文使用文档中新增更精简的“快速开始”章节，收敛为 `opencat-check`、创建 `TODO.md`、运行 `opencat-work` 这 3 步

## [0.1.16] - 2026-04-01

### Changed

- 将插件版本提升到 `0.1.16`
- 同步更新中英文说明中的稳定执行模型版本标识到 `0.1.16`
- 推荐优先以 `Claude Code` 插件形式安装 `opencat-workflows`，并补充“无法通过 marketplace 安装时直接复制 `skills/`”的降级说明
- 在中英文说明和安装参考中加入 [`fly-cat`](https://github.com/okzkx/fly-cat) 作为实际集成参考项目
- 清理失效的 `references/install-cursor.md` 文档引用，统一改为直接说明标准 `skills/` 的复制方式

## [0.1.15] - 2026-04-01

### Changed

- 将插件版本提升到 `0.1.15`
- 同步更新中英文说明中的稳定执行模型版本标识到 `0.1.15`

## [0.1.14] - 2026-04-01

### Changed

- 将中英文说明中的稳定执行模型版本统一更新到 `0.1.14`
- 精简发布包，保留核心技能与主文档，减少面向 Cursor 的额外分发材料

### Removed

- 删除 `references/install-cursor.md`
- 删除 `scripts/sync-cursor-skills.ps1`

## [0.1.12] - 2026-04-01

### Changed

- 为 `opencat-work` 增加队列结束后的主分支 Git 收口要求：最终 `cleanup` 成功后，按需自动执行仓库级 `git commit` 与 `git push`
- 明确 `opencat-task` 继续保持“默认不自动 push”的边界，统一由 `opencat-work` 在全流程末尾发布
- 同步更新中英文 README，对“队列执行完成后统一发布仓库”的行为做出说明

## [0.1.11] - 2026-04-01

### Changed

- 细化 `TODO.md` 激活规则，明确章节标题上的 `>` 为只读授权信号，`opencat-work` 不得私自改写
- 恢复并规范任务行 `>` 的推进逻辑，仅允许在已激活章节内把任务标记为当前执行项
- 更新 `skills/opencat-work/template/TODO.template.md`，把章节只读和任务级激活约束写入模板注释
- 同步更新中英文说明文档，补充任务激活与 backlog 边界

## [0.1.9] - 2026-03-31

### Changed

- 强化 `opencat-task` 与 `opencat-work` 对“执行过程中出现新 TODO 或未知改动”的处理要求
- 明确遇到不明来源改动时不能暂停等待，而应先独立提交收口，再继续原有任务链

## [0.1.8] - 2026-03-31

### Changed

- 细化 `opencat-task` 中文文档中的报告生成说明，补充输出内容要求

## [0.1.7] - 2026-03-31

### Changed

- 重写并补全 `opencat-agent` 的技能说明，使猫咪身份生成、复用和注入流程更完整
- 更新中英文 README，系统化说明五技能执行模型、安装步骤以及任务激活约定
- 统一 `opencat-check`、`opencat-cleanup`、`opencat-task`、`opencat-work` 与 `opencat-agent` 在稳定模型中的职责表述

## [0.1.6] - 2026-03-31

### Changed

- 调整 `opencat-agent` 的命名规则，收紧猫咪身份命名约束

## [0.1.5] - 2026-03-31

### Changed

- 强化 `opencat-cleanup` 的收尾流程，补充与 `base_branch` 对齐、变基和回收的要求
- 更新 `opencat-task` 与 `opencat-work`，要求在流程末尾执行最终 `cleanup`，确保 worktree 回到闲置态

## [0.1.4] - 2026-03-31

### Added

- 新增 `opencat-agent` 技能，用于生成和复用任务子 Agent 的猫咪身份

### Changed

- `opencat-work` 改为通过 `opencat-agent` 获取身份档案、Git 配置命令、Prompt 注入片段和 `DONE.md` 署名片段
- `DONE.template.md` 开始支持记录带猫咪署名的完成日志

## [0.1.3] - 2026-03-31

### Added

- 新增 `doc/logo.svg`

### Changed

- 重整中英文 README，压缩冗余内容并重新组织执行模型、安装和目录结构说明
- 更新 `references/compatibility-matrix.md`、`references/install-claude-code.md` 与 `references/install-cursor.md`
- 微调 `opencat-work` 模板内容，继续完善 `TODO` 示例

## [0.1.2] - 2026-03-30

### Added

- 为 `opencat-work` 增加 `template/TODO.template.md` 与 `template/DONE.template.md`

### Changed

- 大幅扩充 `opencat-check`、`opencat-cleanup`、`opencat-task` 和 `opencat-work` 的技能文档，把关键流程和约束直接内联到 `SKILL.md`
- 删除多份分散的 `references/*.md` 子文档，收敛为技能文件内部的完整说明
- 将插件从“基础骨架”推进为可实际执行的 OpenCat 工作流规范包

## [0.1.1] - 2026-03-30

### Changed

- 将 `skills/` 明确为事实来源，不再把生成后的 `.cursor/skills/` 镜像一并纳入发布内容
- 更新 `README.md` 与 `doc/README.zh-CN.md` 的版本标识
- 小幅修订 `opencat-check`、`opencat-cleanup`、`opencat-task` 与 `opencat-work` 的技能描述

## [0.1.0] - 2026-03-30

### Added

- 首次发布 `opencat-workflows`
- 新增 `opencat-check`、`opencat-cleanup`、`opencat-task` 与 `opencat-work` 四个核心技能
- 新增安装说明、兼容性矩阵、Cursor 安装文档与同步脚本
- 提供基础的许可证、插件清单和技能参考结构
