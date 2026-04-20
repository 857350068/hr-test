package com.hr.datacenter.controller;

import com.baomidou.mybatisplus.core.metadata.IPage;
import com.hr.datacenter.common.Result;
import com.hr.datacenter.entity.DataCategory;
import com.hr.datacenter.service.DataCategoryService;
import lombok.extern.slf4j.Slf4j;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.security.access.prepost.PreAuthorize;
import org.springframework.web.bind.annotation.*;

import java.util.List;

/**
 * 数据分类控制器
 *
 * @author HR DataCenter Team
 * @since 2024-01-20
 */
@Slf4j
@RestController
@RequestMapping("/data-category")
@CrossOrigin(origins = "*")
public class DataCategoryController {

    @Autowired
    private DataCategoryService dataCategoryService;

    /**
     * 分页查询数据分类
     */
    @GetMapping("/list")
    @PreAuthorize("hasAnyAuthority('ROLE_ADMIN','ROLE_HR_ADMIN')")
    public Result<IPage<DataCategory>> getCategoryList(
            @RequestParam(defaultValue = "1") int page,
            @RequestParam(defaultValue = "10") int size,
            @RequestParam(required = false) String keyword) {
        log.info("查询数据分类列表: page={}, size={}, keyword={}", page, size, keyword);
        IPage<DataCategory> categoryPage = dataCategoryService.getCategoryPage(page, size, keyword);
        return Result.success(categoryPage);
    }

    /**
     * 获取所有启用的分类
     */
    @GetMapping("/active")
    @PreAuthorize("isAuthenticated()")
    public Result<List<DataCategory>> getActiveCategories() {
        log.info("获取所有启用的分类");
        List<DataCategory> categories = dataCategoryService.getActiveCategories();
        return Result.success(categories);
    }

    /**
     * 根据父ID获取子分类
     */
    @GetMapping("/children/{parentId}")
    @PreAuthorize("hasAnyAuthority('ROLE_ADMIN','ROLE_HR_ADMIN')")
    public Result<List<DataCategory>> getCategoriesByParentId(@PathVariable Long parentId) {
        log.info("获取子分类: parentId={}", parentId);
        List<DataCategory> categories = dataCategoryService.getCategoriesByParentId(parentId);
        return Result.success(categories);
    }

    /**
     * 根据ID查询分类
     */
    @GetMapping("/{id}")
    @PreAuthorize("hasAnyAuthority('ROLE_ADMIN','ROLE_HR_ADMIN')")
    public Result<DataCategory> getCategoryById(@PathVariable Long id) {
        log.info("查询分类详情: id={}", id);
        DataCategory category = dataCategoryService.getById(id);
        if (category == null) {
            return Result.error("分类不存在");
        }
        return Result.success(category);
    }

    /**
     * 新增分类
     */
    @PostMapping("/add")
    @PreAuthorize("hasAnyAuthority('ROLE_ADMIN','ROLE_HR_ADMIN')")
    public Result<String> addCategory(@RequestBody DataCategory category) {
        log.info("新增分类: {}", category.getCategoryName());
        boolean success = dataCategoryService.addCategory(category);
        if (success) {
            return Result.success("新增成功", "");
        }
        return Result.error("新增失败");
    }

    /**
     * 更新分类
     */
    @PutMapping("/update")
    @PreAuthorize("hasAnyAuthority('ROLE_ADMIN','ROLE_HR_ADMIN')")
    public Result<String> updateCategory(@RequestBody DataCategory category) {
        log.info("更新分类: id={}, name={}", category.getCategoryId(), category.getCategoryName());
        boolean success = dataCategoryService.updateCategory(category);
        if (success) {
            return Result.success("更新成功", "");
        }
        return Result.error("更新失败");
    }

    /**
     * 删除分类
     */
    @DeleteMapping("/delete/{id}")
    @PreAuthorize("hasAnyAuthority('ROLE_ADMIN','ROLE_HR_ADMIN')")
    public Result<String> deleteCategory(@PathVariable Long id) {
        log.info("删除分类: id={}", id);
        boolean success = dataCategoryService.deleteCategory(id);
        if (success) {
            return Result.success("删除成功", "");
        }
        return Result.error("删除失败");
    }
}
