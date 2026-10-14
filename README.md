# emacs.d

面向 **Emacs 31.1** 的个人配置：Evil + Vertico/Orderless/Marginalia/Corfu +
Org 知识库（基于 Org ID、fd、ripgrep，无数据库）。

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
| `lisp/init-org.el` | Org 设置与知识库路径 (`tau-org-*`) |
| `lisp/tau-org.el` | 知识库命令，通过 `C-c n` 按键自动加载 |
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
6. **延迟加载**：Org、Dired、AUCTeX、Eglot、知识库命令都在首次使用时加载；
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

Org、package.el、Vertico、Corfu、Dired、tree-sitter 都不在启动时加载；剩余耗时
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

### 知识库命令（`C-c n`）

| 按键 | 命令 |
| --- | --- |
| `C-c n n` | 新建笔记（带 Org ID） |
| `C-c n f` | 打开知识库中的 Org 文件 |
| `C-c n j` | 跳转到节点 |
| `C-c n i` | 插入节点的 ID 链接 |
| `C-c n b` | 当前节点的反向链接 |
| `C-c n s` | ripgrep 全文搜索（`C-u` 为字面搜索） |
| `C-c n R` | 重建 Org ID 数据库 |
| `C-c n I` | 为当前标题创建 ID（仅 Org 中） |

`M-x tau-org-initialize-directories` 创建知识库目录结构。外部依赖：`rg`（必需）、
`fd`（可选，缺失时用 Lisp 遍历目录）、`dvisvgm`（可选，SVG 公式预览）。

## 相对旧配置的行为变化

- 修复：Emacs 31.1 下旧配置会在启动时无限递归（`load-path-filter-cache-directory-files`
  调用未预加载的 `regexp-opt`，自动加载又触发过滤函数），现在先加载 `regexp-opt`。
- Corfu 自动补全改为 0.1 秒延迟、2 个字符触发（原为 0 秒、1 个字符），减少每次按键的开销。
- tree-sitter 语法库改用 Emacs 31 自带的固定版本配方（仍走 gh-proxy 镜像），
  不再跟踪各仓库的最新提交；缺少语法库时询问是否安装，拒绝或失败时退回传统模式。
- Evil 使用内置的 `undo-redo`，`C-r` 可以重做。
- `*scratch*` 使用 `fundamental-mode`；需要求值时用 `M-x lisp-interaction-mode`。
- 不再手动开启 `xterm-mouse-mode`（Emacs 31 在兼容终端中默认开启）。
- 新增：which-key、recentf、saveplace、auto-revert、so-long（均延迟启用），
  中文标点/假名/注音字体与 emoji 字体，Dired 显示可读文件大小并目录优先（Linux），
  Eglot 默认关闭事件日志并在最后一个缓冲区关闭时停止服务器。
- rainbow-delimiters 的颜色改用 `face-spec-set` 设置，不再写入 `custom.el`；
  `custom.el` 中过期的 `package-selected-packages` 与重复的 face 设置已删除。
