package com.hr.datacenter.controller;

import com.baomidou.mybatisplus.core.metadata.IPage;
import com.hr.datacenter.annotation.OperationLog;
import com.hr.datacenter.common.Result;
import com.hr.datacenter.entity.RecruitmentPlan;
import com.hr.datacenter.service.RecruitmentPlanService;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.security.access.prepost.PreAuthorize;
import org.springframework.web.bind.annotation.*;

@RestController
@RequestMapping("/recruitment")
@CrossOrigin(origins = "*")
public class RecruitmentController {

    @Autowired
    private RecruitmentPlanService recruitmentPlanService;

    @GetMapping("/list")
    @PreAuthorize("hasAnyAuthority('ROLE_ADMIN','ROLE_HR_ADMIN','ROLE_MANAGER')")
    public Result<IPage<RecruitmentPlan>> list(@RequestParam(defaultValue = "1") int page,
                                               @RequestParam(defaultValue = "10") int size,
                                               @RequestParam(required = false) String keyword,
                                               @RequestParam(required = false) Integer status) {
        return Result.success(recruitmentPlanService.getPage(page, size, keyword, status));
    }

    @PostMapping("/add")
    @OperationLog(module = "招聘管理", type = "新增", description = "新增招聘计划")
    @PreAuthorize("hasAnyAuthority('ROLE_ADMIN','ROLE_HR_ADMIN')")
    public Result<String> add(@RequestBody RecruitmentPlan plan) {
        plan.setRecruitId(null);
        if (plan.getStatus() == null) {
            plan.setStatus(0);
        }
        if (plan.getHiredCount() == null) {
            plan.setHiredCount(0);
        }
        recruitmentPlanService.save(plan);
        return Result.success("新增成功", "");
    }

    @PutMapping("/update")
    @OperationLog(module = "招聘管理", type = "更新", description = "更新招聘计划")
    @PreAuthorize("hasAnyAuthority('ROLE_ADMIN','ROLE_HR_ADMIN')")
    public Result<String> update(@RequestBody RecruitmentPlan plan) {
        recruitmentPlanService.updateById(plan);
        return Result.success("更新成功", "");
    }

    @DeleteMapping("/delete/{id}")
    @OperationLog(module = "招聘管理", type = "删除", description = "删除招聘计划")
    @PreAuthorize("hasAnyAuthority('ROLE_ADMIN','ROLE_HR_ADMIN')")
    public Result<String> delete(@PathVariable Long id) {
        recruitmentPlanService.removeById(id);
        return Result.success("删除成功", "");
    }
}
