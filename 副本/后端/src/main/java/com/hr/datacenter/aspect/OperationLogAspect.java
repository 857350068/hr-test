package com.hr.datacenter.aspect;

import com.fasterxml.jackson.databind.ObjectMapper;
import com.hr.datacenter.annotation.OperationLog;
import com.hr.datacenter.entity.SysOperationLog;
import com.hr.datacenter.service.OperationLogService;
import lombok.extern.slf4j.Slf4j;
import org.aspectj.lang.ProceedingJoinPoint;
import org.aspectj.lang.annotation.Around;
import org.aspectj.lang.annotation.Aspect;
import org.aspectj.lang.reflect.MethodSignature;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Component;
import org.springframework.web.context.request.RequestContextHolder;
import org.springframework.web.context.request.ServletRequestAttributes;
import org.springframework.web.multipart.MultipartFile;

import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
import java.lang.reflect.Method;
import java.time.LocalDateTime;
import java.util.HashMap;
import java.util.Map;

/**
 * 操作日志切面
 *
 * @author HR DataCenter Team
 * @since 2024-01-20
 */
@Slf4j
@Aspect
@Component
public class OperationLogAspect {

    @Autowired
    private OperationLogService operationLogService;

    @Autowired
    private ObjectMapper objectMapper;

    @Around("@annotation(com.hr.datacenter.annotation.OperationLog)")
    public Object around(ProceedingJoinPoint point) throws Throwable {
        long startTime = System.currentTimeMillis();

        // 获取注解信息
        MethodSignature signature = (MethodSignature) point.getSignature();
        Method method = signature.getMethod();
        OperationLog operationLog = method.getAnnotation(OperationLog.class);

        // 构建日志对象
        SysOperationLog logEntity = new SysOperationLog();
        logEntity.setModule(operationLog.module());
        logEntity.setOperationType(operationLog.type());
        logEntity.setOperationDesc(operationLog.description());
        logEntity.setOperationTime(LocalDateTime.now());

        // 获取请求信息
        ServletRequestAttributes attributes = (ServletRequestAttributes) RequestContextHolder.getRequestAttributes();
        if (attributes != null) {
            HttpServletRequest request = attributes.getRequest();
            logEntity.setRequestMethod(request.getMethod());
            logEntity.setRequestUrl(request.getRequestURI());
            logEntity.setIpAddress(getIpAddress(request));

            // 获取用户信息
            String token = request.getHeader("Authorization");
            if (token != null && token.startsWith("Bearer ")) {
                // 这里可以从token中解析用户信息
                logEntity.setOperator("当前用户"); // 实际应该从token解析
            }
        }

        // 记录请求参数
        if (operationLog.isSaveRequestData()) {
            String requestParams = getRequestParams(point);
            logEntity.setRequestParams(requestParams);
        }

        Object result = null;
        Exception exception = null;

        try {
            // 执行方法
            result = point.proceed();

            // 记录响应结果
            if (operationLog.isSaveResponseData() && result != null) {
                String responseResult = objectMapper.writeValueAsString(result);
                // 限制响应结果长度
                if (responseResult.length() > 2000) {
                    responseResult = responseResult.substring(0, 2000) + "...";
                }
                logEntity.setResponseResult(responseResult);
            }

            logEntity.setStatus(1); // 成功
            return result;

        } catch (Exception e) {
            exception = e;
            logEntity.setStatus(0); // 失败
            logEntity.setErrorMsg(e.getMessage());
            throw e;

        } finally {
            // 计算执行时间
            long endTime = System.currentTimeMillis();
            logEntity.setExecutionTime(endTime - startTime);

            // 异步保存日志
            try {
                operationLogService.saveLog(logEntity);
            } catch (Exception e) {
                log.error("保存操作日志失败", e);
            }

            // 打印日志
            if (exception == null) {
                log.info("操作日志: 模块={}, 类型={}, 描述={}, 耗时={}ms",
                        logEntity.getModule(), logEntity.getOperationType(),
                        logEntity.getOperationDesc(), logEntity.getExecutionTime());
            } else {
                log.error("操作日志: 模块={}, 类型={}, 描述={}, 错误={}",
                        logEntity.getModule(), logEntity.getOperationType(),
                        logEntity.getOperationDesc(), exception.getMessage());
            }
        }
    }

    /**
     * 获取请求参数
     */
    private String getRequestParams(ProceedingJoinPoint point) {
        try {
            MethodSignature signature = (MethodSignature) point.getSignature();
            String[] paramNames = signature.getParameterNames();
            Object[] paramValues = point.getArgs();

            Map<String, Object> params = new HashMap<>();
            for (int i = 0; i < paramNames.length; i++) {
                Object value = paramValues[i];
                // 过滤掉不需要的参数
                if (value instanceof HttpServletRequest ||
                    value instanceof HttpServletResponse ||
                    value instanceof MultipartFile) {
                    continue;
                }
                params.put(paramNames[i], value);
            }

            String json = objectMapper.writeValueAsString(params);
            // 限制参数长度
            if (json.length() > 2000) {
                json = json.substring(0, 2000) + "...";
            }
            return json;
        } catch (Exception e) {
            return "";
        }
    }

    /**
     * 获取IP地址
     */
    private String getIpAddress(HttpServletRequest request) {
        String ip = request.getHeader("X-Forwarded-For");
        if (ip == null || ip.length() == 0 || "unknown".equalsIgnoreCase(ip)) {
            ip = request.getHeader("Proxy-Client-IP");
        }
        if (ip == null || ip.length() == 0 || "unknown".equalsIgnoreCase(ip)) {
            ip = request.getHeader("WL-Proxy-Client-IP");
        }
        if (ip == null || ip.length() == 0 || "unknown".equalsIgnoreCase(ip)) {
            ip = request.getHeader("HTTP_CLIENT_IP");
        }
        if (ip == null || ip.length() == 0 || "unknown".equalsIgnoreCase(ip)) {
            ip = request.getHeader("HTTP_X_FORWARDED_FOR");
        }
        if (ip == null || ip.length() == 0 || "unknown".equalsIgnoreCase(ip)) {
            ip = request.getRemoteAddr();
        }
        return ip;
    }
}
