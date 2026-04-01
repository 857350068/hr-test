-- 人力资源数据中心数据库初始化脚本

-- 创建数据库
CREATE DATABASE IF NOT EXISTS hr_datacenter DEFAULT CHARSET utf8mb4 COLLATE utf8mb4_unicode_ci;

USE hr_datacenter;

-- 用户表
CREATE TABLE IF NOT EXISTS `sys_user` (
    `user_id` BIGINT NOT NULL AUTO_INCREMENT COMMENT '用户ID',
    `username` VARCHAR(50) NOT NULL COMMENT '用户名',
    `password` VARCHAR(100) NOT NULL COMMENT '密码',
    `real_name` VARCHAR(50) DEFAULT NULL COMMENT '真实姓名',
    `dept_id` BIGINT DEFAULT NULL COMMENT '部门ID',
    `phone` VARCHAR(20) DEFAULT NULL COMMENT '手机号码',
    `email` VARCHAR(100) DEFAULT NULL COMMENT '邮箱',
    `status` TINYINT DEFAULT 1 COMMENT '用户状态(0-禁用 1-启用)',
    `last_login_time` DATETIME DEFAULT NULL COMMENT '最后登录时间',
    `create_time` DATETIME DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',
    `update_time` DATETIME DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT '更新时间',
    `deleted` TINYINT DEFAULT 0 COMMENT '删除标记(0-未删除 1-已删除)',
    PRIMARY KEY (`user_id`),
    UNIQUE KEY `uk_username` (`username`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COMMENT='用户表';

-- 员工表
CREATE TABLE IF NOT EXISTS `employee` (
    `emp_id` BIGINT NOT NULL AUTO_INCREMENT COMMENT '员工ID',
    `emp_no` VARCHAR(20) DEFAULT NULL COMMENT '员工编号',
    `emp_name` VARCHAR(50) NOT NULL COMMENT '员工姓名',
    `gender` TINYINT DEFAULT NULL COMMENT '性别(0-女 1-男)',
    `birth_date` DATE DEFAULT NULL COMMENT '出生日期',
    `id_card` VARCHAR(18) DEFAULT NULL COMMENT '身份证号',
    `phone` VARCHAR(20) DEFAULT NULL COMMENT '手机号码',
    `email` VARCHAR(100) DEFAULT NULL COMMENT '邮箱',
    `department` VARCHAR(50) DEFAULT NULL COMMENT '部门',
    `position` VARCHAR(50) DEFAULT NULL COMMENT '职位',
    `salary` DECIMAL(10,2) DEFAULT NULL COMMENT '薪资',
    `hire_date` DATE DEFAULT NULL COMMENT '入职日期',
    `resign_date` DATE DEFAULT NULL COMMENT '离职日期',
    `status` TINYINT DEFAULT 1 COMMENT '员工状态(0-离职 1-在职 2-试用)',
    `education` VARCHAR(20) DEFAULT NULL COMMENT '学历',
    `create_time` DATETIME DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',
    `update_time` DATETIME DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT '更新时间',
    `deleted` TINYINT DEFAULT 0 COMMENT '删除标记(0-未删除 1-已删除)',
    PRIMARY KEY (`emp_id`),
    UNIQUE KEY `uk_emp_no` (`emp_no`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COMMENT='员工表';

-- 插入测试用户
INSERT INTO `sys_user` (`username`, `password`, `real_name`, `dept_id`, `phone`, `email`, `status`)
VALUES
('admin', '$2a$10$N.zmdr9k7uOCQb376NoUnuTJ8iAt6Z5EHsM8lE9lBOsl7iAt6Z5EH', '系统管理员', 1, '13800138000', 'admin@hr.com', 1),
('hr001', '$2a$10$N.zmdr9k7uOCQb376NoUnuTJ8iAt6Z5EHsM8lE9lBOsl7iAt6Z5EH', '张三', 2, '13800138001', 'hr001@hr.com', 1);

-- 注意:默认密码是 '123456'

-- 插入测试员工数据
INSERT INTO `employee` (`emp_no`, `emp_name`, `gender`, `birth_date`, `id_card`, `phone`, `email`, `department`, `position`, `salary`, `hire_date`, `status`, `education`)
VALUES
('EMP001', '张三', 1, '1990-01-01', '110101199001011234', '13800138001', 'zhangsan@hr.com', '技术部', 'Java开发工程师', 15000.00, '2020-01-01', 1, '本科'),
('EMP002', '李四', 1, '1992-05-15', '110101199205156789', '13800138002', 'lisi@hr.com', '技术部', '前端开发工程师', 13000.00, '2020-03-15', 1, '本科'),
('EMP003', '王五', 0, '1995-08-20', '110101199508201234', '13800138003', 'wangwu@hr.com', '产品部', '产品经理', 18000.00, '2019-06-01', 1, '硕士'),
('EMP004', '赵六', 1, '1993-11-10', '110101199311105678', '13800138004', 'zhaoliu@hr.com', '市场部', '市场专员', 10000.00, '2021-02-01', 2, '本科'),
('EMP005', '钱七', 0, '1994-03-25', '110101199403251234', '13800138005', 'qianqi@hr.com', '人力资源部', 'HR专员', 9000.00, '2021-05-01', 2, '本科'),
('EMP006', '孙八', 1, '1991-07-08', '110101199107085678', '13800138006', 'sunba@hr.com', '技术部', '架构师', 22000.00, '2018-09-01', 1, '硕士'),
('EMP007', '周九', 0, '1996-12-12', '110101199612121234', '13800138007', 'zhoujiu@hr.com', '设计部', 'UI设计师', 11000.00, '2022-01-01', 2, '本科'),
('EMP008', '吴十', 1, '1989-04-30', '110101198904305678', '13800138008', 'wushi@hr.com', '运营部', '运营经理', 16000.00, '2019-12-01', 1, '本科'),
('EMP009', '郑十一', 0, '1997-09-18', '110101199709181234', '13800138009', 'zhengshiyi@hr.com', '技术部', '测试工程师', 12000.00, '2022-03-01', 2, '本科'),
('EMP010', '王小明', 1, '1998-06-25', '110101199806255678', '13800138010', 'wangxiaoming@hr.com', '产品部', '产品助理', 8000.00, '2023-01-01', 2, '本科');

-- 考勤记录表
CREATE TABLE IF NOT EXISTS `attendance` (
    `attendance_id` BIGINT NOT NULL AUTO_INCREMENT COMMENT '考勤ID',
    `emp_id` BIGINT NOT NULL COMMENT '员工ID',
    `attendance_date` DATE NOT NULL COMMENT '考勤日期',
    `clock_in_time` TIME COMMENT '上班打卡时间',
    `clock_out_time` TIME COMMENT '下班打卡时间',
    `attendance_type` TINYINT DEFAULT 0 COMMENT '考勤类型(0-正常 1-迟到 2-早退 3-旷工 4-请假 5-加班)',
    `attendance_status` TINYINT DEFAULT 0 COMMENT '考勤状态(0-未打卡 1-已打卡 2-请假 3-加班)',
    `work_duration` INT COMMENT '工作时长(分钟)',
    `remark` VARCHAR(255) COMMENT '备注',
    `create_time` DATETIME DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',
    `update_time` DATETIME DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT '更新时间',
    `deleted` TINYINT DEFAULT 0 COMMENT '删除标记(0-未删除 1-已删除)',
    PRIMARY KEY (`attendance_id`),
    KEY `idx_emp_date` (`emp_id`, `attendance_date`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COMMENT='考勤记录表';

-- 请假记录表
CREATE TABLE IF NOT EXISTS `leave` (
    `leave_id` BIGINT NOT NULL AUTO_INCREMENT COMMENT '请假ID',
    `emp_id` BIGINT NOT NULL COMMENT '员工ID',
    `leave_type` TINYINT NOT NULL COMMENT '请假类型(0-事假 1-病假 2-年假 3-婚假 4-产假 5-丧假 6-其他)',
    `start_time` DATETIME NOT NULL COMMENT '请假开始时间',
    `end_time` DATETIME NOT NULL COMMENT '请假结束时间',
    `leave_duration` INT COMMENT '请假时长(小时)',
    `reason` TEXT COMMENT '请假原因',
    `approver_id` BIGINT COMMENT '审批人ID',
    `approval_status` TINYINT DEFAULT 0 COMMENT '审批状态(0-待审批 1-已同意 2-已拒绝 3-已撤回)',
    `approval_comment` VARCHAR(255) COMMENT '审批意见',
    `approval_time` DATETIME COMMENT '审批时间',
    `attachment` VARCHAR(255) COMMENT '附件路径',
    `create_time` DATETIME DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',
    `update_time` DATETIME DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT '更新时间',
    `deleted` TINYINT DEFAULT 0 COMMENT '删除标记(0-未删除 1-已删除)',
    PRIMARY KEY (`leave_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COMMENT='请假记录表';

-- 插入测试考勤数据
INSERT INTO `attendance` (`emp_id`, `attendance_date`, `clock_in_time`, `clock_out_time`, `attendance_type`, `attendance_status`, `work_duration`)
VALUES
(1, CURDATE() - INTERVAL 1 DAY, '08:55:00', '18:05:00', 0, 1, 550),
(2, CURDATE() - INTERVAL 1 DAY, '09:10:00', '18:00:00', 1, 1, 530),
(3, CURDATE() - INTERVAL 1 DAY, '08:50:00', '17:55:00', 2, 1, 525),
(4, CURDATE() - INTERVAL 1 DAY, '09:00:00', '18:00:00', 0, 1, 540),
(5, CURDATE() - INTERVAL 1 DAY, '08:45:00', '18:10:00', 0, 1, 565);

-- 插入测试请假数据
INSERT INTO `leave` (`emp_id`, `leave_type`, `start_time`, `end_time`, `leave_duration`, `reason`, `approver_id`, `approval_status`)
VALUES
(1, 0, DATE_ADD(CURDATE(), INTERVAL 3 DAY), DATE_ADD(CURDATE(), INTERVAL 4 DAY), 8, '家里有事', 2, 0),
(2, 1, DATE_ADD(CURDATE(), INTERVAL 5 DAY), DATE_ADD(CURDATE(), INTERVAL 6 DAY), 8, '身体不舒服', 2, 1),
(3, 2, DATE_ADD(CURDATE(), INTERVAL 7 DAY), DATE_ADD(CURDATE(), INTERVAL 8 DAY), 8, '年假', 2, 0);

-- 绩效目标表
CREATE TABLE IF NOT EXISTS `performance_goal` (
    `goal_id` BIGINT NOT NULL AUTO_INCREMENT COMMENT '目标ID',
    `emp_id` BIGINT NOT NULL COMMENT '员工ID',
    `year` INT NOT NULL COMMENT '评估年度',
    `period_type` TINYINT NOT NULL COMMENT '评估周期(1-年度 2-季度 3-月度)',
    `goal_description` VARCHAR(500) NOT NULL COMMENT '目标描述',
    `weight` INT COMMENT '权重(百分比)',
    `completion_standard` VARCHAR(500) COMMENT '完成标准',
    `goal_status` TINYINT DEFAULT 0 COMMENT '目标状态(0-草稿 1-进行中 2-已完成)',
    `create_time` DATE DEFAULT CURRENT_DATE COMMENT '创建时间',
    `update_time` DATE DEFAULT CURRENT_DATE ON UPDATE CURRENT_DATE COMMENT '更新时间',
    `deleted` TINYINT DEFAULT 0 COMMENT '删除标记(0-未删除 1-已删除)',
    PRIMARY KEY (`goal_id`),
    KEY `idx_emp_year_period` (`emp_id`, `year`, `period_type`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COMMENT='绩效目标表';

-- 绩效评估表
CREATE TABLE IF NOT EXISTS `performance_evaluation` (
    `evaluation_id` BIGINT NOT NULL AUTO_INCREMENT COMMENT '评估ID',
    `emp_id` BIGINT NOT NULL COMMENT '员工ID',
    `year` INT NOT NULL COMMENT '评估年度',
    `period_type` TINYINT NOT NULL COMMENT '评估周期(1-年度 2-季度 3-月度)',
    `quarter` TINYINT COMMENT '季度(季度评估时使用)',
    `month` TINYINT COMMENT '月份(月度评估时使用)',
    `self_score` DECIMAL(5,2) COMMENT '自评分',
    `self_comment` TEXT COMMENT '自评说明',
    `supervisor_score` DECIMAL(5,2) COMMENT '上级评分',
    `supervisor_comment` TEXT COMMENT '上级评价意见',
    `final_score` DECIMAL(5,2) COMMENT '综合评分',
    `performance_level` CHAR(1) COMMENT '绩效等级(S-优秀 A-良好 B-合格 C-需改进 D-不合格)',
    `improvement_plan` TEXT COMMENT '改进建议',
    `interview_record` TEXT COMMENT '面谈记录',
    `interview_date` DATE COMMENT '面谈时间',
    `evaluation_status` TINYINT DEFAULT 0 COMMENT '评估状态(0-未评估 1-已自评 2-已评价 3-已完成)',
    `create_time` DATE DEFAULT CURRENT_DATE COMMENT '创建时间',
    `update_time` DATE DEFAULT CURRENT_DATE ON UPDATE CURRENT_DATE COMMENT '更新时间',
    `deleted` TINYINT DEFAULT 0 COMMENT '删除标记(0-未删除 1-已删除)',
    PRIMARY KEY (`evaluation_id`),
    KEY `idx_emp_year_period` (`emp_id`, `year`, `period_type`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COMMENT='绩效评估表';

-- 插入测试绩效目标数据
INSERT INTO `performance_goal` (`emp_id`, `year`, `period_type`, `goal_description`, `weight`, `completion_standard`, `goal_status`)
VALUES
(1, 2024, 1, '完成3个核心项目开发', 40, '按时交付且质量达标', 2),
(1, 2024, 1, '技术分享3次', 20, '分享内容实用,反响良好', 2),
(1, 2024, 1, '代码质量提升', 20, 'Bug率降低20%', 2),
(1, 2024, 1, '团队协作表现', 20, '配合度高,沟通顺畅', 2),
(2, 2024, 1, '完成5个页面开发', 40, '按时交付且符合设计要求', 2),
(2, 2024, 1, '技术分享2次', 20, '分享内容实用', 2),
(2, 2024, 1, '前端性能优化', 20, '页面加载速度提升30%', 2),
(2, 2024, 1, '团队协作表现', 20, '配合度高', 2);

-- 插入测试绩效评估数据
INSERT INTO `performance_evaluation` (`emp_id`, `year`, `period_type`, `self_score`, `self_comment`, `supervisor_score`, `supervisor_comment`, `final_score`, `performance_level`, `evaluation_status`)
VALUES
(1, 2024, 1, 90.00, '完成了所有目标,质量较高', 92.00, '表现优秀,建议继续提升技术深度', 91.20, 'A', 3),
(2, 2024, 1, 85.00, '基本完成目标,个别地方需要改进', 88.00, '表现良好,建议加强技术深度', 86.80, 'A', 3);

-- 薪资发放表
CREATE TABLE IF NOT EXISTS `salary_payment` (
    `payment_id` BIGINT NOT NULL AUTO_INCREMENT COMMENT '发放ID',
    `emp_id` BIGINT NOT NULL COMMENT '员工ID',
    `year` INT NOT NULL COMMENT '发放年度',
    `month` INT NOT NULL COMMENT '发放月份',
    `basic_salary` DECIMAL(10,2) COMMENT '基本工资',
    `performance_salary` DECIMAL(10,2) COMMENT '绩效工资',
    `position_allowance` DECIMAL(10,2) COMMENT '岗位津贴',
    `transport_allowance` DECIMAL(10,2) COMMENT '交通补贴',
    `communication_allowance` DECIMAL(10,2) COMMENT '通讯补贴',
    `meal_allowance` DECIMAL(10,2) COMMENT '餐补',
    `other_allowance` DECIMAL(10,2) COMMENT '其他补贴',
    `overtime_pay` DECIMAL(10,2) COMMENT '加班费',
    `total_gross_salary` DECIMAL(10,2) COMMENT '应发工资总额',
    `social_insurance_personal` DECIMAL(10,2) COMMENT '社保个人部分',
    `housing_fund_personal` DECIMAL(10,2) COMMENT '公积金个人部分',
    `income_tax` DECIMAL(10,2) COMMENT '个人所得税',
    `other_deduction` DECIMAL(10,2) COMMENT '其他扣款',
    `total_net_salary` DECIMAL(10,2) COMMENT '实发工资总额',
    `payment_status` TINYINT DEFAULT 0 COMMENT '发放状态(0-未发放 1-已发放)',
    `payment_date` DATE COMMENT '发放时间',
    `remark` VARCHAR(255) COMMENT '备注',
    `create_time` DATE DEFAULT CURRENT_DATE COMMENT '创建时间',
    `update_time` DATE DEFAULT CURRENT_DATE ON UPDATE CURRENT_DATE COMMENT '更新时间',
    `deleted` TINYINT DEFAULT 0 COMMENT '删除标记(0-未删除 1-已删除)',
    PRIMARY KEY (`payment_id`),
    KEY `idx_emp_year_month` (`emp_id`, `year`, `month`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COMMENT='薪资发放表';

-- 薪资调整表
CREATE TABLE IF NOT EXISTS `salary_adjustment` (
    `adjustment_id` BIGINT NOT NULL AUTO_INCREMENT COMMENT '调整ID',
    `emp_id` BIGINT NOT NULL COMMENT '员工ID',
    `adjustment_type` TINYINT NOT NULL COMMENT '调整类型(1-晋升 2-降职 3-调薪 4-转正)',
    `before_salary` DECIMAL(10,2) COMMENT '调整前基本工资',
    `after_salary` DECIMAL(10,2) COMMENT '调整后基本工资',
    `adjustment_rate` DECIMAL(5,2) COMMENT '调整幅度(%)',
    `effective_date` DATE COMMENT '生效日期',
    `reason` VARCHAR(500) COMMENT '调整原因',
    `approver_id` BIGINT COMMENT '审批人ID',
    `approval_status` TINYINT DEFAULT 0 COMMENT '审批状态(0-待审批 1-已同意 2-已拒绝)',
    `approval_comment` VARCHAR(255) COMMENT '审批意见',
    `approval_date` DATE COMMENT '审批时间',
    `creator_id` BIGINT COMMENT '创建人ID',
    `create_time` DATE DEFAULT CURRENT_DATE COMMENT '创建时间',
    `update_time` DATE DEFAULT CURRENT_DATE ON UPDATE CURRENT_DATE COMMENT '更新时间',
    `deleted` TINYINT DEFAULT 0 COMMENT '删除标记(0-未删除 1-已删除)',
    PRIMARY KEY (`adjustment_id`),
    KEY `idx_emp_id` (`emp_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COMMENT='薪资调整表';

-- 插入测试薪资发放数据
INSERT INTO `salary_payment` (`emp_id`, `year`, `month`, `basic_salary`, `performance_salary`, `position_allowance`, `transport_allowance`, `communication_allowance`, `meal_allowance`, `overtime_pay`, `social_insurance_personal`, `housing_fund_personal`, `income_tax`, `payment_status`, `payment_date`)
VALUES
(1, 2024, 1, 12000.00, 3000.00, 1000.00, 500.00, 200.00, 300.00, 0.00, 1200.00, 960.00, 850.00, 1, '2024-02-10'),
(1, 2024, 2, 12000.00, 3200.00, 1000.00, 500.00, 200.00, 300.00, 500.00, 1200.00, 960.00, 900.00, 1, '2024-03-10'),
(2, 2024, 1, 10000.00, 2500.00, 800.00, 400.00, 150.00, 250.00, 0.00, 1000.00, 800.00, 650.00, 1, '2024-02-10'),
(3, 2024, 1, 15000.00, 4000.00, 1200.00, 600.00, 300.00, 400.00, 0.00, 1500.00, 1200.00, 1200.00, 1, '2024-02-10');

-- 插入测试薪资调整数据
INSERT INTO `salary_adjustment` (`emp_id`, `adjustment_type`, `before_salary`, `after_salary`, `adjustment_rate`, `effective_date`, `reason`, `approver_id`, `approval_status`, `creator_id`)
VALUES
(1, 4, 10000.00, 12000.00, 20.00, '2024-01-01', '转正调薪', 2, 1, 2),
(2, 1, 9000.00, 10000.00, 11.11, '2024-03-01', '晋升调薪', 2, 1, 2),
(3, 3, 14000.00, 15000.00, 7.14, '2024-02-01', '年度调薪', 2, 1, 2);

-- 培训课程表
CREATE TABLE IF NOT EXISTS `training_course` (
    `course_id` BIGINT NOT NULL AUTO_INCREMENT COMMENT '课程ID',
    `course_name` VARCHAR(100) NOT NULL COMMENT '课程名称',
    `course_type` TINYINT NOT NULL COMMENT '课程类型(1-新员工培训 2-技能培训 3-管理培训 4-安全培训 5-其他)',
    `course_description` TEXT COMMENT '课程描述',
    `instructor` VARCHAR(50) COMMENT '培训讲师',
    `duration` INT COMMENT '培训时长(小时)',
    `location` VARCHAR(100) COMMENT '培训地点',
    `start_date` DATE COMMENT '培训开始时间',
    `end_date` DATE COMMENT '培训结束时间',
    `capacity` INT COMMENT '培训名额',
    `enrolled_count` INT DEFAULT 0 COMMENT '已报名人数',
    `course_status` TINYINT DEFAULT 0 COMMENT '课程状态(0-未开始 1-进行中 2-已结束)',
    `create_time` DATE DEFAULT CURRENT_DATE COMMENT '创建时间',
    `update_time` DATE DEFAULT CURRENT_DATE ON UPDATE CURRENT_DATE COMMENT '更新时间',
    `deleted` TINYINT DEFAULT 0 COMMENT '删除标记(0-未删除 1-已删除)',
    PRIMARY KEY (`course_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COMMENT='培训课程表';

-- 培训报名表
CREATE TABLE IF NOT EXISTS `training_enrollment` (
    `enrollment_id` BIGINT NOT NULL AUTO_INCREMENT COMMENT '报名ID',
    `course_id` BIGINT NOT NULL COMMENT '课程ID',
    `emp_id` BIGINT NOT NULL COMMENT '员工ID',
    `enrollment_time` DATE COMMENT '报名时间',
    `approval_status` TINYINT DEFAULT 0 COMMENT '审核状态(0-待审核 1-已通过 2-已拒绝)',
    `approver_id` BIGINT COMMENT '审核人ID',
    `approval_comment` VARCHAR(255) COMMENT '审核意见',
    `approval_date` DATE COMMENT '审核时间',
    `attendance_status` TINYINT DEFAULT 0 COMMENT '出勤状态(0-未出勤 1-已出勤 2-请假)',
    `score` INT COMMENT '培训成绩',
    `feedback` TEXT COMMENT '培训反馈',
    `create_time` DATE DEFAULT CURRENT_DATE COMMENT '创建时间',
    `update_time` DATE DEFAULT CURRENT_DATE ON UPDATE CURRENT_DATE COMMENT '更新时间',
    `deleted` TINYINT DEFAULT 0 COMMENT '删除标记(0-未删除 1-已删除)',
    PRIMARY KEY (`enrollment_id`),
    KEY `idx_course_id` (`course_id`),
    KEY `idx_emp_id` (`emp_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COMMENT='培训报名表';

-- 插入测试培训课程数据
INSERT INTO `training_course` (`course_name`, `course_type`, `course_description`, `instructor`, `duration`, `location`, `start_date`, `end_date`, `capacity`, `enrolled_count`, `course_status`)
VALUES
('新员工入职培训', 1, '帮助新员工快速了解公司文化和规章制度', '张经理', 8, '会议室A', '2024-02-01', '2024-02-01', 20, 15, 2),
('Java高级开发技能培训', 2, '提升Java开发技能,学习新技术', '李架构师', 16, '培训室B', '2024-03-01', '2024-03-02', 15, 12, 1),
('中层管理能力提升培训', 3, '提升中层管理者的领导力和管理能力', '王总监', 12, '会议室C', '2024-04-01', '2024-04-03', 10, 8, 0);

-- 插入测试培训报名数据
INSERT INTO `training_enrollment` (`course_id`, `emp_id`, `enrollment_time`, `approval_status`, `approver_id`, `attendance_status`, `score`)
VALUES
(1, 4, '2024-01-25', 1, 2, 1, 90),
(1, 5, '2024-01-26', 1, 2, 1, 85),
(1, 9, '2024-01-27', 1, 2, 1, 88),
(2, 1, '2024-02-20', 1, 2, 1, 92),
(2, 2, '2024-02-21', 1, 2, 0, NULL),
(3, 3, '2024-03-20', 0, NULL, 0, NULL);
