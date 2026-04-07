#!/bin/bash
# =====================================================
# Hive数据插入修复执行脚本
# 项目: 人力资源数据中心
# 用途: 修复并执行Hive数据插入SQL脚本
# 使用方法: ./fix_hive_execution.sh
# =====================================================

echo "======================================"
echo "开始修复Hive数据插入执行问题"
echo "======================================"

# 检查Hive是否可用
if ! command -v hive &> /dev/null; then
    echo "错误: Hive命令未找到，请确保Hive已正确安装并配置"
    exit 1
fi

# 获取脚本所在目录
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
SQL_FILE="$SCRIPT_DIR/hive_data_insert_final.sql"

echo "SQL文件路径: $SQL_FILE"

# 检查SQL文件是否存在
if [ ! -f "$SQL_FILE" ]; then
    echo "错误: SQL文件不存在: $SQL_FILE"
    exit 1
fi

# 使用Hive命令行执行SQL脚本
echo "开始执行Hive SQL脚本..."
hive -f "$SQL_FILE"

# 检查执行结果
if [ $? -eq 0 ]; then
    echo "======================================"
    echo "Hive数据插入执行成功!"
    echo "======================================"
else
    echo "======================================"
    echo "Hive数据插入执行失败!"
    echo "错误代码: $?"
    echo "请检查错误信息并重试"
    echo "======================================"
    exit 1
fi

exit 0
