-- =====================================================
-- MySQL完整初始化脚本
-- 项目: 人力资源数据中心
-- 数据库: hr_datacenter
-- 功能: 一键初始化数据库、表、索引、数据
-- 创建时间: 2026-03-31
-- =====================================================

-- 设置字符集
SET NAMES utf8mb4;
SET CHARACTER SET utf8mb4;

-- 输出开始信息
SELECT '======================================' AS '';
SELECT '开始初始化人力资源数据中心数据库...' AS message;
SELECT '======================================' AS '';
SELECT NOW() AS 开始时间;

-- =====================================================
-- 第一步: 创建数据库
-- =====================================================
SELECT '>>> 第1步: 创建数据库...' AS step;
SOURCE database/mysql/01_create_database.sql;

-- =====================================================
-- 第二步: 创建数据表
-- =====================================================
SELECT '>>> 第2步: 创建数据表...' AS step;
SOURCE database/mysql/02_create_tables.sql;

-- =====================================================
-- 第三步: 创建索引
-- =====================================================
SELECT '>>> 第3步: 创建索引...' AS step;
SOURCE database/mysql/03_create_indexes.sql;

-- =====================================================
-- 第四步: 插入用户数据
-- =====================================================
SELECT '>>> 第4步: 插入用户数据...' AS step;
SOURCE database/mysql/04_insert_users.sql;

-- =====================================================
-- 第五步: 插入员工数据
-- =====================================================
SELECT '>>> 第5步: 插入员工数据...' AS step;
SOURCE database/mysql/05_insert_employees.sql;

-- =====================================================
-- 第六步: 插入考勤数据
-- =====================================================
SELECT '>>> 第6步: 插入考勤数据...' AS step;
SOURCE database/mysql/06_insert_attendance.sql;

-- =====================================================
-- 第七步: 插入请假数据
-- =====================================================
SELECT '>>> 第7步: 插入请假数据...' AS step;
SOURCE database/mysql/07_insert_leave.sql;

-- =====================================================
-- 第八步: 插入绩效数据
-- =====================================================
SELECT '>>> 第8步: 插入绩效数据...' AS step;
SOURCE database/mysql/08_insert_performance.sql;

-- =====================================================
-- 第九步: 插入薪资数据
-- =====================================================
SELECT '>>> 第9步: 插入薪资数据...' AS step;
SOURCE database/mysql/09_insert_salary.sql;

-- =====================================================
-- 第十步: 插入培训数据
-- =====================================================
SELECT '>>> 第10步: 插入培训数据...' AS step;
SOURCE database/mysql/10_insert_training.sql;

-- =====================================================
-- 输出初始化完成信息
-- =====================================================
SELECT '======================================' AS '';
SELECT '数据库初始化完成!' AS message;
SELECT '======================================' AS '';
SELECT NOW() AS 完成时间;

-- 输出数据统计
SELECT '======================================' AS '';
SELECT '数据统计:' AS message;
SELECT '======================================' AS '';

SELECT '用户表' AS 表名, COUNT(*) AS 记录数 FROM sys_user WHERE deleted = 0
UNION ALL
SELECT '员工表', COUNT(*) FROM employee WHERE deleted = 0
UNION ALL
SELECT '考勤表', COUNT(*) FROM attendance WHERE deleted = 0
UNION ALL
SELECT '请假表', COUNT(*) FROM `leave` WHERE deleted = 0
UNION ALL
SELECT '绩效目标表', COUNT(*) FROM performance_goal WHERE deleted = 0
UNION ALL
SELECT '绩效评估表', COUNT(*) FROM performance_evaluation WHERE deleted = 0
UNION ALL
SELECT '薪资发放表', COUNT(*) FROM salary_payment WHERE deleted = 0
UNION ALL
SELECT '薪资调整表', COUNT(*) FROM salary_adjustment WHERE deleted = 0
UNION ALL
SELECT '培训课程表', COUNT(*) FROM training_course WHERE deleted = 0
UNION ALL
SELECT '培训报名表', COUNT(*) FROM training_enrollment WHERE deleted = 0;

SELECT '======================================' AS '';
SELECT '初始化成功!可以开始使用系统了!' AS message;
SELECT '======================================' AS '';
