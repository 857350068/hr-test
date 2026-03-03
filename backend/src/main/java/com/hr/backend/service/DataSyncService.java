package com.hr.backend.service;

import com.hr.backend.model.entity.DataSyncLog;

import java.util.List;
import java.util.Map;

public interface DataSyncService {

    Map<String, Object> triggerSync();

    List<DataSyncLog> listRecent(int limit);
}
