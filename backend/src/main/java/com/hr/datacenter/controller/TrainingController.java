package com.hr.datacenter.controller;

import com.baomidou.mybatisplus.core.metadata.IPage;
import com.hr.datacenter.common.Result;
import com.hr.datacenter.entity.TrainingCourse;
import com.hr.datacenter.entity.TrainingEnrollment;
import com.hr.datacenter.service.TrainingCourseService;
import com.hr.datacenter.service.TrainingEnrollmentService;
import lombok.extern.slf4j.Slf4j;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.web.bind.annotation.*;

/**
 * 培训管理Controller
 *
 * @author HR DataCenter Team
 * @since 2024-01-20
 */
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;

@RestController
@RequestMapping("/training")
@CrossOrigin(origins = "*")
public class TrainingController {

    private static final Logger log = LoggerFactory.getLogger(TrainingController.class);

    @Autowired
    private TrainingCourseService trainingCourseService;

    @Autowired
    private TrainingEnrollmentService trainingEnrollmentService;

    /**
     * 分页查询培训课程
     */
    @GetMapping("/course/page")
    public Result<IPage<TrainingCourse>> getCoursePage(
            @RequestParam(defaultValue = "1") int page,
            @RequestParam(defaultValue = "10") int size,
            @RequestParam(required = false) String courseName,
            @RequestParam(required = false) Integer courseType,
            @RequestParam(required = false) Integer courseStatus) {
        try {
            IPage<TrainingCourse> result = trainingCourseService.getCoursePage(page, size, courseName, courseType, courseStatus);
            return Result.success("查询成功", result);
        } catch (Exception e) {
            log.error("查询培训课程失败: {}", e.getMessage());
            return Result.error("查询培训课程失败");
        }
    }

    /**
     * 新增培训课程
     */
    @PostMapping("/course/add")
    public Result<String> addCourse(@RequestBody TrainingCourse course) {
        try {
            boolean success = trainingCourseService.addCourse(course);
            if (success) {
                return Result.success("添加成功", "");
            }
            return Result.error("添加失败");
        } catch (Exception e) {
            log.error("添加培训课程失败: {}", e.getMessage());
            return Result.error("添加培训课程失败");
        }
    }

    /**
     * 更新培训课程
     */
    @PostMapping("/course/update")
    public Result<String> updateCourse(@RequestBody TrainingCourse course) {
        try {
            boolean success = trainingCourseService.updateCourse(course);
            if (success) {
                return Result.success("更新成功", "");
            }
            return Result.error("更新失败");
        } catch (Exception e) {
            log.error("更新培训课程失败: {}", e.getMessage());
            return Result.error("更新培训课程失败");
        }
    }

    /**
     * 删除培训课程
     */
    @PostMapping("/course/delete/{courseId}")
    public Result<String> deleteCourse(@PathVariable Long courseId) {
        try {
            boolean success = trainingCourseService.deleteCourse(courseId);
            if (success) {
                return Result.success("删除成功", "");
            }
            return Result.error("删除失败");
        } catch (Exception e) {
            log.error("删除培训课程失败: {}", e.getMessage());
            return Result.error("删除培训课程失败");
        }
    }

    /**
     * 分页查询培训报名
     */
    @GetMapping("/enrollment/page")
    public Result<IPage<TrainingEnrollment>> getEnrollmentPage(
            @RequestParam(defaultValue = "1") int page,
            @RequestParam(defaultValue = "10") int size,
            @RequestParam(required = false) Long courseId,
            @RequestParam(required = false) Long empId,
            @RequestParam(required = false) Integer approvalStatus) {
        try {
            IPage<TrainingEnrollment> result = trainingEnrollmentService.getEnrollmentPage(page, size, courseId, empId, approvalStatus);
            return Result.success("查询成功", result);
        } catch (Exception e) {
            log.error("查询培训报名失败: {}", e.getMessage());
            return Result.error("查询培训报名失败");
        }
    }

    /**
     * 报名培训
     */
    @PostMapping("/enrollment/enroll")
    public Result<String> enrollTraining(@RequestBody TrainingEnrollment enrollment) {
        try {
            boolean success = trainingEnrollmentService.enrollTraining(enrollment);
            if (success) {
                return Result.success("报名成功", "");
            }
            return Result.error("报名失败");
        } catch (Exception e) {
            log.error("报名培训失败: {}", e.getMessage());
            return Result.error("报名培训失败");
        }
    }

    /**
     * 审核培训报名
     */
    @PostMapping("/enrollment/approve")
    public Result<String> approveEnrollment(
            @RequestParam Long enrollmentId,
            @RequestParam Long approverId,
            @RequestParam Integer approvalStatus,
            @RequestParam(required = false) String approvalComment) {
        try {
            boolean success = trainingEnrollmentService.approveEnrollment(enrollmentId, approverId, approvalStatus, approvalComment);
            if (success) {
                return Result.success("审核成功", "");
            }
            return Result.error("审核失败");
        } catch (Exception e) {
            log.error("审核培训报名失败: {}", e.getMessage());
            return Result.error("审核培训报名失败");
        }
    }

    /**
     * 培训签到
     */
    @PostMapping("/enrollment/checkIn/{enrollmentId}")
    public Result<String> checkIn(@PathVariable Long enrollmentId) {
        try {
            boolean success = trainingEnrollmentService.checkIn(enrollmentId);
            if (success) {
                return Result.success("签到成功", "");
            }
            return Result.error("签到失败");
        } catch (Exception e) {
            log.error("培训签到失败: {}", e.getMessage());
            return Result.error("培训签到失败");
        }
    }

    /**
     * 提交培训成绩
     */
    @PostMapping("/enrollment/submitScore")
    public Result<String> submitScore(
            @RequestParam Long enrollmentId,
            @RequestParam Integer score,
            @RequestParam(required = false) String feedback) {
        try {
            boolean success = trainingEnrollmentService.submitScore(enrollmentId, score, feedback);
            if (success) {
                return Result.success("提交成功", "");
            }
            return Result.error("提交失败");
        } catch (Exception e) {
            log.error("提交培训成绩失败: {}", e.getMessage());
            return Result.error("提交培训成绩失败");
        }
    }
}
