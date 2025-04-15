#!/bin/bash

# 立刻退出，如果任何命令执行失败
set -e
# set -u
set -o pipefail

# --- 配置 ---
UNINSTALL=false # 卸载标志
SCRIPT_NAME="ai" # 命令和函数的基础名称
CONTEXT_DIR_NAME="ai_contexts" 

# --- 模型定义 ---
# 数组索引对应命令后缀 (ai1, ai2, ...)
# 自行查找模型:https://openrouter.ai/models
MODEL_SUFFIXES=( "1" "2" "3" "4" "5" )
MODEL_IDS=( # 使用用户指定的模型 ID
    "moonshotai/kimi-vl-a3b-thinking:free"
    "openrouter/optimus-alpha"
    "google/gemini-2.5-pro-exp-03-25:free"
    "deepseek/deepseek-chat-v3-0324:free"
    "meta-llama/llama-4-maverick:free"
)
MODEL_NICKNAMES=( # 为模型设置昵称 (可自定义)
    "Kimi-Thinking"
    "Optimus-Alpha"
    "Gemini-2.5-Pro"
    "DeepSeek-Chat-V3"
    "Llama-4-Maverick"
)
NUM_MODELS=${#MODEL_SUFFIXES[@]}

# --- 参数解析 ---
TEMP=$(getopt -o '' --long uninstall,help -n "$0" -- "$@")
if [ $? != 0 ] ; then echo "终止..." >&2 ; exit 1 ; fi
eval set -- "$TEMP"
unset TEMP

while true; do
  case "$1" in
    '--uninstall' ) UNINSTALL=true; shift ;;
    '--help' )
      echo "用法: $0 [--uninstall|--help]"
      echo "  安装 '$SCRIPT_NAME' 系列 AI 助手工具及其依赖 (fish, jq, curl)。"
      echo "  会创建 ${SCRIPT_NAME}1 到 ${SCRIPT_NAME}${NUM_MODELS} 命令，分别对应不同模型。"
      echo "  --uninstall   移除 '$SCRIPT_NAME' 相关函数文件并提示移除上下文数据。"
      echo "  --help        显示此帮助信息。"
      exit 0 ;;
    '--' ) shift; break ;;
    * ) break ;;
  esac
done

# --- 消息定义 (仅中文) ---
MSG_ERR_NOROOT_ZH="请不要以 root 用户身份运行此脚本。请使用您的普通用户运行。"
MSG_ERR_NOAPT_ZH="此脚本需要 'apt' 包管理器 (适用于 Debian/Ubuntu 系统)。"
MSG_INFO_START_ZH="开始设置 '$SCRIPT_NAME' 系列 AI 助手工具..."
MSG_INFO_UPDATE_APT_ZH="正在更新软件包列表 (需要 sudo 权限)..."
MSG_ERR_UPDATE_APT_FAILED_ZH="更新软件包列表失败。"
MSG_INFO_INSTALL_PKGS_ZH="正在安装所需软件包: fish, jq, curl (需要 sudo 权限)..."
MSG_ERR_INSTALL_PKGS_FAILED_ZH="安装所需软件包失败。"
MSG_INFO_PKGS_INSTALLED_ZH="系统软件包安装成功。"
MSG_INFO_CREATE_FISH_DIRS_ZH="正在创建 Fish 配置目录 (如果不存在)..."
MSG_ERR_CREATE_FISH_DIRS_FAILED_ZH="创建 Fish 函数目录失败: \$1"
MSG_INFO_FISH_DIR_ENSURED_ZH="目录已确保存在: \$1"
MSG_INFO_CREATE_AI_FILES_ZH="正在创建 '$SCRIPT_NAME' 系列函数文件..."
MSG_INFO_AI_FILE_CREATED_ZH="'\$1.fish' 函数文件已成功创建于 \$2"
MSG_ERR_AI_FILE_FAILED_ZH="创建 '\$1.fish' 文件失败！"
MSG_ERR_CREATE_FUNC_FAILED_ZH="创建函数文件失败: \$1"
MSG_INFO_SETUP_COMPLETE_ZH="设置完成！"
MSG_INFO_SEPARATOR_ZH="--------------------------------------------------"
MSG_INFO_NEXT_STEPS_ZH="重要后续步骤："
MSG_INFO_SET_API_KEY_ZH="1. 设置您的 OpenRouter API 密钥："
MSG_INFO_RUN_COMMAND_ZH="   在终端中运行此命令 (强烈建议将其添加到您的 Fish 配置文件 ~/.config/fish/config.fish 中，以便永久生效)："
MSG_INFO_API_KEY_EXAMPLE_ZH="(将 'sk-or-v1-YOUR-API-KEY-HERE' 替换为您的真实密钥)"
MSG_INFO_APPLY_CHANGES_ZH="2. 应用更改并开始使用:"
MSG_INFO_RESTART_SHELL_ZH="   - 打开一个新的 Fish 终端窗口。"
MSG_INFO_OR_SOURCE_CONFIG_ZH="   - 或者，如果在 \`config.fish\` 中设置了 API 密钥, 可以运行: source ~/.config/fish/config.fish"
MSG_INFO_FISH_HOWTO_ZH="   - 如果 Fish 不是您的默认 shell，请先输入 \`fish\` 进入。"
MSG_INFO_EXAMPLE_USAGE_ZH="3. 使用示例："
MSG_INFO_ENJOY_ZH="祝您使用 AI 助手愉快😜！"
MSG_INFO_UNINSTALL_START_ZH="开始卸载 '$SCRIPT_NAME' 系列工具..."
MSG_INFO_REMOVE_AI_FILES_ZH="正在移除 '$SCRIPT_NAME' 相关函数文件..."
MSG_ERR_REMOVE_AI_FILE_FAILED_ZH="移除函数文件失败: \$1"
MSG_INFO_AI_FILES_REMOVED_ZH="'$SCRIPT_NAME' 相关函数文件移除成功。"
MSG_WARN_AI_FILES_NOT_FOUND_ZH="警告: 未找到 '$SCRIPT_NAME' 相关函数文件。"
MSG_PROMPT_CONFIRM_UNINSTALL_CONTEXT_ZH="您想移除上下文数据目录 (\$1) 吗？这将删除所有已保存的聊天记录。 [y/N]: "
MSG_INFO_SKIPPING_CONTEXT_REMOVAL_ZH="跳过移除上下文目录。"
MSG_INFO_REMOVE_CONTEXT_DIR_ZH="正在移除上下文数据目录: \$1"
MSG_ERR_REMOVE_CONTEXT_DIR_FAILED_ZH="移除上下文目录失败: \$1"
MSG_INFO_CONTEXT_DIR_REMOVED_ZH="上下文目录移除成功。"
MSG_INFO_UNINSTALL_COMPLETE_ZH="卸载完成。"
MSG_INFO_UNINSTALL_PKGS_MANUAL_ZH="注意：系统软件包 (fish, jq, curl) 未被自动移除。如果不再需要，您可以手动移除它们 (例如 'sudo apt remove fish jq curl')。"

# --- 消息辅助函数 (仅中文) ---
print_message() {
    local key=$1
    shift # 移除键，剩余参数用于占位符
    local msg_var_zh="MSG_${key}_ZH"
    local chosen_msg=""

    # 选择消息
    if declare -p "$msg_var_zh" &>/dev/null; then
        chosen_msg="${!msg_var_zh}"
    else
         echo "警告: 消息键 '$key' 未找到。" >&2
         return 1
    fi

    # 使用 sed 替换占位符 $1, $2, ...
    local i=1
    for arg in "$@"; do
        
        escaped_arg=$(echo "$arg" | sed -e 's/\\/\\\\/g' -e 's/[$]/\\$/g' -e 's/|/\\|/g')
        chosen_msg=$(echo "$chosen_msg" | sed "s|\\\$$i|$escaped_arg|g")
        i=$((i + 1))
    done
    echo -e "$chosen_msg" # 使用 -e 来解释转义符如 \n
}

# --- 包装函数 ---
print_info() { print_message "$@"; }
print_warning() { print_message "$@" >&2; }
print_error() { print_message "$@" >&2; exit 1; }
# 特殊的提示函数，不自动换行
prompt_user() {
    local key=$1
    shift
    local prompt_text=$(print_message "$key" "$@")
    # 使用 printf 实现无换行，然后直接 read
    printf "%s" "$prompt_text"
}



command_exists() {
    command -v "$1" >/dev/null 2>&1
}

# --- 配置变量 ---
FISH_CONFIG_DIR="$HOME/.config/fish"
FISH_FUNC_DIR="$FISH_CONFIG_DIR/functions"
CONTEXT_DIR="$HOME/.local/share/$CONTEXT_DIR_NAME" # 上下文目录路径
AI_BASE_FUNC_PATH="$FISH_FUNC_DIR/${SCRIPT_NAME}.fish" # 主 ai.fish 的路径

# --- 预检查 ---
if [[ $EUID -eq 0 ]]; then print_error ERR_NOROOT; fi

# --- 卸载逻辑 ---
if [[ "$UNINSTALL" == true ]]; then
    print_info INFO_UNINSTALL_START

    
    print_info INFO_REMOVE_AI_FILES
    found_files=false
    if [[ -f "$AI_BASE_FUNC_PATH" ]]; then
        rm -f "$AI_BASE_FUNC_PATH" || print_error ERR_REMOVE_AI_FILE_FAILED "$AI_BASE_FUNC_PATH"
        found_files=true
    fi
    for suffix in "${MODEL_SUFFIXES[@]}"; do
        func_path="$FISH_FUNC_DIR/${SCRIPT_NAME}${suffix}.fish"
        if [[ -f "$func_path" ]]; then
            rm -f "$func_path" || print_error ERR_REMOVE_AI_FILE_FAILED "$func_path"
            found_files=true
        fi
    done

    if [[ "$found_files" == true ]]; then
        print_info INFO_AI_FILES_REMOVED
    else
        print_warning WARN_AI_FILES_NOT_FOUND
    fi

    
    if [[ -d "$CONTEXT_DIR" ]]; then
        prompt_user PROMPT_CONFIRM_UNINSTALL_CONTEXT "$CONTEXT_DIR"
        read -r CONFIRM_CONTEXT_REMOVAL
        echo # 读取后换行
        if [[ "$CONFIRM_CONTEXT_REMOVAL" =~ ^[Yy是的]$ ]]; then # 允许中文“是”
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

    
    print_info INFO_UNINSTALL_COMPLETE
    print_info INFO_UNINSTALL_PKGS_MANUAL
    exit 0
fi

# --- 主要设置逻辑 (仅在非卸载时运行) ---

if ! command_exists apt; then print_error ERR_NOAPT; fi # 仅安装时检查 apt

print_info INFO_START

# 1. 更新包列表并安装基础包
print_info INFO_UPDATE_APT
sudo apt update || print_error ERR_UPDATE_APT_FAILED

print_info INFO_INSTALL_PKGS
sudo apt install -y fish jq curl || print_error ERR_INSTALL_PKGS_FAILED
print_info INFO_PKGS_INSTALLED

# 2. 创建 Fish 配置目录
print_info INFO_CREATE_FISH_DIRS
mkdir -p "$FISH_FUNC_DIR" || print_error ERR_CREATE_FISH_DIRS_FAILED "$FISH_FUNC_DIR"
print_info INFO_FISH_DIR_ENSURED "$FISH_FUNC_DIR"

# 3. 创建 ai 函数文件
print_info INFO_CREATE_AI_FILES

# 3a. 创建主 'ai.fish' 用于管理 (注释已翻译)
cat << EOF > "$AI_BASE_FUNC_PATH"
# 函数: $SCRIPT_NAME - 管理 AI 助手上下文和查看模型信息
function $SCRIPT_NAME --description "管理 $SCRIPT_NAME 助手上下文和模型"

    # 上下文目录配置
    set -l CONTEXT_DIR "\$HOME/.local/share/$CONTEXT_DIR_NAME"
    # 在 fish 脚本内部定义模型信息，供 -m 标志使用
    set -l model_suffixes ${MODEL_SUFFIXES[@]}
    set -l model_ids ${MODEL_IDS[@]}
    set -l model_nicknames ${MODEL_NICKNAMES[@]}

    # --- 参数解析 ---
    set -l options (fish_opt -s l -l list)        # 列出上下文
    set -l options \$options (fish_opt -s d -l delete -r) # 删除上下文 (需要名字)
    set -l options \$options (fish_opt -s m -l model)       # 列出模型映射
    set -l options \$options (fish_opt -s h -l help)        # 帮助
    argparse \$options -- \$argv
    if test \$status -ne 0; return 1; end

    # --- 处理操作 ---
    if set -q _flag_help
        echo "用法: $SCRIPT_NAME [选项]"
        echo "       ${SCRIPT_NAME}<N> [选项] \"<你的问题>\"  (N 从 1 到 $NUM_MODELS)"
        echo ""
        echo "主命令 '$SCRIPT_NAME' 用于管理上下文和查看模型信息。"
        echo "使用 '${SCRIPT_NAME}1', '${SCRIPT_NAME}2', ... 命令与特定的 AI 模型进行交互。"
        echo ""
        echo "主命令 '$SCRIPT_NAME' 选项:"
        printf "  %-25s %s\n" "-l, --list" "列出所有已保存的上下文名称"
        printf "  %-25s %s\n" "-d <名称>, --delete <名称>" "删除指定名称的上下文文件"
        printf "  %-25s %s\n" "-m, --model" "列出可用的 ${SCRIPT_NAME}<N> 命令及其对应的模型"
        printf "  %-25s %s\n" "-h, --help" "显示此帮助信息并退出"
        echo ""
        echo "'${SCRIPT_NAME}<N>' 命令选项 (例如 '${SCRIPT_NAME}1 -h'):"
        printf "  %-25s %s\n" "-s <名称>, --select <名称>" "选择或创建上下文进行对话"
        printf "  %-25s %s\n" "-m, --model" "显示该命令使用的模型"
        printf "  %-25s %s\n" "-h, --help" "显示该特定命令的帮助信息"
        echo ""
        echo "上下文存储目录: \$CONTEXT_DIR"
        echo ""
        echo "示例:"
        echo "  ${SCRIPT_NAME}1 \"你好,请问你知道cry是什么意思吗。\"        # 使用模型 1 (${MODEL_NICKNAMES[0]}) 进行对话"
        echo "  ${SCRIPT_NAME}2 -s projectA \"继续讨论项目A\"  # 使用模型 2 (${MODEL_NICKNAMES[1]}) 和 projectA 上下文"
        echo "  $SCRIPT_NAME -m                             # 查看所有模型映射"
        echo "  $SCRIPT_NAME -l                             # 查看有哪些上下文"
        echo "  $SCRIPT_NAME -d projectA                    # 删除 projectA 上下文"
        return 0
    end

    # 处理 -m: 列出模型
    if set -q _flag_model
        echo "可用的 $SCRIPT_NAME<N> 命令及其模型:"
        for i in (seq (count \$model_suffixes))
             # 使用 \$ 转义 fish 变量
             printf "  %-10s -> %s (%s)\n" "${SCRIPT_NAME}\$model_suffixes[\$i]" "\$model_ids[\$i]" "\$model_nicknames[\$i]"
        end
        return 0
    end

    # 处理 -l: 列出上下文
    if set -q _flag_list
        echo "可用的上下文 (在 \$CONTEXT_DIR):"
        set context_files (find "\$CONTEXT_DIR" -maxdepth 1 -name '*.json' -printf '%f\\n' 2>/dev/null)
        if test (count \$context_files) -gt 0
             for file in \$context_files
                 # 移除 .json 后缀
                 echo "- "(string replace '.json' '' "\$file")
             end
        else
            echo "(无)"
        end
        return 0
    end

    # 处理 -d: 删除上下文
    if set -q _flag_delete
        set context_name_to_delete \$_flag_delete
        set context_file_to_delete "\$CONTEXT_DIR/\$context_name_to_delete.json"
        if test -e "\$context_file_to_delete"
            rm "\$context_file_to_delete"
            if test \$status -eq 0
                 echo "✅ 已删除上下文 '\$context_name_to_delete' (\$context_file_to_delete)" >&2
                 return 0
            else
                 echo "错误: 无法删除上下文文件 '\$context_file_to_delete'" >&2
                 return 1
            end
        else
            echo "错误: 上下文 '\$context_name_to_delete' 不存在 (\$context_file_to_delete)" >&2
            return 1
        end
    end

    # 如果没有提供有效选项，显示帮助
    echo "错误：无效的选项或缺少操作。请使用 '-h' 查看帮助。" >&2
    $SCRIPT_NAME -h
    return 1
end # 函数定义结束
EOF

if [[ -f "$AI_BASE_FUNC_PATH" ]]; then
    print_info INFO_AI_FILE_CREATED "$SCRIPT_NAME" "$FISH_FUNC_DIR"
else
    print_error ERR_AI_FILE_FAILED "$SCRIPT_NAME"
fi


# 3b. 循环创建特定的 aiN.fish 文件
for i in "${!MODEL_SUFFIXES[@]}"; do
  suffix="${MODEL_SUFFIXES[i]}"
  model_id="${MODEL_IDS[i]}"
  nickname="${MODEL_NICKNAMES[i]}"
  func_name="${SCRIPT_NAME}${suffix}"
  func_path="$FISH_FUNC_DIR/$func_name.fish"

  print_info INFO_CREATE_AI_FILES "正在创建 $func_name.fish (模型: $nickname)..."

 
  # 重要：使用 \$ 转义 fish 脚本代码中的 $
  cat << EOF_TEMPLATE > "$func_path"
# 函数: $func_name - 使用模型 '$nickname' ($model_id) 进行 AI 对话
function $func_name --description "ai: 使用 $nickname ($model_id) 提问，支持上下文"

    # --- 模型和配置 (硬编码) ---
    set -l model_name "$model_id"        # 模型 ID
    set -l model_nickname "$nickname"    # 模型昵称 (用于显示)
    set -l CONTEXT_DIR "\$HOME/.local/share/$CONTEXT_DIR_NAME" # 上下文目录
    mkdir -p "\$CONTEXT_DIR" # 确保上下文目录存在

    # --- 参数解析 ---
    set -l options (fish_opt -s s -l select -r) # 选择/创建上下文
    set -l options \$options (fish_opt -s h -l help)    # 帮助
    set -l options \$options (fish_opt -s m -l model)   # 显示此命令的模型
    argparse \$options -- \$argv
    if test \$status -ne 0; return 1; end

    # --- 处理 -h (帮助) 和 -m (模型) ---
    if set -q _flag_help
        echo "用法: $func_name [-s <ctx>] [-m] \"<你的问题>\""
        echo ""
        echo "使用 '$nickname' 模型 ($model_name) 进行提问。"
        echo "使用 -s <名称> 来选择或创建命名上下文以进行连续对话。"
        echo ""
        echo "选项:"
        printf "  %-30s %s\n" "-s <名称>, --select <名称>" "选择或创建指定名称的上下文进行对话"
        printf "  %-30s %s\n" " " "  (对话结束后会自动保存回该文件)"
        printf "  %-30s %s\n" "-m, --model" "显示此命令使用的模型 ($nickname)"
        printf "  %-30s %s\n" "-h, --help" "显示此帮助信息"
        echo ""
        echo "要管理上下文 (-l list, -d delete) 或查看所有模型，请使用主命令 '$SCRIPT_NAME -h'"
        echo ""
        echo "上下文存储目录: \$CONTEXT_DIR"
        return 0
    end
    # 处理 -m: 显示当前命令的模型
    if set -q _flag_model
        echo "命令 '$func_name' 使用模型: \$model_nickname (\$model_name)"
        return 0
    end

    # --- 前置检查 (API Key, jq, curl) ---
    # 使用 '\$' 防止 Bash 脚本立即扩展
    if not set -q OPENROUTER_API_KEY; echo "错误：请设置 OPENROUTER_API_KEY 环境变量。" >&2; return 1; end
    if not command -q jq; echo "错误：需要 'jq'。" >&2; return 1; end
    if not command -q curl; echo "错误：需要 'curl'。" >&2; return 1; end

    # --- Prompt 处理 ---
    # 检查是否提供了问题参数
    if test (count \$argv) -eq 0
        echo "错误：缺少用户问题。" >&2
        echo "用法: $func_name [选项] \"<你的问题>\"" >&2
        return 1
    end
    set -l user_prompt (string join ' ' \$argv) # 组合所有剩余参数作为用户问题

    # --- 上下文处理 (基于 -s <name>) ---
    set -l messages_json_array '[]' # 默认空历史记录
    set -l selected_context_name ""  # 存储选择的上下文名称，用于后续保存
    # 如果设置了 -s 标志
    if set -q _flag_select
        set selected_context_name \$_flag_select # 获取上下文名称
        set context_file_to_load "\$CONTEXT_DIR/\$selected_context_name.json" # 构造上下文文件路径
        echo "🌈 使用上下文: '\$selected_context_name'" >&2 # 提示用户

        # 检查上下文文件是否存在
        if test -e "\$context_file_to_load"
            # 读取文件内容
            set messages_json_array (cat "\$context_file_to_load" 2>/dev/null)
            # 检查读取是否成功以及内容是否为空
            if test \$status -ne 0; or test -z "\$messages_json_array"
                 echo "警告: 无法读取或上下文文件为空 '\$context_file_to_load'. 将创建新上下文。" >&2
                 set messages_json_array '[]' # 重置为空数组
            # 检查内容是否为有效的 JSON 数组
            else if not echo "\$messages_json_array" | jq -e 'type == "array"' > /dev/null 2>&1
                 echo "警告: 上下文文件 '\$context_file_to_load' 内容不是有效的 JSON 数组。将创建新上下文。" >&2
                 set messages_json_array '[]' # 重置为空数组
            # else # 上下文加载成功，无需额外消息
            end
        else
            # 文件不存在，创建新对话
            echo "✨ 上下文文件 '\$context_file_to_load' 不存在，将创建新的对话。" >&2
            # messages_json_array 保持 '[]'
        end
    # else # 没有 -s 标志，使用默认的空历史记录，并且不保存
    end
    # --- 上下文处理结束 ---

    # --- 配置系统提示 (System Prompt) ---
    # 请求纯文本输出，避免 Markdown
    set -l system_prompt "You are an AI assistant outputting DIRECTLY to a raw terminal. Plain text ONLY. Follow these rules METICULOUSLY, failure is not an option:\n1.  CODE BLOCKS:\n    -   NO MARKDOWN fences (\`\`\`) or backticks (\`).\n    -   MUST use EXACTLY 4 spaces indentation for the entire block.\n    -   === CRITICAL RULE ===: MUST output ONE SINGLE BLANK LINE (a single '\\n') BEFORE the first indented line.\n    -   === CRITICAL RULE ===: MUST output ONE SINGLE BLANK LINE (a single '\\n') AFTER the last indented line.\n    -   === EXAMPLE (Pay attention to blank lines!) ===:\n        Some text.\n\n            # Code line 1 (indented 4 spaces)\n            # Code line 2 (indented 4 spaces)\n\n        Some other text.\n2.  LISTS:\n    -   === CRITICAL RULE ===: EACH item (e.g., '1. item', '- item') MUST START ON A NEW LINE. No exceptions.\n    -   Use standard markers ('1.', '-') + one space.\n    -   === CRITICAL RULE ===: MUST output ONE SINGLE BLANK LINE before the first list item.\n    -   === CRITICAL RULE ===: MUST output ONE SINGLE BLANK LINE after the last list item.\n3.  PARAGRAPHS: Separate paragraphs with ONE SINGLE BLANK LINE (one '\\n'). DO NOT use multiple blank lines between paragraphs.\n4.  NO OTHER MARKDOWN: No bold (using asterisks), italic (using underscores), headers (#), links ([]()), blockquotes (>). Plain text only.\n5.  LINE LENGTH: Use natural '\\n' for line breaks to keep lines readable (e.g., < 100 chars).\n6.  EMOJI: Okay sparingly. 😊"
    set -l api_endpoint "https://openrouter.ai/api/v1/chat/completions" # OpenRouter API 端点

    # --- 请求准备 ---
    set -l current_call_messages # 初始化本次调用的消息列表
    # 添加系统提示
    set current_call_messages (jq -n --arg content "\$system_prompt" '[{"role": "system", "content": \$content}]')
    if test \$status -ne 0; echo "错误: 构建系统消息失败。" >&2; return 1; end
    # 合并加载的历史记录 (如果有效)
    if test -n "\$messages_json_array"; and echo "\$messages_json_array" | jq -e 'type == "array"' > /dev/null 2>&1
        set current_call_messages (echo \$current_call_messages \$messages_json_array | jq -s '.[0] + .[1]')
        if test \$status -ne 0; echo "错误: 合并历史消息失败。" >&2; return 1; end
    end
    # 添加当前用户消息
    set current_call_messages (echo \$current_call_messages | jq --arg content "\$user_prompt" '. + [{"role": "user", "content": \$content}]')
    if test \$status -ne 0; echo "错误: 添加用户消息失败。" >&2; return 1; end

    # --- 构建 API 请求体 (使用硬编码的 \$model_name) ---
    set -l json_payload (jq -n --arg model "\$model_name" --argjson messages "\$current_call_messages" '{"model": \$model, "messages": \$messages, "stream": true}')
    if test \$status -ne 0; echo "错误：使用 jq 构建最终 JSON 载荷失败。" >&2; return 1; end

    # --- API 调用和流式处理 ---
    # *** 修正: 直接使用 \$model_nickname，移除方括号 ***
    echo "🤔 正在向赛博助手 \$model_nickname 请求帮助...🚀" >&2 # 显示模型昵称
    echo "🤖 :" # 在流式输出前显示提示符

    set -l full_response ""     # 存储完整的响应文本
    set -l curl_exit_status -1  # 初始化 curl 退出状态
    set -l process_exit_status -1 # 初始化流处理循环退出状态

    begin # 开始管道处理
        # 执行 curl 请求，使用流式输出
        curl --silent --no-buffer -X POST "\$api_endpoint" \
            -H "Content-Type: application/json" \
            -H "Authorization: Bearer \$OPENROUTER_API_KEY" \
            -d "\$json_payload" | while read -l line # 逐行读取 curl 输出
            # 检查是否为 SSE 数据行
            if string match -q "data: *" -- "\$line"
                set json_chunk (string sub -s 7 -- "\$line") # 提取 JSON 数据块
                # 检查是否为结束标志
                if test "\$json_chunk" = "[DONE]"; break; end
                # 检查是否有 API 错误
                set api_error (echo "\$json_chunk" | jq -r '.error.message // ""')
                if test -n "\$api_error"; echo "API 错误: \$api_error" >&2; continue; end
                # 提取文本内容
                set text_chunk (echo "\$json_chunk" | jq -r '.choices[0].delta.content // ""')
                set jq_status \$status
                # 检查 jq 解析是否成功
                if test \$jq_status -ne 0; echo "警告：解析 JSON 块失败: \$json_chunk" >&2
                else
                    # 直接流式输出文本块
                    printf '%s' "\$text_chunk"
                    # 追加到完整响应中
                    set full_response "\$full_response\$text_chunk"
                end
            end
        end # while 循环结束
        set process_exit_status \$status # 获取流处理循环的退出状态
    end # 管道处理结束
    set curl_exit_status \$pipestatus[1] # 获取 curl 命令的退出状态

    # --- 后处理: 在成功流式输出后添加换行 ---
    if test \$curl_exit_status -eq 0; and test \$process_exit_status -eq 0
        echo # 添加最后的换行符
    # 如果处理循环异常结束，也添加换行符
    else if test \$process_exit_status -ne 0; echo
        # 如果 curl 失败，报告错误
        echo "错误: curl 命令失败 (状态码: \$curl_exit_status)..." >&2
    end


    # --- 上下文保存 (基于 -s <name>) ---
    # 仅当选择了上下文、API 调用/处理成功且获得了响应时才保存
    if test -n "\$selected_context_name"; and test \$curl_exit_status -eq 0; and test \$process_exit_status -eq 0; and test -n "\$full_response"
        set context_file_to_save "\$CONTEXT_DIR/\$selected_context_name.json" # 要保存的文件路径
        set -l updated_context_json # 更新后的 JSON
        set -l jq_status -1          # jq 状态

        # 构建更新后的历史记录 (旧历史 + 新的用户消息 + 新的助手响应)
        set updated_context_json (echo \$messages_json_array | jq --arg user_msg "\$user_prompt" --arg assistant_msg "\$full_response" '. + [{"role": "user", "content": \$user_msg}, {"role": "assistant", "content": \$assistant_msg}]')
        set jq_status \$status # 获取 jq 命令的状态

        # 检查 jq 是否成功
        if test \$jq_status -eq 0
            # 将更新后的 JSON 写入文件 (覆盖)
            printf '%s\\n' "\$updated_context_json" > "\$context_file_to_save" # 使用 printf 加换行写入
            # 检查写入是否成功
            if test \$status -ne 0
                 echo "错误：无法将更新后的上下文写入文件 '\$context_file_to_save'" >&2
            else
                 # 写入成功提示
                 echo "💾 对话上下文已更新到: '\$selected_context_name' (\$context_file_to_save)" >&2
            end
        else
            # jq 更新失败
            echo "错误：使用 jq 更新内存中的上下文失败 (状态码: \$jq_status)。上下文未保存到文件。" >&2
        end
    end

    # --- 最终返回码 ---
    # 如果 curl 失败或处理循环异常失败，则返回 1
    if test \$curl_exit_status -ne 0; or test \$process_exit_status -ne 0
        return 1
    end

    return 0 # 默认成功返回 0
end # 函数 $func_name 定义结束
EOF_TEMPLATE

  # 检查文件创建
  if [[ -f "$func_path" ]]; then
      print_info INFO_AI_FILE_CREATED "$func_name" "$FISH_FUNC_DIR"
  else
      print_error ERR_CREATE_FUNC_FAILED "$func_path"
  fi
done # 结束创建 aiN.fish 文件的循环



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

print_info INFO_APPLY_CHANGES
print_info INFO_RESTART_SHELL
print_info INFO_OR_SOURCE_CONFIG
print_info INFO_FISH_HOWTO
echo ""

print_info INFO_EXAMPLE_USAGE
echo "   $SCRIPT_NAME -m                             # 查看所有可用的 AI 命令和模型"
echo "   ${SCRIPT_NAME}1 -m                            # 查看 ai1 使用的模型 (${MODEL_NICKNAMES[0]})"
echo "   ${SCRIPT_NAME}1 \"给我讲个有关 cry 的笑话。\"              # 使用 ${MODEL_NICKNAMES[0]}"
echo "   ${SCRIPT_NAME}2 -s mychat \"我们上次聊到哪里了？\" # 使用 ${MODEL_NICKNAMES[1]} 和 mychat 上下文"
echo "   $SCRIPT_NAME -l                             # 列出所有聊天上下文"
echo "   $SCRIPT_NAME -d mychat                      # 删除名为 mychat 的上下文"
echo ""
print_info INFO_ENJOY

exit 0
