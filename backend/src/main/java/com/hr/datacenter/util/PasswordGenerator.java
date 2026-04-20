package com.hr.datacenter.util;

/**
 * 密码生成工具
 * 作用：输入明文密码 → 生成BCrypt加密密文 → 控制台输出 → 复制到数据库
 */
public class PasswordGenerator {
    public static void main(String[] args) {
        System.out.println("========================================");
        System.out.println("       HR数据中心 - 密码生成工具");
        System.out.println("========================================");

        // 定义需要生成的密码列表
        String[] passwords = {
            "123456",      // 常用测试密码
            "admin",       // 管理员密码
            "password",    // 通用密码
            "test123",     // 测试密码
            "hr123456"     // HR专用密码
        };

        // 批量生成密码
        for (String rawPassword : passwords) {
            String encodedPassword = PasswordUtil.encode(rawPassword);
            System.out.println("\n明文密码：" + rawPassword);
            System.out.println("加密密文：" + encodedPassword);
            System.out.println("----------------------------------------");
        }

        System.out.println("\n✅ SQL更新语句示例：");
        System.out.println("UPDATE sys_user SET password = '$2a$10$FdfhJ8LfmYT.mWXFa5Ba3.niJvVgJMxmM5lrPpsxxpDXeSom7Mr5C' WHERE username = 'admin';");
        System.out.println("UPDATE sys_user SET password = '新生成的密文' WHERE username = '你的用户名';");
        System.out.println("========================================");
    }
}