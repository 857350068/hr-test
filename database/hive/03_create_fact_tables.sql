-- =====================================================
-- Hive事实表创建脚本
-- 项目: 人力资源数据中心
-- 数据仓库: hr_datacenter_dw
-- 表类型: 事实表(Fact Tables)
-- 创建时间: 2026-03-31
-- =====================================================

USE hr_datacenter_dw;

-- =====================================================
-- 1. fact_attendance (考勤事实表)
-- 用途: 存储考勤事实数据,按年月分区
-- =====================================================
CREATE TABLE IF NOT EXISTS fact_attendance (
    attendance_id BIGINT COMMENT '考勤ID',
    emp_id BIGINT COMMENT '员工ID',
    emp_no STRING COMMENT '员工编号',
    emp_name STRING COMMENT '员工姓名',
    department STRING COMMENT '部门',
    position STRING COMMENT '职位',
    attendance_date STRING COMMENT '考勤日期',
    clock_in_time STRING COMMENT '上班打卡时间',
    clock_out_time STRING COMMENT '下班打卡时间',
    attendance_type INT COMMENT '考勤类型(0-正常 1-迟到 2-早退 3-旷工 4-请假 5-加班)',
    attendance_type_name STRING COMMENT '考勤类型名称',
    attendance_status INT COMMENT '考勤状态',
    work_duration INT COMMENT '工作时长(分钟)',
    year INT COMMENT '年',
    month INT COMMENT '月',
    etl_time TIMESTAMP COMMENT 'ETL时间'
)
COMMENT '考勤事实表'
PARTITIONED BY (year_month STRING COMMENT '年月分区(YYYY-MM)')
STORED AS ORC
TBLPROPERTIES ('orc.compress'='SNAPPY');

-- =====================================================
-- 2. fact_salary (薪资事实表)
-- 用途: 存储薪资事实数据,按年月分区
-- =====================================================
CREATE TABLE IF NOT EXISTS fact_salary (
    payment_id BIGINT COMMENT '发放ID',
    emp_id BIGINT COMMENT '员工ID',
    emp_no STRING COMMENT '员工编号',
    emp_name STRING COMMENT '员工姓名',
    department STRING COMMENT '部门',
    position STRING COMMENT '职位',
    year INT COMMENT '发放年度',
    month INT COMMENT '发放月份',
    basic_salary DECIMAL(10,2) COMMENT '基本工资',
    performance_salary DECIMAL(10,2) COMMENT '绩效工资',
    position_allowance DECIMAL(10,2) COMMENT '岗位津贴',
    transport_allowance DECIMAL(10,2) COMMENT '交通补贴',
    communication_allowance DECIMAL(10,2) COMMENT '通讯补贴',
    meal_allowance DECIMAL(10,2) COMMENT '餐补',
    overtime_pay DECIMAL(10,2) COMMENT '加班费',
    social_insurance DECIMAL(10,2) COMMENT '社保个人部分',
    housing_fund DECIMAL(10,2) COMMENT '公积金个人部分',
    income_tax DECIMAL(10,2) COMMENT '个人所得税',
    other_deduction DECIMAL(10,2) COMMENT '其他扣款',
    total_gross_salary DECIMAL(10,2) COMMENT '应发工资',
    total_net_salary DECIMAL(10,2) COMMENT '实发工资',
    payment_status INT COMMENT '发放状态',
    etl_time TIMESTAMP COMMENT 'ETL时间'
)
COMMENT '薪资事实表'
PARTITIONED BY (year_month STRING COMMENT '年月分区(YYYY-MM)')
STORED AS ORC
TBLPROPERTIES ('orc.compress'='SNAPPY');

-- =====================================================
-- 3. fact_performance (绩效事实表)
-- 用途: 存储绩效事实数据,按年分区
-- =====================================================
CREATE TABLE IF NOT EXISTS fact_performance (
    evaluation_id BIGINT COMMENT '评估ID',
    emp_id BIGINT COMMENT '员工ID',
    emp_no STRING COMMENT '员工编号',
    emp_name STRING COMMENT '员工姓名',
    department STRING COMMENT '部门',
    position STRING COMMENT '职位',
    year INT COMMENT '评估年度',
    period_type INT COMMENT '评估周期(1-年度 2-季度 3-月度)',
    period_type_name STRING COMMENT '评估周期名称',
    self_score DECIMAL(5,2) COMMENT '自评分',
    supervisor_score DECIMAL(5,2) COMMENT '上级评分',
    final_score DECIMAL(5,2) COMMENT '综合评分',
    performance_level STRING COMMENT '绩效等级(S/A/B/C/D)',
    etl_time TIMESTAMP COMMENT 'ETL时间'
)
COMMENT '绩效事实表'
PARTITIONED BY (year_partition INT COMMENT '年分区')
STORED AS ORC
TBLPROPERTIES ('orc.compress'='SNAPPY');

-- =====================================================
-- 4. fact_training (培训事实表)
-- 用途: 存储培训事实数据
-- =====================================================
CREATE TABLE IF NOT EXISTS fact_training (
    enrollment_id BIGINT COMMENT '报名ID',
    course_id BIGINT COMMENT '课程ID',
    course_name STRING COMMENT '课程名称',
    course_type INT COMMENT '课程类型',
    instructor STRING COMMENT '培训讲师',
    emp_id BIGINT COMMENT '员工ID',
    emp_no STRING COMMENT '员工编号',
    emp_name STRING COMMENT '员工姓名',
    department STRING COMMENT '部门',
    enrollment_time STRING COMMENT '报名时间',
    approval_status INT COMMENT '审核状态',
    attendance_status INT COMMENT '出勤状态',
    score INT COMMENT '培训成绩',
    etl_time TIMESTAMP COMMENT 'ETL时间'
)
COMMENT '培训事实表'
STORED AS ORC
TBLPROPERTIES ('orc.compress'='SNAPPY');

-- 输出创建结果
SELECT '事实表创建完成!' AS message;
