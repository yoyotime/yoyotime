@echo off
REM ============================================
REM   颅脑测试 - 纯检查（不需要 Flutter）
REM ============================================

setlocal enabledelayedexpansion

echo.
echo ========================================
echo   颅脑测试
echo ========================================
echo.

set PASS=0
set FAIL=0

REM --- 1. 关键文件检查 ---
echo [1/5] 检查关键文件
set MISSING=0
for %%f in (lib\main.dart lib\app.dart pubspec.yaml android\app\src\main\AndroidManifest.xml assets\config\sources.json assets\config\tone_rules.json) do (
    if not exist "%%f" (
        echo   MISSING: %%f
        set MISSING=1
    )
)
if %MISSING% equ 1 (
    echo   FAIL
    set /a FAIL+=1
) else (
    echo   PASS
    set /a PASS+=1
)

REM --- 2. AndroidManifest 检查 ---
echo [2/5] 检查 AndroidManifest
findstr /C:"usesCleartextTraffic" "android\app\src\main\AndroidManifest.xml" >nul 2>&1
if %ERRORLEVEL% neq 0 (
    echo   FAIL: 缺少 usesCleartextTraffic
    set /a FAIL+=1
) else (
    echo   PASS
    set /a PASS+=1
)

REM --- 3. pubspec.yaml 语法 ---
echo [3/5] 检查 pubspec.yaml
findstr /C:"sdk:" "pubspec.yaml" >nul 2>&1
if %ERRORLEVEL% neq 0 (
    echo   FAIL: pubspec.yaml 缺少 sdk 约束
    set /a FAIL+=1
) else (
    echo   PASS
    set /a PASS+=1
)

REM --- 4. 检查未提交的修改 ---
echo [4/5] 检查 git 状态
git status --porcelain | findstr /C:"dart" >nul 2>&1
if %ERRORLEVEL% equ 0 (
    echo   WARNING: 有未暂存的 .dart 文件
    git status --porcelain | findstr /C:"dart"
) else (
    echo   PASS
    set /a PASS+=1
)

REM --- 5. 检查是否有 print() 调试语句 ---
echo [5/5] 检查 print() 语句
findstr /S /N "print(" lib\*.dart 2>nul | findstr /V "// " | findstr /V "print(" >nul 2>&1
if %ERRORLEVEL% equ 0 (
    echo   WARNING: 发现 print() 语句
    findstr /S /N "print(" lib\*.dart 2>nul | findstr /V "// " | head -5
) else (
    echo   PASS
    set /a PASS+=1
)

echo.
echo ========================================
echo   结果: %PASS% 通过, %FAIL% 失败
echo ========================================

if %FAIL% gtr 0 (
    echo   请修复后再推送！
    exit /b 1
) else (
    echo   可以推送，CI 会做最终验证
    exit /b 0
)
