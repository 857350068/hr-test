package com.hr.backend.controller;

import com.baomidou.mybatisplus.core.metadata.IPage;
import com.baomidou.mybatisplus.extension.plugins.pagination.Page;
import com.hr.backend.common.Response;
import com.hr.backend.model.entity.DataCategory;
import com.hr.backend.service.DataCategoryService;
import org.springframework.security.access.prepost.PreAuthorize;
import org.springframework.web.bind.annotation.*;

import javax.annotation.Resource;
import java.util.List;

@RestController
@RequestMapping("/api/category")
@PreAuthorize("hasRole('HR_ADMIN')")
public class DataCategoryController {

    @Resource
    private DataCategoryService categoryService;

    @GetMapping("/list")
    public Response<List<DataCategory>> list() {
        return Response.success(categoryService.list());
    }

    /**
     * 分页查询数据分类列表
     * @param current 当前页码，默认1
     * @param size 每页条数，默认10
     * @param name 分类名称（可选，支持模糊查询）
     * @return 分页结果
     */
    @GetMapping("/page")
    public Response<IPage<DataCategory>> page(
            @RequestParam(defaultValue = "1") Long current,
            @RequestParam(defaultValue = "10") Long size,
            @RequestParam(required = false) String name) {
        Page<DataCategory> page = new Page<>(current, size);
        IPage<DataCategory> result = categoryService.page(page, name);
        return Response.success(result);
    }

    @GetMapping("/tree")
    public Response<List<DataCategory>> tree() {
        return Response.success(categoryService.tree());
    }

    @PostMapping
    public Response<Void> add(@RequestBody DataCategory category) {
        categoryService.save(category);
        return Response.success();
    }

    @PutMapping("/{id}")
    public Response<Void> update(@PathVariable Long id, @RequestBody DataCategory category) {
        category.setId(id);
        categoryService.updateById(category);
        return Response.success();
    }

    @DeleteMapping("/{id}")
    public Response<Void> delete(@PathVariable Long id) {
        categoryService.removeById(id);
        return Response.success();
    }
}
