-- ============================================================================
-- 人力资源数据中心系统 - MySQL数据库初始化脚本
-- 版本: 1.0
-- 创建时间: 2024-01-20
-- 数据库类型: MySQL 8.0+
-- 说明: 包含所有业务表的建表语句、索引、注释等
-- ============================================================================

-- 设置字符集
SET NAMES utf8mb4;
SET FOREIGN_KEY_CHECKS = 0;

-- ============================================================================
-- 1. 创建数据库
-- ============================================================================
CREATE DATABASE IF NOT EXISTS `hr_datacenter` DEFAULT CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci COMMENT '人力资源数据中心业务数据库';

USE `hr_datacenter`;

-- ============================================================================
-- 2. 系统用户表 (sys_user)
-- ============================================================================
DROP TABLE IF EXISTS `sys_user`;
CREATE TABLE `sys_user` (
    `user_id` BIGINT(20) NOT NULL AUTO_INCREMENT COMMENT '用户ID',
    `username` VARCHAR(50) NOT NULL COMMENT '用户名',
    `password` VARCHAR(100) NOT NULL COMMENT '密码(BCrypt加密)',
    `real_name` VARCHAR(50) DEFAULT NULL COMMENT '真实姓名',
    `dept_id` BIGINT(20) DEFAULT NULL COMMENT '部门ID',
    `phone` VARCHAR(20) DEFAULT NULL COMMENT '手机号码',
    `email` VARCHAR(100) DEFAULT NULL COMMENT '邮箱',
    `status` INT(1) NOT NULL DEFAULT 1 COMMENT '用户状态(0-禁用 1-启用)',
    `last_login_time` DATETIME DEFAULT NULL COMMENT '最后登录时间',
    `create_time` DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',
    `update_time` DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT '更新时间',
    `deleted` INT(1) NOT NULL DEFAULT 0 COMMENT '删除标记(0-未删除 1-已删除)',
    PRIMARY KEY (`user_id`),
    UNIQUE KEY `uk_username` (`username`),
    KEY `idx_dept_id` (`dept_id`),
    KEY `idx_phone` (`phone`),
    KEY `idx_email` (`email`),
    KEY `idx_status` (`status`),
    KEY `idx_deleted` (`deleted`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci COMMENT='系统用户表';

-- 初始化管理员用户(密码: admin123, BCrypt加密后)
INSERT INTO `sys_user` (`username`, `password`, `real_name`, `dept_id`, `phone`, `email`, `status`) VALUES
('admin', '$2a$10$N.zmdr9k7uOCQb376NoUnuTJ8iAt6Z5EHsM8lE9lBOsl7iAt6Z5EH', '系统管理员', 1, '13800138000', 'admin@hrdatacenter.com', 1),
('hr001', '$2a$10$N.zmdr9k7uOCQb376NoUnuTJ8iAt6Z5EHsM8lE9lBOsl7iAt6Z5EH', '人力资源专员', 2, '13800138001', 'hr001@hrdatacenter.com', 1);

-- ============================================================================
-- 3. 系统角色表 (sys_role)
-- ============================================================================
DROP TABLE IF EXISTS `sys_role`;
CREATE TABLE `sys_role` (
    `role_id` BIGINT(20) NOT NULL AUTO_INCREMENT COMMENT '角色ID',
    `role_name` VARCHAR(50) NOT NULL COMMENT '角色名称',
    `role_code` VARCHAR(50) NOT NULL COMMENT '角色编码',
    `role_desc` VARCHAR(200) DEFAULT NULL COMMENT '角色描述',
    `status` INT(1) NOT NULL DEFAULT 1 COMMENT '角色状态(0-禁用 1-启用)',
    `create_time` DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',
    `update_time` DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT '更新时间',
    `deleted` INT(1) NOT NULL DEFAULT 0 COMMENT '删除标记(0-未删除 1-已删除)',
    PRIMARY KEY (`role_id`),
    UNIQUE KEY `uk_role_code` (`role_code`),
    KEY `idx_role_name` (`role_name`),
    KEY `idx_status` (`status`),
    KEY `idx_deleted` (`deleted`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci COMMENT='系统角色表';

-- 初始化角色数据
INSERT INTO `sys_role` (`role_name`, `role_code`, `role_desc`, `status`) VALUES
('超级管理员', 'ROLE_ADMIN', '系统超级管理员，拥有所有权限', 1),
('人力资源管理员', 'ROLE_HR_ADMIN', '人力资源管理员，管理所有人力资源相关功能', 1),
('部门经理', 'ROLE_MANAGER', '部门经理，管理本部门员工信息', 1),
('普通员工', 'ROLE_EMPLOYEE', '普通员工，仅查看个人信息', 1);

-- ============================================================================
-- 4. 员工表 (employee)
-- ============================================================================
DROP TABLE IF EXISTS `employee`;
CREATE TABLE `employee` (
    `emp_id` BIGINT(20) NOT NULL AUTO_INCREMENT COMMENT '员工ID',
    `emp_no` VARCHAR(20) NOT NULL COMMENT '员工编号',
    `emp_name` VARCHAR(50) NOT NULL COMMENT '员工姓名',
    `gender` INT(1) NOT NULL COMMENT '性别(0-女 1-男)',
    `birth_date` DATE DEFAULT NULL COMMENT '出生日期',
    `id_card` VARCHAR(18) DEFAULT NULL COMMENT '身份证号',
    `phone` VARCHAR(20) DEFAULT NULL COMMENT '手机号码',
    `email` VARCHAR(100) DEFAULT NULL COMMENT '邮箱',
    `department` VARCHAR(50) DEFAULT NULL COMMENT '部门',
    `position` VARCHAR(50) DEFAULT NULL COMMENT '职位',
    `salary` DECIMAL(10,2) DEFAULT NULL COMMENT '薪资',
    `hire_date` DATE DEFAULT NULL COMMENT '入职日期',
    `resign_date` DATE DEFAULT NULL COMMENT '离职日期',
    `status` INT(1) DEFAULT 1 COMMENT '员工状态(0-离职 1-在职 2-试用)',
    `education` VARCHAR(20) DEFAULT NULL COMMENT '学历',
    `create_time` DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',
    `update_time` DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT '更新时间',
    `deleted` INT(1) NOT NULL DEFAULT 0 COMMENT '删除标记(0-未删除 1-已删除)',
    PRIMARY KEY (`emp_id`),
    UNIQUE KEY `uk_emp_no` (`emp_no`),
    KEY `idx_emp_name` (`emp_name`),
    KEY `idx_department` (`department`),
    KEY `idx_position` (`position`),
    KEY `idx_phone` (`phone`),
    KEY `idx_email` (`email`),
    KEY `idx_status` (`status`),
    KEY `idx_hire_date` (`hire_date`),
    KEY `idx_deleted` (`deleted`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci COMMENT='员工信息表';

-- 初始化测试员工数据
INSERT INTO `employee` (`emp_no`, `emp_name`, `gender`, `birth_date`, `id_card`, `phone`, `email`, `department`, `position`, `salary`, `hire_date`, `status`, `education`) VALUES
('EMP001', '张三', 1, '1990-01-15', '110101199001011234', '13800138001', 'zhangsan@example.com', '技术部', '软件工程师', 15000.00, '2020-03-01', 1, '本科'),
('EMP002', '李四', 1, '1988-06-20', '110101198806201234', '13800138002', 'lisi@example.com', '技术部', '高级软件工程师', 20000.00, '2018-07-15', 1, '硕士'),
('EMP003', '王五', 0, '1992-03-10', '110101199203101234', '13800138003', 'wangwu@example.com', '技术部', '前端开发工程师', 13000.00, '2021-05-20', 1, '本科'),
('EMP004', '赵六', 1, '1985-11-25', '110101198511251234', '13800138004', 'zhaoliu@example.com', '人力资源部', '人力资源专员', 8000.00, '2019-02-10', 1, '本科'),
('EMP005', '钱七', 0, '1993-08-05', '110101199308051234', '13800138005', 'qianqi@example.com', '财务部', '会计', 9000.00, '2020-08-15', 1, '本科'),
('EMP006', '孙八', 1, '1991-12-30', '110101199112301234', '13800138006', 'sunba@example.com', '市场部', '销售经理', 18000.00, '2019-06-01', 1, '本科'),
('EMP007', '周九', 0, '1994-04-18', '110101199404181234', '13800138007', 'zhoujiu@example.com', '技术部', 'UI设计师', 11000.00, '2022-01-10', 1, '本科'),
('EMP008', '吴十', 1, '1989-09-12', '110101198909121234', '13800138008', 'wushi@example.com', '技术部', '产品经理', 16000.00, '2018-11-20', 1, '硕士');

-- ============================================================================
-- 5. 考勤记录表 (attendance)
-- ============================================================================
DROP TABLE IF EXISTS `attendance`;
CREATE TABLE `attendance` (
    `attendance_id` BIGINT(20) NOT NULL AUTO_INCREMENT COMMENT '考勤ID',
    `emp_id` BIGINT(20) NOT NULL COMMENT '员工ID',
    `attendance_date` DATE NOT NULL COMMENT '考勤日期',
    `clock_in_time` TIME DEFAULT NULL COMMENT '上班打卡时间',
    `clock_out_time` TIME DEFAULT NULL COMMENT '下班打卡时间',
    `attendance_type` INT(1) DEFAULT NULL COMMENT '考勤类型(0-正常 1-迟到 2-早退 3-旷工 4-请假 5-加班)',
    `attendance_status` INT(1) DEFAULT NULL COMMENT '考勤状态(0-未打卡 1-已打卡 2-请假 3-加班)',
    `work_duration` INT(11) DEFAULT NULL COMMENT '工作时长(分钟)',
    `remark` VARCHAR(500) DEFAULT NULL COMMENT '备注',
    `create_time` DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',
    `update_time` DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT '更新时间',
    `deleted` INT(1) NOT NULL DEFAULT 0 COMMENT '删除标记(0-未删除 1-已删除)',
    PRIMARY KEY (`attendance_id`),
    KEY `idx_emp_id` (`emp_id`),
    KEY `idx_attendance_date` (`attendance_date`),
    KEY `idx_attendance_type` (`attendance_type`),
    KEY `idx_attendance_status` (`attendance_status`),
    KEY `idx_deleted` (`deleted`),
    CONSTRAINT `fk_attendance_emp_id` FOREIGN KEY (`emp_id`) REFERENCES `employee` (`emp_id`) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci COMMENT='考勤记录表';

-- ============================================================================
-- 6. 请假记录表 (emp_leave) 修复：替换MySQL关键字leave
-- ============================================================================
DROP TABLE IF EXISTS `emp_leave`;
CREATE TABLE `emp_leave` (
    `leave_id` BIGINT(20) NOT NULL AUTO_INCREMENT COMMENT '请假ID',
    `emp_id` BIGINT(20) NOT NULL COMMENT '员工ID',
    `leave_type` INT(1) NOT NULL COMMENT '请假类型(0-事假 1-病假 2-年假 3-婚假 4-产假 5-丧假 6-其他)',
    `start_time` DATETIME NOT NULL COMMENT '请假开始时间',
    `end_time` DATETIME NOT NULL COMMENT '请假结束时间',
    `leave_duration` INT(11) DEFAULT NULL COMMENT '请假时长(小时)',
    `reason` VARCHAR(500) DEFAULT NULL COMMENT '请假原因',
    `approver_id` BIGINT(20) DEFAULT NULL COMMENT '审批人ID',
    `approval_status` INT(1) DEFAULT 0 COMMENT '审批状态(0-待审批 1-已同意 2-已拒绝 3-已撤回)',
    `approval_comment` VARCHAR(500) DEFAULT NULL COMMENT '审批意见',
    `approval_time` DATETIME DEFAULT NULL COMMENT '审批时间',
    `attachment` VARCHAR(255) DEFAULT NULL COMMENT '附件路径',
    `create_time` DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',
    `update_time` DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT '更新时间',
    `deleted` INT(1) NOT NULL DEFAULT 0 COMMENT '删除标记(0-未删除 1-已删除)',
    PRIMARY KEY (`leave_id`),
    KEY `idx_emp_id` (`emp_id`),
    KEY `idx_leave_type` (`leave_type`),
    KEY `idx_approval_status` (`approval_status`),
    KEY `idx_start_time` (`start_time`),
    KEY `idx_deleted` (`deleted`),
    CONSTRAINT `fk_emp_leave_emp_id` FOREIGN KEY (`emp_id`) REFERENCES `employee` (`emp_id`) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci COMMENT='请假记录表';

-- ============================================================================
-- 7. 绩效目标表 (performance_goal)
-- ============================================================================
DROP TABLE IF EXISTS `performance_goal`;
CREATE TABLE `performance_goal` (
    `goal_id` BIGINT(20) NOT NULL AUTO_INCREMENT COMMENT '目标ID',
    `emp_id` BIGINT(20) NOT NULL COMMENT '员工ID',
    `year` INT(4) NOT NULL COMMENT '评估年度',
    `period_type` INT(1) NOT NULL COMMENT '评估周期(1-年度 2-季度 3-月度)',
    `goal_description` TEXT NOT NULL COMMENT '目标描述',
    `weight` INT(3) DEFAULT NULL COMMENT '权重(百分比)',
    `completion_standard` TEXT DEFAULT NULL COMMENT '完成标准',
    `goal_status` INT(1) DEFAULT 0 COMMENT '目标状态(0-草稿 1-进行中 2-已完成)',
    `create_time` DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',
    `update_time` DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT '更新时间',
    `deleted` INT(1) NOT NULL DEFAULT 0 COMMENT '删除标记(0-未删除 1-已删除)',
    PRIMARY KEY (`goal_id`),
    KEY `idx_emp_id` (`emp_id`),
    KEY `idx_year` (`year`),
    KEY `idx_period_type` (`period_type`),
    KEY `idx_goal_status` (`goal_status`),
    KEY `idx_deleted` (`deleted`),
    CONSTRAINT `fk_performance_goal_emp_id` FOREIGN KEY (`emp_id`) REFERENCES `employee` (`emp_id`) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci COMMENT='绩效目标表';

-- ============================================================================
-- 8. 绩效评估表 (performance_evaluation)
-- ============================================================================
DROP TABLE IF EXISTS `performance_evaluation`;
CREATE TABLE `performance_evaluation` (
    `evaluation_id` BIGINT(20) NOT NULL AUTO_INCREMENT COMMENT '评估ID',
    `emp_id` BIGINT(20) NOT NULL COMMENT '员工ID',
    `year` INT(4) NOT NULL COMMENT '评估年度',
    `period_type` INT(1) NOT NULL COMMENT '评估周期(1-年度 2-季度 3-月度)',
    `quarter` INT(1) DEFAULT NULL COMMENT '季度(季度评估时使用)',
    `month` INT(2) DEFAULT NULL COMMENT '月份(月度评估时使用)',
    `self_score` DECIMAL(5,2) DEFAULT NULL COMMENT '自评分',
    `self_comment` TEXT DEFAULT NULL COMMENT '自评说明',
    `supervisor_score` DECIMAL(5,2) DEFAULT NULL COMMENT '上级评分',
    `supervisor_comment` TEXT DEFAULT NULL COMMENT '上级评价意见',
    `final_score` DECIMAL(5,2) DEFAULT NULL COMMENT '综合评分',
    `performance_level` VARCHAR(10) DEFAULT NULL COMMENT '绩效等级(S-优秀 A-良好 B-合格 C-需改进 D-不合格)',
    `improvement_plan` TEXT DEFAULT NULL COMMENT '改进建议',
    `interview_record` TEXT DEFAULT NULL COMMENT '面谈记录',
    `interview_date` DATETIME DEFAULT NULL COMMENT '面谈时间',
    `evaluation_status` INT(1) DEFAULT 0 COMMENT '评估状态(0-未评估 1-已自评 2-已评价 3-已完成)',
    `create_time` DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',
    `update_time` DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT '更新时间',
    `deleted` INT(1) NOT NULL DEFAULT 0 COMMENT '删除标记(0-未删除 1-已删除)',
    PRIMARY KEY (`evaluation_id`),
    KEY `idx_emp_id` (`emp_id`),
    KEY `idx_year` (`year`),
    KEY `idx_period_type` (`period_type`),
    KEY `idx_evaluation_status` (`evaluation_status`),
    KEY `idx_deleted` (`deleted`),
    CONSTRAINT `fk_performance_evaluation_emp_id` FOREIGN KEY (`emp_id`) REFERENCES `employee` (`emp_id`) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci COMMENT='绩效评估表';

-- ============================================================================
-- 9. 薪资调整表 (salary_adjustment)
-- ============================================================================
DROP TABLE IF EXISTS `salary_adjustment`;
CREATE TABLE `salary_adjustment` (
    `adjustment_id` BIGINT(20) NOT NULL AUTO_INCREMENT COMMENT '调整ID',
    `emp_id` BIGINT(20) NOT NULL COMMENT '员工ID',
    `adjustment_type` INT(1) NOT NULL COMMENT '调整类型(1-晋升 2-降职 3-调薪 4-转正)',
    `before_salary` DECIMAL(10,2) DEFAULT NULL COMMENT '调整前基本工资',
    `after_salary` DECIMAL(10,2) DEFAULT NULL COMMENT '调整后基本工资',
    `adjustment_rate` DECIMAL(5,2) DEFAULT NULL COMMENT '调整幅度(%)',
    `effective_date` DATETIME NOT NULL COMMENT '生效日期',
    `reason` VARCHAR(500) DEFAULT NULL COMMENT '调整原因',
    `approver_id` BIGINT(20) DEFAULT NULL COMMENT '审批人ID',
    `approval_status` INT(1) DEFAULT 0 COMMENT '审批状态(0-待审批 1-已同意 2-已拒绝)',
    `approval_comment` VARCHAR(500) DEFAULT NULL COMMENT '审批意见',
    `approval_date` DATETIME DEFAULT NULL COMMENT '审批时间',
    `creator_id` BIGINT(20) DEFAULT NULL COMMENT '创建人ID',
    `create_time` DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',
    `update_time` DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT '更新时间',
    `deleted` INT(1) NOT NULL DEFAULT 0 COMMENT '删除标记(0-未删除 1-已删除)',
    PRIMARY KEY (`adjustment_id`),
    KEY `idx_emp_id` (`emp_id`),
    KEY `idx_adjustment_type` (`adjustment_type`),
    KEY `idx_effective_date` (`effective_date`),
    KEY `idx_approval_status` (`approval_status`),
    KEY `idx_deleted` (`deleted`),
    CONSTRAINT `fk_salary_adjustment_emp_id` FOREIGN KEY (`emp_id`) REFERENCES `employee` (`emp_id`) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci COMMENT='薪资调整表';

-- ============================================================================
-- 10. 薪资发放表 (salary_payment)
-- ============================================================================
DROP TABLE IF EXISTS `salary_payment`;
CREATE TABLE `salary_payment` (
    `payment_id` BIGINT(20) NOT NULL AUTO_INCREMENT COMMENT '发放ID',
    `emp_id` BIGINT(20) NOT NULL COMMENT '员工ID',
    `year` INT(4) NOT NULL COMMENT '发放年度',
    `month` INT(2) NOT NULL COMMENT '发放月份',
    `basic_salary` DECIMAL(10,2) DEFAULT NULL COMMENT '基本工资',
    `performance_salary` DECIMAL(10,2) DEFAULT NULL COMMENT '绩效工资',
    `position_allowance` DECIMAL(10,2) DEFAULT NULL COMMENT '岗位津贴',
    `transport_allowance` DECIMAL(10,2) DEFAULT NULL COMMENT '交通补贴',
    `communication_allowance` DECIMAL(10,2) DEFAULT NULL COMMENT '通讯补贴',
    `meal_allowance` DECIMAL(10,2) DEFAULT NULL COMMENT '餐补',
    `other_allowance` DECIMAL(10,2) DEFAULT NULL COMMENT '其他补贴',
    `overtime_pay` DECIMAL(10,2) DEFAULT NULL COMMENT '加班费',
    `total_gross_salary` DECIMAL(10,2) DEFAULT NULL COMMENT '应发工资总额',
    `social_insurance` DECIMAL(10,2) DEFAULT NULL COMMENT '社保',
    `housing_fund` DECIMAL(10,2) DEFAULT NULL COMMENT '公积金',
    `income_tax` DECIMAL(10,2) DEFAULT NULL COMMENT '个人所得税',
    `other_deduction` DECIMAL(10,2) DEFAULT NULL COMMENT '其他扣款',
    `total_net_salary` DECIMAL(10,2) DEFAULT NULL COMMENT '实发工资总额',
    `payment_status` INT(1) DEFAULT 0 COMMENT '发放状态(0-未发放 1-已发放)',
    `payment_date` DATETIME DEFAULT NULL COMMENT '发放时间',
    `remark` VARCHAR(500) DEFAULT NULL COMMENT '备注',
    `create_time` DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',
    `update_time` DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT '更新时间',
    `deleted` INT(1) NOT NULL DEFAULT 0 COMMENT '删除标记(0-未删除 1-已删除)',
    PRIMARY KEY (`payment_id`),
    UNIQUE KEY `uk_emp_year_month` (`emp_id`, `year`, `month`),
    KEY `idx_emp_id` (`emp_id`),
    KEY `idx_year` (`year`),
    KEY `idx_month` (`month`),
    KEY `idx_payment_status` (`payment_status`),
    KEY `idx_deleted` (`deleted`),
    CONSTRAINT `fk_salary_payment_emp_id` FOREIGN KEY (`emp_id`) REFERENCES `employee` (`emp_id`) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci COMMENT='薪资发放表';

-- ============================================================================
-- 11. 培训课程表 (training_course)
-- ============================================================================
DROP TABLE IF EXISTS `training_course`;
CREATE TABLE `training_course` (
    `course_id` BIGINT(20) NOT NULL AUTO_INCREMENT COMMENT '课程ID',
    `course_name` VARCHAR(100) NOT NULL COMMENT '课程名称',
    `course_type` INT(1) NOT NULL COMMENT '课程类型(1-新员工培训 2-技能培训 3-管理培训 4-安全培训 5-其他)',
    `course_description` TEXT DEFAULT NULL COMMENT '课程描述',
    `instructor` VARCHAR(50) DEFAULT NULL COMMENT '培训讲师',
    `duration` INT(11) DEFAULT NULL COMMENT '培训时长(小时)',
    `location` VARCHAR(100) DEFAULT NULL COMMENT '培训地点',
    `start_date` DATETIME DEFAULT NULL COMMENT '培训开始时间',
    `end_date` DATETIME DEFAULT NULL COMMENT '培训结束时间',
    `capacity` INT(11) DEFAULT NULL COMMENT '培训名额',
    `enrolled_count` INT(11) DEFAULT 0 COMMENT '已报名人数',
    `course_status` INT(1) DEFAULT 0 COMMENT '课程状态(0-未开始 1-进行中 2-已结束)',
    `create_time` DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',
    `update_time` DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT '更新时间',
    `deleted` INT(1) NOT NULL DEFAULT 0 COMMENT '删除标记(0-未删除 1-已删除)',
    PRIMARY KEY (`course_id`),
    KEY `idx_course_name` (`course_name`),
    KEY `idx_course_type` (`course_type`),
    KEY `idx_course_status` (`course_status`),
    KEY `idx_start_date` (`start_date`),
    KEY `idx_deleted` (`deleted`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci COMMENT='培训课程表';

-- 初始化培训课程数据
INSERT INTO `training_course` (`course_name`, `course_type`, `course_description`, `instructor`, `duration`, `location`, `start_date`, `end_date`, `capacity`, `course_status`) VALUES
('新员工入职培训', 1, '公司文化、规章制度、岗位职责等入职培训', '人力资源部', 8, '培训室A', '2024-02-01 09:00:00', '2024-02-01 17:00:00', 30, 0),
('Java高级开发技能培训', 2, 'Java高级特性、框架应用、性能优化等', '技术专家', 16, '培训室B', '2024-02-15 09:00:00', '2024-02-16 17:00:00', 20, 0),
('团队管理能力提升培训', 3, '团队建设、沟通技巧、项目管理等', '管理顾问', 12, '培训室C', '2024-03-01 09:00:00', '2024-03-02 17:00:00', 25, 0);

-- ============================================================================
-- 12. 培训报名表 (training_enrollment)
-- ============================================================================
DROP TABLE IF EXISTS `training_enrollment`;
CREATE TABLE `training_enrollment` (
    `enrollment_id` BIGINT(20) NOT NULL AUTO_INCREMENT COMMENT '报名ID',
    `course_id` BIGINT(20) NOT NULL COMMENT '课程ID',
    `emp_id` BIGINT(20) NOT NULL COMMENT '员工ID',
    `enrollment_time` DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT '报名时间',
    `approval_status` INT(1) DEFAULT 0 COMMENT '审核状态(0-待审核 1-已通过 2-已拒绝)',
    `approver_id` BIGINT(20) DEFAULT NULL COMMENT '审核人ID',
    `attendance_status` INT(1) DEFAULT 0 COMMENT '出勤状态(0-未出勤 1-已出勤 2-请假)',
    `score` INT(3) DEFAULT NULL COMMENT '培训成绩',
    `feedback` TEXT DEFAULT NULL COMMENT '培训反馈',
    `create_time` DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',
    `update_time` DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT '更新时间',
    `deleted` INT(1) NOT NULL DEFAULT 0 COMMENT '删除标记(0-未删除 1-已删除)',
    PRIMARY KEY (`enrollment_id`),
    KEY `idx_course_id` (`course_id`),
    KEY `idx_emp_id` (`emp_id`),
    KEY `idx_approval_status` (`approval_status`),
    KEY `idx_deleted` (`deleted`),
    CONSTRAINT `fk_training_enrollment_course_id` FOREIGN KEY (`course_id`) REFERENCES `training_course` (`course_id`) ON DELETE CASCADE,
    CONSTRAINT `fk_training_enrollment_emp_id` FOREIGN KEY (`emp_id`) REFERENCES `employee` (`emp_id`) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci COMMENT='培训报名表';

-- ============================================================================
-- 13. 消息表 (sys_message)
-- ============================================================================
DROP TABLE IF EXISTS `sys_message`;
CREATE TABLE `sys_message` (
    `message_id` BIGINT(20) NOT NULL AUTO_INCREMENT COMMENT '消息ID',
    `sender_id` BIGINT(20) NOT NULL COMMENT '发送者ID',
    `receiver_id` BIGINT(20) NOT NULL COMMENT '接收者ID',
    `title` VARCHAR(200) NOT NULL COMMENT '消息标题',
    `content` TEXT NOT NULL COMMENT '消息内容',
    `message_type` INT(1) NOT NULL COMMENT '消息类型(1-系统消息 2-审批提醒 3-个人消息)',
    `is_read` INT(1) DEFAULT 0 COMMENT '是否已读(0-未读 1-已读)',
    `related_id` BIGINT(20) DEFAULT NULL COMMENT '关联ID(如审批ID)',
    `create_time` DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',
    `read_time` DATETIME DEFAULT NULL COMMENT '阅读时间',
    PRIMARY KEY (`message_id`),
    KEY `idx_sender_id` (`sender_id`),
    KEY `idx_receiver_id` (`receiver_id`),
    KEY `idx_message_type` (`message_type`),
    KEY `idx_is_read` (`is_read`),
    KEY `idx_create_time` (`create_time`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci COMMENT='系统消息表';

-- ============================================================================
-- 14. 数据分类表 (data_category)
-- ============================================================================
DROP TABLE IF EXISTS `data_category`;
CREATE TABLE `data_category` (
    `category_id` BIGINT(20) NOT NULL AUTO_INCREMENT COMMENT '分类ID',
    `category_name` VARCHAR(50) NOT NULL COMMENT '分类名称',
    `category_code` VARCHAR(50) NOT NULL COMMENT '分类编码',
    `parent_id` BIGINT(20) DEFAULT NULL COMMENT '父分类ID',
    `description` VARCHAR(200) DEFAULT NULL COMMENT '分类描述',
    `sort_order` INT(11) DEFAULT 0 COMMENT '排序号',
    `status` INT(1) DEFAULT 1 COMMENT '分类状态(0-禁用 1-启用)',
    `create_time` DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',
    `update_time` DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT '更新时间',
    `deleted` INT(1) NOT NULL DEFAULT 0 COMMENT '删除标记(0-未删除 1-已删除)',
    PRIMARY KEY (`category_id`),
    UNIQUE KEY `uk_category_code` (`category_code`),
    KEY `idx_parent_id` (`parent_id`),
    KEY `idx_status` (`status`),
    KEY `idx_sort_order` (`sort_order`),
    KEY `idx_deleted` (`deleted`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci COMMENT='数据分类表';

-- 初始化数据分类
INSERT INTO `data_category` (`category_name`, `category_code`, `parent_id`, `description`, `sort_order`, `status`) VALUES
('人力资源数据', 'HR_DATA', NULL, '人力资源相关数据分类', 1, 1),
('员工数据', 'EMPLOYEE_DATA', 1, '员工基础信息数据', 1, 1),
('考勤数据', 'ATTENDANCE_DATA', 1, '考勤记录数据', 2, 1),
('绩效数据', 'PERFORMANCE_DATA', 1, '绩效评估数据', 3, 1),
('薪资数据', 'SALARY_DATA', 1, '薪资发放数据', 4, 1),
('培训数据', 'TRAINING_DATA', 1, '培训课程数据', 5, 1);

-- ============================================================================
-- 15. 操作日志表 (sys_operation_log)
-- ============================================================================
DROP TABLE IF EXISTS `sys_operation_log`;
CREATE TABLE `sys_operation_log` (
    `log_id` BIGINT(20) NOT NULL AUTO_INCREMENT COMMENT '日志ID',
    `module` VARCHAR(50) NOT NULL COMMENT '操作模块',
    `operation_type` VARCHAR(20) NOT NULL COMMENT '操作类型',
    `operation_desc` VARCHAR(200) DEFAULT NULL COMMENT '操作描述',
    `request_method` VARCHAR(10) DEFAULT NULL COMMENT '请求方法',
    `request_url` VARCHAR(500) DEFAULT NULL COMMENT '请求URL',
    `request_params` TEXT DEFAULT NULL COMMENT '请求参数',
    `response_result` TEXT DEFAULT NULL COMMENT '响应结果',
    `operator` VARCHAR(50) NOT NULL COMMENT '操作人',
    `ip_address` VARCHAR(50) DEFAULT NULL COMMENT 'IP地址',
    `operation_time` DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT '操作时间',
    `execution_time` BIGINT(20) DEFAULT NULL COMMENT '执行时长(毫秒)',
    `status` INT(1) DEFAULT 1 COMMENT '状态(0-失败 1-成功)',
    `error_msg` TEXT DEFAULT NULL COMMENT '错误信息',
    PRIMARY KEY (`log_id`),
    KEY `idx_module` (`module`),
    KEY `idx_operation_type` (`operation_type`),
    KEY `idx_operator` (`operator`),
    KEY `idx_operation_time` (`operation_time`),
    KEY `idx_status` (`status`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci COMMENT='系统操作日志表';

-- ============================================================================
-- 16. 创建视图(可选)
-- ============================================================================

-- 员工考勤统计视图
CREATE OR REPLACE VIEW `v_employee_attendance_stats` AS
SELECT
    e.emp_id,
    e.emp_no,
    e.emp_name,
    e.department,
    COUNT(a.attendance_id) AS total_days,
    SUM(CASE WHEN a.attendance_type = 0 THEN 1 ELSE 0 END) AS normal_days,
    SUM(CASE WHEN a.attendance_type = 1 THEN 1 ELSE 0 END) AS late_days,
    SUM(CASE WHEN a.attendance_type = 2 THEN 1 ELSE 0 END) AS early_leave_days,
    SUM(CASE WHEN a.attendance_type = 3 THEN 1 ELSE 0 END) AS absent_days,
    SUM(CASE WHEN a.attendance_type = 4 THEN 1 ELSE 0 END) AS leave_days,
    SUM(CASE WHEN a.attendance_type = 5 THEN 1 ELSE 0 END) AS overtime_days,
    SUM(a.work_duration) AS total_work_duration
FROM employee e
LEFT JOIN attendance a ON e.emp_id = a.emp_id AND a.deleted = 0
WHERE e.deleted = 0
GROUP BY e.emp_id, e.emp_no, e.emp_name, e.department;

-- 员工薪资统计视图
CREATE OR REPLACE VIEW `v_employee_salary_stats` AS
SELECT
    e.emp_id,
    e.emp_no,
    e.emp_name,
    e.department,
    e.position,
    e.salary AS current_salary,
    COUNT(sa.adjustment_id) AS adjustment_count,
    MAX(sa.effective_date) AS last_adjustment_date,
    AVG(sa.adjustment_rate) AS avg_adjustment_rate
FROM employee e
LEFT JOIN salary_adjustment sa ON e.emp_id = sa.emp_id AND sa.deleted = 0 AND sa.approval_status = 1
WHERE e.deleted = 0
GROUP BY e.emp_id, e.emp_no, e.emp_name, e.department, e.position, e.salary;

-- ============================================================================
-- 17. 创建存储过程(可选)
-- ============================================================================

DELIMITER $$

-- 计算员工工作年限的存储过程
CREATE PROCEDURE `sp_calculate_work_years`()
BEGIN
    UPDATE employee e
    SET e.update_time = NOW()
    WHERE e.deleted = 0;
END$$

-- 清理过期数据的存储过程(保留最近90天的操作日志)
CREATE PROCEDURE `sp_clean_expired_logs`()
BEGIN
    DELETE FROM sys_operation_log
    WHERE operation_time < DATE_SUB(NOW(), INTERVAL 90 DAY);
END$$

DELIMITER ;

-- ============================================================================
-- 18. 创建触发器(可选) 修复：删除多余空格
-- ============================================================================

-- 培训课程报名时自动更新已报名人数
DELIMITER $$
CREATE TRIGGER `trg_training_enrollment_insert`
AFTER INSERT ON `training_enrollment`
FOR EACH ROW
BEGIN
    IF NEW.approval_status = 1 THEN
        UPDATE training_course
        SET enrolled_count = enrolled_count + 1,
            update_time = NOW()
        WHERE course_id = NEW.course_id;
    END IF;
END$$
DELIMITER ;

DELIMITER $$
CREATE TRIGGER `trg_training_enrollment_update`
AFTER UPDATE ON `training_enrollment`
FOR EACH ROW
BEGIN
    IF OLD.approval_status != NEW.approval_status THEN
        IF NEW.approval_status = 1 AND OLD.approval_status != 1 THEN
            UPDATE training_course
            SET enrolled_count = enrolled_count + 1,
                update_time = NOW()
            WHERE course_id = NEW.course_id;
        ELSEIF NEW.approval_status != 1 AND OLD.approval_status = 1 THEN
            UPDATE training_course
            SET enrolled_count = enrolled_count - 1,
                update_time = NOW()
            WHERE course_id = NEW.course_id;
        END IF;
    END IF;
END$$
DELIMITER ;

-- ============================================================================
-- 19. 数据完整性检查
-- ============================================================================

-- 检查外键约束
SELECT
    CONSTRAINT_NAME,
    TABLE_NAME,
    COLUMN_NAME,
    REFERENCED_TABLE_NAME,
    REFERENCED_COLUMN_NAME
FROM
    INFORMATION_SCHEMA.KEY_COLUMN_USAGE
WHERE
    TABLE_SCHEMA = 'hr_datacenter'
    AND REFERENCED_TABLE_NAME IS NOT NULL;

-- ============================================================================
-- 20. 索引优化建议
-- ============================================================================

-- 复合索引(根据实际查询需求创建)
-- ALTER TABLE `attendance` ADD INDEX `idx_emp_date` (`emp_id`, `attendance_date`);
-- ALTER TABLE `emp_leave` ADD INDEX `idx_emp_type_status` (`emp_id`, `leave_type`, `approval_status`);
-- ALTER TABLE `salary_payment` ADD INDEX `idx_emp_date_status` (`emp_id`, `year`, `month`, `payment_status`);

-- ============================================================================
-- 结束
-- ============================================================================
SET FOREIGN_KEY_CHECKS = 1;

-- 显示所有表
SHOW TABLES;

-- 显示数据库统计信息
SELECT
    TABLE_NAME AS '表名',
    TABLE_ROWS AS '记录数',
    ROUND((DATA_LENGTH + INDEX_LENGTH) / 1024 / 1024, 2) AS '大小(MB)'
FROM
    information_schema.TABLES
WHERE
    TABLE_SCHEMA = 'hr_datacenter'
ORDER BY
    TABLE_NAME;

-- 初始化完成提示
SELECT '数据库初始化完成!' AS '状态';