# emacs.d

面向 **Emacs 31.1** 的个人配置，以 Emacs 原生按键和内置功能为主：
Fido + Completion Preview 补全、Org 笔记、tree-sitter、Eglot、Modus Vivendi 主题。

直接配置的第三方包从 16 个减到 **5 个**（不含这些包自身的依赖）：

| 保留的包 | 用途 |
| --- | --- |
| [Rimel](https://github.com/Tao-Boy/rimel) | 中文输入，通过 `:vc` 安装 |
| ECA | AI 编程助手 |
| Tempel、AAS | Org 中自动展开的 LaTeX 数学片段 |
| AUCTeX | LaTeX 编辑 |

Evil、evil-collection、Denote 已移除。通用功能改用以下内置方案：

| 原插件 | 当前方案 |
| --- | --- |
| doom-themes | Modus Vivendi |
| Vertico、Orderless、Marginalia | Fido 纵向候选列表、flex 匹配和内置补全信息 |
| Corfu | Completion Preview；`C-M-i` 调用 `completion-at-point` 查看候选 |
| rainbow-delimiters | `show-paren-mode` 高亮匹配括号 |
| expreg | `C-M-SPC`（`mark-sexp`）、`M-h`、`C-x h` 等原生选区命令 |
| posframe | Rimel 在回显区显示候选 |

结构与启动优化参考了 [minimal-emacs.d](https://github.com/jamescherti/minimal-emacs.d)、
[Doom Emacs](https://github.com/doomemacs/doomemacs)、
[Centaur Emacs](https://github.com/seagle0128/.emacs.d) 和
[Purcell 的 emacs.d](https://github.com/purcell/emacs.d)。

## 目录结构

| 文件 | 内容 |
| --- | --- |
| `early-init.el` | GC、启动期 I/O 优化、package quickstart、原生编译、frame 参数 |
| `init.el` | 版本检查、按顺序加载模块、加载 `custom.el` |
| `lisp/init-const.el` | 平台常量 |
| `lisp/init-package.el` | 软件源、镜像、内置 `use-package`、`:ensure` 快速路径 |
| `lisp/init-basic.el` | GC、首次输入钩子、默认设置、会话记录、内置 which-key |
| `lisp/init-ui.el` | 内置主题、字体、mode line、括号和滚动 |
| `lisp/init-keybindings.el` | 原生按键增强、文件与模式开关前缀 |
| `lisp/init-completion.el` | 内置 Fido、flex 和 Completion Preview |
| `lisp/init-snippet.el` | Tempel、AAS 的 Org 数学片段 |
| `lisp/init-dired.el` | 内置 Dired、Dired-X |
| `lisp/init-prog.el` | 行号、括号配对、tree-sitter、Eglot |
| `lisp/init-latex.el` | AUCTeX |
| `lisp/init-org.el` | 内置 Org、capture、agenda、Org ID |
| `lisp/init-rime.el` | Rimel 输入法和上下文判断 |
| `lisp/init-ai.el` | ECA |
| `site-lisp/org-ratex.el` | 本地公式预览扩展及数学环境判断，供数学片段使用 |
| `custom.el` | Customize 保存的设置 |

## 使用与迁移

```sh
git clone https://github.com/Tao-Boy/emacs.d.git ~/.config/emacs  # 或 ~/.emacs.d
emacs
```

首次启动从 USTC 镜像安装缺少的 ELPA 包；Rimel 通过 `:vc` 从 GitHub 安装。
`tau-elpa-mirror` 和 `tau-github-mirror` 分别控制 ELPA 与 tree-sitter 下载镜像。

更新旧配置后重启 Emacs，恢复原生编辑按键。配置不再安装或启用已移除的插件；
已安装的包不会被自动删除。需要清理磁盘时，可在 `M-x list-packages` 中手动卸载
Evil、evil-collection、Denote、doom-themes、Vertico、Orderless、Marginalia、Corfu、
rainbow-delimiters、expreg、posframe。其他自定义配置仍在使用的包应保留。
卸载后执行 `M-x package-quickstart-refresh`，再重启 Emacs。

原有笔记文件不改名、不删除。旧的 `[[denote:标识符]]` 链接需要改为标准
`[[file:相对路径.org][标题]]` 或 `[[id:UUID][标题]]` 链接；移除 Denote 后不再提供
其专用链接解析、反向链接和重命名功能。已有 Org ID 链接仍由内置 `org-id` 处理。

### 按键与补全

按下前缀后稍等，内置 which-key 会显示后续按键。首次按键前启用
`repeat-mode` 和 `delete-selection-mode`，分别提供重复命令和输入替换选区。

| 按键 | 命令 |
| --- | --- |
| `C-a` | 先到缩进处，再到行首；Org 保持自己的行为 |
| `C-w` / `M-w` | 剪切 / 复制选区；无选区时作用于当前行 |
| `M-<up>` / `M-<down>` | 移动当前行或选区所在行；Org 保持自己的行为 |
| `C-c d` | `duplicate-dwim`：复制当前行或选区 |
| `C-M-SPC` | `mark-sexp`：选择表达式，重复执行扩大选区 |
| `M-h` / `C-x h` | 选择段落 / 整个缓冲区 |
| `M-z` / `M-/` | `zap-up-to-char` / `hippie-expand` |
| `C-/` / `C-M-_` | 内置撤销 / 重做 |
| `C-g` | 退出命令，也可关闭补全窗口、从其他窗口退出 minibuffer |
| `M-o` | 切换窗口 |
| `C-x 2` / `C-x 3` | 分割窗口并切换到新窗口 |
| `C-x k` / `C-x C-b` | 关闭当前缓冲区 / ibuffer |
| `C-x C-r` 或 `C-c f r` | 最近文件 |
| `C-c f R` | 重命名当前文件 |
| `C-c f y` | 复制当前文件路径；`C-u` 复制目录，Dired 中复制当前目录 |
| `C-c f s` | 通过 TRAMP 以 root 编辑当前文件；`C-u` 选择文件 |
| `C-c t l` / `C-c t w` | 行号 / 软换行 |
| `C-c t t` / `C-c t s` / `C-c t f` | 截断长行 / whitespace / 全屏 |

`C-z` 取消绑定，挂起或最小化仍用 `C-x C-z`。`C-c t e` 和 `C-c n` 不再绑定。
`C-=`、`C--` 不再用于扩大或缩小选区；负数参数恢复原生 `C--`，也可用 `M--`。

- **minibuffer**：Fido 纵向显示候选，使用 flex 按字符顺序模糊匹配，
  不再使用 Orderless 的无序多词匹配。`C-n` / `C-p` 选择候选，`RET` 确认；
  `M-j` 提交原样输入，例如创建文件。文件名保留 partial-completion 匹配。
- **代码补全**：输入两个字符、停顿 0.1 秒后显示 Completion Preview 内联建议。
  有建议时 `TAB` 接受，`M-n` / `M-p` 切换；`RET` 保留主模式行为。
  `C-M-i` 手动调用 `completion-at-point`，后端继续使用主模式和 Eglot。

### 笔记与任务（内置 Org）

| 按键 | 用途 |
| --- | --- |
| `C-c c i` | 收集到 `~/org/inbox.org` |
| `C-c c t` | 创建 TODO 到 `~/org/tasks.org` |
| `C-c c n` | 新笔记作为标题收集到 `~/org/notes.org` |
| `C-c C-c` / `C-c C-k` | 完成 / 取消当前 capture |
| `C-c a` | agenda，只扫描 inbox 和 tasks |
| `C-c l` / `C-c C-l` | 存储 / 插入 Org 链接 |
| `C-c C-o` | 打开光标处链接 |
| `C-x C-f` / `C-x d` | 打开笔记文件 / 用 Dired 浏览 `~/org/notes/` |
| `M-x rgrep` | 在笔记目录中全文搜索 |

文件名相对于 `org-directory`（默认 `~/org/`）解析；新笔记不会加入 agenda。
保留一个文件一条笔记的旧文件也能直接打开、编辑和插入标准文件链接。
需要稳定的标题链接时，执行 `M-x org-id-get-create` 创建 ID，再存储、插入链接。

Org 不会自动生成公式预览，LaTeX 保持原始文本，避免打开大篇数学笔记时卡顿。
AAS、Tempel 保留现有数学片段：例如 `mk` 插入行内公式，`dm` 插入独立公式，
公式内 `;a` 展开为 `\alpha`、`ff` 展开分式模板。模板内用 `TAB` / `S-TAB` 切换位置。
`org-ratex-in-math-p` 用于正确识别含列表样式行的数学环境。
`dvisvgm` 为可选的 SVG 公式预览工具。

### 中文输入（Rimel，`C-\`）

使用 [Tao-Boy/rimel](https://github.com/Tao-Boy/rimel)，通过 `use-package :vc`
跟踪仓库最新提交。其 C 模块需要编译器、`make`、`pkg-config`、librime 开发文件
（≥ 1.8）及 Rime 方案数据。Debian/Ubuntu 可安装
`build-essential pkg-config librime-dev rime-data-luna-pinyin`。

MELPA 的同名包接口不同；如果已安装，应先用 `M-x package-delete` 卸载旧的
`rimel-<版本号>` 再重启，由 `:vc` 安装此项目。原有 `rime/` 用户数据目录继续使用。

`C-\` 切换输入法。首次激活时可在后台编译模块，也可执行
`M-x rimel-compile-module`。候选统一在内置回显区显示，无需 posframe。
在代码、英文字母或数字之后、大写字母、Org 源码块和数学公式中自动使用英文。

| 按键 | 用途 |
| --- | --- |
| `C-c r s` | 选择方案，如 `luna_pinyin_simp` |
| `C-c r a` | 切换 Rime 西文模式 |
| `C-c r f` | 下一次组字忽略自动英文判断 |
| `C-c r d` | 修改配置后后台部署 |

配置与词库保存在 `rime/`；方案列表在 `rime/default.custom.yaml` 中设置。
编译参数、方案数据路径和 Nix 支持见 [Rimel 文档](https://github.com/Tao-Boy/rimel#安装)。

### AI 编程助手（ECA，`C-c e`）

| 按键 | 用途 |
| --- | --- |
| `C-c e e` / `C-c e t` | 启动 / 显示或隐藏聊天窗口 |
| `C-c e i` / `C-c e a` | 在当前缓冲区提问 / 添加文件或选区上下文 |
| `C-c e n` / `C-c e s` | 新建 / 切换对话 |
| `C-c e w` / `C-c e m` | 工作区面板 / 选择模型 |
| `C-c e ,` / `C-c e q` | 设置 / 停止服务 |

首次使用自动下载 `eca` 服务端，也可将其放入 `PATH` 或设置 `eca-custom-command`。
模型、服务商和 API key 在服务端配置：`M-x eca-open-global-config`。

## 启动与性能

- 启动期间推迟 GC，完成后使用 64 MB 阈值；minibuffer 打开时暂停 GC。
- 启动期跳过文件名处理器，在 `after-init-hook` 中恢复，保留命令行 `.gz`、TRAMP 支持。
- Emacs 31 的 `load-path-filter-function` 缓存库目录，先加载 `regexp-opt` 防止递归。
- package quickstart 预先生成 autoloads；已安装包通过 `:ensure` 快速路径跳过 package.el。
- Org、Dired、AUCTeX、Eglot、Rimel、ECA 延迟加载；Fido、which-key、会话记录等在首次按键前启用。
- `*scratch*` 使用 `fundamental-mode`，需要求值可切换到 `lisp-interaction-mode`。
- 首帧直接使用主题底色，避免闪白；安装包时进行原生编译。
- tree-sitter 使用 Emacs 31 自带的固定版本配方，缺少语法库时询问安装，失败时退回传统模式。

启动后显示 `Emacs ready in …`，也可执行 `M-x emacs-init-time`。
`emacs --debug-init` 启用 use-package 统计，通过 `M-x use-package-report` 查看。
本次精简后的启动耗时尚未重新测量；旧配置的性能数字不再作为当前结果。
