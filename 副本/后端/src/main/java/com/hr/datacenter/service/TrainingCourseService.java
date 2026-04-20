package com.hr.datacenter.service;

import com.baomidou.mybatisplus.core.conditions.query.LambdaQueryWrapper;
import com.baomidou.mybatisplus.core.metadata.IPage;
import com.baomidou.mybatisplus.extension.plugins.pagination.Page;
import com.baomidou.mybatisplus.extension.service.impl.ServiceImpl;
import com.hr.datacenter.entity.TrainingCourse;
import com.hr.datacenter.mapper.mysql.TrainingCourseMapper;
import lombok.extern.slf4j.Slf4j;
import org.springframework.stereotype.Service;

/**
 * 培训课程Service
 *
 * @author HR DataCenter Team
 * @since 2024-01-20
 */
@Slf4j
@Service
public class TrainingCourseService extends ServiceImpl<TrainingCourseMapper, TrainingCourse> {

    /**
     * 分页查询培训课程
     */
    public IPage<TrainingCourse> getCoursePage(int page, int size, String courseName, Integer courseType, Integer courseStatus) {
        Page<TrainingCourse> pageParam = new Page<>(page, size);
        LambdaQueryWrapper<TrainingCourse> wrapper = new LambdaQueryWrapper<>();
        
        if (courseName != null && !courseName.isEmpty()) {
            wrapper.like(TrainingCourse::getCourseName, courseName);
        }
        if (courseType != null) {
            wrapper.eq(TrainingCourse::getCourseType, courseType);
        }
        if (courseStatus != null) {
            wrapper.eq(TrainingCourse::getCourseStatus, courseStatus);
        }
        
        wrapper.orderByDesc(TrainingCourse::getStartDate);
        return this.page(pageParam, wrapper);
    }

    /**
     * 新增培训课程
     */
    public boolean addCourse(TrainingCourse course) {
        course.setEnrolledCount(0);
        return this.save(course);
    }

    /**
     * 更新培训课程
     */
    public boolean updateCourse(TrainingCourse course) {
        return this.updateById(course);
    }

    /**
     * 删除培训课程
     */
    public boolean deleteCourse(Long courseId) {
        return this.removeById(courseId);
    }
}
