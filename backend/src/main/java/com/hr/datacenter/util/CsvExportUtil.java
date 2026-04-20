package com.hr.datacenter.util;

import org.springframework.http.HttpHeaders;
import org.springframework.http.MediaType;
import org.springframework.http.ResponseEntity;

import java.net.URLEncoder;
import java.nio.charset.StandardCharsets;
import java.time.LocalDateTime;
import java.time.format.DateTimeFormatter;
import java.util.ArrayList;
import java.util.LinkedHashMap;
import java.util.List;
import java.util.Map;

public final class CsvExportUtil {

    private CsvExportUtil() {
    }

    public static String buildFileName(String prefix) {
        String ts = LocalDateTime.now().format(DateTimeFormatter.ofPattern("yyyyMMddHHmmss"));
        return prefix + "_" + ts + ".csv";
    }

    public static ResponseEntity<byte[]> buildCsvResponse(String filename, String csvContent) {
        return ResponseEntity.ok()
                .header(HttpHeaders.CONTENT_DISPOSITION, "attachment; filename*=UTF-8''" + urlEncode(filename))
                .contentType(MediaType.parseMediaType("text/csv;charset=UTF-8"))
                .body(("\uFEFF" + csvContent).getBytes(StandardCharsets.UTF_8));
    }

    public static String toCsv(List<Map<String, Object>> rows) {
        if (rows == null || rows.isEmpty()) {
            return "无数据\n";
        }
        List<String> headers = collectHeaders(rows);
        StringBuilder sb = new StringBuilder();
        sb.append(String.join(",", headers)).append("\n");
        for (Map<String, Object> row : rows) {
            for (int i = 0; i < headers.size(); i++) {
                String key = headers.get(i);
                String value = row.get(key) == null ? "" : String.valueOf(row.get(key));
                String escaped = value.replace("\"", "\"\"");
                if (escaped.contains(",") || escaped.contains("\"") || escaped.contains("\n")) {
                    sb.append("\"").append(escaped).append("\"");
                } else {
                    sb.append(escaped);
                }
                if (i < headers.size() - 1) {
                    sb.append(",");
                }
            }
            sb.append("\n");
        }
        return sb.toString();
    }

    public static List<Map<String, Object>> singleRow(Map<String, Object> row) {
        List<Map<String, Object>> rows = new ArrayList<>();
        rows.add(new LinkedHashMap<>(row));
        return rows;
    }

    private static List<String> collectHeaders(List<Map<String, Object>> rows) {
        List<String> headers = new ArrayList<>();
        for (Map<String, Object> row : rows) {
            if (row == null) {
                continue;
            }
            for (String key : row.keySet()) {
                if (!headers.contains(key)) {
                    headers.add(key);
                }
            }
        }
        return headers;
    }

    private static String urlEncode(String filename) {
        try {
            return URLEncoder.encode(filename, "UTF-8");
        } catch (Exception ex) {
            return filename;
        }
    }
}
