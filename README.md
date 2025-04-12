# OpenRouter Simple AG - Your Command-Line AI Assistant

`ag` (AI Generalist) is a simple yet powerful command-line tool written in Fish shell script that allows you to interact with AI models via the OpenRouter API directly from your terminal. It supports streaming responses, managing multiple conversation contexts, rendering Markdown output, and saving conversations.

Inspired by the need for a straightforward, terminal-based AI interaction tool without heavy dependencies.

**[中文说明](#中文说明) (Chinese Description Below)**

## Features

*   **Direct API Interaction:** Communicates with the OpenRouter API (`/chat/completions` endpoint).
*   **Streaming Responses:** Displays AI responses word-by-word as they arrive (default behavior).
*   **Named Context Management:**
    *   Maintain multiple independent conversation histories using simple named files (`-s <name>`).
    *   List available contexts (`-l`).
    *   Delete specific contexts (`-d <name>`).
    *   Default mode is ephemeral (no context loaded or saved).
*   **Markdown Rendering:**
    *   Optionally render Markdown responses directly in the terminal using `rich-cli` and `less` (`-m`).
    *   Automatically requests Markdown format from the AI when saving to a file (`-o`).
*   **Save Responses:** Save the AI's current response to a specified file (`-o <path>`).
    *   Saves as Markdown if `-o` is used.
    *   Supports absolute paths, relative paths, and a configurable default directory (`$AG_DEFAULT_OUTPUT_DIR`).
    *   Attempts to open the saved Markdown file using `rich` after saving.
*   **Customizable:** Easily change the default AI model or API endpoint within the script.
*   **Lightweight:** Primarily relies on `fish`, `curl`, and `jq`. Markdown features require `rich-cli` and `less`.
*   **Easy Setup:** Includes a one-click setup script for Debian/Ubuntu-based systems.

## Installation (Debian/Ubuntu based systems)

An automated setup script is provided to install dependencies and the `ag` function itself.

1.  **Download the Setup Script:**
    ```bash
    curl -o setup_ag_tool.sh https://raw.githubusercontent.com/YOUR_USERNAME/YOUR_REPO_NAME/main/setup_ag_tool.sh
    # Make sure to replace YOUR_USERNAME and YOUR_REPO_NAME with your actual GitHub details!
    # Or simply clone the repository:
    # git clone https://github.com/YOUR_USERNAME/YOUR_REPO_NAME.git
    # cd YOUR_REPO_NAME
    ```

2.  **Make it Executable:**
    ```bash
    chmod +x setup_ag_tool.sh
    ```

3.  **Run the Script:**
    *   **To install with Markdown support (recommended):**
        ```bash
        ./setup_ag_tool.sh
        ```
    *   **To install WITHOUT Markdown support (no `rich-cli` or `less`):**
        ```bash
        ./setup_ag_tool.sh --no-rich
        ```
    The script will prompt you to choose a language (English/Chinese) for setup instructions and install dependencies (`fish`, `jq`, `curl`, and optionally `pipx`, `rich-cli`, `less`) using `apt` and `pipx`. It will place the `ag.fish` script in `~/.config/fish/functions/`.

4.  **Set API Key:** This is crucial! Set your OpenRouter API key as an environment variable. Run this in your terminal and **add it to your `~/.config/fish/config.fish` file** for persistence:
    ```fish
    set -gx OPENROUTER_API_KEY 'sk-or-v1-YOUR-API-KEY-HERE'
    ```
    *(Replace with your actual key)*

5.  **Start a NEW Fish Shell:** Open a new terminal window or type `fish` to start a new session. This ensures the function is loaded and the `PATH` (if modified by `pipx`) is updated.

## Usage

The basic syntax is: `ag [OPTIONS] "YOUR PROMPT"`

**Examples:**

*   **Simple query (streaming plain text):**
    ```fish
    ag "What is the capital of France?"
    ```

*   **Start or continue a named conversation context:**
    ```fish
    ag -s learning_fish "What are functions in Fish shell?"
    ag -s learning_fish "How do I define arguments for them?"
    ```

*   **List saved contexts:**
    ```fish
    ag -l
    ```

*   **Delete a context:**
    ```fish
    ag -d learning_fish
    ```

*   **Render Markdown response in the terminal:**
    ```fish
    ag -m "Explain git merge vs rebase using Markdown."
    ```

*   **Save Markdown response to a file and open with `rich`:**
    ```fish
    ag -o git_concepts.md "Explain git merge vs rebase using Markdown."
    ```

*   **Save to a specific directory:**
    ```fish
    ag -o ~/Documents/notes/api_notes.md "Summarize the OpenRouter API."
    ```

*   **Use context and save the response:**
    ```fish
    ag -s project_xyz -o update.md "Provide a status update for Project XYZ using Markdown."
    ```

*   **View help:**
    ```fish
    ag -h
    ```

## Configuration

*   **API Key:** Set the `OPENROUTER_API_KEY` environment variable (mandatory).
*   **Default Output Directory:** Optionally set the `AG_DEFAULT_OUTPUT_DIR` environment variable in your `~/.config/fish/config.fish` to specify where files are saved when only a filename is given with `-o`.
    ```fish
    # Example in config.fish
    set -gx AG_DEFAULT_OUTPUT_DIR "$HOME/AI_Responses"
    ```
*   **Model:** Edit the `ag.fish` file (`~/.config/fish/functions/ag.fish`) directly to change the `model_name` variable if desired.
*   **Context Directory:** Context files are stored in `~/.local/share/ag_contexts/`.

## Dependencies

*   **Required:** `fish` (shell), `jq`, `curl`
*   **Optional (for -m / -o):** `rich-cli` (Python package, recommended install via `pipx`), `less` (usually system-provided)

## Troubleshooting

*   **`command not found: ag`:** Ensure you have started a new Fish shell session after running the setup script. Check if `~/.config/fish/functions/ag.fish` exists.
*   **`command not found: rich`:** If you intended to use Markdown features, ensure `rich-cli` was installed correctly (run `pipx list` or `pip list`) and that the directory containing `pipx` binaries (usually `~/.local/bin`) is in your `$PATH` (run `echo $PATH`). Restart your shell.
*   **Permission Denied when saving (`-o`):** Check the permissions of the target directory (either the current working directory or `$AG_DEFAULT_OUTPUT_DIR`). Ensure your user has write access. Try saving to your home directory (`-o ~/response.md`).
*   **Context not saving/loading:** Ensure the context directory (`~/.local/share/ag_contexts/`) is writable. Check the contents of the `.json` files within that directory to see if they are valid JSON arrays.

## Contributing

Feel free to open issues or pull requests if you have suggestions or find bugs!

---

## 中文说明

`ag` (AI Generalist) 是一个用 Fish shell 脚本编写的简单而强大的命令行工具，允许您直接从终端通过 OpenRouter API 与 AI 模型进行交互。它支持流式响应、管理多个对话上下文、渲染 Markdown 输出以及保存对话。

灵感来源于对一个直接、基于终端、无过多重依赖的 AI 交互工具的需求。

### 功能特性

*   **直接 API 交互:** 与 OpenRouter API 的 `/chat/completions` 端点通信。
*   **流式响应:** 默认逐字显示 AI 的响应。
*   **命名上下文管理:**
    *   使用简单的命名文件 (`-s <名称>`) 维护多个独立的对话历史。
    *   列出可用的上下文 (`-l`)。
    *   删除指定的上下文 (`-d <名称>`)。
    *   默认模式为即时对话（不加载也不保存上下文）。
*   **Markdown 渲染:**
    *   可选地使用 `rich-cli` 和 `less` 在终端直接渲染 Markdown 响应 (`-m`)。
    *   当使用 `-o` 保存文件时，会自动向 AI 请求 Markdown 格式。
*   **保存响应:** 将 AI 当前的响应保存到指定文件 (`-o <路径>`)。
    *   使用 `-o` 时默认保存为 Markdown。
    *   支持绝对路径、相对路径以及可配置的默认目录 (`$AG_DEFAULT_OUTPUT_DIR`)。
    *   保存后尝试使用 `rich` 打开保存的 Markdown 文件。
*   **可定制:** 可在脚本中轻松更改默认 AI 模型或 API 端点。
*   **轻量级:** 主要依赖 `fish`, `curl`, `jq`。Markdown 功能需要 `rich-cli` 和 `less`。
*   **易于设置:** 为基于 Debian/Ubuntu 的系统提供了一键安装脚本。

### 安装 (基于 Debian/Ubuntu 的系统)

提供了一个自动化安装脚本来安装依赖项和 `ag` 函数本身。

1.  **下载安装脚本:**
    ```bash
    curl -o setup_ag_tool.sh https://raw.githubusercontent.com/YOUR_USERNAME/YOUR_REPO_NAME/main/setup_ag_tool.sh
    # 请确保将 YOUR_USERNAME 和 YOUR_REPO_NAME 替换为您的 GitHub 用户名和仓库名！
    # 或者直接克隆仓库:
    # git clone https://github.com/YOUR_USERNAME/YOUR_REPO_NAME.git
    # cd YOUR_REPO_NAME
    ```

2.  **使其可执行:**
    ```bash
    chmod +x setup_ag_tool.sh
    ```

3.  **运行脚本:**
    *   **安装并包含 Markdown 支持 (推荐):**
        ```bash
        ./setup_ag_tool.sh
        ```
    *   **安装但不包含 Markdown 支持 (跳过 `rich-cli`, `less`):**
        ```bash
        ./setup_ag_tool.sh --no-rich
        ```
    脚本将提示您选择安装语言 (英文/中文)，并使用 `apt` 和 `pipx` 安装依赖项 (`fish`, `jq`, `curl`, 以及可选的 `pipx`, `rich-cli`, `less`)。它会将 `ag.fish` 脚本放置在 `~/.config/fish/functions/`。

4.  **设置 API 密钥:** 非常重要！将您的 OpenRouter API 密钥设置为环境变量。在终端中运行此命令，并**将其添加到您的 `~/.config/fish/config.fish` 文件中**以持久化：
    ```fish
    set -gx OPENROUTER_API_KEY 'sk-or-v1-你的API密钥放在这里'
    ```
    *(替换为您的真实密钥)*

5.  **启动一个新的 Fish Shell:** 打开一个新的终端窗口或输入 `fish` 来启动新会话。这确保函数被加载并且 `PATH` 环境变量（如果被 `pipx` 修改过）得到更新。

### 使用方法

基本语法: `ag [选项] "你的提示"`

**示例:**

*   **简单查询 (流式纯文本):**
    ```fish
    ag "法国的首都是哪里？"
    ```

*   **开始或继续一个命名对话上下文:**
    ```fish
    ag -s 学习fish "Fish shell 中的函数是什么？"
    ag -s 学习fish "如何为它们定义参数？"
    ```

*   **列出已保存的上下文:**
    ```fish
    ag -l
    ```

*   **删除一个上下文:**
    ```fish
    ag -d 学习fish
    ```

*   **在终端渲染 Markdown 响应:**
    ```fish
    ag -m "用 Markdown 解释 git merge 和 rebase 的区别。"
    ```

*   **保存 Markdown 响应到文件并用 `rich` 打开:**
    ```fish
    ag -o git概念.md "用 Markdown 解释 git merge 和 rebase 的区别。"
    ```

*   **保存到指定目录:**
    ```fish
    ag -o ~/文档/笔记/api笔记.md "总结一下 OpenRouter API。"
    ```

*   **使用上下文并保存响应:**
    ```fish
    ag -s xyz项目 -o 更新.md "使用 Markdown 提供 XYZ 项目的状态更新。"
    ```

*   **查看帮助:**
    ```fish
    ag -h
    ```

### 配置

*   **API 密钥:** 必须设置 `OPENROUTER_API_KEY` 环境变量。
*   **默认输出目录:** 可选地在 `~/.config/fish/config.fish` 中设置 `AG_DEFAULT_OUTPUT_DIR` 环境变量，用于指定当 `-o` 只提供文件名时的默认保存位置。
    ```fish
    # config.fish 中的示例
    set -gx AG_DEFAULT_OUTPUT_DIR "$HOME/AI响应"
    ```
*   **模型:** 可直接编辑 `ag.fish` 文件 (`~/.config/fish/functions/ag.fish`) 来更改 `model_name` 变量。
*   **上下文目录:** 上下文文件存储在 `~/.local/share/ag_contexts/`。

### 依赖

*   **必需:** `fish` (shell), `jq`, `curl`
*   **可选 (用于 -m / -o):** `rich-cli` (Python 包, 推荐通过 `pipx` 安装), `less` (通常系统自带)

### 问题排查

*   **`command not found: ag`:** 确保在运行安装脚本后已启动新的 Fish shell 会话。检查 `~/.config/fish/functions/ag.fish` 是否存在。
*   **`command not found: rich`:** 如果您想使用 Markdown 功能，请确保 `rich-cli` 已正确安装 (运行 `pipx list` 或 `pip list`)，并且包含 `pipx` 二进制文件的目录 (通常是 `~/.local/bin`) 在您的 `$PATH` 中 (运行 `echo $PATH`)。重启您的 shell。
*   **保存时权限被拒绝 (`-o`):** 检查目标目录（当前工作目录或 `$AG_DEFAULT_OUTPUT_DIR`）的权限。确保您的用户具有写入权限。尝试保存到您的主目录 (`-o ~/response.md`)。
*   **上下文未保存/加载:** 确保上下文目录 (`~/.local/share/ag_contexts/`) 可写。检查该目录下的 `.json` 文件内容是否为有效的 JSON 数组。

### 贡献
这只是一个由 ai 生成的小玩具，难免有许多漏洞，你可以来尝试修改使其变得更加方便！
