-- =====================================================
-- 人力资源数据中心 - Hive数据仓库统一初始化脚本
-- 项目: HrDataCenter
-- 数据库: hr_datacenter_dw
-- 版本: v2.0
-- 创建时间: 2026-04-07
-- 功能: 完整的Hive数据仓库初始化，包含维度表、事实表和聚合表
-- 数据格式: ORC + SNAPPY压缩
-- =====================================================

-- =====================================================
-- 第一步: 创建数据库
-- =====================================================
DROP DATABASE IF EXISTS hr_datacenter_dw CASCADE;

CREATE DATABASE hr_datacenter_dw
COMMENT '人力资源数据中心数据仓库'
LOCATION '/user/hive/warehouse/hr_datacenter_dw.db';

USE hr_datacenter_dw;

SELECT '======================================' AS '';
SELECT 'Hive数据仓库 hr_datacenter_dw 创建成功!' AS message;
SELECT '======================================' AS '';

-- =====================================================
-- 第二步: 创建维度表 (Dimension Tables)
-- =====================================================

-- 1. 员工维度表
CREATE TABLE IF NOT EXISTS dim_employee (
    emp_id BIGINT COMMENT '员工ID',
    emp_no STRING COMMENT '员工编号',
    emp_name STRING COMMENT '员工姓名',
    gender INT COMMENT '性别(0-女 1-男)',
    birth_date STRING COMMENT '出生日期',
    age INT COMMENT '年龄',
    id_card STRING COMMENT '身份证号',
    phone STRING COMMENT '手机号码',
    email STRING COMMENT '邮箱',
    department STRING COMMENT '部门',
    position STRING COMMENT '职位',
    salary DECIMAL(10,2) COMMENT '薪资',
    hire_date STRING COMMENT '入职日期',
    resign_date STRING COMMENT '离职日期',
    work_years INT COMMENT '工作年限',
    status INT COMMENT '状态(0-离职 1-在职 2-试用)',
    education STRING COMMENT '学历',
    etl_time TIMESTAMP COMMENT 'ETL时间'
)
COMMENT '员工维度表'
PARTITIONED BY (year STRING COMMENT '年度分区')
STORED AS ORC
TBLPROPERTIES ('orc.compress'='SNAPPY');

-- 2. 部门维度表
CREATE TABLE IF NOT EXISTS dim_department (
    dept_id BIGINT COMMENT '部门ID',
    dept_name STRING COMMENT '部门名称',
    dept_code STRING COMMENT '部门编码',
    parent_dept_id BIGINT COMMENT '上级部门ID',
    dept_level INT COMMENT '部门层级',
    manager_name STRING COMMENT '部门负责人',
    employee_count INT COMMENT '员工数量',
    avg_salary DECIMAL(10,2) COMMENT '平均薪资',
    etl_time TIMESTAMP COMMENT 'ETL时间'
)
COMMENT '部门维度表'
STORED AS ORC
TBLPROPERTIES ('orc.compress'='SNAPPY');

-- 3. 日期维度表
CREATE TABLE IF NOT EXISTS dim_date (
    date_id STRING COMMENT '日期ID(YYYYMMDD)',
    date_value STRING COMMENT '日期值',
    year INT COMMENT '年份',
    month INT COMMENT '月份',
    day INT COMMENT '日期',
    quarter INT COMMENT '季度',
    week INT COMMENT '周数',
    day_of_week INT COMMENT '星期几(1-7)',
    is_weekend BOOLEAN COMMENT '是否周末',
    is_holiday BOOLEAN COMMENT '是否节假日',
    month_name STRING COMMENT '月份名称',
    quarter_name STRING COMMENT '季度名称',
    etl_time TIMESTAMP COMMENT 'ETL时间'
)
COMMENT '日期维度表'
PARTITIONED BY (year STRING COMMENT '年度分区')
STORED AS ORC
TBLPROPERTIES ('orc.compress'='SNAPPY');

-- 4. 课程维度表
CREATE TABLE IF NOT EXISTS dim_course (
    course_id BIGINT COMMENT '课程ID',
    course_name STRING COMMENT '课程名称',
    course_type INT COMMENT '课程类型(1-新员工培训 2-技能培训 3-管理培训 4-安全培训 5-其他)',
    course_type_name STRING COMMENT '课程类型名称',
    course_description STRING COMMENT '课程描述',
    instructor STRING COMMENT '培训讲师',
    duration INT COMMENT '培训时长(小时)',
    location STRING COMMENT '培训地点',
    capacity INT COMMENT '培训名额',
    enrolled_count INT COMMENT '已报名人数',
    completion_rate DECIMAL(5,2) COMMENT '完成率',
    avg_score DECIMAL(5,2) COMMENT '平均分数',
    etl_time TIMESTAMP COMMENT 'ETL时间'
)
COMMENT '课程维度表'
STORED AS ORC
TBLPROPERTIES ('orc.compress'='SNAPPY');

SELECT '======================================' AS '';
SELECT '维度表创建完成!' AS message;
SELECT '======================================' AS '';

-- =====================================================
-- 第三步: 创建事实表 (Fact Tables)
-- =====================================================

-- 1. 考勤事实表
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
    day INT COMMENT '日',
    etl_time TIMESTAMP COMMENT 'ETL时间'
)
COMMENT '考勤事实表'
PARTITIONED BY (year_month STRING COMMENT '年月分区(YYYY-MM)')
STORED AS ORC
TBLPROPERTIES ('orc.compress'='SNAPPY');

-- 2. 薪资事实表
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
    other_allowance DECIMAL(10,2) COMMENT '其他补贴',
    overtime_pay DECIMAL(10,2) COMMENT '加班费',
    total_gross_salary DECIMAL(10,2) COMMENT '应发工资总额',
    social_insurance DECIMAL(10,2) COMMENT '社保个人部分',
    housing_fund DECIMAL(10,2) COMMENT '公积金个人部分',
    income_tax DECIMAL(10,2) COMMENT '个人所得税',
    other_deduction DECIMAL(10,2) COMMENT '其他扣款',
    total_net_salary DECIMAL(10,2) COMMENT '实发工资总额',
    payment_status INT COMMENT '发放状态(0-未发放 1-已发放)',
    payment_date STRING COMMENT '发放时间',
    etl_time TIMESTAMP COMMENT 'ETL时间'
)
COMMENT '薪资事实表'
PARTITIONED BY (year_month STRING COMMENT '年月分区(YYYY-MM)')
STORED AS ORC
TBLPROPERTIES ('orc.compress'='SNAPPY');

-- 3. 绩效事实表
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
    quarter INT COMMENT '季度(季度评估时使用)',
    month INT COMMENT '月份(月度评估时使用)',
    self_score DECIMAL(5,2) COMMENT '自评分',
    supervisor_score DECIMAL(5,2) COMMENT '上级评分',
    final_score DECIMAL(5,2) COMMENT '综合评分',
    performance_level STRING COMMENT '绩效等级(S/A/B/C/D)',
    performance_level_name STRING COMMENT '绩效等级名称',
    improvement_plan STRING COMMENT '改进建议',
    interview_date STRING COMMENT '面谈时间',
    evaluation_status INT COMMENT '评估状态(0-未评估 1-已自评 2-已评价 3-已完成)',
    evaluation_status_name STRING COMMENT '评估状态名称',
    etl_time TIMESTAMP COMMENT 'ETL时间'
)
COMMENT '绩效事实表'
PARTITIONED BY (year STRING COMMENT '年度分区')
STORED AS ORC
TBLPROPERTIES ('orc.compress'='SNAPPY');

-- 4. 培训事实表
CREATE TABLE IF NOT EXISTS fact_training (
    enrollment_id BIGINT COMMENT '报名ID',
    course_id BIGINT COMMENT '课程ID',
    course_name STRING COMMENT '课程名称',
    course_type INT COMMENT '课程类型',
    course_type_name STRING COMMENT '课程类型名称',
    emp_id BIGINT COMMENT '员工ID',
    emp_no STRING COMMENT '员工编号',
    emp_name STRING COMMENT '员工姓名',
    department STRING COMMENT '部门',
    position STRING COMMENT '职位',
    enrollment_time STRING COMMENT '报名时间',
    approval_status INT COMMENT '审核状态(0-待审核 1-已通过 2-已拒绝)',
    approval_status_name STRING COMMENT '审核状态名称',
    approver_id BIGINT COMMENT '审核人ID',
    attendance_status INT COMMENT '出勤状态(0-未出勤 1-已出勤 2-请假)',
    attendance_status_name STRING COMMENT '出勤状态名称',
    score INT COMMENT '培训成绩',
    score_level STRING COMMENT '成绩等级',
    feedback STRING COMMENT '培训反馈',
    year INT COMMENT '年份',
    month INT COMMENT '月份',
    etl_time TIMESTAMP COMMENT 'ETL时间'
)
COMMENT '培训事实表'
PARTITIONED BY (year_month STRING COMMENT '年月分区(YYYY-MM)')
STORED AS ORC
TBLPROPERTIES ('orc.compress'='SNAPPY');

SELECT '======================================' AS '';
SELECT '事实表创建完成!' AS message;
SELECT '======================================' AS '';

-- =====================================================
-- 第四步: 创建聚合表 (Aggregate Tables)
-- =====================================================

-- 1. 部门月度考勤汇总表
CREATE TABLE IF NOT EXISTS agg_dept_monthly_attendance (
    department STRING COMMENT '部门',
    year_month STRING COMMENT '年月',
    year INT COMMENT '年份',
    month INT COMMENT '月份',
    total_employees INT COMMENT '总员工数',
    total_days INT COMMENT '总工作天数',
    total_attendance INT COMMENT '总出勤天数',
    attendance_rate DECIMAL(5,2) COMMENT '出勤率',
    normal_count INT COMMENT '正常次数',
    late_count INT COMMENT '迟到次数',
    early_leave_count INT COMMENT '早退次数',
    absence_count INT COMMENT '旷工次数',
    leave_count INT COMMENT '请假次数',
    overtime_count INT COMMENT '加班次数',
    avg_work_duration DECIMAL(10,2) COMMENT '平均工作时长',
    etl_time TIMESTAMP COMMENT 'ETL时间'
)
COMMENT '部门月度考勤汇总表'
PARTITIONED BY (year STRING COMMENT '年度分区')
STORED AS ORC
TBLPROPERTIES ('orc.compress'='SNAPPY');

-- 2. 部门月度薪资汇总表
CREATE TABLE IF NOT EXISTS agg_dept_monthly_salary (
    department STRING COMMENT '部门',
    year_month STRING COMMENT '年月',
    year INT COMMENT '年份',
    month INT COMMENT '月份',
    employee_count INT COMMENT '员工人数',
    total_basic_salary DECIMAL(15,2) COMMENT '基本工资总额',
    total_performance_salary DECIMAL(15,2) COMMENT '绩效工资总额',
    total_allowance DECIMAL(15,2) COMMENT '津贴总额',
    total_overtime_pay DECIMAL(15,2) COMMENT '加班费总额',
    total_gross_salary DECIMAL(15,2) COMMENT '应发工资总额',
    total_deduction DECIMAL(15,2) COMMENT '扣款总额',
    total_net_salary DECIMAL(15,2) COMMENT '实发工资总额',
    avg_basic_salary DECIMAL(10,2) COMMENT '平均基本工资',
    avg_net_salary DECIMAL(10,2) COMMENT '平均实发工资',
    max_salary DECIMAL(10,2) COMMENT '最高薪资',
    min_salary DECIMAL(10,2) COMMENT '最低薪资',
    payment_count INT COMMENT '已发放人数',
    etl_time TIMESTAMP COMMENT 'ETL时间'
)
COMMENT '部门月度薪资汇总表'
PARTITIONED BY (year STRING COMMENT '年度分区')
STORED AS ORC
TBLPROPERTIES ('orc.compress'='SNAPPY');

-- 3. 员工年度绩效汇总表
CREATE TABLE IF NOT EXISTS agg_employee_yearly_performance (
    emp_id BIGINT COMMENT '员工ID',
    emp_no STRING COMMENT '员工编号',
    emp_name STRING COMMENT '员工姓名',
    department STRING COMMENT '部门',
    position STRING COMMENT '职位',
    year INT COMMENT '年份',
    total_evaluations INT COMMENT '总评估次数',
    avg_self_score DECIMAL(5,2) COMMENT '平均自评分',
    avg_supervisor_score DECIMAL(5,2) COMMENT '平均上级评分',
    avg_final_score DECIMAL(5,2) COMMENT '平均综合分数',
    s_level_count INT COMMENT 'S级次数',
    a_level_count INT COMMENT 'A级次数',
    b_level_count INT COMMENT 'B级次数',
    c_level_count INT COMMENT 'C级次数',
    d_level_count INT COMMENT 'D级次数',
    overall_level STRING COMMENT '总体等级',
    score_trend STRING COMMENT '分数趋势',
    improvement_count INT COMMENT '改进计划数量',
    etl_time TIMESTAMP COMMENT 'ETL时间'
)
COMMENT '员工年度绩效汇总表'
PARTITIONED BY (year STRING COMMENT '年度分区')
STORED AS ORC
TBLPROPERTIES ('orc.compress'='SNAPPY');

-- 4. 培训课程统计表
CREATE TABLE IF NOT EXISTS agg_course_statistics (
    course_id BIGINT COMMENT '课程ID',
    course_name STRING COMMENT '课程名称',
    course_type INT COMMENT '课程类型',
    course_type_name STRING COMMENT '课程类型名称',
    instructor STRING COMMENT '培训讲师',
    duration INT COMMENT '培训时长',
    location STRING COMMENT '培训地点',
    capacity INT COMMENT '培训名额',
    total_enrollments INT COMMENT '总报名人数',
    approved_count INT COMMENT '已通过审核人数',
    completed_count INT COMMENT '已完成人数',
    completion_rate DECIMAL(5,2) COMMENT '完成率',
    attendance_rate DECIMAL(5,2) COMMENT '出勤率',
    avg_score DECIMAL(5,2) COMMENT '平均分数',
    satisfaction_rate DECIMAL(5,2) COMMENT '满意度',
    excellent_rate DECIMAL(5,2) COMMENT '优秀率(80分以上)',
    good_rate DECIMAL(5,2) COMMENT '良好率(60-79分)',
    pass_rate DECIMAL(5,2) COMMENT '及格率(60分以上)',
    fail_rate DECIMAL(5,2) COMMENT '不及格率(60分以下)',
    first_course_date STRING COMMENT '首次开课日期',
    last_course_date STRING COMMENT '最近开课日期',
    total_feedback INT COMMENT '总反馈数量',
    etl_time TIMESTAMP COMMENT 'ETL时间'
)
COMMENT '培训课程统计表'
STORED AS ORC
TBLPROPERTIES ('orc.compress'='SNAPPY');

-- 5. 员工流失分析表
CREATE TABLE IF NOT EXISTS agg_employee_turnover (
    department STRING COMMENT '部门',
    year_month STRING COMMENT '年月',
    year INT COMMENT '年份',
    month INT COMMENT '月份',
    beginning_count INT COMMENT '期初人数',
    new_hire_count INT COMMENT '新入职人数',
    resign_count INT COMMENT '离职人数',
    turnover_rate DECIMAL(5,2) COMMENT '流失率',
    avg_tenure DECIMAL(10,2) COMMENT '平均在职时长(月)',
    avg_salary_resigned DECIMAL(10,2) COMMENT '离职员工平均薪资',
    avg_salary_current DECIMAL(10,2) COMMENT '在职员工平均薪资',
    high_performer_resign_count INT COMMENT '高绩效离职人数',
    high_performer_resign_rate DECIMAL(5,2) COMMENT '高绩效流失率',
    new_hire_avg_age DECIMAL(5,2) COMMENT '新员工平均年龄',
    resign_avg_age DECIMAL(5,2) COMMENT '离职员工平均年龄',
    etl_time TIMESTAMP COMMENT 'ETL时间'
)
COMMENT '员工流失分析表'
PARTITIONED BY (year STRING COMMENT '年度分区')
STORED AS ORC
TBLPROPERTIES ('orc.compress'='SNAPPY');

-- 6. 人力成本分析表
CREATE TABLE IF NOT EXISTS agg_labor_cost (
    department STRING COMMENT '部门',
    year_month STRING COMMENT '年月',
    year INT COMMENT '年份',
    month INT COMMENT '月份',
    employee_count INT COMMENT '员工人数',
    total_labor_cost DECIMAL(18,2) COMMENT '总人力成本',
    salary_cost DECIMAL(18,2) COMMENT '薪资成本',
    allowance_cost DECIMAL(18,2) COMMENT '津贴成本',
    benefit_cost DECIMAL(18,2) COMMENT '福利成本',
    training_cost DECIMAL(18,2) COMMENT '培训成本',
    recruitment_cost DECIMAL(18,2) COMMENT '招聘成本',
    avg_cost_per_employee DECIMAL(12,2) COMMENT '人均成本',
    cost_growth_rate DECIMAL(5,2) COMMENT '成本增长率',
    cost_per_revenue DECIMAL(5,2) COMMENT '成本占收入比',
    overtime_cost_ratio DECIMAL(5,2) COMMENT '加班费占比',
    etl_time TIMESTAMP COMMENT 'ETL时间'
)
COMMENT '人力成本分析表'
PARTITIONED BY (year STRING COMMENT '年度分区')
STORED AS ORC
TBLPROPERTIES ('orc.compress'='SNAPPY');

SELECT '======================================' AS '';
SELECT '聚合表创建完成!' AS message;
SELECT '======================================' AS '';

-- =====================================================
-- 初始化完成
-- =====================================================
SELECT '======================================' AS '';
SELECT 'Hive数据仓库初始化完成!' AS message;
SELECT '======================================' AS '';

-- 显示所有创建的表
SHOW TABLES;

SELECT '======================================' AS '';
SELECT '创建完成!' AS message;
SELECT '======================================' AS '';
