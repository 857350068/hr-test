package com.hr.datacenter.controller.system;

import com.baomidou.mybatisplus.core.conditions.query.LambdaQueryWrapper;
import com.hr.datacenter.common.Result;
import com.hr.datacenter.entity.AnalysisRule;
import com.hr.datacenter.service.AnalysisRuleService;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.security.access.prepost.PreAuthorize;
import org.springframework.web.bind.annotation.*;

import java.time.LocalDateTime;
import java.util.List;

@RestController
@RequestMapping("/system/rule")
@CrossOrigin(origins = "*")
public class RuleController {
    @Autowired
    private AnalysisRuleService ruleService;

    @GetMapping("/list")
    @PreAuthorize("hasAnyAuthority('ROLE_ADMIN','ROLE_HR_ADMIN')")
    public Result<List<AnalysisRule>> list(@RequestParam(required = false) String ruleType) {
        LambdaQueryWrapper<AnalysisRule> wrapper = new LambdaQueryWrapper<>();
        if (ruleType != null && !ruleType.isEmpty()) {
            wrapper.eq(AnalysisRule::getRuleType, ruleType);
        }
        wrapper.orderByDesc(AnalysisRule::getUpdateTime);
        return Result.success(ruleService.list(wrapper));
    }

    @PostMapping("/add")
    @PreAuthorize("hasAnyAuthority('ROLE_ADMIN','ROLE_HR_ADMIN')")
    public Result<String> add(@RequestBody AnalysisRule rule) {
        rule.setRuleId(null);
        rule.setCreateTime(LocalDateTime.now());
        rule.setUpdateTime(LocalDateTime.now());
        if (rule.getEffectStatus() == null) rule.setEffectStatus(0);
        ruleService.save(rule);
        return Result.success("新增成功", "");
    }

    @PutMapping("/update")
    @PreAuthorize("hasAnyAuthority('ROLE_ADMIN','ROLE_HR_ADMIN')")
    public Result<String> update(@RequestBody AnalysisRule rule) {
        AnalysisRule db = ruleService.getById(rule.getRuleId());
        if (db == null) return Result.error("规则不存在");
        if (db.getEffectStatus() != null && db.getEffectStatus() == 1) {
            return Result.error("已生效规则不可修改");
        }
        rule.setUpdateTime(LocalDateTime.now());
        ruleService.updateById(rule);
        return Result.success("更新成功", "");
    }

    @DeleteMapping("/delete/{id}")
    @PreAuthorize("hasAnyAuthority('ROLE_ADMIN','ROLE_HR_ADMIN')")
    public Result<String> delete(@PathVariable Long id) {
        AnalysisRule db = ruleService.getById(id);
        if (db == null) return Result.error("规则不存在");
        if (db.getEffectStatus() != null && db.getEffectStatus() == 1) {
            return Result.error("已生效规则不可删除");
        }
        ruleService.removeById(id);
        return Result.success("删除成功", "");
    }

    @PutMapping("/effect/{id}")
    @PreAuthorize("hasAnyAuthority('ROLE_ADMIN','ROLE_HR_ADMIN')")
    public Result<String> effect(@PathVariable Long id) {
        AnalysisRule db = ruleService.getById(id);
        if (db == null) return Result.error("规则不存在");
        db.setEffectStatus(1);
        db.setUpdateTime(LocalDateTime.now());
        db.setChangeLog("规则已生效：" + LocalDateTime.now());
        ruleService.updateById(db);
        return Result.success("规则生效成功", "");
    }
}
