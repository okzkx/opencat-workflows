# 执行工作流

本文件提供 `/opencat-work` 的详细执行路径。主 `SKILL.md` 负责给出摘要，这里负责展开顺序与边界。运行时操作对象是项目内真实 `TODO.md` / `DONE.md`；`${CLAUDE_SKILL_DIR}/template/TODO.md` 与 `${CLAUDE_SKILL_DIR}/template/DONE.md` 仅作只读格式参考。

## 阶段总览

```text
read TODO/DONE
→ check
→ cleanup
→ select active task
→ assign cat agent
→ run opencat-task
→ archive result
→ cleanup again
→ next task or finish
→ final cleanup
→ final commit/push
```

## 1. 初始化

- 读取项目内真实 `TODO.md` 和 `DONE.md`
- 识别活跃章节、活跃任务、未激活 backlog
- 记录本轮已使用的猫咪姓名列表

## 2. check + cleanup 闸门

- 先调用 `opencat-check`
- 再调用 `opencat-cleanup`
- 若 cleanup 后仍存在非闲置 worktree、残留任务分支或不可解释脏改动，则不得领取新任务

## 3. 候选任务选择

按以下顺序选择：

1. 当前已带 `- >` 的活跃任务
2. `P1` 活跃章节中的第一个未完成任务
3. `P2` 活跃章节中的第一个未完成任务
4. `P3` 活跃章节中的第一个未完成任务

若没有活跃章节，也没有活跃任务，则直接结束并报告“当前无可执行任务”。

## 4. 领取任务

- 若候选任务位于活跃章节内但尚未带 `>`，可将其标记为当前任务
- 编辑项目内真实 `TODO.md` 时仅允许最小粒度修改任务行
- 保存前必须检查章节标题是否逐字保持不变

## 5. 启动 SubAgent

- 调用 `opencat-agent` 生成唯一猫咪身份
- 启动一个新的任务 SubAgent
- 在注入提示中明确：
  - 使用猫咪身份
  - 调用 `opencat-task`
  - 不得向主 Agent 反向追问常规决策

## 6. 执行等待

- 主 Agent 只做等待、轮询和状态更新
- 连续 20 分钟无新文本回应，不构成卡死判定
- 只有在明确失败、崩溃、无法继续或用户明确要求接管时，主 Agent 才可改变策略

## 7. 成功归档

- 从项目内真实 `TODO.md` 删除已完成任务行
- 在项目内真实 `DONE.md` 末尾追加一条精简记录
- 若有默认归档目录需求，使用 `.claude/docs/opencat/`

## 8. 失败记录

- 在任务行后追加失败注释
- 记录阻塞原因
- 若仍有可继续的收尾或下一可执行任务，继续推进

## 9. 下一任务

- 每完成一个任务后，再调用一次 `opencat-cleanup`
- 只有 cleanup 确认全部 worktree 闲置后，才允许继续领取下一项

## 10. 最终收口

- 当没有更多可执行任务时，再执行一次最终 `opencat-cleanup`
- 主 worktree 如有未提交改动，执行最终提交
- 如当前分支存在未推送提交，执行 `git push`
- 输出最终状态报告
