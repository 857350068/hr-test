package com.hr.datacenter.entity;

import com.baomidou.mybatisplus.annotation.*;
import lombok.Data;

import java.io.Serializable;
import java.math.BigDecimal;
import java.time.LocalDateTime;

/**
 * 薪资发放实体类
 *
 * @author HR DataCenter Team
 * @since 2024-01-20
 */
@Data
@TableName("salary_payment")
public class SalaryPayment implements Serializable {

    private static final long serialVersionUID = 1L;

    /**
     * 发放ID
     */
    @TableId(value = "payment_id", type = IdType.AUTO)
    private Long paymentId;

    /**
     * 员工ID
     */
    private Long empId;

    /**
     * 发放年度
     */
    private Integer year;

    /**
     * 发放月份
     */
    private Integer month;

    /**
     * 基本工资
     */
    private BigDecimal basicSalary;

    /**
     * 绩效工资
     */
    private BigDecimal performanceSalary;

    /**
     * 岗位津贴
     */
    private BigDecimal positionAllowance;

    /**
     * 交通补贴
     */
    private BigDecimal transportAllowance;

    /**
     * 通讯补贴
     */
    private BigDecimal communicationAllowance;

    /**
     * 餐补
     */
    private BigDecimal mealAllowance;

    /**
     * 其他补贴
     */
    private BigDecimal otherAllowance;

    /**
     * 加班费
     */
    private BigDecimal overtimePay;

    /**
     * 应发工资总额
     */
    private BigDecimal totalGrossSalary;

    /**
     * 社保个人部分
     */
    private BigDecimal socialInsurancePersonal;

    /**
     * 公积金个人部分
     */
    private BigDecimal housingFundPersonal;

    /**
     * 个人所得税
     */
    private BigDecimal incomeTax;

    /**
     * 其他扣款
     */
    private BigDecimal otherDeduction;

    /**
     * 实发工资总额
     */
    private BigDecimal totalNetSalary;

    /**
     * 发放状态(0-未发放 1-已发放)
     */
    private Integer paymentStatus;

    /**
     * 发放时间
     */
    private LocalDateTime paymentDate;

    /**
     * 备注
     */
    private String remark;

    /**
     * 创建时间
     */
    @TableField(fill = FieldFill.INSERT)
    private LocalDateTime createTime;

    /**
     * 更新时间
     */
    @TableField(fill = FieldFill.INSERT_UPDATE)
    private LocalDateTime updateTime;

    /**
     * 删除标记
     */
    @TableLogic
    private Integer deleted;

    // Getter and Setter methods
    public Long getPaymentId() {
        return paymentId;
    }

    public void setPaymentId(Long paymentId) {
        this.paymentId = paymentId;
    }

    public Long getEmpId() {
        return empId;
    }

    public void setEmpId(Long empId) {
        this.empId = empId;
    }

    public Integer getYear() {
        return year;
    }

    public void setYear(Integer year) {
        this.year = year;
    }

    public Integer getMonth() {
        return month;
    }

    public void setMonth(Integer month) {
        this.month = month;
    }

    public BigDecimal getBasicSalary() {
        return basicSalary;
    }

    public void setBasicSalary(BigDecimal basicSalary) {
        this.basicSalary = basicSalary;
    }

    public BigDecimal getPerformanceSalary() {
        return performanceSalary;
    }

    public void setPerformanceSalary(BigDecimal performanceSalary) {
        this.performanceSalary = performanceSalary;
    }

    public BigDecimal getPositionAllowance() {
        return positionAllowance;
    }

    public void setPositionAllowance(BigDecimal positionAllowance) {
        this.positionAllowance = positionAllowance;
    }

    public BigDecimal getTransportAllowance() {
        return transportAllowance;
    }

    public void setTransportAllowance(BigDecimal transportAllowance) {
        this.transportAllowance = transportAllowance;
    }

    public BigDecimal getCommunicationAllowance() {
        return communicationAllowance;
    }

    public void setCommunicationAllowance(BigDecimal communicationAllowance) {
        this.communicationAllowance = communicationAllowance;
    }

    public BigDecimal getMealAllowance() {
        return mealAllowance;
    }

    public void setMealAllowance(BigDecimal mealAllowance) {
        this.mealAllowance = mealAllowance;
    }

    public BigDecimal getOtherAllowance() {
        return otherAllowance;
    }

    public void setOtherAllowance(BigDecimal otherAllowance) {
        this.otherAllowance = otherAllowance;
    }

    public BigDecimal getOvertimePay() {
        return overtimePay;
    }

    public void setOvertimePay(BigDecimal overtimePay) {
        this.overtimePay = overtimePay;
    }

    public BigDecimal getTotalGrossSalary() {
        return totalGrossSalary;
    }

    public void setTotalGrossSalary(BigDecimal totalGrossSalary) {
        this.totalGrossSalary = totalGrossSalary;
    }

    public BigDecimal getSocialInsurancePersonal() {
        return socialInsurancePersonal;
    }

    public void setSocialInsurancePersonal(BigDecimal socialInsurancePersonal) {
        this.socialInsurancePersonal = socialInsurancePersonal;
    }

    public BigDecimal getHousingFundPersonal() {
        return housingFundPersonal;
    }

    public void setHousingFundPersonal(BigDecimal housingFundPersonal) {
        this.housingFundPersonal = housingFundPersonal;
    }

    public BigDecimal getIncomeTax() {
        return incomeTax;
    }

    public void setIncomeTax(BigDecimal incomeTax) {
        this.incomeTax = incomeTax;
    }

    public BigDecimal getOtherDeduction() {
        return otherDeduction;
    }

    public void setOtherDeduction(BigDecimal otherDeduction) {
        this.otherDeduction = otherDeduction;
    }

    public BigDecimal getTotalNetSalary() {
        return totalNetSalary;
    }

    public void setTotalNetSalary(BigDecimal totalNetSalary) {
        this.totalNetSalary = totalNetSalary;
    }

    public Integer getPaymentStatus() {
        return paymentStatus;
    }

    public void setPaymentStatus(Integer paymentStatus) {
        this.paymentStatus = paymentStatus;
    }

    public LocalDateTime getPaymentDate() {
        return paymentDate;
    }

    public void setPaymentDate(LocalDateTime paymentDate) {
        this.paymentDate = paymentDate;
    }

    public String getRemark() {
        return remark;
    }

    public void setRemark(String remark) {
        this.remark = remark;
    }

    public LocalDateTime getCreateTime() {
        return createTime;
    }

    public void setCreateTime(LocalDateTime createTime) {
        this.createTime = createTime;
    }

    public LocalDateTime getUpdateTime() {
        return updateTime;
    }

    public void setUpdateTime(LocalDateTime updateTime) {
        this.updateTime = updateTime;
    }

    public Integer getDeleted() {
        return deleted;
    }

    public void setDeleted(Integer deleted) {
        this.deleted = deleted;
    }
}
