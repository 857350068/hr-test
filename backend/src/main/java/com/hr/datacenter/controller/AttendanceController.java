package com.hr.datacenter.controller;

import com.baomidou.mybatisplus.core.metadata.IPage;
import com.hr.datacenter.common.Result;
import com.hr.datacenter.entity.Attendance;
import com.hr.datacenter.service.AttendanceService;
import lombok.extern.slf4j.Slf4j;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.web.bind.annotation.*;

import java.time.LocalDate;
import java.util.Map;

/**
 * 考勤控制器
 *
 * @author HR DataCenter Team
 * @since 2024-01-20
 */
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;

@RestController
@RequestMapping("/attendance")
@CrossOrigin(origins = "*")
public class AttendanceController {

    private static final Logger log = LoggerFactory.getLogger(AttendanceController.class);

    @Autowired
    private AttendanceService attendanceService;

    /**
     * 上班打卡
     */
    @PostMapping("/clockIn")
    public Result<String> clockIn(@RequestParam Long empId) {
        log.info("上班打卡: empId={}", empId);
        try {
            attendanceService.clockIn(empId);
            return Result.success("打卡成功", "");
        } catch (Exception e) {
            log.error("打卡失败: {}", e.getMessage());
            return Result.error(e.getMessage());
        }
    }

    /**
     * 下班打卡
     */
    @PostMapping("/clockOut")
    public Result<String> clockOut(@RequestParam Long empId) {
        log.info("下班打卡: empId={}", empId);
        try {
            attendanceService.clockOut(empId);
            return Result.success("打卡成功", "");
        } catch (Exception e) {
            log.error("打卡失败: {}", e.getMessage());
            return Result.error(e.getMessage());
        }
    }

    /**
     * 获取今日考勤记录
     */
    @GetMapping("/today")
    public Result<Attendance> getTodayAttendance(@RequestParam Long empId) {
        log.info("查询今日考勤: empId={}", empId);
        Attendance attendance = attendanceService.getTodayAttendance(empId);
        return Result.success(attendance);
    }

    /**
     * 分页查询考勤记录
     */
    @GetMapping("/list")
    public Result<IPage<Attendance>> getAttendanceList(
            @RequestParam(defaultValue = "1") int page,
            @RequestParam(defaultValue = "10") int size,
            @RequestParam(required = false) Long empId,
            @RequestParam(required = false) LocalDate startDate,
            @RequestParam(required = false) LocalDate endDate) {
        log.info("查询考勤列表: page={}, size={}, empId={}", page, size, empId);
        IPage<Attendance> attendancePage = attendanceService.getAttendancePage(page, size, empId, startDate, endDate);
        return Result.success(attendancePage);
    }

    /**
     * 获取考勤统计
     */
    @GetMapping("/stats")
    public Result<Map<String, Object>> getAttendanceStats(
            @RequestParam(required = false) LocalDate startDate,
            @RequestParam(required = false) LocalDate endDate) {
        log.info("查询考勤统计: startDate={}, endDate={}", startDate, endDate);
        Map<String, Object> stats = attendanceService.getAttendanceStats(startDate, endDate);
        return Result.success(stats);
    }
}
