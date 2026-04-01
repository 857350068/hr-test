-- =====================================================
-- Hive数据仓库创建脚本
-- 项目: 人力资源数据中心
-- 数据库名: hr_datacenter_dw
-- 存储格式: ORC
-- 压缩格式: SNAPPY
-- 创建时间: 2026-03-31
-- =====================================================

-- 删除已存在的数据库(谨慎使用)
DROP DATABASE IF EXISTS hr_datacenter_dw CASCADE;

-- 创建数据仓库
CREATE DATABASE hr_datacenter_dw
COMMENT '人力资源数据中心数据仓库'
LOCATION '/user/hive/warehouse/hr_datacenter_dw.db';

-- 使用数据库
USE hr_datacenter_dw;

-- 输出创建结果
SELECT '数据仓库 hr_datacenter_dw 创建成功!' AS message;
