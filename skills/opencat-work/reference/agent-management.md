# 智能体管理

本文件定义 `/opencat-work` 如何管理猫咪身份、主 Agent 与任务 SubAgent。

## 角色边界

### 主 Agent

负责：

- 读取和解析任务队列
- 调用 `opencat-check` / `opencat-cleanup`
- 选择任务
- 生成猫咪身份
- 启动与轮询 SubAgent
- 更新项目内真实 `TODO.md` / `DONE.md`
- 做最终 Git 收口

不负责：

- 直接实现具体任务
- 接管 SubAgent 的主开发流程
- 绕过 `opencat-task` 直接在主上下文完成子任务

### 任务 SubAgent

负责：

- 使用猫咪身份执行任务
- 在内部调用 `opencat-task`
- 自主完成实现、验证、归档与收尾

不负责：

- 把常规不确定性上抛给主 Agent
- 使用通用 Git 身份提交代码

## 猫咪身份规则

- 每个任务必须使用一只新的猫咪
- 同一会话中禁止复用同名猫咪
- 身份生成统一委托给 `opencat-agent`
- 调用时应传入：
  - 当前任务名称
  - 当前任务描述
  - 本轮已使用的猫咪姓名列表

## Git 身份隔离

- SubAgent 必须在 worktree 中设置猫咪身份的 `git config user.name`
- SubAgent 必须在 worktree 中设置猫咪身份的 `git config user.email`
- 禁止沿用主 Agent 或默认全局身份提交代码

## 串行执行

- 同一时刻只能有一个任务 SubAgent 处于执行中
- 当前 SubAgent 未结束前，不得启动下一个任务 SubAgent
- 队列推进依赖“当前任务完成并收尾”作为前置条件

## 等待与轮询

- 主 Agent 启动 SubAgent 后，应优先等待结果
- 如无明确失败信号，连续 20 分钟静默仍按正常执行处理
- 避免高频 resume、催促或抢工作，减少主上下文污染

## 决策原则

- 子 Agent 遇到常规不确定性时，选择最保守且可继续的方案
- 子 Agent 先记录问题，再继续推进
- 只有在已无法继续任何有效步骤时，才允许以失败状态返回
