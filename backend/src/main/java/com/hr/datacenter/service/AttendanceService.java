package com.hr.datacenter.service;

import com.baomidou.mybatisplus.core.conditions.query.LambdaQueryWrapper;
import com.baomidou.mybatisplus.core.metadata.IPage;
import com.baomidou.mybatisplus.extension.plugins.pagination.Page;
import com.baomidou.mybatisplus.extension.service.impl.ServiceImpl;
import com.hr.datacenter.entity.Attendance;
import com.hr.datacenter.entity.Employee;
import com.hr.datacenter.mapper.mysql.AttendanceMapper;
import com.hr.datacenter.mapper.mysql.EmployeeMapper;
import lombok.extern.slf4j.Slf4j;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;

import java.time.LocalDate;
import java.time.LocalDateTime;
import java.time.LocalTime;
import java.time.temporal.ChronoUnit;

/**
 * 考勤Service
 *
 * @author HR DataCenter Team
 * @since 2024-01-20
 */
@Slf4j
@Service
public class AttendanceService extends ServiceImpl<AttendanceMapper, Attendance> {

    @Autowired
    private EmployeeMapper employeeMapper;

    /**
     * 上班打卡
     */
    public boolean clockIn(Long empId) {
        LocalDate today = LocalDate.now();
        LocalTime now = LocalTime.now();
        
        // 查询今天是否已经打卡
        LambdaQueryWrapper<Attendance> wrapper = new LambdaQueryWrapper<>();
        wrapper.eq(Attendance::getEmpId, empId)
               .eq(Attendance::getAttendanceDate, today);
        Attendance attendance = this.getOne(wrapper);
        
        if (attendance != null && attendance.getClockInTime() != null) {
            throw new RuntimeException("今天已经上班打卡了");
        }
        
        // 判断是否迟到(假设上班时间是9:00)
        LocalTime workStartTime = LocalTime.of(9, 0);
        int attendanceType = now.isAfter(workStartTime) ? 1 : 0; // 1-迟到 0-正常
        
        if (attendance == null) {
            // 创建新记录
            attendance = new Attendance();
            attendance.setEmpId(empId);
            attendance.setAttendanceDate(today);
            attendance.setClockInTime(now);
            attendance.setAttendanceType(attendanceType);
            attendance.setAttendanceStatus(1);
            return this.save(attendance);
        } else {
            // 更新记录
            attendance.setClockInTime(now);
            attendance.setAttendanceType(attendanceType);
            attendance.setAttendanceStatus(1);
            return this.updateById(attendance);
        }
    }

    /**
     * 下班打卡
     */
    public boolean clockOut(Long empId) {
        LocalDate today = LocalDate.now();
        LocalTime now = LocalTime.now();
        
        // 查询今天的考勤记录
        LambdaQueryWrapper<Attendance> wrapper = new LambdaQueryWrapper<>();
        wrapper.eq(Attendance::getEmpId, empId)
               .eq(Attendance::getAttendanceDate, today);
        Attendance attendance = this.getOne(wrapper);
        
        if (attendance == null) {
            throw new RuntimeException("请先进行上班打卡");
        }
        
        if (attendance.getClockOutTime() != null) {
            throw new RuntimeException("今天已经下班打卡了");
        }
        
        // 判断是否早退(假设下班时间是18:00)
        LocalTime workEndTime = LocalTime.of(18, 0);
        int attendanceType = now.isBefore(workEndTime) ? 2 : 0; // 2-早退 0-正常
        
        // 计算工作时长
        if (attendance.getClockInTime() != null) {
            long minutes = ChronoUnit.MINUTES.between(attendance.getClockInTime(), now);
            attendance.setWorkDuration((int) minutes);
        }
        
        attendance.setClockOutTime(now);
        attendance.setAttendanceType(attendanceType);
        return this.updateById(attendance);
    }

    /**
     * 获取今日考勤记录
     */
    public Attendance getTodayAttendance(Long empId) {
        LocalDate today = LocalDate.now();
        LambdaQueryWrapper<Attendance> wrapper = new LambdaQueryWrapper<>();
        wrapper.eq(Attendance::getEmpId, empId)
               .eq(Attendance::getAttendanceDate, today);
        return this.getOne(wrapper);
    }

    /**
     * 分页查询考勤记录
     */
    public IPage<Attendance> getAttendancePage(int page, int size, Long empId, LocalDate startDate, LocalDate endDate) {
        Page<Attendance> pageParam = new Page<>(page, size);
        LambdaQueryWrapper<Attendance> wrapper = new LambdaQueryWrapper<>();
        
        if (empId != null) {
            wrapper.eq(Attendance::getEmpId, empId);
        }
        if (startDate != null) {
            wrapper.ge(Attendance::getAttendanceDate, startDate);
        }
        if (endDate != null) {
            wrapper.le(Attendance::getAttendanceDate, endDate);
        }
        
        wrapper.orderByDesc(Attendance::getAttendanceDate);
        return this.page(pageParam, wrapper);
    }

    /**
     * 获取考勤统计
     */
    public java.util.Map<String, Object> getAttendanceStats(LocalDate startDate, LocalDate endDate) {
        java.util.Map<String, Object> stats = new java.util.HashMap<>();
        
        LambdaQueryWrapper<Attendance> wrapper = new LambdaQueryWrapper<>();
        if (startDate != null) {
            wrapper.ge(Attendance::getAttendanceDate, startDate);
        }
        if (endDate != null) {
            wrapper.le(Attendance::getAttendanceDate, endDate);
        }
        
        long totalCount = this.count(wrapper);
        
        LambdaQueryWrapper<Attendance> lateWrapper = wrapper.clone();
        lateWrapper.eq(Attendance::getAttendanceType, 1);
        long lateCount = this.count(lateWrapper);
        
        LambdaQueryWrapper<Attendance> earlyLeaveWrapper = wrapper.clone();
        earlyLeaveWrapper.eq(Attendance::getAttendanceType, 2);
        long earlyLeaveCount = this.count(earlyLeaveWrapper);
        
        stats.put("totalCount", totalCount);
        stats.put("lateCount", lateCount);
        stats.put("earlyLeaveCount", earlyLeaveCount);
        stats.put("normalCount", totalCount - lateCount - earlyLeaveCount);
        
        return stats;
    }
}
