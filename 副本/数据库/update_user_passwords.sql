-- ============================================================================
-- 人力资源数据中心系统 - 更新用户密码SQL脚本
-- 使用项目原生的BCrypt加密器生成的密文，确保100%兼容
-- ============================================================================

USE hr_datacenter;

-- 更新管理员账号 admin (密码: 123456)
UPDATE sys_user SET password = '$2a$10$FdfhJ8LfmYT.mWXFa5Ba3.niJvVgJMxmM5lrPpsxxpDXeSom7Mr5C'
WHERE username = 'admin';

-- 更新HR账号 hr001 (密码: 123456)
UPDATE sys_user SET password = '$2a$10$FdfhJ8LfmYT.mWXFa5Ba3.niJvVgJMxmM5lrPpsxxpDXeSom7Mr5C'
WHERE username = 'hr001';

-- 添加更多测试用户（可选）
-- INSERT INTO sys_user (username, password, real_name, dept_id, phone, email, status) VALUES
-- ('test001', '$2a$10$FdfhJ8LfmYT.mWXFa5Ba3.niJvVgJMxmM5lrPpsxxpDXeSom7Mr5C', '测试用户', 1, '13800138002', 'test001@hrdatacenter.com', 1);

COMMIT;

-- 验证更新结果
SELECT user_id, username, real_name, LEFT(password, 20) as '密码前20位', status
FROM sys_user
WHERE deleted = 0;

-- ============================================================================
-- 常用密码的BCrypt密文对照表（由项目原生BCrypt生成）
-- ============================================================================
-- 明文: 123456    -> 密文: $2a$10$FdfhJ8LfmYT.mWXFa5Ba3.niJvVgJMxmM5lrPpsxxpDXeSom7Mr5C
-- 明文: admin     -> 密文: $2a$10$9We7aqjdBilyhWyvxhdpNOc4SkfP1CmYrt0MU9qByRZt9MAoPgvfW
-- 明文: password  -> 密文: $2a$10$j4dS01gsJwQa9/NFTFBM2eiW1pKYLExwGH9cJliq0AGnf9MHEnjfu
-- 明文: test123   -> 密文: $2a$10$0yzz5.kLSx.2fP3SqRG7dOWtXFM3MlXY6wuTGuuHkkCkNVsoFEDY2
-- 明文: hr123456  -> 密文: $2a$10$YsH2LoJxtbj87XEZr7Nm9OU3nSmXbE7zDLbEYRSirO6utwUKrKAHW
-- ============================================================================

-- ============================================================================
-- 如何生成新的密码密文
-- ============================================================================
-- 方法1: 运行项目自带的密码生成工具
-- cd backend
-- mvn exec:java -Dexec.mainClass="com.hr.datacenter.util.PasswordGenerator"

-- 方法2: 修改 PasswordGenerator.java 中的密码，然后重新运行
-- 编辑文件: backend/src/main/java/com/hr/datacenter/util/PasswordGenerator.java
-- 修改第10行的 String rawPassword = "你的密码";
-- 然后运行: mvn exec:java -Dexec.mainClass="com.hr.datacenter.util.PasswordGenerator"
-- ============================================================================