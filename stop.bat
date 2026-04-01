@echo off
chcp 65001 >nul
echo ========================================
echo   停止人力资源数据中心服务
echo ========================================
echo.

echo [步骤1] 停止后端服务...
taskkill /F /IM java.exe >nul 2>&1
if %errorlevel% equ 0 (
    echo [成功] 后端服务已停止
) else (
    echo [提示] 后端服务未运行
)
echo.

echo [步骤2] 停止前端服务...
taskkill /F /IM node.exe >nul 2>&1
if %errorlevel% equ 0 (
    echo [成功] 前端服务已停止
) else (
    echo [提示] 前端服务未运行
)
echo.

echo ========================================
echo   所有服务已停止
echo ========================================
pause
