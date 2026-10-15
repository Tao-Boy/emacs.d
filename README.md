# emacs.d

面向 **Emacs 31.1** 的个人配置：Evil + Vertico/Orderless/Marginalia/Corfu +
Org + [Denote](https://protesilaos.com/emacs/denote) 笔记。

结构与启动优化参考了 [minimal-emacs.d](https://github.com/jamescherti/minimal-emacs.d)、
[Doom Emacs](https://github.com/doomemacs/doomemacs)、
[Centaur Emacs](https://github.com/seagle0128/.emacs.d) 和
[Purcell 的 emacs.d](https://github.com/purcell/emacs.d)。

## 目录结构

| 文件 | 内容 |
| --- | --- |
| `early-init.el` | GC、启动期 I/O 优化、package quickstart、原生编译、frame 参数 |
| `init.el` | 版本检查、按顺序加载 `lisp/` 下的模块、加载 `custom.el` |
| `lisp/init-const.el` | 平台常量 |
| `lisp/init-package.el` | 软件源、`use-package`、`:ensure` 快速路径 |
| `lisp/init-basic.el` | 运行期 GC 策略、`tau-first-input-hook`、默认设置、savehist/recentf/saveplace |
| `lisp/init-ui.el` | 主题、字体（含中文和 emoji）、mode line、括号、滚动、终端 |
| `lisp/init-evil.el` | Evil |
| `lisp/init-completion.el` | Vertico、Orderless、Marginalia、Corfu |
| `lisp/init-snippet.el` | Tempel、AAS（Org 中的 LaTeX 数学片段） |
| `lisp/init-dired.el` | Dired、Dired-X |
| `lisp/init-prog.el` | 行号、括号配对、tree-sitter、Eglot |
| `lisp/init-latex.el` | AUCTeX |
| `lisp/init-org.el` | Org、Denote |
| `lisp/init-rime.el` | 中文输入：Rimel + 预编译的 liberime |
| `lisp/init-ai.el` | ECA（Editor Code Assistant） |
| `custom.el` | Customize 保存的设置 |

## 启动优化

1. **启动期间暂停 GC**：`gc-cons-threshold` 设为最大值，启动完成后改为 64 MB；
   minibuffer 打开时不 GC，失去焦点时顺便 GC。
2. **启动期间跳过 `file-name-handler-alist`**：每次 `load` 都会遍历它；在
   `after-init-hook` 中恢复，因此命令行上的 `.gz`/TRAMP 文件仍可正常打开。
3. **`load-path-filter-function`（Emacs 31）**：缓存 `load-path` 目录内容，
   `require` 只查找真正包含该文件的目录。
4. **package quickstart**：启动时只加载一个预先生成的 autoloads 文件，
   不再逐个扫描包目录，也不加载 package.el。
5. **`:ensure` 快速路径**：`use-package` 的 `:ensure` 每次都会加载 package.el；
   `tau-package-ensure` 先用 `package-installed-p`（Emacs 31 预加载，
   quickstart 下直接查 `package-activated-list`）判断，已安装的包零开销。
6. **延迟加载**：Org、Denote、Dired、AUCTeX、Eglot、Rime、ECA 都在首次使用时加载；
   Vertico、Marginalia、savehist、recentf、which-key、auto-revert、so-long
   在第一次按键前（`tau-first-input-hook`）才启用；`*scratch*` 使用
   `fundamental-mode`，避免启动时触发 `prog-mode-hook`。
7. **frame 参数**：在 `early-init.el` 中关闭菜单栏/工具栏/滚动条，并预设主题
   背景色，没有白屏闪烁；`frame-inhibit-implied-resize` 避免设置字体时重排窗口。
8. **原生编译**：包在安装时编译为本地代码（`package-native-compile`），
   内置库（如 Org）保持 JIT 编译。

### 实测

Emacs 31.1（原生编译、tree-sitter）在终端（`-nw`）中各启动 10 次，两份配置使用相同的
已原生编译的软件包：

| | 平均 `emacs-init-time` | 启动后已加载的 feature 数 |
| --- | --- | --- |
| 旧配置（加上 `regexp-opt` 修复后才能启动） | 288 ms | 273 |
| 新配置 | 142 ms | 189 |

Org、Denote、package.el、Vertico、Corfu、Dired、tree-sitter 都不在启动时加载；剩余耗时
主要是 Evil（约 35 ms）和主题（约 17 ms）。

## 用到的 Emacs 31 新特性

- `load-path-filter-function`：加速库查找。
- `treesit-enabled-modes`：使用内置的 tree-sitter 模式映射；缺少语法库时按
  `treesit-auto-install-grammar`（默认询问）安装，语法库版本使用 Emacs 自带的
  固定版本。下载通过 `tau-github-mirror`（默认 gh-proxy.com）进行，
  只作用于该次 git 调用，不修改全局 git 配置。
- TTY 子窗口（child frames）：终端里 Corfu 也能弹出补全框，
  并使用 Unicode 边框（`standard-display-unicode-special-glyphs`）。
- `xterm-mouse-mode` 在兼容终端中默认开启，无需手动启用。
- `xterm-update-cursor`、`mode-line-collapse-minor-modes`、
  `completion-pcm-leading-wildcard`、`recentf-autosave-interval`、
  `save-place-autosave-interval`。
- Org 9.8：`org-startup-with-link-previews`、`org-src-content-indentation`。

## 使用

```sh
git clone <this repo> ~/.config/emacs   # 或 ~/.emacs.d
emacs                                   # 首次启动自动安装软件包
```

首次启动会从 USTC 镜像安装软件包并生成 `package-quickstart.el`，之后的启动不再
加载 package.el。手动安装或升级包后 quickstart 文件会自动刷新；如果出现异常，
可以执行 `M-x package-quickstart-refresh`。

查看启动耗时：启动后 echo area 会显示 `Emacs ready in …`，也可以执行
`M-x emacs-init-time`。用 `emacs --debug-init` 启动时会记录 `use-package`
统计信息，可通过 `M-x use-package-report` 查看各包耗时。

### 笔记（Denote，`C-c n`）

笔记放在 `~/org/notes/`（`denote-directory`），每条笔记一个文件，文件名形如
`20261014T130053--标题__关键词.org`，按领域放在子目录中（新建时先选子目录）。
笔记之间用 `[[denote:标识符]]` 链接。

| 按键 | 命令 |
| --- | --- |
| `C-c n n` | `denote`：新建笔记（子目录、标题、关键词） |
| `C-c n f` | `denote-open-or-create`：打开笔记，不存在则新建 |
| `C-c n i` | `denote-link-or-create`：插入笔记链接，不存在则新建 |
| `C-c n l` | `denote-find-link`：跳转到当前笔记链接到的笔记 |
| `C-c n b` | `denote-backlinks`：反向链接列表 |
| `C-c n B` | `denote-find-backlink`：跳转到某条反向链接 |
| `C-c n s` | `denote-grep`：全文搜索 |
| `C-c n r` | `denote-rename-file`：修改标题/关键词并重命名文件 |
| `C-c n R` | `denote-rename-file-using-front-matter`：按文件头重命名 |
| `C-c n d` | `denote-sort-dired`：在 Dired 中筛选、排序笔记 |
| `C-c c n` | 通过 `org-capture` 新建 Denote 笔记 |

反向链接和全文搜索通过 xref 进行，安装了 `rg` 时自动使用 ripgrep。
`dvisvgm`（可选）用于 SVG 公式预览。

### 中文输入（Rimel，`C-\`）

`C-\` 切换输入法，默认方案 `luna_pinyin_simp`，候选显示在光标旁的子窗口中
（Emacs 31 的终端里也可以）。在代码、英文字母之后、大写字母、Evil normal
state、Org 源码块和数学公式中自动输入英文。`M-i` 把光标前的拼音转换成汉字。

第一次按 `C-\` 时，如果找不到 liberime 模块，会询问是否下载
[liberime](https://github.com/emacs-rime/liberime/releases) 的预编译版本
（`M-x tau-liberime-install` 也可以），解压到 `liberime/`，**不需要编译**：

- **Windows**：下载 `-with-deps` 包，自带 librime、依赖 DLL 和 Rime 输入方案，
  不需要 MSYS2 或小狼毫。根据 Emacs 链接的 C 运行库自动选择 `ucrt-x86_64` 或
  `x86_64` 版本（官方发布的 Emacs 两种都有），ARM 选 `clang-arm64`。
  GCC 运行库 DLL 使用 Emacs 自带的那份。
  Windows 不会在模块所在目录查找依赖 DLL，而 `setenv` 也改不了 Emacs 进程自身的
  `PATH`，所以配置会先把 `bin/` 中的依赖 DLL 逐个载入，再加载 `liberime-core.dll`，
  不需要修改系统环境变量。
- **GNU/Linux、macOS**：下载对应平台的模块，需要系统中已安装 librime
  （如 `apt install librime1 librime-data`、`brew install librime`）。

下载通过 `tau-github-mirror`（默认 gh-proxy.com）进行，设为 `nil` 则直连 GitHub。
Rime 用户数据保存在 `rime/`，第一次启用时部署词库需要一些时间。

### AI 编程助手（ECA，`C-c e`）

| 按键 | 命令 |
| --- | --- |
| `C-c e e` | `eca`：启动服务并打开聊天窗口 |
| `C-c e t` | 显示/隐藏聊天窗口 |
| `C-c e i` | 在当前缓冲区中直接提问（行内结果） |
| `C-c e a` | 把当前文件或选区加入上下文 |
| `C-c e n` / `C-c e s` | 新建对话 / 切换对话 |
| `C-c e w` | 所有工作区和对话的面板 |
| `C-c e m` | 选择模型 |
| `C-c e ,` | 设置（MCP 服务器等） |
| `C-c e q` | 停止服务 |

第一次 `C-c e e` 会自动下载 `eca` 服务端（也可以把 `eca` 放进 `PATH` 或设置
`eca-custom-command`）。模型、服务商和 API key 在服务端配置：
`M-x eca-open-global-config`。聊天窗口中按 `C-c .` 打开命令菜单。

## 相对旧配置的行为变化

- 修复：Emacs 31.1 下旧配置会在启动时无限递归（`load-path-filter-cache-directory-files`
  调用未预加载的 `regexp-opt`，自动加载又触发过滤函数），现在先加载 `regexp-opt`。
- Org 中不再渲染 LaTeX 符号（`org-pretty-entities` 关闭）：`\alpha` 不显示为 α，
  `x_{i}` 不再抬升显示，公式只做语法着色；公式预览也不会自动生成。
- Corfu 自动补全改为 0.1 秒延迟、2 个字符触发（原为 0 秒、1 个字符），减少每次按键的开销。
- tree-sitter 语法库改用 Emacs 31 自带的固定版本配方（仍走 gh-proxy 镜像），
  不再跟踪各仓库的最新提交；缺少语法库时询问是否安装，拒绝或失败时退回传统模式。
- Evil 使用内置的 `undo-redo`，`C-r` 可以重做。
- `*scratch*` 使用 `fundamental-mode`；需要求值时用 `M-x lisp-interaction-mode`。
- 不再手动开启 `xterm-mouse-mode`（Emacs 31 在兼容终端中默认开启）。
- Org 笔记部分改用 Denote，自写的知识库命令（`tau-org.el`）、`tau-org-*` 选项以及
  为它服务的 Org ID 设置（`org-id-link-to-org-use-id` 等、`C-c n I`）已删除。
  旧笔记的文件名 `时间戳--标题.org` 已是 Denote 格式，可以直接使用；旧的
  `[[id:…]]` 链接仍可跳转（加载 Org 时会加载 org-id），但不计入 Denote 的反向链接，
  可以用 `denote-rename-file` 补上关键词、逐步改为 `denote:` 链接。
- 新增：Rimel 中文输入、ECA；which-key、recentf、saveplace、auto-revert、so-long（均延迟启用），
  中文标点/假名/注音字体与 emoji 字体，Dired 显示可读文件大小并目录优先（Linux），
  Eglot 默认关闭事件日志并在最后一个缓冲区关闭时停止服务器。
- rainbow-delimiters 的颜色改用 `face-spec-set` 设置，不再写入 `custom.el`；
  `custom.el` 中过期的 `package-selected-packages` 与重复的 face 设置已删除。
