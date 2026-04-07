-- =====================================================
-- MySQL薪资初始化数据
-- 项目: 人力资源数据中心
-- 数据表: salary_payment, salary_adjustment
-- 数据量: 500+条薪资发放记录
-- 创建时间: 2026-03-31
-- =====================================================

USE hr_datacenter;

DELIMITER //

-- 生成薪资发放数据
DROP PROCEDURE IF EXISTS generate_salary_data//
CREATE PROCEDURE generate_salary_data()
BEGIN
    DECLARE v_emp_id BIGINT;
    DECLARE v_base_salary DECIMAL(10,2);
    DECLARE v_year INT;
    DECLARE v_month INT;
    DECLARE v_perf_salary DECIMAL(10,2);
    DECLARE v_gross DECIMAL(10,2);
    DECLARE v_social DECIMAL(10,2);
    DECLARE v_fund DECIMAL(10,2);
    DECLARE v_tax DECIMAL(10,2);
    DECLARE v_net DECIMAL(10,2);
    DECLARE v_done INT DEFAULT 0;
    DECLARE v_counter INT DEFAULT 0;

    DECLARE emp_cursor CURSOR FOR
        SELECT emp_id, salary FROM employee WHERE status IN (1, 2) AND deleted = 0;

    DECLARE CONTINUE HANDLER FOR NOT FOUND SET v_done = 1;

    OPEN emp_cursor;

    emp_loop: LOOP
        FETCH emp_cursor INTO v_emp_id, v_base_salary;
        IF v_done = 1 THEN
            LEAVE emp_loop;
        END IF;

        -- 为每个员工生成最近12个月的薪资
        SET v_month = MONTH(CURDATE());
        SET v_year = YEAR(CURDATE());

        month_loop: LOOP
            IF v_year = YEAR(CURDATE()) AND v_month > MONTH(CURDATE()) THEN
                LEAVE month_loop;
            END IF;

            -- 绩效工资(基本工资的10%-30%)
            SET v_perf_salary = v_base_salary * (0.1 + RAND() * 0.2);

            -- 应发工资
            SET v_gross = v_base_salary + v_perf_salary + 500 + 300 + 200 + 100; -- 基本+绩效+岗位津贴+交通+通讯+餐补

            -- 扣款
            SET v_social = v_base_salary * 0.105; -- 社保10.5%
            SET v_fund = v_base_salary * 0.12; -- 公积金12%
            SET v_tax = (v_gross - v_social - v_fund - 5000) * 0.1; -- 简化个税计算
            IF v_tax < 0 THEN SET v_tax = 0; END IF;

            -- 实发工资
            SET v_net = v_gross - v_social - v_fund - v_tax;

            -- 插入薪资记录
            INSERT INTO salary_payment (
                emp_id, year, month, basic_salary, performance_salary,
                position_allowance, transport_allowance, communication_allowance, meal_allowance, other_allowance,
                overtime_pay, total_gross_salary, social_insurance, housing_fund, income_tax, other_deduction,
                total_net_salary, payment_status, payment_date, remark
            ) VALUES (
                v_emp_id, v_year, v_month, v_base_salary, v_perf_salary,
                500, 300, 200, 100, 0,
                100, v_gross, v_social, v_fund, v_tax, 0,
                v_net, 1, DATE_FORMAT(CONCAT(v_year, '-', v_month, '-15 10:00:00'), '%Y-%m-%d %H:%i:%s'), '月度薪资发放'
            );

            SET v_counter = v_counter + 1;

            -- 递减月份
            SET v_month = v_month - 1;
            IF v_month = 0 THEN
                SET v_month = 12;
                SET v_year = v_year - 1;
            END IF;

            IF v_counter >= 600 THEN
                LEAVE month_loop;
            END IF;
        END LOOP month_loop;
    END LOOP emp_loop;

    CLOSE emp_cursor;
    SELECT CONCAT('成功生成 ', v_counter, ' 条薪资记录!') AS message;
END//

DELIMITER ;

-- 执行存储过程
CALL generate_salary_data();

-- 输出统计
SELECT '======================================' AS '';
SELECT '薪资数据统计:' AS message;
SELECT '======================================' AS '';
SELECT COUNT(*) AS 薪资记录数 FROM salary_payment WHERE deleted = 0;

DROP PROCEDURE IF EXISTS generate_salary_data;
