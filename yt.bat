@echo off
rem =============================================
rem Yoyotime tool launcher (ASCII only)
rem Just calls PowerShell tool for all operations
rem =============================================

if "%1"=="" goto MENU
if /i "%1"=="ps" goto PS_MENU
if /i "%1"=="bash" goto GIT_BASH
if /i "%1"=="status" goto GIT_STATUS
if /i "%1"=="push" goto GIT_PUSH
if /i "%1"=="commit" goto GIT_COMMIT
if /i "%1"=="release" goto GIT_RELEASE
if /i "%1"=="setup" goto SETUP
if /i "%1"=="fix" goto FIX
if /i "%1"=="unlock" goto FIX
if /i "%1"=="help" goto HELP

echo [X] Unknown command: %1
echo     Run "yt.bat" for menu
goto END

:MENU
echo.
echo ==========================================
echo   Yoyotime Project Tool
echo ==========================================
echo.
echo   1. ps       - open PowerShell tool menu
echo   2. bash     - open Git Bash
echo   3. status   - git status
echo   4. commit   - commit (provide message after)
echo   5. push     - push to main (5 mirror retries)
echo   6. release  - create release tag (5 mirror retries)
echo   7. setup    - download gradle wrapper
echo   8. fix      - fix stuck processes
echo   9. help     - show help
echo   0. exit
echo.
echo Usage examples:
echo   yt.bat commit "feat: add homepage"
echo   yt.bat release v0.2.0
echo.
goto END

:PS_MENU
echo Starting PowerShell tool menu...
powershell -NoProfile -ExecutionPolicy Bypass -File "%~dp0scripts\yt.ps1" menu
goto END

:GIT_BASH
echo Opening Git Bash here...
"C:\Program Files\Git\bin\bash.exe" --cd="%cd%"
goto END

:GIT_STATUS
echo.
echo === Git Status ===
git branch --show-current
git status --short
echo.
echo === Last 5 commits ===
git --no-pager log --oneline -5
goto END

:GIT_COMMIT
if "%~2"=="" (
    set /p msg=Commit message:
) else (
    set msg=%~2
)
git add .
git commit -m "%msg%"
goto END

:GIT_PUSH
echo.
echo === Pushing to main (5 retry rounds via mirrors) ===
echo.

rem Extract repo path and auth from origin URL
rem Format: https://TOKEN@github.com/user/repo.git
set "REMOTE_URL="
for /f "tokens=*" %%U in ('git remote get-url origin 2^>nul') do set "REMOTE_URL=%%U"

if "%REMOTE_URL%"=="" (
    echo [X] No git remote configured
    goto END
)

rem Split on @ to get auth and path
for /f "tokens=1,2 delims=@" %%a in ("%REMOTE_URL%") do (
    set "AUTH=%%a"
    set "REPO_PATH=%%b"
)

setlocal enabledelayedexpansion

rem List of mirror hosts to try (Chinese domestic mirrors + fallback)
rem Note: ghproxy-style proxies are mainly for read (clone); push usually only works on direct or codeload
set "MIRRORS=gh-proxy.com ghfast.top mirror.ghproxy.com ghproxy.com github.akams.cn gh-proxy.ygxz.in codeload.github.com github.com"

set TRIES=0
set MAX_TRIES=8
set SUCCESS=0

for %%M in (%MIRRORS%) do (
    if !TRIES! lss !MAX_TRIES! (
        set /a TRIES+=1 >nul
        echo.
        echo [!TRIES!/!MAX_TRIES!] Trying mirror: %%M
        set "PUSH_URL=!AUTH!@%%M/!REPO_PATH!"
        git push "!PUSH_URL!" main 2>nul
        if !errorlevel! equ 0 (
            echo.
            echo [OK] Pushed successfully via %%M
            set SUCCESS=1
            goto :PUSH_DONE
        ) else (
            echo      Failed, trying next...
            ping -n 2 127.0.0.1 >nul 2>&1
        )
    )
)

:PUSH_DONE
endlocal & set "PUSH_SUCCESS=%SUCCESS%"

if "%PUSH_SUCCESS%"=="0" (
    echo.
    echo [X] All %MAX_TRIES% attempts failed.
    echo     Check network: Test-NetConnection github.com -Port 443
    echo     Or try SSH: yt.bat bash
)
goto END

:GIT_RELEASE
if "%~2"=="" (
    set /p ver=Version (e.g. v0.2.0):
) else (
    set ver=%~2
)
echo %ver% | findstr /b "v" >nul
if errorlevel 1 set ver=v%ver%
echo Creating tag %ver%...
git tag %ver%

rem Extract repo path and auth from origin URL
set "REMOTE_URL="
for /f "tokens=*" %%U in ('git remote get-url origin 2^>nul') do set "REMOTE_URL=%%U"
if "%REMOTE_URL%"=="" (
    echo [X] No git remote configured
    goto END
)
for /f "tokens=1,2 delims=@" %%a in ("%REMOTE_URL%") do (
    set "AUTH=%%a"
    set "REPO_PATH=%%b"
)

setlocal enabledelayedexpansion
set "MIRRORS=gh-proxy.com ghfast.top mirror.ghproxy.com ghproxy.com github.akams.cn gh-proxy.ygxz.in codeload.github.com github.com"
set TRIES=0
set MAX_TRIES=8
set SUCCESS=0

for %%M in (%MIRRORS%) do (
    if !TRIES! lss !MAX_TRIES! (
        set /a TRIES+=1 >nul
        echo [!TRIES!/!MAX_TRIES!] Pushing tag via %%M
        set "PUSH_URL=!AUTH!@%%M/!REPO_PATH!"
        git push "!PUSH_URL!" %ver% 2>nul
        if !errorlevel! equ 0 (
            echo [OK] Tag %ver% pushed via %%M
            set SUCCESS=1
            goto :RELEASE_DONE
        ) else (
            ping -n 2 127.0.0.1 >nul 2>&1
        )
    )
)
:RELEASE_DONE
endlocal & set "RELEASE_SUCCESS=%SUCCESS%"
if "%RELEASE_SUCCESS%"=="0" echo [X] All attempts failed
goto END

:SETUP
echo === Setup: download gradle wrapper ===
if exist "android\gradle\wrapper\gradle-wrapper.jar" (
    echo [OK] gradle-wrapper.jar exists
) else (
    echo [..] Downloading...
    powershell -NoProfile -Command "Invoke-WebRequest -Uri 'https://github.com/gradle/gradle/raw/v8.2.1/gradle/wrapper/gradle-wrapper.jar' -OutFile 'android\gradle\wrapper\gradle-wrapper.jar' -UseBasicParsing"
    if exist "android\gradle\wrapper\gradle-wrapper.jar" (
        echo [OK] Downloaded
    ) else (
        echo [X] Download failed
    )
)
goto END

:FIX
echo === Fix stuck processes ===
echo Killing stuck git processes...
taskkill /F /IM git.exe 2>nul
echo Killing stuck winget processes...
taskkill /F /IM winget.exe 2>nul
echo Adding Git to PATH...
set PATH=%PATH%;C:\Program Files\Git\bin
echo Removing stale git locks...
if exist ".git\index.lock" (
    del /F /Q ".git\index.lock"
    echo [OK] Removed .git\index.lock
)
if exist ".git\HEAD.lock" (
    del /F /Q ".git\HEAD.lock"
    echo [OK] Removed .git\HEAD.lock
)
if exist ".git\refs\heads\master.lock" (
    del /F /Q ".git\refs\heads\master.lock"
)
if exist ".git\refs\heads\main.lock" (
    del /F /Q ".git\refs\heads\main.lock"
)
echo Done. Try again or restart computer.
goto END

:HELP
echo.
echo Yoyotime Tool Help
echo.
echo Basic git operations (work without PowerShell):
echo   yt.bat status              - show git status
echo   yt.bat commit "msg"        - commit all changes
echo   yt.bat push                - push to main (5 mirror retries)
echo   yt.bat release v0.2.0      - create and push tag (5 mirror retries)
echo   yt.bat setup               - download gradle wrapper
echo   yt.bat fix                 - fix stuck processes
echo.
echo PowerShell tool (better UI):
echo   yt.bat ps                  - open PowerShell tool menu
echo.
echo Direct shell:
echo   yt.bat bash                - open Git Bash
echo.
goto END

:END
