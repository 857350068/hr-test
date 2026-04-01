@echo off
chcp 65001 >nul
echo ========================================
echo   人力资源数据中心 - 启动脚本
echo ========================================
echo.

echo [步骤1] 检查Java环境...
java -version >nul 2>&1
if %errorlevel% neq 0 (
    echo [错误] 未检测到Java环境,请先安装JDK 1.8+
    pause
    exit /b 1
)
echo [成功] Java环境正常
echo.

echo [步骤2] 检查Node.js环境...
node -v >nul 2>&1
if %errorlevel% neq 0 (
    echo [错误] 未检测到Node.js环境,请先安装Node.js 16+
    pause
    exit /b 1
)
echo [成功] Node.js环境正常
echo.

echo [步骤3] 检查MySQL数据库...
mysql -u root -proot -e "USE hr_datacenter;" >nul 2>&1
if %errorlevel% neq 0 (
    echo [警告] 数据库连接失败,请确保MySQL已启动并创建了hr_datacenter数据库
    echo [提示] 执行 backend/src/main/resources/sql/init.sql 初始化数据库
    pause
)
echo [成功] 数据库连接正常
echo.

echo ========================================
echo   请选择启动方式:
echo ========================================
echo   1. 启动后端服务
echo   2. 启动前端服务
echo   3. 同时启动前后端服务
echo   4. 退出
echo ========================================
set /p choice=请输入选项(1-4):

if "%choice%"=="1" goto startBackend
if "%choice%"=="2" goto startFrontend
if "%choice%"=="3" goto startAll
if "%choice%"=="4" goto end
echo [错误] 无效的选项
pause
exit /b 1

:startBackend
echo.
echo [启动] 正在启动后端服务...
cd backend
if not exist target\hr-datacenter-1.0.0.jar (
    echo [编译] 正在编译打包...
    call mvn clean package -DskipTests
    if %errorlevel% neq 0 (
        echo [错误] 编译失败
        pause
        exit /b 1
    )
)
echo [启动] 后端服务启动中...
start "HR后端" cmd /k "java -jar target\hr-datacenter-1.0.0.jar"
echo [成功] 后端服务已启动,访问地址: http://localhost:8080/api
echo.
goto end

:startFrontend
echo.
echo [启动] 正在启动前端服务...
cd frontend
if not exist node_modules (
    echo [安装] 正在安装依赖...
    call npm install
    if %errorlevel% neq 0 (
        echo [错误] 依赖安装失败
        pause
        exit /b 1
    )
)
echo [启动] 前端服务启动中...
start "HR前端" cmd /k "npm run dev"
echo [成功] 前端服务已启动,访问地址: http://localhost:3000
echo.
goto end

:startAll
echo.
echo [启动] 正在同时启动前后端服务...

cd backend
if not exist target\hr-datacenter-1.0.0.jar (
    echo [编译] 正在编译打包后端...
    call mvn clean package -DskipTests
    if %errorlevel% neq 0 (
        echo [错误] 后端编译失败
        pause
        exit /b 1
    )
)
start "HR后端" cmd /k "java -jar target\hr-datacenter-1.0.0.jar"
echo [成功] 后端服务已启动

cd ..\frontend
if not exist node_modules (
    echo [安装] 正在安装前端依赖...
    call npm install
    if %errorlevel% neq 0 (
        echo [错误] 前端依赖安装失败
        pause
        exit /b 1
    )
)
start "HR前端" cmd /k "npm run dev"
echo [成功] 前端服务已启动

echo.
echo ========================================
echo   所有服务已启动!
echo ========================================
echo   后端地址: http://localhost:8080/api
echo   前端地址: http://localhost:3000
echo.
echo   测试账号: admin / 123456
echo   测试账号: hr001 / 123456
echo ========================================
echo.

:end
echo.
echo 按任意键退出...
pause >nul
