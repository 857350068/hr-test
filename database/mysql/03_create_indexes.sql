-- =====================================================
-- MySQL索引优化脚本
-- 项目: 人力资源数据中心
-- 数据库: hr_datacenter
-- 用途: 创建补充索引,优化查询性能
-- 创建时间: 2026-03-31
-- =====================================================

USE hr_datacenter;

-- =====================================================
-- 说明: 主要索引已在建表脚本中创建
-- 本脚本用于创建补充索引和复合索引,进一步优化查询性能
-- =====================================================

-- =====================================================
-- 1. 员工表补充索引
-- =====================================================
-- 部门+职位联合索引(用于按部门和职位查询员工)
CREATE INDEX idx_dept_position ON employee(department, position);

-- 入职日期+状态联合索引(用于按时间和状态筛选员工)
CREATE INDEX idx_hire_status ON employee(hire_date, status);

-- =====================================================
-- 2. 考勤表补充索引
-- =====================================================
-- 考勤日期+类型联合索引(用于按日期和类型统计考勤)
CREATE INDEX idx_date_type ON attendance(attendance_date, attendance_type);

-- 考勤日期+状态联合索引(用于按日期和状态筛选考勤)
CREATE INDEX idx_date_status ON attendance(attendance_date, attendance_status);

-- =====================================================
-- 3. 请假表补充索引
-- =====================================================
-- 员工+审批状态联合索引(用于查询员工的待审批请假)
CREATE INDEX idx_emp_approval ON `leave`(emp_id, approval_status);

-- 开始时间+结束时间联合索引(用于查询某时间段的请假)
CREATE INDEX idx_time_range ON `leave`(start_time, end_time);

-- =====================================================
-- 4. 绩效表补充索引
-- =====================================================
-- 年度+绩效等级联合索引(用于按年度和等级统计绩效)
CREATE INDEX idx_year_level ON performance_evaluation(year, performance_level);

-- 员工+目标状态联合索引(用于查询员工的进行中目标)
CREATE INDEX idx_emp_goal_status ON performance_goal(emp_id, goal_status);

-- =====================================================
-- 5. 薪资表补充索引
-- =====================================================
-- 员工+发放状态联合索引(用于查询员工的已发放薪资)
CREATE INDEX idx_emp_payment_status ON salary_payment(emp_id, payment_status);

-- 年+月+部门联合索引(用于按时间统计部门薪资,需要关联员工表)
-- 注意:此索引需要通过关联查询使用

-- =====================================================
-- 6. 培训表补充索引
-- =====================================================
-- 课程+状态联合索引(用于查询进行中的课程)
CREATE INDEX idx_course_status_date ON training_course(course_status, start_date);

-- 课程类型+开始日期联合索引(用于按类型和时间查询课程)
CREATE INDEX idx_type_date ON training_course(course_type, start_date);

-- =====================================================
-- 输出索引创建结果
-- =====================================================
SELECT '======================================' AS '';
SELECT 'MySQL索引优化完成!' AS message;
SELECT '======================================' AS '';

-- 显示所有索引
SELECT
    TABLE_NAME AS 表名,
    INDEX_NAME AS 索引名,
    COLUMN_NAME AS 列名,
    SEQ_IN_INDEX AS 序号,
    NON_UNIQUE AS 非唯一,
    INDEX_TYPE AS 索引类型
FROM information_schema.STATISTICS
WHERE TABLE_SCHEMA = 'hr_datacenter'
  AND INDEX_NAME != 'PRIMARY'
ORDER BY TABLE_NAME, INDEX_NAME, SEQ_IN_INDEX;
