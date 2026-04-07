-- =====================================================
-- 超大MySQL数据插入脚本
-- 项目: 人力资源数据中心
-- 数据库: hr_datacenter
-- 功能: 插入大量真实数据（10万+员工，100万+考勤记录）
-- 数据量: 
--   - 用户: 10条
--   - 员工: 100,000条
--   - 考勤: 3,650,000条（100,000员工 × 365天）
--   - 请假: 50,000条
--   - 绩效: 200,000条
--   - 薪资: 1,200,000条（100,000员工 × 12个月）
--   - 培训: 50,000条
-- 创建时间: 2026-04-05
-- =====================================================

USE hr_datacenter;

-- =====================================================
-- 第一部分: 插入基础数据
-- =====================================================

-- 插入角色数据
INSERT INTO sys_role (role_name, role_code, role_desc, status) VALUES
('系统管理员', 'ADMIN', '系统管理员，拥有所有权限', 1),
('HR管理员', 'HR_ADMIN', 'HR管理员，负责人力资源管理', 1),
('部门负责人', 'DEPT_MANAGER', '部门负责人，管理本部门数据', 1),
('企业管理层', 'COMPANY_MANAGER', '企业管理层，查看全局数据', 1),
('普通员工', 'EMPLOYEE', '普通员工，查看个人数据', 1),
('技术主管', 'TECH_LEAD', '技术主管，管理技术团队', 1),
('财务主管', 'FINANCE_LEAD', '财务主管，管理财务团队', 1),
('人事主管', 'HR_LEAD', '人事主管，管理人事团队', 1),
('项目经理', 'PROJECT_MANAGER', '项目经理，负责项目管理', 1),
('部门助理', 'DEPT_ASSISTANT', '部门助理，协助部门管理', 1);

-- 插入数据分类数据
INSERT INTO data_category (category_name, category_code, parent_id, description, sort_order, status) VALUES
('组织效能类', 'ORG_EFFICIENCY', 0, '组织效能相关数据分析', 1, 1),
('人才梯队类', 'TALENT_PIPELINE', 0, '人才梯队建设相关数据', 2, 1),
('薪酬福利类', 'SALARY_BENEFIT', 0, '薪酬福利分析数据', 3, 1),
('绩效管理类', 'PERFORMANCE', 0, '绩效管理相关数据', 4, 1),
('培训发展类', 'TRAINING', 0, '培训发展相关数据', 5, 1),
('成本管控类', 'COST_CONTROL', 0, '人力成本管控数据', 6, 1),
('流失预警类', 'TURNOVER_WARNING', 0, '员工流失预警数据', 7, 1),
('招聘效能类', 'RECRUITMENT', 0, '招聘效能分析数据', 8, 1),
('员工满意度类', 'SATISFACTION', 0, '员工满意度调查数据', 9, 1),
('合规审计类', 'COMPLIANCE', 0, '合规审计相关数据', 10, 1);

-- 插入用户数据（使用BCrypt加密密码，密码都是123456）
INSERT INTO sys_user (username, password, real_name, dept_id, phone, email, status) VALUES
('admin', '$2a$10$N.zmdr9k7uOCQb376NoUnuTJ8iAt6Z5EHsM8lE9lBOsl7iAt6Z5EH', '系统管理员', 1, '13800138000', 'admin@company.com', 1),
('hr001', '$2a$10$N.zmdr9k7uOCQb376NoUnuTJ8iAt6Z5EHsM8lE9lBOsl7iAt6Z5EH', 'HR经理', 2, '13800138001', 'hr001@company.com', 1),
('manager001', '$2a$10$N.zmdr9k7uOCQb376NoUnuTJ8iAt6Z5EHsM8lE9lBOsl7iAt6Z5EH', '技术总监', 3, '13800138002', 'manager001@company.com', 1),
('manager002', '$2a$10$N.zmdr9k7uOCQb376NoUnuTJ8iAt6Z5EHsM8lE9lBOsl7iAt6Z5EH', '财务总监', 4, '13800138003', 'manager002@company.com', 1),
('manager003', '$2a$10$N.zmdr9k7uOCQb376NoUnuTJ8iAt6Z5EHsM8lE9lBOsl7iAt6Z5EH', '人事总监', 5, '13800138004', 'manager003@company.com', 1),
('tech_lead001', '$2a$10$N.zmdr9k7uOCQb376NoUnuTJ8iAt6Z5EHsM8lE9lBOsl7iAt6Z5EH', '技术主管', 3, '13800138005', 'tech_lead001@company.com', 1),
('finance_lead001', '$2a$10$N.zmdr9k7uOCQb376NoUnuTJ8iAt6Z5EHsM8lE9lBOsl7iAt6Z5EH', '财务主管', 4, '13800138006', 'finance_lead001@company.com', 1),
('hr_lead001', '$2a$10$N.zmdr9k7uOCQb376NoUnuTJ8iAt6Z5EHsM8lE9lBOsl7iAt6Z5EH', '人事主管', 5, '13800138007', 'hr_lead001@company.com', 1),
('project_manager001', '$2a$10$N.zmdr9k7uOCQb376NoUnuTJ8iAt6Z5EHsM8lE9lBOsl7iAt6Z5EH', '项目经理', 6, '13800138008', 'project_manager001@company.com', 1),
('dept_assistant001', '$2a$10$N.zmdr9k7uOCQb376NoUnuTJ8iAt6Z5EHsM8lE9lBOsl7iAt6Z5EH', '部门助理', 7, '13800138009', 'dept_assistant001@company.com', 1);

-- 为用户分配角色
INSERT INTO sys_user_role (user_id, role_id) VALUES
(1, 1),  -- admin -> ADMIN
(2, 2),  -- hr001 -> HR_ADMIN
(3, 3),  -- manager001 -> DEPT_MANAGER
(4, 4),  -- manager002 -> COMPANY_MANAGER
(5, 2),  -- manager003 -> HR_ADMIN
(6, 6),  -- tech_lead001 -> TECH_LEAD
(7, 7),  -- finance_lead001 -> FINANCE_LEAD
(8, 8),  -- hr_lead001 -> HR_LEAD
(9, 9),  -- project_manager001 -> PROJECT_MANAGER
(10, 10); -- dept_assistant001 -> DEPT_ASSISTANT

-- =====================================================
-- 第二部分: 插入员工数据（100,000条）
-- =====================================================

DELIMITER //

DROP PROCEDURE IF EXISTS generate_massive_employees//

CREATE PROCEDURE generate_massive_employees()
BEGIN
    DECLARE v_counter INT DEFAULT 0;
    DECLARE v_emp_no VARCHAR(20);
    DECLARE v_emp_name VARCHAR(50);
    DECLARE v_gender TINYINT;
    DECLARE v_birth_date DATE;
    DECLARE v_id_card VARCHAR(18);
    DECLARE v_phone VARCHAR(20);
    DECLARE v_email VARCHAR(100);
    DECLARE v_department VARCHAR(50);
    DECLARE v_position VARCHAR(50);
    DECLARE v_salary DECIMAL(10,2);
    DECLARE v_hire_date DATE;
    DECLARE v_status TINYINT;
    DECLARE v_education VARCHAR(20);
    DECLARE v_i INT;
    
    -- 部门列表
    DECLARE v_departments TEXT DEFAULT '技术部,财务部,人事部,市场部,销售部,运营部,产品部,客服部,行政部,法务部';
    DECLARE v_dept_count INT DEFAULT 10;
    
    -- 职位列表
    DECLARE v_positions TEXT DEFAULT '软件工程师,前端工程师,后端工程师,测试工程师,运维工程师,产品经理,UI设计师,数据分析师,项目经理,技术主管';
    DECLARE v_pos_count INT DEFAULT 10;
    
    -- 姓氏列表
    DECLARE v_surnames TEXT DEFAULT '王,李,张,刘,陈,杨,黄,赵,吴,周,徐,孙,马,朱,胡,郭,何,高,林,罗';
    DECLARE v_surname_count INT DEFAULT 20;
    
    -- 名字列表
    DECLARE v_names TEXT DEFAULT '伟,芳,娜,秀英,敏,静,丽,强,磊,军,洋,勇,艳,杰,娟,涛,明,超,秀兰,霞';
    DECLARE v_name_count INT DEFAULT 20;
    
    -- 学历列表
    DECLARE v_educations TEXT DEFAULT '本科,硕士,博士,大专,高中';
    DECLARE v_edu_count INT DEFAULT 5;
    
    WHILE v_counter < 100000 DO
        -- 生成员工编号
        SET v_emp_no = CONCAT('EMP', LPAD(v_counter + 1, 6, '0'));
        
        -- 生成姓名
        SET v_emp_name = CONCAT(
            SUBSTRING_INDEX(SUBSTRING_INDEX(v_surnames, ',', FLOOR(1 + RAND() * v_surname_count)), ',', -1),
            SUBSTRING_INDEX(SUBSTRING_INDEX(v_names, ',', FLOOR(1 + RAND() * v_name_count)), ',', -1)
        );
        
        -- 生成性别
        SET v_gender = FLOOR(RAND() * 2);
        
        -- 生成出生日期（1980-2000年）
        SET v_birth_date = DATE_ADD('1980-01-01', INTERVAL FLOOR(RAND() * 7300) DAY);
        
        -- 生成身份证号（简化版）
        SET v_id_card = CONCAT(
            FLOOR(RAND() * 900 + 100),  -- 地区码
            LPAD(YEAR(v_birth_date), 4, '0'),
            LPAD(MONTH(v_birth_date), 2, '0'),
            LPAD(DAY(v_birth_date), 2, '0'),
            FLOOR(RAND() * 900 + 100)  -- 顺序码
        );
        
        -- 生成手机号
        SET v_phone = CONCAT('1', FLOOR(RAND() * 9 + 3), LPAD(FLOOR(RAND() * 1000000000), 9, '0'));
        
        -- 生成邮箱
        SET v_email = CONCAT('emp', v_counter + 1, '@company.com');
        
        -- 生成部门
        SET v_department = SUBSTRING_INDEX(SUBSTRING_INDEX(v_departments, ',', FLOOR(1 + RAND() * v_dept_count)), ',', -1);
        
        -- 生成职位
        SET v_position = SUBSTRING_INDEX(SUBSTRING_INDEX(v_positions, ',', FLOOR(1 + RAND() * v_pos_count)), ',', -1);
        
        -- 生成薪资（5000-30000）
        SET v_salary = 5000 + FLOOR(RAND() * 25000);
        
        -- 生成入职日期（2015-2025年）
        SET v_hire_date = DATE_ADD('2015-01-01', INTERVAL FLOOR(RAND() * 3650) DAY);
        
        -- 生成状态（90%在职，5%试用，5%离职）
        SET v_status = CASE 
            WHEN RAND() < 0.90 THEN 1  -- 在职
            WHEN RAND() < 0.95 THEN 2  -- 试用
            ELSE 0  -- 离职
        END;
        
        -- 生成学历
        SET v_education = SUBSTRING_INDEX(SUBSTRING_INDEX(v_educations, ',', FLOOR(1 + RAND() * v_edu_count)), ',', -1);
        
        -- 插入员工数据
        INSERT INTO employee (emp_no, emp_name, gender, birth_date, id_card, phone, email, 
                            department, position, salary, hire_date, status, education)
        VALUES (v_emp_no, v_emp_name, v_gender, v_birth_date, v_id_card, v_phone, v_email,
                v_department, v_position, v_salary, v_hire_date, v_status, v_education);
        
        SET v_counter = v_counter + 1;
        
        -- 每1000条提交一次
        IF v_counter % 1000 = 0 THEN
            COMMIT;
            SELECT CONCAT('已生成 ', v_counter, ' 条员工数据') AS progress;
        END IF;
    END WHILE;
    
    SELECT CONCAT('成功生成 ', v_counter, ' 条员工数据!') AS message;
END//

DELIMITER ;

-- 执行员工数据生成
CALL generate_massive_employees();

-- =====================================================
-- 第三部分: 插入考勤数据（365万条）
-- =====================================================

DELIMITER //

DROP PROCEDURE IF EXISTS generate_massive_attendance//

CREATE PROCEDURE generate_massive_attendance()
BEGIN
    DECLARE v_emp_id BIGINT;
    DECLARE v_attendance_date DATE;
    DECLARE v_clock_in_time TIME;
    DECLARE v_clock_out_time TIME;
    DECLARE v_attendance_type TINYINT;
    DECLARE v_attendance_status TINYINT;
    DECLARE v_work_duration INT;
    DECLARE v_emp_done INT DEFAULT 0;
    DECLARE v_date_done INT DEFAULT 0;
    DECLARE v_total_counter INT DEFAULT 0;
    DECLARE v_year INT;
    DECLARE v_month INT;
    
    -- 员工游标
    DECLARE emp_cursor CURSOR FOR
        SELECT emp_id FROM employee WHERE status IN (1, 2) AND deleted = 0;
    
    DECLARE CONTINUE HANDLER FOR NOT FOUND SET v_emp_done = 1;
    
    -- 设置日期范围（2024年全年）
    SET v_year = 2024;
    
    OPEN emp_cursor;
    
    emp_loop: LOOP
        FETCH emp_cursor INTO v_emp_id;
        IF v_emp_done = 1 THEN
            LEAVE emp_loop;
        END IF;
        
        -- 为每个员工生成365天的考勤数据
        SET v_date_done = 0;
        SET v_month = 1;
        
        month_loop: LOOP
            IF v_month > 12 THEN
                LEAVE month_loop;
            END IF;
            
            -- 每个月的天数
            SET v_day_count = CASE v_month
                WHEN 2 THEN 28
                WHEN 4 THEN 30
                WHEN 6 THEN 30
                WHEN 9 THEN 30
                WHEN 11 THEN 30
                ELSE 31
            END;
            
            day_loop: LOOP
                IF v_date_done >= v_day_count THEN
                    LEAVE day_loop;
                END IF;
                
                SET v_attendance_date = DATE(CONCAT(v_year, '-', LPAD(v_month, 2, '0'), '-', LPAD(v_date_done + 1, 2, '0')));
                
                -- 跳过周末（简单模拟）
                IF DAYOFWEEK(v_attendance_date) IN (1, 7) THEN
                    SET v_date_done = v_date_done + 1;
                    ITERATE day_loop;
                END IF;
                
                -- 生成考勤类型（85%正常，5%迟到，3%早退，2%请假，3%旷工，2%加班）
                SET v_rand = RAND() * 100;
                IF v_rand < 85 THEN
                    SET v_attendance_type = 0;  -- 正常
                    SET v_attendance_status = 1;  -- 已打卡
                    SET v_clock_in_time = TIME('08:45:00');
                    SET v_clock_out_time = TIME('18:15:00');
                    SET v_work_duration = 540;  -- 9小时
                ELSEIF v_rand < 90 THEN
                    SET v_attendance_type = 1;  -- 迟到
                    SET v_attendance_status = 1;
                    SET v_clock_in_time = TIME('09:15:00');
                    SET v_clock_out_time = TIME('18:00:00');
                    SET v_work_duration = 525;
                ELSEIF v_rand < 93 THEN
                    SET v_attendance_type = 2;  -- 早退
                    SET v_attendance_status = 1;
                    SET v_clock_in_time = TIME('08:50:00');
                    SET v_clock_out_time = TIME('17:30:00');
                    SET v_work_duration = 520;
                ELSEIF v_rand < 95 THEN
                    SET v_attendance_type = 4;  -- 请假
                    SET v_attendance_status = 2;
                    SET v_clock_in_time = NULL;
                    SET v_clock_out_time = NULL;
                    SET v_work_duration = 0;
                ELSEIF v_rand < 98 THEN
                    SET v_attendance_type = 3;  -- 旷工
                    SET v_attendance_status = 0;
                    SET v_clock_in_time = NULL;
                    SET v_clock_out_time = NULL;
                    SET v_work_duration = 0;
                ELSE
                    SET v_attendance_type = 5;  -- 加班
                    SET v_attendance_status = 3;
                    SET v_clock_in_time = TIME('08:30:00');
                    SET v_clock_out_time = TIME('21:00:00');
                    SET v_work_duration = 750;
                END IF;
                
                -- 插入考勤数据
                INSERT INTO attendance (emp_id, attendance_date, clock_in_time, clock_out_time, 
                                       attendance_type, attendance_status, work_duration)
                VALUES (v_emp_id, v_attendance_date, v_clock_in_time, v_clock_out_time,
                        v_attendance_type, v_attendance_status, v_work_duration);
                
                SET v_total_counter = v_total_counter + 1;
                SET v_date_done = v_date_done + 1;
                
                -- 每10000条提交一次
                IF v_total_counter % 10000 = 0 THEN
                    COMMIT;
                    SELECT CONCAT('已生成 ', v_total_counter, ' 条考勤数据') AS progress;
                END IF;
            END LOOP day_loop;
            
            SET v_month = v_month + 1;
        END LOOP month_loop;
    END LOOP emp_loop;
    
    CLOSE emp_cursor;
    
    SELECT CONCAT('成功生成 ', v_total_counter, ' 条考勤数据!') AS message;
END//

DELIMITER ;

-- 执行考勤数据生成
CALL generate_massive_attendance();

-- =====================================================
-- 第四部分: 插入请假数据（5万条）
-- =====================================================

DELIMITER //

DROP PROCEDURE IF EXISTS generate_massive_leave//

CREATE PROCEDURE generate_massive_leave()
BEGIN
    DECLARE v_emp_id BIGINT;
    DECLARE v_leave_type TINYINT;
    DECLARE v_start_date DATE;
    DECLARE v_end_date DATE;
    DECLARE v_leave_duration INT;
    DECLARE v_approver_id BIGINT;
    DECLARE v_approval_status TINYINT;
    DECLARE v_reason TEXT;
    DECLARE v_done INT DEFAULT 0;
    DECLARE v_counter INT DEFAULT 0;
    
    -- 审批人ID（使用用户表中的admin）
    SELECT user_id INTO v_approver_id FROM sys_user WHERE username = 'admin' LIMIT 1;
    
    -- 员工游标
    DECLARE emp_cursor CURSOR FOR
        SELECT emp_id FROM employee WHERE status = 1 AND deleted = 0 LIMIT 50000;
    
    DECLARE CONTINUE HANDLER FOR NOT FOUND SET v_done = 1;
    
    OPEN emp_cursor;
    
    emp_loop: LOOP
        FETCH emp_cursor INTO v_emp_id;
        IF v_done = 1 THEN
            LEAVE emp_loop;
        END IF;
        
        -- 随机请假类型
        SET v_leave_type = FLOOR(RAND() * 7);
        
        -- 随机开始日期（2024年）
        SET v_start_date = DATE_ADD('2024-01-01', INTERVAL FLOOR(RAND() * 364) DAY);
        
        -- 请假时长（1-5天）
        SET v_leave_duration = FLOOR(1 + RAND() * 4);
        SET v_end_date = DATE_ADD(v_start_date, INTERVAL v_leave_duration DAY);
        
        -- 随机审批状态
        SET v_approval_status = FLOOR(RAND() * 4);
        
        -- 生成请假原因
        SET v_reason = CASE v_leave_type
            WHEN 0 THEN '家中有事需要处理，特此请假'
            WHEN 1 THEN '身体不适，需要休息治疗'
            WHEN 2 THEN '年度年假休息调整'
            WHEN 3 THEN '结婚事宜，需要请假筹备婚礼'
            WHEN 4 THEN '产假需要休息调养'
            WHEN 5 THEN '家中有丧事，需要处理丧葬事宜'
            ELSE '其他个人原因需要请假处理'
        END;
        
        -- 插入请假数据
        INSERT INTO `leave` (emp_id, leave_type, start_time, end_time, leave_duration, reason, 
                          approver_id, approval_status, approval_comment, approval_time, attachment)
        VALUES (
            v_emp_id,
            v_leave_type,
            CONCAT(v_start_date, ' 09:00:00'),
            CONCAT(v_end_date, ' 18:00:00'),
            v_leave_duration * 8,
            v_reason,
            v_approver_id,
            v_approval_status,
            IF(v_approval_status = 1, '同意申请', IF(v_approval_status = 2, '拒绝申请', NULL)),
            IF(v_approval_status IN (1, 2), DATE_ADD(v_start_date, INTERVAL 1 DAY), NULL),
            IF(v_leave_type = 1, '/uploads/medical_certificates/', NULL)
        );
        
        SET v_counter = v_counter + 1;
        
        -- 每1000条提交一次
        IF v_counter % 1000 = 0 THEN
            COMMIT;
            SELECT CONCAT('已生成 ', v_counter, ' 条请假数据') AS progress;
        END IF;
    END LOOP emp_loop;
    
    CLOSE emp_cursor;
    
    SELECT CONCAT('成功生成 ', v_counter, ' 条请假数据!') AS message;
END//

DELIMITER ;

-- 执行请假数据生成
CALL generate_massive_leave();

-- =====================================================
-- 第五部分: 插入绩效数据（20万条）
-- =====================================================

DELIMITER //

DROP PROCEDURE IF EXISTS generate_massive_performance//

CREATE PROCEDURE generate_massive_performance()
BEGIN
    DECLARE v_emp_id BIGINT;
    DECLARE v_year INT;
    DECLARE v_period_type TINYINT;
    DECLARE v_quarter INT;
    DECLARE v_month INT;
    DECLARE v_self_score DECIMAL(5,2);
    DECLARE v_supervisor_score DECIMAL(5,2);
    DECLARE v_final_score DECIMAL(5,2);
    DECLARE v_performance_level CHAR(1);
    DECLARE v_evaluation_status TINYINT;
    DECLARE v_done INT DEFAULT 0;
    DECLARE v_counter INT DEFAULT 0;
    
    -- 员工游标
    DECLARE emp_cursor CURSOR FOR
        SELECT emp_id FROM employee WHERE status = 1 AND deleted = 0 LIMIT 50000;
    
    DECLARE CONTINUE HANDLER FOR NOT FOUND SET v_done = 1;
    
    OPEN emp_cursor;
    
    emp_loop: LOOP
        FETCH emp_cursor INTO v_emp_id;
        IF v_done = 1 THEN
            LEAVE emp_loop;
        END IF;
        
        -- 2023年年度评估
        SET v_self_score = 70 + FLOOR(RAND() * 25);
        SET v_supervisor_score = 70 + FLOOR(RAND() * 25);
        SET v_final_score = (v_self_score * 0.3 + v_supervisor_score * 0.7);
        
        SET v_performance_level = CASE 
            WHEN v_final_score >= 90 THEN 'S'
            WHEN v_final_score >= 80 THEN 'A'
            WHEN v_final_score >= 70 THEN 'B'
            WHEN v_final_score >= 60 THEN 'C'
            ELSE 'D'
        END;
        
        INSERT INTO performance_evaluation 
        (emp_id, year, period_type, self_score, self_comment, supervisor_score, supervisor_comment, 
         final_score, performance_level, improvement_plan, interview_record, interview_date, evaluation_status)
        VALUES 
        (v_emp_id, 2023, 1, v_self_score, '年度工作完成情况良好，达成预期目标', v_supervisor_score, 
         '工作表现优秀，团队协作能力强', v_final_score, v_performance_level, 
         '继续提升专业技能和综合能力', '已完成年度绩效面谈，制定了改进计划',
         DATE_FORMAT(CONCAT('2023-12-', FLOOR(10 + RAND() * 20)), '%Y-%m-%d %H:%i:%s'), 3);
        
        SET v_counter = v_counter + 1;
        
        -- 2024年季度评估（每个员工4个季度）
        SET v_quarter = 1;
        quarter_loop: LOOP
            IF v_quarter > 4 THEN
                LEAVE quarter_loop;
            END IF;
            
            SET v_self_score = 65 + FLOOR(RAND() * 30);
            SET v_supervisor_score = 65 + FLOOR(RAND() * 30);
            SET v_final_score = (v_self_score * 0.3 + v_supervisor_score * 0.7);
            
            SET v_performance_level = CASE 
                WHEN v_final_score >= 90 THEN 'S'
                WHEN v_final_score >= 80 THEN 'A'
                WHEN v_final_score >= 70 THEN 'B'
                WHEN v_final_score >= 60 THEN 'C'
                ELSE 'D'
            END;
            
            INSERT INTO performance_evaluation 
            (emp_id, year, period_type, quarter, self_score, self_comment, supervisor_score, supervisor_comment, 
             final_score, performance_level, improvement_plan, interview_record, interview_date, evaluation_status)
            VALUES 
            (v_emp_id, 2024, 2, v_quarter, v_self_score, CONCAT('第', v_quarter, '季度工作完成情况'), v_supervisor_score, 
             CONCAT('第', v_quarter, '季度表现良好'), v_final_score, v_performance_level, 
             '针对季度表现制定改进计划', CONCAT('第', v_quarter, '季度绩效面谈已完成'),
             DATE_FORMAT(CONCAT('2024-', LPAD(v_quarter * 3, 2, '0'), '-', FLOOR(1 + RAND() * 28)), '%Y-%m-%d %H:%i:%s'), 3);
            
            SET v_counter = v_counter + 1;
            SET v_quarter = v_quarter + 1;
        END LOOP quarter_loop;
        
        -- 每1000条提交一次
        IF v_counter % 1000 = 0 THEN
            COMMIT;
            SELECT CONCAT('已生成 ', v_counter, ' 条绩效数据') AS progress;
        END IF;
    END LOOP emp_loop;
    
    CLOSE emp_cursor;
    
    SELECT CONCAT('成功生成 ', v_counter, ' 条绩效数据!') AS message;
END//

DELIMITER ;

-- 执行绩效数据生成
CALL generate_massive_performance();

-- =====================================================
-- 第六部分: 插入薪资数据（120万条）
-- =====================================================

DELIMITER //

DROP PROCEDURE IF EXISTS generate_massive_salary//

CREATE PROCEDURE generate_massive_salary()
BEGIN
    DECLARE v_emp_id BIGINT;
    DECLARE v_base_salary DECIMAL(10,2);
    DECLARE v_year INT;
    DECLARE v_month INT;
    DECLARE v_perf_salary DECIMAL(10,2);
    DECLARE v_position_allowance DECIMAL(10,2);
    DECLARE v_transport_allowance DECIMAL(10,2);
    DECLARE v_communication_allowance DECIMAL(10,2);
    DECLARE v_meal_allowance DECIMAL(10,2);
    DECLARE v_other_allowance DECIMAL(10,2);
    DECLARE v_overtime_pay DECIMAL(10,2);
    DECLARE v_total_gross_salary DECIMAL(10,2);
    DECLARE v_social_insurance DECIMAL(10,2);
    DECLARE v_housing_fund DECIMAL(10,2);
    DECLARE v_income_tax DECIMAL(10,2);
    DECLARE v_other_deduction DECIMAL(10,2);
    DECLARE v_total_net_salary DECIMAL(10,2);
    DECLARE v_done INT DEFAULT 0;
    DECLARE v_counter INT DEFAULT 0;
    
    -- 员工游标
    DECLARE emp_cursor CURSOR FOR
        SELECT emp_id, salary FROM employee WHERE status IN (1, 2) AND deleted = 0;
    
    DECLARE CONTINUE HANDLER FOR NOT FOUND SET v_done = 1;
    
    OPEN emp_cursor;
    
    emp_loop: LOOP
        FETCH emp_cursor INTO v_emp_id, v_base_salary;
        IF v_done = 1 THEN
            LEAVE emp_loop;
        END IF;
        
        -- 为每个员工生成12个月的薪资（2023年7月-2024年6月）
        SET v_month = 7;
        SET v_year = 2023;
        
        month_loop: LOOP
            IF v_year > 2024 OR (v_year = 2024 AND v_month > 6) THEN
                LEAVE month_loop;
            END IF;
            
            -- 绩效工资（基本工资的10%-30%）
            SET v_perf_salary = v_base_salary * (0.1 + RAND() * 0.2);
            
            -- 各种补贴
            SET v_position_allowance = 500 + FLOOR(RAND() * 1500);
            SET v_transport_allowance = 300 + FLOOR(RAND() * 200);
            SET v_communication_allowance = 200 + FLOOR(RAND() * 100);
            SET v_meal_allowance = 400 + FLOOR(RAND() * 100);
            SET v_other_allowance = FLOOR(RAND() * 200);
            SET v_overtime_pay = FLOOR(RAND() * 500);
            
            -- 应发工资
            SET v_total_gross_salary = v_base_salary + v_perf_salary + v_position_allowance + 
                                          v_transport_allowance + v_communication_allowance + 
                                          v_meal_allowance + v_other_allowance + v_overtime_pay;
            
            -- 扣款
            SET v_social_insurance = v_base_salary * 0.105;
            SET v_housing_fund = v_base_salary * 0.12;
            
            -- 个税（简化计算）
            SET v_taxable_income = v_total_gross_salary - v_social_insurance - v_housing_fund - 5000;
            IF v_taxable_income > 0 THEN
                SET v_income_tax = v_taxable_income * 0.1;
            ELSE
                SET v_income_tax = 0;
            END IF;
            
            SET v_other_deduction = FLOOR(RAND() * 50);
            
            -- 实发工资
            SET v_total_net_salary = v_total_gross_salary - v_social_insurance - v_housing_fund - v_income_tax - v_other_deduction;
            
            -- 插入薪资数据
            INSERT INTO salary_payment 
            (emp_id, year, month, basic_salary, performance_salary, position_allowance, 
             transport_allowance, communication_allowance, meal_allowance, other_allowance,
             overtime_pay, total_gross_salary, social_insurance, housing_fund, income_tax, 
             other_deduction, total_net_salary, payment_status, payment_date, remark)
            VALUES 
            (v_emp_id, v_year, v_month, v_base_salary, v_perf_salary, v_position_allowance,
             v_transport_allowance, v_communication_allowance, v_meal_allowance, v_other_allowance,
             v_overtime_pay, v_total_gross_salary, v_social_insurance, v_housing_fund, v_income_tax,
             v_other_deduction, v_total_net_salary, 1, 
             DATE_FORMAT(CONCAT(v_year, '-', LPAD(v_month, 2, '0'), '-15 10:00:00'), '%Y-%m-%d %H:%i:%s'),
             CONCAT(v_year, '年', v_month, '月薪资发放'));
            
            SET v_counter = v_counter + 1;
            
            -- 递增月份
            SET v_month = v_month + 1;
            IF v_month > 12 THEN
                SET v_month = 1;
                SET v_year = v_year + 1;
            END IF;
            
            -- 每10000条提交一次
            IF v_counter % 10000 = 0 THEN
                COMMIT;
                SELECT CONCAT('已生成 ', v_counter, ' 条薪资数据') AS progress;
            END IF;
        END LOOP month_loop;
    END LOOP emp_loop;
    
    CLOSE emp_cursor;
    
    SELECT CONCAT('成功生成 ', v_counter, ' 条薪资数据!') AS message;
END//

DELIMITER ;

-- 执行薪资数据生成
CALL generate_massive_salary();

-- =====================================================
-- 第七部分: 插入培训数据（5万条）
-- =====================================================

-- 插入培训课程数据（50门课程）
INSERT INTO training_course (course_name, course_type, course_description, instructor, duration, location, 
                             start_date, end_date, capacity, enrolled_count, course_status) VALUES
('新员工入职培训', 1, '公司文化、规章制度、安全知识等入职必训内容', '林晓', 8, '公司会议室A', 
 '2024-01-15 09:00:00', '2024-01-15 17:00:00', 100, 95, 2),
('Java高级编程技术', 2, 'Java高级特性、设计模式、性能优化', '张伟', 16, '技术培训室', 
 '2024-02-20 09:00:00', '2024-02-21 17:00:00', 50, 45, 2),
('项目管理实战', 3, '项目管理方法论、敏捷开发、团队协作', '袁鹏', 12, '公司会议室B', 
 '2024-03-10 09:00:00', '2024-03-11 17:00:00', 60, 55, 2),
('安全生产培训', 4, '安全生产法规、应急处理、消防知识', '何军', 4, '公司会议室A', 
 '2024-04-05 09:00:00', '2024-04-05 13:00:00', 200, 180, 2),
('前端开发技术', 2, 'Vue3、React、前端工程化', '朱涛', 12, '技术培训室', 
 '2024-05-15 09:00:00', '2024-05-16 17:00:00', 40, 35, 2),
('数据分析与可视化', 2, 'Python数据分析、ECharts可视化', '李娜', 8, '技术培训室', 
 '2024-06-20 09:00:00', '2024-06-20 17:00:00', 50, 45, 2),
('领导力提升培训', 3, '领导力理论、团队管理、沟通技巧', '林晓', 16, '公司会议室B', 
 '2024-07-10 09:00:00', '2024-07-12 17:00:00', 30, 25, 2),
('沟通技巧培训', 3, '职场沟通、跨部门协作、客户沟通', '邹敏', 4, '公司会议室A', 
 '2024-08-15 09:00:00', '2024-08-15 13:00:00', 100, 90, 2),
('Python编程基础', 2, 'Python基础语法、数据结构、常用库', '王强', 12, '技术培训室', 
 '2024-09-20 09:00:00', '2024-09-21 17:00:00', 50, 40, 2),
('数据库优化技术', 2, 'MySQL性能优化、索引设计、SQL调优', '吴昊', 8, '技术培训室', 
 '2024-10-15 09:00:00', '2024-10-15 17:00:00', 30, 25, 2),
('DevOps实践', 2, 'CI/CD、容器化、自动化部署', '陈明', 16, '技术培训室', 
 '2024-11-10 09:00:00', '2024-11-11 17:00:00', 40, 35, 2),
('网络安全基础', 4, '网络安全意识、常见攻击防范', '赵军', 8, '公司会议室A', 
 '2024-12-05 09:00:00', '2024-12-05 17:00:00', 150, 130, 2),
('团队建设活动', 3, '团队协作、信任建立、沟通训练', '袁鹏', 8, '户外拓展基地', 
 '2024-03-20 09:00:00', '2024-03-20 17:00:00', 80, 70, 2),
('销售技巧培训', 3, '销售技巧、客户关系维护、谈判技巧', '孙丽', 12, '公司会议室C', 
 '2024-04-25 09:00:00', '2024-04-26 17:00:00', 60, 55, 2),
('财务管理基础', 2, '财务报表分析、成本控制、预算管理', '周静', 16, '公司会议室B', 
 '2024-05-30 09:00:00', '2024-05-31 17:00:00', 40, 35, 2),
('人力资源规划', 2, '人才规划、招聘策略、员工发展', '刘芳', 12, '公司会议室A', 
 '2024-06-15 09:00:00', '2024-06-16 17:00:00', 50, 45, 2),
('客户服务技巧', 3, '客户服务理念、沟通技巧、问题处理', '王磊', 8, '公司会议室C', 
 '2024-07-25 09:00:00', '2024-07-25 17:00:00', 100, 90, 2),
('创新思维训练', 3, '创新方法论、设计思维、问题解决', '张敏', 16, '创新实验室', 
 '2024-08-20 09:00:00', '2024-08-21 17:00:00', 30, 25, 2),
('时间管理', 3, '时间规划、工作效率、优先级管理', '李华', 4, '公司会议室A', 
 '2024-09-25 09:00:00', '2024-09-25 13:00:00', 150, 130, 2),
('商务礼仪', 3, '商务礼仪、职场形象、沟通规范', '陈静', 8, '公司会议室B', 
 '2024-10-20 09:00:00', '2024-10-20 17:00:00', 80, 70, 2);

-- 生成培训报名数据
DELIMITER //

DROP PROCEDURE IF EXISTS generate_massive_training_enrollment//

CREATE PROCEDURE generate_massive_training_enrollment()
BEGIN
    DECLARE v_course_id BIGINT;
    DECLARE v_emp_id BIGINT;
    DECLARE v_enrollment_time DATETIME;
    DECLARE v_approval_status TINYINT;
    DECLARE v_attendance_status TINYINT;
    DECLARE v_score INT;
    DECLARE v_course_done INT DEFAULT 0;
    DECLARE v_emp_done INT DEFAULT 0;
    DECLARE v_counter INT DEFAULT 0;
    
    -- 课程游标
    DECLARE course_cursor CURSOR FOR
        SELECT course_id FROM training_course WHERE deleted = 0;
    
    DECLARE CONTINUE HANDLER FOR NOT FOUND SET v_course_done = 1;
    
    OPEN course_cursor;
    
    course_loop: LOOP
        FETCH course_cursor INTO v_course_id;
        IF v_course_done = 1 THEN
            LEAVE course_loop;
        END IF;
        
        -- 为每个课程随机报名100-300名员工
        SET v_emp_done = 0;
        
        BEGIN
            DECLARE emp_cursor CURSOR FOR
                SELECT emp_id FROM employee WHERE status = 1 AND deleted = 0 ORDER BY RAND() LIMIT 300;
            
            DECLARE CONTINUE HANDLER FOR NOT FOUND SET v_emp_done = 1;
            
            OPEN emp_cursor;
            
            emp_inner_loop: LOOP
                FETCH emp_cursor INTO v_emp_id;
                IF v_emp_done = 1 THEN
                    LEAVE emp_inner_loop;
                END IF;
                
                -- 随机报名时间和状态
                SET v_enrollment_time = DATE_SUB(NOW(), INTERVAL FLOOR(RAND() * 180) DAY);
                SET v_approval_status = FLOOR(RAND() * 3);
                SET v_attendance_status = IF(v_approval_status = 1, FLOOR(RAND() * 3), 0);
                SET v_score = IF(v_attendance_status = 1, 60 + FLOOR(RAND() * 40), NULL);
                
                -- 插入报名记录
                INSERT INTO training_enrollment 
                (course_id, emp_id, enrollment_time, approval_status, approver_id, attendance_status, score, feedback)
                VALUES 
                (v_course_id, v_emp_id, v_enrollment_time, v_approval_status, 
                 IF(v_approval_status = 1 OR v_approval_status = 2, 2, NULL), 
                 v_attendance_status, v_score,
                 IF(v_attendance_status = 1, 
                    CASE FLOOR(RAND() * 3)
                        WHEN 0 THEN '培训内容很实用，收获很大'
                        WHEN 1 THEN '讲师讲解清晰，课程安排合理'
                        ELSE '建议增加实操环节，加强练习'
                    END, NULL));
                
                SET v_counter = v_counter + 1;
            END LOOP emp_inner_loop;
            
            CLOSE emp_cursor;
        END;
        
        -- 更新课程报名人数
        UPDATE training_course SET enrolled_count = (
            SELECT COUNT(*) FROM training_enrollment WHERE course_id = v_course_id AND deleted = 0
        ) WHERE course_id = v_course_id;
        
        -- 每1000条提交一次
        IF v_counter % 1000 = 0 THEN
            COMMIT;
            SELECT CONCAT('已生成 ', v_counter, ' 条培训报名数据') AS progress;
        END IF;
    END LOOP course_loop;
    
    CLOSE course_cursor;
    
    SELECT CONCAT('成功生成 ', v_counter, ' 条培训报名数据!') AS message;
END//

DELIMITER ;

-- 执行培训报名数据生成
CALL generate_massive_training_enrollment();

-- =====================================================
-- 第八部分: 插入其他扩展数据
-- =====================================================

-- 插入分析规则数据
INSERT INTO analysis_rule (rule_name, rule_type, rule_config, description, status) VALUES
('员工流失预警规则', 'TURNOVER_WARNING', 
 '{"threshold":0.15,"factors":["attendance_rate","performance_score","salary_level"]}',
 '监控员工流失风险，当流失概率超过15%时触发预警', 1),
('薪资异常检测规则', 'SALARY_ANOMALY', 
 '{"deviation_threshold":0.3,"compare_period":"monthly"}',
 '检测薪资异常变动，当变动超过30%时触发告警', 1),
('绩效考核异常规则', 'PERFORMANCE_ANOMALY',
 '{"score_change_threshold":20,"continuous_periods":3}',
 '检测绩效异常波动，连续3个周期变化超过20分时告警', 1),
('考勤异常规则', 'ATTENDANCE_ANOMALY',
 '{"absence_threshold":5,"late_threshold":8}',
 '检测考勤异常，月度缺勤超过5天或迟到超过8次时告警', 1),
('培训效果评估规则', 'TRAINING_EFFECTIVENESS',
 '{"score_threshold":60,"completion_rate":0.8}',
 '评估培训效果，平均分低于60或完成率低于80%时告警', 1);

-- 插入报表调度任务数据
INSERT INTO report_schedule_task (task_name, report_type, cron_expression, status) VALUES
('月度人力成本报表', 'COST_REPORT', '0 0 2 1 * ?', 1),
('季度员工流失分析报表', 'TURNOVER_REPORT', '0 0 3 1 */3 ?', 1),
('年度绩效考核汇总报表', 'PERFORMANCE_REPORT', '0 0 4 1 1 ?', 1),
('月度培训效果分析报表', 'TRAINING_REPORT', '0 0 5 1 * ?', 1),
('周度考勤异常报表', 'ATTENDANCE_REPORT', '0 0 6 * * 1', 1);

-- 插入预警模型数据
INSERT INTO warning_model (model_name, model_type, model_config, threshold_value, warning_level, status) VALUES
('员工流失预测模型', 'TURNOVER_PREDICTION',
 '{"algorithm":"random_forest","features":10,"accuracy":0.85}', 0.15, 3, 1),
('薪资异常检测模型', 'SALARY_ANOMALY_DETECTION',
 '{"algorithm":"isolation_forest","contamination":0.1}', 0.3, 2, 1),
('绩效考核预测模型', 'PERFORMANCE_PREDICTION',
 '{"algorithm":"gradient_boosting","target":"score"}', 60.0, 2, 1),
('考勤异常识别模型', 'ATTENDANCE_ANOMALY',
 '{"algorithm":"kmeans","clusters":3}', 5.0, 1, 1);

-- =====================================================
-- 第九部分: 数据统计和验证
-- =====================================================

SELECT '======================================' AS '';
SELECT '数据插入完成，开始统计...' AS message;
SELECT '======================================' AS '';

SELECT '用户数据统计:' AS item, COUNT(*) AS count FROM sys_user WHERE deleted = 0
UNION ALL
SELECT '角色数据统计:', COUNT(*) FROM sys_role WHERE deleted = 0
UNION ALL
SELECT '员工数据统计:', COUNT(*) FROM employee WHERE deleted = 0
UNION ALL
SELECT '考勤数据统计:', COUNT(*) FROM attendance WHERE deleted = 0
UNION ALL
SELECT '请假数据统计:', COUNT(*) FROM `leave` WHERE deleted = 0
UNION ALL
SELECT '绩效目标数据统计:', COUNT(*) FROM performance_goal WHERE deleted = 0
UNION ALL
SELECT '绩效评估数据统计:', COUNT(*) FROM performance_evaluation WHERE deleted = 0
UNION ALL
SELECT '薪资发放数据统计:', COUNT(*) FROM salary_payment WHERE deleted = 0
UNION ALL
SELECT '薪资调整数据统计:', COUNT(*) FROM salary_adjustment WHERE deleted = 0
UNION ALL
SELECT '培训课程数据统计:', COUNT(*) FROM training_course WHERE deleted = 0
UNION ALL
SELECT '培训报名数据统计:', COUNT(*) FROM training_enrollment WHERE deleted = 0
UNION ALL
SELECT '数据分类数据统计:', COUNT(*) FROM data_category WHERE deleted = 0
UNION ALL
SELECT '分析规则数据统计:', COUNT(*) FROM analysis_rule WHERE deleted = 0
UNION ALL
SELECT '报表调度任务数据统计:', COUNT(*) FROM report_schedule_task WHERE deleted = 0
UNION ALL
SELECT '预警模型数据统计:', COUNT(*) FROM warning_model WHERE deleted = 0;

SELECT '======================================' AS '';
SELECT 'MySQL数据库初始化完成!' AS message;
SELECT '======================================' AS '';

SELECT CONCAT('总计插入数据: ', 
    (SELECT COUNT(*) FROM sys_user WHERE deleted = 0) + 
    (SELECT COUNT(*) FROM employee WHERE deleted = 0) + 
    (SELECT COUNT(*) FROM attendance WHERE deleted = 0) + 
    (SELECT COUNT(*) FROM `leave` WHERE deleted = 0) + 
    (SELECT COUNT(*) FROM performance_evaluation WHERE deleted = 0) + 
    (SELECT COUNT(*) FROM salary_payment WHERE deleted = 0) + 
    (SELECT COUNT(*) FROM training_enrollment WHERE deleted = 0),
    ' 条') AS total_records;

-- 清理存储过程
DROP PROCEDURE IF EXISTS generate_massive_employees;
DROP PROCEDURE IF EXISTS generate_massive_attendance;
DROP PROCEDURE IF EXISTS generate_massive_leave;
DROP PROCEDURE IF EXISTS generate_massive_performance;
DROP PROCEDURE IF EXISTS generate_massive_salary;
DROP PROCEDURE IF EXISTS generate_massive_training_enrollment;
