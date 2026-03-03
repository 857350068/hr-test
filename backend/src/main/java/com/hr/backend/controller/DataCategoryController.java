package com.hr.backend.controller;

import com.hr.backend.common.Response;
import com.hr.backend.model.entity.DataCategory;
import com.hr.backend.service.DataCategoryService;
import org.springframework.web.bind.annotation.*;

import javax.annotation.Resource;
import java.util.List;

@RestController
@RequestMapping("/api/category")
public class DataCategoryController {

    @Resource
    private DataCategoryService categoryService;

    @GetMapping("/list")
    public Response<List<DataCategory>> list() {
        return Response.success(categoryService.list());
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
