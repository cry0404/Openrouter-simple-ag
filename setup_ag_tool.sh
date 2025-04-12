#!/bin/bash

# Exit immediately if a command exits with a non-zero status.
set -e
# set -u # Uncomment for stricter variable checking
set -o pipefail

# --- Configuration ---
INSTALL_RICH=true # Default to installing rich-cli and less

# --- Argument Parsing ---
TEMP=$(getopt -o '' --long no-rich,help -n "$0" -- "$@")
if [ $? != 0 ] ; then echo "Terminating..." >&2 ; exit 1 ; fi
eval set -- "$TEMP"
unset TEMP

while true; do
  case "$1" in
    '--no-rich' ) INSTALL_RICH=false; shift ;;
    '--help' )
      echo "Usage: $0 [--no-rich]"
      echo "  Installs the 'ag' AI assistant tool and its dependencies."
      echo "  --no-rich   Skip installation of rich-cli and less (disables Markdown rendering)."
      exit 0 ;;
    '--' ) shift; break ;;
    * ) break ;;
  esac
done

# --- Language Selection ---
SCRIPT_LANG=""
while [[ "$SCRIPT_LANG" != "en" && "$SCRIPT_LANG" != "zh" ]]; do
    read -p "Please choose language (请输入语言) [en/zh]: " SCRIPT_LANG
    SCRIPT_LANG=$(echo "$SCRIPT_LANG" | tr '[:upper:]' '[:lower:]')
    if [[ "$SCRIPT_LANG" != "en" && "$SCRIPT_LANG" != "zh" ]]; then
        echo "Invalid input. Please enter 'en' or 'zh'."
        echo "无效输入，请输入 'en' 或 'zh'。"
    fi
done
echo "Language set to: $SCRIPT_LANG"
echo "语言设置为: $SCRIPT_LANG"
echo

# --- Message Definitions (Same as previous version) ---
# ... (Message definitions remain the same) ...
# --- English Messages ---
MSG_ERR_NOROOT_EN="This script should not be run as root. Please run as your regular user."
MSG_ERR_NOAPT_EN="This script requires 'apt' package manager (Debian/Ubuntu based systems)."
MSG_INFO_START_EN="Starting setup for the 'ag' AI assistant tool..."
MSG_INFO_UPDATE_APT_EN="Updating package lists (requires sudo)..."
MSG_ERR_UPDATE_APT_FAILED_EN="Failed to update package lists."
MSG_INFO_INSTALL_PKGS_EN="Installing base packages: fish, jq, curl (requires sudo)..."
MSG_INFO_INSTALL_PKGS_RICH_EN="Installing optional packages for Markdown: pipx, less (requires sudo)..."
MSG_ERR_INSTALL_PKGS_FAILED_EN="Failed to install required packages."
MSG_INFO_PKGS_INSTALLED_EN="System packages installed successfully."
MSG_INFO_SETUP_PIPX_EN="Setting up pipx..."
MSG_WARN_PIPX_PATH_FAILED_EN="pipx ensurepath command failed. You might need to manually add pipx binary path to your PATH."
MSG_WARN_PIPX_PATH_RESTART_EN="Check pipx documentation or run 'pipx ensurepath' again after restarting your shell."
MSG_INFO_PIPX_RESTART_NOTE_EN="pipx setup command executed. You might need to restart your shell or source ~/.profile for PATH changes to take effect."
MSG_INFO_INSTALL_RICH_EN="Installing rich-cli using pipx..."
MSG_INFO_RICH_FOUND_EN="'rich' command already found. Skipping installation."
MSG_INFO_RICH_INSTALLED_EN="rich-cli installed successfully via pipx."
MSG_WARN_RICH_NOT_FOUND_EN="Installed rich-cli via pipx, but 'rich' command not found immediately. Restart your shell or check PATH."
MSG_ERR_RICH_INSTALL_FAILED_EN="Failed to install rich-cli using pipx."
MSG_INFO_SKIPPING_RICH_EN="Skipping installation of rich-cli and less as requested."
MSG_INFO_CREATE_FISH_DIRS_EN="Creating Fish configuration directories (if they don't exist)..."
MSG_ERR_CREATE_FISH_DIRS_FAILED_EN="Failed to create Fish function directory: \$1"
MSG_INFO_FISH_DIR_ENSURED_EN="Directory ensured: \$1"
MSG_INFO_CREATE_AG_FILE_EN="Creating the 'ag.fish' function file..."
MSG_INFO_AG_FILE_CREATED_EN="'ag.fish' function file created successfully at \$1"
MSG_ERR_AG_FILE_FAILED_EN="Failed to create 'ag.fish' file!"
MSG_INFO_SETUP_COMPLETE_EN="Setup complete!"
MSG_INFO_SEPARATOR_EN="--------------------------------------------------"
MSG_INFO_NEXT_STEPS_EN="IMPORTANT NEXT STEPS:"
MSG_INFO_SET_API_KEY_EN="1. Set your OpenRouter API Key:"
MSG_INFO_RUN_COMMAND_EN="   Run this command in your terminal (and ideally add it to your Fish config):"
MSG_INFO_API_KEY_EXAMPLE_EN="(Replace 'sk-or-v1-YOUR-API-KEY-HERE' with your actual key)"
MSG_INFO_START_FISH_EN="2. Start using the 'ag' command in a NEW Fish shell:"
MSG_INFO_FISH_HOWTO_EN="   - If Fish is not your default shell, type: fish"
MSG_INFO_FISH_DEFAULT_EN="   - If Fish IS your default shell, simply open a new terminal window."
MSG_INFO_FISH_CHSH_EN="   - (Optional) To make Fish your default shell permanently, run: chsh -s \"\$(command -v fish)\""
MSG_INFO_EXAMPLE_USAGE_EN="3. Example Usage:"
MSG_INFO_ENJOY_EN="Enjoy your AI assistant!"
MSG_INFO_RICH_DISABLED_NOTE_EN="Note: Markdown rendering (-m, -o) requires rich-cli and less, which were skipped."

# --- Chinese Messages (中文消息) ---
MSG_ERR_NOROOT_ZH="请不要以 root 用户身份运行此脚本。请使用您的普通用户运行。"
MSG_ERR_NOAPT_ZH="此脚本需要 'apt' 包管理器 (适用于 Debian/Ubuntu 系统)。"
MSG_INFO_START_ZH="开始设置 'ag' AI 助手工具..."
MSG_INFO_UPDATE_APT_ZH="正在更新软件包列表 (需要 sudo 权限)..."
MSG_ERR_UPDATE_APT_FAILED_ZH="更新软件包列表失败。"
MSG_INFO_INSTALL_PKGS_ZH="正在安装基础软件包: fish, jq, curl (需要 sudo 权限)..."
MSG_INFO_INSTALL_PKGS_RICH_ZH="正在安装 Markdown 功能所需的可选软件包: pipx, less (需要 sudo 权限)..."
MSG_ERR_INSTALL_PKGS_FAILED_ZH="安装所需软件包失败。"
MSG_INFO_PKGS_INSTALLED_ZH="系统软件包安装成功。"
MSG_INFO_SETUP_PIPX_ZH="正在设置 pipx..."
MSG_WARN_PIPX_PATH_FAILED_ZH="pipx ensurepath 命令失败。您可能需要手动将 pipx 二进制文件路径添加到 PATH。"
MSG_WARN_PIPX_PATH_RESTART_ZH="请查阅 pipx 文档或在重启 shell 后再次运行 'pipx ensurepath'。"
MSG_INFO_PIPX_RESTART_NOTE_ZH="pipx 设置命令已执行。您可能需要重启 shell 或 source ~/.profile 以使 PATH 更改生效。"
MSG_INFO_INSTALL_RICH_ZH="正在使用 pipx 安装 rich-cli..."
MSG_INFO_RICH_FOUND_ZH="已找到 'rich' 命令。跳过安装。"
MSG_INFO_RICH_INSTALLED_ZH="已通过 pipx 成功安装 rich-cli。"
MSG_WARN_RICH_NOT_FOUND_ZH="已通过 pipx 安装 rich-cli，但未能立即找到 'rich' 命令。请重启 shell 或检查 PATH。"
MSG_ERR_RICH_INSTALL_FAILED_ZH="使用 pipx 安装 rich-cli 失败。"
MSG_INFO_SKIPPING_RICH_ZH="已根据请求跳过安装 rich-cli 和 less。"
MSG_INFO_CREATE_FISH_DIRS_ZH="正在创建 Fish 配置目录 (如果不存在)..."
MSG_ERR_CREATE_FISH_DIRS_FAILED_ZH="创建 Fish 函数目录失败: \$1"
MSG_INFO_FISH_DIR_ENSURED_ZH="目录已确保存在: \$1"
MSG_INFO_CREATE_AG_FILE_ZH="正在创建 'ag.fish' 函数文件..."
MSG_INFO_AG_FILE_CREATED_ZH="'ag.fish' 函数文件已成功创建于 \$1"
MSG_ERR_AG_FILE_FAILED_ZH="创建 'ag.fish' 文件失败！"
MSG_INFO_SETUP_COMPLETE_ZH="设置完成！"
MSG_INFO_SEPARATOR_ZH="--------------------------------------------------"
MSG_INFO_NEXT_STEPS_ZH="重要后续步骤："
MSG_INFO_SET_API_KEY_ZH="1. 设置您的 OpenRouter API 密钥："
MSG_INFO_RUN_COMMAND_ZH="   在终端中运行此命令 (并建议将其添加到您的 Fish 配置中)："
MSG_INFO_API_KEY_EXAMPLE_ZH="(将 'sk-or-v1-YOUR-API-KEY-HERE' 替换为您的真实密钥)"
MSG_INFO_START_FISH_ZH="2. 在一个新的 Fish shell 中开始使用 'ag' 命令："
MSG_INFO_FISH_HOWTO_ZH="   - 如果 Fish 不是您的默认 shell，请输入: fish"
MSG_INFO_FISH_DEFAULT_ZH="   - 如果 Fish 是您的默认 shell，只需打开一个新的终端窗口。"
MSG_INFO_FISH_CHSH_ZH="   - (可选) 要将 Fish 永久设置为默认 shell，请运行: chsh -s \"\$(command -v fish)\""
MSG_INFO_EXAMPLE_USAGE_ZH="3. 使用示例："
MSG_INFO_ENJOY_ZH="祝您使用 AI 助手愉快！"
MSG_INFO_RICH_DISABLED_NOTE_ZH="注意：Markdown 渲染 (-m, -o) 需要 rich-cli 和 less，这些已被跳过安装。"


# --- Helper Function for Messages (Corrected version) ---
print_message() {
    local key=$1
    shift
    local msg_var_en="MSG_${key}_EN"
    local msg_var_zh="MSG_${key}_ZH"
    local chosen_msg=""
    if [[ "$SCRIPT_LANG" == "zh" ]] && declare -p "$msg_var_zh" &>/dev/null; then chosen_msg="${!msg_var_zh}"; elif declare -p "$msg_var_en" &>/dev/null; then chosen_msg="${!msg_var_en}"; else echo "WARN: Message key '$key' not found." >&2; return 1; fi;
    local i=1; for arg in "$@"; do escaped_arg=$(echo "$arg" | sed -e 's/[\/&]/\\&/g'); chosen_msg=$(echo "$chosen_msg" | sed "s|\\\$$i|$escaped_arg|g"); i=$((i + 1)); done; echo "$chosen_msg"
}

# --- Wrapper Functions ---
print_info() { print_message "$@"; }
print_warning() { print_message "$@" >&2; }
print_error() { print_message "$@" >&2; exit 1; }

# Function to check if a command exists
command_exists() { command -v "$1" >/dev/null 2>&1; }

# --- Configuration Variables ---
FISH_CONFIG_DIR="$HOME/.config/fish"
FISH_FUNC_DIR="$FISH_CONFIG_DIR/functions"
AG_SCRIPT_PATH="$FISH_FUNC_DIR/ag.fish"

# --- Pre-checks ---
if [[ $EUID -eq 0 ]]; then print_error ERR_NOROOT; fi
if ! command_exists apt; then print_error ERR_NOAPT; fi

# --- Main Setup Logic ---
print_info INFO_START

# 1. Update package lists and install base packages
print_info INFO_UPDATE_APT
sudo apt update || print_error ERR_UPDATE_APT_FAILED

print_info INFO_INSTALL_PKGS
sudo apt install -y fish jq curl || print_error ERR_INSTALL_PKGS_FAILED
print_info INFO_PKGS_INSTALLED

# 2. Conditionally install Markdown rendering dependencies
if [[ "$INSTALL_RICH" == true ]]; then
    print_info INFO_INSTALL_PKGS_RICH
    sudo apt install -y pipx less || print_error ERR_INSTALL_PKGS_FAILED
    print_info INFO_SETUP_PIPX
    if ! pipx ensurepath; then print_warning WARN_PIPX_PATH_FAILED; print_warning WARN_PIPX_PATH_RESTART; fi
    print_info INFO_PIPX_RESTART_NOTE
    print_info INFO_INSTALL_RICH
    if command_exists rich; then print_info INFO_RICH_FOUND; else if pipx install rich-cli; then print_info INFO_RICH_INSTALLED; if ! command_exists rich; then print_warning WARN_RICH_NOT_FOUND; fi; else print_error ERR_RICH_INSTALL_FAILED; fi; fi
else
    print_info INFO_SKIPPING_RICH
fi

# 3. Create Fish configuration directories
print_info INFO_CREATE_FISH_DIRS
mkdir -p "$FISH_FUNC_DIR" || print_error ERR_CREATE_FISH_DIRS_FAILED "$FISH_FUNC_DIR"
print_info INFO_FISH_DIR_ENSURED "$FISH_FUNC_DIR"

# 4. Create the ag.fish function file
print_info INFO_CREATE_AG_FILE

# --- !!! CORRECTED ag.fish content embedded below !!! ---
cat << 'EOF' > "$AG_SCRIPT_PATH"
# 函数：ag - 向 OpenRouter API 提问，支持流式、多文件上下文、保存响应、Markdown 渲染
# 用法: ag [-s <ctx>] [-l] [-d <ctx>] [-m] [-o <file>] [-h] "你的问题是什么？"
# 警告：此命令名 'ag' 可能覆盖 The Silver Searcher 工具！
function ag --description "ag: 向 OpenRouter 提问，可选多文件上下文、保存/rich查看、终端Markdown渲染"

    # --- 配置 ---
    set -l CONTEXT_DIR "$HOME/.local/share/ag_contexts"
    mkdir -p "$CONTEXT_DIR" # 确保上下文目录存在
    # --- 配置结束 ---

    # --- 参数解析 ---
    set -l options (fish_opt -s l -l list)        # 列出上下文
    set -l options $options (fish_opt -s s -l select -r) # 选择/创建上下文 (需要名字)
    set -l options $options (fish_opt -s d -l delete -r) # 删除上下文 (需要名字)
    set -l options $options (fish_opt -s m -l markdown)    # 终端渲染 Markdown
    set -l options $options (fish_opt -s o -l output -r)    # 保存当前响应到文件
    set -l options $options (fish_opt -s h -l help)        # 帮助
    argparse $options -- $argv
    if test $status -ne 0; return 1; end

    # --- 处理独占操作: List / Delete / Help ---
    if set -q _flag_help
        echo "用法: ag [选项] \"<你的问题>\""
        echo ""
        echo "向 OpenRouter API 提问，支持多种输出方式："
        echo "  1. 默认：流式纯文本输出到终端。"
        echo "  2. -o <路径>: 保存 Markdown 到 <路径> 并用 'rich --markdown' 打开查看。"
        echo "  3. -m: 在终端渲染 Markdown (需 rich/less, 无 -o 时使用)。"
        echo "警告：此命令名 'ag' 可能覆盖 The Silver Searcher 工具。"
        echo ""
        echo "选项:"
        printf "  %-25s %s\n" "-s <名称>, --select <名称>" "选择或创建指定名称的上下文进行对话"
        printf "  %-25s %s\n" " " "  (对话结束后会自动保存回该文件)"
        printf "  %-25s %s\n" "-l, --list" "列出所有已保存的上下文名称"
        printf "  %-25s %s\n" "-d <名称>, --delete <名称>" "删除指定名称的上下文文件"
        printf "  %-25s %s\n" "-m, --markdown" "请求 Markdown 格式并在终端渲染 (需 rich/less)"
        printf "  %-25s %s\n" "-o <路径>, --output <路径>" "将本次 AI 响应保存到指定文件"
        printf "  %-25s %s\n" " " "  (若同时用 -m 或默认, 请求 Markdown; 否则纯文本)"
        printf "  %-25s %s\n" " " "  (保存前会尝试创建目录 (mkdir -p))"
        printf "  %-25s %s\n" " " "  (保存后会尝试用 'rich' 打开文件)"
        printf "  %-25s %s\n" "-h, --help" "显示此帮助信息并退出"
        echo ""
        echo "上下文存储目录: $CONTEXT_DIR"
        # --- CORRECTED: Use Fish syntax for checking/printing env var ---
        set -l default_dir_status
        if set -q AG_DEFAULT_OUTPUT_DIR; and test -n "$AG_DEFAULT_OUTPUT_DIR"
            set default_dir_status "$AG_DEFAULT_OUTPUT_DIR"
        else
            set default_dir_status "未设置"
        end
        echo "默认输出目录 (\$AG_DEFAULT_OUTPUT_DIR): $default_dir_status"
        # --- End Correction ---
        echo ""
        echo "依赖: jq. 可选: rich-cli, less (用于 -m 无 -o)"
        echo ""
        echo "示例:"
        echo "  ag \"你好\"                         # 即时对话"
        echo "  ag -s projectA \"开始讨论项目A\"      # 使用或创建 projectA 上下文"
        echo "  ag -s projectA \"继续讨论...\"       # 继续 projectA 对话"
        echo "  ag -l                             # 查看有哪些上下文"
        echo "  ag -d projectA                    # 删除 projectA 上下文"
        echo "  ag -o out.md -s projB \"...\"     # 使用 projB 上下文, 保存响应并用 rich 打开"
        return 0
    end

    if set -q _flag_list
        echo "可用的上下文 (在 $CONTEXT_DIR):"
        set context_files (find "$CONTEXT_DIR" -maxdepth 1 -name '*.json' -printf '%f\n' 2>/dev/null | string replace '.json' '')
        if test (count $context_files) -gt 0; for file in $context_files; echo "- "$file; end; else; echo "(无)"; end
        return 0
    end

    if set -q _flag_delete
        set context_name_to_delete $_flag_delete
        set context_file_to_delete "$CONTEXT_DIR/$context_name_to_delete.json"
        if test -e "$context_file_to_delete"
            rm "$context_file_to_delete"; if test $status -eq 0; echo "✅ 已删除上下文 '$context_name_to_delete' ($context_file_to_delete)" >&2; return 0; else; echo "错误: 无法删除上下文文件 '$context_file_to_delete'" >&2; return 1; end
        else; echo "错误: 上下文 '$context_name_to_delete' 不存在 ($context_file_to_delete)" >&2; return 1; end
    end

    # --- 确定最终输出文件路径 (-o 选项) ---
    set -l output_file ""
    if set -q _flag_output
        set -l user_output_spec $_flag_output
        if string match -q -r '^/' -- "$user_output_spec"; set output_file $user_output_spec
        else if string match -q '~/*' -- "$user_output_spec"; set output_file (string replace -r '^~' "$HOME" "$user_output_spec")
        else if test "$user_output_spec" = "~"; set output_file $HOME
        else if string match -q '*/*' -- "$user_output_spec"; set output_file $user_output_spec
        else
            if set -q AG_DEFAULT_OUTPUT_DIR; and test -n "$AG_DEFAULT_OUTPUT_DIR"; and test -d "$AG_DEFAULT_OUTPUT_DIR"; set output_file "$AG_DEFAULT_OUTPUT_DIR/$user_output_spec"; else; set output_file "$user_output_spec"; end
        end
    end

    # --- 前置检查 ---
    if not set -q OPENROUTER_API_KEY; echo "错误：请设置 OPENROUTER_API_KEY 环境变量。" >&2; return 1; end
    if not command -q jq; echo "错误：需要 'jq'。" >&2; return 1; end
    if set -q _flag_output; or set -q _flag_markdown
        if not command -q rich
            echo "错误：选项 -o 或 -m 需要 'rich-cli'。请确认已安装或重新运行安装脚本不带 --no-rich。" >&2
            return 1
        end
    end
    if set -q _flag_markdown; and not set -q _flag_output
        if not command -q less; echo "错误：选项 -m (无 -o) 需要 'less'。" >&2; return 1; end
    end

    # --- 参数和 Prompt 处理 ---
    if test (count $argv) -eq 0; echo "错误：缺少用户问题。" >&2; echo "用法: ag [选项] \"<你的问题>\"" >&2; return 1; end
    set -l user_prompt (string join ' ' $argv)

    # --- 上下文处理 (基于 -s <name>) ---
    set -l messages_json_array '[]'
    set -l selected_context_name ""
    set -l context_file_to_use "" # 文件路径
    if set -q _flag_select
        set selected_context_name $_flag_select
        set context_file_to_use "$CONTEXT_DIR/$selected_context_name.json"
        echo "ℹ️ 使用上下文: '$selected_context_name'" >&2
        if test -e "$context_file_to_use"
            set messages_json_array (cat "$context_file_to_use" 2>/dev/null)
            if test $status -ne 0; or test -z "$messages_json_array"; echo "警告: 无法读取或上下文文件为空 '$context_file_to_use'. 将创建新上下文。" >&2; set messages_json_array '[]';
            else if not echo "$messages_json_array" | jq -e 'type == "array"' > /dev/null 2>&1; echo "警告: 上下文文件 '$context_file_to_use' 内容不是有效的 JSON 数组。将创建新上下文。" >&2; set messages_json_array '[]'; end; end
        else; echo "✨ 上下文文件 '$context_file_to_use' 不存在，将创建新的对话。" >&2; end
    end

    # --- 配置 System Prompt ---
    set -l system_prompt_base "根据需要进行适当的换行和分段。回答尽量详细，将我当作小白来解释。"
    set -l system_prompt_format_instruction
    if set -q _flag_output; or set -q _flag_markdown # 如果保存文件或请求 markdown 渲染
        set system_prompt_format_instruction "请使用 Markdown 格式进行回复（包括代码块、列表、加粗等）。"
    else
        set system_prompt_format_instruction "请始终使用纯文本格式进行回复,可以使用emoji,但也不宜太多。绝对不要使用任何Markdown标记（如\`*\`、\`#\`、\` \`\`\` \`、\\"-\\"等），因为输出环境是终端。"
    end
    set -l system_prompt "$system_prompt_format_instruction $system_prompt_base"
    set -l model_name "deepseek/deepseek-chat-v3-0324:free"
    set -l api_endpoint "https://openrouter.ai/api/v1/chat/completions"

    # --- 请求准备 ---
    set -l current_call_messages (jq -n --arg content "$system_prompt" '[{"role": "system", "content": $content}]')
    if test $status -ne 0; echo "错误: 构建系统消息失败。" >&2; return 1; end
    if test -n "$messages_json_array"; and echo "$messages_json_array" | jq -e 'type == "array"' > /dev/null 2>&1 # 合并有效历史
        set current_call_messages (echo $current_call_messages $messages_json_array | jq -s '.[0] + .[1]')
        if test $status -ne 0; echo "错误: 合并历史消息失败。" >&2; return 1; end
    end
    set current_call_messages (echo $current_call_messages | jq --arg content "$user_prompt" '. + [{"role": "user", "content": $content}]')
    if test $status -ne 0; echo "错误: 添加用户消息失败。" >&2; return 1; end

    # --- 构建 API 请求体 ---
    set -l json_payload (jq -n --arg model "$model_name" --argjson messages "$current_call_messages" '{"model": $model, "messages": $messages, "stream": true}')
    if test $status -ne 0; echo "错误：使用 jq 构建最终 JSON 载荷失败。" >&2; return 1; end

    # --- API 调用和流式处理 ---
    echo "🤔 正在向 cry 的赛博助手 $model_name 请求帮助😎..." >&2
    if test -n "$selected_context_name"; echo "(使用上下文: $selected_context_name)" >&2; end # Display context name if used
    if not set -q _flag_output; and not set -q _flag_markdown; echo "🤖 :"; end

    set -l full_response ""
    set -l curl_exit_status -1
    set -l process_exit_status -1

    begin # pipeline start
        curl --silent --no-buffer -X POST "$api_endpoint" \
            -H "Content-Type: application/json" \
            -H "Authorization: Bearer $OPENROUTER_API_KEY" \
            -d "$json_payload" | while read -l line
            if string match -q "data: *" -- "$line"
                set json_chunk (string sub -s 7 -- "$line")
                if test "$json_chunk" = "[DONE]"; break; end
                set api_error (echo "$json_chunk" | jq -r '.error.message // ""')
                if test -n "$api_error"; echo "API 错误: $api_error" >&2; continue; end
                set text_chunk (echo "$json_chunk" | jq -r '.choices[0].delta.content // ""')
                if test $status -ne 0; echo "警告：解析 JSON 块失败: $json_chunk" >&2
                else
                    if not set -q _flag_output; and not set -q _flag_markdown; printf '%s' "$text_chunk"; end
                    set full_response "$full_response$text_chunk"
                end
            end
        end # while end
    end # pipeline end
    set curl_exit_status $pipestatus[1]
    set process_exit_status $pipestatus[-1]

    # --- 后处理、保存响应、终端渲染或添加换行 ---
    if test $curl_exit_status -ne 0; echo "错误:curl 命令失败 (状态码: $curl_exit_status)..." >&2; return 1; end
    if test $process_exit_status -ne 0; echo "警告：While 循环处理过程异常结束 (状态码: $process_exit_status)..." >&2; end

    set -l save_status 0; set -l render_status 0
    # 处理 -o (保存当前响应)
    if test -n "$output_file"; and test $curl_exit_status -eq 0; and test $process_exit_status -eq 0; and test -n "$full_response"
        set output_dir (dirname "$output_file"); if not test -d "$output_dir"; mkdir -p "$output_dir"; if test $status -ne 0; echo "错误：无法创建目录 '$output_dir'" >&2; set save_status 1; end; end
        if test $save_status -eq 0; printf '%s' "$full_response" > "$output_file"; set save_status $status; end
        if test $save_status -eq 0
            echo "✅ 本次响应已保存到: $output_file" >&2
            if test -e "$output_file"; if command -q rich; echo "ℹ️ 正在使用 rich --markdown 打开文件..." >&2; rich --markdown "$output_file"; set render_status $status; if test $render_status -ne 0; echo "警告: rich 命令未能成功显示文件 (状态码: $render_status)" >&2; end; else; echo "警告: 未找到 rich 命令，无法自动打开文件。" >&2; end; else; echo "错误：文件 '$output_file' 在保存后未能找到！无法打开。" >&2; set save_status 1; end
        else; echo "错误：无法将响应写入文件 '$output_file' (状态码: $save_status)" >&2; end
    # 处理 -m 且无 -o (终端渲染)
    else if not set -q _flag_output; and set -q _flag_markdown; and test $curl_exit_status -eq 0; and test $process_exit_status -eq 0; and test -n "$full_response"
        set -l tmp_file "/tmp/ag_render."(random)".md"; printf '%s' "$full_response" > "$tmp_file"
        if test $status -eq 0; rich "$tmp_file" | less -R; set render_status $pipestatus[1]; if test $render_status -ne 0; echo "警告: rich 命令渲染可能出错 (状态码: $render_status)" >&2; end; rm "$tmp_file"; else; echo "错误: 无法创建临时文件进行渲染" >&2; echo "$full_response"; set render_status 1; end
    # 处理默认流式输出的换行
    else if not set -q _flag_output; and not set -q _flag_markdown; and test $curl_exit_status -eq 0; and test $process_exit_status -eq 0; echo
    # 处理错误时的换行
    else if test $process_exit_status -ne 0; echo; end

    # --- 上下文保存 (基于 -s <name>) ---
    if test -n "$selected_context_name"; and test $curl_exit_status -eq 0; and test $process_exit_status -eq 0; and test -n "$full_response"
        set context_file_to_save "$CONTEXT_DIR/$selected_context_name.json"
        set -l updated_context_json
        set -l jq_status -1
        set updated_context_json (echo $messages_json_array | jq --arg user_msg "$user_prompt" --arg assistant_msg "$full_response" '. + [{"role": "user", "content": $user_msg}, {"role": "assistant", "content": $assistant_msg}]')
        set jq_status $status
        if test $jq_status -eq 0
            if test "$updated_context_json" != "$messages_json_array" # 仅当内容变化时写入
                 printf '%s\n' "$updated_context_json" > "$context_file_to_save"
                 if test $status -ne 0; echo "错误：无法将更新后的上下文写入文件 '$context_file_to_save'" >&2; end
            fi
        else; echo "错误：使用 jq 更新内存中的上下文失败 (状态码: $jq_status)。上下文未保存到文件。" >&2; end
    end

    # --- 最终返回码 ---
    if test $curl_exit_status -ne 0; or test $process_exit_status -ne 0; or test $save_status -ne 0; or test $render_status -ne 0
        return 1
    end
    return 0
end # <--- 函数定义的唯一结束 end

EOF

# Check if the file was created successfully
if [[ -f "$AG_SCRIPT_PATH" ]]; then
    print_info INFO_AG_FILE_CREATED "$AG_SCRIPT_PATH"
else
    print_error ERR_AG_FILE_FAILED
fi

# --- Final Instructions ---
echo ""
print_info INFO_SETUP_COMPLETE
print_info INFO_SEPARATOR # Use a key for the separator
echo ""
print_info INFO_NEXT_STEPS
echo ""
print_info INFO_SET_API_KEY
print_info INFO_RUN_COMMAND
echo "   set -gx OPENROUTER_API_KEY 'sk-or-v1-YOUR-API-KEY-HERE'"
print_info INFO_API_KEY_EXAMPLE
echo ""
print_info INFO_START_FISH
print_info INFO_FISH_HOWTO
print_info INFO_FISH_DEFAULT
print_info INFO_FISH_CHSH
echo ""
print_info INFO_EXAMPLE_USAGE
echo "   ag \"Explain the theory of relativity simply.\""
echo "   ag -s projectX \"Start a new chat for project X\""
echo "   ag -l"
echo "   ag -m -s projectX \"Continue project X discussion with Markdown\""
echo "   ag -o response.md \"Save this response\""
echo ""
if [[ "$INSTALL_RICH" == false ]]; then
    print_info INFO_RICH_DISABLED_NOTE
fi
print_info ENJOY

exit 0
