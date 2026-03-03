-- ============================================================
-- 人力资源数据中心系统 - MySQL 数据库初始化脚本
-- 数据库: hr_db | MySQL 8.0.33
-- 说明: 建库建表 + 不少于10条初始数据（每张业务表）
-- ============================================================

SET NAMES utf8mb4;
SET FOREIGN_KEY_CHECKS = 0;

-- 创建数据库
CREATE DATABASE IF NOT EXISTS hr_db DEFAULT CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;
USE hr_db;

-- ------------------------------------------------------------
-- 1. 部门表 hr_department
-- ------------------------------------------------------------
DROP TABLE IF EXISTS `hr_department`;
CREATE TABLE `hr_department` (
  `id` bigint NOT NULL AUTO_INCREMENT COMMENT '主键ID',
  `name` varchar(50) NOT NULL COMMENT '部门名称',
  `parent_id` bigint DEFAULT '0' COMMENT '父部门ID: 0=顶级',
  `sort_order` int DEFAULT '0' COMMENT '排序序号',
  PRIMARY KEY (`id`),
  KEY `idx_parent_id` (`parent_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci COMMENT='部门表';

INSERT INTO `hr_department` (`name`, `parent_id`, `sort_order`) VALUES
('销售部', 0, 1),
('研发部', 0, 2),
('人事部', 0, 3),
('财务部', 0, 4),
('市场部', 0, 5),
('运营部', 0, 6),
('客服部', 0, 7),
('采购部', 0, 8),
('生产部', 0, 9),
('技术部', 0, 10);

-- ------------------------------------------------------------
-- 2. 用户表 sys_user
-- 密码均为 123456 的 BCrypt 加密
-- ------------------------------------------------------------
DROP TABLE IF EXISTS `sys_user`;
CREATE TABLE `sys_user` (
  `id` bigint NOT NULL AUTO_INCREMENT COMMENT '主键ID',
  `username` varchar(50) NOT NULL COMMENT '工号',
  `password` varchar(100) NOT NULL COMMENT 'BCrypt加密密码',
  `name` varchar(50) NOT NULL DEFAULT '' COMMENT '姓名',
  `role` varchar(20) NOT NULL COMMENT '角色: HR_ADMIN/DEPT_HEAD/MANAGEMENT/EMPLOYEE',
  `dept_id` bigint DEFAULT NULL COMMENT '所属部门ID',
  `dept_name` varchar(50) DEFAULT NULL COMMENT '部门名称',
  `dept_scope` text COMMENT '部门范围JSON数组 [101,102,103]',
  `phone` varchar(20) DEFAULT NULL COMMENT '手机号',
  `email` varchar(100) DEFAULT NULL COMMENT '邮箱',
  `status` tinyint DEFAULT '1' COMMENT '状态: 0=禁用 1=启用',
  `is_deleted` tinyint DEFAULT '0' COMMENT '逻辑删除: 0=正常 1=已删除',
  `create_time` datetime DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',
  `update_time` datetime DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT '更新时间',
  PRIMARY KEY (`id`),
  UNIQUE KEY `uk_username` (`username`),
  KEY `idx_dept_id` (`dept_id`),
  KEY `idx_role` (`role`),
  KEY `idx_status` (`status`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci COMMENT='用户表';

INSERT INTO `sys_user` (`username`, `password`, `name`, `role`, `dept_id`, `dept_name`, `dept_scope`, `phone`, `email`, `status`) VALUES
-- 密码均为 123456，BCrypt 哈希（与 Spring Security 兼容）
('admin', '$2a$10$dXJ3SW6G7P50lGmMkkmwe.20cQQubK3.HZWzG3YB1tlRy.fqvM/BG', 'HR管理员', 'HR_ADMIN', 3, '人事部', '[1,2,3,4,5,6,7,8,9,10]', '13800000001', 'admin@hr.com', 1),
('1001', '$2a$10$dXJ3SW6G7P50lGmMkkmwe.20cQQubK3.HZWzG3YB1tlRy.fqvM/BG', '张三', 'DEPT_HEAD', 1, '销售部', '[1]', '13800000002', 'zhangsan@hr.com', 1),
('1002', '$2a$10$dXJ3SW6G7P50lGmMkkmwe.20cQQubK3.HZWzG3YB1tlRy.fqvM/BG', '李四', 'DEPT_HEAD', 2, '研发部', '[2]', '13800000003', 'lisi@hr.com', 1),
('2001', '$2a$10$dXJ3SW6G7P50lGmMkkmwe.20cQQubK3.HZWzG3YB1tlRy.fqvM/BG', '王五', 'MANAGEMENT', 3, '人事部', '[1,2,3,4,5]', '13800000004', 'wangwu@hr.com', 1),
('3001', '$2a$10$dXJ3SW6G7P50lGmMkkmwe.20cQQubK3.HZWzG3YB1tlRy.fqvM/BG', '赵六', 'EMPLOYEE', 1, '销售部', NULL, '13800000005', 'zhaoliu@hr.com', 1),
('3002', '$2a$10$dXJ3SW6G7P50lGmMkkmwe.20cQQubK3.HZWzG3YB1tlRy.fqvM/BG', '钱七', 'EMPLOYEE', 2, '研发部', NULL, '13800000006', 'qianqi@hr.com', 1),
('3003', '$2a$10$dXJ3SW6G7P50lGmMkkmwe.20cQQubK3.HZWzG3YB1tlRy.fqvM/BG', '孙八', 'EMPLOYEE', 1, '销售部', NULL, '13800000007', 'sunba@hr.com', 1),
('3004', '$2a$10$dXJ3SW6G7P50lGmMkkmwe.20cQQubK3.HZWzG3YB1tlRy.fqvM/BG', '周九', 'EMPLOYEE', 3, '人事部', NULL, '13800000008', 'zhoujiu@hr.com', 1),
('3005', '$2a$10$dXJ3SW6G7P50lGmMkkmwe.20cQQubK3.HZWzG3YB1tlRy.fqvM/BG', '吴十', 'EMPLOYEE', 4, '财务部', NULL, '13800000009', 'wushi@hr.com', 1),
('1003', '$2a$10$dXJ3SW6G7P50lGmMkkmwe.20cQQubK3.HZWzG3YB1tlRy.fqvM/BG', '郑十一', 'DEPT_HEAD', 4, '财务部', '[4]', '13800000010', 'zheng@hr.com', 1);

-- ------------------------------------------------------------
-- 3. 数据分类表 hr_data_category
-- ------------------------------------------------------------
DROP TABLE IF EXISTS `hr_data_category`;
CREATE TABLE `hr_data_category` (
  `id` bigint NOT NULL AUTO_INCREMENT COMMENT '主键ID',
  `name` varchar(50) NOT NULL COMMENT '分类名称',
  `parent_id` bigint DEFAULT '0' COMMENT '父分类ID: 0=顶级',
  `sort_order` int DEFAULT '0' COMMENT '排序序号',
  PRIMARY KEY (`id`),
  KEY `idx_parent_id` (`parent_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci COMMENT='数据分类表';

INSERT INTO `hr_data_category` (`name`, `parent_id`, `sort_order`) VALUES
('组织效能分析', 0, 1),
('人才梯队建设', 0, 2),
('薪酬福利分析', 0, 3),
('绩效管理体系', 0, 4),
('员工流失预警', 0, 5),
('培训效果评估', 0, 6),
('人力成本优化', 0, 7),
('人才发展预测', 0, 8);

-- ------------------------------------------------------------
-- 4. 员工档案表 employee_profile
-- category_id 1~8 对应上述八大数据分类
-- ------------------------------------------------------------
DROP TABLE IF EXISTS `employee_profile`;
CREATE TABLE `employee_profile` (
  `id` bigint NOT NULL AUTO_INCREMENT COMMENT '主键ID',
  `employee_no` varchar(50) DEFAULT NULL COMMENT '员工编号',
  `name` varchar(50) DEFAULT NULL COMMENT '姓名',
  `dept_id` bigint DEFAULT NULL COMMENT '部门ID',
  `dept_name` varchar(50) DEFAULT NULL COMMENT '部门名称(冗余)',
  `job` varchar(50) DEFAULT NULL COMMENT '岗位',
  `category_id` bigint DEFAULT NULL COMMENT '数据分类ID',
  `value` float DEFAULT NULL COMMENT '指标值',
  `period` varchar(20) DEFAULT NULL COMMENT '统计周期(YYYYMM)',
  `is_deleted` tinyint DEFAULT '0' COMMENT '逻辑删除: 0=正常 1=已删除',
  `create_time` datetime DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',
  PRIMARY KEY (`id`),
  KEY `idx_employee_no` (`employee_no`),
  KEY `idx_dept_id` (`dept_id`),
  KEY `idx_category_id` (`category_id`),
  KEY `idx_period` (`period`),
  KEY `idx_category_period` (`category_id`, `period`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci COMMENT='员工档案表';

INSERT INTO `employee_profile` (`employee_no`, `name`, `dept_id`, `dept_name`, `job`, `category_id`, `value`, `period`) VALUES
('E001', '张三', 1, '销售部', '销售经理', 1, 88.5, '202601'),
('E002', '李四', 2, '研发部', '高级工程师', 1, 92.0, '202601'),
('E003', '王五', 1, '销售部', '销售代表', 1, 78.0, '202601'),
('E004', '赵六', 2, '研发部', '工程师', 2, 85.0, '202601'),
('E005', '钱七', 3, '人事部', 'HR专员', 2, 82.0, '202601'),
('E006', '孙八', 1, '销售部', '销售代表', 3, 12500.0, '202601'),
('E007', '周九', 2, '研发部', '工程师', 3, 18500.0, '202601'),
('E008', '吴十', 1, '销售部', '销售代表', 4, 86.0, '202601'),
('E009', '郑十一', 2, '研发部', '高级工程师', 4, 91.0, '202601'),
('E010', '陈十二', 1, '销售部', '销售代表', 5, 6.5, '202601'),
('E011', '林十三', 2, '研发部', '工程师', 5, 3.2, '202601'),
('E012', '黄十四', 3, '人事部', '培训专员', 6, 88.0, '202601'),
('E013', '刘十五', 2, '研发部', '工程师', 6, 90.0, '202601'),
('E014', '杨十六', 4, '财务部', '会计', 7, 9500.0, '202601'),
('E015', '何十七', 1, '销售部', '销售经理', 7, 12000.0, '202601'),
('E016', '马十八', 2, '研发部', '架构师', 8, 92.0, '202601'),
('E017', '罗十九', 3, '人事部', '招聘专员', 8, 85.0, '202601'),
('E018', '梁二十', 1, '销售部', '销售代表', 1, 80.0, '202602'),
('E019', '宋二一', 2, '研发部', '工程师', 2, 88.0, '202602'),
('E020', '唐二二', 4, '财务部', '出纳', 3, 7500.0, '202602');

-- ------------------------------------------------------------
-- 5. 预警规则表 warning_rule
-- ------------------------------------------------------------
DROP TABLE IF EXISTS `warning_rule`;
CREATE TABLE `warning_rule` (
  `id` bigint NOT NULL AUTO_INCREMENT COMMENT '主键ID',
  `rule_type` varchar(20) NOT NULL COMMENT '规则类型: FLIGHT_RISK/TALENT_SHORTAGE/COST_OVER',
  `threshold` float NOT NULL COMMENT '阈值',
  `description` varchar(200) DEFAULT NULL COMMENT '规则描述',
  `effective` tinyint DEFAULT '0' COMMENT '是否生效: 0=未生效 1=生效',
  `update_log` text COMMENT '修改历史JSON',
  `create_time` datetime DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',
  `update_time` datetime DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT '更新时间',
  PRIMARY KEY (`id`),
  KEY `idx_rule_type` (`rule_type`),
  KEY `idx_effective` (`effective`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci COMMENT='预警规则表';

INSERT INTO `warning_rule` (`rule_type`, `threshold`, `description`, `effective`) VALUES
('FLIGHT_RISK', 8.0, '员工流失率超过8%触发预警', 1),
('TALENT_SHORTAGE', 3.0, '关键岗位空缺超过3人触发预警', 1),
('COST_OVER', 15.0, '人力成本环比增长超过15%触发预警', 1),
('FLIGHT_RISK', 10.0, '流失率超过10%严重预警', 0),
('TALENT_SHORTAGE', 5.0, '关键岗位空缺超过5人严重预警', 0),
('COST_OVER', 20.0, '人力成本环比增长超过20%严重预警', 0),
('FLIGHT_RISK', 5.0, '流失率超过5%提醒', 0),
('TALENT_SHORTAGE', 1.0, '关键岗位出现空缺即提醒', 0),
('COST_OVER', 10.0, '人力成本环比增长超过10%提醒', 0),
('FLIGHT_RISK', 12.0, '流失率超过12%紧急预警', 0);

-- ------------------------------------------------------------
-- 6. 报表模板表 report_template
-- ------------------------------------------------------------
DROP TABLE IF EXISTS `report_template`;
CREATE TABLE `report_template` (
  `id` bigint NOT NULL AUTO_INCREMENT COMMENT '主键ID',
  `name` varchar(100) NOT NULL COMMENT '模板名称',
  `description` varchar(500) DEFAULT NULL COMMENT '模板描述',
  `category` varchar(50) DEFAULT NULL COMMENT '模板分类',
  `content` text COMMENT '模板内容(JSON格式)',
  `query_sql` text COMMENT '查询语句',
  `parameters` text COMMENT '参数配置(JSON格式)',
  `chart_config` text COMMENT '图表配置(JSON格式)',
  `enabled` tinyint DEFAULT '1' COMMENT '是否启用: 0=否 1=是',
  `create_time` datetime DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',
  `update_time` datetime DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT '更新时间',
  `created_by` bigint DEFAULT NULL COMMENT '创建人ID',
  `updated_by` bigint DEFAULT NULL COMMENT '更新人ID',
  `version` int DEFAULT '1' COMMENT '版本号',
  PRIMARY KEY (`id`),
  KEY `idx_enabled` (`enabled`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci COMMENT='报表模板表';

INSERT INTO `report_template` (`name`, `description`, `category`, `content`, `query_sql`, `parameters`, `chart_config`, `enabled`, `created_by`) VALUES
('月度人员报表', '月度人员变动情况统计', 'PERSONNEL', '{"type":"table","columns":["employee_no","name","dept_name","job"]}', 'SELECT employee_no, name, dept_name, job FROM employee_profile WHERE period = ? AND is_deleted = 0', '{"period":"YYYYMM"}', '{"type":"column","title":"月度人员统计"}', 1, 1),
('季度绩效报表', '季度员工绩效评估汇总', 'PERFORMANCE', '{"type":"chart","chartType":"bar","metrics":["performance_score"]}', 'SELECT dept_name, AVG(value) as avg_score FROM employee_profile WHERE category_id = 4 AND period >= ? GROUP BY dept_name', '{"quarter":"YYYYQ"}', '{"type":"bar","title":"部门绩效对比"}', 1, 1),
('年度薪酬报表', '年度薪酬福利支出统计', 'COMPENSATION', '{"type":"chart","chartType":"pie","metrics":["salary_cost"]}', 'SELECT dept_name, SUM(value) as total_cost FROM employee_profile WHERE category_id = 3 AND period LIKE ? GROUP BY dept_name', '{"year":"YYYY"}', '{"type":"pie","title":"各部门薪酬占比"}', 1, 1),
('组织效能趋势报表', '组织效能月度趋势', 'EFFICIENCY', '{"type":"line","metrics":["efficiency"]}', 'SELECT period, AVG(value) as avg_val FROM employee_profile WHERE category_id = 1 GROUP BY period ORDER BY period', '{}', '{"type":"line","title":"组织效能趋势"}', 1, 1),
('人才梯队健康度报表', '人才梯队健康度分析', 'TALENT', '{"type":"radar","metrics":["talent_health"]}', 'SELECT dept_name, AVG(value) as avg_val FROM employee_profile WHERE category_id = 2 GROUP BY dept_name', '{}', '{"type":"radar","title":"人才梯队健康度"}', 1, 1),
('流失预警报表', '员工流失预警汇总', 'TURNOVER', '{"type":"table","columns":["dept_name","turnover_rate"]}', 'SELECT dept_name, AVG(value) as turnover_rate FROM employee_profile WHERE category_id = 5 GROUP BY dept_name', '{}', '{"type":"bar","title":"部门流失率"}', 1, 1),
('培训效果报表', '培训效果评估汇总', 'TRAINING', '{"type":"table","columns":["dept_name","avg_score"]}', 'SELECT dept_name, AVG(value) as avg_score FROM employee_profile WHERE category_id = 6 GROUP BY dept_name', '{}', '{"type":"bar","title":"部门培训得分"}', 1, 1),
('人力成本报表', '人力成本结构分析', 'COST', '{"type":"pie","metrics":["cost"]}', 'SELECT dept_name, SUM(value) as total FROM employee_profile WHERE category_id = 7 GROUP BY dept_name', '{}', '{"type":"pie","title":"部门成本占比"}', 1, 1),
('人才发展预测报表', '人才发展预测分析', 'DEVELOPMENT', '{"type":"line","metrics":["development"]}', 'SELECT period, AVG(value) as avg_val FROM employee_profile WHERE category_id = 8 GROUP BY period ORDER BY period', '{}', '{"type":"line","title":"人才发展指数"}', 1, 1),
('综合人力资源报表', '综合人力资源多维度报表', 'COMPREHENSIVE', '{"type":"mixed","metrics":["multi"]}', 'SELECT category_id, period, AVG(value) as avg_val FROM employee_profile WHERE is_deleted = 0 GROUP BY category_id, period ORDER BY period', '{}', '{"type":"mixed","title":"综合指标"}', 1, 1);

-- ------------------------------------------------------------
-- 7. 收藏表 sys_favorite
-- ------------------------------------------------------------
DROP TABLE IF EXISTS `sys_favorite`;
CREATE TABLE `sys_favorite` (
  `id` bigint NOT NULL AUTO_INCREMENT COMMENT '主键ID',
  `user_id` bigint NOT NULL COMMENT '用户ID',
  `fav_type` varchar(20) NOT NULL COMMENT '收藏类型: REPORT/WARNING/TALENT',
  `report_id` bigint DEFAULT NULL COMMENT '报表ID',
  `title` varchar(200) DEFAULT NULL COMMENT '标题',
  `create_time` datetime DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',
  PRIMARY KEY (`id`),
  KEY `idx_user_id` (`user_id`),
  KEY `idx_fav_type` (`fav_type`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci COMMENT='收藏表';

INSERT INTO `sys_favorite` (`user_id`, `fav_type`, `report_id`, `title`) VALUES
(1, 'REPORT', 1, '月度人员报表'),
(1, 'REPORT', 2, '季度绩效报表'),
(2, 'REPORT', 1, '月度人员报表'),
(2, 'WARNING', NULL, '销售部流失预警'),
(3, 'TALENT', NULL, '高潜人才-研发部'),
(4, 'REPORT', 3, '年度薪酬报表'),
(5, 'REPORT', 2, '季度绩效报表'),
(5, 'WARNING', NULL, '人力成本超支预警'),
(6, 'TALENT', NULL, '关键岗位人才'),
(7, 'REPORT', 4, '组织效能趋势报表'),
(8, 'REPORT', 5, '人才梯队健康度报表'),
(9, 'WARNING', NULL, '人才缺口预警'),
(10, 'REPORT', 6, '流失预警报表');

-- ------------------------------------------------------------
-- 8. 数据同步日志表 data_sync_log
-- ------------------------------------------------------------
DROP TABLE IF EXISTS `data_sync_log`;
CREATE TABLE `data_sync_log` (
  `id` bigint NOT NULL AUTO_INCREMENT COMMENT '主键ID',
  `start_time` datetime NOT NULL COMMENT '同步开始时间',
  `end_time` datetime NOT NULL COMMENT '同步结束时间',
  `status` varchar(20) NOT NULL COMMENT '状态: SUCCESS/FAILED',
  `records_processed` bigint DEFAULT '0' COMMENT '处理记录数',
  `details` varchar(500) DEFAULT NULL COMMENT '同步详情',
  `create_time` datetime DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',
  PRIMARY KEY (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci COMMENT='数据同步日志表';

INSERT INTO `data_sync_log` (`start_time`, `end_time`, `status`, `records_processed`, `details`) VALUES
('2026-01-01 02:00:00', '2026-01-01 02:01:15', 'SUCCESS', 100, '全量同步employee_profile到Hive'),
('2026-01-02 02:00:00', '2026-01-02 02:00:58', 'SUCCESS', 105, '全量同步'),
('2026-01-03 02:00:00', '2026-01-03 02:01:02', 'SUCCESS', 110, '全量同步'),
('2026-01-04 02:00:00', '2026-01-04 02:00:45', 'SUCCESS', 115, '全量同步'),
('2026-01-05 02:00:00', '2026-01-05 02:01:20', 'SUCCESS', 120, '全量同步'),
('2026-01-06 02:00:00', '2026-01-06 02:00:55', 'SUCCESS', 125, '全量同步'),
('2026-01-07 02:00:00', '2026-01-07 02:01:10', 'SUCCESS', 130, '全量同步'),
('2026-01-08 02:00:00', '2026-01-08 02:00:50', 'FAILED', 0, 'Hive连接超时'),
('2026-01-09 02:00:00', '2026-01-09 02:01:05', 'SUCCESS', 135, '全量同步'),
('2026-01-10 02:00:00', '2026-01-10 02:01:18', 'SUCCESS', 140, '全量同步'),
('2026-02-01 10:30:00', '2026-02-01 10:31:00', 'SUCCESS', 20, '手动触发同步');

-- ------------------------------------------------------------
-- 9. 操作日志表 sys_log
-- ------------------------------------------------------------
DROP TABLE IF EXISTS `sys_log`;
CREATE TABLE `sys_log` (
  `id` bigint NOT NULL AUTO_INCREMENT COMMENT '主键ID',
  `user_id` bigint DEFAULT NULL COMMENT '操作人ID',
  `username` varchar(50) DEFAULT NULL COMMENT '操作人工号',
  `operation` varchar(100) DEFAULT NULL COMMENT '操作类型',
  `method` varchar(200) DEFAULT NULL COMMENT '请求方法',
  `params` text COMMENT '请求参数',
  `ip` varchar(50) DEFAULT NULL COMMENT 'IP地址',
  `create_time` datetime DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',
  PRIMARY KEY (`id`),
  KEY `idx_user_id` (`user_id`),
  KEY `idx_username` (`username`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci COMMENT='操作日志表';

INSERT INTO `sys_log` (`user_id`, `username`, `operation`, `method`, `params`, `ip`) VALUES
(1, 'admin', '用户登录', 'POST /api/auth/login', '{}', '192.168.1.100'),
(1, 'admin', '查询用户列表', 'GET /api/admin/users', '{"page":1}', '192.168.1.100'),
(2, '1001', '用户登录', 'POST /api/auth/login', '{}', '192.168.1.101'),
(2, '1001', '查看组织效能分析', 'GET /api/analysis/organization-efficiency', '{"period":"202601"}', '192.168.1.101'),
(3, '1002', '用户登录', 'POST /api/auth/login', '{}', '192.168.1.102'),
(1, 'admin', '数据同步', 'POST /api/admin/sync', '{}', '192.168.1.100'),
(4, '2001', '用户登录', 'POST /api/auth/login', '{}', '192.168.1.103'),
(5, '3001', '用户登录', 'POST /api/auth/login', '{}', '192.168.1.104'),
(1, 'admin', '修改预警规则', 'PUT /api/rule/1', '{"threshold":9}', '192.168.1.100'),
(2, '1001', '导出报表', 'GET /api/report/export/1', '{}', '192.168.1.101'),
(3, '1002', '收藏报表', 'POST /api/favorite', '{"reportId":2,"title":"季度绩效"}', '192.168.1.102'),
(1, 'admin', '新增用户', 'POST /api/admin/users', '{}', '192.168.1.100'),
(6, '3002', '用户登录', 'POST /api/auth/login', '{}', '192.168.1.105');

SET FOREIGN_KEY_CHECKS = 1;
