package com.hr.backend.security;

import com.hr.backend.model.entity.User;
import org.springframework.security.core.context.SecurityContextHolder;

/**
 * 安全工具类
 *
 * @author HrDataCenter
 * @since 2026-03-24
 */
public final class SecurityUtil {

    /**
     * 获取当前登录用户
     *
     * @return 当前用户对象，如果未登录则返回null
     */
    public static User getCurrentUser() {
        Object principal = SecurityContextHolder.getContext().getAuthentication().getPrincipal();
        if (principal instanceof User) {
            return (User) principal;
        }
        return null;
    }

    /**
     * 获取当前用户ID
     *
     * @return 当前用户ID，如果未登录则返回null
     */
    public static Long getCurrentUserId() {
        User u = getCurrentUser();
        return u == null ? null : u.getId();
    }

    /**
     * 获取当前用户名
     *
     * @return 当前用户名，如果未登录则返回null
     */
    public static String getCurrentUsername() {
        User u = getCurrentUser();
        return u == null ? null : u.getUsername();
    }

    /**
     * 判断当前用户是否为管理员
     *
     * @return true-管理员，false-非管理员
     */
    public static boolean isAdmin() {
        User u = getCurrentUser();
        return u != null && "HR_ADMIN".equals(u.getRole());
    }
}
