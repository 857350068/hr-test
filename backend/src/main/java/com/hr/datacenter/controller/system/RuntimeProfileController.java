package com.hr.datacenter.controller.system;

import com.hr.datacenter.common.Result;
import org.springframework.core.env.Environment;
import org.springframework.security.access.prepost.PreAuthorize;
import org.springframework.web.bind.annotation.CrossOrigin;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RestController;

import java.util.LinkedHashMap;
import java.util.Map;

@RestController
@RequestMapping("/system/runtime")
@CrossOrigin(origins = "*")
public class RuntimeProfileController {

    private final Environment environment;

    public RuntimeProfileController(Environment environment) {
        this.environment = environment;
    }

    @GetMapping("/profile")
    @PreAuthorize("hasAnyAuthority('ROLE_ADMIN','ROLE_HR_ADMIN')")
    public Result<Map<String, Object>> profile() {
        String modeName = environment.getProperty("project.runtime.mode-name", "标准模式");
        String modeDesc = environment.getProperty("project.runtime.mode-desc", "未配置");
        String hiveDriver = environment.getProperty("spring.datasource.hive.driver-class-name", "");
        String activeProfiles = String.join(",", environment.getActiveProfiles());
        boolean dataSyncEnabled = Boolean.parseBoolean(environment.getProperty("data-sync.enabled", "false"));
        boolean realHive = hiveDriver.contains("hive");

        Map<String, Object> data = new LinkedHashMap<>();
        data.put("modeName", modeName);
        data.put("modeDesc", modeDesc);
        data.put("activeProfiles", activeProfiles.isEmpty() ? "default" : activeProfiles);
        data.put("dataSourceMode", realHive ? "真实Hive" : "兼容模式");
        data.put("dataSyncEnabled", dataSyncEnabled);
        return Result.success(data);
    }
}
