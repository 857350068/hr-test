-- =====================================================
-- MySQL培训初始化数据
-- 项目: 人力资源数据中心
-- 数据表: training_course, training_enrollment
-- 数据量: 10+个培训课程, 100+条培训报名
-- 创建时间: 2026-03-31
-- =====================================================

USE hr_datacenter;

-- =====================================================
-- 插入培训课程数据
-- =====================================================
INSERT INTO training_course (course_name, course_type, instructor, duration, location, start_date, end_date, capacity, enrolled_count, course_status, description) VALUES
('新员工入职培训', 1, '林晓', 8, '公司会议室A', '2024-01-15', '2024-01-15', 30, 25, 2, '公司文化、规章制度、安全知识等入职必训内容'),
('Java高级编程技术', 2, '张伟', 16, '技术培训室', '2024-02-20', '2024-02-21', 20, 18, 2, 'Java高级特性、设计模式、性能优化'),
('项目管理实战', 3, '袁鹏', 12, '公司会议室B', '2024-03-10', '2024-03-11', 25, 22, 2, '项目管理方法论、敏捷开发、团队协作'),
('安全生产培训', 4, '何军', 4, '公司会议室A', '2024-04-05', '2024-04-05', 50, 45, 2, '安全生产法规、应急处理、消防知识'),
('前端开发技术', 2, '朱涛', 12, '技术培训室', '2024-05-15', '2024-05-16', 15, 12, 2, 'Vue3、React、前端工程化'),
('数据分析与可视化', 2, '李娜', 8, '技术培训室', '2024-06-20', '2024-06-20', 20, 15, 2, 'Python数据分析、ECharts可视化'),
('领导力提升培训', 3, '林晓', 16, '公司会议室B', '2024-07-10', '2024-07-12', 15, 13, 2, '领导力理论、团队管理、沟通技巧'),
('沟通技巧培训', 3, '邹敏', 4, '公司会议室A', '2024-08-15', '2024-08-15', 30, 28, 2, '职场沟通、跨部门协作、客户沟通'),
('Python编程基础', 2, '王强', 12, '技术培训室', '2024-09-20', '2024-09-21', 20, 16, 2, 'Python基础语法、数据结构、常用库'),
('新员工入职培训', 1, '林晓', 8, '公司会议室A', '2025-01-10', '2025-01-10', 30, 20, 1, '2025年第一期新员工入职培训'),
('数据库优化技术', 2, '吴昊', 8, '技术培训室', '2025-02-15', '2025-02-15', 15, 10, 1, 'MySQL性能优化、索引设计、SQL调优'),
('团队建设活动', 3, '袁鹏', 8, '户外拓展基地', '2025-03-20', '2025-03-20', 40, 35, 0, '团队协作、信任建立、沟通训练');

-- =====================================================
-- 生成培训报名数据
-- =====================================================
DELIMITER //

DROP PROCEDURE IF EXISTS generate_training_enrollments//
CREATE PROCEDURE generate_training_enrollments()
BEGIN
    DECLARE v_course_id BIGINT;
    DECLARE v_emp_id BIGINT;
    DECLARE v_enrollment_time DATETIME;
    DECLARE v_approval_status TINYINT;
    DECLARE v_attendance_status TINYINT;
    DECLARE v_score INT;
    DECLARE v_done1 INT DEFAULT 0;
    DECLARE v_done2 INT DEFAULT 0;
    DECLARE v_counter INT DEFAULT 0;

    DECLARE course_cursor CURSOR FOR
        SELECT course_id FROM training_course WHERE deleted = 0;

    DECLARE CONTINUE HANDLER FOR NOT FOUND SET v_done1 = 1;

    OPEN course_cursor;

    course_loop: LOOP
        FETCH course_cursor INTO v_course_id;
        IF v_done1 = 1 THEN
            LEAVE course_loop;
        END IF;

        -- 为每个课程随机报名5-15个员工
        SET v_done2 = 0;
        BEGIN
            DECLARE emp_cursor CURSOR FOR
                SELECT emp_id FROM employee WHERE status = 1 AND deleted = 0 ORDER BY RAND() LIMIT 15;

            OPEN emp_cursor;

            emp_loop: LOOP
                FETCH emp_cursor INTO v_emp_id;
                IF v_done2 = 1 THEN
                    LEAVE emp_loop;
                END IF;

                -- 随机报名时间和状态
                SET v_enrollment_time = DATE_SUB(NOW(), INTERVAL FLOOR(RAND() * 30) DAY);
                SET v_approval_status = FLOOR(RAND() * 3);
                SET v_attendance_status = IF(v_approval_status = 1, FLOOR(RAND() * 2), 0);
                SET v_score = IF(v_attendance_status = 1, 60 + FLOOR(RAND() * 40), NULL);

                -- 插入报名记录
                INSERT INTO training_enrollment (course_id, emp_id, enrollment_time, approval_status, attendance_status, score, feedback)
                VALUES (v_course_id, v_emp_id, v_enrollment_time, v_approval_status, v_attendance_status, v_score,
                    IF(v_attendance_status = 1, '培训收获很大', NULL));

                SET v_counter = v_counter + 1;
            END LOOP emp_loop;

            CLOSE emp_cursor;
        END;
    END LOOP course_loop;

    CLOSE course_cursor;

    SELECT CONCAT('成功生成 ', v_counter, ' 条培训报名记录!') AS message;
END//

DELIMITER ;

-- 执行存储过程
CALL generate_training_enrollments();

-- 输出统计
SELECT '======================================' AS '';
SELECT '培训数据统计:' AS message;
SELECT '======================================' AS '';
SELECT '培训课程数量:' AS item, COUNT(*) AS count FROM training_course WHERE deleted = 0
UNION ALL
SELECT '培训报名数量:' AS item, COUNT(*) AS count FROM training_enrollment WHERE deleted = 0;

DROP PROCEDURE IF EXISTS generate_training_enrollments;
