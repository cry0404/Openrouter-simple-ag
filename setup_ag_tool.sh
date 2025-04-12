#!/bin/bash

# Exit immediately if a command exits with a non-zero status.
set -e
# Treat unset variables as an error when substituting.
# set -u # Uncomment if you prefer stricter variable checking
# Prevent errors in pipelines from being masked.
set -o pipefail

# --- Configuration ---
# Default directory for saving responses (can be overridden by user in config.fish)
# Ensure this path uses $HOME explicitly if needed, as ~ might not expand correctly here.
DEFAULT_AI_RESPONSE_DIR="$HOME/AI_Responses"
FISH_CONFIG_DIR="$HOME/.config/fish"
FISH_FUNC_DIR="$FISH_CONFIG_DIR/functions"
AG_SCRIPT_PATH="$FISH_FUNC_DIR/ag.fish"
FISH_CONFIG_PATH="$FISH_CONFIG_DIR/config.fish"

# --- Helper Functions ---
print_info() {
    echo "INFO: $1"
}

print_warning() {
    echo "WARN: $1" >&2
}

print_error() {
    echo "ERROR: $1" >&2
    exit 1
}

# Function to check if a command exists
command_exists() {
    command -v "$1" >/dev/null 2>&1
}

# --- Pre-checks ---
if [[ $EUID -eq 0 ]]; then
   print_error "This script should not be run as root. Please run as your regular user."
fi

if ! command_exists apt; then
    print_error "This script requires 'apt' package manager (Debian/Ubuntu based systems)."
fi

# --- Main Setup Logic ---
print_info "Starting setup for the 'ag' AI assistant tool..."

# 1. Update package lists and install required packages
print_info "Updating package lists (requires sudo)..."
sudo apt update || print_error "Failed to update package lists."

print_info "Installing required packages: fish, jq, curl, pipx (requires sudo)..."
sudo apt install -y fish jq curl pipx || print_error "Failed to install required packages."
print_info "System packages installed successfully."

# 2. Setup pipx
print_info "Setting up pipx..."
if ! pipx ensurepath; then
    print_warning "pipx ensurepath command failed. You might need to manually add pipx binary path to your PATH."
    print_warning "Check pipx documentation or run 'pipx ensurepath' again after restarting your shell."
fi
# Note: Path changes might require shell restart or sourcing profile
print_info "pipx setup command executed. You might need to restart your shell or source ~/.profile for PATH changes to take effect."

# 3. Install rich-cli using pipx
print_info "Installing rich-cli using pipx..."
if command_exists rich; then
    print_info "'rich' command already found. Skipping installation."
else
    if pipx install rich-cli; then
        print_info "rich-cli installed successfully via pipx."
        # Verify installation
        if ! command_exists rich; then
             print_warning "Installed rich-cli via pipx, but 'rich' command not found immediately. Restart your shell or check PATH."
        fi
    else
        print_error "Failed to install rich-cli using pipx."
    fi
fi

# 4. Create Fish configuration directories
print_info "Creating Fish configuration directories (if they don't exist)..."
mkdir -p "$FISH_FUNC_DIR" || print_error "Failed to create Fish function directory: $FISH_FUNC_DIR"
print_info "Directory $FISH_FUNC_DIR ensured."

# 5. Create the ag.fish function file with embedded content
print_info "Creating the 'ag.fish' function file..."

# Use cat with HEREDOC 'EOF' to prevent variable expansion inside the script content
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
    # jq check already done by setup script
    # if not command -q jq; echo "错误：需要 'jq'。" >&2; return 1; end
    # rich check already done by setup script (conditionally)
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
    print_info "'ag.fish' function file created successfully at $AG_SCRIPT_PATH"
else
    print_error "Failed to create 'ag.fish' file!"
fi

# 6. Optional: Setup basic config.fish (uncomment to enable)
# print_info "Checking for Fish config file..."
# if [[ ! -f "$FISH_CONFIG_PATH" ]]; then
#     print_info "No config.fish found. Creating a basic one..."
#     mkdir -p "$FISH_CONFIG_DIR" # Ensure directory exists
#     cat << EOF > "$FISH_CONFIG_PATH"
# # Fish configuration
#
# # Set default output directory for 'ag' tool (optional)
# # Ensure the directory exists or the script will try to create it
# # set -gx AG_DEFAULT_OUTPUT_DIR "$DEFAULT_AI_RESPONSE_DIR"
#
# # Initialize Starship prompt (if installed)
# # if command -v starship > /dev/null
# #    starship init fish | source
# # end
#
# EOF
#     print_info "Basic config.fish created at $FISH_CONFIG_PATH"
# else
#     print_info "Existing config.fish found at $FISH_CONFIG_PATH. No changes made."
#     # Optionally, add code here to append settings if config.fish exists,
#     # checking first if the settings are already present.
#     # Example: Check and add AG_DEFAULT_OUTPUT_DIR if not set
#     # if ! grep -q "set -gx AG_DEFAULT_OUTPUT_DIR" "$FISH_CONFIG_PATH"; then
#     #    print_info "Adding AG_DEFAULT_OUTPUT_DIR setting to config.fish..."
#     #    echo "" >> "$FISH_CONFIG_PATH"
#     #    echo "# Set default output directory for 'ag' tool (added by setup script)" >> "$FISH_CONFIG_PATH"
#     #    echo "set -gx AG_DEFAULT_OUTPUT_DIR \"$DEFAULT_AI_RESPONSE_DIR\"" >> "$FISH_CONFIG_PATH"
#     # fi
# fi


# --- Final Instructions ---
echo ""
print_info "--------------------------------------------------"
print_info "Setup complete!"
print_info "--------------------------------------------------"
echo ""
echo "IMPORTANT NEXT STEPS:"
echo ""
echo "1. Set your OpenRouter API Key:"
echo "   Run this command in your terminal (and ideally add it to your Fish config):"
echo "   set -gx OPENROUTER_API_KEY 'sk-or-v1-YOUR-API-KEY-HERE'"
echo "   (Replace 'sk-or-v1-YOUR-API-KEY-HERE' with your actual key)"
echo ""
echo "2. Start using the 'ag' command in a NEW Fish shell:"
echo "   - If Fish is not your default shell, type: fish"
echo "   - If Fish IS your default shell, simply open a new terminal window."
echo "   - (Optional) To make Fish your default shell permanently, run: chsh -s \"\$(command -v fish)\""
echo ""
echo "3. Example Usage:"
echo "   ag \"Explain the theory of relativity simply.\""
echo "   ag -m \"Show me a Python example for reading a file using Markdown.\""
echo "   ag -o relativity.md \"Explain the theory of relativity simply.\""
echo "   ag -c \"What was the last thing I asked you?\""
echo ""
print_info "Enjoy your AI assistant!"

exit 0
