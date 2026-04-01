-- =====================================================
-- Hive数据加载脚本
-- 项目: 人力资源数据中心
-- 数据仓库: hr_datacenter_dw
-- 功能: 从MySQL加载数据到Hive
-- 创建时间: 2026-03-31
-- 说明: 实际环境需要使用Sqoop或DataX等工具
-- =====================================================

USE hr_datacenter_dw;

-- =====================================================
-- 说明:
-- 本脚本为示例脚本,实际生产环境需要:
-- 1. 使用Sqoop从MySQL导入数据到HDFS
-- 2. 使用Hive外部表映射HDFS数据
-- 3. 使用INSERT OVERWRITE加载到内部表
-- =====================================================

-- =====================================================
-- 1. 加载员工维度数据
-- =====================================================
-- 实际命令示例:
-- sqoop import --connect jdbc:mysql://localhost:3306/hr_datacenter \
--   --username root --password root \
--   --table employee \
--   --hive-import --hive-table hr_datacenter_dw.dim_employee \
--   --hive-overwrite

INSERT OVERWRITE TABLE dim_employee
SELECT
    emp_id,
    emp_no,
    emp_name,
    gender,
    DATE_FORMAT(birth_date, 'yyyy-MM-dd'),
    id_card,
    phone,
    email,
    department,
    position,
    salary,
    DATE_FORMAT(hire_date, 'yyyy-MM-dd'),
    IFNULL(DATE_FORMAT(resign_date, 'yyyy-MM-dd'), ''),
    status,
    education,
    CURRENT_TIMESTAMP
FROM hr_datacenter.employee
WHERE deleted = 0;

SELECT '员工维度数据加载完成!' AS message;

-- =====================================================
-- 2. 加载考勤事实数据
-- =====================================================
INSERT OVERWRITE TABLE fact_attendance PARTITION(year_month)
SELECT
    a.attendance_id,
    a.emp_id,
    e.emp_no,
    e.emp_name,
    e.department,
    e.position,
    DATE_FORMAT(a.attendance_date, 'yyyy-MM-dd'),
    IFNULL(a.clock_in_time, ''),
    IFNULL(a.clock_out_time, ''),
    a.attendance_type,
    CASE a.attendance_type
        WHEN 0 THEN '正常'
        WHEN 1 THEN '迟到'
        WHEN 2 THEN '早退'
        WHEN 3 THEN '旷工'
        WHEN 4 THEN '请假'
        WHEN 5 THEN '加班'
    END,
    a.attendance_status,
    a.work_duration,
    YEAR(a.attendance_date),
    MONTH(a.attendance_date),
    CURRENT_TIMESTAMP,
    CONCAT(YEAR(a.attendance_date), '-', LPAD(MONTH(a.attendance_date), 2, '0'))
FROM hr_datacenter.attendance a
JOIN hr_datacenter.employee e ON a.emp_id = e.emp_id
WHERE a.deleted = 0;

SELECT '考勤事实数据加载完成!' AS message;

-- =====================================================
-- 3. 加载薪资事实数据
-- =====================================================
INSERT OVERWRITE TABLE fact_salary PARTITION(year_month)
SELECT
    s.payment_id,
    s.emp_id,
    e.emp_no,
    e.emp_name,
    e.department,
    e.position,
    s.year,
    s.month,
    s.basic_salary,
    s.performance_salary,
    s.position_allowance,
    s.transport_allowance,
    s.communication_allowance,
    s.meal_allowance,
    s.overtime_pay,
    s.social_insurance,
    s.housing_fund,
    s.income_tax,
    s.other_deduction,
    s.total_gross_salary,
    s.total_net_salary,
    s.payment_status,
    CURRENT_TIMESTAMP,
    CONCAT(s.year, '-', LPAD(s.month, 2, '0'))
FROM hr_datacenter.salary_payment s
JOIN hr_datacenter.employee e ON s.emp_id = e.emp_id
WHERE s.deleted = 0;

SELECT '薪资事实数据加载完成!' AS message;

-- =====================================================
-- 4. 加载绩效事实数据
-- =====================================================
INSERT OVERWRITE TABLE fact_performance PARTITION(year_partition)
SELECT
    p.evaluation_id,
    p.emp_id,
    e.emp_no,
    e.emp_name,
    e.department,
    e.position,
    p.year,
    p.period_type,
    CASE p.period_type
        WHEN 1 THEN '年度'
        WHEN 2 THEN '季度'
        WHEN 3 THEN '月度'
    END,
    p.self_score,
    p.supervisor_score,
    p.final_score,
    p.performance_level,
    CURRENT_TIMESTAMP,
    p.year
FROM hr_datacenter.performance_evaluation p
JOIN hr_datacenter.employee e ON p.emp_id = e.emp_id
WHERE p.deleted = 0;

SELECT '绩效事实数据加载完成!' AS message;

-- =====================================================
-- 5. 加载培训事实数据
-- =====================================================
INSERT OVERWRITE TABLE fact_training
SELECT
    t.enrollment_id,
    t.course_id,
    c.course_name,
    c.course_type,
    c.instructor,
    t.emp_id,
    e.emp_no,
    e.emp_name,
    e.department,
    DATE_FORMAT(t.enrollment_time, 'yyyy-MM-dd HH:mm:ss'),
    t.approval_status,
    t.attendance_status,
    t.score,
    CURRENT_TIMESTAMP
FROM hr_datacenter.training_enrollment t
JOIN hr_datacenter.training_course c ON t.course_id = c.course_id
JOIN hr_datacenter.employee e ON t.emp_id = e.emp_id
WHERE t.deleted = 0;

SELECT '培训事实数据加载完成!' AS message;

-- =====================================================
-- 6. 生成聚合数据
-- =====================================================

-- 部门月度考勤汇总
INSERT OVERWRITE TABLE agg_dept_monthly_attendance
SELECT
    department,
    year,
    month,
    COUNT(DISTINCT emp_id) AS total_employees,
    COUNT(*) AS total_attendance,
    SUM(CASE WHEN attendance_type = 0 THEN 1 ELSE 0 END) AS normal_count,
    SUM(CASE WHEN attendance_type = 1 THEN 1 ELSE 0 END) AS late_count,
    SUM(CASE WHEN attendance_type = 2 THEN 1 ELSE 0 END) AS early_leave_count,
    SUM(CASE WHEN attendance_type = 3 THEN 1 ELSE 0 END) AS absent_count,
    SUM(CASE WHEN attendance_type = 4 THEN 1 ELSE 0 END) AS leave_count,
    SUM(CASE WHEN attendance_type = 5 THEN 1 ELSE 0 END) AS overtime_count,
    AVG(work_duration) AS avg_work_duration,
    ROUND(SUM(CASE WHEN attendance_type = 0 THEN 1 ELSE 0 END) * 100.0 / COUNT(*), 2) AS attendance_rate,
    CURRENT_TIMESTAMP
FROM fact_attendance
GROUP BY department, year, month;

-- 部门月度薪资汇总
INSERT OVERWRITE TABLE agg_dept_monthly_salary
SELECT
    department,
    year,
    month,
    COUNT(DISTINCT emp_id) AS total_employees,
    SUM(total_gross_salary) AS total_gross_salary,
    SUM(total_net_salary) AS total_net_salary,
    AVG(total_gross_salary) AS avg_gross_salary,
    AVG(total_net_salary) AS avg_net_salary,
    SUM(basic_salary) AS total_basic_salary,
    SUM(performance_salary) AS total_performance_salary,
    SUM(social_insurance + housing_fund + income_tax + other_deduction) AS total_deduction,
    CURRENT_TIMESTAMP
FROM fact_salary
GROUP BY department, year, month;

-- 员工年度绩效汇总
INSERT OVERWRITE TABLE agg_employee_yearly_performance
SELECT
    emp_id,
    emp_no,
    emp_name,
    department,
    year,
    AVG(final_score) AS avg_final_score,
    MAX(final_score) AS max_final_score,
    MIN(final_score) AS min_final_score,
    SUM(CASE WHEN performance_level = 'S' THEN 1 ELSE 0 END) AS s_count,
    SUM(CASE WHEN performance_level = 'A' THEN 1 ELSE 0 END) AS a_count,
    SUM(CASE WHEN performance_level = 'B' THEN 1 ELSE 0 END) AS b_count,
    SUM(CASE WHEN performance_level = 'C' THEN 1 ELSE 0 END) AS c_count,
    SUM(CASE WHEN performance_level = 'D' THEN 1 ELSE 0 END) AS d_count,
    COUNT(*) AS total_evaluations,
    CURRENT_TIMESTAMP
FROM fact_performance
GROUP BY emp_id, emp_no, emp_name, department, year;

-- 培训课程统计
INSERT OVERWRITE TABLE agg_course_statistics
SELECT
    course_id,
    course_name,
    course_type,
    instructor,
    COUNT(*) AS total_enrollments,
    SUM(CASE WHEN approval_status = 1 THEN 1 ELSE 0 END) AS approved_count,
    SUM(CASE WHEN approval_status = 2 THEN 1 ELSE 0 END) AS rejected_count,
    SUM(CASE WHEN attendance_status = 1 THEN 1 ELSE 0 END) AS attended_count,
    AVG(score) AS avg_score,
    ROUND(SUM(CASE WHEN approval_status = 1 THEN 1 ELSE 0 END) * 100.0 / COUNT(*), 2) AS pass_rate,
    ROUND(SUM(CASE WHEN attendance_status = 1 THEN 1 ELSE 0 END) * 100.0 / COUNT(*), 2) AS attendance_rate,
    CURRENT_TIMESTAMP
FROM fact_training
GROUP BY course_id, course_name, course_type, instructor;

SELECT '聚合数据生成完成!' AS message;
