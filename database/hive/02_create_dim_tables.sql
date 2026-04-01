-- =====================================================
-- Hive维度表创建脚本
-- 项目: 人力资源数据中心
-- 数据仓库: hr_datacenter_dw
-- 表类型: 维度表(Dimension Tables)
-- 创建时间: 2026-03-31
-- =====================================================

USE hr_datacenter_dw;

-- =====================================================
-- 1. dim_employee (员工维度表)
-- 用途: 存储员工维度信息,用于多维分析
-- =====================================================
CREATE TABLE IF NOT EXISTS dim_employee (
    emp_id BIGINT COMMENT '员工ID',
    emp_no STRING COMMENT '员工编号',
    emp_name STRING COMMENT '员工姓名',
    gender INT COMMENT '性别(0-女 1-男)',
    birth_date STRING COMMENT '出生日期',
    id_card STRING COMMENT '身份证号',
    phone STRING COMMENT '手机号码',
    email STRING COMMENT '邮箱',
    department STRING COMMENT '部门',
    position STRING COMMENT '职位',
    salary DECIMAL(10,2) COMMENT '薪资',
    hire_date STRING COMMENT '入职日期',
    resign_date STRING COMMENT '离职日期',
    status INT COMMENT '状态(0-离职 1-在职 2-试用)',
    education STRING COMMENT '学历',
    etl_time TIMESTAMP COMMENT 'ETL时间'
)
COMMENT '员工维度表'
STORED AS ORC
TBLPROPERTIES ('orc.compress'='SNAPPY');

-- =====================================================
-- 2. dim_department (部门维度表)
-- 用途: 存储部门维度信息
-- =====================================================
CREATE TABLE IF NOT EXISTS dim_department (
    dept_id BIGINT COMMENT '部门ID',
    dept_name STRING COMMENT '部门名称',
    dept_code STRING COMMENT '部门编码',
    parent_dept_id BIGINT COMMENT '上级部门ID',
    dept_level INT COMMENT '部门层级',
    manager_name STRING COMMENT '部门负责人',
    etl_time TIMESTAMP COMMENT 'ETL时间'
)
COMMENT '部门维度表'
STORED AS ORC
TBLPROPERTIES ('orc.compress'='SNAPPY');

-- =====================================================
-- 3. dim_date (日期维度表)
-- 用途: 存储日期维度信息,用于时间分析
-- =====================================================
CREATE TABLE IF NOT EXISTS dim_date (
    date_id INT COMMENT '日期ID(YYYYMMDD)',
    full_date STRING COMMENT '完整日期(YYYY-MM-DD)',
    year INT COMMENT '年',
    quarter INT COMMENT '季度',
    month INT COMMENT '月',
    week INT COMMENT '周',
    day INT COMMENT '日',
    day_of_week INT COMMENT '星期几(1-7)',
    day_of_year INT COMMENT '一年中的第几天',
    is_weekend INT COMMENT '是否周末(0-否 1-是)',
    is_holiday INT COMMENT '是否节假日(0-否 1-是)',
    etl_time TIMESTAMP COMMENT 'ETL时间'
)
COMMENT '日期维度表'
STORED AS ORC
TBLPROPERTIES ('orc.compress'='SNAPPY');

-- =====================================================
-- 4. dim_course (培训课程维度表)
-- 用途: 存储培训课程维度信息
-- =====================================================
CREATE TABLE IF NOT EXISTS dim_course (
    course_id BIGINT COMMENT '课程ID',
    course_name STRING COMMENT '课程名称',
    course_type INT COMMENT '课程类型(1-新员工 2-技能 3-管理 4-安全)',
    course_type_name STRING COMMENT '课程类型名称',
    instructor STRING COMMENT '培训讲师',
    duration INT COMMENT '培训时长(小时)',
    location STRING COMMENT '培训地点',
    etl_time TIMESTAMP COMMENT 'ETL时间'
)
COMMENT '培训课程维度表'
STORED AS ORC
TBLPROPERTIES ('orc.compress'='SNAPPY');

-- 输出创建结果
SELECT '维度表创建完成!' AS message;
