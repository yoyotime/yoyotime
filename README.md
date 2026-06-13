# 悠悠时光 Yoyotime

> 一款让你安静地了解世界的内容聚合 App

## 🎯 项目使命
愿普天之下皆为净土，没有战争，没有罪恶。

## 🛠️ 日常操作（推荐用 PowerShell 工具）

### 最简单：双击 `yt.bat` 进入菜单

或者在 PowerShell 中：

```powershell
cd E:\yoyotime
.\yt.ps1 menu            # 交互菜单
.\yt.ps1 status          # 查看状态
.\yt.ps1 commit "msg"    # 提交改动
.\yt.ps1 push            # 推送到 main
.\yt.ps1 sync            # 一键 commit + push
.\yt.ps1 release v0.2.0  # 发版（自动 CI 构建 APK）
.\yt.ps1 fix             # 修复卡住的 shell/git
```

### 批处理版本（PowerShell 卡死时用）

```cmd
yt.bat                   # 进入菜单
yt.bat status
yt.bat commit "msg"
yt.bat push
yt.bat release v0.2.0
yt.bat setup             # 下载 gradle-wrapper.jar
yt.bat fix               # 修复问题
```

## 📋 完整发布流程

1. **写代码**（任何编辑器）
2. **提交**：`yt.ps1 commit "feat: xxx"`
3. **推送**：`yt.ps1 push`（自动触发 CI）
4. **发版**：`yt.ps1 release v0.2.0`（CI 自动构建 + 创建 Release）
5. **下载 APK**：去 GitHub Actions 页面下载

## 🐛 遇到问题

### 第一次使用：解决 PowerShell 执行策略
如果遇到 "无法加载文件，因为在此系统上禁止运行脚本"：
```powershell
Set-ExecutionPolicy -Scope CurrentUser -ExecutionPolicy Bypass
```

### Shell 卡死
```powershell
.\yt.ps1 fix
```
或者直接重启 PowerShell。如果还不行，重启电脑。

**完全没响应时的硬重启方法：**
1. `Ctrl+Alt+Del` → 任务管理器
2. 找到 `powershell.exe` 进程 → 结束
3. 新开 PowerShell → `cd E:\yoyotime` → 继续工作

### 推送失败
1. 检查网络：`Test-NetConnection github.com -Port 443`
2. 检查 token 是否过期
3. 看 `git remote -v` 确认远程地址正确

### CI 失败
1. 打开 GitHub → Actions → 失败的运行
2. 看错误信息
3. 常见问题：gradle-wrapper.jar 缺失（运行 `yt.ps1 setup`）

## 📁 项目结构

```
yoyotime/
├── lib/                    # Flutter 客户端
├── backend/                # Python FastAPI 后端
├── docs/SPEC.md            # 完整产品规格
├── AGENTS.md               # 项目记忆
├── scripts/yt.ps1          # 主力工具
├── yt.bat                  # 批处理工具
├── .github/workflows/      # CI 配置
└── android/                # Android 工程
```

## 🔑 关键信息

- **仓库**：`github.com/yoyotime/yoyotime`
- **包名**：`com.yoyotime.app`
- **默认分支**：`main`
- **CI**：GitHub Actions（推 main 触发构建，推 `v*` tag 触发发版）
