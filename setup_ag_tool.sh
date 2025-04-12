#!/bin/bash

# Exit immediately if a command exits with a non-zero status.
set -e
# set -u # Uncomment for stricter variable checking
set -o pipefail

# --- Configuration ---
UNINSTALL=false # Flag for uninstall action

# --- Argument Parsing ---
TEMP=$(getopt -o '' --long uninstall,help -n "$0" -- "$@")
if [ $? != 0 ] ; then echo "Terminating..." >&2 ; exit 1 ; fi
eval set -- "$TEMP"
unset TEMP

while true; do
  case "$1" in
    '--uninstall' ) UNINSTALL=true; shift ;;
    '--help' )
      echo "Usage: $0 [--uninstall|--help]"
      echo "  Installs the 'ag' AI assistant tool and its dependencies (fish, jq, curl)."
      echo "  --uninstall   Removes the 'ag' function file and prompts to remove context data."
      echo "  --help        Show this help message."
      exit 0 ;;
    '--' ) shift; break ;;
    * ) break ;;
  esac
done

# --- !!! Language Selection (Only needed for Install/Messages) !!! ---
SCRIPT_LANG=""
if [[ "$UNINSTALL" == false ]]; then
    while [[ "$SCRIPT_LANG" != "en" && "$SCRIPT_LANG" != "zh" ]]; do
        # Prompt in both languages initially
        read -p "Please choose language (请输入语言) [en/zh]: " SCRIPT_LANG
        # Convert to lowercase
        SCRIPT_LANG=$(echo "$SCRIPT_LANG" | tr '[:upper:]' '[:lower:]')
        if [[ "$SCRIPT_LANG" != "en" && "$SCRIPT_LANG" != "zh" ]]; then
            echo "Invalid input. Please enter 'en' or 'zh'."
            echo "无效输入，请输入 'en' 或 'zh'。"
        fi
    done
    echo "Language set to: $SCRIPT_LANG"
    echo "语言设置为: $SCRIPT_LANG"
    echo # Add a newline for spacing
else
    # Default to English for uninstall messages if language prompt is skipped
    SCRIPT_LANG="en"
fi


# --- Message Definitions (Removed Rich/Output related messages, Added Uninstall messages) ---
# --- English Messages ---
MSG_ERR_NOROOT_EN="This script should not be run as root. Please run as your regular user."
MSG_ERR_NOAPT_EN="This script requires 'apt' package manager (Debian/Ubuntu based systems)."
MSG_INFO_START_EN="Starting setup for the 'ag' AI assistant tool..."
MSG_INFO_UPDATE_APT_EN="Updating package lists (requires sudo)..."
MSG_ERR_UPDATE_APT_FAILED_EN="Failed to update package lists."
MSG_INFO_INSTALL_PKGS_EN="Installing required packages: fish, jq, curl (requires sudo)..."
MSG_ERR_INSTALL_PKGS_FAILED_EN="Failed to install required packages."
MSG_INFO_PKGS_INSTALLED_EN="System packages installed successfully."
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
MSG_INFO_UNINSTALL_START_EN="Starting uninstallation of the 'ag' tool..."
MSG_INFO_REMOVE_AG_FILE_EN="Removing 'ag.fish' function file: \$1"
MSG_ERR_REMOVE_AG_FILE_FAILED_EN="Failed to remove 'ag.fish' file: \$1"
MSG_INFO_AG_FILE_REMOVED_EN="'ag.fish' file removed successfully."
MSG_PROMPT_CONFIRM_UNINSTALL_CONTEXT_EN="Do you want to remove the context data directory (\$1)? This will delete all saved chat histories. [y/N]: "
MSG_INFO_SKIPPING_CONTEXT_REMOVAL_EN="Skipping removal of context directory."
MSG_INFO_REMOVE_CONTEXT_DIR_EN="Removing context data directory: \$1"
MSG_ERR_REMOVE_CONTEXT_DIR_FAILED_EN="Failed to remove context directory: \$1"
MSG_INFO_CONTEXT_DIR_REMOVED_EN="Context directory removed successfully."
MSG_INFO_UNINSTALL_COMPLETE_EN="Uninstallation complete."
MSG_INFO_UNINSTALL_PKGS_MANUAL_EN="Note: System packages (fish, jq, curl) were NOT automatically removed. You can remove them manually if no longer needed (e.g., 'sudo apt remove fish jq curl')."

# --- Chinese Messages (中文消息) ---
MSG_ERR_NOROOT_ZH="请不要以 root 用户身份运行此脚本。请使用您的普通用户运行。"
MSG_ERR_NOAPT_ZH="此脚本需要 'apt' 包管理器 (适用于 Debian/Ubuntu 系统)。"
MSG_INFO_START_ZH="开始设置 'ag' AI 助手工具..."
MSG_INFO_UPDATE_APT_ZH="正在更新软件包列表 (需要 sudo 权限)..."
MSG_ERR_UPDATE_APT_FAILED_ZH="更新软件包列表失败。"
MSG_INFO_INSTALL_PKGS_ZH="正在安装所需软件包: fish, jq, curl (需要 sudo 权限)..."
MSG_ERR_INSTALL_PKGS_FAILED_ZH="安装所需软件包失败。"
MSG_INFO_PKGS_INSTALLED_ZH="系统软件包安装成功。"
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
MSG_INFO_ENJOY_ZH="祝您使用 AI 助手愉快😜，它应该不会出错了，closeai 就是垃圾！"
MSG_INFO_UNINSTALL_START_ZH="开始卸载 'ag' 工具..."
MSG_INFO_REMOVE_AG_FILE_ZH="正在移除 'ag.fish' 函数文件: \$1"
MSG_ERR_REMOVE_AG_FILE_FAILED_ZH="移除 'ag.fish' 文件失败: \$1"
MSG_INFO_AG_FILE_REMOVED_ZH="'ag.fish' 文件移除成功。"
MSG_PROMPT_CONFIRM_UNINSTALL_CONTEXT_ZH="您想移除上下文数据目录 (\$1) 吗？这将删除所有已保存的聊天记录。 [y/N]: "
MSG_INFO_SKIPPING_CONTEXT_REMOVAL_ZH="跳过移除上下文目录。"
MSG_INFO_REMOVE_CONTEXT_DIR_ZH="正在移除上下文数据目录: \$1"
MSG_ERR_REMOVE_CONTEXT_DIR_FAILED_ZH="移除上下文目录失败: \$1"
MSG_INFO_CONTEXT_DIR_REMOVED_ZH="上下文目录移除成功。"
MSG_INFO_UNINSTALL_COMPLETE_ZH="卸载完成。"
MSG_INFO_UNINSTALL_PKGS_MANUAL_ZH="注意：系统软件包 (fish, jq, curl) 未被自动移除。如果不再需要，您可以手动移除它们 (例如 'sudo apt remove fish jq curl')。"


# --- Helper Function for Messages (Corrected version) ---
print_message() {
    local key=$1
    shift # Remove the key, remaining args are for placeholders
    local msg_var_en="MSG_${key}_EN"
    local msg_var_zh="MSG_${key}_ZH"
    local chosen_msg=""

    # Select the message based on language
    if [[ "$SCRIPT_LANG" == "zh" ]] && declare -p "$msg_var_zh" &>/dev/null; then
        chosen_msg="${!msg_var_zh}"
    elif declare -p "$msg_var_en" &>/dev/null; then
         chosen_msg="${!msg_var_en}"
    else
         echo "WARN: Message key '$key' not found." >&2
         return 1
    fi

    # Replace placeholders $1, $2, etc. with actual arguments using sed
    local i=1
    for arg in "$@"; do
        # Use sed for safer replacement, escape backslashes and delimiter
        escaped_arg=$(echo "$arg" | sed -e 's/[\/&]/\\&/g')
        chosen_msg=$(echo "$chosen_msg" | sed "s|\\\$$i|$escaped_arg|g")
        i=$((i + 1))
    done
    echo "$chosen_msg"
}

# --- Wrapper Functions ---
print_info() { print_message "$@"; }
print_warning() { print_message "$@" >&2; }
print_error() { print_message "$@" >&2; exit 1; }
# Special prompt function that doesn't automatically add newline
prompt_user() {
    local key=$1
    shift
    local prompt_text=$(print_message "$key" "$@")
    # Use printf for no newline, read directly after
    printf "%s" "$prompt_text"
}


# Function to check if a command exists
command_exists() {
    command -v "$1" >/dev/null 2>&1
}

# --- Configuration Variables ---
FISH_CONFIG_DIR="$HOME/.config/fish"
FISH_FUNC_DIR="$FISH_CONFIG_DIR/functions"
AG_SCRIPT_PATH="$FISH_FUNC_DIR/ag.fish"
CONTEXT_DIR="$HOME/.local/share/ag_contexts" # Needed for uninstall

# --- Pre-checks ---
if [[ $EUID -eq 0 ]]; then print_error ERR_NOROOT; fi

# --- Uninstall Logic ---
if [[ "$UNINSTALL" == true ]]; then
    print_info INFO_UNINSTALL_START

    # 1. Remove the ag.fish file
    if [[ -f "$AG_SCRIPT_PATH" ]]; then
        print_info INFO_REMOVE_AG_FILE "$AG_SCRIPT_PATH"
        rm -f "$AG_SCRIPT_PATH"
        if [[ $? -eq 0 ]]; then
            print_info INFO_AG_FILE_REMOVED
        else
            print_error ERR_REMOVE_AG_FILE_FAILED "$AG_SCRIPT_PATH"
        fi
    else
        print_warning WARN_AG_FILE_NOT_FOUND "$AG_SCRIPT_PATH" # Consider adding this message key if needed
        echo "(File '$AG_SCRIPT_PATH' not found, skipping removal)"
    fi

    # 2. Prompt to remove context directory
    if [[ -d "$CONTEXT_DIR" ]]; then
        prompt_user PROMPT_CONFIRM_UNINSTALL_CONTEXT "$CONTEXT_DIR"
        read -r CONFIRM_CONTEXT_REMOVAL
        echo # Add newline after read
        if [[ "$CONFIRM_CONTEXT_REMOVAL" =~ ^[Yy]$ ]]; then
            print_info INFO_REMOVE_CONTEXT_DIR "$CONTEXT_DIR"
            rm -rf "$CONTEXT_DIR"
            if [[ $? -eq 0 ]]; then
                print_info INFO_CONTEXT_DIR_REMOVED
            else
                print_error ERR_REMOVE_CONTEXT_DIR_FAILED "$CONTEXT_DIR"
            fi
        else
            print_info INFO_SKIPPING_CONTEXT_REMOVAL
        fi
    fi

    # 3. Final uninstall messages
    print_info INFO_UNINSTALL_COMPLETE
    print_info INFO_UNINSTALL_PKGS_MANUAL
    exit 0
fi

# --- Main Setup Logic (Only runs if not uninstalling) ---

if ! command_exists apt; then print_error ERR_NOAPT; fi # Check apt only needed for install

print_info INFO_START

# 1. Update package lists and install base packages
print_info INFO_UPDATE_APT
sudo apt update || print_error ERR_UPDATE_APT_FAILED

print_info INFO_INSTALL_PKGS
sudo apt install -y fish jq curl || print_error ERR_INSTALL_PKGS_FAILED
print_info INFO_PKGS_INSTALLED

# 2. Create Fish configuration directories
print_info INFO_CREATE_FISH_DIRS
mkdir -p "$FISH_FUNC_DIR" || print_error ERR_CREATE_FISH_DIRS_FAILED "$FISH_FUNC_DIR"
print_info INFO_FISH_DIR_ENSURED "$FISH_FUNC_DIR"

# 3. Create the ag.fish function file (Modified embedded content)
print_info INFO_CREATE_AG_FILE

# --- !!! Embedded ag.fish script (Modified: Removed -m, -o, rich, less) !!! ---
cat << 'EOF' > "$AG_SCRIPT_PATH"
# 函数：ag - 向 OpenRouter API 提问，支持流式、多文件上下文
# 用法: ag [-s <ctx>] [-l] [-d <ctx>] [-h] "你的问题是什么？"
# 警告：此命令名 'ag' 可能覆盖 The Silver Searcher 工具！
function ag --description "ag: 向 OpenRouter 提问，可选上下文，纯文本流式输出"

    # --- 配置 ---
    set -l CONTEXT_DIR "$HOME/.local/share/ag_contexts"
    mkdir -p "$CONTEXT_DIR" # 确保上下文目录存在
    # --- 配置结束 ---

    # --- 参数解析 ---
    set -l options (fish_opt -s l -l list)        # 列出上下文
    set -l options $options (fish_opt -s s -l select -r) # 选择/创建上下文 (需要名字)
    set -l options $options (fish_opt -s d -l delete -r) # 删除上下文 (需要名字)
    set -l options $options (fish_opt -s h -l help)        # 帮助
    argparse $options -- $argv
    if test $status -ne 0; return 1; end

    # --- 处理独占操作: List / Delete / Help ---
    if set -q _flag_help
        echo "用法: ag [选项] \"<你的问题>\""
        echo ""
        echo "向 OpenRouter API 提问，纯文本流式输出。"
        echo "可通过 -s 选择或创建命名上下文进行连续对话。"
        echo "默认不加载也不保存上下文（即时对话）。"
        echo "警告：此命令名 'ag' 可能覆盖 The Silver Searcher 工具。"
        echo ""
        echo "选项:"
        printf "  %-25s %s\n" "-s <名称>, --select <名称>" "选择或创建指定名称的上下文进行对话"
        printf "  %-25s %s\n" " " "  (对话结束后会自动保存回该文件)"
        printf "  %-25s %s\n" "-l, --list" "列出所有已保存的上下文名称"
        printf "  %-25s %s\n" "-d <名称>, --delete <名称>" "删除指定名称的上下文文件"
        printf "  %-25s %s\n" "-h, --help" "显示此帮助信息并退出"
        echo ""
        echo "上下文存储目录: $CONTEXT_DIR"
        echo ""
        echo "依赖: jq"
        echo ""
        echo "示例:"
        echo "  ag \"你好\"                         # 即时对话"
        echo "  ag -s projectA \"开始讨论项目A\"      # 使用或创建 projectA 上下文"
        echo "  ag -s projectA \"继续讨论...\"       # 继续 projectA 对话"
        echo "  ag -l                             # 查看有哪些上下文"
        echo "  ag -d projectA                    # 删除 projectA 上下文"
        return 0
    end

    # 列出上下文
    if set -q _flag_list
        echo "可用的上下文 (在 $CONTEXT_DIR):"
        set context_files (find "$CONTEXT_DIR" -maxdepth 1 -name '*.json' -printf '%f\n' 2>/dev/null)
        if test (count $context_files) -gt 0
             for file in $context_files
                 # 移除 .json 后缀
                 echo "- "(string replace '.json' '' "$file")
             end
        else
            echo "(无)"
        end
        return 0
    end

    # 删除上下文
    if set -q _flag_delete
        set context_name_to_delete $_flag_delete
        set context_file_to_delete "$CONTEXT_DIR/$context_name_to_delete.json"
        if test -e "$context_file_to_delete"
            rm "$context_file_to_delete"
            if test $status -eq 0
                 echo "✅ 已删除上下文 '$context_name_to_delete' ($context_file_to_delete)" >&2
                 return 0
            else
                 echo "错误: 无法删除上下文文件 '$context_file_to_delete'" >&2
                 return 1
            end
        else
            echo "错误: 上下文 '$context_name_to_delete' 不存在 ($context_file_to_delete)" >&2
            return 1
        end
    end

    # --- 前置检查 ---
    if not set -q OPENROUTER_API_KEY; echo "错误：请设置 OPENROUTER_API_KEY 环境变量。" >&2; return 1; end
    if not command -q jq; echo "错误：需要 'jq'。" >&2; return 1; end

    # --- 参数和 Prompt 处理 ---
    if test (count $argv) -eq 0
        echo "错误：缺少用户问题。" >&2
        echo "用法: ag [选项] \"<你的问题>\"" >&2
        return 1
    end
    set -l user_prompt (string join ' ' $argv)

    # --- 上下文处理 (基于 -s <name>) ---
    set -l messages_json_array '[]' # 默认空历史
    set -l selected_context_name ""  # 存储选择的上下文名称，用于后续保存
    if set -q _flag_select
        set selected_context_name $_flag_select
        set context_file_to_load "$CONTEXT_DIR/$selected_context_name.json"
        echo "ℹ️ 使用上下文: '$selected_context_name'" >&2 # 提示用户

        if test -e "$context_file_to_load"
            set messages_json_array (cat "$context_file_to_load" 2>/dev/null)
            if test $status -ne 0; or test -z "$messages_json_array"
                 echo "警告: 无法读取或上下文文件为空 '$context_file_to_load'. 将创建新上下文。" >&2
                 set messages_json_array '[]'
            else if not echo "$messages_json_array" | jq -e 'type == "array"' > /dev/null 2>&1
                 echo "警告: 上下文文件 '$context_file_to_load' 内容不是有效的 JSON 数组。将创建新上下文。" >&2
                 set messages_json_array '[]'
            # else # Context loaded successfully, no extra message needed
            end
        else
            echo "✨ 上下文文件 '$context_file_to_load' 不存在，将创建新的对话。" >&2
            # messages_json_array 保持 '[]'
        end
    # else # 没有 -s 标志，使用默认的空历史，不保存
    end
    # --- 上下文处理结束 ---

    # --- 配置 System Prompt ---
    # Simple system prompt requesting plain text output
    set -l system_prompt "根据需要进行适当的换行和分段。回答尽量详细，将我当作小白来解释。请始终使用纯文本格式进行回复,可以使用emoji,但也不宜太多。绝对不要使用任何Markdown标记（如\`*\`、\`#\`、\` \`\`\` \`、\\"-\\"等），因为输出环境是终端。"
    set -l model_name "deepseek/deepseek-chat-v3-0324:free"
    set -l api_endpoint "https://openrouter.ai/api/v1/chat/completions"

    # --- 请求准备 ---
    set -l current_call_messages
    set current_call_messages (jq -n --arg content "$system_prompt" '[{"role": "system", "content": $content}]')
    if test $status -ne 0; echo "错误: 构建系统消息失败。" >&2; return 1; end
    # 合并加载的历史记录 (如果有效)
    if test -n "$messages_json_array"; and echo "$messages_json_array" | jq -e 'type == "array"' > /dev/null 2>&1
        set current_call_messages (echo $current_call_messages $messages_json_array | jq -s '.[0] + .[1]')
        if test $status -ne 0; echo "错误: 合并历史消息失败。" >&2; return 1; end
    end
    # 添加当前用户消息
    set current_call_messages (echo $current_call_messages | jq --arg content "$user_prompt" '. + [{"role": "user", "content": $content}]')
    if test $status -ne 0; echo "错误: 添加用户消息失败。" >&2; return 1; end

    # --- 构建 API 请求体 ---
    set -l json_payload (jq -n --arg model "$model_name" --argjson messages "$current_call_messages" '{"model": $model, "messages": $messages, "stream": true}')
    if test $status -ne 0; echo "错误：使用 jq 构建最终 JSON 载荷失败。" >&2; return 1; end

    # --- API 调用和流式处理 ---
    echo "🤔 正在向赛博助手 $model_name 请求帮助😎..." >&2
    echo "🤖 :" # Always show prompt before streaming

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
                set jq_status $status
                if test $jq_status -ne 0; echo "警告：解析 JSON 块失败: $json_chunk" >&2
                else
                    # Always stream output directly
                    printf '%s' "$text_chunk"
                    set full_response "$full_response$text_chunk"
                end
            end
        end # while end
        set process_exit_status $status
    end # pipeline end
    set curl_exit_status $pipestatus[1]

    # --- Post-processing: Add newline after successful stream ---
    if test $curl_exit_status -eq 0; and test $process_exit_status -eq 0
        echo # Add the final newline
    else if test $process_exit_status -ne 0; echo # Also add newline if processing loop ended abnormally
        echo "错误: curl 命令失败 (状态码: $curl_exit_status)..." >&2 # Report curl error if any
    end


    # --- 上下文保存 (基于 -s <name>) ---
    # Only save if context was selected, API call/processing succeeded, and we got a response
    if test -n "$selected_context_name"; and test $curl_exit_status -eq 0; and test $process_exit_status -eq 0; and test -n "$full_response"
        set context_file_to_save "$CONTEXT_DIR/$selected_context_name.json"
        set -l updated_context_json
        set -l jq_status -1

        # 构建更新后的历史记录
        set updated_context_json (echo $messages_json_array | jq --arg user_msg "$user_prompt" --arg assistant_msg "$full_response" '. + [{"role": "user", "content": $user_msg}, {"role": "assistant", "content": $assistant_msg}]')
        set jq_status $status

        if test $jq_status -eq 0
            # 将更新后的 JSON 写入文件 (覆盖)
            printf '%s\n' "$updated_context_json" > "$context_file_to_save"
            if test $status -ne 0
                 echo "错误：无法将更新后的上下文写入文件 '$context_file_to_save'" >&2
            else
                 echo "💾 对话上下文已更新到: '$selected_context_name' ($context_file_to_save)" >&2
            end
        else
            echo "错误：使用 jq 更新内存中的上下文失败 (状态码: $jq_status)。上下文未保存到文件。" >&2
        end
    end

    # --- 最终返回码 ---
    # Return 1 if curl failed or the processing loop failed abnormally
    if test $curl_exit_status -ne 0; or test $process_exit_status -ne 0
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

# --- Final Instructions (Simplified) ---
echo ""
print_info INFO_SETUP_COMPLETE
print_info INFO_SEPARATOR
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
echo "   ag -d projectX"
echo ""
print_info INFO_ENJOY

exit 0
