-- 2026-04-16 增量补丁：角色字段、招聘模块
USE `hr_datacenter`;

-- 说明：`hr_datacenter_mysql_init.sql` 已包含 `sys_user.role_code`。
-- 以下 UPDATE 仅用于从极老库升级时对齐角色；全新初始化时亦可安全执行。

UPDATE `sys_user` SET `role_code` = 'ROLE_ADMIN' WHERE `username` = 'admin';
UPDATE `sys_user` SET `role_code` = 'ROLE_HR_ADMIN' WHERE `username` = 'hr001';
UPDATE `sys_user` SET `role_code` = 'ROLE_EMPLOYEE' WHERE `role_code` IS NULL OR `role_code` = '';

CREATE TABLE IF NOT EXISTS `recruitment_plan` (
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

CREATE TABLE IF NOT EXISTS `report_execution_log` (
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

CREATE TABLE IF NOT EXISTS `report_share_log` (
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

INSERT INTO `analysis_rule` (`rule_name`, `rule_type`, `rule_key`, `rule_value`, `effect_status`, `change_log`)
SELECT '流失预警高风险阈值', 'turnover', 'turnover.highRiskThreshold', '0.70', 1, '2026-04-16 初始化'
WHERE NOT EXISTS (SELECT 1 FROM `analysis_rule` WHERE `rule_key` = 'turnover.highRiskThreshold');

INSERT INTO `analysis_rule` (`rule_name`, `rule_type`, `rule_key`, `rule_value`, `effect_status`, `change_log`)
SELECT '流失预警中风险阈值', 'turnover', 'turnover.mediumRiskThreshold', '0.40', 1, '2026-04-16 初始化'
WHERE NOT EXISTS (SELECT 1 FROM `analysis_rule` WHERE `rule_key` = 'turnover.mediumRiskThreshold');

INSERT INTO `analysis_rule` (`rule_name`, `rule_type`, `rule_key`, `rule_value`, `effect_status`, `change_log`)
SELECT '人才缺口基础团队规模', 'talentGap', 'talentGap.minTeamSize', '3', 1, '2026-04-16 初始化'
WHERE NOT EXISTS (SELECT 1 FROM `analysis_rule` WHERE `rule_key` = 'talentGap.minTeamSize');

INSERT INTO `analysis_rule` (`rule_name`, `rule_type`, `rule_key`, `rule_value`, `effect_status`, `change_log`)
SELECT '人才缺口技术团队规模', 'talentGap', 'talentGap.techTeamSize', '8', 1, '2026-04-16 初始化'
WHERE NOT EXISTS (SELECT 1 FROM `analysis_rule` WHERE `rule_key` = 'talentGap.techTeamSize');

INSERT INTO `analysis_rule` (`rule_name`, `rule_type`, `rule_key`, `rule_value`, `effect_status`, `change_log`)
SELECT '成本预警预算系数', 'cost', 'cost.budgetMultiplier', '1.10', 1, '2026-04-16 初始化'
WHERE NOT EXISTS (SELECT 1 FROM `analysis_rule` WHERE `rule_key` = 'cost.budgetMultiplier');

INSERT INTO `warning_model` (`model_name`, `model_type`, `feature_weights`, `accuracy_rate`, `model_version`, `status`)
SELECT '员工流失预警模型', 'turnover', '{\"tenure\":0.30,\"salary\":0.25,\"education\":0.20,\"position\":0.15,\"department\":0.10}', 0.8400, 'v1.0', 1
WHERE NOT EXISTS (SELECT 1 FROM `warning_model` WHERE `model_type` = 'turnover');

INSERT INTO `warning_model` (`model_name`, `model_type`, `feature_weights`, `accuracy_rate`, `model_version`, `status`)
SELECT '人才缺口预警模型', 'talentGap', '{\"department\":0.35,\"position\":0.35,\"structure\":0.30}', 0.8100, 'v1.0', 1
WHERE NOT EXISTS (SELECT 1 FROM `warning_model` WHERE `model_type` = 'talentGap');

INSERT INTO `warning_model` (`model_name`, `model_type`, `feature_weights`, `accuracy_rate`, `model_version`, `status`)
SELECT '成本超支预警模型', 'cost', '{\"budget\":0.40,\"avgSalary\":0.30,\"headcount\":0.30}', 0.8000, 'v1.0', 1
WHERE NOT EXISTS (SELECT 1 FROM `warning_model` WHERE `model_type` = 'cost');

INSERT INTO `report_task` (`task_name`, `report_type`, `cron_expr`, `share_target`, `status`)
SELECT '每日预警概览报表', 'warning', '0 0 9 * * ?', 'admin,hr001', 1
WHERE NOT EXISTS (SELECT 1 FROM `report_task` WHERE `task_name` = '每日预警概览报表');

INSERT INTO `report_task` (`task_name`, `report_type`, `cron_expr`, `share_target`, `status`)
SELECT '每周组织效能报表', 'org', '0 0 10 ? * MON', 'admin', 1
WHERE NOT EXISTS (SELECT 1 FROM `report_task` WHERE `task_name` = '每周组织效能报表');

INSERT INTO `report_task` (`task_name`, `report_type`, `cron_expr`, `share_target`, `status`)
SELECT '每月薪酬分析报表', 'salary', '0 0 11 1 * ?', 'admin,hr001', 1
WHERE NOT EXISTS (SELECT 1 FROM `report_task` WHERE `task_name` = '每月薪酬分析报表');
