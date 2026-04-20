package com.hr.datacenter.service;

import com.baomidou.mybatisplus.core.conditions.query.LambdaQueryWrapper;
import com.baomidou.mybatisplus.core.metadata.IPage;
import com.baomidou.mybatisplus.extension.plugins.pagination.Page;
import com.baomidou.mybatisplus.extension.service.impl.ServiceImpl;
import com.hr.datacenter.entity.SalaryPayment;
import com.hr.datacenter.mapper.mysql.SalaryPaymentMapper;
import lombok.extern.slf4j.Slf4j;
import org.springframework.stereotype.Service;

import java.math.BigDecimal;

/**
 * 薪资发放Service
 *
 * @author HR DataCenter Team
 * @since 2024-01-20
 */
@Slf4j
@Service
public class SalaryPaymentService extends ServiceImpl<SalaryPaymentMapper, SalaryPayment> {

    /**
     * 分页查询薪资发放
     */
    public IPage<SalaryPayment> getPaymentPage(int page, int size, Long empId, Integer year, Integer month) {
        Page<SalaryPayment> pageParam = new Page<>(page, size);
        LambdaQueryWrapper<SalaryPayment> wrapper = new LambdaQueryWrapper<>();
        
        if (empId != null) {
            wrapper.eq(SalaryPayment::getEmpId, empId);
        }
        if (year != null) {
            wrapper.eq(SalaryPayment::getYear, year);
        }
        if (month != null) {
            wrapper.eq(SalaryPayment::getMonth, month);
        }
        
        wrapper.orderByDesc(SalaryPayment::getYear)
               .orderByDesc(SalaryPayment::getMonth);
        return this.page(pageParam, wrapper);
    }

    /**
     * 计算薪资
     */
    public SalaryPayment calculateSalary(SalaryPayment payment) {
        // 计算应发工资总额
        BigDecimal totalGross = BigDecimal.ZERO;
        if (payment.getBasicSalary() != null) {
            totalGross = totalGross.add(payment.getBasicSalary());
        }
        if (payment.getPerformanceSalary() != null) {
            totalGross = totalGross.add(payment.getPerformanceSalary());
        }
        if (payment.getPositionAllowance() != null) {
            totalGross = totalGross.add(payment.getPositionAllowance());
        }
        if (payment.getTransportAllowance() != null) {
            totalGross = totalGross.add(payment.getTransportAllowance());
        }
        if (payment.getCommunicationAllowance() != null) {
            totalGross = totalGross.add(payment.getCommunicationAllowance());
        }
        if (payment.getMealAllowance() != null) {
            totalGross = totalGross.add(payment.getMealAllowance());
        }
        if (payment.getOvertimePay() != null) {
            totalGross = totalGross.add(payment.getOvertimePay());
        }
        payment.setTotalGrossSalary(totalGross);

        // 计算实发工资总额
        BigDecimal totalNet = totalGross;
        if (payment.getSocialInsurance() != null) {
            totalNet = totalNet.subtract(payment.getSocialInsurance());
        }
        if (payment.getHousingFund() != null) {
            totalNet = totalNet.subtract(payment.getHousingFund());
        }
        if (payment.getIncomeTax() != null) {
            totalNet = totalNet.subtract(payment.getIncomeTax());
        }
        if (payment.getOtherDeduction() != null) {
            totalNet = totalNet.subtract(payment.getOtherDeduction());
        }
        payment.setTotalNetSalary(totalNet);

        return payment;
    }

    /**
     * 新增薪资发放
     */
    public boolean addPayment(SalaryPayment payment) {
        payment = calculateSalary(payment);
        return this.save(payment);
    }

    /**
     * 更新薪资发放
     */
    public boolean updatePayment(SalaryPayment payment) {
        payment = calculateSalary(payment);
        return this.updateById(payment);
    }

    /**
     * 发放薪资
     */
    public boolean releasePayment(Long paymentId) {
        SalaryPayment payment = this.getById(paymentId);
        if (payment == null) {
            throw new RuntimeException("薪资记录不存在");
        }
        payment.setPaymentStatus(1); // 1-已发放
        payment.setPaymentDate(java.time.LocalDateTime.now());
        return this.updateById(payment);
    }

    /**
     * 获取员工薪资统计
     */
    public java.util.Map<String, Object> getSalaryStatistics(Long empId, Integer year) {
        LambdaQueryWrapper<SalaryPayment> wrapper = new LambdaQueryWrapper<>();
        wrapper.eq(SalaryPayment::getEmpId, empId);
        if (year != null) {
            wrapper.eq(SalaryPayment::getYear, year);
        }
        
        java.util.List<SalaryPayment> list = this.list(wrapper);
        
        BigDecimal totalGross = BigDecimal.ZERO;
        BigDecimal totalNet = BigDecimal.ZERO;
        int paidCount = 0;
        
        for (SalaryPayment payment : list) {
            if (payment.getTotalGrossSalary() != null) {
                totalGross = totalGross.add(payment.getTotalGrossSalary());
            }
            if (payment.getTotalNetSalary() != null) {
                totalNet = totalNet.add(payment.getTotalNetSalary());
            }
            if (payment.getPaymentStatus() != null && payment.getPaymentStatus() == 1) {
                paidCount++;
            }
        }
        
        java.util.Map<String, Object> result = new java.util.HashMap<>();
        result.put("totalGross", totalGross);
        result.put("totalNet", totalNet);
        result.put("paidCount", paidCount);
        result.put("totalCount", list.size());
        
        return result;
    }
}
