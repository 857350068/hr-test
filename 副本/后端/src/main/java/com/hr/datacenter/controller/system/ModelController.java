package com.hr.datacenter.controller.system;

import com.baomidou.mybatisplus.core.conditions.query.LambdaQueryWrapper;
import com.hr.datacenter.common.Result;
import com.hr.datacenter.entity.WarningModel;
import com.hr.datacenter.service.WarningModelService;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.security.access.prepost.PreAuthorize;
import org.springframework.web.bind.annotation.*;

import java.time.LocalDateTime;
import java.util.List;

@RestController
@RequestMapping("/system/model")
@CrossOrigin(origins = "*")
public class ModelController {
    @Autowired
    private WarningModelService modelService;

    @GetMapping("/list")
    @PreAuthorize("hasAnyAuthority('ROLE_ADMIN','ROLE_HR_ADMIN')")
    public Result<List<WarningModel>> list(@RequestParam(required = false) String modelType) {
        LambdaQueryWrapper<WarningModel> wrapper = new LambdaQueryWrapper<>();
        if (modelType != null && !modelType.isEmpty()) {
            wrapper.eq(WarningModel::getModelType, modelType);
        }
        wrapper.orderByDesc(WarningModel::getUpdateTime);
        return Result.success(modelService.list(wrapper));
    }

    @PostMapping("/add")
    @PreAuthorize("hasAnyAuthority('ROLE_ADMIN','ROLE_HR_ADMIN')")
    public Result<String> add(@RequestBody WarningModel model) {
        model.setModelId(null);
        model.setCreateTime(LocalDateTime.now());
        model.setUpdateTime(LocalDateTime.now());
        if (model.getStatus() == null) model.setStatus(1);
        modelService.save(model);
        return Result.success("新增成功", "");
    }

    @PutMapping("/update")
    @PreAuthorize("hasAnyAuthority('ROLE_ADMIN','ROLE_HR_ADMIN')")
    public Result<String> update(@RequestBody WarningModel model) {
        model.setUpdateTime(LocalDateTime.now());
        modelService.updateById(model);
        return Result.success("更新成功", "");
    }

    @DeleteMapping("/delete/{id}")
    @PreAuthorize("hasAnyAuthority('ROLE_ADMIN','ROLE_HR_ADMIN')")
    public Result<String> delete(@PathVariable Long id) {
        modelService.removeById(id);
        return Result.success("删除成功", "");
    }
}
