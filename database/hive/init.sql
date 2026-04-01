-- =====================================================
-- Hive完整初始化脚本
-- 项目: 人力资源数据中心
-- 数据仓库: hr_datacenter_dw
-- 功能: 一键初始化数据仓库
-- 创建时间: 2026-03-31
-- =====================================================

-- 输出开始信息
SELECT '======================================' AS '';
SELECT '开始初始化人力资源数据中心数据仓库...' AS message;
SELECT '======================================' AS '';
SELECT CURRENT_TIMESTAMP AS 开始时间;

-- =====================================================
-- 第一步: 创建数据仓库
-- =====================================================
SELECT '>>> 第1步: 创建数据仓库...' AS step;
SOURCE database/hive/01_create_database.sql;

-- =====================================================
-- 第二步: 创建维度表
-- =====================================================
SELECT '>>> 第2步: 创建维度表...' AS step;
SOURCE database/hive/02_create_dim_tables.sql;

-- =====================================================
-- 第三步: 创建事实表
-- =====================================================
SELECT '>>> 第3步: 创建事实表...' AS step;
SOURCE database/hive/03_create_fact_tables.sql;

-- =====================================================
-- 第四步: 创建聚合表
-- =====================================================
SELECT '>>> 第4步: 创建聚合表...' AS step;
SOURCE database/hive/04_create_agg_tables.sql;

-- =====================================================
-- 第五步: 加载数据
-- =====================================================
SELECT '>>> 第5步: 加载数据...' AS step;
SOURCE database/hive/05_load_data.sql;

-- =====================================================
-- 输出初始化完成信息
-- =====================================================
SELECT '======================================' AS '';
SELECT '数据仓库初始化完成!' AS message;
SELECT '======================================' AS '';
SELECT CURRENT_TIMESTAMP AS 完成时间;

-- 输出数据统计
SELECT '======================================' AS '';
SELECT '数据统计:' AS message;
SELECT '======================================' AS '';

SELECT '员工维度表' AS 表名, COUNT(*) AS 记录数 FROM dim_employee
UNION ALL
SELECT '考勤事实表', COUNT(*) FROM fact_attendance
UNION ALL
SELECT '薪资事实表', COUNT(*) FROM fact_salary
UNION ALL
SELECT '绩效事实表', COUNT(*) FROM fact_performance
UNION ALL
SELECT '培训事实表', COUNT(*) FROM fact_training
UNION ALL
SELECT '部门月度考勤汇总', COUNT(*) FROM agg_dept_monthly_attendance
UNION ALL
SELECT '部门月度薪资汇总', COUNT(*) FROM agg_dept_monthly_salary
UNION ALL
SELECT '员工年度绩效汇总', COUNT(*) FROM agg_employee_yearly_performance
UNION ALL
SELECT '培训课程统计', COUNT(*) FROM agg_course_statistics;

SELECT '======================================' AS '';
SELECT '初始化成功!可以开始使用数据仓库了!' AS message;
SELECT '======================================' AS '';
