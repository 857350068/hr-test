package com.hr.datacenter.controller;

import com.hr.datacenter.common.Result;
import lombok.extern.slf4j.Slf4j;
import org.springframework.beans.factory.annotation.Value;
import org.springframework.web.bind.annotation.*;
import org.springframework.web.multipart.MultipartFile;

import java.io.File;
import java.io.IOException;
import java.nio.file.Files;
import java.nio.file.Path;
import java.nio.file.Paths;
import java.time.LocalDate;
import java.time.format.DateTimeFormatter;
import java.util.*;

/**
 * 文件上传控制器
 *
 * @author HR DataCenter Team
 * @since 2024-01-20
 */
@Slf4j
@RestController
@RequestMapping("/file")
@CrossOrigin(origins = "*")
public class FileUploadController {

    @Value("${file.upload.path:./uploads}")
    private String uploadPath;

    @Value("${file.upload.maxSize:10485760}")
    private long maxFileSize;

    /**
     * 上传单个文件
     */
    @PostMapping("/upload")
    public Result<Map<String, Object>> uploadFile(@RequestParam("file") MultipartFile file) {
        if (file.isEmpty()) {
            return Result.error("文件不能为空");
        }

        try {
            // 检查文件大小
            if (file.getSize() > maxFileSize) {
                return Result.error("文件大小超过限制");
            }

            // 生成文件保存路径
            String originalFilename = file.getOriginalFilename();
            String fileExtension = getFileExtension(originalFilename);
            String newFilename = generateFilename() + fileExtension;

            // 按日期分目录存储
            String datePath = LocalDate.now().format(DateTimeFormatter.ofPattern("yyyy/MM/dd"));
            String fullPath = uploadPath + File.separator + datePath;

            // 创建目录
            Path directory = Paths.get(fullPath);
            if (!Files.exists(directory)) {
                Files.createDirectories(directory);
            }

            // 保存文件
            Path filePath = Paths.get(fullPath, newFilename);
            file.transferTo(filePath.toFile());

            // 返回文件信息
            Map<String, Object> result = new HashMap<>();
            result.put("filename", newFilename);
            result.put("originalFilename", originalFilename);
            result.put("url", "/uploads/" + datePath + "/" + newFilename);
            result.put("size", file.getSize());
            result.put("type", file.getContentType());

            log.info("文件上传成功: {}", result);
            return Result.success(result);

        } catch (IOException e) {
            log.error("文件上传失败", e);
            return Result.error("文件上传失败: " + e.getMessage());
        }
    }

    /**
     * 批量上传文件
     */
    @PostMapping("/batch-upload")
    public Result<Map<String, Object>> batchUpload(@RequestParam("files") MultipartFile[] files) {
        if (files == null || files.length == 0) {
            return Result.error("文件不能为空");
        }

        List<Map<String, Object>> results = new ArrayList<>();
        List<String> errors = new ArrayList<>();

        for (int i = 0; i < files.length; i++) {
            MultipartFile file = files[i];
            try {
                if (file.isEmpty()) {
                    errors.add("文件" + (i + 1) + "为空");
                    continue;
                }

                if (file.getSize() > maxFileSize) {
                    errors.add("文件" + (i + 1) + "大小超过限制");
                    continue;
                }

                String originalFilename = file.getOriginalFilename();
                String fileExtension = getFileExtension(originalFilename);
                String newFilename = generateFilename() + fileExtension;

                String datePath = LocalDate.now().format(DateTimeFormatter.ofPattern("yyyy/MM/dd"));
                String fullPath = uploadPath + File.separator + datePath;

                Path directory = Paths.get(fullPath);
                if (!Files.exists(directory)) {
                    Files.createDirectories(directory);
                }

                Path filePath = Paths.get(fullPath, newFilename);
                file.transferTo(filePath.toFile());

                Map<String, Object> fileInfo = new HashMap<>();
                fileInfo.put("filename", newFilename);
                fileInfo.put("originalFilename", originalFilename);
                fileInfo.put("url", "/uploads/" + datePath + "/" + newFilename);
                fileInfo.put("size", file.getSize());
                fileInfo.put("type", file.getContentType());
                results.add(fileInfo);

            } catch (IOException e) {
                errors.add("文件" + (i + 1) + "上传失败: " + e.getMessage());
                log.error("文件上传失败", e);
            }
        }

        if (errors.isEmpty()) {
            Map<String, Object> response = new HashMap<>();
            response.put("files", results);
            return Result.success(response);
        } else {
            Map<String, Object> response = new HashMap<>();
            response.put("success", results);
            response.put("errors", errors);
            return Result.success(response);
        }
    }

    /**
     * 上传员工照片
     */
    @PostMapping("/upload-photo")
    public Result<Map<String, Object>> uploadPhoto(
            @RequestParam("file") MultipartFile file,
            @RequestParam("empId") Long empId) {
        if (file.isEmpty()) {
            return Result.error("照片不能为空");
        }

        try {
            // 检查文件类型
            String contentType = file.getContentType();
            if (contentType == null || !contentType.startsWith("image/")) {
                return Result.error("只能上传图片文件");
            }

            // 检查文件大小（照片最大2MB）
            if (file.getSize() > 2 * 1024 * 1024) {
                return Result.error("照片大小不能超过2MB");
            }

            String originalFilename = file.getOriginalFilename();
            String fileExtension = getFileExtension(originalFilename);
            String newFilename = "photo_" + empId + "_" + generateFilename() + fileExtension;

            String photoPath = uploadPath + File.separator + "photos";
            Path directory = Paths.get(photoPath);
            if (!Files.exists(directory)) {
                Files.createDirectories(directory);
            }

            Path filePath = Paths.get(photoPath, newFilename);
            file.transferTo(filePath.toFile());

            Map<String, Object> result = new HashMap<>();
            result.put("filename", newFilename);
            result.put("originalFilename", originalFilename);
            result.put("url", "/uploads/photos/" + newFilename);
            result.put("empId", empId);

            log.info("员工照片上传成功: empId={}, url={}", empId, result.get("url"));
            return Result.success(result);

        } catch (IOException e) {
            log.error("照片上传失败", e);
            return Result.error("照片上传失败: " + e.getMessage());
        }
    }

    /**
     * 删除文件
     */
    @DeleteMapping("/delete")
    public Result<String> deleteFile(@RequestParam String fileUrl) {
        try {
            String filePath = uploadPath + fileUrl.replace("/uploads", "");
            Path path = Paths.get(filePath);

            if (Files.exists(path)) {
                Files.delete(path);
                log.info("文件删除成功: {}", fileUrl);
                return Result.success("删除成功");
            } else {
                return Result.error("文件不存在");
            }
        } catch (IOException e) {
            log.error("文件删除失败", e);
            return Result.error("文件删除失败: " + e.getMessage());
        }
    }

    /**
     * 获取文件扩展名
     */
    private String getFileExtension(String filename) {
        if (filename == null || filename.lastIndexOf(".") == -1) {
            return "";
        }
        return filename.substring(filename.lastIndexOf("."));
    }

    /**
     * 生成唯一文件名
     */
    private String generateFilename() {
        return UUID.randomUUID().toString().replace("-", "");
    }
}
