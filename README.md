# OpenRouter Simple AI - “不靠谱”的命令行 AI 助手

**(曾短暂用名 'ag' - 后来改名了，主要是怕跟真正认真写的的工具重名，而且叫 'ai' 感觉……更好玩一点？也许 ai 更加碰瓷？管他的，只是为了名字简短方便敲指令而已)**

故事是这样的：**我**让一个 AI 写了个简单的命令行小工具，用来通过 OpenRouter 跟其他 AI 聊天。然后，一个人类（就是**我**！）稍微戳了戳它，改了点明显不对劲的地方，然后……嗯！就有了这个玩意儿。基本上，这就是个用 Fish Shell 脚本拼凑出来的、连接到云端 AI 的小工具。🤖🔧

你可以把 `ai` 和它的编号小弟们 (`ai1`, `ai2`, ... `ai5`) 想象成一支有点难以预测的 AI 助理小队，每个都被“硬塞”了一个*不同的* AI 模型。想要个快速答案？需要点头脑风暴？或者纯粹就是无聊了？随便挑一个 `ai<N>` 吧！它支持流式响应（所以你能实时围观 AI “思考”的过程……大概是吧），还允许你用上下文功能来勉强追踪不同的聊天记录。

它就是个玩具。一个实验品。八成有 Bug。用它、玩坏它、然后笑话它。祝你玩得开心！😂

---

## 功能特性 (它*努力*想做到的事)

*   **直连 OpenRouter 瞎聊**: 有礼貌地（希望吧）对着 OpenRouter API (`/chat/completions`) 喊话。
*   **“现场打字”效果**: 一字一顿地吐出 AI 的回复（纯文本限定，没花里胡哨的）。
*   **聊天记忆 (凑合版)**: 用命名文件来管理多个对话：
    *   开始/继续一个聊天线索: `ai<N> -s <聊天名> "咱刚才聊到哪了？"`
    *   查看你那一团糟的聊天列表: `ai -l`
    *   从地球上抹掉某个聊天记录: `ai -d <聊天名>`
    *   默认模式？纯粹失忆。问个问题，得到回答，然后忘得一干二净！
*   **指定“大脑”**: 每个 `ai<N>` 命令都绑定了一个特定的模型 (用 `ai -m` 查看谁是谁)。
*   **手痒可改 (风险自负)**: 你*可以试着*通过编辑文件来更改每个 `ai<N>` 用哪个模型 (详情见下)。
*   **轻量级选手**: 就靠 `fish`, `curl`, `jq` 运行。如果这都能让你电脑卡，那问题可能有点大。
*   **安装 & 跑路还算方便**: 带了个脚本，*应该*能在 Debian/Ubuntu 上跑通，还附赠的卸载选项。

## 安装 (抓稳了！)

**我**准备了个脚本！它在 Debian/Ubuntu 系统上尽力而为。

1. **搞到安装脚本:**

   ```bash
   # --- 直接 curl ---
   curl -O https://raw.githubusercontent.com/cry0404/ai-for-cli/main/ai.sh
   # --- 或者 ---
   # 如果你就是喜欢 clone...
   # git clone https://github.com/cry0404/ai-for-cli.git
   # cd Openrouter-simple-ag
   # (如果你 clone 了，请确保用的是仓库里的 setup_ai_tool.sh)
   ```

2. **赋予它运行的权力 (危险动作！):**

   ```bash
   chmod +x ai.sh
   ```

3. **运行这个“神奇”脚本:**

   ```bash
   ./ai.sh
   ```

   它会尝试用 `apt` 安装 `fish`, `jq`, `curl`。然后，它会往 Fish 函数的神圣文件夹 (`~/.config/fish/functions/`) 里扔一堆 `.fish` 文件 (`ai.fish`, `ai1.fish`, ... `ai5.fish`)。

   *   **注意！** 你需要 Fish Shell 3.0 或更高版本。如果你还在用老古董版本，这脚本只会无奈的报错。

4. **献祭 API 密钥:** 这步没得商量。你需要一个 OpenRouter API 密钥。把它设成环境变量。在终端里运行下面这行，并且**郑重建议你把它加到 `~/.config/fish/config.fish` 文件里**，否则你每次都得重新设。

   ```fish
   # 把这行加到 ~/.config/fish/config.fish
   set -gx OPENROUTER_API_KEY 'sk-or-v1-你的密钥放这里啊喂'
   # (对，用你 *真的* 密钥替换上面那串！)
   ```

5. **神圣仪式：重启你的 Shell！** 打开一个**全新的**终端窗口。如果 Fish 不是你的默认 Shell，先输入 `fish`。别跳过这步！Fish 需要时间去闻一闻那些新来的函数文件。

## 卸载 (尖叫着跑开)

想把这工具驱逐回数字虚空？

1. 运行安装脚本，但告诉它你受够了：

   ```bash
   ./ai.sh --uninstall
   ```

2. 脚本会把 `ai.fish` 和所有的 `ai<N>.fish` 文件都去掉。没啦 : (

3. 然后它会有点尴尬地问你，要不要删掉聊天记录文件夹 (`~/.local/share/ai_contexts`)。你看着办。

4. 像个懒惰的客人，它**不会**帮忙清理它安装的 `fish`, `jq`, `curl` 这些包。如果你不想要了，得自己动手 (`sudo apt remove fish jq curl`)。

## 使用方法 (怎么跟这些 AI 唠嗑)

主要两种玩法：

1.  管理杂项: `ai [选项]`
2.  正经聊天: `ai<N> [选项] "你的正经问题"` (这里的 `<N>` 是 1 到 5)

**举栗子:**

* 看看手下都有哪些 AI 小弟以及它们分别是哪个模型的：

  ```bash
  ai -m
  ```

* 跟 1 号助理聊天 (天知道它现在是哪个模型)：

  ```bash
  ai1 "为啥天是蓝的？用三岁小孩都能听懂的话解释，假设我还稍微有点走神。"
  ```

* 用 3 号助理继续你的“征服世界”计划：

  ```bash
  ai3 -s 征服世界 "好了，第二步：搞到更多的猫。咋整？"
  ```

* 看看你都忘了哪些聊天记录：

  ```bash
  ai -l
  ```

* 删掉那个尴尬的“学杂耍”聊天记录：

  ```bash
  ai -d 学杂耍
  ```

* 实在没辙了，就喊救命：

  ```bash
  ai -h   # 通用帮助
  ai1 -h  # ai1 的专属帮助
  ```

## 配置 & 折腾 

* **API 密钥**: 看安装步骤 4。设置 `OPENROUTER_API_KEY`。

* **更换模型 (高级作死技巧):**

  * 每个 `ai<N>` 命令用哪个模型是**写死**在它自己的文件里的。想让 `ai1` 换个脑子？你就得编辑 `~/.config/fish/functions/ai1.fish`。想改 `ai2`？编辑 `~/.config/fish/functions/ai2.fish`，以此类推。

  * 打开对应的文件 (比如 `ai1.fish`)，在靠近顶部的地方找到这两行：

    ```fish
    # --- 模型和配置 (硬编码) ---
    set -l model_name "moonshotai/kimi-vl-a3b-thinking:free" # <-- 改这个模型 ID
    set -l model_nickname "Kimi-Thinking"                   # <-- 改这个昵称 (显示用)
    ```

  * 把模型 ID 字符串换成你想用的 OpenRouter 模型 ID。顺便改下昵称，这样你自己才知道在跟谁说话！

* **编辑完之后的【【【关键步骤】】】：** Fish 不会自动发现你改了文件！你**必须**二选一：

  1.  **启动一个全新的 Fish shell 会话。** (最简单的方法)
  2.  **或者，`source` 你刚刚修改的那个文件：** 如果你改了 `ai1.fish`，就在你*当前的* Shell 里运行 `source ~/.config/fish/functions/ai1.fish`。

  *   **说真的，别忘了这步！** 否则，你还是在跟旧模型聊天，然后奇怪为啥你英明神武的修改一点用都没有。这种事谁都可能遇到。😉

* **聊天记录存放地**: 你那些宝贵的（或者丢人的）聊天记录住在 `~/.local/share/ai_contexts/`。

## 依赖 (就这点家当)

*   `fish` (Shell): 版本 3.0+。
*   `jq`: 跟 JSON 数据交流。
*   `curl`: 实际跟互联网唠嗑用的。

## 问题排查 (AI 助手闹脾气了怎么办)

*   **"找不到命令 'ai'/'aiN'" 或者 `source: Error while reading file...`**:
    *   安装完（步骤 5）你重启 Shell 了吗？说真的，重启了吗？
    *   你的 Fish 版本是不是老掉牙了？用 `fish --version` 查查。需要 3.0+。需要的话就升级 (`sudo apt update && sudo apt install fish`)。
    *   安装脚本是不是卡壳了？看看 `~/.config/fish/functions/ai.fish` 和 `aiN.fish` 文件到底在不在。要不……再运行一遍安装脚本试试？
*   **聊天记录行为怪异 (不保存/不加载)?**:
    *   检查权限：你当前用户真的能往 `~/.local/share/ai_contexts/` 里写东西吗？
    *   偷偷看看那个目录下的 `.json` 文件。它们还是合法的 JSON 数组吗？可能哪个文件不小心被你搞坏了？

## 贡献 (或者说，帮忙收拾这个烂摊子)

听着，这玩意儿是 AI 生成的，然后被**我**稍微收拾了一下。里面八成全是坑。欢迎你把它 clone 下去，随便改，让它变得不那么烂，加点功能，或者就是指着它哈哈大笑。欢迎提交 Pull Request，但别指望太多！记住，它只是个玩具。

是的，就连这个 Readme.md 都是 AI 写的，你还能指望这个 cry 干些什么呢！

