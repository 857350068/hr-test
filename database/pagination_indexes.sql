-- =====================================================
-- 分页功能数据库索引优化脚本
-- =====================================================
-- 创建日期: 2026-03-25
-- 说明: 为分页查询涉及的数据库表创建索引，优化查询性能
-- =====================================================

-- 6.1 创建部门表索引
-- 为 hr_department 表的 name 字段创建索引
CREATE INDEX IF NOT EXISTS idx_department_name ON hr_department(name);

-- 6.2 创建数据分类表索引
-- 为 hr_data_category 表的 name 字段创建索引
CREATE INDEX IF NOT EXISTS idx_data_category_name ON hr_data_category(name);

-- 6.3 创建预警规则表索引
-- 为 warning_rule 表的 rule_type、is_active 和 created_time 字段创建索引
CREATE INDEX IF NOT EXISTS idx_warning_rule_type_status ON warning_rule(rule_type, is_active);
CREATE INDEX IF NOT EXISTS idx_warning_rule_created_time ON warning_rule(created_time);

-- 6.4 创建报表模板表索引
-- 为 report_template 表的 category、name 和 created_time 字段创建索引
CREATE INDEX IF NOT EXISTS idx_report_template_category_name ON report_template(category, name);
CREATE INDEX IF NOT EXISTS idx_report_template_created_time ON report_template(created_time);

-- 6.5 创建收藏表索引
-- 为 sys_favorite 表的 user_id、fav_type 和 created_time 字段创建索引
CREATE INDEX IF NOT EXISTS idx_favorite_user_type ON sys_favorite(user_id, fav_type);
CREATE INDEX IF NOT EXISTS idx_favorite_created_time ON sys_favorite(created_time);

-- =====================================================
-- 索引创建完成
-- =====================================================
-- 可以使用以下命令验证索引是否创建成功:
-- SHOW INDEX FROM hr_department;
-- SHOW INDEX FROM hr_data_category;
-- SHOW INDEX FROM warning_rule;
-- SHOW INDEX FROM report_template;
-- SHOW INDEX FROM sys_favorite;
-- =====================================================
