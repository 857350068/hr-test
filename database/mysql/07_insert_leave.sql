-- =====================================================
-- MySQL请假初始化数据
-- 项目: 人力资源数据中心
-- 数据表: leave
-- 数据量: 50+条请假记录
-- 创建时间: 2026-03-31
-- =====================================================

USE hr_datacenter;

-- =====================================================
-- 插入请假数据(使用存储过程批量生成)
-- =====================================================
DELIMITER //

DROP PROCEDURE IF EXISTS generate_leave_data//

CREATE PROCEDURE generate_leave_data()
BEGIN
    DECLARE v_emp_id BIGINT;
    DECLARE v_leave_type TINYINT;
    DECLARE v_start_date DATE;
    DECLARE v_end_date DATE;
    DECLARE v_duration INT;
    DECLARE v_approver_id BIGINT;
    DECLARE v_approval_status TINYINT;
    DECLARE v_done INT DEFAULT 0;
    DECLARE v_counter INT DEFAULT 0;
    DECLARE v_i INT;

    -- 游标:遍历所有在职员工
    DECLARE emp_cursor CURSOR FOR
        SELECT emp_id FROM employee WHERE status = 1 AND deleted = 0 LIMIT 30;

    DECLARE CONTINUE HANDLER FOR NOT FOUND SET v_done = 1;

    -- 审批人ID(使用用户表中的admin和hr001)
    SELECT user_id INTO v_approver_id FROM sys_user WHERE username = 'admin' LIMIT 1;

    OPEN emp_cursor;

    emp_loop: LOOP
        FETCH emp_cursor INTO v_emp_id;
        IF v_done = 1 THEN
            LEAVE emp_loop;
        END IF;

        -- 为每个员工生成1-3条请假记录
        SET v_i = 0;
        leave_loop: LOOP
            IF v_i >= FLOOR(1 + RAND() * 2) THEN
                LEAVE leave_loop;
            END IF;

            -- 随机请假类型(0-6)
            SET v_leave_type = FLOOR(RAND() * 7);

            -- 随机开始日期(最近60天内)
            SET v_start_date = DATE_SUB(CURDATE(), INTERVAL FLOOR(RAND() * 60) DAY);

            -- 请假时长1-5天
            SET v_duration = FLOOR(1 + RAND() * 4);
            SET v_end_date = DATE_ADD(v_start_date, INTERVAL v_duration DAY);

            -- 随机审批状态(70%已同意,20%待审批,10%已拒绝)
            SET v_approval_status = FLOOR(RAND() * 100);
            IF v_approval_status < 70 THEN
                SET v_approval_status = 1;
            ELSEIF v_approval_status < 90 THEN
                SET v_approval_status = 0;
            ELSE
                SET v_approval_status = 2;
            END IF;

            -- 插入请假记录
            INSERT INTO `leave` (emp_id, leave_type, start_time, end_time, leave_duration, reason, approver_id, approval_status, approval_comment, approval_time, attachment)
            VALUES (
                v_emp_id,
                v_leave_type,
                CONCAT(v_start_date, ' 09:00:00'),
                CONCAT(v_end_date, ' 18:00:00'),
                v_duration * 8,
                CASE v_leave_type
                    WHEN 0 THEN '家中有事需要处理'
                    WHEN 1 THEN '身体不适需要休息'
                    WHEN 2 THEN '年假休息'
                    WHEN 3 THEN '结婚事宜'
                    WHEN 4 THEN '产检/产假'
                    WHEN 5 THEN '家中有丧事'
                    WHEN 6 THEN '其他个人原因'
                END,
                v_approver_id,
                v_approval_status,
                IF(v_approval_status = 1, '同意', IF(v_approval_status = 2, '拒绝', NULL)),
                IF(v_approval_status = 1, DATE_FORMAT(DATE_ADD(v_start_date, INTERVAL 1 DAY), '%Y-%m-%d %H:%i:%s'), NULL),
                IF(v_leave_type = 1, '/uploads/medical_certificate.pdf', NULL)
            );

            SET v_counter = v_counter + 1;
            SET v_i = v_i + 1;
        END LOOP leave_loop;
    END LOOP emp_loop;

    CLOSE emp_cursor;

    SELECT CONCAT('成功生成 ', v_counter, ' 条请假记录!') AS message;
END//

DELIMITER ;

-- 执行存储过程
CALL generate_leave_data();

-- 输出统计
SELECT '======================================' AS '';
SELECT '请假数据统计:' AS message;
SELECT '======================================' AS '';
SELECT
    CASE leave_type
        WHEN 0 THEN '事假'
        WHEN 1 THEN '病假'
        WHEN 2 THEN '年假'
        WHEN 3 THEN '婚假'
        WHEN 4 THEN '产假'
        WHEN 5 THEN '丧假'
    END AS 请假类型,
    COUNT(*) AS 记录数
FROM `leave`
WHERE deleted = 0
GROUP BY leave_type;

DROP PROCEDURE IF EXISTS generate_leave_data;
