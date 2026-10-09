# 重构验证记录

验证日期：2026-10-09。原始提交：`eb430ae657bfb18012771e91d3899494e77f3036`。

## 环境与结果

在同一 Debian 13 容器、同一 GNU Emacs 31.1 终端构建、相同已安装依赖下完成对照。构建具有 Tree-sitter、TLS 和 SQLite 支持；该环境没有启用 native Lisp compilation。Emacs 与依赖由环境预先提供，验证没有更新依赖或访问包源。

- 原配置的 7 项工作流检查：7/7 通过。
- 重构后的 13 项检查：源码和字节编译配置均 13/13 通过，0 失败。
- 没有第三方包的离线初始状态：12 项通过，1 项片段展开检查因缺少 AAS/Tempel 跳过，0 失败。
- 原有的 7 项工作流检查（仅更新模块名称和补全初始化入口）：7/7 通过。
- 配置字节编译：有依赖和无依赖均通过，配置自身的警告作为错误处理。
- 实际控制终端：Evil 首个命令前已生效；首个 `completing-read` 使用 Vertico；`M-x` 补全和执行成功。
- Git diff 空白检查、Lisp 括号检查和 Python 编译检查通过。

检查覆盖：启动不联网及加载边界、初始化错误后的 GC 恢复、离线包缓存生成、Evil 和主题、首次补全、Dired、编程 hook、中文笔记与 UUID、ripgrep ID 索引及纯 Emacs 文件遍历、Org capture/agenda、目录初始化不覆盖现有文件、AAS/Tempel 展开、AUCTeX 编辑、搜索参数引用、以 `--` 开头的查询、backlink 大小写精确匹配和旧状态文件的保留迁移。

GitHub Actions 定义了离线初始状态、严格字节编译和编译后的检查；这里列出的结果来自本地执行，远端 CI 状态应以 PR 上的运行结果为准。

## 启动基准

每组 9 次独立 Emacs 进程，报告中位数。基准在开始测量前为新旧配置都加载 `regexp-opt`，以兼容原配置在 Emacs 31 中的 load-path filter；原配置所需的第三方包已全部安装。测量从读取 `early-init.el` 开始，包括 `init.el`、`after-init-hook` 和 `emacs-startup-hook`，随后分别测量补全启用、首个 Org buffer、首个编程 buffer。

| 配置 | 初始化 ms | 启动新增库数 | 补全启用 ms | 首个 Org buffer ms | 首个编程 buffer ms |
| --- | ---: | ---: | ---: | ---: | ---: |
| 原配置（源码，无 quickstart） | 346.2 | 165 | 0.0 | 78.8 | 12.0 |
| 重构（源码，无 quickstart） | 236.1 | 88 | 25.3 | 147.6 | 10.4 |
| 重构（源码，有 quickstart） | 259.0 | 78 | 28.9 | 149.1 | 10.6 |
| 重构（配置 .elc，有 quickstart） | 336.2 | 78 | 36.6 | 216.9 | 16.4 |

后几组顺序测量出现明显的云端负载波动，因此另做交错对照：运行 9 对新旧配置，每对交换先后顺序，两者使用同一环境和依赖，结果如下。前面的顺序测量原始样本仍保留，避免仅展示最快的一组。

| 配置 | 初始化 ms | 启动新增库数 | 补全启用 ms | 首个 Org buffer ms | 首个编程 buffer ms |
| --- | ---: | ---: | ---: | ---: | ---: |
| 交错对照：原配置 | 393.7 | 165 | 0.0 | 84.2 | 13.5 |
| 交错对照：重构（.elc + quickstart） | 269.8 | 78 | 30.7 | 157.7 | 10.4 |

交错对照中，初始化中位数约 394 → 270 ms；逐对改善百分比的中位数为 32.0%。启动新增库数由 165 减至 78。顺序测量中源码路径也约快 32%。配置本身字节编译的额外收益没有稳定显现：立即加载的第三方库仍占较多时间，云端机器负载会影响样本，因此没有声称编译一定继续提速。

延迟加载也有成本：交错对照中，第一次启用补全约 31 ms，第一次进入 Org 约 158 ms，之后相关库已加载。原配置在初始化时就加载 Org，因此其首个 Org buffer 耗时更短。该取舍优先改善没有立即进入 Org 的启动路径；直接打开 Org 文件时仍须支付必要的 Org 加载成本。

这不是磁盘冷启动测试，不包含 Emacs C 初始化、GUI 绘制、GUI 字体查找或用户自己的 `local.el`。每次是新的 Emacs 进程，但操作系统文件缓存保留。不能据此保证其他机器上的绝对启动时间或“全场景最快”。原始样本见 [benchmark-results.json](benchmark-results.json)。

## 依赖与验证范围

本次完整依赖检查使用：Evil 1.14.2、Vertico 2.1、Orderless 1.4、Marginalia 2.0、Corfu 2.1、AAS 1.2、Tempel 1.12、AUCTeX 13.2、Doom Themes 2.3.0、Rainbow Delimiters 2.1.5（间接依赖 Compat 30.1.0.0、goto-chg 1.7.5）。这些是测试环境的版本记录，配置不会自动安装或升级到这些版本，也没有引入新的锁文件/包管理器。

已安装的旧版第三方库在 Emacs 31 上会报告过时宏、缺少 lexical-binding 等警告。这些警告来自依赖源码；没有通过全局关闭警告隐藏它们。

最低运行版本设为 Emacs 29.1；本次完整依赖验证实际使用 Emacs 31.1。Emacs 29 的检查由仓库 CI 在 Ubuntu 24.04 的系统 Emacs 上执行，需查看远端结果。

未验证 GUI 字体/缩放渲染、daemon 图形客户端 frame、外部 TeX 编译与 LaTeX 预览、实际语言 grammar 的下载编译、远端 TRAMP 连接或 native compilation。对应代码保留内置行为和可用性检查，相关环境仍需实际验证。

## 复现

```sh
TAU_PACKAGE_DIR=/path/to/elpa emacs -Q --batch -l scripts/check.el
TAU_PACKAGE_DIR=/path/to/elpa emacs -Q --batch -l scripts/compile.el
TAU_PACKAGE_DIR=/path/to/elpa emacs -Q --batch -l scripts/check.el
TAU_PACKAGE_DIR=/path/to/elpa python3 scripts/benchmark.py --runs 9
TAU_PACKAGE_DIR=/path/to/elpa python3 scripts/benchmark.py --runs 9 --compare /path/to/reference
```

包缓存由 `M-x tau-packages-refresh` 离线重建。测量无缓存路径时，先移走 `var/package-quickstart.el` 与 `.elc`；测量源码路径时移走配置 `.elc`。删除的都是可再生文件，不要删除个人配置或知识库。基准不会初始化或扫描真实知识库；状态文件按正常配置规则写入配置目录。
