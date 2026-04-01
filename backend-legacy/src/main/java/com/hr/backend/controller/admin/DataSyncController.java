package com.hr.backend.controller.admin;

import com.hr.backend.common.Response;
import com.hr.backend.model.entity.DataSyncLog;
import com.hr.backend.service.DataSyncService;
import org.springframework.security.access.prepost.PreAuthorize;
import org.springframework.web.bind.annotation.*;

import javax.annotation.Resource;
import java.util.List;
import java.util.Map;

@RestController
@RequestMapping("/api/admin/sync")
@PreAuthorize("hasRole('HR_ADMIN')")
public class DataSyncController {

    @Resource
    private DataSyncService dataSyncService;

    @PostMapping("/trigger")
    public Response<Map<String, Object>> trigger() {
        return Response.success(dataSyncService.triggerSync());
    }

    @GetMapping("/logs")
    public Response<List<DataSyncLog>> logs(@RequestParam(defaultValue = "20") int limit) {
        return Response.success(dataSyncService.listRecent(limit));
    }
}
