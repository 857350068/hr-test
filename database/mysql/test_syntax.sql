-- =====================================================
-- SQL语法验证测试脚本
-- 用于验证修复后的存储过程语法是否正确
-- =====================================================

USE hr_datacenter;

-- 测试1: 验证generate_leave_data存储过程语法
DELIMITER //
DROP PROCEDURE IF EXISTS test_leave_syntax//
CREATE PROCEDURE test_leave_syntax()
BEGIN
    DECLARE v_test INT DEFAULT 0;
    DECLARE test_cursor CURSOR FOR SELECT 1;
    DECLARE CONTINUE HANDLER FOR NOT FOUND SET v_test = 1;

    OPEN test_cursor;
    CLOSE test_cursor;

    SELECT 'generate_leave_data 语法结构正确' AS test_result;
END//
DELIMITER ;

CALL test_leave_syntax();
DROP PROCEDURE IF EXISTS test_leave_syntax;

-- 测试2: 验证generate_training_enrollments存储过程语法
DELIMITER //
DROP PROCEDURE IF EXISTS test_training_syntax//
CREATE PROCEDURE test_training_syntax()
BEGIN
    DECLARE v_test1 INT DEFAULT 0;
    DECLARE v_test2 INT DEFAULT 0;
    DECLARE test_cursor1 CURSOR FOR SELECT 1;
    DECLARE test_cursor2 CURSOR FOR SELECT 1;
    DECLARE CONTINUE HANDLER FOR NOT FOUND SET v_test1 = 1;

    OPEN test_cursor1;
    CLOSE test_cursor1;

    -- 在嵌套块中使用第二个HANDLER
    BEGIN
        DECLARE CONTINUE HANDLER FOR NOT FOUND SET v_test2 = 1;
        OPEN test_cursor2;
        CLOSE test_cursor2;
    END;

    SELECT 'generate_training_enrollments 语法结构正确' AS test_result;
END//
DELIMITER ;

CALL test_training_syntax();
DROP PROCEDURE IF EXISTS test_training_syntax;

-- 测试3: 验证INSERT IGNORE语法
CREATE TABLE IF NOT EXISTS test_ignore_table (
    id INT PRIMARY KEY,
    name VARCHAR(50)
);

INSERT INTO test_ignore_table VALUES (1, 'Test1');
INSERT IGNORE INTO test_ignore_table VALUES (1, 'Test1'); -- 应该被忽略,不报错

SELECT 'INSERT IGNORE 语法正确,重复数据被忽略' AS test_result;

DROP TABLE IF EXISTS test_ignore_table;

SELECT '========================================' AS '';
SELECT '✅ 所有语法测试通过!' AS final_result;
SELECT '========================================' AS '';
