package com.hr.datacenter.controller;

import com.baomidou.mybatisplus.core.metadata.IPage;
import com.hr.datacenter.common.Result;
import com.hr.datacenter.entity.SalaryPayment;
import com.hr.datacenter.service.SalaryPaymentService;
import lombok.extern.slf4j.Slf4j;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.web.bind.annotation.*;

import java.util.Map;

/**
 * 薪资发放Controller
 *
 * @author HR DataCenter Team
 * @since 2024-01-20
 */
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;

@RestController
@RequestMapping("/salary/payment")
@CrossOrigin(origins = "*")
public class SalaryPaymentController {

    private static final Logger log = LoggerFactory.getLogger(SalaryPaymentController.class);

    @Autowired
    private SalaryPaymentService salaryPaymentService;

    /**
     * 分页查询薪资发放
     */
    @GetMapping("/page")
    public Result<IPage<SalaryPayment>> getPaymentPage(
            @RequestParam(defaultValue = "1") int page,
            @RequestParam(defaultValue = "10") int size,
            @RequestParam(required = false) Long empId,
            @RequestParam(required = false) Integer year,
            @RequestParam(required = false) Integer month) {
        try {
            IPage<SalaryPayment> result = salaryPaymentService.getPaymentPage(page, size, empId, year, month);
            return Result.success("查询成功", result);
        } catch (Exception e) {
            log.error("查询薪资发放失败: {}", e.getMessage());
            return Result.error("查询薪资发放失败");
        }
    }

    /**
     * 新增薪资发放
     */
    @PostMapping("/add")
    public Result<String> addPayment(@RequestBody SalaryPayment payment) {
        try {
            boolean success = salaryPaymentService.addPayment(payment);
            if (success) {
                return Result.success("添加成功", "");
            }
            return Result.error("添加失败");
        } catch (Exception e) {
            log.error("添加薪资发放失败: {}", e.getMessage());
            return Result.error("添加薪资发放失败");
        }
    }

    /**
     * 更新薪资发放
     */
    @PostMapping("/update")
    public Result<String> updatePayment(@RequestBody SalaryPayment payment) {
        try {
            boolean success = salaryPaymentService.updatePayment(payment);
            if (success) {
                return Result.success("更新成功", "");
            }
            return Result.error("更新失败");
        } catch (Exception e) {
            log.error("更新薪资发放失败: {}", e.getMessage());
            return Result.error("更新薪资发放失败");
        }
    }

    /**
     * 发放薪资
     */
    @PostMapping("/release/{paymentId}")
    public Result<String> releasePayment(@PathVariable Long paymentId) {
        try {
            boolean success = salaryPaymentService.releasePayment(paymentId);
            if (success) {
                return Result.success("发放成功", "");
            }
            return Result.error("发放失败");
        } catch (Exception e) {
            log.error("发放薪资失败: {}", e.getMessage());
            return Result.error("发放薪资失败");
        }
    }

    /**
     * 获取员工薪资统计
     */
    @GetMapping("/statistics")
    public Result<Map<String, Object>> getSalaryStatistics(
            @RequestParam Long empId,
            @RequestParam(required = false) Integer year) {
        try {
            Map<String, Object> result = salaryPaymentService.getSalaryStatistics(empId, year);
            return Result.success("查询成功", result);
        } catch (Exception e) {
            log.error("查询薪资统计失败: {}", e.getMessage());
            return Result.error("查询薪资统计失败");
        }
    }
}
