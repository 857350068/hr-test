-- ============================================================
-- 人力资源数据中心 - Hive 库创建
-- 与 MySQL hr_db / 后端实体 对齐，用于数仓与离线分析
-- ============================================================

CREATE DATABASE IF NOT EXISTS hr_db
  COMMENT '人力资源数据中心数仓库，与 MySQL hr_db 结构对齐'
  LOCATION '/user/hive/warehouse/hr_db.db';

USE hr_db;
