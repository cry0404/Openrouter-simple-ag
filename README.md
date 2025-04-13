# 基于 OpenRouter 简易命令行工具 (`ai`)

一个用于通过 OpenRouter 与 AI 模型快速交互的轻量级 Fish Shell 命令行工具
 ![展示效果](https://github.com/user-attachments/assets/5bcd8272-ba17-417d-b6d6-f64238436fb0)
## 项目概述

本项目提供了一个简洁的命令行界面 (`ai`)，旨在方便用户通过 OpenRouter API 与各种 AI 模型进行交互。它的诞生源于一个 AI 生成的脚本原型，后经人类 ctrl + c 和 ctrl + v 集成开发者（没错，就是我！）的细致调整与改进，最终形成了这个主要基于 Fish Shell 脚本构建的、功能性的实验工具。

您可以将 `ai` 及其编号伙伴 (`ai1`, `ai2`, ..., `ai5`) 想象成一支小型 AI 助手团队，每个成员都预先配置了不同的 OpenRouter 模型。无论您是需要快速获取答案、进行头脑风暴，还是仅仅想体验不同 AI 的风格，都可以选择一个 `ai<N>` 命令开始对话。

该工具支持流式响应（实时观察 AI “思考”过程），并通过命名会话文件提供了基础的上下文管理能力，让您可以轻松维护多个独立的对话线索。
![帮助](https://github.com/user-attachments/assets/f635dd0a-8646-42d2-9bc7-18822abdbdcd)


**请注意：** 这主要是一个实验性工具和学习项目。它可能包含未预见的 Bug，且在健壮性方面无法与成熟的应用程序相比。欢迎您使用、测试，并就发现的问题或改进建议提出反馈。**同时需要注意的一点是，api 需要在对应区域可用，openrouter 大概率只是作了转发，如果是 hk 的 ip 请求类似 gpt 和 gemini 这样的大模型会失败**


## 功能特性

*   **直连 OpenRouter：** 直接向 OpenRouter 的 `/chat/completions` API 端点发送请求。
*   **流式响应：** 实时、增量地显示 AI 的回复内容（纯文本格式）。
*   **会话上下文管理：** 使用命名文件来管理多个对话历史：
    *   启动或继续一个命名会话：`ai<N> -s <会话名称> "您的提示..."`
    *   列出现有的会话列表：`ai -l`
    *   删除指定的会话记录：`ai -d <会话名称>`
    *   默认模式（不带 `-s` 标志）是无状态的：每个查询都是独立的。
*   **预配置模型访问：** 每个 `ai<N>` 命令内部硬编码指定了一个 OpenRouter 模型（可通过 `ai -m` 查看分配情况）。
*   **可定制模型分配：** 用户可以通过编辑底层的 `.fish` 函数文件来更改每个 `ai<N>` 命令所使用的模型。
*   **最小化依赖：** 仅依赖 `fish`, `curl`, 和 `jq`。
*   **便捷的安装与卸载：** 提供一个为 Debian/Ubuntu 系统设计的安装脚本，并包含卸载选项。

## 环境要求

*   **Fish Shell:** 版本 3.0 或更高。
*   **`jq`:** 命令行 JSON 处理工具。
*   **`curl`:** 用于网络数据传输的命令行工具。

## 安装 (Debian/Ubuntu)

我们提供了一个安装脚本以简化在 Debian/Ubuntu 系统上的部署过程。

1.  **获取安装脚本:**
    ```bash
    # --- 方式一：直接下载 ---
    curl -O https://raw.githubusercontent.com/cry0404/ai-for-cli/main/ai.sh
   

    # --- 方式二：克隆仓库 ---
    # git clone https://github.com/cry0404/ai-for-cli.git
    # cd ai-for-cli # 注意：仓库名可能不同
     
    ```

2.  **赋予脚本执行权限:**
    ```bash
    chmod +x ai.sh
    ```

3.  **运行安装脚本:**
    ```bash
    ./ai.sh
    ```
    该脚本将尝试执行以下操作：
    *   如果系统未安装 `fish`, `jq`, `curl`，则尝试使用 `apt` 进行安装。
    *   将必要的函数文件 (`ai.fish`, `ai1.fish`, ..., `ai5.fish`) 复制到 Fish 的函数目录 (`~/.config/fish/functions/`)。
    *   **注意：** 脚本会检查 Fish Shell 版本是否为 3.0+。如果检测到过旧的版本，将报错并退出。

4.  **配置 API 密钥:** **必须**提供 OpenRouter API 密钥。请将其设置为环境变量。
    ```fish
    # 在您的 Fish 终端中运行此命令
    set -gx OPENROUTER_API_KEY 'sk-or-v1-此处替换为您的真实密钥'

    # 【重要】建议将上面这行添加到您的 Fish 配置文件
    # (~/.config/fish/config.fish) 中，以使其在不同会话间保持持久。
    # 切记将 'sk-or-v1-此处替换为您的真实密钥' 替换为您的有效密钥！
    ```

5.  **【关键步骤】重新加载 Shell 配置:** 这是确保 Fish 能够识别新添加函数的**必要步骤**。
    *   最简单的方法是：**关闭当前的终端窗口，然后打开一个全新的终端窗口。**
    *   或者，如果您当前已在 Fish shell 中，可以尝试重新加载配置文件：`source ~/.config/fish/config.fish`（但重启终端通常对函数发现更可靠）。
    *   如果 Fish 不是您的默认 Shell，请先输入 `fish` 启动它。

## 卸载

若要移除此工具：

1.  **使用 `--uninstall` 标志运行安装脚本:**
    ```bash
    ./ai.sh --uninstall
    ```
    这将从 `~/.config/fish/functions/` 目录中移除 `ai.fish` 及所有 `ai<N>.fish` 文件。

2.  **可选：移除聊天记录:** 脚本会询问您是否同时删除聊天上下文目录 (`~/.local/share/ai_contexts`)。请根据需要选择。

3.  **手动移除依赖项:** 卸载脚本**不会**自动移除其可能安装的依赖项 (`fish`, `jq`, `curl`)。如果您不再需要这些包，请使用系统的包管理器手动卸载（例如 `sudo apt remove fish jq curl`）。

## 使用方法

该工具主要通过以下两种命令结构进行操作：

1.  **管理任务:** `ai [选项]`
2.  **进行聊天:** `ai<N> [选项] "您的提示内容"` (其中 `<N>` 是 1 到 5 的数字)

**示例:**

*   **查看可用的 AI 助手及其分配的模型：**
    ```fish
    ai -m
    ```

*   **与 1 号助手（使用其默认模型）对话：**
    ```fish
    ai1 "用简单的语言解释为什么天空是蓝色的，假设听众有点走神。"
    ```

*   **使用 3 号助手继续名为“世界征服”的会话：**
    ```fish
    ai3 -s 世界征服 "好的，第二阶段：招募更多猫科盟友。有什么建议吗？"
    ```

*   **列出所有已保存的会话名称：**
    ```fish
    ai -l
    ```

*   **删除名为“杂耍练习”的会话记录：**
    ```fish
    ai -d 杂耍练习
    ```

*   **显示帮助信息：**
    ```fish
    ai -h   # 通用帮助信息
    ai1 -h  # ai1 的专属帮助信息（包含模型信息）
    ```

## 配置与定制

*   **API 密钥:** 请参见“安装”部分的第 4 步。`OPENROUTER_API_KEY` 环境变量是必需的。

*   **更换模型 (进阶操作):**
    每个 `ai<N>` 命令使用的模型是在其对应的函数文件中定义的。要更改 `ai1` 使用的模型，您需要编辑 `~/.config/fish/functions/ai1.fish` 文件；更改 `ai2` 则编辑 `ai2.fish`，依此类推。

    1.  打开相应的函数文件 (例如 `nano ~/.config/fish/functions/ai1.fish`)。
    2.  找到文件顶部附近的配置部分：
        ```fish
        # --- 模型与配置 (硬编码) ---
        set -l model_name "某个/模型ID:版本号" # <-- 修改此处的模型 ID
        set -l model_nickname "模型昵称"       # <-- 修改此处的显示昵称
        ```
    3.  将 `model_name` 后的字符串替换为您想使用的 OpenRouter 模型标识符。
    4.  （可选）更新 `model_nickname`，以便在使用 `ai -m` 或 `ai<N> -h` 时能清晰辨认。
    5.  **【【【极端重要步骤】】】 重新加载 Fish 配置:** 对函数文件的修改**不会**被 Fish 自动识别！您必须执行以下操作之一：
        *   启动一个**全新**的 Fish Shell 会话（最简单可靠）。
        *   或者，在当前会话中 `source` 您刚刚修改过的那个文件（例如，若修改了 `ai1.fish`，则运行 `source ~/.config/fish/functions/ai1.fish`）。
        *   **请务必执行此步骤！** 否则，尽管您修改了文件，命令仍将继续使用旧模型，导致您的更改看似无效。

*   **聊天记录存储位置:** 会话历史记录（JSON 文件格式）存放于 `~/.local/share/ai_contexts/` 目录。

## 依赖项摘要

*   `fish`: Shell 环境 (版本 3.0+)。
*   `jq`: 用于解析 API 返回的 JSON 数据。
*   `curl`: 用于向 OpenRouter API 发起 HTTP 请求。

## 常见问题排查

*   **提示 `Command not found: ai` 或 `Command not found: aiN`:**
    *   您在运行安装脚本后是否重新加载了 Shell 配置（安装步骤 5）？这是最常见的原因。请务必重启终端或 `source` 配置文件。
    *   您的 Fish 版本是否低于 3.0？使用 `fish --version` 检查。如果需要，请升级 (`sudo apt update && sudo apt install fish`)。
    *   安装脚本是否成功完成？检查 `~/.config/fish/functions/` 目录下是否存在 `.fish` 文件。可以尝试重新运行 `./ai.sh`。
*   **提示 `source: Error while reading file...`:**
    *   通常与上述问题相关，特别是安装不完整或文件路径错误。请验证文件是否存在及权限设置。
*   **上下文无法正确保存/加载:**
    *   检查 `~/.local/share/ai_contexts/` 目录的权限。当前用户是否有写入权限？
    *   查看该目录下的 `.json` 文件。它们是否是有效的 JSON 数组格式？某个文件可能在异常中断或编辑过程中损坏。

## 贡献

本项目按“原样”提供，它是一个由 AI 启发、经人工完善的简单工具。请记住，它主要是一个有趣的实验品！

(对了，此 README 的部分内容也是在 AI 辅助下完成的。你还能指望 cry 干些什么呢？ 😉)
