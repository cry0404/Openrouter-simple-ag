#!/bin/bash

# Exit immediately if a command exits with a non-zero status.
set -e
# Treat unset variables as an error when substituting.
# set -u
# Prevent errors in pipelines from being masked.
set -o pipefail

# --- Language Detection ---
SCRIPT_LANG="en" # Default to English
if [[ "${LANG}" == "zh"* ]]; then
    SCRIPT_LANG="zh"
fi

# --- Message Definitions ---

# --- English Messages ---
MSG_ERR_NOROOT_EN="This script should not be run as root. Please run as your regular user."
MSG_ERR_NOAPT_EN="This script requires 'apt' package manager (Debian/Ubuntu based systems)."
MSG_INFO_START_EN="Starting setup for the 'ag' AI assistant tool..."
MSG_INFO_UPDATE_APT_EN="Updating package lists (requires sudo)..."
MSG_ERR_UPDATE_APT_FAILED_EN="Failed to update package lists."
MSG_INFO_INSTALL_PKGS_EN="Installing required packages: fish, jq, curl, pipx (requires sudo)..."
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
MSG_INFO_CREATE_FISH_DIRS_EN="Creating Fish configuration directories (if they don't exist)..."
MSG_ERR_CREATE_FISH_DIRS_FAILED_EN="Failed to create Fish function directory:"
MSG_INFO_FISH_DIR_ENSURED_EN="Directory ensured:"
MSG_INFO_CREATE_AG_FILE_EN="Creating the 'ag.fish' function file..."
MSG_INFO_AG_FILE_CREATED_EN="'ag.fish' function file created successfully at"
MSG_ERR_AG_FILE_FAILED_EN="Failed to create 'ag.fish' file!"
MSG_INFO_SETUP_COMPLETE_EN="Setup complete!"
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

# --- Chinese Messages (中文消息) ---
MSG_ERR_NOROOT_ZH="请不要以 root 用户身份运行此脚本。请使用您的普通用户运行。"
MSG_ERR_NOAPT_ZH="此脚本需要 'apt' 包管理器 (适用于 Debian/Ubuntu 系统)。"
MSG_INFO_START_ZH="开始设置 'ag' AI 助手工具..."
MSG_INFO_UPDATE_APT_ZH="正在更新软件包列表 (需要 sudo 权限)..."
MSG_ERR_UPDATE_APT_FAILED_ZH="更新软件包列表失败。"
MSG_INFO_INSTALL_PKGS_ZH="正在安装所需软件包: fish, jq, curl, pipx (需要 sudo 权限)..."
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
MSG_INFO_CREATE_FISH_DIRS_ZH="正在创建 Fish 配置目录 (如果不存在)..."
MSG_ERR_CREATE_FISH_DIRS_FAILED_ZH="创建 Fish 函数目录失败:"
MSG_INFO_FISH_DIR_ENSURED_ZH="目录已确保存在:"
MSG_INFO_CREATE_AG_FILE_ZH="正在创建 'ag.fish' 函数文件..."
MSG_INFO_AG_FILE_CREATED_ZH="'ag.fish' 函数文件已成功创建于"
MSG_ERR_AG_FILE_FAILED_ZH="创建 'ag.fish' 文件失败！"
MSG_INFO_SETUP_COMPLETE_ZH="设置完成！"
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


# --- Helper Function for Messages ---
print_message() {
    local key=$1
    local msg_var_en="MSG_${key}_EN"
    local msg_var_zh="MSG_${key}_ZH"
    if [[ "$SCRIPT_LANG" == "zh" ]] && [[ -v "$msg_var_zh" ]]; then
        echo "${!msg_var_zh}" # Use indirect expansion
    elif [[ -v "$msg_var_en" ]]; then
         echo "${!msg_var_en}"
    else
         echo "WARN: Message key '$key' not found." >&2 # Fallback warning
    fi
}

# --- Wrapper Functions ---
print_info() { print_message "$1"; }
print_warning() { print_message "$1" >&2; }
print_error() { print_message "$1" >&2; exit 1; }

# Function to check if a command exists
command_exists() {
    command -v "$1" >/dev/null 2>&1
}

# --- Configuration Variables (User home dependent) ---
FISH_CONFIG_DIR="$HOME/.config/fish"
FISH_FUNC_DIR="$FISH_CONFIG_DIR/functions"
AG_SCRIPT_PATH="$FISH_FUNC_DIR/ag.fish"
FISH_CONFIG_PATH="$FISH_CONFIG_DIR/config.fish"
# DEFAULT_AI_RESPONSE_DIR="$HOME/AI_Responses" # Used only in optional config.fish creation


# --- Pre-checks ---
if [[ $EUID -eq 0 ]]; then
   print_error ERR_NOROOT
fi

if ! command_exists apt; then
    print_error ERR_NOAPT
fi

# --- Main Setup Logic ---
print_info INFO_START

# 1. Update package lists and install required packages
print_info INFO_UPDATE_APT
sudo apt update || print_error ERR_UPDATE_APT_FAILED

print_info INFO_INSTALL_PKGS
sudo apt install -y fish jq curl pipx || print_error ERR_INSTALL_PKGS_FAILED
print_info INFO_PKGS_INSTALLED

# 2. Setup pipx
print_info INFO_SETUP_PIPX
if ! pipx ensurepath; then
    print_warning WARN_PIPX_PATH_FAILED
    print_warning WARN_PIPX_PATH_RESTART
fi
print_info INFO_PIPX_RESTART_NOTE

# 3. Install rich-cli using pipx
print_info INFO_INSTALL_RICH
if command_exists rich; then
    print_info INFO_RICH_FOUND
else
    if pipx install rich-cli; then
        print_info INFO_RICH_INSTALLED
        if ! command_exists rich; then
             print_warning WARN_RICH_NOT_FOUND
        fi
    else
        print_error ERR_RICH_INSTALL_FAILED
    fi
fi

# 4. Create Fish configuration directories
print_info INFO_CREATE_FISH_DIRS
mkdir -p "$FISH_FUNC_DIR" || print_error ERR_CREATE_FISH_DIRS_FAILED "$FISH_FUNC_DIR"
print_info INFO_FISH_DIR_ENSURED "$FISH_FUNC_DIR"

# 5. Create the ag.fish function file with embedded content
print_info INFO_CREATE_AG_FILE

# Use cat with HEREDOC 'EOF' to prevent variable expansion inside the script content
# Note: The ag.fish content itself remains in English for simplicity
cat << 'EOF' > "$AG_SCRIPT_PATH"
# 函数：ag - 向 OpenRouter API 提问，支持流式、保存并用 rich 打开文件、或仅终端渲染
# 用法: ag [-c|--context] [-r|--reset] [-m] [-o <file>] [-h] "你的问题是什么？"
# 警告：此命令名 'ag' 可能覆盖 The Silver Searcher 工具！
function ag --description "ag: 向 OpenRouter 提问，可选上下文、保存/rich查看、终端Markdown渲染"

    # --- 参数解析 ---
    set -l options (fish_opt -s c -l context)
    set -l options $options (fish_opt -s r -l reset)
    set -l options $options (fish_opt -s m -l markdown) # 终端渲染选项
    set -l options $options (fish_opt -s o -l output -r) # 保存并用 rich 打开选项
    set -l options $options (fish_opt -s h -l help)
    argparse $options -- $argv
    if test $status -ne 0; return 1; end

    # --- 处理帮助选项 ---
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
        printf "  %-25s %s\n" "-c, --context" "使用并更新对话上下文"
        printf "  %-25s %s\n" "-r, --reset" "在提问前重置对话上下文"
        printf "  %-25s %s\n" "-o <路径>, --output <路径>" "保存 Markdown 到<路径>并用 'rich -m' 打开"
        printf "  %-25s %s\n" " " "  (路径处理方式同之前版本，支持默认目录)"
        printf "  %-25s %s\n" "-m, --markdown" "仅在终端渲染 Markdown (无 -o 时生效)"
        printf "  %-25s %s\n" "-h, --help" "显示此帮助信息并退出"
        echo ""
        echo "配置: 可选设置环境变量 \$AG_DEFAULT_OUTPUT_DIR 指定默认保存目录。"
        echo "      示例 (config.fish): set -gx AG_DEFAULT_OUTPUT_DIR \"\$HOME/AI_Responses\""
        echo ""
        echo "依赖: jq, rich-cli (推荐 pipx install). 可选依赖: less (用于 -m 无 -o)"
        echo ""
        echo "示例:"
        echo "  ag \"解释 fish shell\""
        echo "  ag -o fish_explained.md \"解释 fish shell (md)\""
        echo "  ag -m \"解释 git rebase (md)\"           # 仅终端渲染"
        return 0
    end

    # --- 确定最终输出文件路径 ---
    set -l output_file ""
    if set -q _flag_output
        set -l user_output_spec $_flag_output
        if string match -q -r '^/' -- "$user_output_spec"; set output_file $user_output_spec
        else if string match -q '~/*' -- "$user_output_spec"; set output_file (string replace -r '^~' "$HOME" "$user_output_spec")
        else if test "$user_output_spec" = "~"; set output_file $HOME
        else if string match -q '*/*' -- "$user_output_spec"; set output_file $user_output_spec
        else
            if set -q AG_DEFAULT_OUTPUT_DIR; and test -n "$AG_DEFAULT_OUTPUT_DIR"; and test -d "$AG_DEFAULT_OUTPUT_DIR"
                 set output_file "$AG_DEFAULT_OUTPUT_DIR/$user_output_spec"
            else
                 set output_file "$user_output_spec"
            end
        end
    end

    # --- 前置检查 ---
    if not set -q OPENROUTER_API_KEY; echo "错误：请设置 OPENROUTER_API_KEY 环境变量。" >&2; return 1; end
    # jq should be installed by setup script
    # rich should be installed by setup script if needed
    if set -q _flag_output; or set -q _flag_markdown
        if not command -q rich
            echo "错误：保存/渲染 Markdown 需要 'rich-cli'。请确认已安装。" >&2
            echo "(推荐: pipx install rich-cli)" >&2
            return 1
        end
    end
    # less check only needed for -m without -o
    if set -q _flag_markdown; and not set -q _flag_output
        if not command -q less
             echo "错误：终端 Markdown 分页显示需要 'less'。请确认已安装。" >&2
             return 1
        end
    end

    # --- 参数和 Prompt 处理 ---
    if test (count $argv) -eq 0; and not set -q _flag_reset
        if not set -q _flag_reset
            echo "用法: ag [-c] [-r] [-m] [-o <file>] [-h] \"<你的问题>\"" >&2
            return 1
        end
    end
    set -l user_prompt ""
    if test (count $argv) -gt 0
       set user_prompt (string join ' ' $argv)
    end

    # --- 配置 System Prompt ---
    set -l system_prompt_base "根据需要进行适当的换行和分段。回答尽量详细，将我当作小白来解释。"
    set -l system_prompt_format_instruction
    if set -q _flag_output; or set -q _flag_markdown
        set system_prompt_format_instruction "请使用 Markdown 格式进行回复（包括代码块、列表、加粗等）。"
    else
        set system_prompt_format_instruction "请始终使用纯文本格式进行回复,可以使用emoji,但也不宜太多。绝对不要使用任何Markdown标记（如\`*\`、\`#\`、\` \`\`\` \`、\\"-\\"等），因为输出环境是终端。"
    end
    set -l system_prompt "$system_prompt_format_instruction $system_prompt_base"
    set -l model_name "deepseek/deepseek-chat-v3-0324:free" # Or your preferred model
    set -l api_endpoint "https://openrouter.ai/api/v1/chat/completions"
    set -l context_var_name "__ag_session_context"

    # --- 上下文处理 ---
    if set -q _flag_reset; echo "🔄 正在重置 ag 对话上下文。" >&2; set -e $context_var_name; end
    set -l messages_json_array '[]'
    if set -q _flag_context
        if set -q $context_var_name
            set messages_json_array $$context_var_name
            if not string match -q -r '^\[.*\]$' -- "$messages_json_array"; echo "警告:ag 存储的上下文格式无效..." >&2; set messages_json_array '[]'; else; echo "🧠 使用现有 ag 会话上下文。" >&2; end
        else; echo "✨ 开启新的 ag 对话上下文。" >&2; end
    else
        set messages_json_array '[]'
    end

    # --- 请求准备 ---
    set -l current_call_messages
    set current_call_messages (jq -n --arg content "$system_prompt" '[{"role": "system", "content": $content}]')
    if test $status -ne 0; echo "错误: 构建系统消息失败。" >&2; return 1; end
    if set -q _flag_context; and test -n "$messages_json_array"; and string match -q -r '^\[.*\]$' -- "$messages_json_array" # merge history start
        set current_call_messages (echo $current_call_messages $messages_json_array | jq -s '.[0] + .[1]')
        if test $status -ne 0; echo "错误: 合并历史消息失败。" >&2; return 1; end
    end # merge history end
    if test -n "$user_prompt" # add user msg start
        set current_call_messages (echo $current_call_messages | jq --arg content "$user_prompt" '. + [{"role": "user", "content": $content}]')
        if test $status -ne 0; echo "错误: 添加用户消息失败。" >&2; return 1; end
    else if not set -q _flag_reset # add user msg else if
         echo "错误：缺少用户问题。" >&2; return 1
    end # add user msg end

    # --- 如果只是重置操作 ---
    if set -q _flag_reset; and test -z "$user_prompt"; echo "✅ 上下文已重置。" >&2; return 0; end

    # --- 构建 API 请求体 ---
    set -l json_payload (jq -n --arg model "$model_name" --argjson messages "$current_call_messages" '{"model": $model, "messages": $messages, "stream": true}')
    if test $status -ne 0; echo "错误：使用 jq 构建最终 JSON 载荷失败。" >&2; return 1; end

    # --- API 调用和流式处理 ---
    echo "🤔 正在向 cry 的赛博助手 $model_name 请求帮助😎..." >&2
    if set -q _flag_context; echo "(使用上下文)" >&2; end
    if not set -q _flag_output; and not set -q _flag_markdown
        echo "🤖 :"
    end

    set -l full_response ""
    set -l curl_exit_status -1
    set -l process_exit_status -1

    begin # pipeline start
        curl --silent --no-buffer -X POST "$api_endpoint" \
            -H "Content-Type: application/json" \
            -H "Authorization: Bearer $OPENROUTER_API_KEY" \
            -d "$json_payload" | while read -l line # while start

            if string match -q "data: *" -- "$line" # if data start
                set json_chunk (string sub -s 7 -- "$line")
                if test "$json_chunk" = "[DONE]"; break; end # if done check

                set api_error (echo "$json_chunk" | jq -r '.error.message // ""')
                if test -n "$api_error"; echo "API 错误: $api_error" >&2; continue; end # if api error check

                set text_chunk (echo "$json_chunk" | jq -r '.choices[0].delta.content // ""')
                set jq_status $status

                if test $jq_status -ne 0 # if jq parse chunk start
                     echo "警告：解析 JSON 块失败: $json_chunk" >&2
                else # if jq parse chunk else
                    if not set -q _flag_output; and not set -q _flag_markdown
                        printf '%s' "$text_chunk"
                    end
                    set full_response "$full_response$text_chunk"
                end # if jq parse chunk end
            end # if data end
        end # while end
        set process_exit_status $status
    end # pipeline end
    set curl_exit_status $pipestatus[1]

    # --- 后处理、保存/打开文件、终端渲染或添加换行 ---
    if test $curl_exit_status -ne 0; echo "错误:curl 命令失败 (状态码: $curl_exit_status)..." >&2; return 1; end
    if test $process_exit_status -ne 0
        echo "警告：While 循环处理过程异常结束 (状态码: $process_exit_status)。响应可能不完整。" >&2
    end

    set -l save_status 0
    set -l render_status 0
    if test -n "$output_file"; and test $curl_exit_status -eq 0; and test $process_exit_status -eq 0; and test -n "$full_response"
        set output_dir (dirname "$output_file")
        if not test -d "$output_dir"
             mkdir -p "$output_dir"
             if test $status -ne 0
                  echo "错误：无法创建目录 '$output_dir'" >&2
                  set save_status 1
             end
        end

        if test $save_status -eq 0
             printf '%s' "$full_response" > "$output_file"
             set save_status $status
             if test $save_status -eq 0
                  echo "✅ 响应已保存到: $output_file" >&2
                  if test -e "$output_file"
                      if command -q rich
                           echo "ℹ️ 正在使用 rich --markdown 打开文件..." >&2
                           rich --markdown "$output_file" # 强制 rich 将文件视为 Markdown
                           set render_status $status
                           if test $render_status -ne 0
                               echo "警告: rich 命令未能成功显示文件 (状态码: $render_status)" >&2
                           end
                      else
                           echo "警告: 未找到 rich 命令，无法自动打开文件。" >&2
                      end
                  else
                       echo "错误：文件 '$output_file' 在保存后未能找到！无法打开。" >&2
                       set save_status 1
                  end
             else
                  echo "错误：无法将响应写入文件 '$output_file' (状态码: $save_status)" >&2
             end
        end
    else if not set -q _flag_output; and set -q _flag_markdown; and test $curl_exit_status -eq 0; and test $process_exit_status -eq 0; and test -n "$full_response"
        set -l tmp_file "/tmp/ag_render."(random)".md"
        printf '%s' "$full_response" > "$tmp_file"
        if test $status -eq 0
             rich "$tmp_file" | less -R
             set render_status $pipestatus[1] # rich status
             if test $render_status -ne 0; echo "警告: rich 命令渲染可能出错 (状态码: $render_status)" >&2; end
             rm "$tmp_file"
        else
             echo "错误: 无法创建临时文件进行渲染" >&2
             echo "$full_response"
             set render_status 1
        end
    else if not set -q _flag_output; and not set -q _flag_markdown; and test $curl_exit_status -eq 0; and test $process_exit_status -eq 0
        echo
    else if test $process_exit_status -ne 0
        echo
    end

    # --- 上下文保存 ---
    if set -q _flag_context; and test $curl_exit_status -eq 0; and test -n "$full_response"
        if test $process_exit_status -eq 0
            set -l updated_context_json
            set -l jq_status -1
            if test -n "$user_prompt"
                set updated_context_json (echo $messages_json_array | jq --arg user_msg "$user_prompt" --arg assistant_msg "$full_response" '. + [{"role": "user", "content": $user_msg}, {"role": "assistant", "content": $assistant_msg}]')
                set jq_status $status
            else
                set updated_context_json $messages_json_array
                set jq_status 0
            end
            if test $jq_status -eq 0
                if test "$updated_context_json" != "$messages_json_array"
                    set -g $context_var_name "$updated_context_json"
                end
            else
                echo "错误：使用 jq 更新 ag 上下文历史失败 (状态码: $jq_status)。" >&2
            end
        end
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
print_info SETUP_COMPLETE
print_info "--------------------------------------------------" # Separator in both languages
echo ""
print_info NEXT_STEPS
echo ""
print_info SET_API_KEY
print_info RUN_COMMAND
echo "   set -gx OPENROUTER_API_KEY 'sk-or-v1-YOUR-API-KEY-HERE'"
print_info API_KEY_EXAMPLE
echo ""
print_info START_FISH
print_info FISH_HOWTO
print_info FISH_DEFAULT
print_info FISH_CHSH
echo ""
print_info EXAMPLE_USAGE
echo "   ag \"Explain the theory of relativity simply.\""
echo "   ag -m \"Show me a Python example for reading a file using Markdown.\""
echo "   ag -o relativity.md \"Explain the theory of relativity simply.\""
echo "   ag -c \"What was the last thing I asked you?\""
echo ""
print_info ENJOY

exit 0
