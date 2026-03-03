package com.hr.backend.controller;

import com.hr.backend.common.Response;
import com.hr.backend.model.entity.ReportTemplate;
import com.hr.backend.service.ReportTemplateService;
import org.springframework.web.bind.annotation.*;

import javax.annotation.Resource;
import java.util.List;

@RestController
@RequestMapping("/api/report")
public class ReportController {

    @Resource
    private ReportTemplateService reportTemplateService;

    @GetMapping("/list")
    public Response<List<ReportTemplate>> list() {
        return Response.success(reportTemplateService.list());
    }

    @GetMapping("/{id}")
    public Response<ReportTemplate> getById(@PathVariable Long id) {
        return Response.success(reportTemplateService.getById(id));
    }

    @PostMapping
    public Response<Void> add(@RequestBody ReportTemplate template) {
        reportTemplateService.save(template);
        return Response.success();
    }

    @PutMapping("/{id}")
    public Response<Void> update(@PathVariable Long id, @RequestBody ReportTemplate template) {
        template.setId(id);
        reportTemplateService.updateById(template);
        return Response.success();
    }

    @DeleteMapping("/{id}")
    public Response<Void> delete(@PathVariable Long id) {
        reportTemplateService.removeById(id);
        return Response.success();
    }
}
