-- =====================================================
-- 人力资源数据中心 - MySQL数据库统一初始化脚本
-- 项目: HrDataCenter
-- 数据库: hr_datacenter
-- 版本: v2.0
-- 创建时间: 2026-04-07
-- 功能: 完整的数据库初始化，包含建库、建表、索引和测试数据
-- =====================================================

SET NAMES utf8mb4;
SET CHARACTER SET utf8mb4;

-- =====================================================
-- 第一步: 创建数据库
-- =====================================================
DROP DATABASE IF EXISTS hr_datacenter;
CREATE DATABASE hr_datacenter
    DEFAULT CHARACTER SET utf8mb4
    DEFAULT COLLATE utf8mb4_unicode_ci;

USE hr_datacenter;

SELECT '======================================' AS '';
SELECT '数据库 hr_datacenter 创建成功!' AS message;
SELECT '======================================' AS '';

-- =====================================================
-- 第二步: 创建业务表
-- =====================================================

-- 1. sys_user (用户表)
-- 用途: 存储系统用户信息,用于登录认证和权限管理
CREATE TABLE sys_user (
    user_id BIGINT PRIMARY KEY AUTO_INCREMENT COMMENT '用户ID',
    username VARCHAR(50) NOT NULL UNIQUE COMMENT '用户名',
    password VARCHAR(100) NOT NULL COMMENT '密码(BCrypt加密)',
    real_name VARCHAR(50) NOT NULL COMMENT '真实姓名',
    dept_id BIGINT COMMENT '部门ID',
    phone VARCHAR(20) COMMENT '手机号码',
    email VARCHAR(100) COMMENT '邮箱',
    role_id BIGINT COMMENT '角色ID',
    status TINYINT NOT NULL DEFAULT 1 COMMENT '状态(0-禁用 1-启用)',
    avatar VARCHAR(255) COMMENT '头像URL',
    last_login_time DATETIME COMMENT '最后登录时间',
    last_login_ip VARCHAR(50) COMMENT '最后登录IP',
    create_time DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',
    update_time DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT '更新时间',
    create_by VARCHAR(50) COMMENT '创建人',
    update_by VARCHAR(50) COMMENT '更新人',
    remark VARCHAR(500) COMMENT '备注',
    deleted TINYINT NOT NULL DEFAULT 0 COMMENT '删除标记(0-未删除 1-已删除)',
    INDEX idx_username (username),
    INDEX idx_dept_id (dept_id),
    INDEX idx_role_id (role_id),
    INDEX idx_status (status)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COMMENT='用户表';

-- 2. sys_role (角色表)
-- 用途: 存储系统角色信息
CREATE TABLE sys_role (
    role_id BIGINT PRIMARY KEY AUTO_INCREMENT COMMENT '角色ID',
    role_name VARCHAR(50) NOT NULL COMMENT '角色名称',
    role_code VARCHAR(50) NOT NULL UNIQUE COMMENT '角色编码',
    role_desc VARCHAR(200) COMMENT '角色描述',
    status TINYINT NOT NULL DEFAULT 1 COMMENT '状态(0-禁用 1-启用)',
    create_time DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',
    update_time DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT '更新时间',
    create_by VARCHAR(50) COMMENT '创建人',
    update_by VARCHAR(50) COMMENT '更新人',
    remark VARCHAR(500) COMMENT '备注',
    INDEX idx_role_code (role_code),
    INDEX idx_status (status)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COMMENT='角色表';

-- 3. employee (员工表)
-- 用途: 存储员工基本信息、工作信息、状态信息
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
    position_id BIGINT COMMENT '职位ID',
    job_level VARCHAR(20) COMMENT '职级',
    salary DECIMAL(10,2) NOT NULL COMMENT '薪资',
    hire_date DATE NOT NULL COMMENT '入职日期',
    leave_date DATE COMMENT '离职日期',
    status TINYINT NOT NULL DEFAULT 1 COMMENT '状态(0-离职 1-在职 2-试用)',
    education VARCHAR(20) COMMENT '学历',
    school VARCHAR(100) COMMENT '毕业院校',
    major VARCHAR(100) COMMENT '专业',
    work_years INT NOT NULL DEFAULT 0 COMMENT '工作年限',
    address VARCHAR(200) COMMENT '居住地址',
    emergency_contact VARCHAR(50) COMMENT '紧急联系人',
    emergency_phone VARCHAR(20) COMMENT '紧急联系电话',
    create_time DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',
    update_time DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT '更新时间',
    create_by VARCHAR(50) COMMENT '创建人',
    update_by VARCHAR(50) COMMENT '更新人',
    remark VARCHAR(500) COMMENT '备注',
    deleted TINYINT NOT NULL DEFAULT 0 COMMENT '删除标记',
    INDEX idx_emp_no (emp_no),
    idx_department (department),
    idx_position_id (position_id),
    idx_status (status),
    idx_hire_date (hire_date)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COMMENT='员工表';

-- 4. attendance (考勤记录表)
-- 用途: 存储员工每日考勤打卡记录
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
    idx_emp_date (emp_id, attendance_date),
    idx_attendance_type (attendance_type)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COMMENT='考勤记录表';

-- 5. leave (请假记录表)
-- 用途: 存储员工请假申请和审批记录
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
    idx_approver_id (approver_id),
    idx_start_time (start_time),
    idx_approval_status (approval_status),
    idx_approval_time (approval_time)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COMMENT='请假记录表';

-- 6. performance_goal (绩效目标表)
-- 用途: 存储员工绩效目标设定
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

-- 7. performance_evaluation (绩效评估表)
-- 用途: 存储员工绩效评估结果
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
    idx_interview_date (interview_date)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COMMENT='绩效评估表';

-- 8. salary_payment (薪资发放表)
-- 用途: 存储员工每月薪资发放明细
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

-- 9. salary_adjustment (薪资调整表)
-- 用途: 存储员工薪资调整记录
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
    idx_effective_date (effective_date),
    idx_adjustment_type (adjustment_type),
    idx_approval_date (approval_date),
    INDEX idx_creator_id (creator_id)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COMMENT='薪资调整表';

-- 10. training_course (培训课程表)
-- 用途: 存储企业培训课程信息
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
    idx_start_date (start_date),
    idx_course_status (course_status)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COMMENT='培训课程表';

-- 11. training_enrollment (培训报名表)
-- 用途: 存储员工培训报名记录
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
    idx_emp_id (emp_id),
    INDEX idx_approval_status (approval_status),
    INDEX idx_approver_id (approver_id)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COMMENT='培训报名表';

-- 12. data_category (数据分类表)
-- 用途: 存储数据分析分类信息
CREATE TABLE data_category (
    category_id BIGINT PRIMARY KEY AUTO_INCREMENT COMMENT '分类ID',
    category_name VARCHAR(50) NOT NULL COMMENT '分类名称',
    category_code VARCHAR(50) NOT NULL UNIQUE COMMENT '分类编码',
    parent_id BIGINT NOT NULL DEFAULT 0 COMMENT '父分类ID',
    icon VARCHAR(50) COMMENT '图标',
    description VARCHAR(200) COMMENT '分类描述',
    sort_order INT NOT NULL DEFAULT 0 COMMENT '排序序号',
    status TINYINT NOT NULL DEFAULT 1 COMMENT '状态(0-禁用 1-启用)',
    create_time DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',
    update_time DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT '更新时间',
    create_by VARCHAR(50) COMMENT '创建人',
    update_by VARCHAR(50) COMMENT '更新人',
    remark VARCHAR(500) COMMENT '备注',
    deleted TINYINT NOT NULL DEFAULT 0 COMMENT '删除标记',
    UNIQUE KEY uk_category_code (category_code),
    INDEX idx_parent_id (parent_id),
    INDEX idx_status (status)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COMMENT='数据分类表';

-- 13. sys_operation_log (操作日志表)
-- 用途: 记录用户操作日志
CREATE TABLE sys_operation_log (
    log_id BIGINT PRIMARY KEY AUTO_INCREMENT COMMENT '日志ID',
    user_id BIGINT COMMENT '用户ID',
    username VARCHAR(50) COMMENT '用户名',
    module VARCHAR(50) COMMENT '模块名',
    type VARCHAR(20) COMMENT '操作类型',
    description VARCHAR(200) COMMENT '操作描述',
    request_method VARCHAR(10) COMMENT '请求方法',
    request_url VARCHAR(500) COMMENT '请求URL',
    request_ip VARCHAR(50) COMMENT '请求IP',
    request_params TEXT COMMENT '请求参数',
    response_data TEXT COMMENT '响应数据',
    status TINYINT NOT NULL DEFAULT 1 COMMENT '状态(0-失败 1-成功)',
    error_message TEXT COMMENT '错误信息',
    execution_time INT COMMENT '执行时长(毫秒)',
    create_time DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',
    INDEX idx_user_id (user_id),
    idx_module (module),
    idx_type (type),
    idx_create_time (create_time)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COMMENT='操作日志表';

-- 14. message (消息表)
-- 用途: 存储系统消息通知
CREATE TABLE message (
    message_id BIGINT PRIMARY KEY AUTO_INCREMENT COMMENT '消息ID',
    title VARCHAR(200) NOT NULL COMMENT '消息标题',
    content TEXT NOT NULL COMMENT '消息内容',
    message_type TINYINT NOT NULL COMMENT '消息类型(0-系统通知 1-业务通知)',
    receiver_id BIGINT COMMENT '接收人ID',
    sender_id BIGINT COMMENT '发送人ID',
    is_read TINYINT NOT NULL DEFAULT 0 COMMENT '是否已读(0-未读 1-已读)',
    read_time DATETIME COMMENT '阅读时间',
    create_time DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',
    deleted TINYINT NOT NULL DEFAULT 0 COMMENT '删除标记',
    INDEX idx_receiver_id (receiver_id),
    idx_is_read (is_read),
    idx_create_time (create_time)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COMMENT='消息表';

-- =====================================================
-- 第三步: 创建索引
-- =====================================================

-- 员工表索引
ALTER TABLE employee ADD INDEX idx_emp_name (emp_name);

-- 考勤表索引
ALTER TABLE attendance ADD INDEX idx_clock_in_time (clock_in_time);

-- 请假表索引
ALTER TABLE `leave` ADD INDEX idx_end_time (end_time);

-- 绩效目标表索引
ALTER TABLE performance_goal ADD INDEX idx_year (year);
ALTER TABLE performance_goal ADD INDEX idx_period_type (period_type);

-- 绩效评估表索引
ALTER TABLE performance_evaluation ADD INDEX idx_quarter (quarter);
ALTER TABLE performance_evaluation ADD INDEX idx_month (month);

-- 薪资发放表索引
ALTER TABLE salary_payment ADD INDEX idx_basic_salary (basic_salary);
ALTER TABLE salary_payment ADD INDEX idx_total_gross_salary (total_gross_salary);

-- 薪资调整表索引
ALTER TABLE salary_adjustment ADD INDEX idx_before_salary (before_salary);
ALTER TABLE salary_adjustment ADD INDEX idx_after_salary (after_salary);

-- 培训课程表索引
ALTER TABLE training_course ADD INDEX idx_course_name (course_name);
ALTER TABLE training_course ADD INDEX idx_instructor (instructor);

-- 培训报名表索引
ALTER TABLE training_enrollment ADD INDEX idx_enrollment_time (enrollment_time);

-- 数据分类表索引
ALTER TABLE data_category ADD INDEX idx_category_name (category_name);

-- 消息表索引
ALTER TABLE message ADD INDEX idx_title (title);

SELECT '======================================' AS '';
SELECT 'MySQL数据表和索引创建完成!' AS message;
SELECT '======================================' AS '';

-- =====================================================
-- 第四步: 插入测试数据
-- =====================================================

-- =====================================================
-- 4.1 插入角色数据
-- =====================================================
INSERT INTO sys_role (role_name, role_code, role_desc, status) VALUES
('系统管理员', 'ADMIN', '系统管理员，拥有所有权限', 1),
('HR管理员', 'HR_ADMIN', 'HR管理员，负责人力资源管理', 1),
('部门负责人', 'DEPT_MANAGER', '部门负责人，管理本部门数据', 1),
('企业管理层', 'COMPANY_MANAGER', '企业管理层，查看全局数据', 1),
('普通员工', 'EMPLOYEE', '普通员工，查看个人数据', 1);

SELECT '======================================' AS '';
SELECT '角色数据插入完成!' AS message;
SELECT '======================================' AS '';

-- =====================================================
-- 4.2 插入数据分类数据
-- =====================================================
INSERT INTO data_category (category_name, category_code, parent_id, description, sort_order, status) VALUES
('组织效能类', 'ORG_EFFICIENCY', 0, '组织效能相关数据分析', 1, 1),
('人才梯队类', 'TALENT_PIPELINE', 0, '人才梯队建设相关数据', 2, 1),
('薪酬福利类', 'SALARY_BENEFIT', 0, '薪酬福利分析数据', 3, 1),
('绩效管理类', 'PERFORMANCE', 0, '绩效管理相关数据', 4, 1),
('培训发展类', 'TRAINING', 0, '培训发展相关数据', 5, 1),
('成本管控类', 'COST_CONTROL', 0, '人力成本管控数据', 6, 1),
('流失预警类', 'TURNOVER_WARNING', 0, '员工流失预警数据', 7, 1),
('招聘效能类', 'RECRUITMENT', 0, '招聘效能分析数据', 8, 1),
('员工满意度类', 'SATISFACTION', 0, '员工满意度调查数据', 9, 1),
('合规审计类', 'COMPLIANCE', 0, '合规审计相关数据', 10, 1);

SELECT '======================================' AS '';
SELECT '数据分类数据插入完成!' AS message;
SELECT '======================================' AS '';

-- =====================================================
-- 4.3 插入用户数据
-- 密码说明: 使用BCrypt加密,原始密码为123456
-- =====================================================
INSERT INTO sys_user (username, password, real_name, dept_id, phone, email, role_id, status) VALUES
('admin', '$2a$10$N.zmdr9k7uOCbU2gU1G3eOGoZ7v8wJ6xH5mK4lP3qR2sT1uV0wXyZ', '系统管理员', 1, '13800138000', 'admin@hrdatacenter.com', 1, 1),
('hr001', '$2a$10$N.zmdr9k7uOCbU2gU1G3eOGoZ7v8wJ6xH5mK4lP3qR2sT1uV0wXyZ', '张三', 2, '13800138001', 'hr001@hrdatacenter.com', 2, 1),
('manager001', '$2a$10$N.zmdr9k7uOCbU2gU1G3eOGoZ7v8wJ6xH5mK4lP3qR2sT1uV0wXyZ', '李四', 3, '13800138002', 'manager001@hrdatacenter.com', 3, 1);

SELECT '======================================' AS '';
SELECT '用户数据插入完成!' AS message;
SELECT '======================================' AS '';

-- =====================================================
-- 4.4 插入员工数据 (50条测试数据)
-- =====================================================

-- 技术部员工(15人)
INSERT INTO employee (emp_no, emp_name, gender, birth_date, id_card, phone, email, department, position, salary, hire_date, status, education, work_years) VALUES
('EMP00000001', '张伟', 1, '1990-05-15', '110101199005150011', '13900000001', 'zhangwei@company.com', '技术部', '技术总监', 35000.00, '2018-03-01', 1, '硕士', 6),
('EMP00000002', '李娜', 0, '1992-08-20', '110101199208200022', '13900000002', 'lina@company.com', '技术部', '高级工程师', 25000.00, '2019-06-15', 1, '本科', 5),
('EMP00000003', '王强', 1, '1991-03-10', '110101199103100033', '13900000003', 'wangqiang@company.com', '技术部', '高级工程师', 24000.00, '2019-07-01', 1, '本科', 5),
('EMP00000004', '刘洋', 1, '1993-11-25', '110101199311250044', '13900000004', 'liuyang@company.com', '技术部', '中级工程师', 18000.00, '2020-01-10', 1, '本科', 4),
('EMP00000005', '陈静', 0, '1994-02-18', '110101199402180055', '13900000005', 'chenjing@company.com', '技术部', '中级工程师', 17500.00, '2020-03-15', 1, '本科', 4),
('EMP00000006', '杨帆', 1, '1995-07-30', '110101199507300066', '13900000006', 'yangfan@company.com', '技术部', '初级工程师', 12000.00, '2021-06-01', 1, '本科', 3),
('EMP00000007', '赵敏', 0, '1996-09-12', '110101199609120077', '13900000007', 'zhaomin@company.com', '技术部', '初级工程师', 11500.00, '2021-07-15', 1, '本科', 3),
('EMP00000008', '周杰', 1, '1997-01-05', '110101199701050088', '13900000008', 'zhoujie@company.com', '技术部', '实习生', 6000.00, '2024-01-01', 2, '本科', 0),
('EMP00000009', '吴昊', 1, '1988-12-20', '110101198812200099', '13900000009', 'wuhao@company.com', '技术部', '架构师', 40000.00, '2017-01-15', 1, '博士', 7),
('EMP00000010', '郑丽', 0, '1993-04-08', '110101199304080010', '13900000010', 'zhengli@company.com', '技术部', '测试工程师', 16000.00, '2020-05-20', 1, '本科', 4),
('EMP00000011', '孙磊', 1, '1992-06-15', '110101199206150011', '13900000011', 'sunlei@company.com', '技术部', '运维工程师', 17000.00, '2019-11-01', 1, '本科', 5),
('EMP00000012', '马芳', 0, '1994-10-22', '110101199410220012', '13900000012', 'mafang@company.com', '技术部', 'UI设计师', 15000.00, '2020-08-10', 1, '本科', 4),
('EMP00000013', '朱涛', 1, '1995-03-28', '110101199503280013', '13900000013', 'zhutao@company.com', '技术部', '前端工程师', 16500.00, '2020-10-15', 1, '本科', 4),
('EMP00000014', '胡婷', 0, '1996-08-14', '110101199608140014', '13900000014', 'huting@company.com', '技术部', '前端工程师', 16000.00, '2021-01-20', 1, '本科', 3),
('EMP00000015', '高明', 1, '1997-12-03', '110101199712030015', '13900000015', 'gaoming@company.com', '技术部', '实习生', 5500.00, '2024-02-01', 2, '本科', 0);

-- 人事部员工(10人)
INSERT INTO employee (emp_no, emp_name, gender, birth_date, id_card, phone, email, department, position, salary, hire_date, status, education, work_years) VALUES
('EMP00000016', '林晓', 0, '1985-09-18', '110101198509180016', '13900000016', 'linxiao@company.com', '人事部', '人事总监', 30000.00, '2016-05-01', 1, '硕士', 8),
('EMP00000017', '何军', 1, '1989-02-25', '110101198902250017', '13900000017', 'hejun@company.com', '人事部', '招聘经理', 20000.00, '2018-08-15', 1, '本科', 6),
('EMP00000018', '郭燕', 0, '1991-07-10', '110101199107100018', '13900000018', 'guoyan@company.com', '人事部', '培训主管', 18000.00, '2019-03-20', 1, '本科', 5),
('EMP00000019', '罗辉', 1, '1992-11-30', '110101199211300019', '13900000019', 'luohui@company.com', '人事部', '薪酬专员', 14000.00, '2020-01-15', 1, '本科', 4),
('EMP00000020', '梁萍', 0, '1993-05-16', '110101199305160020', '13900000020', 'liangping@company.com', '人事部', '招聘专员', 12000.00, '2020-06-01', 1, '本科', 4),
('EMP00000021', '宋波', 1, '1994-09-08', '110101199409080021', '13900000021', 'songbo@company.com', '人事部', '人事专员', 11000.00, '2021-02-10', 1, '本科', 3),
('EMP00000022', '唐雪', 0, '1995-12-22', '110101199512220022', '13900000022', 'tangxue@company.com', '人事部', '人事专员', 10500.00, '2021-05-15', 1, '本科', 3),
('EMP00000023', '许鹏', 1, '1996-04-14', '110101199604140023', '13900000023', 'xupeng@company.com', '人事部', '实习生', 5000.00, '2024-01-15', 2, '本科', 0),
('EMP00000024', '韩梅', 0, '1990-01-28', '110101199001280024', '13900000024', 'hanmei@company.com', '人事部', '绩效主管', 16000.00, '2019-09-01', 1, '本科', 5),
('EMP00000025', '冯刚', 1, '1993-08-05', '110101199308050025', '13900000025', 'fenggang@company.com', '人事部', '员工关系专员', 13000.00, '2020-04-20', 1, '本科', 4);

-- 财务部员工(8人)
INSERT INTO employee (emp_no, emp_name, gender, birth_date, id_card, phone, email, department, position, salary, hire_date, status, education, work_years) VALUES
('EMP00000026', '蒋华', 1, '1982-06-12', '110101198206120026', '13900000026', 'jianghua@company.com', '财务部', '财务总监', 32000.00, '2015-10-01', 1, '硕士', 9),
('EMP00000027', '沈红', 0, '1987-03-20', '110101198703200027', '13900000027', 'shenhong@company.com', '财务部', '财务经理', 22000.00, '2017-04-15', 1, '本科', 7),
('EMP00000028', '韦龙', 1, '1990-10-08', '110101199010080028', '13900000028', 'weilong@company.com', '财务部', '会计主管', 16000.00, '2019-02-01', 1, '本科', 5),
('EMP00000029', '尤芳', 0, '1992-05-25', '110101199205250029', '13900000029', 'youfang@company.com', '财务部', '会计', 13000.00, '2020-03-10', 1, '本科', 4),
('EMP00000030', '彭涛', 1, '1993-09-15', '110101199309150030', '13900000030', 'pengtao@company.com', '财务部', '出纳', 11000.00, '2020-07-20', 1, '本科', 4),
('EMP00000031', '潘丽', 0, '1994-12-03', '110101199412030031', '13900000031', 'panli@company.com', '财务部', '会计', 12500.00, '2020-11-15', 1, '本科', 4),
('EMP00000032', '田伟', 1, '1995-07-28', '110101199507280032', '13900000032', 'tianwei@company.com', '财务部', '财务专员', 10000.00, '2021-06-01', 1, '本科', 3),
('EMP00000033', '董静', 0, '1996-02-10', '110101199602100033', '13900000033', 'dongjing@company.com', '财务部', '实习生', 4500.00, '2024-03-01', 2, '本科', 0);

-- 市场部员工(10人)
INSERT INTO employee (emp_no, emp_name, gender, birth_date, id_card, phone, email, department, position, salary, hire_date, status, education, work_years) VALUES
('EMP00000034', '袁鹏', 1, '1984-11-18', '110101198411180034', '13900000034', 'yuanpeng@company.com', '市场部', '市场总监', 28000.00, '2016-08-01', 1, '硕士', 8),
('EMP00000035', '邹敏', 0, '1988-04-22', '110101198804220035', '13900000035', 'zoumin@company.com', '市场部', '市场经理', 20000.00, '2018-05-15', 1, '本科', 6),
('EMP00000036', '熊磊', 1, '1990-08-30', '110101199008300036', '13900000036', 'xionglei@company.com', '市场部', '品牌主管', 16000.00, '2019-10-01', 1, '本科', 5),
('EMP00000037', '金燕', 0, '1992-01-15', '110101199201150037', '13900000037', 'jinyan@company.com', '市场部', '市场专员', 12000.00, '2020-02-20', 1, '本科', 4),
('EMP00000038', '钱浩', 1, '1993-06-08', '110101199306080038', '13900000038', 'qianhao@company.com', '市场部', '市场专员', 11500.00, '2020-05-10', 1, '本科', 4),
('EMP00000039', '孙婷', 0, '1994-10-25', '110101199410250039', '13900000039', 'sunting@company.com', '市场部', '活动策划', 13000.00, '2020-08-15', 1, '本科', 4),
('EMP00000040', '李强', 1, '1995-03-12', '110101199503120040', '13900000040', 'liqiang@company.com', '市场部', '市场专员', 11000.00, '2021-01-20', 1, '本科', 3),
('EMP00000041', '周芳', 0, '1996-07-20', '110101199607200041', '13900000041', 'zhoufang@company.com', '市场部', '新媒体运营', 10500.00, '2021-04-01', 1, '本科', 3),
('EMP00000042', '吴磊', 1, '1997-11-05', '110101199711050042', '13900000042', 'wulei@company.com', '市场部', '实习生', 5000.00, '2024-02-15', 2, '本科', 0),
('EMP00000043', '郑敏', 0, '1991-09-18', '110101199109180043', '13900000043', 'zhengmin@company.com', '市场部', '公关主管', 15000.00, '2019-12-10', 1, '本科', 5);

-- 销售部员工(7人)
INSERT INTO employee (emp_no, emp_name, gender, birth_date, id_card, phone, email, department, position, salary, hire_date, status, education, work_years) VALUES
('EMP00000044', '王刚', 1, '1983-05-10', '110101198305100044', '13900000044', 'wanggang@company.com', '销售部', '销售总监', 30000.00, '2016-03-01', 1, '本科', 8),
('EMP00000045', '李红', 0, '1986-12-22', '110101198612220045', '13900000045', 'lihong@company.com', '销售部', '销售经理', 18000.00, '2018-02-15', 1, '本科', 6),
('EMP00000046', '张磊', 1, '1989-08-15', '110101198908150046', '13900000046', 'zhanglei@company.com', '销售部', '销售主管', 15000.00, '2019-05-20', 1, '本科', 5),
('EMP00000047', '刘燕', 0, '1991-04-08', '110101199104080047', '13900000047', 'liuyan@company.com', '销售部', '销售代表', 10000.00, '2020-01-10', 1, '本科', 4),
('EMP00000048', '陈浩', 1, '1992-09-28', '110101199209280048', '13900000048', 'chenhao@company.com', '销售部', '销售代表', 9500.00, '2020-04-15', 1, '本科', 4),
('EMP00000049', '杨敏', 0, '1993-02-16', '110101199302160049', '13900000049', 'yangmin@company.com', '销售部', '销售代表', 9000.00, '2020-07-20', 1, '本科', 4),
('EMP00000050', '赵强', 1, '1994-07-03', '110101199407030050', '13900000050', 'zhaoqiang@company.com', '销售部', '销售代表', 8500.00, '2020-10-01', 1, '本科', 4);

SELECT '======================================' AS '';
SELECT '员工数据插入完成!' AS message;
SELECT '======================================' AS '';

-- =====================================================
-- 4.5 插入培训课程数据
-- =====================================================
INSERT INTO training_course (course_name, course_type, course_description, instructor, duration, location, start_date, end_date, capacity, enrolled_count, course_status) VALUES
('新员工入职培训', 1, '帮助新员工快速了解公司文化、规章制度和工作流程', '林晓', 8, '培训室A', '2024-01-10 09:00:00', '2024-01-10 17:00:00', 30, 25, 2),
('Java高级编程培训', 2, '深入讲解Java高级特性、并发编程和性能优化', '张伟', 16, '培训室B', '2024-02-15 09:00:00', '2024-02-16 17:00:00', 20, 18, 2),
('团队管理技能提升', 3, '提升管理者的团队领导力和沟通技巧', '林晓', 12, '培训室A', '2024-03-20 09:00:00', '2024-03-21 17:00:00', 15, 12, 2),
('安全生产规范培训', 4, '学习公司安全生产规范和应急处理流程', '郭燕', 4, '培训室C', '2024-04-10 14:00:00', '2024-04-10 18:00:00', 50, 45, 2),
('Excel高级应用培训', 2, '掌握Excel高级函数、数据透视表和图表制作', '韩梅', 6, '培训室B', '2024-05-15 09:00:00', '2024-05-15 16:00:00', 25, 20, 1),
('项目管理最佳实践', 3, '学习项目管理的流程、工具和最佳实践', '袁鹏', 8, '培训室A', '2024-06-20 09:00:00', '2024-06-20 17:00:00', 20, 15, 0);

SELECT '======================================' AS '';
SELECT '培训课程数据插入完成!' AS message;
SELECT '======================================' AS '';

-- =====================================================
-- 4.6 插入培训报名数据
-- =====================================================
INSERT INTO training_enrollment (course_id, emp_id, enrollment_time, approval_status, attendance_status, score, feedback) VALUES
(1, 8, '2024-01-05 10:00:00', 1, 1, 90, '培训内容很实用，快速了解了公司文化'),
(1, 15, '2024-01-05 14:00:00', 1, 1, 85, '讲师讲解清晰，受益匪浅'),
(1, 23, '2024-01-06 09:00:00', 1, 1, 88, '培训组织得很好'),
(2, 2, '2024-02-10 10:00:00', 1, 1, 92, '技术内容深入，收获很大'),
(2, 3, '2024-02-11 14:00:00', 1, 1, 89, '实战案例很有帮助'),
(2, 4, '2024-02-12 09:00:00', 1, 1, 87, '讲师经验丰富'),
(3, 16, '2024-03-15 10:00:00', 1, 1, 95, '管理课程非常实用'),
(3, 17, '2024-03-16 14:00:00', 1, 1, 93, '学到了很多团队管理技巧'),
(4, 1, '2024-04-05 10:00:00', 1, 1, 88, '安全培训很重要'),
(4, 2, '2024-04-06 14:00:00', 1, 1, 90, '规范讲解详细');

SELECT '======================================' AS '';
SELECT '培训报名数据插入完成!' AS message;
SELECT '======================================' AS '';

-- =====================================================
-- 4.7 插入系统消息数据
-- =====================================================
INSERT INTO message (title, content, message_type, receiver_id, sender_id, is_read, read_time) VALUES
('欢迎使用人力资源数据中心', '欢迎您使用人力资源数据中心系统！本系统提供员工管理、考勤管理、绩效管理、薪酬管理、培训管理等全方位的人力资源管理功能。', 0, 1, 1, 1, '2024-01-01 10:00:00'),
('系统升级通知', '系统将于2024年1月20日进行升级维护，预计维护时间为2小时，期间系统将无法访问，请提前做好准备。', 0, 2, 1, 1, '2024-01-15 09:00:00'),
('新员工入职培训提醒', '新员工入职培训将于1月10日举行，请相关部门通知新员工准时参加。', 1, 16, 1, 0, NULL),
('绩效评估启动通知', '2024年第一季度绩效评估工作已启动，请各部门按时完成评估工作。', 1, 17, 1, 0, NULL);

SELECT '======================================' AS '';
SELECT '系统消息数据插入完成!' AS message;
SELECT '======================================' AS '';

-- =====================================================
-- 初始化完成
-- =====================================================
SELECT '======================================' AS '';
SELECT 'MySQL数据库初始化完成!' AS message;
SELECT '======================================' AS '';
SELECT
    TABLE_NAME AS 表名,
    TABLE_COMMENT AS 表说明,
    TABLE_ROWS AS 数据行数
FROM information_schema.TABLES
WHERE TABLE_SCHEMA = 'hr_datacenter'
ORDER BY TABLE_NAME;
