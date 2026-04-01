package com.hr.backend.controller;

import com.hr.backend.common.Response;
import com.hr.backend.service.DashboardService;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RestController;

import javax.annotation.Resource;
import java.util.Map;

@RestController
@RequestMapping("/api/dashboard")
public class DashboardController {

    @Resource
    private DashboardService dashboardService;

    @GetMapping("/statistics")
    public Response<Map<String, Object>> statistics() {
        return Response.success(dashboardService.getStatistics());
    }

    @GetMapping("/warnings")
    public Response<Map<String, Object>> warnings() {
        return Response.success(dashboardService.getWarnings());
    }
}
