-- =====================================================
-- MySQL数据库创建脚本
-- 项目: 人力资源数据中心
-- 数据库名: hr_datacenter
-- 字符集: utf8mb4
-- 排序规则: utf8mb4_unicode_ci
-- 创建时间: 2026-03-31
-- =====================================================

-- 设置字符集
SET NAMES utf8mb4;
SET CHARACTER SET utf8mb4;

-- 删除已存在的数据库(谨慎使用,会删除所有数据)
DROP DATABASE IF EXISTS hr_datacenter;

-- 创建数据库
CREATE DATABASE hr_datacenter
    DEFAULT CHARACTER SET utf8mb4
    DEFAULT COLLATE utf8mb4_unicode_ci;

-- 使用数据库
USE hr_datacenter;

-- 输出创建结果
SELECT '数据库 hr_datacenter 创建成功!' AS message;
SELECT
    DATABASE() AS current_database,
    @@character_set_database AS character_set,
    @@collation_database AS collation;
