package com.hr.backend.service;

import java.util.Map;

public interface DashboardService {

    Map<String, Object> getStatistics();

    Map<String, Object> getWarnings();
}
