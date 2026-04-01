package com.hr.backend.exception;

import com.hr.backend.common.BaseException;
import com.hr.backend.common.ErrorCode;
import com.hr.backend.common.Response;
import lombok.extern.slf4j.Slf4j;
import org.springframework.security.access.AccessDeniedException;
import org.springframework.security.core.AuthenticationException;
import org.springframework.validation.BindingResult;
import org.springframework.validation.FieldError;
import org.springframework.web.bind.MethodArgumentNotValidException;
import org.springframework.web.bind.annotation.ExceptionHandler;
import org.springframework.web.bind.annotation.RestControllerAdvice;

import java.util.stream.Collectors;

@RestControllerAdvice
@Slf4j
public class GlobalExceptionHandler {

    @ExceptionHandler(BaseException.class)
    public Response<Void> handleBaseException(BaseException e) {
        log.error("业务异常: {}", e.getMessage());
        return Response.error(e.getCode(), e.getMessage());
    }

    @ExceptionHandler(BusinessException.class)
    public Response<Void> handleBusinessException(BusinessException e) {
        log.error("业务异常: code={}, message={}", e.getCode(), e.getMessage());
        return Response.error(e.getCode(), e.getMessage());
    }

    @ExceptionHandler(RuntimeException.class)
    public Response<Void> handleRuntimeException(RuntimeException e) {
        log.error("运行时异常: {}", e.getMessage(), e);
        return Response.error(ErrorCode.SYSTEM_ERROR.getCode(), "系统错误，请稍后重试");
    }

    @ExceptionHandler(MethodArgumentNotValidException.class)
    public Response<Void> handleValidationException(MethodArgumentNotValidException e) {
        BindingResult br = e.getBindingResult();
        String msg = br.getFieldErrors().stream()
                .map(FieldError::getDefaultMessage)
                .collect(Collectors.joining("; "));
        log.error("参数校验异常: {}", msg);
        return Response.error(ErrorCode.PARAM_ERROR.getCode(), msg);
    }

    @ExceptionHandler(AuthenticationException.class)
    public Response<Void> handleAuthenticationException(AuthenticationException e) {
        log.error("认证异常: {}", e.getMessage());
        return Response.error(ErrorCode.UNAUTHORIZED.getCode(), "认证失败，请重新登录");
    }

    @ExceptionHandler(AccessDeniedException.class)
    public Response<Void> handleAccessDeniedException(AccessDeniedException e) {
        log.error("权限异常: {}", e.getMessage());
        return Response.error(ErrorCode.FORBIDDEN.getCode(), "权限不足");
    }
}
