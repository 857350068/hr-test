package com.hr.backend.security;

import com.hr.backend.model.entity.User;
import org.springframework.security.core.context.SecurityContextHolder;

public final class SecurityUtil {

    public static User getCurrentUser() {
        Object principal = SecurityContextHolder.getContext().getAuthentication().getPrincipal();
        if (principal instanceof User) {
            return (User) principal;
        }
        return null;
    }

    public static Long getCurrentUserId() {
        User u = getCurrentUser();
        return u == null ? null : u.getId();
    }

    public static boolean isAdmin() {
        User u = getCurrentUser();
        return u != null && "HR_ADMIN".equals(u.getRole());
    }
}
