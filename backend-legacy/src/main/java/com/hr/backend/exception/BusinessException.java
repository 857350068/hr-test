package com.hr.backend.exception;

import lombok.Getter;

/**
 * 业务异常类
 *
 * @author HrDataCenter
 * @since 2026-03-24
 */
@Getter
public class BusinessException extends RuntimeException {

    private final String code;
    private final String message;

    public BusinessException(String code, String message) {
        super(message);
        this.code = code;
        this.message = message;
    }

    public BusinessException(String message) {
        super(message);
        this.code = "BUSINESS_ERROR";
        this.message = message;
    }
}
