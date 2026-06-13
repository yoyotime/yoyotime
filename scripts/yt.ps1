# Yoyotime 项目管理工具
# 使用方法：
#   .\yt.ps1 setup     - 初始化环境
#   .\yt.ps1 status    - 查看项目状态
#   .\yt.ps1 commit "msg"  - 提交改动
#   .\yt.ps1 push      - 推送到 main
#   .\yt.ps1 release v0.2.0  - 发布新版本
#   .\yt.ps1 logs      - 查看最近 CI 日志
#   .\yt.ps1 fix       - 修复常见问题
#   .\yt.ps1 menu      - 交互菜单

param(
    [Parameter(Position=0)]
    [string]$Command = 'menu',

    [Parameter(Position=1)]
    [string]$Arg1 = '',

    [Parameter(Position=2)]
    [string]$Arg2 = ''
)

# 颜色
$Colors = @{
    Red     = 'Red'
    Green   = 'Green'
    Yellow  = 'Yellow'
    Cyan    = 'Cyan'
    Gray    = 'DarkGray'
    Magenta = 'Magenta'
}

# 输出辅助
function Print($text, $color = '') {
    if ($color -ne '') {
        Write-Host $text -ForegroundColor $color
    } else {
        Write-Host $text
    }
}

function Print-Success($text) { Print "[OK] $text" $Colors.Green }
function Print-Warn($text)    { Print "[!] $text" $Colors.Yellow }
function Print-Err($text)     { Print "[X] $text" $Colors.Red }
function Print-Info($text)    { Print "[i] $text" $Colors.Cyan }

function Print-Line() { Print ('-' * 60) $Colors.Gray }

# 工具：执行 git 命令
function Exec-Git($args) {
    $git = Get-Command git -ErrorAction SilentlyContinue
    if (-not $git) {
        Print-Err 'Git 未安装或不在 PATH'
        return $false
    }
    try {
        & git $args 2>&1 | Out-String | Write-Host
        return $true
    } catch {
        Print-Err "git $args 失败: $_"
        return $false
    }
}

# 工具：检测 PowerShell 版本
function Get-PSVersion() {
    return $PSVersionTable.PSVersion.Major
}

# 工具：检查网络
function Test-Network() {
    try {
        $null = Invoke-WebRequest -Uri 'https://github.com' -UseBasicParsing -TimeoutSec 5
        return $true
    } catch {
        return $false
    }
}

# 命令：setup
function Cmd-Setup() {
    Print-Info '开始设置 Yoyotime 项目'
    Print-Line

    # 检查 Git
    $git = Get-Command git -ErrorAction SilentlyContinue
    if ($git) {
        $v = git --version
        Print-Success "Git: $v"
    } else {
        Print-Err 'Git 未安装。请运行: winget install Git.Git'
        return
    }

    # 检查网络
    if (Test-Network) {
        Print-Success '网络连通'
    } else {
        Print-Warn '无法访问 GitHub，请检查网络'
        return
    }

    # 下载 gradle-wrapper.jar
    $jar = 'android\gradle\wrapper\gradle-wrapper.jar'
    if (Test-Path $jar) {
        Print-Success "gradle-wrapper.jar 已存在"
    } else {
        Print-Info '下载 gradle-wrapper.jar...'
        $url = 'https://github.com/gradle/gradle/raw/v8.2.1/gradle/wrapper/gradle-wrapper.jar'
        try {
            Invoke-WebRequest -Uri $url -OutFile $jar -UseBasicParsing
            Print-Success 'gradle-wrapper.jar 下载成功'
        } catch {
            Print-Err "下载失败: $_"
        }
    }

    # 检查 git 仓库状态
    if (Test-Path '.git') {
        Print-Success 'Git 仓库已初始化'
        $status = git status --short
        if ($status) {
            Print-Warn '有未提交的改动'
        } else {
            Print-Success '无未提交改动'
        }
    } else {
        Print-Warn '未初始化 git 仓库。运行: yt.ps1 init'
    }

    Print-Line
    Print-Success '设置完成'
    Print ''
    Print '常用命令：' $Colors.Cyan
    Print '  yt.ps1 status              - 查看状态' $Colors.Gray
    Print '  yt.ps1 commit "msg"        - 提交改动' $Colors.Gray
    Print '  yt.ps1 push                - 推送 main' $Colors.Gray
    Print '  yt.ps1 release v0.2.0      - 发版' $Colors.Gray
}

# 命令：init
function Cmd-Init() {
    if (Test-Path '.git') {
        Print-Warn '已经是 git 仓库'
        return
    }
    Print-Info '初始化 git 仓库...'
    git init | Out-Null
    git config user.name 'yoyotime' 2>$null
    git config user.email 'dev@yoyotime.app' 2>$null
    Print-Success '完成'
}

# 命令：status
function Cmd-Status() {
    Print-Info '项目状态'
    Print-Line

    Print '当前分支:' $Colors.Cyan
    git branch --show-current
    Print ''

    Print '未提交改动:' $Colors.Cyan
    $changes = git status --short
    if ($changes) {
        $changes | ForEach-Object { Print "  $_" $Colors.Yellow }
    } else {
        Print '  (无)' $Colors.Gray
    }
    Print ''

    Print '最近 5 次提交:' $Colors.Cyan
    git log --oneline -5
    Print ''

    Print '远程仓库:' $Colors.Cyan
    git remote -v
    Print-Line
}

# 命令：commit
function Cmd-Commit($msg) {
    if ([string]::IsNullOrWhiteSpace($msg)) {
        $msg = Read-Host '请输入提交信息'
    }
    if ([string]::IsNullOrWhiteSpace($msg)) {
        Print-Err '提交信息不能为空'
        return
    }
    Print-Info '添加所有改动...'
    git add .
    Print-Info "提交: $msg"
    git commit -m $msg
    if ($LASTEXITCODE -eq 0) {
        Print-Success '提交成功'
    } else {
        Print-Err '提交失败'
    }
}

# 命令：push
function Cmd-Push() {
    $branch = git branch --show-current
    Print-Info "推送到 origin/$branch"
    git push origin $branch
    if ($LASTEXITCODE -eq 0) {
        Print-Success '推送成功'
    } else {
        Print-Err '推送失败'
    }
}

# 命令：release
function Cmd-Release($version) {
    if ([string]::IsNullOrWhiteSpace($version)) {
        $version = Read-Host '请输入版本号 (例如 v0.2.0)'
    }
    if (-not $version.StartsWith('v')) {
        $version = 'v' + $version
    }
    Print-Info "创建 tag: $version"
    git tag $version
    if ($LASTEXITCODE -ne 0) {
        Print-Err 'tag 创建失败（可能已存在）'
        return
    }
    Print-Info "推送 tag: $version"
    git push origin $version
    if ($LASTEXITCODE -eq 0) {
        Print-Success "发布 $version 成功，CI 会自动构建"
    } else {
        Print-Err 'tag 推送失败'
    }
}

# 命令：sync - 一键 commit + push
function Cmd-Sync() {
    $changes = git status --short
    if (-not $changes) {
        Print-Info '无改动可提交'
        return
    }
    Cmd-Commit ''
    if ($LASTEXITCODE -eq 0) {
        Cmd-Push
    }
}

# 命令：fix - 尝试修复常见问题
function Cmd-Fix() {
    Print-Info '尝试修复常见问题...'
    Print-Line

    # 1. 清理可能的卡住进程
    Print-Info '1. 清理卡住的 git 进程'
    Get-Process -Name 'git*' -ErrorAction SilentlyContinue | ForEach-Object {
        try {
            Stop-Process -Id $_.Id -Force -ErrorAction Stop
            Print "  已结束: $($_.ProcessName) PID=$($_.Id)" $Colors.Gray
        } catch {}
    }

    # 2. 清理可能卡住的 winget
    Get-Process -Name 'winget*' -ErrorAction SilentlyContinue | ForEach-Object {
        try {
            Stop-Process -Id $_.Id -Force -ErrorAction Stop
            Print "  已结束: $($_.ProcessName) PID=$($_.Id)" $Colors.Gray
        } catch {}
    }

    # 3. 清理 PowerShell 缓存
    Print-Info '2. 清理 PowerShell 模块缓存'
    $cache = "$env:LOCALAPPDATA\Microsoft\Windows\PowerShell\CommandAnalysis"
    if (Test-Path $cache) {
        Remove-Item $cache\* -Force -Recurse -ErrorAction SilentlyContinue
        Print '  已清理' $Colors.Gray
    }

    # 4. 检查并修复 PATH
    Print-Info '3. 检查 PATH'
    $gitPath = 'C:\Program Files\Git\bin'
    if (Test-Path $gitPath) {
        $currentPath = [Environment]::GetEnvironmentVariable('Path', 'User')
        if ($currentPath -notlike "*$gitPath*") {
            Print-Warn "Git 不在 PATH，临时添加"
            $env:Path = $env:Path + ';' + $gitPath
        }
        Print-Success "Git 路径存在: $gitPath"
    } else {
        Print-Warn "Git 未找到: $gitPath"
    }

    Print-Line
    Print-Success '修复完成。如果仍然有问题，请重启电脑'
}

# 命令：menu
function Cmd-Menu() {
    while ($true) {
        Clear-Host
        Print '========================================' $Colors.Cyan
        Print '   Yoyotime 项目管理工具' $Colors.Cyan
        Print '========================================' $Colors.Cyan
        Print ''
        Print '  1. setup     - 初始化环境（下载 gradle-wrapper）' $Colors.White
        Print '  2. status    - 查看项目状态' $Colors.White
        Print '  3. commit    - 提交改动（需输入信息）' $Colors.White
        Print '  4. push      - 推送到 main' $Colors.White
        Print '  5. sync      - 一键 commit + push' $Colors.White
        Print '  6. release   - 创建并推送 tag（自动触发发版）' $Colors.White
        Print '  7. fix       - 修复卡住的 shell 或 git' $Colors.White
        Print '  8. download  - 下载 gradle-wrapper.jar' $Colors.White
        Print '  9. shell     - 测试 shell 是否正常' $Colors.White
        Print '  0. 退出' $Colors.Gray
        Print ''
        $choice = Read-Host '请选择 (0-9)'

        switch ($choice) {
            '1' { Cmd-Setup; Wait-Key }
            '2' { Cmd-Status; Wait-Key }
            '3' { Cmd-Commit ''; Wait-Key }
            '4' { Cmd-Push; Wait-Key }
            '5' { Cmd-Sync; Wait-Key }
            '6' { Cmd-Release ''; Wait-Key }
            '7' { Cmd-Fix; Wait-Key }
            '8' {
                $jar = 'android\gradle\wrapper\gradle-wrapper.jar'
                if (Test-Path $jar) { Print-Success '已存在' } else {
                    Print-Info '下载中...'
                    Invoke-WebRequest -Uri 'https://github.com/gradle/gradle/raw/v8.2.1/gradle/wrapper/gradle-wrapper.jar' -OutFile $jar -UseBasicParsing
                    Print-Success '完成'
                }
                Wait-Key
            }
            '9' {
                Print-Info '测试 shell...'
                try {
                    $test = 'hello'
                    Print-Success "Shell 正常: $test"
                } catch {
                    Print-Err "Shell 异常: $_"
                }
                Wait-Key
            }
            '0' { return }
            default { Print-Warn '无效选择'; Start-Sleep -Seconds 1 }
        }
    }
}

# 路由
function Wait-Key() {
    Print ''
    Print '按任意键继续...' $Colors.Gray
    $null = $Host.UI.RawUI.ReadKey('NoEcho,IncludeKeyDown')
}

# 主入口
switch ($Command) {
    'setup'    { Cmd-Setup }
    'init'     { Cmd-Init }
    'status'   { Cmd-Status }
    'commit'   { Cmd-Commit $Arg1 }
    'push'     { Cmd-Push }
    'sync'     { Cmd-Sync }
    'release'  { Cmd-Release $Arg1 }
    'fix'      { Cmd-Fix }
    'menu'     { Cmd-Menu }
    'help'     {
        Print 'Yoyotime 工具使用帮助' $Colors.Cyan
        Print-Line
        Print '  yt.ps1 setup     - 初始化项目环境'
        Print '  yt.ps1 init      - 初始化 git 仓库'
        Print '  yt.ps1 status    - 查看状态'
        Print '  yt.ps1 commit "msg"  - 提交改动'
        Print '  yt.ps1 push      - 推送 main'
        Print '  yt.ps1 sync      - 一键 commit + push'
        Print '  yt.ps1 release v0.2.0  - 发版（创建并推送 tag）'
        Print '  yt.ps1 fix       - 修复常见问题'
        Print '  yt.ps1 menu      - 交互菜单'
        Print '  yt.ps1 help      - 帮助'
    }
    default {
        Print-Err "未知命令: $Command"
        Print '运行 yt.ps1 help 查看可用命令' $Colors.Yellow
    }
}
