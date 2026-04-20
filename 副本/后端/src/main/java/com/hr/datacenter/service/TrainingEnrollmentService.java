package com.hr.datacenter.service;

import com.baomidou.mybatisplus.core.conditions.query.LambdaQueryWrapper;
import com.baomidou.mybatisplus.core.metadata.IPage;
import com.baomidou.mybatisplus.extension.plugins.pagination.Page;
import com.baomidou.mybatisplus.extension.service.impl.ServiceImpl;
import com.hr.datacenter.entity.TrainingEnrollment;
import com.hr.datacenter.mapper.mysql.TrainingEnrollmentMapper;
import lombok.extern.slf4j.Slf4j;
import org.springframework.stereotype.Service;

import java.util.HashMap;
import java.util.Map;

/**
 * 培训报名Service
 *
 * @author HR DataCenter Team
 * @since 2024-01-20
 */
@Slf4j
@Service
public class TrainingEnrollmentService extends ServiceImpl<TrainingEnrollmentMapper, TrainingEnrollment> {

    /**
     * 分页查询培训报名
     */
    public IPage<TrainingEnrollment> getEnrollmentPage(int page, int size, Long courseId, Long empId, Integer approvalStatus) {
        Page<TrainingEnrollment> pageParam = new Page<>(page, size);
        LambdaQueryWrapper<TrainingEnrollment> wrapper = new LambdaQueryWrapper<>();
        
        if (courseId != null) {
            wrapper.eq(TrainingEnrollment::getCourseId, courseId);
        }
        if (empId != null) {
            wrapper.eq(TrainingEnrollment::getEmpId, empId);
        }
        if (approvalStatus != null) {
            wrapper.eq(TrainingEnrollment::getApprovalStatus, approvalStatus);
        }
        
        wrapper.orderByDesc(TrainingEnrollment::getEnrollmentTime);
        return this.page(pageParam, wrapper);
    }

    /**
     * 报名培训
     */
    public boolean enrollTraining(TrainingEnrollment enrollment) {
        enrollment.setApprovalStatus(0); // 0-待审核
        enrollment.setEnrollmentTime(java.time.LocalDateTime.now());
        return this.save(enrollment);
    }

    /**
     * 审核培训报名
     */
    public boolean approveEnrollment(Long enrollmentId, Long approverId, Integer approvalStatus, String approvalComment) {
        TrainingEnrollment enrollment = this.getById(enrollmentId);
        if (enrollment == null) {
            throw new RuntimeException("报名记录不存在");
        }
        
        if (enrollment.getApprovalStatus() != 0) {
            throw new RuntimeException("该报名记录已审核");
        }

        enrollment.setApprovalStatus(approvalStatus);

        return this.updateById(enrollment);
    }

    /**
     * 培训签到
     */
    public boolean checkIn(Long enrollmentId) {
        TrainingEnrollment enrollment = this.getById(enrollmentId);
        if (enrollment == null) {
            throw new RuntimeException("报名记录不存在");
        }
        
        enrollment.setAttendanceStatus(1); // 1-已出勤
        return this.updateById(enrollment);
    }

    /**
     * 提交培训成绩
     */
    public boolean submitScore(Long enrollmentId, Integer score, String feedback) {
        TrainingEnrollment enrollment = this.getById(enrollmentId);
        if (enrollment == null) {
            throw new RuntimeException("报名记录不存在");
        }
        
        enrollment.setScore(score);
        enrollment.setFeedback(feedback);
        return this.updateById(enrollment);
    }

    public Map<String, Object> getTrainingEffectOverview() {
        Map<String, Object> result = new HashMap<>();
        long total = this.count();
        long approved = this.count(new LambdaQueryWrapper<TrainingEnrollment>()
                .eq(TrainingEnrollment::getApprovalStatus, 1));
        long attended = this.count(new LambdaQueryWrapper<TrainingEnrollment>()
                .eq(TrainingEnrollment::getAttendanceStatus, 1));
        long scored = this.count(new LambdaQueryWrapper<TrainingEnrollment>()
                .isNotNull(TrainingEnrollment::getScore));
        Double avgScore = this.baseMapper.selectObjs(new LambdaQueryWrapper<TrainingEnrollment>()
                        .select(TrainingEnrollment::getScore)
                        .isNotNull(TrainingEnrollment::getScore))
                .stream()
                .mapToDouble(item -> item == null ? 0D : Double.parseDouble(String.valueOf(item)))
                .average()
                .orElse(0D);
        long feedbackCount = this.count(new LambdaQueryWrapper<TrainingEnrollment>()
                .isNotNull(TrainingEnrollment::getFeedback));

        result.put("totalEnrollments", total);
        result.put("approvedCount", approved);
        result.put("attendedCount", attended);
        result.put("attendanceRate", approved == 0 ? 0D : Math.round(attended * 10000.0 / approved) / 100.0);
        result.put("scoredCount", scored);
        result.put("avgScore", Math.round(avgScore * 100.0) / 100.0);
        result.put("feedbackCount", feedbackCount);
        return result;
    }
}
