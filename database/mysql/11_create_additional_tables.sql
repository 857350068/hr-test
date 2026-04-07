-- =====================================================
-- 补充表结构脚本
-- 项目: 人力资源数据中心
-- 功能: 创建角色表、数据分类表等补充表
-- 创建时间: 2026-04-01
-- =====================================================

USE hr_datacenter;

-- =====================================================
-- 1. 创建角色表
-- =====================================================
DROP TABLE IF EXISTS `sys_role`;
CREATE TABLE `sys_role` (
    `role_id` BIGINT NOT NULL AUTO_INCREMENT COMMENT '角色ID',
    `role_name` VARCHAR(50) NOT NULL COMMENT '角色名称',
    `role_code` VARCHAR(50) NOT NULL COMMENT '角色编码',
    `role_desc` VARCHAR(200) COMMENT '角色描述',
    `status` TINYINT DEFAULT 1 COMMENT '角色状态(0-禁用 1-启用)',
    `create_time` DATETIME DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',
    `update_time` DATETIME DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT '更新时间',
    `deleted` TINYINT DEFAULT 0 COMMENT '删除标记(0-未删除 1-已删除)',
    PRIMARY KEY (`role_id`),
    UNIQUE KEY `uk_role_code` (`role_code`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COMMENT='角色表';

-- =====================================================
-- 2. 创建用户角色关联表
-- =====================================================
DROP TABLE IF EXISTS `sys_user_role`;
CREATE TABLE `sys_user_role` (
    `id` BIGINT NOT NULL AUTO_INCREMENT COMMENT 'ID',
    `user_id` BIGINT NOT NULL COMMENT '用户ID',
    `role_id` BIGINT NOT NULL COMMENT '角色ID',
    `create_time` DATETIME DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',
    PRIMARY KEY (`id`),
    UNIQUE KEY `uk_user_role` (`user_id`, `role_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COMMENT='用户角色关联表';

-- =====================================================
-- 3. 创建数据分类表
-- =====================================================
DROP TABLE IF EXISTS `data_category`;
CREATE TABLE `data_category` (
    `category_id` BIGINT NOT NULL AUTO_INCREMENT COMMENT '分类ID',
    `category_name` VARCHAR(50) NOT NULL COMMENT '分类名称',
    `category_code` VARCHAR(50) NOT NULL COMMENT '分类编码',
    `parent_id` BIGINT DEFAULT 0 COMMENT '父分类ID',
    `description` VARCHAR(200) COMMENT '分类描述',
    `sort_order` INT DEFAULT 0 COMMENT '排序号',
    `status` TINYINT DEFAULT 1 COMMENT '分类状态(0-禁用 1-启用)',
    `create_time` DATETIME DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',
    `update_time` DATETIME DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT '更新时间',
    `deleted` TINYINT DEFAULT 0 COMMENT '删除标记(0-未删除 1-已删除)',
    PRIMARY KEY (`category_id`),
    UNIQUE KEY `uk_category_code` (`category_code`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COMMENT='数据分类表';

-- =====================================================
-- 4. 创建收藏表
-- =====================================================
DROP TABLE IF EXISTS `user_favorite`;
CREATE TABLE `user_favorite` (
    `favorite_id` BIGINT NOT NULL AUTO_INCREMENT COMMENT '收藏ID',
    `user_id` BIGINT NOT NULL COMMENT '用户ID',
    `favorite_type` VARCHAR(20) NOT NULL COMMENT '收藏类型(report-报表, warning-预警, employee-员工)',
    `favorite_name` VARCHAR(100) NOT NULL COMMENT '收藏名称',
    `favorite_data` TEXT COMMENT '收藏数据(JSON格式)',
    `create_time` DATETIME DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',
    `update_time` DATETIME DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT '更新时间',
    `deleted` TINYINT DEFAULT 0 COMMENT '删除标记(0-未删除 1-已删除)',
    PRIMARY KEY (`favorite_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COMMENT='用户收藏表';

-- =====================================================
-- 5. 插入默认角色数据
-- =====================================================
INSERT INTO `sys_role` (`role_name`, `role_code`, `role_desc`, `status`) VALUES
('系统管理员', 'ADMIN', '系统管理员，拥有所有权限', 1),
('HR管理员', 'HR_ADMIN', 'HR管理员，负责人力资源管理', 1),
('部门负责人', 'DEPT_MANAGER', '部门负责人，管理本部门数据', 1),
('企业管理层', 'COMPANY_MANAGER', '企业管理层，查看全局数据', 1),
('普通员工', 'EMPLOYEE', '普通员工，查看个人数据', 1);

-- =====================================================
-- 6. 插入数据分类数据
-- =====================================================
INSERT INTO `data_category` (`category_name`, `category_code`, `parent_id`, `description`, `sort_order`, `status`) VALUES
('组织效能类', 'ORG_EFFICIENCY', 0, '组织效能相关数据分析', 1, 1),
('人才梯队类', 'TALENT_PIPELINE', 0, '人才梯队建设相关数据', 2, 1),
('薪酬福利类', 'SALARY_BENEFIT', 0, '薪酬福利分析数据', 3, 1),
('绩效管理类', 'PERFORMANCE', 0, '绩效管理相关数据', 4, 1),
('培训发展类', 'TRAINING', 0, '培训发展相关数据', 5, 1),
('成本管控类', 'COST_CONTROL', 0, '人力成本管控数据', 6, 1);

-- =====================================================
-- 7. 为默认用户分配角色
-- =====================================================
-- 为admin用户分配管理员角色
INSERT INTO `sys_user_role` (`user_id`, `role_id`)
SELECT u.user_id, r.role_id
FROM `sys_user` u, `sys_role` r
WHERE u.username = 'admin' AND r.role_code = 'ADMIN';

-- 为hr001用户分配HR管理员角色
INSERT INTO `sys_user_role` (`user_id`, `role_id`)
SELECT u.user_id, r.role_id
FROM `sys_user` u, `sys_role` r
WHERE u.username = 'hr001' AND r.role_code = 'HR_ADMIN';

SELECT '补充表结构创建完成!' AS message;
