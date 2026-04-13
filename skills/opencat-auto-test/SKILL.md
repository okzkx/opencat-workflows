---
name: opencat-auto-test
description: 基于本地技能 `/playwright-cli` 对 Web 应用做自动化测试，**必须**用可见浏览器 `--headed`、命名 session 并在结束时关闭会话。当用户提到 playwright/playwrite cli、页面冒烟测试、交互验证时触发。
---

# Playwright CLI 自动测试

用于让 Claude 直接调用本地技能 `/playwright-cli`，并通过 `playwright-cli` 命令对本地或远程 Web 应用执行轻量自动化测试。

## 触发条件

- 用户要求“用 playwright-cli 测试页面”
- 用户提到 “playwrite cli” 或类似拼写
- 用户要求做页面冒烟测试、基础交互验证、前端自动测试
- 用户明确要求浏览器要显示出来，不要后台无头运行

## 依赖技能

- 本技能**依赖本地技能** `/playwright-cli`
- 进入测试流程后，应先按 `/playwright-cli` 的约定执行浏览器自动化，再执行本技能规定的“`--headed` + 命名 session + 收尾关闭会话”规则
- 如果本地技能 `/playwright-cli` 不存在，应明确报告依赖缺失，而不是静默改用其他浏览器工具

## 核心规则

### 🚨 不可违反规则

1. **可以**直接在当前上下文执行测试，不要求额外启动 Agent 或 Subagent。
2. **必须**明确使用本地技能 `/playwright-cli` 作为浏览器自动化技能入口；不能只写“使用 playwright-cli”而不说明技能来源。
3. **必须**使用 `playwright-cli` 执行浏览器操作；只有在命令不存在时，才可尝试 `npx --no-install playwright-cli`。
4. **必须**使用可见浏览器模式。真实参数是 `--headed`；如果用户写的是 `--head`，**必须**自动纠正为 `--headed`。
5. **必须**使用命名会话 `-s=<session>`，保证测试过程隔离且便于关闭。
6. **必须**在结束时关闭浏览器会话，并返回清晰的测试结论。

## 执行步骤

### 步骤 1：确认测试目标

先明确以下信息：

- 目标 URL
- 需要验证的页面或流程
- 是否只做简单冒烟测试，还是要深入交互

如果用户没有说清楚，默认执行最小可用的冒烟测试：

- 页面能否打开
- 标题、主标题或关键内容是否出现
- 1 到 2 个核心操作是否可用
- 是否存在明显的控制台报错或资源加载失败

### 步骤 2：准备测试执行方式

默认直接在当前上下文执行测试，无需额外启动 Agent 或 Subagent。

建议使用的测试提示词：

```text
先使用本地技能 /playwright-cli，再通过 playwright-cli 在可见浏览器模式下打开 <url>，通过命名 session 执行一轮轻量自动化测试。重点验证 <scope>，记录通过项、失败项、阻塞项，以及 console/network 中的重要异常。用户若写 --head，应自动改为 --headed。结束前关闭浏览器会话。
```

## 步骤 3：执行测试

### 3.0 激活本地技能

在开始浏览器测试前，先明确本次测试依赖的是本地技能：

```text
/playwright-cli
```

随后再按该技能提供的命令约定执行测试。

### 3.1 检查命令可用性

先检查 `playwright-cli` 是否可用：

```bash
playwright-cli --version
```

如果不可用，再尝试：

```bash
npx --no-install playwright-cli --version
```

如果两者都不可用，直接报告环境缺失，不要擅自安装。

### 3.2 打开可见浏览器

使用命名会话启动页面：

```bash
playwright-cli -s=app-test open --headed http://localhost:3000/
```

### 3.3 获取页面快照

在第一次交互前抓取快照：

```bash
playwright-cli -s=app-test snapshot
```

在每次点击、输入、跳转或页面状态变化后，都应重新抓取快照，再进行下一步操作。

如果元素引用失效，不要盲目重复点击；**必须**先重新获取快照。

### 3.4 按最小路径执行验证

默认按以下顺序进行：

1. 打开页面
2. 检查标题、主标题或关键区域是否出现
3. 执行 1 到 2 个核心操作
4. 确认界面出现可见状态变化
5. 查看 console 或 network 是否有关键异常

常用命令示例：

```bash
playwright-cli -s=app-test click e15
playwright-cli -s=app-test fill e8 "test value"
playwright-cli -s=app-test console
playwright-cli -s=app-test network
```

### 3.5 收尾关闭会话

测试结束后关闭浏览器：

```bash
playwright-cli -s=app-test close
```

## 输出格式

返回结果时使用下面的结构：

- `目标`：测试 URL 与测试范围
- `执行动作`：本次实际做了哪些关键操作
- `通过项`：成功验证的内容
- `失败或阻塞`：失败点、阻塞点、无法继续的原因
- `控制台或网络异常`：重要报错、警告、失败请求
- `后续建议`：仅在确实有价值时提供

## 示例

### 示例 1：本地页面冒烟测试

**输入**：

```text
用 playwright-cli 打开 http://localhost:1430/ 做一些简单测试，浏览器要显示出来。
```

**期望行为**：

- 明确使用本地技能 `/playwright-cli`
- 使用 `playwright-cli`
- 用 `--headed` 打开浏览器
- 做一轮轻量冒烟测试
- 返回测试结论并关闭浏览器

### 示例 2：用户写成 --head

**输入**：

```text
用 playwrite cli 和 --head 测试登录页。
```

**处理规则**：

- 将 `playwrite cli` 识别为 `playwright-cli`
- 明确本次浏览器能力来自本地技能 `/playwright-cli`
- 将 `--head` 自动改写为 `--headed`
- 直接在当前上下文执行，或按需要自行决定是否隔离执行

## 注意事项

- 本地站点打不开时，应明确报告“应用未启动”或“地址不可达”，不要臆测页面内容。
- 默认避免执行删除、批量修改、提交等破坏性操作，除非用户明确要求。
- 如果页面只加载出部分内容，也应先完成可执行的最小验证，再说明前置条件缺失。
- 如果用户要求更深入测试，可在同一技能流程下扩大验证范围，但仍要保持 `playwright-cli`、`--headed` 与命名 session 三条核心规则不变。
