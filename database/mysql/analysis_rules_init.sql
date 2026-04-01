-- =====================================================
-- 人力资源数据中心系统 - 分析规则管理功能数据库初始化脚本
-- 创建时间：2026-03-24
-- 说明：本脚本创建分析规则管理、预警模型管理、报表定时任务、
--       培训反馈、绩效改进计划等功能所需的数据库表
-- =====================================================

USE hr_data_center;

-- =====================================================
-- 1. 分析规则表
-- =====================================================
CREATE TABLE IF NOT EXISTS `analysis_rule` (
  `id` BIGINT NOT NULL AUTO_INCREMENT COMMENT '主键ID',
  `rule_id` VARCHAR(50) NOT NULL COMMENT '规则唯一标识，格式：RULE_YYYYMMDD_NNNN',
  `rule_type` VARCHAR(50) NOT NULL COMMENT '规则类型：TURNOVER_WARNING-流失预警, COMPENSATION_BENCHMARK-薪酬对标, TRAINING_ROI-培训ROI, PERFORMANCE_EVAL-绩效评估, TALENT_GAP-人才缺口',
  `rule_name` VARCHAR(50) NOT NULL COMMENT '规则名称',
  `rule_params` TEXT NOT NULL COMMENT '规则参数，JSON格式，包含具体的阈值、权重等参数',
  `is_active` TINYINT(1) DEFAULT 0 COMMENT '生效状态：0-未生效，1-已生效',
  `created_by` VARCHAR(50) NOT NULL COMMENT '创建人',
  `created_time` DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',
  `updated_by` VARCHAR(50) NOT NULL COMMENT '最后修改人',
  `updated_time` DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT '最后修改时间',
  PRIMARY KEY (`id`),
  UNIQUE KEY `uk_rule_id` (`rule_id`),
  UNIQUE KEY `uk_rule_name` (`rule_name`),
  KEY `idx_rule_type` (`rule_type`),
  KEY `idx_is_active` (`is_active`),
  KEY `idx_created_time` (`created_time`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COMMENT='分析规则表';

-- =====================================================
-- 2. 规则调整日志表
-- =====================================================
CREATE TABLE IF NOT EXISTS `rule_adjustment_log` (
  `id` BIGINT NOT NULL AUTO_INCREMENT COMMENT '主键ID',
  `log_id` VARCHAR(50) NOT NULL COMMENT '日志唯一标识',
  `rule_id` VARCHAR(50) NOT NULL COMMENT '关联的分析规则ID',
  `adjustment_type` VARCHAR(20) NOT NULL COMMENT '调整类型：CREATE-创建, UPDATE-更新, ACTIVATE-激活, DEACTIVATE-失效, DELETE-删除',
  `old_value` TEXT COMMENT '调整前的值，JSON格式',
  `new_value` TEXT COMMENT '调整后的值，JSON格式',
  `adjusted_by` VARCHAR(50) NOT NULL COMMENT '调整人',
  `adjusted_time` DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT '调整时间',
  `remark` VARCHAR(200) COMMENT '调整备注',
  PRIMARY KEY (`id`),
  UNIQUE KEY `uk_log_id` (`log_id`),
  KEY `idx_rule_id` (`rule_id`),
  KEY `idx_adjusted_time` (`adjusted_time`),
  KEY `idx_adjustment_type` (`adjustment_type`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COMMENT='规则调整日志表';

-- =====================================================
-- 3. 预警模型表
-- =====================================================
CREATE TABLE IF NOT EXISTS `warning_model` (
  `id` BIGINT NOT NULL AUTO_INCREMENT COMMENT '主键ID',
  `model_id` VARCHAR(50) NOT NULL COMMENT '模型唯一标识，格式：MODEL_YYYYMMDD_NNNN',
  `model_type` VARCHAR(50) NOT NULL COMMENT '模型类型：TURNOVER_PREDICTION-流失预测, TALENT_GAP-人才缺口, COST_OVERSPEED-成本超支',
  `model_name` VARCHAR(50) NOT NULL COMMENT '模型名称',
  `feature_weights` TEXT NOT NULL COMMENT '特征权重，JSON格式，如{"age": 0.2, "performance": 0.3, "salary": 0.5}，所有权重之和必须等于1',
  `accuracy_rate` DECIMAL(5,4) COMMENT '准确率，取值范围0-1，初始值为NULL',
  `version` VARCHAR(20) NOT NULL COMMENT '模型版本，格式：v1.0, v1.1等',
  `is_active` TINYINT(1) DEFAULT 0 COMMENT '是否启用：0-未启用，1-已启用',
  `created_by` VARCHAR(50) NOT NULL COMMENT '创建人',
  `created_time` DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',
  PRIMARY KEY (`id`),
  UNIQUE KEY `uk_model_id` (`model_id`),
  KEY `idx_model_type` (`model_type`),
  KEY `idx_is_active` (`is_active`),
  KEY `idx_created_time` (`created_time`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COMMENT='预警模型表';

-- =====================================================
-- 4. 报表定时任务表
-- =====================================================
CREATE TABLE IF NOT EXISTS `report_schedule_task` (
  `id` BIGINT NOT NULL AUTO_INCREMENT COMMENT '主键ID',
  `task_id` VARCHAR(50) NOT NULL COMMENT '任务唯一标识',
  `template_id` VARCHAR(50) NOT NULL COMMENT '关联的报表模板ID',
  `task_name` VARCHAR(50) NOT NULL COMMENT '任务名称',
  `schedule_type` VARCHAR(20) NOT NULL COMMENT '调度类型：DAILY-日报, WEEKLY-周报, MONTHLY-月报',
  `execute_time` VARCHAR(50) NOT NULL COMMENT '执行时间，格式：HH:MM（日报）或DAY HH:MM（周报/月报）',
  `share_permissions` VARCHAR(200) NOT NULL COMMENT '分享权限，JSON数组格式，如["HR_ADMIN", "DEPT_HEAD"]',
  `link_expiry_days` INT NOT NULL COMMENT '链接有效期天数，取值范围1-365',
  `is_active` TINYINT(1) DEFAULT 1 COMMENT '是否启用：0-未启用，1-已启用',
  `created_by` VARCHAR(50) NOT NULL COMMENT '创建人',
  `created_time` DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',
  PRIMARY KEY (`id`),
  UNIQUE KEY `uk_task_id` (`task_id`),
  KEY `idx_template_id` (`template_id`),
  KEY `idx_is_active` (`is_active`),
  KEY `idx_created_time` (`created_time`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COMMENT='报表定时任务表';

-- =====================================================
-- 5. 报表分享记录表
-- =====================================================
CREATE TABLE IF NOT EXISTS `report_share_record` (
  `id` BIGINT NOT NULL AUTO_INCREMENT COMMENT '主键ID',
  `share_id` VARCHAR(50) NOT NULL COMMENT '分享记录唯一标识',
  `task_id` VARCHAR(50) NOT NULL COMMENT '关联的定时任务ID',
  `report_file_path` VARCHAR(500) NOT NULL COMMENT '报表文件存储路径',
  `share_link` VARCHAR(500) NOT NULL COMMENT '分享链接，包含唯一token',
  `share_permissions` VARCHAR(200) NOT NULL COMMENT '分享权限，JSON数组格式',
  `expiry_time` DATETIME NOT NULL COMMENT '链接过期时间',
  `created_time` DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',
  PRIMARY KEY (`id`),
  UNIQUE KEY `uk_share_id` (`share_id`),
  KEY `idx_task_id` (`task_id`),
  KEY `idx_expiry_time` (`expiry_time`),
  KEY `idx_created_time` (`created_time`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COMMENT='报表分享记录表';

-- =====================================================
-- 6. 培训效果反馈表
-- =====================================================
CREATE TABLE IF NOT EXISTS `training_feedback` (
  `id` BIGINT NOT NULL AUTO_INCREMENT COMMENT '主键ID',
  `feedback_id` VARCHAR(50) NOT NULL COMMENT '反馈唯一标识',
  `training_id` VARCHAR(50) NOT NULL COMMENT '关联的培训记录ID',
  `employee_id` VARCHAR(50) NOT NULL COMMENT '员工ID',
  `satisfaction_score` INT NOT NULL COMMENT '培训满意度评分，取值范围1-5',
  `skill_improvement` INT NOT NULL COMMENT '技能提升程度，取值范围1-5',
  `application_effect` INT NOT NULL COMMENT '应用效果，取值范围1-5',
  `feedback_content` VARCHAR(500) COMMENT '反馈内容',
  `feedback_by` VARCHAR(50) NOT NULL COMMENT '反馈人',
  `feedback_time` DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT '反馈时间',
  PRIMARY KEY (`id`),
  UNIQUE KEY `uk_feedback_id` (`feedback_id`),
  KEY `idx_training_id` (`training_id`),
  KEY `idx_employee_id` (`employee_id`),
  KEY `idx_feedback_time` (`feedback_time`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COMMENT='培训效果反馈表';

-- =====================================================
-- 7. 绩效改进计划表
-- =====================================================
CREATE TABLE IF NOT EXISTS `performance_improvement_plan` (
  `id` BIGINT NOT NULL AUTO_INCREMENT COMMENT '主键ID',
  `plan_id` VARCHAR(50) NOT NULL COMMENT '计划唯一标识',
  `employee_id` VARCHAR(50) NOT NULL COMMENT '员工ID',
  `improvement_goal` VARCHAR(200) NOT NULL COMMENT '改进目标',
  `action_steps` TEXT NOT NULL COMMENT '执行步骤，JSON数组格式',
  `target_completion_time` DATE NOT NULL COMMENT '目标完成时间',
  `current_progress` INT DEFAULT 0 COMMENT '当前进度，取值范围0-100',
  `completion_status` VARCHAR(20) NOT NULL DEFAULT 'NOT_STARTED' COMMENT '完成状态：NOT_STARTED-未开始, IN_PROGRESS-进行中, COMPLETED-已完成, DELAYED-延期',
  `actual_completion_time` DATE COMMENT '实际完成时间',
  `improvement_effect` VARCHAR(200) COMMENT '改进效果',
  `created_by` VARCHAR(50) NOT NULL COMMENT '创建人',
  `created_time` DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',
  `updated_by` VARCHAR(50) NOT NULL COMMENT '最后更新人',
  `updated_time` DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT '最后更新时间',
  PRIMARY KEY (`id`),
  UNIQUE KEY `uk_plan_id` (`plan_id`),
  KEY `idx_employee_id` (`employee_id`),
  KEY `idx_completion_status` (`completion_status`),
  KEY `idx_created_time` (`created_time`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COMMENT='绩效改进计划表';

-- =====================================================
-- 插入初始数据
-- =====================================================

-- 插入默认分析规则
INSERT INTO `analysis_rule` (`rule_id`, `rule_type`, `rule_name`, `rule_params`, `is_active`, `created_by`, `updated_by`) VALUES
('RULE_20260324_0001', 'TURNOVER_WARNING', '员工流失预警规则', '{"threshold": 0.15, "timeWindow": "6个月", "alertLevel": "medium"}', 1, 'admin', 'admin'),
('RULE_20260324_0002', 'COMPENSATION_BENCHMARK', '薪酬竞争力对标规则', '{"marketPercentile": 75, "deviationThreshold": 0.2}', 1, 'admin', 'admin'),
('RULE_20260324_0003', 'TRAINING_ROI', '培训ROI计算规则', '{"minROI": 1.5, "costIncludeSalary": true}', 0, 'admin', 'admin'),
('RULE_20260324_0004', 'PERFORMANCE_EVAL', '绩效评估规则', '{"excellentThreshold": 90, "goodThreshold": 75, "passThreshold": 60}', 1, 'admin', 'admin'),
('RULE_20260324_0005', 'TALENT_GAP', '人才缺口预警规则', '{"gapThreshold": 0.3, "keyPositions": ["技术总监", "产品经理", "架构师"]}', 0, 'admin', 'admin');

-- 插入默认预警模型
INSERT INTO `warning_model` (`model_id`, `model_type`, `model_name`, `feature_weights`, `accuracy_rate`, `version`, `is_active`, `created_by`) VALUES
('MODEL_20260324_0001', 'TURNOVER_PREDICTION', '员工流失预测模型', '{"age": 0.15, "performance": 0.25, "salary": 0.25, "tenure": 0.20, "satisfaction": 0.15}', 0.82, 'v1.0', 1, 'admin'),
('MODEL_20260324_0002', 'TALENT_GAP', '人才缺口预测模型', '{"businessGrowth": 0.30, "turnoverRate": 0.25, "retirementRate": 0.20, "marketDemand": 0.25}', NULL, 'v1.0', 0, 'admin'),
('MODEL_20260324_0003', 'COST_OVERSPEED', '人力成本超支预警模型', '{"salaryGrowth": 0.35, "headcountGrowth": 0.30, "benefitGrowth": 0.20, "overtimeCost": 0.15}', NULL, 'v1.0', 0, 'admin');

-- =====================================================
-- 完成提示
-- =====================================================
SELECT '数据库表创建成功！' AS '执行结果';
SELECT COUNT(*) AS '分析规则表记录数' FROM analysis_rule;
SELECT COUNT(*) AS '预警模型表记录数' FROM warning_model;
