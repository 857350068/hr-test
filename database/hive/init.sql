-- ============================================================
-- 人力资源数据中心系统 - Hive 数据库初始化脚本
-- Hive 3.1.3 | 默认库 default
-- 说明: 建表 + 视图 + 不少于10条初始数据
-- 执行: 在 Hive 客户端或 beeline 中执行
-- ============================================================

-- 使用默认库
USE default;

-- ------------------------------------------------------------
-- 1. 员工分析数据表 hr_analytic_data
-- 与 MySQL employee_profile 结构对应，用于同步与分析查询
-- ------------------------------------------------------------
DROP TABLE IF EXISTS hr_analytic_data;
CREATE TABLE hr_analytic_data (
  id BIGINT,
  employee_no STRING,
  name STRING,
  dept_id BIGINT,
  job STRING,
  category_id BIGINT,
  value FLOAT,
  period STRING,
  create_time TIMESTAMP
)
COMMENT '员工分析数据表-从MySQL同步'
ROW FORMAT DELIMITED
FIELDS TERMINATED BY '\001'
STORED AS ORC
TBLPROPERTIES ('orc.compress'='SNAPPY');

-- 插入不少于10条分析数据（Hive 3.x 支持 INSERT INTO ... VALUES）
INSERT INTO hr_analytic_data VALUES
(1, 'E001', '张三', 1, '销售经理', 1, 88.5, '202601', cast('2026-01-01 08:00:00' as timestamp)),
(2, 'E002', '李四', 2, '高级工程师', 1, 92.0, '202601', cast('2026-01-01 08:00:00' as timestamp)),
(3, 'E003', '王五', 1, '销售代表', 1, 78.0, '202601', cast('2026-01-01 08:00:00' as timestamp)),
(4, 'E004', '赵六', 2, '工程师', 2, 85.0, '202601', cast('2026-01-01 08:00:00' as timestamp)),
(5, 'E005', '钱七', 3, 'HR专员', 2, 82.0, '202601', cast('2026-01-01 08:00:00' as timestamp)),
(6, 'E006', '孙八', 1, '销售代表', 3, 12500.0, '202601', cast('2026-01-01 08:00:00' as timestamp)),
(7, 'E007', '周九', 2, '工程师', 3, 18500.0, '202601', cast('2026-01-01 08:00:00' as timestamp)),
(8, 'E008', '吴十', 1, '销售代表', 4, 86.0, '202601', cast('2026-01-01 08:00:00' as timestamp)),
(9, 'E009', '郑十一', 2, '高级工程师', 4, 91.0, '202601', cast('2026-01-01 08:00:00' as timestamp)),
(10, 'E010', '陈十二', 1, '销售代表', 5, 6.5, '202601', cast('2026-01-01 08:00:00' as timestamp)),
(11, 'E011', '林十三', 2, '工程师', 5, 3.2, '202601', cast('2026-01-01 08:00:00' as timestamp)),
(12, 'E012', '黄十四', 3, '培训专员', 6, 88.0, '202601', cast('2026-01-01 08:00:00' as timestamp)),
(13, 'E013', '刘十五', 2, '工程师', 6, 90.0, '202601', cast('2026-01-01 08:00:00' as timestamp)),
(14, 'E014', '杨十六', 4, '会计', 7, 9500.0, '202601', cast('2026-01-01 08:00:00' as timestamp)),
(15, 'E015', '何十七', 1, '销售经理', 7, 12000.0, '202601', cast('2026-01-01 08:00:00' as timestamp)),
(16, 'E016', '马十八', 2, '架构师', 8, 92.0, '202601', cast('2026-01-01 08:00:00' as timestamp)),
(17, 'E017', '罗十九', 3, '招聘专员', 8, 85.0, '202601', cast('2026-01-01 08:00:00' as timestamp)),
(18, 'E018', '梁二十', 1, '销售代表', 1, 80.0, '202602', cast('2026-02-01 08:00:00' as timestamp)),
(19, 'E019', '宋二一', 2, '工程师', 2, 88.0, '202602', cast('2026-02-01 08:00:00' as timestamp)),
(20, 'E020', '唐二二', 4, '出纳', 3, 7500.0, '202602', cast('2026-02-01 08:00:00' as timestamp));

-- ------------------------------------------------------------
-- 2. 培训效果表 hr_training_effect
-- ------------------------------------------------------------
DROP TABLE IF EXISTS hr_training_effect;
CREATE TABLE hr_training_effect (
  id BIGINT,
  dept_id BIGINT,
  employee_id BIGINT,
  training_name STRING,
  score FLOAT,
  satisfaction STRING,
  create_time TIMESTAMP
)
COMMENT '培训效果表'
ROW FORMAT DELIMITED
FIELDS TERMINATED BY '\001'
STORED AS ORC
TBLPROPERTIES ('orc.compress'='SNAPPY');

INSERT INTO hr_training_effect VALUES
(1, 1, 1001, '销售技巧提升', 88.5, '满意', cast('2026-01-10 09:00:00' as timestamp)),
(2, 1, 1002, '销售技巧提升', 92.0, '非常满意', cast('2026-01-10 09:00:00' as timestamp)),
(3, 2, 2001, 'Java进阶', 90.0, '非常满意', cast('2026-01-12 09:00:00' as timestamp)),
(4, 2, 2002, 'Java进阶', 85.5, '满意', cast('2026-01-12 09:00:00' as timestamp)),
(5, 3, 3001, 'HR合规培训', 95.0, '非常满意', cast('2026-01-15 09:00:00' as timestamp)),
(6, 2, 2003, '架构设计', 88.0, '满意', cast('2026-01-18 09:00:00' as timestamp)),
(7, 1, 1003, '客户关系管理', 82.0, '满意', cast('2026-01-20 09:00:00' as timestamp)),
(8, 4, 4001, '财务制度', 91.0, '非常满意', cast('2026-01-22 09:00:00' as timestamp)),
(9, 2, 2004, 'DevOps实践', 87.0, '满意', cast('2026-01-25 09:00:00' as timestamp)),
(10, 3, 3002, '招聘面试技巧', 89.0, '非常满意', cast('2026-01-28 09:00:00' as timestamp)),
(11, 1, 1004, '销售技巧提升', 84.0, '满意', cast('2026-02-01 09:00:00' as timestamp)),
(12, 2, 2005, 'Java进阶', 86.0, '满意', cast('2026-02-05 09:00:00' as timestamp));

-- ------------------------------------------------------------
-- 3. 视图：部门绩效视图 vw_dept_performance
-- ------------------------------------------------------------
DROP VIEW IF EXISTS vw_dept_performance;
CREATE VIEW vw_dept_performance AS
SELECT
  dept_id,
  AVG(value) AS avg_performance,
  COUNT(*) AS employee_count
FROM hr_analytic_data
WHERE category_id = 4
GROUP BY dept_id;

-- ------------------------------------------------------------
-- 4. 视图：培训汇总视图 vw_training_summary
-- ------------------------------------------------------------
DROP VIEW IF EXISTS vw_training_summary;
CREATE VIEW vw_training_summary AS
SELECT
  dept_id,
  training_name,
  AVG(score) AS avg_score,
  COUNT(*) AS participant_count
FROM hr_training_effect
GROUP BY dept_id, training_name;
