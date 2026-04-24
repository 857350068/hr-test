-- 测试Leave功能的SQL脚本
-- 用于验证emp_leave表是否可以正常访问

USE hr_datacenter;

-- 1. 检查emp_leave表是否存在
SHOW TABLES LIKE 'emp_leave';

-- 2. 查看表结构
DESC emp_leave;

-- 3. 插入测试数据
INSERT INTO emp_leave (
    emp_id, leave_type, start_time, end_time, 
    leave_duration, reason, approval_status, 
    create_time, update_time, deleted
) VALUES (
    1, 0, '2024-04-15 09:00:00', '2024-04-15 18:00:00',
    8, '测试请假申请', 0,
    NOW(), NOW(), 0
);

-- 4. 查询测试数据
SELECT * FROM emp_leave WHERE emp_id = 1 ORDER BY create_time DESC LIMIT 5;

-- 5. 统计记录数
SELECT COUNT(*) as total_records FROM emp_leave WHERE deleted = 0;

-- 6. 按审批状态统计
SELECT 
    approval_status,
    CASE approval_status
        WHEN 0 THEN '待审批'
        WHEN 1 THEN '已同意'
        WHEN 2 THEN '已拒绝'
        WHEN 3 THEN '已撤回'
        ELSE '未知'
    END as status_name,
    COUNT(*) as count
FROM emp_leave 
WHERE deleted = 0
GROUP BY approval_status;
