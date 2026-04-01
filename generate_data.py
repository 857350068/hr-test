#!/usr/bin/env python3
# -*- coding: utf-8 -*-
"""
人力资源数据中心系统 - 数据生成脚本
生成2025年1月到12月的大量真实数据
支持MySQL和Hive两种格式
"""

import random
import datetime

# 员工数据模板
employees = [
    # 销售部 (dept_id=1)
    {'no': 'E001', 'name': '赵强', 'dept_id': 1, 'dept_name': '销售部', 'job': '销售经理', 'base_salary': 18500},
    {'no': 'E003', 'name': '孙磊', 'dept_id': 1, 'dept_name': '销售部', 'job': '销售代表', 'base_salary': 12500},
    {'no': 'E015', 'name': '杨帆', 'dept_id': 1, 'dept_name': '销售部', 'job': '销售主管', 'base_salary': 15500},
    {'no': 'E020', 'name': '黄磊', 'dept_id': 1, 'dept_name': '销售部', 'job': '销售代表', 'base_salary': 11800},
    {'no': 'E025', 'name': '周涛', 'dept_id': 1, 'dept_name': '销售部', 'job': '销售经理', 'base_salary': 19500},
    # 研发部 (dept_id=2)
    {'no': 'E002', 'name': '刘芳', 'dept_id': 2, 'dept_name': '研发部', 'job': '高级工程师', 'base_salary': 22000},
    {'no': 'E021', 'name': '郑华', 'dept_id': 2, 'dept_name': '研发部', 'job': '架构师', 'base_salary': 30000},
    # 产品研发中心 (dept_id=15)
    {'no': 'E018', 'name': '周杰', 'dept_id': 15, 'dept_name': '产品研发中心', 'job': '产品经理', 'base_salary': 26000},
    # 技术研发中心 (dept_id=16)
    {'no': 'E019', 'name': '吴磊', 'dept_id': 16, 'dept_name': '技术研发中心', 'job': '技术总监', 'base_salary': 35000},
    {'no': 'E026', 'name': '李明', 'dept_id': 16, 'dept_name': '技术研发中心', 'job': '高级工程师', 'base_salary': 24000},
    # 人事部 (dept_id=3)
    {'no': 'E004', 'name': '周静', 'dept_id': 3, 'dept_name': '人事部', 'job': 'HR专员', 'base_salary': 9500},
    {'no': 'E027', 'name': '王芳', 'dept_id': 3, 'dept_name': '人事部', 'job': '招聘经理', 'base_salary': 11000},
    {'no': 'E028', 'name': '张丽', 'dept_id': 3, 'dept_name': '人事部', 'job': '培训主管', 'base_salary': 10800},
    {'no': 'E029', 'name': '陈静', 'dept_id': 3, 'dept_name': '人事部', 'job': '薪酬专员', 'base_salary': 10500},
    {'no': 'E030', 'name': '刘洋', 'dept_id': 3, 'dept_name': '人事部', 'job': '人事经理', 'base_salary': 15000},
    # 财务部 (dept_id=4)
    {'no': 'E005', 'name': '吴敏', 'dept_id': 4, 'dept_name': '财务部', 'job': '会计', 'base_salary': 12000},
    {'no': 'E031', 'name': '赵婷', 'dept_id': 4, 'dept_name': '财务部', 'job': '财务经理', 'base_salary': 28000},
    {'no': 'E032', 'name': '孙磊', 'dept_id': 4, 'dept_name': '财务部', 'job': '出纳', 'base_salary': 8500},
    {'no': 'E033', 'name': '周杰', 'dept_id': 4, 'dept_name': '财务部', 'job': '成本会计', 'base_salary': 11500},
    {'no': 'E034', 'name': '吴芳', 'dept_id': 4, 'dept_name': '财务部', 'job': '审计专员', 'base_salary': 11800},
    # 市场部 (dept_id=5)
    {'no': 'E006', 'name': '王磊', 'dept_id': 5, 'dept_name': '市场部', 'job': '市场经理', 'base_salary': 19500},
    {'no': 'E035', 'name': '李萍', 'dept_id': 5, 'dept_name': '市场部', 'job': '营销总监', 'base_salary': 32000},
    {'no': 'E036', 'name': '张伟', 'dept_id': 5, 'dept_name': '市场部', 'job': '品牌经理', 'base_salary': 17500},
    {'no': 'E037', 'name': '刘芳', 'dept_id': 5, 'dept_name': '市场部', 'job': '市场专员', 'base_salary': 10500},
    {'no': 'E038', 'name': '陈晨', 'dept_id': 5, 'dept_name': '市场部', 'job': '活动策划', 'base_salary': 11000},
    # 运营部 (dept_id=6)
    {'no': 'E007', 'name': '张伟', 'dept_id': 6, 'dept_name': '运营部', 'job': '运营专员', 'base_salary': 11000},
    # 客服部 (dept_id=7)
    {'no': 'E008', 'name': '刘洋', 'dept_id': 7, 'dept_name': '客服部', 'job': '客服专员', 'base_salary': 9000},
    # 采购部 (dept_id=8)
    {'no': 'E009', 'name': '陈晨', 'dept_id': 8, 'dept_name': '采购部', 'job': '采购专员', 'base_salary': 10000},
    # 生产部 (dept_id=9)
    {'no': 'E010', 'name': '赵婷', 'dept_id': 9, 'dept_name': '生产部', 'job': '生产主管', 'base_salary': 15500},
    # 技术部 (dept_id=10)
    {'no': 'E011', 'name': '孙丽', 'dept_id': 10, 'dept_name': '技术部', 'job': '技术专员', 'base_salary': 13500},
    # 测试中心 (dept_id=17)
    {'no': 'E014', 'name': '郑敏', 'dept_id': 17, 'dept_name': '测试中心', 'job': '测试工程师', 'base_salary': 14500},
]

# 数据分类配置
categories = {
    1: {'name': '组织效能分析', 'value_range': (75, 95), 'unit': '分'},
    2: {'name': '人才梯队建设', 'value_range': (70, 92), 'unit': '分'},
    3: {'name': '薪酬福利分析', 'value_range': (8000, 38000), 'unit': '元'},
    4: {'name': '绩效管理体系', 'value_range': (65, 98), 'unit': '分'},
    5: {'name': '员工流失预警', 'value_range': (2, 15), 'unit': '%'},
    6: {'name': '培训效果评估', 'value_range': (75, 96), 'unit': '分'},
    7: {'name': '人力成本优化', 'value_range': (5000, 45000), 'unit': '元'},
    8: {'name': '人才发展预测', 'value_range': (72, 94), 'unit': '分'},
}

def generate_value(category_id, base_value=None, month=1):
    """生成随机值,带有季节性和波动性"""
    cat = categories[category_id]
    min_val, max_val = cat['value_range']

    # 季节性调整
    seasonal_factor = 1.0 + random.uniform(-0.05, 0.05)

    if base_value and category_id in [3, 7]:  # 薪资和成本类
        # 薪资有轻微增长趋势
        growth_factor = 1.0 + (month * 0.005)
        value = base_value * growth_factor * seasonal_factor
        # 添加随机波动
        value = value * random.uniform(0.98, 1.02)
    else:
        value = random.uniform(min_val, max_val)
        # 添加随机波动
        value = value * random.uniform(0.95, 1.05)

    # 确保在合理范围内
    value = max(min_val, min(max_val, value))

    return round(value, 1)

def generate_mysql_sql(month):
    """生成MySQL格式的SQL文件"""
    period = f'2025{month:02d}'
    filename = f'D:/HrDataCenter/database/mysql/{period}.sql'

    sql_lines = []
    sql_lines.append(f"""-- ============================================================
-- 人力资源数据中心系统 - MySQL 数据插入脚本
-- 文件名: {period}.sql
-- 数据库: hr_db | MySQL 8.0.33
-- 说明: {period}月大量真实数据插入
-- ============================================================

USE hr_db;

-- ------------------------------------------------------------
-- employee_profile - {period}月大量真实数据
-- 包含:组织效能、人才梯队、薪酬福利、绩效管理、流失预警、培训效果、人力成本、人才发展
-- ------------------------------------------------------------
INSERT INTO `employee_profile` (`employee_no`, `name`, `dept_id`, `dept_name`, `job`, `category_id`, `value`, `period`, `create_time`) VALUES""")

    # 为每个员工生成8个分类的数据
    for emp in employees:
        for category_id in range(1, 9):
            if category_id in [3, 7]:
                value = generate_value(category_id, emp['base_salary'], month)
            else:
                value = generate_value(category_id, None, month)

            sql_lines.append(f"('{emp['no']}', '{emp['name']}', {emp['dept_id']}, '{emp['dept_name']}', '{emp['job']}', {category_id}, {value}, '{period}', '2025-{month:02d}-15 09:00:00'),")

    # 修改最后一个逗号为分号
    sql_lines[-1] = sql_lines[-1].rstrip(',') + ';'

    # 添加数据同步日志
    sql_lines.append(f"""
-- ------------------------------------------------------------
-- 插入数据同步日志
-- ------------------------------------------------------------
INSERT INTO `data_sync_log` (`start_time`, `end_time`, `status`, `records_processed`, `details`, `create_time`) VALUES
('2025-{month:02d}-15 02:00:00', '2025-{month:02d}-15 02:02:30', 'SUCCESS', {len(employees) * 8}, '{period}月全量数据同步', '2025-{month:02d}-15 02:00:00');

-- 执行完成
SELECT '{period}.sql 数据插入完成！' AS message;""")

    # 写入文件
    with open(filename, 'w', encoding='utf-8') as f:
        f.write('\n'.join(sql_lines))

    print(f'生成MySQL文件: {filename}')

def generate_hive_sql(month):
    """生成Hive格式的SQL文件"""
    period = f'2025{month:02d}'
    filename = f'D:/HrDataCenter/database/hive/{period}.sql'

    sql_lines = []
    sql_lines.append(f"""-- ============================================================
-- 人力资源数据中心系统 - Hive 数据插入脚本
-- 文件名: {period}.sql
-- Hive 3.1.3 | 数据库: hr_db
-- 说明: {period}月大量真实数据插入
-- 执行: 在 Hive 客户端或 beeline 中执行
-- ============================================================

USE hr_db;

-- ------------------------------------------------------------
-- employee_profile - {period}月大量真实数据
-- 包含:组织效能、人才梯队、薪酬福利、绩效管理、流失预警、培训效果、人力成本、人才发展
-- ------------------------------------------------------------
INSERT INTO hr_db.employee_profile VALUES""")

    # 为每个员工生成8个分类的数据
    for emp in employees:
        for category_id in range(1, 9):
            if category_id in [3, 7]:
                value = generate_value(category_id, emp['base_salary'], month)
            else:
                value = generate_value(category_id, None, month)

            sql_lines.append(f"(NULL, '{emp['no']}', '{emp['name']}', {emp['dept_id']}, '{emp['dept_name']}', '{emp['job']}', {category_id}, {value}, '{period}', 0, '2025-{month:02d}-15 09:00:00'),")

    # 修改最后一个逗号为分号
    sql_lines[-1] = sql_lines[-1].rstrip(',') + ';'

    # 添加数据同步日志
    sql_lines.append(f"""
-- ------------------------------------------------------------
-- 插入数据同步日志
-- ------------------------------------------------------------
INSERT INTO hr_db.data_sync_log VALUES
(NULL, '2025-{month:02d}-15 02:00:00', '2025-{month:02d}-15 02:02:30', 'SUCCESS', {len(employees) * 8}, '{period}月全量数据同步', '2025-{month:02d}-15 02:00:00');

-- 执行完成
SELECT '{period}.sql 数据插入完成！' AS message;""")

    # 写入文件
    with open(filename, 'w', encoding='utf-8') as f:
        f.write('\n'.join(sql_lines))

    print(f'生成Hive文件: {filename}')

def main():
    """主函数"""
    print('=' * 80)
    print('人力资源数据中心系统 - 数据生成器')
    print('生成2025年1月到12月的MySQL和Hive格式数据文件')
    print('=' * 80)

    for month in range(1, 13):
        print(f'\n正在生成2025年{month:02d}月数据...')
        generate_mysql_sql(month)
        generate_hive_sql(month)

    print('\n' + '=' * 80)
    print('所有数据文件生成完成!')
    print('MySQL文件位置: D:/HrDataCenter/database/mysql/')
    print('Hive文件位置: D:/HrDataCenter/database/hive/')
    print('=' * 80)

if __name__ == '__main__':
    main()
