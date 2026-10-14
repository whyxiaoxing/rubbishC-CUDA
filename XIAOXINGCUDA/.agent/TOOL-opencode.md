---
main:下面是内置的工具你可以搜索到
---

> **本机约定**：文件搜索、模糊匹配一律**直接调用 `rg`**（ripgrep 15.1.0，`features:+pcre2`，已在 PATH）。

## 工具清单

| 工具 | 用途 |
| --- | --- |
| `bash` | 在项目环境中执行 shell 命令 |
| `read` | 读取文件内容，支持指定行范围 |
| `edit` | 通过精确字符串替换修改现有文件 |
| `write` | 创建新文件或覆盖已有文件 |
| `apply_patch` | 应用补丁（diff / patch） |
| `grep` | 用正则搜索文件内容 |
| `glob` | 按模式匹配查找文件 |
| `lsp` | 与 LSP 服务器交互，获取定义、引用、悬停等代码智能（实验性） |
| `skill` | 加载技能（`SKILL.md`）并注入对话 |
| `todowrite` | 管理会话内的待办列表 |
| `webfetch` | 抓取网页内容 |
| `websearch` | 联网搜索信息 |
| `question` | 执行过程中向用户提问 |

## 本机 rg 约定

| OpenCode 工具 | 本机实现 |
| --- | --- |
| `grep` | `rg '<pattern>'` |
| `glob` | `rg --files -g '<pattern>'` |

> `rg` 默认遵循 `.gitignore`。需放行时在项目根目录建 `.ignore`：`!node_modules/`

**PowerShell 引号**：含 `?` `|` `{}` `(` `$` `\` 的模式必须用单引号。
