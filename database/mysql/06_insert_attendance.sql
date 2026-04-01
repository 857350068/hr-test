-- =====================================================
-- MySQL考勤初始化数据
-- 项目: 人力资源数据中心
-- 数据表: attendance
-- 数据量: 使用存储过程生成1000+条考勤记录
-- 创建时间: 2026-03-31
-- =====================================================

USE hr_datacenter;

-- =====================================================
-- 创建存储过程:批量生成考勤数据
-- =====================================================
DELIMITER //

DROP PROCEDURE IF EXISTS generate_attendance_data//

CREATE PROCEDURE generate_attendance_data()
BEGIN
    DECLARE v_emp_id BIGINT;
    DECLARE v_date DATE;
    DECLARE v_day INT;
    DECLARE v_type TINYINT;
    DECLARE v_clock_in TIME;
    DECLARE v_clock_out TIME;
    DECLARE v_duration INT;
    DECLARE v_status TINYINT;
    DECLARE v_done INT DEFAULT 0;
    DECLARE v_counter INT DEFAULT 0;

    -- 游标:遍历所有在职员工
    DECLARE emp_cursor CURSOR FOR
        SELECT emp_id FROM employee WHERE status IN (1, 2) AND deleted = 0;

    DECLARE CONTINUE HANDLER FOR NOT FOUND SET v_done = 1;

    OPEN emp_cursor;

    emp_loop: LOOP
        FETCH emp_cursor INTO v_emp_id;
        IF v_done = 1 THEN
            LEAVE emp_loop;
        END IF;

        -- 为每个员工生成最近90天的考勤数据
        SET v_day = 0;
        day_loop: LOOP
            IF v_day >= 90 THEN
                LEAVE day_loop;
            END IF;

            SET v_date = DATE_SUB(CURDATE(), INTERVAL v_day DAY);

            -- 跳过周末
            IF DAYOFWEEK(v_date) IN (1, 7) THEN
                SET v_day = v_day + 1;
                ITERATE day_loop;
            END IF;

            -- 随机生成考勤类型(80%正常,10%迟到,5%早退,3%请假,2%加班)
            SET v_type = FLOOR(RAND() * 100);
            IF v_type < 80 THEN
                SET v_type = 0; -- 正常
                SET v_clock_in = '09:00:00';
                SET v_clock_out = '18:00:00';
                SET v_duration = 540; -- 9小时
                SET v_status = 1; -- 已打卡
            ELSEIF v_type < 90 THEN
                SET v_type = 1; -- 迟到
                SET v_clock_in = SEC_TO_TIME(32400 + FLOOR(RAND() * 1800)); -- 9:00-9:30
                SET v_clock_out = '18:00:00';
                SET v_duration = FLOOR(TIMESTAMPDIFF(MINUTE, v_clock_in, v_clock_out));
                SET v_status = 1;
            ELSEIF v_type < 95 THEN
                SET v_type = 2; -- 早退
                SET v_clock_in = '09:00:00';
                SET v_clock_out = SEC_TO_TIME(64800 - FLOOR(RAND() * 1800)); -- 17:00-17:30
                SET v_duration = FLOOR(TIMESTAMPDIFF(MINUTE, v_clock_in, v_clock_out));
                SET v_status = 1;
            ELSEIF v_type < 98 THEN
                SET v_type = 4; -- 请假
                SET v_clock_in = NULL;
                SET v_clock_out = NULL;
                SET v_duration = 0;
                SET v_status = 2; -- 请假
            ELSE
                SET v_type = 5; -- 加班
                SET v_clock_in = '09:00:00';
                SET v_clock_out = '20:00:00';
                SET v_duration = 660; -- 11小时
                SET v_status = 3; -- 加班
            END IF;

            -- 插入考勤记录
            INSERT INTO attendance (emp_id, attendance_date, clock_in_time, clock_out_time, attendance_type, attendance_status, work_duration)
            VALUES (v_emp_id, v_date, v_clock_in, v_clock_out, v_type, v_status, v_duration);

            SET v_counter = v_counter + 1;
            SET v_day = v_day + 1;
        END LOOP day_loop;
    END LOOP emp_loop;

    CLOSE emp_cursor;

    SELECT CONCAT('成功生成 ', v_counter, ' 条考勤记录!') AS message;
END//

DELIMITER ;

-- =====================================================
-- 执行存储过程生成考勤数据
-- =====================================================
CALL generate_attendance_data();

-- =====================================================
-- 输出统计结果
-- =====================================================
SELECT '======================================' AS '';
SELECT '考勤数据统计:' AS message;
SELECT '======================================' AS '';

SELECT
    CASE attendance_type
        WHEN 0 THEN '正常'
        WHEN 1 THEN '迟到'
        WHEN 2 THEN '早退'
        WHEN 3 THEN '旷工'
        WHEN 4 THEN '请假'
        WHEN 5 THEN '加班'
    END AS 考勤类型,
    COUNT(*) AS 记录数
FROM attendance
WHERE deleted = 0
GROUP BY attendance_type
ORDER BY attendance_type;

-- 删除存储过程
DROP PROCEDURE IF EXISTS generate_attendance_data;
