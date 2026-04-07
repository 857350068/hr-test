-- =====================================================
-- 添加缺失字段脚本
-- 项目: 人力资源数据中心
-- 功能: 为现有表添加实体类中需要但缺失的字段
-- 创建时间: 2026-04-05
-- 说明: 此脚本用于修复数据库表结构与实体类不匹配的问题
-- =====================================================

USE hr_datacenter;

-- =====================================================
-- 1. 修复 leave 表（请假记录表）
-- =====================================================

-- 添加审批时间字段
ALTER TABLE `leave`
ADD COLUMN approval_time DATETIME COMMENT '审批时间' AFTER approval_comment;

-- 添加附件路径字段
ALTER TABLE `leave`
ADD COLUMN attachment VARCHAR(500) COMMENT '附件路径' AFTER approval_time;

-- 更新审批状态注释，添加已撤回状态
ALTER TABLE `leave`
MODIFY COLUMN approval_status TINYINT NOT NULL DEFAULT 0 COMMENT '审批状态(0-待审批 1-已同意 2-已拒绝 3-已撤回)';

SELECT 'leave表字段添加完成!' AS message;

-- =====================================================
-- 2. 修复 performance_evaluation 表（绩效评估表）
-- =====================================================

-- 添加季度字段
ALTER TABLE performance_evaluation
ADD COLUMN quarter INT COMMENT '季度(季度评估时使用)' AFTER period_type;

-- 添加月份字段
ALTER TABLE performance_evaluation
ADD COLUMN month INT COMMENT '月份(月度评估时使用)' AFTER quarter;

-- 添加面谈时间字段
ALTER TABLE performance_evaluation
ADD COLUMN interview_date DATETIME COMMENT '面谈时间' AFTER interview_record;

-- 添加评估状态字段
ALTER TABLE performance_evaluation
ADD COLUMN evaluation_status TINYINT NOT NULL DEFAULT 0 COMMENT '评估状态(0-未评估 1-已自评 2-已评价 3-已完成)' AFTER interview_date;

SELECT 'performance_evaluation表字段添加完成!' AS message;

-- =====================================================
-- 3. 修复 salary_payment 表（薪资发放表）
-- =====================================================

-- 添加其他补贴字段
ALTER TABLE salary_payment
ADD COLUMN other_allowance DECIMAL(10,2) NOT NULL DEFAULT 0 COMMENT '其他补贴' AFTER meal_allowance;

-- 添加备注字段
ALTER TABLE salary_payment
ADD COLUMN remark VARCHAR(500) COMMENT '备注' AFTER payment_date;

SELECT 'salary_payment表字段添加完成!' AS message;

-- =====================================================
-- 4. 修复 salary_adjustment 表（薪资调整表）
-- =====================================================

-- 添加审批意见字段
ALTER TABLE salary_adjustment
ADD COLUMN approval_comment TEXT COMMENT '审批意见' AFTER approval_status;

-- 添加审批时间字段
ALTER TABLE salary_adjustment
ADD COLUMN approval_date DATETIME COMMENT '审批时间' AFTER approval_comment;

-- 添加创建人ID字段
ALTER TABLE salary_adjustment
ADD COLUMN creator_id BIGINT COMMENT '创建人ID' AFTER approval_date;

SELECT 'salary_adjustment表字段添加完成!' AS message;

-- =====================================================
-- 5. 修复 training_course 表（培训课程表）
-- =====================================================

-- 修改课程描述字段名
ALTER TABLE training_course
CHANGE COLUMN description course_description VARCHAR(500) COMMENT '课程描述';

-- 修改开始日期字段类型为DATETIME
ALTER TABLE training_course
MODIFY COLUMN start_date DATETIME NOT NULL COMMENT '培训开始时间';

-- 修改结束日期字段类型为DATETIME
ALTER TABLE training_course
MODIFY COLUMN end_date DATETIME NOT NULL COMMENT '培训结束时间';

-- 更新课程类型注释
ALTER TABLE training_course
MODIFY COLUMN course_type TINYINT NOT NULL COMMENT '课程类型(1-新员工培训 2-技能培训 3-管理培训 4-安全培训 5-其他)';

SELECT 'training_course表字段修复完成!' AS message;

-- =====================================================
-- 6. 修复 training_enrollment 表（培训报名表）
-- =====================================================

-- 添加审核人ID字段
ALTER TABLE training_enrollment
ADD COLUMN approver_id BIGINT COMMENT '审核人ID' AFTER approval_status;

-- 更新出勤状态注释，添加请假状态
ALTER TABLE training_enrollment
MODIFY COLUMN attendance_status TINYINT NOT NULL DEFAULT 0 COMMENT '出勤状态(0-未出勤 1-已出勤 2-请假)';

SELECT 'training_enrollment表字段添加完成!' AS message;

-- =====================================================
-- 7. 为新增字段添加索引（优化查询性能）
-- =====================================================

-- leave表索引
ALTER TABLE `leave` ADD INDEX idx_approval_time (approval_time);

-- performance_evaluation表索引
ALTER TABLE performance_evaluation ADD INDEX idx_evaluation_status (evaluation_status);
ALTER TABLE performance_evaluation ADD INDEX idx_interview_date (interview_date);

-- salary_adjustment表索引
ALTER TABLE salary_adjustment ADD INDEX idx_approval_date (approval_date);
ALTER TABLE salary_adjustment ADD INDEX idx_creator_id (creator_id);

-- training_enrollment表索引
ALTER TABLE training_enrollment ADD INDEX idx_approver_id (approver_id);

SELECT '索引添加完成!' AS message;

-- =====================================================
-- 验证修复结果
-- =====================================================
SELECT '======================================' AS '';
SELECT '数据库表结构修复完成!' AS message;
SELECT '======================================' AS '';

-- 显示修复后的表结构
SELECT
    TABLE_NAME AS '表名',
    COLUMN_NAME AS '字段名',
    DATA_TYPE AS '数据类型',
    COLUMN_COMMENT AS '字段说明'
FROM information_schema.COLUMNS
WHERE TABLE_SCHEMA = 'hr_datacenter'
  AND TABLE_NAME IN ('leave', 'performance_evaluation', 'salary_payment', 'salary_adjustment', 'training_course', 'training_enrollment')
  AND COLUMN_NAME IN ('approval_time', 'attachment', 'quarter', 'month', 'interview_date', 'evaluation_status', 'other_allowance', 'remark', 'approval_comment', 'approval_date', 'creator_id', 'course_description', 'approver_id')
ORDER BY TABLE_NAME, ORDINAL_POSITION;
