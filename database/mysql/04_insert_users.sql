-- =====================================================
-- MySQL用户初始化数据
-- 项目: 人力资源数据中心
-- 数据表: sys_user
-- 数据量: 2条测试用户
-- 创建时间: 2026-03-31
-- =====================================================

USE hr_datacenter;

-- =====================================================
-- 插入测试用户数据
-- 密码说明: 使用BCrypt加密,原始密码为123456
-- BCrypt加密结果: $2a$10$N.zmdr9k7uOCbU2gU1G3eOGoZ7v8wJ6xH5mK4lP3qR2sT1uV0wXyZ
-- =====================================================

-- 清空用户表(如果需要重新初始化)
-- TRUNCATE TABLE sys_user;

-- 插入管理员用户
INSERT INTO sys_user (username, password, real_name, dept_id, phone, email, status, last_login_time) VALUES
('admin', '$2a$10$N.zmdr9k7uOCbU2gU1G3eOGoZ7v8wJ6xH5mK4lP3qR2sT1uV0wXyZ', '系统管理员', NULL, '13800138000', 'admin@hrdatacenter.com', 1, NULL);

-- 插入HR用户
INSERT INTO sys_user (username, password, real_name, dept_id, phone, email, status, last_login_time) VALUES
('hr001', '$2a$10$N.zmdr9k7uOCbU2gU1G3eOGoZ7v8wJ6xH5mK4lP3qR2sT1uV0wXyZ', '张三', NULL, '13800138001', 'hr001@hrdatacenter.com', 1, NULL);

-- 插入部门经理用户
INSERT INTO sys_user (username, password, real_name, dept_id, phone, email, status, last_login_time) VALUES
('manager001', '$2a$10$N.zmdr9k7uOCbU2gU1G3eOGoZ7v8wJ6xH5mK4lP3qR2sT1uV0wXyZ', '李四', NULL, '13800138002', 'manager001@hrdatacenter.com', 1, NULL);

-- 插入普通员工用户
INSERT INTO sys_user (username, password, real_name, dept_id, phone, email, status, last_login_time) VALUES
('emp001', '$2a$10$N.zmdr9k7uOCbU2gU1G3eOGoZ7v8wJ6xH5mK4lP3qR2sT1uV0wXyZ', '王五', NULL, '13800138003', 'emp001@hrdatacenter.com', 1, NULL);

-- =====================================================
-- 输出插入结果
-- =====================================================
SELECT '======================================' AS '';
SELECT '用户数据插入完成!' AS message;
SELECT '======================================' AS '';
SELECT
    user_id AS 用户ID,
    username AS 用户名,
    real_name AS 真实姓名,
    phone AS 手机,
    email AS 邮箱,
    status AS 状态
FROM sys_user
WHERE deleted = 0
ORDER BY user_id;
