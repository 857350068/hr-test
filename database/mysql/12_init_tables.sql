-- 消息表
CREATE TABLE IF NOT EXISTS `sys_message` (
  `message_id` BIGINT NOT NULL AUTO_INCREMENT COMMENT '消息ID',
  `sender_id` BIGINT DEFAULT NULL COMMENT '发送者ID',
  `receiver_id` BIGINT NOT NULL COMMENT '接收者ID',
  `title` VARCHAR(200) NOT NULL COMMENT '消息标题',
  `content` TEXT COMMENT '消息内容',
  `message_type` TINYINT NOT NULL DEFAULT 1 COMMENT '消息类型 1-系统消息 2-审批提醒 3-个人消息',
  `is_read` TINYINT NOT NULL DEFAULT 0 COMMENT '是否已读 0-未读 1-已读',
  `related_id` BIGINT DEFAULT NULL COMMENT '关联ID',
  `create_time` DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',
  `read_time` DATETIME DEFAULT NULL COMMENT '阅读时间',
  PRIMARY KEY (`message_id`),
  KEY `idx_receiver_id` (`receiver_id`),
  KEY `idx_create_time` (`create_time`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COMMENT='消息表';

-- 操作日志表
CREATE TABLE IF NOT EXISTS `sys_operation_log` (
  `log_id` BIGINT NOT NULL AUTO_INCREMENT COMMENT '日志ID',
  `module` VARCHAR(50) DEFAULT NULL COMMENT '操作模块',
  `operation_type` VARCHAR(50) DEFAULT NULL COMMENT '操作类型',
  `operation_desc` VARCHAR(200) DEFAULT NULL COMMENT '操作描述',
  `request_method` VARCHAR(10) DEFAULT NULL COMMENT '请求方法',
  `request_url` VARCHAR(500) DEFAULT NULL COMMENT '请求URL',
  `request_params` TEXT COMMENT '请求参数',
  `response_result` TEXT COMMENT '响应结果',
  `operator` VARCHAR(50) DEFAULT NULL COMMENT '操作人',
  `ip_address` VARCHAR(50) DEFAULT NULL COMMENT 'IP地址',
  `operation_time` DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT '操作时间',
  `execution_time` BIGINT DEFAULT NULL COMMENT '执行时长(毫秒)',
  `status` TINYINT NOT NULL DEFAULT 1 COMMENT '状态 0-失败 1-成功',
  `error_msg` TEXT COMMENT '错误信息',
  PRIMARY KEY (`log_id`),
  KEY `idx_module` (`module`),
  KEY `idx_operation_time` (`operation_time`),
  KEY `idx_status` (`status`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COMMENT='操作日志表';
