---
name: opencat-check
description: 检查并补齐 OpenCat / OpenSpec 环境，并判定仓库是否已达到 OpenCat 队列入口就绪态。入口就绪的前提包括：所有承载开发成果的分支都已先用贴合实际改动的自定义描述提交收口并合并回 `trunk`，所有 `idle branch` 都已对齐最新 `trunk`；凡未满足者都**必须**转交 `opencat-cleanup`。默认由 `opencat-work` 在队列入口统一调用。
compatibility: 需要 shell 权限；当缺少工具或缺失 worktree 槽位元数据时，需要允许安装依赖或创建最小必要的分支 / worktree 元数据。
---

在执行 OpenCat 工作流之前，先完成环境检查与安全引导修复。

## 🚨 核心不可违反规则

1. **严禁**把 detached、直接停在 `trunk`、或工作区脏的保留 worktree 当作可复用槽位。
2. 只要发现任何非 `trunk` 分支仍承载未收口成果，或任何 `idle branch` 尚未对齐最新 `trunk`，都**必须**先转交 `opencat-cleanup` 做分支收敛，不得跳过。
3. 进入 OpenCat 队列前，所有待收口成果都必须先以贴合实际改动的自定义描述提交保存；**严禁**用空泛占位描述跳过收尾要求。
4. 本技能只允许补齐最小必要元数据；**严禁**吞掉、覆盖或丢弃已有任务工作。
5. 只要前置条件还没补齐，就**不得**继续进入 `opencat-task`。
6. **必须**默认自主决断并继续完成剩余检查；最多记录环境限制，不因常规不确定性暂停询问用户。

## 最高准则

- **必须**把“完成完整 OpenCat 工作流”作为最高优先级
- **必须**把“所有开发功能分支都已收口到 `trunk`、所有 `idle branch` 都已同步到最新 `trunk`”视为队列入口的硬前提
- **绝对不要**因为任何预期外的变动停止执行；包括但不限于额外未提交修改、删除文件、子模块新变化、执行过程中冒出的附带改动
- **必须**把当前未提交改动视为允许自动收口的工作流残留；继续执行相关 OpenCat 流程时，无需再因未预期改动中断
- 遇到预期外变动时，默认策略是记录并继续，把它视为后续技能链路需要一并处理的现实状态
- 只有在当前关键命令真实失败且已经无法继续任何有效动作时，才允许停止本技能

适用场景：
- `opencat-work` 开始跑 TODO 队列之前
- 需要在进入 OpenCat 队列前做统一前置检查
- 为 OpenSpec 工作流补齐缺失工具
- 修复 git、node、包管理器或 OpenSpec CLI 环境
- 校验保留中的 OpenCat worktree 是否处于合法的闲置态 / 任务态

## 调用约定

- `opencat-work` 在开始执行 TODO 队列前，固定先调用一次 `opencat-check`
- 正常的 `opencat-work -> opencat-task` 链路中，`opencat-task` **不重复调用** `opencat-check`
- `opencat-check` 负责环境、依赖、分支收敛状态和 worktree 拓扑检查，但不负责展开完整 cleanup 执行细节
- 一旦发现 retained worktree、任务分支、其他未收口分支或闲置槽位状态异常，应立即转交 `opencat-cleanup`

---

**输入**：当前仓库根目录，或用户希望准备好的目标仓库。

## 工作流程

1. **检查仓库上下文**

   - 确认目标目录就是预期仓库
   - 根据 lockfile 识别首选包管理器
   - 识别仓库真实的 `trunk` 分支
   - 检查 `git worktree list --porcelain`

2. **按顺序检查必需工具**

   检查：
   1. `git --version`
   2. `node --version`
   3. 根据 lockfile 推导出的首选包管理器版本
   4. `openspec --version`
   5. 若 `openspec` 不在 `PATH` 中，则执行 `npx openspec@latest --version`

3. **检查项目依赖**

   - 若项目依赖缺失，则使用从 lockfile 推导出的包管理器安装依赖
   - 若依赖已完整安装，不要为了保险而重复安装

4. **检查分支收敛状态与 OpenCat worktree 拓扑**

   先检查整个仓库是否已达到“可进入队列”的收敛状态：

   - 是否存在相对 `trunk` 仍有独有提交的非 `trunk` 分支
   - 这些分支上的成果是否已经以贴合实际内容的自定义描述提交保存
   - 所有 `opencat/idle/<slot-name>` 是否已经对齐最新 `trunk`

   然后再对每个保留的 worktree 槽位，检查：

   - worktree 路径
   - 当前分支，或是否处于 detached 状态
   - `git status --short`
   - 是否存在与之配对的闲置分支

   必须满足以下不变量：

   1. 每个保留 worktree 槽位都必须有一个配对的闲置分支
      - 推荐命名：`opencat/idle/<slot-name>`
   2. 一个闲置 worktree 只有在以下条件都满足时才算合法：
      - 当前位于自己的闲置分支
      - `git status --short` 为空
   3. 一个忙碌中的 worktree 只有在以下条件都满足时才算合法：
      - 当前位于一个明确命名的任务分支上，例如 `opencat/<task-name>`
      - 不处于 detached 状态
   4. 队列入口不允许保留任何尚未收口到 `trunk` 的开发分支；若某分支相对 `trunk` 仍有独有提交，则必须先经 `opencat-cleanup` 用贴合实际改动的自定义描述提交完成收口，再合并回 `trunk`
   5. 所有 `idle branch` 都必须与最新 `trunk` 对齐，避免从闲置态领取新任务时产生分支交叉
   6. 保留 worktree 不允许长期处于以下状态：
      - detached HEAD
      - 直接停在 `trunk`
      - 在闲置分支上但工作区是脏的
      - 停在无法明确归属任务的未知分支上

5. **补齐缺失前置条件**

   若发现缺失项，先修复再继续：

   - 若缺少 `git`，优先用当前操作系统可用的包管理器安装，然后重新检查 `git --version`
   - 若缺少 `node` 或仓库所需包管理器，先安装对应运行时，再重新检查
   - 若缺少 OpenSpec，优先尝试无需全局安装的 `npx openspec@latest --version`
   - 若仍需要持久安装 OpenSpec，则执行 `npm install -g @fission-ai/openspec@latest`，然后重新验证 `openspec --version`

6. **补齐最小 worktree 槽位元数据**

   本技能只允许做小而安全的修复，且不能吞掉或丢弃任务工作：

   - 若某个保留 worktree 路径已经存在，但其配对闲置分支缺失，则基于当前 `trunk` 创建该闲置分支
   - 若仓库里还没有任何可复用 worktree 槽位，则创建第一个槽位，并同时创建其配对闲置分支

   本技能**不得**静默修复以下高风险残留状态：

   - 保留 worktree 处于 detached 状态
   - 闲置 worktree 处于脏状态
   - 保留 worktree 直接停在 `trunk`
   - 保留 worktree 停在一个仍有未完成工作的任务分支上
   - 任意非 `trunk` 分支仍有尚未合并到 `trunk` 的独有提交
   - 任意 `idle branch` 尚未对齐最新 `trunk`

   这些状态都表示仓库**尚未就绪**，必须转交给 `opencat-cleanup` 处理。

7. **每次修复后重新验证**

   - 每完成一次安装或引导修复，都要立即重跑失败项检查
   - 只要仍有任何前置条件缺失或不可用，就不能报告成功

8. **汇总就绪状态**

   需要报告：

   - 哪些工具原本就可用
   - 本次运行期间安装了哪些工具或依赖
   - 哪些保留 worktree 已经处于 `idle-ready`
   - 是否仍有分支必须先经自定义描述提交并合并回 `trunk`
   - 是否仍有 `idle branch` 必须先同步到最新 `trunk`
   - 是否有 worktree 必须先经过 `opencat-cleanup`
   - 当前环境是否已经可以运行 `opencat-task`
   - 是否仍有已记录但未自动消除的问题

## 护栏规则

- 优先使用仓库现有的包管理器，不要凭空换一套
- 只安装满足当前工作流所需的最小依赖
- 只要前置条件还没补齐，就不要继续进入 `opencat-task`
- 进入队列前，必须先确保所有开发分支都已收口到 `trunk`
- 进入队列前，必须先确保所有 `idle branch` 都已对齐最新 `trunk`
- 若发现待收口成果，必须先经 `opencat-cleanup` 用贴合实际改动的自定义描述提交保存，再合并回 `trunk`
- 不要把 detached / 挂在 `trunk` / 脏的保留 worktree 当作可复用槽位
- 若 worktree 拓扑不健康，应转交 `opencat-cleanup`，不要临时发明破坏性修复
- 若安装需要管理员权限、联网批准，或涉及代理无法安全决定的系统级选择，不要暂停发问；应记录该环境限制，并继续完成剩余可执行检查
- 默认自主决断：遇到常规不确定性时，不等待用户确认，优先选择最保守且可继续的处理路径
- 当前未提交改动默认视为允许自动收口的工作流残留；不要因这类改动单独中断 OpenCat 流程
- 每次安装或引导修复完成后，都要立即验证
