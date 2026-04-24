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
CREATE DATABASE IF NOT EXISTS `hr_datacenter` DEFAULT CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;

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
    `role_code` VARCHAR(50) NOT NULL DEFAULT 'ROLE_EMPLOYEE' COMMENT '角色编码',
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
INSERT INTO `sys_user` (`username`, `password`, `real_name`, `dept_id`, `phone`, `email`, `role_code`, `status`) VALUES
('admin', '$2a$10$N.zmdr9k7uOCQb376NoUnuTJ8iAt6Z5EHsM8lE9lBOsl7iAt6Z5EH', '系统管理员', 1, '13800138000', 'admin@hrdatacenter.com', 'ROLE_ADMIN', 1),
('hr001', '$2a$10$N.zmdr9k7uOCQb376NoUnuTJ8iAt6Z5EHsM8lE9lBOsl7iAt6Z5EH', '人力资源专员', 2, '13800138001', 'hr001@hrdatacenter.com', 'ROLE_HR_ADMIN', 1);

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
-- 3.1 收藏表 (user_favorite)
-- ============================================================================
DROP TABLE IF EXISTS `user_favorite`;
CREATE TABLE `user_favorite` (
    `favorite_id` BIGINT(20) NOT NULL AUTO_INCREMENT COMMENT '收藏ID',
    `user_id` BIGINT(20) NOT NULL COMMENT '用户ID',
    `favorite_type` VARCHAR(50) NOT NULL COMMENT '收藏类型',
    `target_key` VARCHAR(255) NOT NULL COMMENT '目标标识',
    `title` VARCHAR(100) DEFAULT NULL COMMENT '标题',
    `content` VARCHAR(500) DEFAULT NULL COMMENT '描述',
    `create_time` DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',
    PRIMARY KEY (`favorite_id`),
    KEY `idx_user_id` (`user_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci COMMENT='用户收藏表';

-- ============================================================================
-- 3.2 分析规则表 (analysis_rule)
-- ============================================================================
DROP TABLE IF EXISTS `analysis_rule`;
CREATE TABLE `analysis_rule` (
    `rule_id` BIGINT(20) NOT NULL AUTO_INCREMENT COMMENT '规则ID',
    `rule_name` VARCHAR(100) NOT NULL COMMENT '规则名称',
    `rule_type` VARCHAR(50) NOT NULL COMMENT '规则类型',
    `rule_key` VARCHAR(100) NOT NULL COMMENT '规则键',
    `rule_value` VARCHAR(200) NOT NULL COMMENT '规则值',
    `effect_status` INT(1) NOT NULL DEFAULT 0 COMMENT '生效状态(0-未生效 1-已生效)',
    `change_log` VARCHAR(500) DEFAULT NULL COMMENT '调整日志',
    `create_time` DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',
    `update_time` DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT '更新时间',
    PRIMARY KEY (`rule_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci COMMENT='分析规则表';

-- ============================================================================
-- 3.3 预警模型表 (warning_model)
-- ============================================================================
DROP TABLE IF EXISTS `warning_model`;
CREATE TABLE `warning_model` (
    `model_id` BIGINT(20) NOT NULL AUTO_INCREMENT COMMENT '模型ID',
    `model_name` VARCHAR(100) NOT NULL COMMENT '模型名称',
    `model_type` VARCHAR(50) NOT NULL COMMENT '模型类型',
    `feature_weights` TEXT DEFAULT NULL COMMENT '特征权重JSON',
    `accuracy_rate` DECIMAL(5,4) DEFAULT NULL COMMENT '模型准确率',
    `model_version` VARCHAR(50) DEFAULT NULL COMMENT '模型版本',
    `status` INT(1) NOT NULL DEFAULT 1 COMMENT '状态(0-停用 1-启用)',
    `create_time` DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',
    `update_time` DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT '更新时间',
    PRIMARY KEY (`model_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci COMMENT='预警模型表';

-- ============================================================================
-- 3.4 报表任务表 (report_task)
-- ============================================================================
DROP TABLE IF EXISTS `report_task`;
CREATE TABLE `report_task` (
    `task_id` BIGINT(20) NOT NULL AUTO_INCREMENT COMMENT '任务ID',
    `task_name` VARCHAR(100) NOT NULL COMMENT '任务名',
    `report_type` VARCHAR(50) NOT NULL COMMENT '报表类型',
    `cron_expr` VARCHAR(100) DEFAULT NULL COMMENT '定时表达式',
    `share_target` VARCHAR(200) DEFAULT NULL COMMENT '分享目标',
    `status` INT(1) NOT NULL DEFAULT 1 COMMENT '状态(0-停用 1-启用)',
    `last_run_time` DATETIME DEFAULT NULL COMMENT '最近执行时间',
    `create_time` DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',
    `update_time` DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT '更新时间',
    PRIMARY KEY (`task_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci COMMENT='报表任务表';

-- 初始化分析规则
INSERT INTO `analysis_rule` (`rule_name`, `rule_type`, `rule_key`, `rule_value`, `effect_status`, `change_log`) VALUES
('流失预警高风险阈值', 'turnover', 'turnover.highRiskThreshold', '0.70', 1, '初始化规则'),
('流失预警中风险阈值', 'turnover', 'turnover.mediumRiskThreshold', '0.40', 1, '初始化规则'),
('人才缺口基础团队规模', 'talentGap', 'talentGap.minTeamSize', '3', 1, '初始化规则'),
('人才缺口技术团队规模', 'talentGap', 'talentGap.techTeamSize', '8', 1, '初始化规则'),
('成本预警预算系数', 'cost', 'cost.budgetMultiplier', '1.10', 1, '初始化规则');

-- 初始化预警模型
INSERT INTO `warning_model` (`model_name`, `model_type`, `feature_weights`, `accuracy_rate`, `model_version`, `status`) VALUES
('员工流失预警模型', 'turnover', '{\"tenure\":0.30,\"salary\":0.25,\"education\":0.20,\"position\":0.15,\"department\":0.10}', 0.8400, 'v1.0', 1),
('人才缺口预警模型', 'talentGap', '{\"department\":0.35,\"position\":0.35,\"structure\":0.30}', 0.8100, 'v1.0', 1),
('成本超支预警模型', 'cost', '{\"budget\":0.40,\"avgSalary\":0.30,\"headcount\":0.30}', 0.8000, 'v1.0', 1);

-- 初始化报表任务
INSERT INTO `report_task` (`task_name`, `report_type`, `cron_expr`, `share_target`, `status`) VALUES
('每日预警概览报表', 'warning', '0 0 9 * * ?', 'admin,hr001', 1),
('每周组织效能报表', 'org', '0 0 10 ? * MON', 'admin', 1),
('每月薪酬分析报表', 'salary', '0 0 11 1 * ?', 'admin,hr001', 1);

-- ============================================================================
-- 3.5 报表执行记录表 (report_execution_log)
-- ============================================================================
DROP TABLE IF EXISTS `report_execution_log`;
CREATE TABLE `report_execution_log` (
    `log_id` BIGINT(20) NOT NULL AUTO_INCREMENT COMMENT '执行记录ID',
    `task_id` BIGINT(20) DEFAULT NULL COMMENT '任务ID',
    `task_name` VARCHAR(100) DEFAULT NULL COMMENT '任务名称',
    `report_type` VARCHAR(50) NOT NULL COMMENT '报表类型',
    `file_name` VARCHAR(255) DEFAULT NULL COMMENT '文件名',
    `status` INT(1) NOT NULL DEFAULT 1 COMMENT '执行状态(0-失败 1-成功)',
    `message` VARCHAR(500) DEFAULT NULL COMMENT '执行说明',
    `run_time` DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT '执行时间',
    PRIMARY KEY (`log_id`),
    KEY `idx_task_id` (`task_id`),
    KEY `idx_report_type` (`report_type`),
    KEY `idx_run_time` (`run_time`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci COMMENT='报表执行记录表';

-- ============================================================================
-- 3.6 报表分享记录表 (report_share_log)
-- ============================================================================
DROP TABLE IF EXISTS `report_share_log`;
CREATE TABLE `report_share_log` (
    `share_id` BIGINT(20) NOT NULL AUTO_INCREMENT COMMENT '分享记录ID',
    `task_id` BIGINT(20) DEFAULT NULL COMMENT '任务ID',
    `report_type` VARCHAR(50) NOT NULL COMMENT '报表类型',
    `target` VARCHAR(200) NOT NULL COMMENT '分享目标',
    `share_channel` VARCHAR(50) NOT NULL DEFAULT 'message' COMMENT '分享渠道',
    `status` INT(1) NOT NULL DEFAULT 1 COMMENT '分享状态(0-失败 1-成功)',
    `message` VARCHAR(500) DEFAULT NULL COMMENT '分享说明',
    `share_time` DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT '分享时间',
    PRIMARY KEY (`share_id`),
    KEY `idx_task_id` (`task_id`),
    KEY `idx_report_type` (`report_type`),
    KEY `idx_share_time` (`share_time`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci COMMENT='报表分享记录表';

-- ============================================================================
-- 4. 招聘计划表 (recruitment_plan)
-- ============================================================================
DROP TABLE IF EXISTS `recruitment_plan`;
CREATE TABLE `recruitment_plan` (
    `recruit_id` BIGINT(20) NOT NULL AUTO_INCREMENT COMMENT '招聘计划ID',
    `recruit_code` VARCHAR(50) NOT NULL COMMENT '招聘计划编号',
    `department` VARCHAR(50) NOT NULL COMMENT '部门',
    `position` VARCHAR(50) NOT NULL COMMENT '岗位',
    `plan_count` INT(11) NOT NULL COMMENT '计划招聘人数',
    `hired_count` INT(11) NOT NULL DEFAULT 0 COMMENT '已招聘人数',
    `budget` DECIMAL(12,2) DEFAULT NULL COMMENT '招聘预算',
    `status` INT(1) NOT NULL DEFAULT 0 COMMENT '状态(0-草稿 1-招聘中 2-已完成 3-已关闭)',
    `start_date` DATE DEFAULT NULL COMMENT '开始日期',
    `end_date` DATE DEFAULT NULL COMMENT '结束日期',
    `owner` VARCHAR(50) DEFAULT NULL COMMENT '负责人',
    `remark` VARCHAR(500) DEFAULT NULL COMMENT '备注',
    `create_time` DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',
    `update_time` DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT '更新时间',
    `deleted` INT(1) NOT NULL DEFAULT 0 COMMENT '删除标记(0-未删除 1-已删除)',
    PRIMARY KEY (`recruit_id`),
    UNIQUE KEY `uk_recruit_code` (`recruit_code`),
    KEY `idx_department` (`department`),
    KEY `idx_position` (`position`),
    KEY `idx_status` (`status`),
    KEY `idx_deleted` (`deleted`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci COMMENT='招聘计划表';

INSERT INTO `recruitment_plan` (`recruit_code`, `department`, `position`, `plan_count`, `hired_count`, `budget`, `status`, `start_date`, `end_date`, `owner`, `remark`) VALUES
('RC202601001', '技术部', 'Java开发工程师', 3, 1, 30000.00, 1, '2026-01-01', '2026-03-31', 'hr001', '核心系统扩编'),
('RC202601002', '产品部', '产品经理', 1, 0, 15000.00, 1, '2026-01-10', '2026-04-10', 'admin', '新产品线需求');

-- ============================================================================
-- 5. 员工表 (employee)
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
-- ============================================================================
-- 兼容：Mapper 使用 sys_user.id、password_hash、sys_user_role、sys_role.id、sys_role.data_scope
-- 与现有 user_id、password、role_code 并存（普通列 + 同步 SQL）
-- 说明：为兼容 MySQL 8.0.28，采用 INFORMATION_SCHEMA + PREPARE 动态加列
-- ============================================================================

SET NAMES utf8mb4;
USE `hr_datacenter`;

DROP PROCEDURE IF EXISTS `sp_apply_mysql_compat_20260423`;
DELIMITER $$
CREATE PROCEDURE `sp_apply_mysql_compat_20260423`()
BEGIN
    DECLARE col_count INT DEFAULT 0;
    DECLARE col_extra VARCHAR(255) DEFAULT '';

    -- sys_role.data_scope
    SELECT COUNT(*) INTO col_count
    FROM INFORMATION_SCHEMA.COLUMNS
    WHERE TABLE_SCHEMA = DATABASE() AND TABLE_NAME = 'sys_role' AND COLUMN_NAME = 'data_scope';
    IF col_count = 0 THEN
        SET @sql = 'ALTER TABLE `sys_role` ADD COLUMN `data_scope` VARCHAR(32) NOT NULL DEFAULT ''ALL'' COMMENT ''数据范围 ALL/DEPT/SELF'' AFTER `role_code`';
        PREPARE stmt FROM @sql; EXECUTE stmt; DEALLOCATE PREPARE stmt;
    END IF;

    -- sys_role.id
    SELECT COUNT(*) INTO col_count
    FROM INFORMATION_SCHEMA.COLUMNS
    WHERE TABLE_SCHEMA = DATABASE() AND TABLE_NAME = 'sys_role' AND COLUMN_NAME = 'id';
    IF col_count = 0 THEN
        SET @sql = 'ALTER TABLE `sys_role` ADD COLUMN `id` BIGINT NULL COMMENT ''与 role_id 一致（兼容列）''';
        PREPARE stmt FROM @sql; EXECUTE stmt; DEALLOCATE PREPARE stmt;
    END IF;
    SELECT IFNULL(EXTRA, '') INTO col_extra
    FROM INFORMATION_SCHEMA.COLUMNS
    WHERE TABLE_SCHEMA = DATABASE() AND TABLE_NAME = 'sys_role' AND COLUMN_NAME = 'id'
    LIMIT 1;
    IF col_extra LIKE '%GENERATED%' THEN
        SET @sql = 'ALTER TABLE `sys_role` DROP COLUMN `id`';
        PREPARE stmt FROM @sql; EXECUTE stmt; DEALLOCATE PREPARE stmt;
        SET @sql = 'ALTER TABLE `sys_role` ADD COLUMN `id` BIGINT NULL COMMENT ''与 role_id 一致（兼容列）''';
        PREPARE stmt FROM @sql; EXECUTE stmt; DEALLOCATE PREPARE stmt;
    END IF;

    -- sys_user.id
    SELECT COUNT(*) INTO col_count
    FROM INFORMATION_SCHEMA.COLUMNS
    WHERE TABLE_SCHEMA = DATABASE() AND TABLE_NAME = 'sys_user' AND COLUMN_NAME = 'id';
    IF col_count = 0 THEN
        SET @sql = 'ALTER TABLE `sys_user` ADD COLUMN `id` BIGINT NULL COMMENT ''与 user_id 一致（兼容列）''';
        PREPARE stmt FROM @sql; EXECUTE stmt; DEALLOCATE PREPARE stmt;
    END IF;
    SELECT IFNULL(EXTRA, '') INTO col_extra
    FROM INFORMATION_SCHEMA.COLUMNS
    WHERE TABLE_SCHEMA = DATABASE() AND TABLE_NAME = 'sys_user' AND COLUMN_NAME = 'id'
    LIMIT 1;
    IF col_extra LIKE '%GENERATED%' THEN
        SET @sql = 'ALTER TABLE `sys_user` DROP COLUMN `id`';
        PREPARE stmt FROM @sql; EXECUTE stmt; DEALLOCATE PREPARE stmt;
        SET @sql = 'ALTER TABLE `sys_user` ADD COLUMN `id` BIGINT NULL COMMENT ''与 user_id 一致（兼容列）''';
        PREPARE stmt FROM @sql; EXECUTE stmt; DEALLOCATE PREPARE stmt;
    END IF;

    -- sys_user.password_hash
    SELECT COUNT(*) INTO col_count
    FROM INFORMATION_SCHEMA.COLUMNS
    WHERE TABLE_SCHEMA = DATABASE() AND TABLE_NAME = 'sys_user' AND COLUMN_NAME = 'password_hash';
    IF col_count = 0 THEN
        SET @sql = 'ALTER TABLE `sys_user` ADD COLUMN `password_hash` VARCHAR(200) NULL COMMENT ''与 password 一致（兼容列）''';
        PREPARE stmt FROM @sql; EXECUTE stmt; DEALLOCATE PREPARE stmt;
    END IF;
    SELECT IFNULL(EXTRA, '') INTO col_extra
    FROM INFORMATION_SCHEMA.COLUMNS
    WHERE TABLE_SCHEMA = DATABASE() AND TABLE_NAME = 'sys_user' AND COLUMN_NAME = 'password_hash'
    LIMIT 1;
    IF col_extra LIKE '%GENERATED%' THEN
        SET @sql = 'ALTER TABLE `sys_user` DROP COLUMN `password_hash`';
        PREPARE stmt FROM @sql; EXECUTE stmt; DEALLOCATE PREPARE stmt;
        SET @sql = 'ALTER TABLE `sys_user` ADD COLUMN `password_hash` VARCHAR(200) NULL COMMENT ''与 password 一致（兼容列）''';
        PREPARE stmt FROM @sql; EXECUTE stmt; DEALLOCATE PREPARE stmt;
    END IF;
END$$
DELIMITER ;

CALL `sp_apply_mysql_compat_20260423`();
DROP PROCEDURE IF EXISTS `sp_apply_mysql_compat_20260423`;

UPDATE `sys_role` SET `id` = `role_id` WHERE `id` IS NULL OR `id` <> `role_id`;
UPDATE `sys_role` SET `data_scope` = CASE `role_code`
    WHEN 'ROLE_MANAGER' THEN 'DEPT'
    WHEN 'ROLE_EMPLOYEE' THEN 'SELF'
    ELSE 'ALL'
END;

UPDATE `sys_user`
SET `id` = `user_id`,
    `password_hash` = `password`
WHERE `id` IS NULL OR `id` <> `user_id` OR `password_hash` IS NULL OR `password_hash` <> `password`;

DROP TABLE IF EXISTS `sys_user_role`;
CREATE TABLE `sys_user_role` (
    `user_id` BIGINT NOT NULL COMMENT 'sys_user.user_id',
    `role_id` BIGINT NOT NULL COMMENT 'sys_role.role_id',
    PRIMARY KEY (`user_id`, `role_id`),
    KEY `idx_sur_role_id` (`role_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci COMMENT='用户-角色关联';

INSERT INTO `sys_user_role` (`user_id`, `role_id`)
SELECT u.`user_id`, r.`role_id`
FROM `sys_user` u
INNER JOIN `sys_role` r ON r.`role_code` = u.`role_code` AND r.`deleted` = 0
WHERE u.`deleted` = 0;

SELECT 'mysql_compat_sys_user_role_20260423 applied' AS status;
-- ============================================================================
-- MySQL 批量补数脚本（可重复执行）
-- 目标：修复页面 NoData，补齐员工/考勤/请假/绩效/薪资/培训等核心数据
-- 规模：新增约 180 名员工 + 多月业务事实数据
-- ============================================================================

USE hr_datacenter;
SET FOREIGN_KEY_CHECKS = 0;

-- 生成序列 1..180
DROP TEMPORARY TABLE IF EXISTS tmp_seq;
CREATE TEMPORARY TABLE tmp_seq (n INT PRIMARY KEY);
INSERT INTO tmp_seq (n)
WITH RECURSIVE cte AS (
    SELECT 1 AS n
    UNION ALL
    SELECT n + 1 FROM cte WHERE n < 180
)
SELECT n FROM cte;

-- 生成月份 2025-10 到 2026-03
DROP TEMPORARY TABLE IF EXISTS tmp_months;
CREATE TEMPORARY TABLE tmp_months (
    ym DATE PRIMARY KEY,
    y INT NOT NULL,
    m INT NOT NULL
);
INSERT INTO tmp_months (ym, y, m)
WITH RECURSIVE mth AS (
    SELECT DATE('2025-10-01') AS ym
    UNION ALL
    SELECT DATE_ADD(ym, INTERVAL 1 MONTH) FROM mth WHERE ym < DATE('2026-03-01')
)
SELECT ym, YEAR(ym), MONTH(ym) FROM mth;

-- 生成最近 60 天序列
DROP TEMPORARY TABLE IF EXISTS tmp_days;
CREATE TEMPORARY TABLE tmp_days (d INT PRIMARY KEY);
INSERT INTO tmp_days (d)
WITH RECURSIVE day_seq AS (
    SELECT 0 AS d
    UNION ALL
    SELECT d + 1 FROM day_seq WHERE d < 59
)
SELECT d FROM day_seq;

-- 1) 员工主数据（新增 EMP1001+）
INSERT INTO employee (
    emp_no, emp_name, gender, birth_date, id_card, phone, email, department, position,
    salary, hire_date, resign_date, status, education
)
SELECT
    CONCAT('EMP', LPAD(1000 + s.n, 4, '0')) AS emp_no,
    CONCAT(
        CASE MOD(s.n, 30)
            WHEN 0 THEN '王' WHEN 1 THEN '李' WHEN 2 THEN '张' WHEN 3 THEN '刘' WHEN 4 THEN '陈'
            WHEN 5 THEN '杨' WHEN 6 THEN '赵' WHEN 7 THEN '黄' WHEN 8 THEN '周' WHEN 9 THEN '吴'
            WHEN 10 THEN '徐' WHEN 11 THEN '孙' WHEN 12 THEN '马' WHEN 13 THEN '朱' WHEN 14 THEN '胡'
            WHEN 15 THEN '郭' WHEN 16 THEN '何' WHEN 17 THEN '高' WHEN 18 THEN '林' WHEN 19 THEN '罗'
            WHEN 20 THEN '郑' WHEN 21 THEN '梁' WHEN 22 THEN '谢' WHEN 23 THEN '宋' WHEN 24 THEN '唐'
            WHEN 25 THEN '韩' WHEN 26 THEN '冯' WHEN 27 THEN '于' WHEN 28 THEN '董' ELSE '萧'
        END,
        CASE MOD(s.n, 40)
            WHEN 0 THEN '伟' WHEN 1 THEN '芳' WHEN 2 THEN '娜' WHEN 3 THEN '敏' WHEN 4 THEN '磊'
            WHEN 5 THEN '静' WHEN 6 THEN '洋' WHEN 7 THEN '强' WHEN 8 THEN '涛' WHEN 9 THEN '杰'
            WHEN 10 THEN '琳' WHEN 11 THEN '雪' WHEN 12 THEN '博' WHEN 13 THEN '晨' WHEN 14 THEN '宇'
            WHEN 15 THEN '轩' WHEN 16 THEN '雨桐' WHEN 17 THEN '子涵' WHEN 18 THEN '思远' WHEN 19 THEN '佳宁'
            WHEN 20 THEN '浩然' WHEN 21 THEN '梦瑶' WHEN 22 THEN '文博' WHEN 23 THEN '欣怡' WHEN 24 THEN '梓轩'
            WHEN 25 THEN '雅婷' WHEN 26 THEN '俊豪' WHEN 27 THEN '明轩' WHEN 28 THEN '嘉怡' WHEN 29 THEN '天宇'
            WHEN 30 THEN '晓彤' WHEN 31 THEN '诗涵' WHEN 32 THEN '瑞泽' WHEN 33 THEN '心怡' WHEN 34 THEN '乐天'
            WHEN 35 THEN '亦凡' WHEN 36 THEN '俊杰' WHEN 37 THEN '雨晨' WHEN 38 THEN '家豪' ELSE '若曦'
        END
    ) AS emp_name,
    MOD(s.n, 2) AS gender,
    DATE_ADD('1988-01-01', INTERVAL MOD(s.n * 37, 9500) DAY) AS birth_date,
    CONCAT('430101', DATE_FORMAT(DATE_ADD('1988-01-01', INTERVAL MOD(s.n * 37, 9500) DAY), '%Y%m%d'), LPAD(MOD(1000 + s.n, 4), 4, '0')) AS id_card,
    CONCAT('13', LPAD(200000000 + s.n, 9, '0')) AS phone,
    CONCAT('emp', 1000 + s.n, '@hrdatacenter.local') AS email,
    CASE MOD(s.n, 8)
        WHEN 0 THEN '技术部'
        WHEN 1 THEN '研发部'
        WHEN 2 THEN '市场部'
        WHEN 3 THEN '人力资源部'
        WHEN 4 THEN '财务部'
        WHEN 5 THEN '运营部'
        WHEN 6 THEN '客服部'
        ELSE '行政部'
    END AS department,
    CASE MOD(s.n, 10)
        WHEN 0 THEN '高级工程师'
        WHEN 1 THEN '开发工程师'
        WHEN 2 THEN '产品经理'
        WHEN 3 THEN '测试工程师'
        WHEN 4 THEN '算法工程师'
        WHEN 5 THEN '运营专员'
        WHEN 6 THEN '招聘专员'
        WHEN 7 THEN '会计'
        WHEN 8 THEN '销售经理'
        ELSE '数据分析师'
    END AS position,
    ROUND(
        7000
        + MOD(s.n, 15) * 900
        + CASE
            WHEN MOD(s.n, 8) IN (0, 1) THEN 2500
            WHEN MOD(s.n, 8) = 2 THEN 1800
            WHEN MOD(s.n, 8) = 4 THEN 1200
            ELSE 900
          END
    , 2) AS salary,
    DATE_ADD('2016-01-01', INTERVAL MOD(s.n * 23, 3300) DAY) AS hire_date,
    CASE
        WHEN MOD(s.n, 17) = 0 THEN DATE_ADD(DATE_ADD('2016-01-01', INTERVAL MOD(s.n * 23, 3300) DAY), INTERVAL (300 + MOD(s.n, 700)) DAY)
        ELSE NULL
    END AS resign_date,
    CASE
        WHEN MOD(s.n, 17) = 0 THEN 0
        WHEN MOD(s.n, 13) = 0 THEN 2
        ELSE 1
    END AS status,
    CASE MOD(s.n, 5)
        WHEN 0 THEN '本科'
        WHEN 1 THEN '硕士'
        WHEN 2 THEN '本科'
        WHEN 3 THEN '大专'
        ELSE '博士'
    END AS education
FROM tmp_seq s
ON DUPLICATE KEY UPDATE
    emp_name = VALUES(emp_name),
    salary = VALUES(salary),
    department = VALUES(department),
    position = VALUES(position),
    status = VALUES(status),
    education = VALUES(education),
    update_time = NOW();

-- 2) 考勤（最近 60 天工作日）
DELETE FROM attendance WHERE remark = 'AUTO_GEN_BULK';
INSERT INTO attendance (
    emp_id, attendance_date, clock_in_time, clock_out_time,
    attendance_type, attendance_status, work_duration, remark
)
SELECT
    e.emp_id,
    DATE_SUB(CURDATE(), INTERVAL d.d DAY) AS attendance_date,
    MAKETIME(8 + MOD(e.emp_id + d.d, 2), MOD(e.emp_id + d.d, 6) * 10, 0) AS clock_in_time,
    MAKETIME(18 + MOD(e.emp_id + d.d, 3), MOD(e.emp_id + d.d, 6) * 5, 0) AS clock_out_time,
    CASE
        WHEN MOD(e.emp_id + d.d, 33) = 0 THEN 5
        WHEN MOD(e.emp_id + d.d, 21) = 0 THEN 1
        ELSE 0
    END AS attendance_type,
    CASE
        WHEN MOD(e.emp_id + d.d, 33) = 0 THEN 3
        ELSE 1
    END AS attendance_status,
    510 + MOD(e.emp_id * 7 + d.d * 13, 120) AS work_duration,
    'AUTO_GEN_BULK' AS remark
FROM employee e
JOIN tmp_days d ON 1 = 1
WHERE e.deleted = 0
  AND e.status IN (1, 2)
  AND e.emp_no LIKE 'EMP1%'
  AND WEEKDAY(DATE_SUB(CURDATE(), INTERVAL d.d DAY)) < 5;

-- 3) 请假
DELETE FROM emp_leave WHERE reason LIKE 'AUTO_GEN_BULK%';
INSERT INTO emp_leave (
    emp_id, leave_type, start_time, end_time, leave_duration,
    reason, approver_id, approval_status, approval_comment, approval_time
)
SELECT
    e.emp_id,
    MOD(e.emp_id, 3) AS leave_type,
    DATE_ADD(CURDATE(), INTERVAL -MOD(e.emp_id, 40) DAY),
    DATE_ADD(DATE_ADD(CURDATE(), INTERVAL -MOD(e.emp_id, 40) DAY), INTERVAL 1 DAY),
    16,
    'AUTO_GEN_BULK-业务请假',
    1,
    1,
    '批量补数自动审批',
    NOW()
FROM employee e
WHERE e.deleted = 0
  AND e.status IN (1, 2)
  AND e.emp_no LIKE 'EMP1%'
  AND MOD(e.emp_id, 19) = 0;

-- 4) 绩效目标
DELETE FROM performance_goal WHERE goal_description LIKE 'AUTO_GEN_BULK%';
INSERT INTO performance_goal (
    emp_id, year, period_type, goal_description, weight, completion_standard, goal_status
)
SELECT
    e.emp_id,
    2025,
    1,
    CONCAT('AUTO_GEN_BULK-年度目标-', e.position),
    100,
    '达成岗位核心目标并完成月度复盘',
    1
FROM employee e
WHERE e.deleted = 0
  AND e.status IN (1, 2)
  AND e.emp_no LIKE 'EMP1%';

-- 5) 绩效评估（2025 年四个季度）
DROP TEMPORARY TABLE IF EXISTS tmp_quarters;
CREATE TEMPORARY TABLE tmp_quarters (q INT PRIMARY KEY);
INSERT INTO tmp_quarters (q) VALUES (1), (2), (3), (4);

DELETE FROM performance_evaluation WHERE self_comment LIKE 'AUTO_GEN_BULK%';
INSERT INTO performance_evaluation (
    emp_id, year, period_type, quarter, month,
    self_score, self_comment, supervisor_score, supervisor_comment,
    final_score, performance_level, improvement_plan, interview_record, interview_date, evaluation_status
)
SELECT
    e.emp_id,
    2025,
    2,
    q.q,
    NULL,
    ROUND(75 + MOD(e.emp_id + q.q * 7, 25) + MOD(e.emp_id, 10) / 10, 2) AS self_score,
    'AUTO_GEN_BULK-员工自评',
    ROUND(76 + MOD(e.emp_id + q.q * 9, 23) + MOD(e.emp_id, 10) / 10, 2) AS supervisor_score,
    'AUTO_GEN_BULK-主管评语',
    ROUND((ROUND(75 + MOD(e.emp_id + q.q * 7, 25) + MOD(e.emp_id, 10) / 10, 2) * 0.4)
        + (ROUND(76 + MOD(e.emp_id + q.q * 9, 23) + MOD(e.emp_id, 10) / 10, 2) * 0.6), 2) AS final_score,
    CASE
        WHEN ((75 + MOD(e.emp_id + q.q * 7, 25)) * 0.4 + (76 + MOD(e.emp_id + q.q * 9, 23)) * 0.6) >= 90 THEN 'S'
        WHEN ((75 + MOD(e.emp_id + q.q * 7, 25)) * 0.4 + (76 + MOD(e.emp_id + q.q * 9, 23)) * 0.6) >= 80 THEN 'A'
        WHEN ((75 + MOD(e.emp_id + q.q * 7, 25)) * 0.4 + (76 + MOD(e.emp_id + q.q * 9, 23)) * 0.6) >= 70 THEN 'B'
        WHEN ((75 + MOD(e.emp_id + q.q * 7, 25)) * 0.4 + (76 + MOD(e.emp_id + q.q * 9, 23)) * 0.6) >= 60 THEN 'C'
        ELSE 'D'
    END AS performance_level,
    'AUTO_GEN_BULK-持续改进',
    'AUTO_GEN_BULK-季度面谈',
    DATE_ADD('2025-01-15', INTERVAL (q.q - 1) * 90 DAY),
    3
FROM employee e
JOIN tmp_quarters q ON 1 = 1
WHERE e.deleted = 0
  AND e.status IN (1, 2)
  AND e.emp_no LIKE 'EMP1%';

-- 6) 薪资发放（6 个月）
INSERT INTO salary_payment (
    emp_id, year, month,
    basic_salary, performance_salary,
    position_allowance, transport_allowance, communication_allowance, meal_allowance, other_allowance,
    overtime_pay, total_gross_salary,
    social_insurance, housing_fund, income_tax, other_deduction,
    total_net_salary, payment_status, payment_date, remark
)
SELECT
    e.emp_id,
    m.y,
    m.m,
    ROUND(e.salary * (0.90 + MOD(e.emp_id + m.m, 4) * 0.03), 2) AS basic_salary,
    ROUND(e.salary * (0.10 + MOD(e.emp_id + m.m, 5) * 0.02), 2) AS performance_salary,
    ROUND(500 + MOD(e.emp_id, 8) * 120, 2) AS position_allowance,
    300.00 AS transport_allowance,
    200.00 AS communication_allowance,
    300.00 AS meal_allowance,
    0.00 AS other_allowance,
    ROUND(MOD(e.emp_id + m.m, 6) * 120, 2) AS overtime_pay,
    ROUND(
        ROUND(e.salary * (0.90 + MOD(e.emp_id + m.m, 4) * 0.03), 2)
        + ROUND(e.salary * (0.10 + MOD(e.emp_id + m.m, 5) * 0.02), 2)
        + ROUND(500 + MOD(e.emp_id, 8) * 120, 2)
        + 300 + 200 + 300 + ROUND(MOD(e.emp_id + m.m, 6) * 120, 2)
    , 2) AS total_gross_salary,
    ROUND(e.salary * 0.08, 2) AS social_insurance,
    ROUND(e.salary * 0.08, 2) AS housing_fund,
    ROUND(e.salary * 0.03, 2) AS income_tax,
    0.00 AS other_deduction,
    ROUND(
        ROUND(
            ROUND(e.salary * (0.90 + MOD(e.emp_id + m.m, 4) * 0.03), 2)
            + ROUND(e.salary * (0.10 + MOD(e.emp_id + m.m, 5) * 0.02), 2)
            + ROUND(500 + MOD(e.emp_id, 8) * 120, 2)
            + 300 + 200 + 300 + ROUND(MOD(e.emp_id + m.m, 6) * 120, 2)
        , 2)
        - ROUND(e.salary * 0.08, 2)
        - ROUND(e.salary * 0.08, 2)
        - ROUND(e.salary * 0.03, 2)
    , 2) AS total_net_salary,
    1 AS payment_status,
    LAST_DAY(m.ym) AS payment_date,
    'AUTO_GEN_BULK'
FROM employee e
JOIN tmp_months m ON 1 = 1
WHERE e.deleted = 0
  AND e.status IN (1, 2)
  AND e.emp_no LIKE 'EMP1%'
ON DUPLICATE KEY UPDATE
    basic_salary = VALUES(basic_salary),
    performance_salary = VALUES(performance_salary),
    total_gross_salary = VALUES(total_gross_salary),
    total_net_salary = VALUES(total_net_salary),
    payment_status = VALUES(payment_status),
    payment_date = VALUES(payment_date),
    remark = VALUES(remark),
    update_time = NOW();

-- 7) 薪资调整
DELETE FROM salary_adjustment WHERE reason LIKE 'AUTO_GEN_BULK%';
INSERT INTO salary_adjustment (
    emp_id, adjustment_type, before_salary, after_salary, adjustment_rate, effective_date,
    reason, approver_id, approval_status, approval_comment, approval_date, creator_id
)
SELECT
    e.emp_id,
    3,
    ROUND(e.salary * 0.95, 2),
    e.salary,
    ROUND((e.salary - ROUND(e.salary * 0.95, 2)) / ROUND(e.salary * 0.95, 2) * 100, 2),
    DATE('2025-01-01'),
    'AUTO_GEN_BULK-年度调薪',
    1,
    1,
    '批量补数自动通过',
    NOW(),
    1
FROM employee e
WHERE e.deleted = 0
  AND e.status IN (1, 2)
  AND e.emp_no LIKE 'EMP1%'
  AND MOD(e.emp_id, 10) = 0;

-- 8) 培训课程 + 报名
DELETE FROM training_enrollment WHERE feedback = 'AUTO_GEN_BULK';
DELETE FROM training_course WHERE course_name LIKE 'AUTO_GEN_BULK课程%';

INSERT INTO training_course (
    course_name, course_type, course_description, instructor, duration, location,
    start_date, end_date, capacity, enrolled_count, course_status
)
SELECT
    CONCAT('AUTO_GEN_BULK课程', LPAD(s.n, 2, '0')),
    MOD(s.n, 5) + 1,
    '批量补数课程',
    CONCAT('讲师', s.n),
    8 + MOD(s.n, 4) * 4,
    CONCAT('培训室', CHAR(65 + MOD(s.n, 5))),
    DATE_ADD('2026-01-01 09:00:00', INTERVAL s.n DAY),
    DATE_ADD('2026-01-01 17:00:00', INTERVAL s.n DAY),
    30 + MOD(s.n, 3) * 10,
    0,
    0
FROM (
    SELECT 1 AS n UNION ALL SELECT 2 UNION ALL SELECT 3 UNION ALL SELECT 4 UNION ALL SELECT 5 UNION ALL SELECT 6
    UNION ALL SELECT 7 UNION ALL SELECT 8 UNION ALL SELECT 9 UNION ALL SELECT 10 UNION ALL SELECT 11 UNION ALL SELECT 12
) s;

DROP TEMPORARY TABLE IF EXISTS tmp_training_course_ids;
CREATE TEMPORARY TABLE tmp_training_course_ids (
    course_id BIGINT PRIMARY KEY
);
INSERT INTO tmp_training_course_ids (course_id)
SELECT course_id
FROM training_course
WHERE course_name LIKE 'AUTO_GEN_BULK课程%';

INSERT INTO training_enrollment (
    course_id, emp_id, enrollment_time, approval_status, approver_id, attendance_status, score, feedback
)
SELECT
    c.course_id,
    e.emp_id,
    DATE_SUB(NOW(), INTERVAL MOD(e.emp_id, 20) DAY),
    1,
    1,
    CASE WHEN MOD(e.emp_id, 10) = 0 THEN 2 ELSE 1 END,
    70 + MOD(e.emp_id, 31),
    'AUTO_GEN_BULK'
FROM tmp_training_course_ids c
JOIN employee e ON e.deleted = 0 AND e.status IN (1, 2) AND e.emp_no LIKE 'EMP1%'
WHERE MOD(e.emp_id + c.course_id, 9) = 0;

-- 8.1) 清洗历史脏姓名（数字名/新增员工/测试员工/Hive前缀）
UPDATE employee
SET emp_name = CONCAT(
    CASE MOD(emp_id, 30)
        WHEN 0 THEN '王' WHEN 1 THEN '李' WHEN 2 THEN '张' WHEN 3 THEN '刘' WHEN 4 THEN '陈'
        WHEN 5 THEN '杨' WHEN 6 THEN '赵' WHEN 7 THEN '黄' WHEN 8 THEN '周' WHEN 9 THEN '吴'
        WHEN 10 THEN '徐' WHEN 11 THEN '孙' WHEN 12 THEN '马' WHEN 13 THEN '朱' WHEN 14 THEN '胡'
        WHEN 15 THEN '郭' WHEN 16 THEN '何' WHEN 17 THEN '高' WHEN 18 THEN '林' WHEN 19 THEN '罗'
        WHEN 20 THEN '郑' WHEN 21 THEN '梁' WHEN 22 THEN '谢' WHEN 23 THEN '宋' WHEN 24 THEN '唐'
        WHEN 25 THEN '韩' WHEN 26 THEN '冯' WHEN 27 THEN '于' WHEN 28 THEN '董' ELSE '萧'
    END,
    CASE MOD(emp_id, 40)
        WHEN 0 THEN '伟' WHEN 1 THEN '芳' WHEN 2 THEN '娜' WHEN 3 THEN '敏' WHEN 4 THEN '磊'
        WHEN 5 THEN '静' WHEN 6 THEN '洋' WHEN 7 THEN '强' WHEN 8 THEN '涛' WHEN 9 THEN '杰'
        WHEN 10 THEN '琳' WHEN 11 THEN '雪' WHEN 12 THEN '博' WHEN 13 THEN '晨' WHEN 14 THEN '宇'
        WHEN 15 THEN '轩' WHEN 16 THEN '雨桐' WHEN 17 THEN '子涵' WHEN 18 THEN '思远' WHEN 19 THEN '佳宁'
        WHEN 20 THEN '浩然' WHEN 21 THEN '梦瑶' WHEN 22 THEN '文博' WHEN 23 THEN '欣怡' WHEN 24 THEN '梓轩'
        WHEN 25 THEN '雅婷' WHEN 26 THEN '俊豪' WHEN 27 THEN '明轩' WHEN 28 THEN '嘉怡' WHEN 29 THEN '天宇'
        WHEN 30 THEN '晓彤' WHEN 31 THEN '诗涵' WHEN 32 THEN '瑞泽' WHEN 33 THEN '心怡' WHEN 34 THEN '乐天'
        WHEN 35 THEN '亦凡' WHEN 36 THEN '俊杰' WHEN 37 THEN '雨晨' WHEN 38 THEN '家豪' ELSE '若曦'
    END
)
WHERE deleted = 0
  AND (emp_name REGEXP '[0-9]' OR emp_name LIKE '员工%' OR emp_name LIKE '新增员工%' OR emp_name LIKE '测试员工%' OR emp_name LIKE 'Hive%');

-- 9) 兼容分析模块：确保 dim_employee 可查
CREATE OR REPLACE VIEW dim_employee AS
SELECT
    emp_id,
    emp_no,
    emp_name,
    gender,
    birth_date,
    id_card,
    phone,
    email,
    department,
    position,
    salary AS current_salary,
    hire_date,
    resign_date,
    status,
    education,
    DATE_FORMAT(COALESCE(update_time, create_time, NOW()), '%Y%m%d') AS dt
FROM employee
WHERE deleted = 0;

SET FOREIGN_KEY_CHECKS = 1;

SELECT
    'MySQL批量补数完成' AS status,
    (SELECT COUNT(*) FROM employee WHERE deleted = 0) AS employee_count,
    (SELECT COUNT(*) FROM attendance WHERE deleted = 0) AS attendance_count,
    (SELECT COUNT(*) FROM salary_payment WHERE deleted = 0) AS salary_payment_count,
    (SELECT COUNT(*) FROM performance_evaluation WHERE deleted = 0) AS performance_eval_count;
-- ============================================================================
-- 人力资源数据中心系统 - 更新用户密码SQL脚本
-- 使用项目原生的BCrypt加密器生成的密文，确保100%兼容
-- ============================================================================

USE hr_datacenter;

-- 更新管理员账号 admin (密码: 123456)
UPDATE sys_user SET password = '$2a$10$FdfhJ8LfmYT.mWXFa5Ba3.niJvVgJMxmM5lrPpsxxpDXeSom7Mr5C'
WHERE username = 'admin';

-- 更新HR账号 hr001 (密码: 123456)
UPDATE sys_user SET password = '$2a$10$FdfhJ8LfmYT.mWXFa5Ba3.niJvVgJMxmM5lrPpsxxpDXeSom7Mr5C'
WHERE username = 'hr001';

-- 添加更多测试用户（可选）
-- INSERT INTO sys_user (username, password, real_name, dept_id, phone, email, status) VALUES
-- ('test001', '$2a$10$FdfhJ8LfmYT.mWXFa5Ba3.niJvVgJMxmM5lrPpsxxpDXeSom7Mr5C', '测试用户', 1, '13800138002', 'test001@hrdatacenter.com', 1);

COMMIT;

-- 验证更新结果
SELECT user_id, username, real_name, LEFT(password, 20) as '密码前20位', status
FROM sys_user
WHERE deleted = 0;

-- ============================================================================
-- 常用密码的BCrypt密文对照表（由项目原生BCrypt生成）
-- ============================================================================
-- 明文: 123456    -> 密文: $2a$10$FdfhJ8LfmYT.mWXFa5Ba3.niJvVgJMxmM5lrPpsxxpDXeSom7Mr5C
-- 明文: admin     -> 密文: $2a$10$9We7aqjdBilyhWyvxhdpNOc4SkfP1CmYrt0MU9qByRZt9MAoPgvfW
-- 明文: password  -> 密文: $2a$10$j4dS01gsJwQa9/NFTFBM2eiW1pKYLExwGH9cJliq0AGnf9MHEnjfu
-- 明文: test123   -> 密文: $2a$10$0yzz5.kLSx.2fP3SqRG7dOWtXFM3MlXY6wuTGuuHkkCkNVsoFEDY2
-- 明文: hr123456  -> 密文: $2a$10$YsH2LoJxtbj87XEZr7Nm9OU3nSmXbE7zDLbEYRSirO6utwUKrKAHW
-- ============================================================================

-- ============================================================================
-- 如何生成新的密码密文
-- ============================================================================
-- 方法1: 运行项目自带的密码生成工具
-- cd backend
-- mvn exec:java -Dexec.mainClass="com.hr.datacenter.util.PasswordGenerator"

-- 方法2: 修改 PasswordGenerator.java 中的密码，然后重新运行
-- 编辑文件: backend/src/main/java/com/hr/datacenter/util/PasswordGenerator.java
-- 修改第10行的 String rawPassword = "你的密码";
-- 然后运行: mvn exec:java -Dexec.mainClass="com.hr.datacenter.util.PasswordGenerator"
-- ============================================================================