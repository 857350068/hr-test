package com.hr.backend.controller;

import com.hr.backend.common.Response;
import com.hr.backend.model.entity.WarningRule;
import com.hr.backend.service.WarningRuleService;
import org.springframework.web.bind.annotation.*;

import javax.annotation.Resource;
import java.util.List;

@RestController
@RequestMapping("/api/rule")
public class RuleController {

    @Resource
    private WarningRuleService warningRuleService;

    @GetMapping("/list")
    public Response<List<WarningRule>> list() {
        return Response.success(warningRuleService.list());
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
