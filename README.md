# emacs.d

面向 **Emacs 31.1** 的个人配置，使用 `use-package` 管理：

- Emacs 原生按键与内置 repeat、delete-selection。
- Vertico + Orderless + Consult：minibuffer 补全、搜索和代码补全。
- Org + CDLaTeX + AUCTeX：笔记、任务和数学输入。
- 上游 [liberime](https://github.com/emacs-rime/liberime) +
  [Rimel](https://github.com/emacs-rime/rimel)：中文输入。

## 安装与迁移

```sh
git clone https://github.com/Tao-Boy/emacs.d.git ~/.config/emacs
emacs
```

缺少的包通过 USTC ELPA 镜像安装。`tau-elpa-mirror` 控制软件源，
`tau-github-mirror` 控制 tree-sitter 下载镜像。

**从旧配置迁移时，先卸载通过 `:vc` 安装的 `Tao-Boy/rimel`，再重启 Emacs。**
两种实现的包名都是 `rimel`，`:ensure t` 不会替换已经安装的同名包。
在 `M-x list-packages` 中删除旧包，或执行 `M-x package-delete RET rimel RET`；
然后执行 `M-x package-quickstart-refresh` 并重启，新配置会安装 MELPA 的上游 Rimel。
原有 `rime/` 目录继续使用，词库和方案不删除。

Tempel、AAS 和 org-ratex 已从配置中移除，本地 `site-lisp/org-ratex.el` 也已删除。
Evil、evil-collection 和 ECA 也已从配置中移除，更新后重启 Emacs 即使用原生按键。
已安装的这些包可以在 `M-x list-packages` 中手动卸载；
卸载后执行 `M-x package-quickstart-refresh`。其他配置仍使用的包应保留。

## 按键

使用 Emacs 原生编辑按键，无需切换编辑状态。
首次按键前启用内置 `repeat-mode` 和 `delete-selection-mode`，
支持重复窗口等命令，以及输入时替换选区。
minibuffer 中 `C-n` / `C-p` 选候选，`RET` 确认，`M-RET` 提交原样输入。

| 按键 | 用途 |
| --- | --- |
| `C-f` / `C-b` / `C-n` / `C-p` | 前进 / 后退 / 下一行 / 上一行 |
| `C-a` / `C-e` / `M-f` / `M-b` | 行首 / 行尾 / 向前或向后移动一个词 |
| `C-SPC` / `C-w` / `M-w` / `C-y` | 设置标记 / 剪切选区 / 复制选区 / 粘贴 |
| `C-/` / `C-M-_` | 撤销 / 重做 |
| `C-g` | 取消当前命令 |
| `C-x 2` / `C-x 3` / `C-x o` / `C-x 0` | 上下分屏 / 左右分屏 / 切换窗口 / 关闭窗口 |
| `M-o` / `C-x k` / `C-x C-b` | 切换窗口 / 关闭缓冲区 / ibuffer |
| `C-c f f` / `C-c f r` / `C-c f R` | 打开 / 最近文件 / 重命名当前文件 |
| `C-c t l` / `C-c t w` / `C-c t t` | 行号 / 软换行 / 截断长行 |
| `C-c t s` / `C-c t f` | whitespace / 全屏 |
| `C-x b` / `C-x C-r` / `M-y` | Consult 缓冲区 / 最近文件 / kill ring |
| `M-g g` / `M-g l` / `C-c s` | 跳转行号 / 当前缓冲区搜索 / ripgrep |
| `C-c d` | 复制当前行或选区（`duplicate-dwim`） |

已删除原先自定义的行首跳转、整行剪切复制、移动行、分屏、路径复制、sudo 编辑等函数。
`C-a`、`C-w`、`M-w`、`C-g` 等直接使用内置命令，Org 保留主模式行为。
`C-c t e`、`C-c e`、`C-c f y` 和 `C-c f s` 不再绑定。

代码中 `TAB` 先缩进，再通过 `consult-completion-in-region` 在 Vertico 中选择补全。
Org 和 CDLaTeX 有自己的 `TAB` 行为。没有自动内联补全建议。

## Org 与数学输入

`C-c c` 打开 capture（`i` 收集、`t` 任务、`n` 笔记），`C-c a` 打开 agenda，
`C-c l` 存储链接。默认笔记目录为 `~/org/`，agenda 只扫描 `inbox.org` 和 `tasks.org`。
笔记使用标准 file/id 链接；旧 Denote 链接需要改为标准链接。
Org 不在打开文件时自动生成公式预览。

Org、LaTeX/AUCTeX 缓冲区自动启用 CDLaTeX。
原有关键词尽量保留，**关键词后现在按 `TAB` 展开**：

| 输入 | 结果 |
| --- | --- |
| `mk TAB` / `dm TAB` | `\(...\)` / `\[...\]` |
| `ff TAB` / `sq TAB` | 分式 / 平方根 |
| `sr TAB` / `cb TAB` | 平方 / 立方 |
| `sum TAB` / `prod TAB` / `int TAB` / `lim TAB` | 求和 / 连乘 / 积分 / 极限 |
| `jk TAB` / `kj TAB` | 下标 / 上标 |
| `lr( TAB`、`lr[ TAB`、`lr{ TAB`、`lr\| TAB` | 成对的 `\left...\right` |
| `xx TAB`、`inn TAB`、`nin TAB`、`AA TAB`、`EE TAB` | 乘号、属于、不属于、全称、存在 |
| `oo TAB`、`pd TAB`、`nbl TAB` | 无穷、偏导、梯度 |
| `sin TAB`、`cos TAB`、`tan TAB`、`log TAB`、`ln TAB`、`exp TAB` | 数学函数 |

除了 `mk`、`dm`，这些关键词只在数学环境中展开。
Org 中 `TAB` 由内置 `org-try-cdlatex-tab` 协调，标题仍可折叠；
在正文行中途插入 `mk`、`dm` 时，用 **`C-c TAB`** 直接调用 CDLaTeX。

希腊字母继续用 `;` 前缀：`;a` → `\alpha`、`;t` → `\theta`、`;u` → `\tau` 等，
大写字母键保留原有映射。变体使用 CDLaTeX 的第二层：`;;e` → `\varepsilon`、
`;;f` → `\varphi`，替代原来的 `:e`、`:f`。
符号使用 `;<` / `;>` / `;!` / `;~` / `;+` / `;-` / `;.`
输入 `\leq` / `\geq` / `\neq` / `\approx` / `\pm` / `\mp` / `\cdot`；
原来 `<=`、`>=`、`!=` 等不再自动展开。

`TAB` 跳到下一个可输入位置。CDLaTeX 不提供 Tempel 的反向字段跳转，
`S-TAB` 保留主模式行为；向前或向后移动可用 `C-f` / `C-b`。
启用 CDLaTeX 的缓冲区中，`;` 是数学前缀，输入字面分号用 `C-q ;`。
数学判断使用 Org、CDLaTeX 和 AUCTeX 自带逻辑。

## 中文输入

使用 MELPA 的上游 liberime 与 Rimel。Emacs 需要动态模块支持，系统需要 librime、
Rime 方案数据；自动编译 liberime 时还需要 C 编译器和 `make`。
Debian/Ubuntu 可安装 `build-essential librime-dev rime-data-luna-pinyin`。
也可以按 [liberime 文档](https://github.com/emacs-rime/liberime) 设置预编译的 `liberime-module-file`。

`C-\` 切换输入法，`C-c r s` 选择方案，`C-c r d` 部署。
候选显示在回显区；用户数据在配置目录下的 `rime/`。
在代码、英文字母之后、大写字母、
Org 源码块和数学环境中，使用 Rimel 内置断言自动输入英文。
旧实现的 `C-c r a`、`C-c r f` 没有上游对应命令，已移除。

## 文件结构

`init.el` 按顺序加载 `lisp/init-*.el`，包分别放在对应功能模块；
`early-init.el` 保留启动优化，`custom.el` 最后加载。
保留现有 tree-sitter、Eglot、字体、GC 和会话记录设置。
删除了自定义包安装快速路径，使用标准 `use-package :ensure`。

验证使用 Emacs 31.1：启动与原生按键、Org/AUCTeX 的 CDLaTeX 输入、
Consult、上游 liberime 原生模块与 Rimel 中文输入。
