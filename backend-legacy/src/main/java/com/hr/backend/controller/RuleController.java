package com.hr.backend.controller;

import com.baomidou.mybatisplus.core.metadata.IPage;
import com.baomidou.mybatisplus.extension.plugins.pagination.Page;
import com.hr.backend.common.Response;
import com.hr.backend.model.entity.WarningRule;
import com.hr.backend.service.WarningRuleService;
import org.springframework.security.access.prepost.PreAuthorize;
import org.springframework.web.bind.annotation.*;

import javax.annotation.Resource;
import java.util.List;

@RestController
@RequestMapping("/api/rule")
@PreAuthorize("hasRole('HR_ADMIN')")
public class RuleController {

    @Resource
    private WarningRuleService warningRuleService;

    @GetMapping("/list")
    public Response<List<WarningRule>> list() {
        return Response.success(warningRuleService.list());
    }

    /**
     * 分页查询预警规则列表
     * @param current 当前页码，默认1
     * @param size 每页条数，默认10
     * @param ruleType 规则类型（可选，支持精确查询）
     * @param isActive 生效状态（可选，支持精确查询）
     * @return 分页结果
     */
    @GetMapping("/page")
    public Response<IPage<WarningRule>> page(
            @RequestParam(defaultValue = "1") Long current,
            @RequestParam(defaultValue = "10") Long size,
            @RequestParam(required = false) String ruleType,
            @RequestParam(required = false) Boolean isActive) {
        Page<WarningRule> page = new Page<>(current, size);
        IPage<WarningRule> result = warningRuleService.page(page, ruleType, isActive);
        return Response.success(result);
    }

    @GetMapping("/{id}")
    public Response<WarningRule> getById(@PathVariable Long id) {
        return Response.success(warningRuleService.getById(id));
    }

    @PostMapping
    public Response<Void> add(@RequestBody WarningRule rule) {
        warningRuleService.save(rule);
        return Response.success();
    }

    @PutMapping("/{id}")
    public Response<Void> update(@PathVariable Long id, @RequestBody WarningRule rule) {
        rule.setId(id);
        warningRuleService.updateById(rule);
        return Response.success();
    }

    @DeleteMapping("/{id}")
    public Response<Void> delete(@PathVariable Long id) {
        warningRuleService.removeById(id);
        return Response.success();
    }
}
