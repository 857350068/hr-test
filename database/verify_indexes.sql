-- =====================================================
-- 分页功能索引验证脚本
-- =====================================================
-- 创建日期: 2026-03-25
-- 说明: 验证索引是否创建成功，并测试索引是否生效
-- =====================================================

-- 显示所有表的索引
SHOW INDEX FROM hr_department;
SHOW INDEX FROM hr_data_category;
SHOW INDEX FROM warning_rule;
SHOW INDEX FROM report_template;
SHOW INDEX FROM sys_favorite;

-- =====================================================
-- 使用 EXPLAIN 验证索引是否生效
-- =====================================================

-- 验证部门表索引
EXPLAIN SELECT * FROM hr_department WHERE name LIKE '%技术%' ORDER BY id LIMIT 10;

-- 验证数据分类表索引
EXPLAIN SELECT * FROM hr_data_category WHERE name LIKE '%数据%' ORDER BY id LIMIT 10;

-- 验证预警规则表索引
EXPLAIN SELECT * FROM warning_rule WHERE rule_type = 'TURNOVER' AND is_active = true ORDER BY created_time DESC LIMIT 10;

-- 验证报表模板表索引
EXPLAIN SELECT * FROM report_template WHERE category = 'HR' AND name LIKE '%报表%' ORDER BY created_time DESC LIMIT 10;

-- 验证收藏表索引
EXPLAIN SELECT * FROM sys_favorite WHERE user_id = 1 AND fav_type = 'REPORT' ORDER BY created_time DESC LIMIT 10;

-- =====================================================
-- 索引性能分析建议
-- =====================================================
-- 1. 查看 EXPLAIN 结果中的 type 列：
--    - ALL: 全表扫描（性能最差）
--    - index: 索引扫描
--    - range: 索引范围扫描
--    - ref: 索引查找（较好）
--    - eq_ref: 唯一索引查找（最好）
--
-- 2. 查看 EXPLAIN 结果中的 key 列：
--    - 显示实际使用的索引名称
--
-- 3. 查看 EXPLAIN 结果中的 rows 列：
--    - 预计扫描的行数，数值越小越好
--
-- 4. 如果发现索引未生效，可能的原因：
--    - 数据量太小，优化器选择全表扫描
--    - 索引字段使用了函数或表达式
--    - LIKE 查询以通配符开头（如 '%abc'）
--    - OR 条件可能导致索引失效
-- =====================================================
