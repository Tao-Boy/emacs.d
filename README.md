# Tau 的 Emacs 配置

Emacs 29.1+，使用内置 `package.el` 和显式模块。保留 Evil、Vertico / Orderless / Marginalia、Corfu、Org 数学片段、原生 Org 知识库及 Doom Tokyo Night 主题。

日常启动只使用本地文件。联网安装、包缓存刷新和字节编译都是明确的维护操作。缺少第三方包时仍可启动，补全、主题和 LaTeX 使用内置功能。

## 安装与升级

将仓库放在 Emacs 的配置目录（例如 `~/.emacs.d/`），或者用 Emacs 29+ 的 `--init-directory /path/to/emacs.d` 启动。不要覆盖已有配置；先备份并选择自己的安装位置。

1. 按需把 `local.example.el` 复制为 `local.el`，设置字体、主题、Org 根目录、模块和包源。
2. 启动 Emacs，运行 `M-x tau-packages-install` 安装缺失的声明依赖。这一步会联网；默认沿用原配置的 USTC ELPA 镜像，可以在 `local.el` 改用上游包源。
3. 重启 Emacs。首次使用 Org 时，如果还没有知识库，运行 `M-x tau-org-initialize-directories`。它不会覆盖已有笔记。
4. 可选：执行 `emacs -Q --batch -l scripts/compile.el`，将配置编译为 `.elc`。

从旧结构升级前，保留你当前的 `custom.el` 副本。它现在属于个人配置，Git 不再跟踪它；更新到删除该文件的提交时，Git 可能移除旧的已跟踪副本。升级后可恢复该文件，配置仍会读取原来的 `custom.el`。不要把旧的 `package-selected-packages` 当作依赖清单；声明依赖现在由 `tau-packages` 管理。

包版本不会在启动时自动更新。需要升级时使用 Emacs 的包菜单；升级或手动修改 `elpa/` 后运行 `M-x tau-packages-refresh` 并重启。包缓存不属于源码，迁移机器或切换 Emacs 版本后也应重建。现有包可继续使用，不需要为重构重新安装。

## 目录与职责

```text
early-init.el              有界启动 GC、首次 frame 参数、关闭自动包激活
init.el                    路径 → core → local.el → 包激活 → 模块 → Custom
lisp/
  tau-core.el              公共选项、编辑默认值、状态路径
  tau-packages.el          依赖清单、包激活、显式安装/缓存命令
  modules/
    init-editor.el         编程 buffer 的行号、括号与配对
    init-completion.el     首次命令启用 minibuffer 补全；Corfu 按 buffer 启用
    init-dired.el          首次打开 Dired 后配置
    init-treesitter.el     仅为已安装且可用的 grammar 注册 remap
    init-latex.el          首次打开 .tex/.ltx 后加载 AUCTeX
    init-org.el            仅注册 Org 入口、autoload 和快捷键
    init-snippet.el        Org 数学片段，按 Org buffer 加载 AAS/Tempel
    init-evil.el           立即启用 Evil，保证首个按键的语义
    init-ui.el             立即加载主题；GUI/daemon 新 frame 字体设置
  org/
    tau-org-settings.el    Org 外观、数学显示、capture、agenda、ID 策略
    tau-org-notes.el       文件发现、笔记创建、目录初始化与节点身份
    tau-org-search.el      按需索引、节点跳转、ID 链接、backlink 和搜索
local.example.el           加载模块前的个人配置示例
custom.example.el          Customize 文件示例
scripts/                   离线检查、编译和性能测量
tests/                     加载边界与真实编辑流程的回归检查
var/                       忽略的运行状态和包 autoload 缓存
elpa/                      忽略的安装包，沿用 package.el 默认位置
```

`local.el`、`custom.el`、`var/`、安装包和编译产物不提交到 Git。默认把补全历史、Org ID 数据和 Org 持久缓存放进 `var/`；外部启动文件已设置的 Org 状态路径会保留。

旧的 `history` 和 `.org-id-locations` 在首次使用对应功能时复制到新状态目录，保留旧文件并且不覆盖已有的新文件。如果知识库文件移动过或 ID 缓存已经失效，运行 `M-x tau-org-refresh-id-db` 重建。

## 启动与维护规则

- `early-init.el` 不联网、不安装包，不移除文件名处理器，也不改写 Lisp 加载后缀。TRAMP 和压缩 Lisp 在启动期间仍可使用。
- 只激活一次安装包。已有 `package-quickstart` 缓存时直接读取；没有缓存时走本地 autoload 激活路径。启动不会生成缓存或扫描知识库。
- Evil 和主题立即生效；其余较重的功能按实际入口加载。minibuffer 补全在首个交互命令或公共读取入口启用，因此第一次 `M-x` 就能使用 Vertico。
- 使用 `require`、`with-eval-after-load`、明确的 hook/autoload，不建立额外的包管理框架或定时批量加载队列。
- 保留 Emacs 的包签名校验策略。配置不关闭签名校验、TLS 校验或 native compilation。
- `.el` 新于 `.elc` 时使用源码，避免忘记重新编译后仍加载旧配置。编译产物可随时删除。

启用/删除模块，在 `local.el` 设置 `tau-modules`，然后重启。需要在加载前读取的选项（模块列表、Evil 选项、主题、字体或包路径）应放在 `local.el`。`custom.el` 最后读取，用于覆盖模块的普通设置；它不能撤销已发生的模块加载或重新应用已加载的主题。

添加功能时：

1. 在 `lisp/modules/` 添加有 `lexical-binding` 的 `init-*.el`，以同名 `provide` 结尾，并在 `tau-modules` 中显式注册。
2. 第三方依赖加入 `tau-packages`，安装与升级由维护命令执行。
3. 把 buffer 级功能放进 major-mode hook；命令用 autoload；已有库的键位/变量用 `with-eval-after-load`。只有首帧外观或首个按键所必需的功能才立即加载。
4. 保持功能模块单向依赖。Org 子模块的依赖是 `search → notes → settings`，公共选项依赖 `tau-core`。不要让公共层反向依赖功能模块。
5. 给延迟库的变量写 `defvar` 声明、函数写 `declare-function`，避免为了编译而在启动时加载它们。
6. 修改启动边界或核心工作流时运行下面的检查与基准。

## 常用快捷键

| 快捷键 | 功能 |
| --- | --- |
| `C-c l` | 保存 Org 链接 |
| `C-c c` | Capture（`i` 收件箱 / `t` 任务） |
| `C-c a` | Agenda，只读取 inbox 和 tasks |
| `C-c n n` / `f` / `j` | 新建笔记 / 查找文件 / 跳转 ID 节点 |
| `C-c n i` / `b` / `s` | 插入 ID 链接 / backlink / ripgrep 搜索 |
| `C-u C-c n s` | 按字面文本搜索 |
| `C-c n R` | 重建 Org ID 数据 |
| Org 中 `C-c n I` | 为当前标题创建 ID |

Org 数学片段保留原触发词，例如 `mk`、`dm`、`;a` 和 `ff`。搜索和 backlink 需要 `rg`；文件发现优先使用 `fd`/`fdfind`，也支持纯 Emacs 遍历。LaTeX 预览需要外部 TeX 与 `dvisvgm`，不会在启动时安装这些程序。Tree-sitter grammar 用 `M-x treesit-install-language-grammar` 显式安装，随后重启；没有 grammar 时不进行对应的模式 remap。

## 验证与测量

```sh
emacs -Q --batch -l scripts/check.el
emacs -Q --batch -l scripts/compile.el
emacs -Q --batch -l scripts/check.el
python3 scripts/benchmark.py --runs 9
```

使用非默认包目录可设置 `TAU_PACKAGE_DIR=/path/to/elpa`。检查和编译使用临时状态目录，不写入真实知识库；有特殊发行版包路径时，可以通过 `TAU_TEST_SETUP=/path/to/setup.el` 传入只设置路径的启动文件。新 checkout 没有第三方包时，片段展开检查会跳过，其余测试覆盖内置回退。GitHub Actions 检查这种离线初始状态与编译后的配置；完整第三方依赖环境须另外运行同一组检查。

基准每次启动一个新的 `-Q --batch` 进程，测量配置和初始化 hook，再分别测量补全启用、首个 Org buffer 和首个编程 buffer；输出中位数和每次启动样本。它不包含 Emacs C 初始化、GUI 绘制或磁盘冷缓存，不能直接解释为你的桌面启动时间。可用 `--compare /path/to/reference` 交错测量新旧配置、降低负载波动的影响；也可用 `TAU_BENCH_ROOT=/path/to/reference` 单独测量另一份配置。对照旧配置前应确保其依赖已安装，避免旧逻辑触发联网。

实测数据、验证范围和限制见 [docs/validation.md](docs/validation.md)。
