-- =====================================================
-- MySQL绩效初始化数据
-- 项目: 人力资源数据中心
-- 数据表: performance_goal, performance_evaluation
-- 数据量: 100+条绩效目标, 50+条绩效评估
-- 创建时间: 2026-03-31
-- =====================================================

USE hr_datacenter;

DELIMITER //

-- 生成绩效目标
DROP PROCEDURE IF EXISTS generate_performance_goals//
CREATE PROCEDURE generate_performance_goals()
BEGIN
    DECLARE v_emp_id BIGINT;
    DECLARE v_year INT;
    DECLARE v_period TINYINT;
    DECLARE v_done INT DEFAULT 0;
    DECLARE v_counter INT DEFAULT 0;

    DECLARE emp_cursor CURSOR FOR
        SELECT emp_id FROM employee WHERE status = 1 AND deleted = 0 LIMIT 40;

    DECLARE CONTINUE HANDLER FOR NOT FOUND SET v_done = 1;

    OPEN emp_cursor;

    emp_loop: LOOP
        FETCH emp_cursor INTO v_emp_id;
        IF v_done = 1 THEN
            LEAVE emp_loop;
        END IF;

        -- 为每个员工生成2024和2025年的绩效目标
        SET v_year = 2024;
        year_loop: LOOP
            IF v_year > 2025 THEN
                LEAVE year_loop;
            END IF;

            -- 年度目标
            INSERT INTO performance_goal (emp_id, year, period_type, goal_description, weight, completion_standard, goal_status)
            VALUES (v_emp_id, v_year, 1, '完成年度工作目标,提升业务能力', 100, '按时完成年度工作任务,绩效评分达到B级以上', 2);

            -- 季度目标
            SET v_period = 1;
            quarter_loop: LOOP
                IF v_period > 4 THEN
                    LEAVE quarter_loop;
                END IF;
                INSERT INTO performance_goal (emp_id, year, period_type, goal_description, weight, completion_standard, goal_status)
                VALUES (v_emp_id, v_year, 2, CONCAT('第', v_period, '季度工作目标'), 25, '完成季度工作任务', IF(v_year = 2025 AND v_period > 1, 0, 2));
                SET v_counter = v_counter + 1;
                SET v_period = v_period + 1;
            END LOOP quarter_loop;

            SET v_year = v_year + 1;
        END LOOP year_loop;
    END LOOP emp_loop;

    CLOSE emp_cursor;
    SELECT CONCAT('成功生成 ', v_counter, ' 条绩效目标!') AS message;
END//

-- 生成绩效评估
DROP PROCEDURE IF EXISTS generate_performance_evaluations//
CREATE PROCEDURE generate_performance_evaluations()
BEGIN
    DECLARE v_emp_id BIGINT;
    DECLARE v_year INT;
    DECLARE v_self_score DECIMAL(5,2);
    DECLARE v_supervisor_score DECIMAL(5,2);
    DECLARE v_final_score DECIMAL(5,2);
    DECLARE v_level CHAR(1);
    DECLARE v_done INT DEFAULT 0;
    DECLARE v_counter INT DEFAULT 0;

    DECLARE emp_cursor CURSOR FOR
        SELECT emp_id FROM employee WHERE status = 1 AND deleted = 0 LIMIT 30;

    DECLARE CONTINUE HANDLER FOR NOT FOUND SET v_done = 1;

    OPEN emp_cursor;

    emp_loop: LOOP
        FETCH emp_cursor INTO v_emp_id;
        IF v_done = 1 THEN
            LEAVE emp_loop;
        END IF;

        -- 2024年度评估
        SET v_self_score = 70 + FLOOR(RAND() * 25);
        SET v_supervisor_score = 70 + FLOOR(RAND() * 25);
        SET v_final_score = (v_self_score * 0.3 + v_supervisor_score * 0.7);

        IF v_final_score >= 90 THEN SET v_level = 'S';
        ELSEIF v_final_score >= 80 THEN SET v_level = 'A';
        ELSEIF v_final_score >= 70 THEN SET v_level = 'B';
        ELSEIF v_final_score >= 60 THEN SET v_level = 'C';
        ELSE SET v_level = 'D';
        END IF;

        INSERT INTO performance_evaluation (emp_id, year, period_type, self_score, self_comment, supervisor_score, supervisor_comment, final_score, performance_level)
        VALUES (v_emp_id, 2024, 1, v_self_score, '年度工作完成情况良好', v_supervisor_score, '工作表现优秀', v_final_score, v_level);

        SET v_counter = v_counter + 1;
    END LOOP emp_loop;

    CLOSE emp_cursor;
    SELECT CONCAT('成功生成 ', v_counter, ' 条绩效评估!') AS message;
END//

DELIMITER ;

-- 执行存储过程
CALL generate_performance_goals();
CALL generate_performance_evaluations();

-- 输出统计
SELECT '======================================' AS '';
SELECT '绩效数据统计:' AS message;
SELECT '======================================' AS '';
SELECT '绩效目标数量:' AS item, COUNT(*) AS count FROM performance_goal WHERE deleted = 0
UNION ALL
SELECT '绩效评估数量:' AS item, COUNT(*) AS count FROM performance_evaluation WHERE deleted = 0;

DROP PROCEDURE IF EXISTS generate_performance_goals;
DROP PROCEDURE IF EXISTS generate_performance_evaluations;
