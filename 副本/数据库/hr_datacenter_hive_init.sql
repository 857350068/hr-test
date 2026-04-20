-- ============================================================================
-- 人力资源数据中心系统 - Hive数据仓库初始化脚本
-- 版本: 1.0
-- 创建时间: 2024-01-20
-- 数据库类型: Hive 3.1.3+
-- 说明: 包含维度表、事实表的建表语句，采用星型模型设计
-- ============================================================================

-- 设置Hive参数 ✅ 修复：动态分区参数拼写错误
SET hive.exec.dynamic.partition=true;
SET hive.exec.dynamic.partition.mode=nonstrict;
SET hive.mapred.mode=nonstrict;
SET hive.exec.compress.output=true;
SET mapred.output.compression.codec=org.apache.hadoop.io.compress.SnappyCodec;

-- ============================================================================
-- 1. 创建数据库
-- ============================================================================
CREATE DATABASE IF NOT EXISTS hr_datacenter_dw
COMMENT '人力资源数据中心数据仓库'
LOCATION '/user/hive/warehouse/hr_datacenter_dw.db';

USE hr_datacenter_dw;

-- ============================================================================
-- 2. 维度表 (Dimension Tables)
-- ============================================================================

-- ============================================================================
-- 2.1 员工维度表 (dim_employee)
-- ============================================================================
DROP TABLE IF EXISTS dim_employee;
CREATE EXTERNAL TABLE IF NOT EXISTS dim_employee (
    emp_id BIGINT COMMENT '员工ID',
    emp_no STRING COMMENT '员工编号',
    emp_name STRING COMMENT '员工姓名',
    gender INT COMMENT '性别(0-女 1-男)',
    gender_name STRING COMMENT '性别名称',
    birth_date DATE COMMENT '出生日期',
    age INT COMMENT '年龄',
    id_card STRING COMMENT '身份证号',
    phone STRING COMMENT '手机号码',
    email STRING COMMENT '邮箱',
    department STRING COMMENT '部门',
    position STRING COMMENT '职位',
    current_salary DECIMAL(10,2) COMMENT '当前薪资',
    hire_date DATE COMMENT '入职日期',
    resign_date DATE COMMENT '离职日期',
    work_years INT COMMENT '工作年限',
    status INT COMMENT '员工状态(0-离职 1-在职 2-试用)',
    status_name STRING COMMENT '状态名称',
    education STRING COMMENT '学历',
    education_level INT COMMENT '学历等级(1-高中 2-大专 3-本科 4-硕士 5-博士)',
    create_time TIMESTAMP COMMENT '创建时间',
    update_time TIMESTAMP COMMENT '更新时间',
    dw_create_time TIMESTAMP COMMENT '数据仓库创建时间',
    dw_update_time TIMESTAMP COMMENT '数据仓库更新时间'
)
COMMENT '员工维度表'
PARTITIONED BY (dt STRING COMMENT '数据日期分区')
STORED AS ORC
TBLPROPERTIES (
    'orc.compress'='SNAPPY',
    'orc.create.index'='true',
    'orc.bloom.filter.columns'='emp_no,emp_name,department,position',
    'comment'='员工维度表，存储员工基础信息'
);

-- ============================================================================
-- 2.2 部门维度表 (dim_department)
-- ============================================================================
DROP TABLE IF EXISTS dim_department;
CREATE EXTERNAL TABLE IF NOT EXISTS dim_department (
    department_id BIGINT COMMENT '部门ID',
    department_code STRING COMMENT '部门编码',
    department_name STRING COMMENT '部门名称',
    parent_id BIGINT COMMENT '上级部门ID',
    department_level INT COMMENT '部门层级',
    manager_id BIGINT COMMENT '部门负责人ID',
    manager_name STRING COMMENT '部门负责人姓名',
    employee_count INT COMMENT '员工人数',
    budget DECIMAL(15,2) COMMENT '部门预算',
    description STRING COMMENT '部门描述',
    status INT COMMENT '部门状态(0-禁用 1-启用)',
    create_time TIMESTAMP COMMENT '创建时间',
    update_time TIMESTAMP COMMENT '更新时间',
    dw_create_time TIMESTAMP COMMENT '数据仓库创建时间',
    dw_update_time TIMESTAMP COMMENT '数据仓库更新时间'
)
COMMENT '部门维度表'
PARTITIONED BY (dt STRING COMMENT '数据日期分区')
STORED AS ORC
TBLPROPERTIES (
    'orc.compress'='SNAPPY',
    'orc.create.index'='true',
    'orc.bloom.filter.columns'='department_code,department_name',
    'comment'='部门维度表，存储部门组织架构信息'
);

-- 初始化部门维度数据
INSERT OVERWRITE TABLE dim_department PARTITION (dt='20240120')
VALUES
(1, 'DEPT001', '技术部', NULL, 1, 2, '李四', 4, 500000.00, '负责公司技术研发工作', 1, CURRENT_TIMESTAMP, CURRENT_TIMESTAMP, CURRENT_TIMESTAMP, CURRENT_TIMESTAMP),
(2, 'DEPT002', '人力资源部', NULL, 1, 4, '赵六', 2, 200000.00, '负责人力资源管理工作', 1, CURRENT_TIMESTAMP, CURRENT_TIMESTAMP, CURRENT_TIMESTAMP, CURRENT_TIMESTAMP),
(3, 'DEPT003', '财务部', NULL, 1, 5, '钱七', 2, 200000.00, '负责财务管理工作', 1, CURRENT_TIMESTAMP, CURRENT_TIMESTAMP, CURRENT_TIMESTAMP, CURRENT_TIMESTAMP),
(4, 'DEPT004', '市场部', NULL, 1, 6, '孙八', 2, 300000.00, '负责市场推广工作', 1, CURRENT_TIMESTAMP, CURRENT_TIMESTAMP, CURRENT_TIMESTAMP, CURRENT_TIMESTAMP);

-- ============================================================================
-- 2.3 时间维度表 (dim_time)
-- ============================================================================
DROP TABLE IF EXISTS dim_time;
CREATE EXTERNAL TABLE IF NOT EXISTS dim_time (
    date_key INT COMMENT '日期键(YYYYMMDD格式)',
    date_value DATE COMMENT '日期值',
    year INT COMMENT '年份',
    quarter INT COMMENT '季度',
    month INT COMMENT '月份',
    day INT COMMENT '日期',
    week INT COMMENT '周数',
    day_of_week INT COMMENT '星期几(1-7)',
    day_of_year INT COMMENT '一年中的第几天',
    is_weekend BOOLEAN COMMENT '是否周末',
    is_holiday BOOLEAN COMMENT '是否节假日',
    holiday_name STRING COMMENT '节假日名称',
    month_name STRING COMMENT '月份名称',
    quarter_name STRING COMMENT '季度名称',
    year_quarter STRING COMMENT '年季度(YYYY-QX)',
    year_month STRING COMMENT '年月(YYYY-MM)',
    year_week STRING COMMENT '年周(YYYY-WWW)'
)
COMMENT '时间维度表'
STORED AS ORC
TBLPROPERTIES (
    'orc.compress'='SNAPPY',
    'orc.create.index'='true',
    'comment'='时间维度表，存储时间相关属性'
);

-- 初始化时间维度数据(生成2024年的时间数据) ✅ 修复：Hive兼容的日期生成逻辑
INSERT INTO TABLE dim_time
WITH date_series AS (
    SELECT date_add('2024-01-01', t.n) AS date_value
    FROM (
        SELECT row_number() over() - 1 AS n
        FROM (
            SELECT 1 UNION ALL SELECT 2 UNION ALL SELECT 3 UNION ALL SELECT 4 UNION ALL SELECT 5
            UNION ALL SELECT 6 UNION ALL SELECT 7 UNION ALL SELECT 8 UNION ALL SELECT 9 UNION ALL SELECT 10
        ) t1
        CROSS JOIN (
            SELECT 1 UNION ALL SELECT 2 UNION ALL SELECT 3 UNION ALL SELECT 4 UNION ALL SELECT 5
            UNION ALL SELECT 6 UNION ALL SELECT 7 UNION ALL SELECT 8 UNION ALL SELECT 9 UNION ALL SELECT 10
        ) t2
        CROSS JOIN (
            SELECT 1 UNION ALL SELECT 2 UNION ALL SELECT 3 UNION ALL SELECT 4 UNION ALL SELECT 5
            UNION ALL SELECT 6 UNION ALL SELECT 7 UNION ALL SELECT 8 UNION ALL SELECT 9 UNION ALL SELECT 10
        ) t3
    ) t
    WHERE t.n < 366
)
SELECT
    CAST(year(date_value) * 10000 + month(date_value) * 100 + day(date_value) AS INT) AS date_key,
    date_value,
    year(date_value) AS year,
    quarter(date_value) AS quarter,
    month(date_value) AS month,
    day(date_value) AS day,
    weekofyear(date_value) AS week,
    pmod(datediff(date_value, '1900-01-07'), 7) + 1 AS day_of_week,
    datediff(date_value, concat(year(date_value), '-01-01')) + 1 AS day_of_year,
    pmod(datediff(date_value, '1900-01-07'), 7) IN (5, 6) AS is_weekend,
    false AS is_holiday,
    NULL AS holiday_name,
    monthname(date_value) AS month_name,
    concat('Q', quarter(date_value)) AS quarter_name,
    concat(year(date_value), '-Q', quarter(date_value)) AS year_quarter,
    concat(year(date_value), '-', lpad(month(date_value), 2, '0')) AS year_month,
    concat(year(date_value), '-W', lpad(weekofyear(date_value), 3, '0')) AS year_week
FROM date_series;

-- ============================================================================
-- 2.4 职位维度表 (dim_position)
-- ============================================================================
DROP TABLE IF EXISTS dim_position;
CREATE EXTERNAL TABLE IF NOT EXISTS dim_position (
    position_id BIGINT COMMENT '职位ID',
    position_code STRING COMMENT '职位编码',
    position_name STRING COMMENT '职位名称',
    position_level INT COMMENT '职位级别(1-初级 2-中级 3-高级 4-专家 5-管理)',
    position_category STRING COMMENT '职位类别',
    department STRING COMMENT '所属部门',
    min_salary DECIMAL(10,2) COMMENT '最低薪资',
    max_salary DECIMAL(10,2) COMMENT '最高薪资',
    avg_salary DECIMAL(10,2) COMMENT '平均薪资',
    employee_count INT COMMENT '员工人数',
    description STRING COMMENT '职位描述',
    status INT COMMENT '职位状态(0-禁用 1-启用)',
    create_time TIMESTAMP COMMENT '创建时间',
    update_time TIMESTAMP COMMENT '更新时间',
    dw_create_time TIMESTAMP COMMENT '数据仓库创建时间',
    dw_update_time TIMESTAMP COMMENT '数据仓库更新时间'
)
COMMENT '职位维度表'
PARTITIONED BY (dt STRING COMMENT '数据日期分区')
STORED AS ORC
TBLPROPERTIES (
    'orc.compress'='SNAPPY',
    'orc.create.index'='true',
    'orc.bloom.filter.columns'='position_code,position_name,department',
    'comment'='职位维度表，存储职位信息'
);

-- 初始化职位维度数据
INSERT OVERWRITE TABLE dim_position PARTITION (dt='20240120')
VALUES
(1, 'POS001', '初级软件工程师', 1, '技术', '技术部', 8000.00, 12000.00, 10000.00, 0, '负责初级软件开发工作', 1, CURRENT_TIMESTAMP, CURRENT_TIMESTAMP, CURRENT_TIMESTAMP, CURRENT_TIMESTAMP),
(2, 'POS002', '中级软件工程师', 2, '技术', '技术部', 12000.00, 18000.00, 15000.00, 3, '负责中级软件开发工作', 1, CURRENT_TIMESTAMP, CURRENT_TIMESTAMP, CURRENT_TIMESTAMP, CURRENT_TIMESTAMP),
(3, 'POS003', '高级软件工程师', 3, '技术', '技术部', 18000.00, 25000.00, 20000.00, 1, '负责高级软件开发工作', 1, CURRENT_TIMESTAMP, CURRENT_TIMESTAMP, CURRENT_TIMESTAMP, CURRENT_TIMESTAMP),
(4, 'POS004', '前端开发工程师', 2, '技术', '技术部', 10000.00, 16000.00, 13000.00, 1, '负责前端开发工作', 1, CURRENT_TIMESTAMP, CURRENT_TIMESTAMP, CURRENT_TIMESTAMP, CURRENT_TIMESTAMP),
(5, 'POS005', '人力资源专员', 2, '职能', '人力资源部', 6000.00, 10000.00, 8000.00, 1, '负责人力资源管理工作', 1, CURRENT_TIMESTAMP, CURRENT_TIMESTAMP, CURRENT_TIMESTAMP, CURRENT_TIMESTAMP),
(6, 'POS006', '会计', 2, '财务', '财务部', 7000.00, 11000.00, 9000.00, 1, '负责财务会计工作', 1, CURRENT_TIMESTAMP, CURRENT_TIMESTAMP, CURRENT_TIMESTAMP, CURRENT_TIMESTAMP),
(7, 'POS007', '销售经理', 3, '销售', '市场部', 15000.00, 22000.00, 18000.00, 1, '负责销售管理工作', 1, CURRENT_TIMESTAMP, CURRENT_TIMESTAMP, CURRENT_TIMESTAMP, CURRENT_TIMESTAMP),
(8, 'POS008', '产品经理', 3, '产品', '技术部', 14000.00, 20000.00, 16000.00, 1, '负责产品管理工作', 1, CURRENT_TIMESTAMP, CURRENT_TIMESTAMP, CURRENT_TIMESTAMP, CURRENT_TIMESTAMP),
(9, 'POS009', 'UI设计师', 2, '设计', '技术部', 9000.00, 14000.00, 11000.00, 1, '负责UI设计工作', 1, CURRENT_TIMESTAMP, CURRENT_TIMESTAMP, CURRENT_TIMESTAMP, CURRENT_TIMESTAMP);

-- ============================================================================
-- 3. 事实表 (Fact Tables)
-- ============================================================================

-- ============================================================================
-- 3.1 考勤事实表 (fact_attendance)
-- ============================================================================
DROP TABLE IF EXISTS fact_attendance;
CREATE EXTERNAL TABLE IF NOT EXISTS fact_attendance (
    attendance_id BIGINT COMMENT '考勤ID',
    emp_id BIGINT COMMENT '员工ID',
    emp_no STRING COMMENT '员工编号',
    emp_name STRING COMMENT '员工姓名',
    department STRING COMMENT '部门',
    attendance_date DATE COMMENT '考勤日期',
    date_key INT COMMENT '日期键',
    clock_in_time STRING COMMENT '上班打卡时间',
    clock_out_time STRING COMMENT '下班打卡时间',
    attendance_type INT COMMENT '考勤类型(0-正常 1-迟到 2-早退 3-旷工 4-请假 5-加班)',
    attendance_type_name STRING COMMENT '考勤类型名称',
    attendance_status INT COMMENT '考勤状态(0-未打卡 1-已打卡 2-请假 3-加班)',
    attendance_status_name STRING COMMENT '考勤状态名称',
    work_duration INT COMMENT '工作时长(分钟)',
    work_hours DECIMAL(5,2) COMMENT '工作时长(小时)',
    is_late BOOLEAN COMMENT '是否迟到',
    is_early_leave BOOLEAN COMMENT '是否早退',
    is_absent BOOLEAN COMMENT '是否旷工',
    is_overtime BOOLEAN COMMENT '是否加班',
    remark STRING COMMENT '备注',
    create_time TIMESTAMP COMMENT '创建时间',
    update_time TIMESTAMP COMMENT '更新时间',
    dw_create_time TIMESTAMP COMMENT '数据仓库创建时间',
    dw_update_time TIMESTAMP COMMENT '数据仓库更新时间'
)
COMMENT '考勤事实表'
PARTITIONED BY (year STRING COMMENT '年分区', month STRING COMMENT '月分区')
STORED AS ORC
TBLPROPERTIES (
    'orc.compress'='SNAPPY',
    'orc.create.index'='true',
    'orc.bloom.filter.columns'='emp_id,emp_no,department,attendance_date',
    'comment'='考勤事实表，存储员工考勤记录'
);

-- ============================================================================
-- 3.2 绩效事实表 (fact_performance)
-- ============================================================================
DROP TABLE IF EXISTS fact_performance;
CREATE EXTERNAL TABLE IF NOT EXISTS fact_performance (
    evaluation_id BIGINT COMMENT '评估ID',
    emp_id BIGINT COMMENT '员工ID',
    emp_no STRING COMMENT '员工编号',
    emp_name STRING COMMENT '员工姓名',
    department STRING COMMENT '部门',
    position STRING COMMENT '职位',
    year INT COMMENT '评估年度',
    year_quarter STRING COMMENT '年季度',
    period_type INT COMMENT '评估周期(1-年度 2-季度 3-月度)',
    period_type_name STRING COMMENT '评估周期名称',
    quarter INT COMMENT '季度',
    month INT COMMENT '月份',
    self_score DECIMAL(5,2) COMMENT '自评分',
    self_comment STRING COMMENT '自评说明',
    supervisor_score DECIMAL(5,2) COMMENT '上级评分',
    supervisor_comment STRING COMMENT '上级评价意见',
    final_score DECIMAL(5,2) COMMENT '综合评分',
    performance_level STRING COMMENT '绩效等级(S-优秀 A-良好 B-合格 C-需改进 D-不合格)',
    performance_score INT COMMENT '绩效分数(S=5,A=4,B=3,C=2,D=1)',
    improvement_plan STRING COMMENT '改进建议',
    interview_record STRING COMMENT '面谈记录',
    interview_date TIMESTAMP COMMENT '面谈时间',
    evaluation_status INT COMMENT '评估状态(0-未评估 1-已自评 2-已评价 3-已完成)',
    evaluation_status_name STRING COMMENT '评估状态名称',
    create_time TIMESTAMP COMMENT '创建时间',
    update_time TIMESTAMP COMMENT '更新时间',
    dw_create_time TIMESTAMP COMMENT '数据仓库创建时间',
    dw_update_time TIMESTAMP COMMENT '数据仓库更新时间'
)
COMMENT '绩效事实表'
PARTITIONED BY (year STRING COMMENT '年分区', quarter STRING COMMENT '季度分区')
STORED AS ORC
TBLPROPERTIES (
    'orc.compress'='SNAPPY',
    'orc.create.index'='true',
    'orc.bloom.filter.columns'='emp_id,emp_no,department,year,quarter',
    'comment'='绩效事实表，存储员工绩效评估数据'
);

-- ============================================================================
-- 3.3 薪资事实表 (fact_salary)
-- ============================================================================
DROP TABLE IF EXISTS fact_salary;
CREATE EXTERNAL TABLE IF NOT EXISTS fact_salary (
    payment_id BIGINT COMMENT '发放ID',
    emp_id BIGINT COMMENT '员工ID',
    emp_no STRING COMMENT '员工编号',
    emp_name STRING COMMENT '员工姓名',
    department STRING COMMENT '部门',
    position STRING COMMENT '职位',
    year INT COMMENT '发放年度',
    year_month STRING COMMENT '年月',
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
    social_insurance DECIMAL(10,2) COMMENT '社保',
    housing_fund DECIMAL(10,2) COMMENT '公积金',
    income_tax DECIMAL(10,2) COMMENT '个人所得税',
    other_deduction DECIMAL(10,2) COMMENT '其他扣款',
    total_deduction DECIMAL(10,2) COMMENT '总扣款',
    total_net_salary DECIMAL(10,2) COMMENT '实发工资总额',
    payment_status INT COMMENT '发放状态(0-未发放 1-已发放)',
    payment_status_name STRING COMMENT '发放状态名称',
    payment_date TIMESTAMP COMMENT '发放时间',
    remark STRING COMMENT '备注',
    create_time TIMESTAMP COMMENT '创建时间',
    update_time TIMESTAMP COMMENT '更新时间',
    dw_create_time TIMESTAMP COMMENT '数据仓库创建时间',
    dw_update_time TIMESTAMP COMMENT '数据仓库更新时间'
)
COMMENT '薪资事实表'
PARTITIONED BY (year STRING COMMENT '年分区', month STRING COMMENT '月分区')
STORED AS ORC
TBLPROPERTIES (
    'orc.compress'='SNAPPY',
    'orc.create.index'='true',
    'orc.bloom.filter.columns'='emp_id,emp_no,department,year,month',
    'comment'='薪资事实表，存储员工薪资发放数据'
);

-- ============================================================================
-- 3.4 培训事实表 (fact_training)
-- ============================================================================
DROP TABLE IF EXISTS fact_training;
CREATE EXTERNAL TABLE IF NOT EXISTS fact_training (
    enrollment_id BIGINT COMMENT '报名ID',
    course_id BIGINT COMMENT '课程ID',
    emp_id BIGINT COMMENT '员工ID',
    emp_no STRING COMMENT '员工编号',
    emp_name STRING COMMENT '员工姓名',
    department STRING COMMENT '部门',
    position STRING COMMENT '职位',
    course_name STRING COMMENT '课程名称',
    course_type INT COMMENT '课程类型(1-新员工培训 2-技能培训 3-管理培训 4-安全培训 5-其他)',
    course_type_name STRING COMMENT '课程类型名称',
    course_description STRING COMMENT '课程描述',
    instructor STRING COMMENT '培训讲师',
    duration INT COMMENT '培训时长(小时)',
    location STRING COMMENT '培训地点',
    start_date TIMESTAMP COMMENT '培训开始时间',
    end_date TIMESTAMP COMMENT '培训结束时间',
    enrollment_time TIMESTAMP COMMENT '报名时间',
    approval_status INT COMMENT '审核状态(0-待审核 1-已通过 2-已拒绝)',
    approval_status_name STRING COMMENT '审核状态名称',
    approver_id BIGINT COMMENT '审核人ID',
    attendance_status INT COMMENT '出勤状态(0-未出勤 1-已出勤 2-请假)',
    attendance_status_name STRING COMMENT '出勤状态名称',
    score INT COMMENT '培训成绩',
    score_level STRING COMMENT '成绩等级(A-优秀 B-良好 C-合格 D-不合格)',
    feedback STRING COMMENT '培训反馈',
    create_time TIMESTAMP COMMENT '创建时间',
    update_time TIMESTAMP COMMENT '更新时间',
    dw_create_time TIMESTAMP COMMENT '数据仓库创建时间',
    dw_update_time TIMESTAMP COMMENT '数据仓库更新时间'
)
COMMENT '培训事实表'
PARTITIONED BY (year STRING COMMENT '年分区')
STORED AS ORC
TBLPROPERTIES (
    'orc.compress'='SNAPPY',
    'orc.create.index'='true',
    'orc.bloom.filter.columns'='emp_id,emp_no,course_id,course_name,department',
    'comment'='培训事实表，存储员工培训数据'
);

-- ============================================================================
-- 4. 聚合表 (Aggregate Tables)
-- ============================================================================

-- ============================================================================
-- 4.1 员工月度考勤汇总表 (agg_employee_monthly_attendance)
-- ============================================================================
DROP TABLE IF EXISTS agg_employee_monthly_attendance;
CREATE EXTERNAL TABLE IF NOT EXISTS agg_employee_monthly_attendance (
    emp_id BIGINT COMMENT '员工ID',
    emp_no STRING COMMENT '员工编号',
    emp_name STRING COMMENT '员工姓名',
    department STRING COMMENT '部门',
    year INT COMMENT '年份',
    month INT COMMENT '月份',
    year_month STRING COMMENT '年月',
    total_days INT COMMENT '总考勤天数',
    normal_days INT COMMENT '正常天数',
    late_days INT COMMENT '迟到天数',
    early_leave_days INT COMMENT '早退天数',
    absent_days INT COMMENT '旷工天数',
    leave_days INT COMMENT '请假天数',
    overtime_days INT COMMENT '加班天数',
    total_work_duration INT COMMENT '总工作时长(分钟)',
    avg_work_duration DECIMAL(5,2) COMMENT '平均工作时长(小时)',
    late_rate DECIMAL(5,2) COMMENT '迟到率(%)',
    absent_rate DECIMAL(5,2) COMMENT '旷工率(%)',
    overtime_rate DECIMAL(5,2) COMMENT '加班率(%)',
    dw_update_time TIMESTAMP COMMENT '数据仓库更新时间'
)
COMMENT '员工月度考勤汇总表'
PARTITIONED BY (year STRING COMMENT '年分区', month STRING COMMENT '月分区')
STORED AS ORC
TBLPROPERTIES (
    'orc.compress'='SNAPPY',
    'orc.create.index'='true',
    'orc.bloom.filter.columns'='emp_id,emp_no,department,year,month',
    'comment'='员工月度考勤汇总表'
);

-- ============================================================================
-- 4.2 部门月度绩效汇总表 (agg_department_monthly_performance)
-- ============================================================================
DROP TABLE IF EXISTS agg_department_monthly_performance;
CREATE EXTERNAL TABLE IF NOT EXISTS agg_department_monthly_performance (
    department STRING COMMENT '部门',
    year INT COMMENT '年份',
    month INT COMMENT '月份',
    year_month STRING COMMENT '年月',
    total_employees INT COMMENT '总员工数',
    evaluated_employees INT COMMENT '已评估员工数',
    evaluation_rate DECIMAL(5,2) COMMENT '评估率(%)',
    avg_self_score DECIMAL(5,2) COMMENT '平均自评分',
    avg_supervisor_score DECIMAL(5,2) COMMENT '平均上级评分',
    avg_final_score DECIMAL(5,2) COMMENT '平均综合评分',
    s_level_count INT COMMENT '优秀人数',
    a_level_count INT COMMENT '良好人数',
    b_level_count INT COMMENT '合格人数',
    c_level_count INT COMMENT '需改进人数',
    d_level_count INT COMMENT '不合格人数',
    s_level_rate DECIMAL(5,2) COMMENT '优秀率(%)',
    a_level_rate DECIMAL(5,2) COMMENT '良好率(%)',
    b_level_rate DECIMAL(5,2) COMMENT '合格率(%)',
    c_level_rate DECIMAL(5,2) COMMENT '需改进率(%)',
    d_level_rate DECIMAL(5,2) COMMENT '不合格率(%)',
    dw_update_time TIMESTAMP COMMENT '数据仓库更新时间'
)
COMMENT '部门月度绩效汇总表'
PARTITIONED BY (year STRING COMMENT '年分区', month STRING COMMENT '月分区')
STORED AS ORC
TBLPROPERTIES (
    'orc.compress'='SNAPPY',
    'orc.create.index'='true',
    'orc.bloom.filter.columns'='department,year,month',
    'comment'='部门月度绩效汇总表'
);

-- ============================================================================
-- 4.3 员工月度薪资汇总表 (agg_employee_monthly_salary)
-- ============================================================================
DROP TABLE IF EXISTS agg_employee_monthly_salary;
CREATE EXTERNAL TABLE IF NOT EXISTS agg_employee_monthly_salary (
    emp_id BIGINT COMMENT '员工ID',
    emp_no STRING COMMENT '员工编号',
    emp_name STRING COMMENT '员工姓名',
    department STRING COMMENT '部门',
    position STRING COMMENT '职位',
    year INT COMMENT '年份',
    month INT COMMENT '月份',
    year_month STRING COMMENT '年月',
    basic_salary DECIMAL(10,2) COMMENT '基本工资',
    performance_salary DECIMAL(10,2) COMMENT '绩效工资',
    total_allowance DECIMAL(10,2) COMMENT '总补贴',
    overtime_pay DECIMAL(10,2) COMMENT '加班费',
    total_gross_salary DECIMAL(10,2) COMMENT '应发工资',
    total_deduction DECIMAL(10,2) COMMENT '总扣款',
    total_net_salary DECIMAL(10,2) COMMENT '实发工资',
    payment_status INT COMMENT '发放状态',
    payment_status_name STRING COMMENT '发放状态名称',
    salary_growth_rate DECIMAL(5,2) COMMENT '薪资增长率(%)',
    dw_update_time TIMESTAMP COMMENT '数据仓库更新时间'
)
COMMENT '员工月度薪资汇总表'
PARTITIONED BY (year STRING COMMENT '年分区', month STRING COMMENT '月分区')
STORED AS ORC
TBLPROPERTIES (
    'orc.compress'='SNAPPY',
    'orc.create.index'='true',
    'orc.bloom.filter.columns'='emp_id,emp_no,department,year,month',
    'comment'='员工月度薪资汇总表'
);

-- ============================================================================
-- 4.4 部门月度人力成本汇总表 (agg_department_monthly_cost)
-- ============================================================================
DROP TABLE IF EXISTS agg_department_monthly_cost;
CREATE EXTERNAL TABLE IF NOT EXISTS agg_department_monthly_cost (
    department STRING COMMENT '部门',
    year INT COMMENT '年份',
    month INT COMMENT '月份',
    year_month STRING COMMENT '年月',
    employee_count INT COMMENT '员工人数',
    total_gross_salary DECIMAL(15,2) COMMENT '应发工资总额',
    total_net_salary DECIMAL(15,2) COMMENT '实发工资总额',
    avg_salary DECIMAL(10,2) COMMENT '人均薪资',
    total_allowance DECIMAL(15,2) COMMENT '总补贴',
    total_overtime_pay DECIMAL(15,2) COMMENT '总加班费',
    total_social_insurance DECIMAL(15,2) COMMENT '总社保',
    total_housing_fund DECIMAL(15,2) COMMENT '总公积金',
    total_income_tax DECIMAL(15,2) COMMENT '总个税',
    total_cost DECIMAL(15,2) COMMENT '总人力成本',
    cost_per_employee DECIMAL(10,2) COMMENT '人均成本',
    cost_growth_rate DECIMAL(5,2) COMMENT '成本增长率(%)',
    dw_update_time TIMESTAMP COMMENT '数据仓库更新时间'
)
COMMENT '部门月度人力成本汇总表'
PARTITIONED BY (year STRING COMMENT '年分区', month STRING COMMENT '月分区')
STORED AS ORC
TBLPROPERTIES (
    'orc.compress'='SNAPPY',
    'orc.create.index'='true',
    'orc.bloom.filter.columns'='department,year,month',
    'comment'='部门月度人力成本汇总表'
);

-- ============================================================================
-- 5. 数据同步视图 (用于从MySQL同步数据)
-- ============================================================================

-- ============================================================================
-- 5.1 员工数据同步视图
-- ============================================================================
CREATE OR REPLACE VIEW v_sync_employee AS
SELECT
    emp_id,
    emp_no,
    emp_name,
    gender,
    CASE WHEN gender = 1 THEN '男' ELSE '女' END AS gender_name,
    birth_date,
    FLOOR(DATEDIFF(CURRENT_DATE, birth_date) / 365) AS age,
    id_card,
    phone,
    email,
    department,
    position,
    salary AS current_salary,
    hire_date,
    resign_date,
    FLOOR(DATEDIFF(CURRENT_DATE, hire_date) / 365) AS work_years,
    status,
    CASE status
        WHEN 0 THEN '离职'
        WHEN 1 THEN '在职'
        WHEN 2 THEN '试用'
        ELSE '未知'
    END AS status_name,
    education,
    CASE education
        WHEN '高中' THEN 1
        WHEN '大专' THEN 2
        WHEN '本科' THEN 3
        WHEN '硕士' THEN 4
        WHEN '博士' THEN 5
        ELSE 0
    END AS education_level,
    create_time,
    update_time
FROM employee
WHERE deleted = 0;

-- ============================================================================
-- 6. 常用分析查询示例
-- ============================================================================

-- ============================================================================
-- 6.1 员工流失率分析
-- ============================================================================
-- SELECT
--     department,
--     COUNT(*) AS total_employees,
--     SUM(CASE WHEN status = 0 THEN 1 ELSE 0 END) AS resigned_count,
--     CONCAT(ROUND(SUM(CASE WHEN status = 0 THEN 1 ELSE 0 END) * 100.0 / COUNT(*), 2), '%') AS turnover_rate
-- FROM dim_employee
-- WHERE dt = '20240120'
-- GROUP BY department;

-- ============================================================================
-- 6.2 部门平均薪资对比
-- ============================================================================
-- SELECT
--     department,
--     COUNT(*) AS employee_count,
--     ROUND(AVG(current_salary), 2) AS avg_salary,
--     ROUND(MIN(current_salary), 2) AS min_salary,
--     ROUND(MAX(current_salary), 2) AS max_salary,
--     ROUND(STDDEV(current_salary), 2) AS salary_stddev
-- FROM dim_employee
-- WHERE dt = '20240120' AND status = 1
-- GROUP BY department
-- ORDER BY avg_salary DESC;

-- ============================================================================
-- 6.3 员工绩效趋势分析
-- ============================================================================
-- SELECT
--     emp_no,
--     emp_name,
--     department,
--     year_quarter,
--     final_score,
--     performance_level,
--     LAG(final_score) OVER (PARTITION BY emp_id ORDER BY year_quarter) AS prev_score,
--     final_score - LAG(final_score) OVER (PARTITION BY emp_id ORDER BY year_quarter) AS score_change
-- FROM fact_performance
-- WHERE year = '2024'
-- ORDER BY emp_id, year_quarter;

-- ============================================================================
-- 6.4 部门人力成本分析
-- ============================================================================
-- SELECT
--     department,
--     year_month,
--     employee_count,
--     total_cost,
--     cost_per_employee,
--     LAG(total_cost) OVER (PARTITION BY department ORDER BY year_month) AS prev_cost,
--     ROUND((total_cost - LAG(total_cost) OVER (PARTITION BY department ORDER BY year_month)) * 100.0 / LAG(total_cost) OVER (PARTITION BY department ORDER BY year_month), 2) AS cost_growth_rate
-- FROM agg_department_monthly_cost
-- WHERE year = '2024'
-- ORDER BY department, year_month;

-- ============================================================================
-- 7. 数据质量检查函数
-- ============================================================================

-- 检查员工数据完整性
-- SELECT
--     '员工数据完整性检查' AS check_type,
--     COUNT(*) AS total_records,
--     SUM(CASE WHEN emp_no IS NULL THEN 1 ELSE 0 END) AS null_emp_no,
--     SUM(CASE WHEN emp_name IS NULL THEN 1 ELSE 0 END) AS null_emp_name,
--     SUM(CASE WHEN department IS NULL THEN 1 ELSE 0 END) AS null_department,
--     SUM(CASE WHEN position IS NULL THEN 1 ELSE 0 END) AS null_position,
--     SUM(CASE WHEN phone IS NULL THEN 1 ELSE 0 END) AS null_phone,
--     SUM(CASE WHEN email IS NULL THEN 1 ELSE 0 END) AS null_email
-- FROM dim_employee
-- WHERE dt = '20240120';

-- ============================================================================
-- 8. 表结构信息查询
-- ============================================================================

-- 显示所有表
SHOW TABLES;

-- 显示表结构
DESCRIBE dim_employee;

-- 显示分区信息
SHOW PARTITIONS dim_employee;

-- ============================================================================
-- 9. 数据统计信息
-- ============================================================================

-- 统计各表的记录数
SELECT
    'dim_employee' AS table_name,
    COUNT(*) AS record_count
FROM dim_employee
WHERE dt = '20240120'
UNION ALL
SELECT
    'dim_department' AS table_name,
    COUNT(*) AS record_count
FROM dim_department
WHERE dt = '20240120'
UNION ALL
SELECT
    'dim_position' AS table_name,
    COUNT(*) AS record_count
FROM dim_position
WHERE dt = '20240120'
UNION ALL
SELECT
    'dim_time' AS table_name,
    COUNT(*) AS record_count
FROM dim_time;

-- ============================================================================
-- 10. 初始化完成提示
-- ============================================================================
SELECT 'Hive数据仓库初始化完成!' AS '状态';

-- ============================================================================
-- 说明:
-- 1. 本脚本采用星型模型设计，包含4个维度表和4个事实表
-- 2. 所有表使用ORC存储格式和SNAPPY压缩，提高查询性能
-- 3. 事实表采用分区存储，按时间维度进行分区
-- 4. 提供了聚合表用于快速查询汇总数据
-- 5. 包含了常用的分析查询示例
-- 6. 数据从MySQL业务数据库同步到Hive数据仓库
-- 7. 建议定期执行数据同步和聚合计算任务
-- ============================================================================