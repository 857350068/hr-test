-- =====================================================
-- Hive聚合表创建脚本
-- 项目: 人力资源数据中心
-- 数据仓库: hr_datacenter_dw
-- 表类型: 聚合表(Aggregation Tables)
-- 创建时间: 2026-03-31
-- =====================================================

USE hr_datacenter_dw;

-- =====================================================
-- 1. agg_dept_monthly_attendance (部门月度考勤汇总)
-- 用途: 预聚合部门月度考勤数据,提高查询性能
-- =====================================================
CREATE TABLE IF NOT EXISTS agg_dept_monthly_attendance (
    department STRING COMMENT '部门',
    year INT COMMENT '年',
    month INT COMMENT '月',
    total_employees INT COMMENT '总人数',
    total_attendance INT COMMENT '总考勤次数',
    normal_count INT COMMENT '正常次数',
    late_count INT COMMENT '迟到次数',
    early_leave_count INT COMMENT '早退次数',
    absent_count INT COMMENT '旷工次数',
    leave_count INT COMMENT '请假次数',
    overtime_count INT COMMENT '加班次数',
    avg_work_duration DECIMAL(10,2) COMMENT '平均工作时长(分钟)',
    attendance_rate DECIMAL(5,2) COMMENT '出勤率(%)',
    etl_time TIMESTAMP COMMENT 'ETL时间'
)
COMMENT '部门月度考勤汇总表'
STORED AS ORC
TBLPROPERTIES ('orc.compress'='SNAPPY');

-- =====================================================
-- 2. agg_dept_monthly_salary (部门月度薪资汇总)
-- 用途: 预聚合部门月度薪资数据
-- =====================================================
CREATE TABLE IF NOT EXISTS agg_dept_monthly_salary (
    department STRING COMMENT '部门',
    year INT COMMENT '年',
    month INT COMMENT '月',
    total_employees INT COMMENT '总人数',
    total_gross_salary DECIMAL(15,2) COMMENT '应发工资总额',
    total_net_salary DECIMAL(15,2) COMMENT '实发工资总额',
    avg_gross_salary DECIMAL(10,2) COMMENT '平均应发工资',
    avg_net_salary DECIMAL(10,2) COMMENT '平均实发工资',
    total_basic_salary DECIMAL(15,2) COMMENT '基本工资总额',
    total_performance_salary DECIMAL(15,2) COMMENT '绩效工资总额',
    total_deduction DECIMAL(15,2) COMMENT '扣款总额',
    etl_time TIMESTAMP COMMENT 'ETL时间'
)
COMMENT '部门月度薪资汇总表'
STORED AS ORC
TBLPROPERTIES ('orc.compress'='SNAPPY');

-- =====================================================
-- 3. agg_employee_yearly_performance (员工年度绩效汇总)
-- 用途: 预聚合员工年度绩效数据
-- =====================================================
CREATE TABLE IF NOT EXISTS agg_employee_yearly_performance (
    emp_id BIGINT COMMENT '员工ID',
    emp_no STRING COMMENT '员工编号',
    emp_name STRING COMMENT '员工姓名',
    department STRING COMMENT '部门',
    year INT COMMENT '年',
    avg_final_score DECIMAL(5,2) COMMENT '平均综合评分',
    max_final_score DECIMAL(5,2) COMMENT '最高综合评分',
    min_final_score DECIMAL(5,2) COMMENT '最低综合评分',
    s_count INT COMMENT 'S级次数',
    a_count INT COMMENT 'A级次数',
    b_count INT COMMENT 'B级次数',
    c_count INT COMMENT 'C级次数',
    d_count INT COMMENT 'D级次数',
    total_evaluations INT COMMENT '总评估次数',
    etl_time TIMESTAMP COMMENT 'ETL时间'
)
COMMENT '员工年度绩效汇总表'
STORED AS ORC
TBLPROPERTIES ('orc.compress'='SNAPPY');

-- =====================================================
-- 4. agg_course_statistics (培训课程统计)
-- 用途: 预聚合培训课程统计数据
-- =====================================================
CREATE TABLE IF NOT EXISTS agg_course_statistics (
    course_id BIGINT COMMENT '课程ID',
    course_name STRING COMMENT '课程名称',
    course_type INT COMMENT '课程类型',
    instructor STRING COMMENT '培训讲师',
    total_enrollments INT COMMENT '总报名人数',
    approved_count INT COMMENT '已通过人数',
    rejected_count INT COMMENT '已拒绝人数',
    attended_count INT COMMENT '实际出勤人数',
    avg_score DECIMAL(5,2) COMMENT '平均成绩',
    pass_rate DECIMAL(5,2) COMMENT '通过率(%)',
    attendance_rate DECIMAL(5,2) COMMENT '出勤率(%)',
    etl_time TIMESTAMP COMMENT 'ETL时间'
)
COMMENT '培训课程统计表'
STORED AS ORC
TBLPROPERTIES ('orc.compress'='SNAPPY');

-- 输出创建结果
SELECT '聚合表创建完成!' AS message;
