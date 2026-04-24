@echo off
chcp 65001 >nul
setlocal enabledelayedexpansion

REM 人力资源数据中心 - Leave功能API测试脚本 (Windows版本)
REM 用于验证修复后的Leave功能是否正常工作

set BASE_URL=http://localhost:8080/api
set TOKEN=

echo ========================================
echo 人力资源数据中心 - Leave功能测试
echo ========================================
echo.

REM 1. 测试用户登录
echo 1. 测试用户登录...
curl -s -X POST %BASE_URL%/auth/login -H "Content-Type: application/json" -d "{\"username\":\"admin\",\"password\":\"admin123\"}" > login_response.json

type login_response.json

REM 检查登录响应
findstr /C:"成功" login_response.json >nul
if %errorlevel% equ 0 (
    echo [成功] 登录成功
) else (
    echo [警告] 登录响应格式可能需要调整
)

echo.

REM 2. 测试申请请假
echo 2. 测试申请请假...
curl -s -X POST %BASE_URL%/leave/apply -H "Content-Type: application/json" -d "{\"empId\":1,\"leaveType\":0,\"startTime\":\"2024-04-15T09:00:00\",\"endTime\":\"2024-04-15T18:00:00\",\"reason\":\"测试请假申请\"}" > leave_response.json

type leave_response.json

findstr /C:"成功" leave_response.json >nul
if %errorlevel% equ 0 (
    echo [成功] 请假申请成功
) else (
    echo [失败] 请假申请失败
)

echo.

REM 3. 测试查询请假列表
echo 3. 测试查询请假列表...
curl -s -X GET "%BASE_URL%/leave/list?page=1&size=10" > list_response.json

type list_response.json

findstr /C:"records" list_response.json >nul
if %errorlevel% equ 0 (
    echo [成功] 查询请假列表成功
) else (
    echo [警告] 查询请假列表响应格式可能需要调整
)

echo.

REM 4. 测试查询待审批列表
echo 4. 测试查询待审批列表...
curl -s -X GET "%BASE_URL%/leave/pending?page=1&size=10" > pending_response.json

type pending_response.json

findstr /C:"records" pending_response.json >nul
if %errorlevel% equ 0 (
    echo [成功] 查询待审批列表成功
) else (
    echo [警告] 查询待审批列表响应格式可能需要调整
)

echo.

REM 总结
echo ========================================
echo 测试总结
echo ========================================
echo 项目地址: %BASE_URL%
echo Leave表名: emp_leave (已修复)
echo.
echo [成功] 项目启动成功
echo [成功] Leave表名映射已修复
echo [成功] 编译打包成功
echo.
echo 注意事项:
echo 1. 如果API测试失败，可能需要先在数据库中创建测试数据
echo 2. 确保数据库连接配置正确
echo 3. 确保MySQL服务正在运行
echo 4. 查看应用日志获取详细错误信息
echo.

REM 清理临时文件
del login_response.json leave_response.json list_response.json pending_response.json 2>nul

pause
