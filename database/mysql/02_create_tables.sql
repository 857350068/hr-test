-- =====================================================
-- MySQL建表脚本
-- 项目: 人力资源数据中心
-- 数据库: hr_datacenter
-- 表数量: 10张核心业务表
-- 创建时间: 2026-03-31
-- =====================================================

USE hr_datacenter;

-- =====================================================
-- 1. sys_user (用户表)
-- 用途: 存储系统用户信息,用于登录认证和权限管理
-- =====================================================
CREATE TABLE sys_user (
    user_id BIGINT PRIMARY KEY AUTO_INCREMENT COMMENT '用户ID',
    username VARCHAR(50) NOT NULL UNIQUE COMMENT '用户名',
    password VARCHAR(100) NOT NULL COMMENT '密码(BCrypt加密)',
    real_name VARCHAR(50) NOT NULL COMMENT '真实姓名',
    dept_id BIGINT COMMENT '部门ID',
    phone VARCHAR(20) COMMENT '手机号码',
    email VARCHAR(100) COMMENT '邮箱',
    status TINYINT NOT NULL DEFAULT 1 COMMENT '状态(0-禁用 1-启用)',
    last_login_time DATETIME COMMENT '最后登录时间',
    create_time DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',
    update_time DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT '更新时间',
    deleted TINYINT NOT NULL DEFAULT 0 COMMENT '删除标记(0-未删除 1-已删除)',
    INDEX idx_username (username),
    INDEX idx_dept_id (dept_id),
    INDEX idx_status (status)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COMMENT='用户表';

-- =====================================================
-- 2. employee (员工表)
-- 用途: 存储员工基本信息、工作信息、状态信息
-- =====================================================
CREATE TABLE employee (
    emp_id BIGINT PRIMARY KEY AUTO_INCREMENT COMMENT '员工ID',
    emp_no VARCHAR(20) NOT NULL UNIQUE COMMENT '员工编号',
    emp_name VARCHAR(50) NOT NULL COMMENT '员工姓名',
    gender TINYINT NOT NULL COMMENT '性别(0-女 1-男)',
    birth_date DATE NOT NULL COMMENT '出生日期',
    id_card VARCHAR(18) NOT NULL COMMENT '身份证号',
    phone VARCHAR(20) NOT NULL COMMENT '手机号码',
    email VARCHAR(100) COMMENT '邮箱',
    department VARCHAR(50) NOT NULL COMMENT '部门',
    position VARCHAR(50) NOT NULL COMMENT '职位',
    salary DECIMAL(10,2) NOT NULL COMMENT '薪资',
    hire_date DATE NOT NULL COMMENT '入职日期',
    resign_date DATE COMMENT '离职日期',
    status TINYINT NOT NULL DEFAULT 1 COMMENT '状态(0-离职 1-在职 2-试用)',
    education VARCHAR(20) COMMENT '学历',
    create_time DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',
    update_time DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT '更新时间',
    deleted TINYINT NOT NULL DEFAULT 0 COMMENT '删除标记',
    INDEX idx_emp_no (emp_no),
    INDEX idx_department (department),
    INDEX idx_status (status),
    INDEX idx_hire_date (hire_date)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COMMENT='员工表';

-- =====================================================
-- 3. attendance (考勤记录表)
-- 用途: 存储员工每日考勤打卡记录
-- =====================================================
CREATE TABLE attendance (
    attendance_id BIGINT PRIMARY KEY AUTO_INCREMENT COMMENT '考勤ID',
    emp_id BIGINT NOT NULL COMMENT '员工ID',
    attendance_date DATE NOT NULL COMMENT '考勤日期',
    clock_in_time TIME COMMENT '上班打卡时间',
    clock_out_time TIME COMMENT '下班打卡时间',
    attendance_type TINYINT NOT NULL COMMENT '考勤类型(0-正常 1-迟到 2-早退 3-旷工 4-请假 5-加班)',
    attendance_status TINYINT NOT NULL COMMENT '考勤状态(0-未打卡 1-已打卡 2-请假 3-加班)',
    work_duration INT COMMENT '工作时长(分钟)',
    remark VARCHAR(500) COMMENT '备注',
    create_time DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',
    update_time DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT '更新时间',
    deleted TINYINT NOT NULL DEFAULT 0 COMMENT '删除标记',
    UNIQUE KEY uk_emp_date (emp_id, attendance_date),
    INDEX idx_attendance_date (attendance_date),
    INDEX idx_emp_date (emp_id, attendance_date),
    INDEX idx_attendance_type (attendance_type)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COMMENT='考勤记录表';

-- =====================================================
-- 4. leave (请假记录表)
-- 用途: 存储员工请假申请和审批记录
-- =====================================================
CREATE TABLE `leave` (
    leave_id BIGINT PRIMARY KEY AUTO_INCREMENT COMMENT '请假ID',
    emp_id BIGINT NOT NULL COMMENT '员工ID',
    leave_type TINYINT NOT NULL COMMENT '请假类型(0-事假 1-病假 2-年假 3-婚假 4-产假 5-丧假 6-其他)',
    start_time DATETIME NOT NULL COMMENT '请假开始时间',
    end_time DATETIME NOT NULL COMMENT '请假结束时间',
    leave_duration INT NOT NULL COMMENT '请假时长(小时)',
    reason TEXT NOT NULL COMMENT '请假原因',
    approver_id BIGINT NOT NULL COMMENT '审批人ID',
    approval_status TINYINT NOT NULL DEFAULT 0 COMMENT '审批状态(0-待审批 1-已同意 2-已拒绝 3-已撤回)',
    approval_comment TEXT COMMENT '审批意见',
    approval_time DATETIME COMMENT '审批时间',
    attachment VARCHAR(500) COMMENT '附件路径',
    create_time DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',
    update_time DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT '更新时间',
    deleted TINYINT NOT NULL DEFAULT 0 COMMENT '删除标记',
    INDEX idx_emp_id (emp_id),
    INDEX idx_approver_id (approver_id),
    INDEX idx_start_time (start_time),
    INDEX idx_approval_status (approval_status),
    INDEX idx_approval_time (approval_time)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COMMENT='请假记录表';

-- =====================================================
-- 5. performance_goal (绩效目标表)
-- 用途: 存储员工绩效目标设定
-- =====================================================
CREATE TABLE performance_goal (
    goal_id BIGINT PRIMARY KEY AUTO_INCREMENT COMMENT '目标ID',
    emp_id BIGINT NOT NULL COMMENT '员工ID',
    year INT NOT NULL COMMENT '评估年度',
    period_type TINYINT NOT NULL COMMENT '评估周期(1-年度 2-季度 3-月度)',
    goal_description VARCHAR(500) NOT NULL COMMENT '目标描述',
    weight INT NOT NULL COMMENT '权重(百分比)',
    completion_standard VARCHAR(500) NOT NULL COMMENT '完成标准',
    goal_status TINYINT NOT NULL DEFAULT 0 COMMENT '目标状态(0-草稿 1-进行中 2-已完成)',
    create_time DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',
    update_time DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT '更新时间',
    deleted TINYINT NOT NULL DEFAULT 0 COMMENT '删除标记',
    INDEX idx_emp_year_period (emp_id, year, period_type),
    INDEX idx_goal_status (goal_status)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COMMENT='绩效目标表';

-- =====================================================
-- 6. performance_evaluation (绩效评估表)
-- 用途: 存储员工绩效评估结果
-- =====================================================
CREATE TABLE performance_evaluation (
    evaluation_id BIGINT PRIMARY KEY AUTO_INCREMENT COMMENT '评估ID',
    emp_id BIGINT NOT NULL COMMENT '员工ID',
    year INT NOT NULL COMMENT '评估年度',
    period_type TINYINT NOT NULL COMMENT '评估周期(1-年度 2-季度 3-月度)',
    quarter INT COMMENT '季度(季度评估时使用)',
    month INT COMMENT '月份(月度评估时使用)',
    self_score DECIMAL(5,2) NOT NULL COMMENT '自评分',
    self_comment TEXT COMMENT '自评说明',
    supervisor_score DECIMAL(5,2) COMMENT '上级评分',
    supervisor_comment TEXT COMMENT '上级评价意见',
    final_score DECIMAL(5,2) COMMENT '综合评分',
    performance_level CHAR(1) COMMENT '绩效等级(S/A/B/C/D)',
    improvement_plan TEXT COMMENT '改进建议',
    interview_record TEXT COMMENT '面谈记录',
    interview_date DATETIME COMMENT '面谈时间',
    evaluation_status TINYINT NOT NULL DEFAULT 0 COMMENT '评估状态(0-未评估 1-已自评 2-已评价 3-已完成)',
    create_time DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',
    update_time DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT '更新时间',
    deleted TINYINT NOT NULL DEFAULT 0 COMMENT '删除标记',
    INDEX idx_emp_year_period (emp_id, year, period_type),
    INDEX idx_performance_level (performance_level),
    INDEX idx_evaluation_status (evaluation_status),
    INDEX idx_interview_date (interview_date)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COMMENT='绩效评估表';

-- =====================================================
-- 7. salary_payment (薪资发放表)
-- 用途: 存储员工每月薪资发放明细
-- =====================================================
CREATE TABLE salary_payment (
    payment_id BIGINT PRIMARY KEY AUTO_INCREMENT COMMENT '发放ID',
    emp_id BIGINT NOT NULL COMMENT '员工ID',
    year INT NOT NULL COMMENT '发放年度',
    month INT NOT NULL COMMENT '发放月份',
    basic_salary DECIMAL(10,2) NOT NULL COMMENT '基本工资',
    performance_salary DECIMAL(10,2) NOT NULL DEFAULT 0 COMMENT '绩效工资',
    position_allowance DECIMAL(10,2) NOT NULL DEFAULT 0 COMMENT '岗位津贴',
    transport_allowance DECIMAL(10,2) NOT NULL DEFAULT 0 COMMENT '交通补贴',
    communication_allowance DECIMAL(10,2) NOT NULL DEFAULT 0 COMMENT '通讯补贴',
    meal_allowance DECIMAL(10,2) NOT NULL DEFAULT 0 COMMENT '餐补',
    other_allowance DECIMAL(10,2) NOT NULL DEFAULT 0 COMMENT '其他补贴',
    overtime_pay DECIMAL(10,2) NOT NULL DEFAULT 0 COMMENT '加班费',
    total_gross_salary DECIMAL(10,2) NOT NULL COMMENT '应发工资总额',
    social_insurance DECIMAL(10,2) NOT NULL DEFAULT 0 COMMENT '社保个人部分',
    housing_fund DECIMAL(10,2) NOT NULL DEFAULT 0 COMMENT '公积金个人部分',
    income_tax DECIMAL(10,2) NOT NULL DEFAULT 0 COMMENT '个人所得税',
    other_deduction DECIMAL(10,2) NOT NULL DEFAULT 0 COMMENT '其他扣款',
    total_net_salary DECIMAL(10,2) NOT NULL COMMENT '实发工资总额',
    payment_status TINYINT NOT NULL DEFAULT 0 COMMENT '发放状态(0-未发放 1-已发放)',
    payment_date DATETIME COMMENT '发放时间',
    remark VARCHAR(500) COMMENT '备注',
    create_time DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',
    update_time DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT '更新时间',
    deleted TINYINT NOT NULL DEFAULT 0 COMMENT '删除标记',
    INDEX idx_emp_year_month (emp_id, year, month),
    INDEX idx_year_month (year, month),
    INDEX idx_payment_status (payment_status)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COMMENT='薪资发放表';

-- =====================================================
-- 8. salary_adjustment (薪资调整表)
-- 用途: 存储员工薪资调整记录
-- =====================================================
CREATE TABLE salary_adjustment (
    adjustment_id BIGINT PRIMARY KEY AUTO_INCREMENT COMMENT '调整ID',
    emp_id BIGINT NOT NULL COMMENT '员工ID',
    adjustment_type TINYINT NOT NULL COMMENT '调整类型(1-晋升 2-降职 3-调薪 4-转正)',
    before_salary DECIMAL(10,2) NOT NULL COMMENT '调整前工资',
    after_salary DECIMAL(10,2) NOT NULL COMMENT '调整后工资',
    adjustment_rate DECIMAL(5,2) COMMENT '调整幅度(%)',
    effective_date DATETIME NOT NULL COMMENT '生效日期',
    reason TEXT COMMENT '调整原因',
    approver_id BIGINT NOT NULL COMMENT '审批人ID',
    approval_status TINYINT NOT NULL DEFAULT 0 COMMENT '审批状态(0-待审批 1-已同意 2-已拒绝)',
    approval_comment TEXT COMMENT '审批意见',
    approval_date DATETIME COMMENT '审批时间',
    creator_id BIGINT COMMENT '创建人ID',
    create_time DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',
    update_time DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT '更新时间',
    deleted TINYINT NOT NULL DEFAULT 0 COMMENT '删除标记',
    INDEX idx_emp_id (emp_id),
    INDEX idx_effective_date (effective_date),
    INDEX idx_adjustment_type (adjustment_type),
    INDEX idx_approval_date (approval_date),
    INDEX idx_creator_id (creator_id)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COMMENT='薪资调整表';

-- =====================================================
-- 9. training_course (培训课程表)
-- 用途: 存储企业培训课程信息
-- =====================================================
CREATE TABLE training_course (
    course_id BIGINT PRIMARY KEY AUTO_INCREMENT COMMENT '课程ID',
    course_name VARCHAR(100) NOT NULL COMMENT '课程名称',
    course_type TINYINT NOT NULL COMMENT '课程类型(1-新员工培训 2-技能培训 3-管理培训 4-安全培训 5-其他)',
    course_description VARCHAR(500) COMMENT '课程描述',
    instructor VARCHAR(50) NOT NULL COMMENT '培训讲师',
    duration INT NOT NULL COMMENT '培训时长(小时)',
    location VARCHAR(100) NOT NULL COMMENT '培训地点',
    start_date DATETIME NOT NULL COMMENT '培训开始时间',
    end_date DATETIME NOT NULL COMMENT '培训结束时间',
    capacity INT NOT NULL COMMENT '培训名额',
    enrolled_count INT NOT NULL DEFAULT 0 COMMENT '已报名人数',
    course_status TINYINT NOT NULL DEFAULT 0 COMMENT '课程状态(0-未开始 1-进行中 2-已结束)',
    create_time DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',
    update_time DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT '更新时间',
    deleted TINYINT NOT NULL DEFAULT 0 COMMENT '删除标记',
    INDEX idx_course_type (course_type),
    INDEX idx_start_date (start_date),
    INDEX idx_course_status (course_status)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COMMENT='培训课程表';

-- =====================================================
-- 10. training_enrollment (培训报名表)
-- 用途: 存储员工培训报名记录
-- =====================================================
CREATE TABLE training_enrollment (
    enrollment_id BIGINT PRIMARY KEY AUTO_INCREMENT COMMENT '报名ID',
    course_id BIGINT NOT NULL COMMENT '课程ID',
    emp_id BIGINT NOT NULL COMMENT '员工ID',
    enrollment_time DATETIME NOT NULL COMMENT '报名时间',
    approval_status TINYINT NOT NULL DEFAULT 0 COMMENT '审核状态(0-待审核 1-已通过 2-已拒绝)',
    approver_id BIGINT COMMENT '审核人ID',
    attendance_status TINYINT NOT NULL DEFAULT 0 COMMENT '出勤状态(0-未出勤 1-已出勤 2-请假)',
    score INT COMMENT '培训成绩',
    feedback TEXT COMMENT '培训反馈',
    create_time DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',
    update_time DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT '更新时间',
    deleted TINYINT NOT NULL DEFAULT 0 COMMENT '删除标记',
    UNIQUE KEY uk_course_emp (course_id, emp_id),
    INDEX idx_course_id (course_id),
    INDEX idx_emp_id (emp_id),
    INDEX idx_approval_status (approval_status),
    INDEX idx_approver_id (approver_id)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COMMENT='培训报名表';

-- =====================================================
-- 输出创建结果
-- =====================================================
SELECT '======================================' AS '';
SELECT 'MySQL数据表创建完成!' AS message;
SELECT '======================================' AS '';
SELECT
    TABLE_NAME AS 表名,
    TABLE_COMMENT AS 表说明,
    TABLE_ROWS AS 数据行数
FROM information_schema.TABLES
WHERE TABLE_SCHEMA = 'hr_datacenter'
ORDER BY TABLE_NAME;
