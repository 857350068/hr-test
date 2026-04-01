# 分页功能 - 技术设计文档

## 1. 架构概述

### 1.1 设计目标

本设计文档描述如何为人力资源数据中心系统实现统一的分页功能，确保在数据量增长时系统仍能保持良好的性能和用户体验。设计遵循以下原则：

- **类型安全**：严格使用强类型定义，避免使用 `any`，确保编译时类型检查
- **统一规范**：所有分页接口使用统一的参数命名和响应格式
- **性能优先**：使用数据库分页而非内存分页，避免加载全部数据
- **向后兼容**：保留原有的 `list` 接口，不影响现有功能
- **安全可靠**：添加参数校验和边界检查，防止SQL注入和页码越界

### 1.2 技术栈

**后端技术栈：**
- Spring Boot 2.7.18
- MyBatis-Plus 3.5.5
- MySQL 8.0.33
- JDK 1.8

**前端技术栈：**
- Vue 3.4.0
- Element Plus 2.5.0
- TypeScript 5.x
- Axios 1.6.5

### 1.3 整体架构

```mermaid
graph TB
    subgraph 前端层
        A[Vue组件] --> B[el-pagination组件]
        B --> C[Axios HTTP客户端]
    end

    subgraph 后端层
        C --> D[Controller层]
        D --> E[Service层]
        E --> F[MyBatis-Plus Mapper]
    end

    subgraph 数据层
        F --> G[MySQL数据库]
    end

    subgraph 拦截层
        E --> H[MyBatis-Plus分页插件]
        H --> F
    end

    style A fill:#e1f5ff
    style D fill:#fff4e1
    style E fill:#fff4e1
    style G fill:#e8f5e9
```

---

## 2. 后端设计

### 2.1 分页插件配置

MyBatis-Plus 分页插件需要在配置类中进行初始化。如果项目中尚未配置，需要添加以下配置：

**配置类路径：** `com.hr.backend.config.MybatisPlusConfig`

```java
package com.hr.backend.config;

import com.baomidou.mybatisplus.annotation.DbType;
import com.baomidou.mybatisplus.extension.plugins.MybatisPlusInterceptor;
import com.baomidou.mybatisplus.extension.plugins.inner.PaginationInnerInterceptor;
import org.springframework.context.annotation.Bean;
import org.springframework.context.annotation.Configuration;

/**
 * MyBatis-Plus配置类
 * 配置分页插件
 */
@Configuration
public class MybatisPlusConfig {

    /**
     * 配置MyBatis-Plus分页插件
     * @return MybatisPlusInterceptor
     */
    @Bean
    public MybatisPlusInterceptor mybatisPlusInterceptor() {
        MybatisPlusInterceptor interceptor = new MybatisPlusInterceptor();
        // 添加分页插件，指定数据库类型为MySQL
        PaginationInnerInterceptor paginationInterceptor = new PaginationInnerInterceptor(DbType.MYSQL);
        // 设置请求的页面大于最大页后操作，true调回到首页，false继续请求
        paginationInterceptor.setOverflow(false);
        // 设置单页分页条数限制（默认无限制）
        paginationInterceptor.setMaxLimit(100L);
        interceptor.addInnerInterceptor(paginationInterceptor);
        return interceptor;
    }
}
```

**设计说明：**
- `DbType.MYSQL`：指定数据库类型，确保生成正确的分页SQL
- `setOverflow(false)`：当请求页码超过总页数时，返回空数据（由业务层处理边界）
- `setMaxLimit(100L)`：限制每页最大条数为100，防止性能问题

### 2.2 统一分页参数类

为了确保类型安全和代码复用，定义统一的分页参数类：

**类路径：** `com.hr.backend.model.dto.PageQuery`

```java
package com.hr.backend.model.dto;

import lombok.Data;

/**
 * 统一分页查询参数
 */
@Data
public class PageQuery {

    /**
     * 当前页码，从1开始
     */
    private Long current = 1L;

    /**
     * 每页条数，默认10，最大100
     */
    private Long size = 10L;

    /**
     * 校验并修正分页参数
     * 确保current >= 1，size在1-100之间
     */
    public void validateAndCorrect() {
        if (current == null || current < 1) {
            current = 1L;
        }
        if (size == null || size < 1) {
            size = 10L;
        }
        if (size > 100) {
            size = 100L;
        }
    }
}
```

**类型安全说明：**
- 使用 `Long` 类型而非 `int`，避免溢出风险
- 提供 `validateAndCorrect()` 方法进行边界校验
- 所有字段使用明确的默认值

### 2.3 Controller层设计

为每个需要分页的Controller添加分页查询接口，遵循统一的接口规范。

#### 2.3.1 DepartmentController

**文件路径：** `com.hr.backend.controller.DepartmentController`

**新增接口：**

```java
package com.hr.backend.controller;

import com.baomidou.mybatisplus.core.metadata.IPage;
import com.baomidou.mybatisplus.extension.plugins.pagination.Page;
import com.hr.backend.common.Response;
import com.hr.backend.model.entity.Department;
import com.hr.backend.service.DepartmentService;
import org.springframework.security.access.prepost.PreAuthorize;
import org.springframework.web.bind.annotation.*;

import javax.annotation.Resource;

/**
 * 部门管理控制器
 * 提供部门的增删改查和分页查询功能
 */
@RestController
@RequestMapping("/api/department")
@PreAuthorize("hasRole('HR_ADMIN')")
public class DepartmentController {

    @Resource
    private DepartmentService departmentService;

    /**
     * 分页查询部门列表
     * @param current 当前页码，默认1
     * @param size 每页条数，默认10
     * @param name 部门名称（可选，支持模糊查询）
     * @return 分页结果
     */
    @GetMapping("/page")
    public Response<IPage<Department>> page(
            @RequestParam(defaultValue = "1") Long current,
            @RequestParam(defaultValue = "10") Long size,
            @RequestParam(required = false) String name) {
        // 创建分页对象
        Page<Department> page = new Page<>(current, size);
        // 调用Service层分页查询
        IPage<Department> result = departmentService.page(page, name);
        return Response.success(result);
    }

    // 保留原有的list接口，确保向后兼容
    @GetMapping("/list")
    public Response<List<Department>> list() {
        return Response.success(departmentService.getAllDepartments());
    }

    // ... 其他现有方法保持不变
}
```

**接口说明：**
- 接口路径：`GET /api/department/page`
- 参数类型：使用 `Long` 类型明确指定，避免使用 `any`
- 响应类型：`Response<IPage<Department>>`，严格类型定义
- 权限控制：`@PreAuthorize("hasRole('HR_ADMIN')")`

#### 2.3.2 DataCategoryController

**文件路径：** `com.hr.backend.controller.DataCategoryController`

**新增接口：**

```java
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

/**
 * 数据分类管理控制器
 */
@RestController
@RequestMapping("/api/category")
@PreAuthorize("hasRole('HR_ADMIN')")
public class DataCategoryController {

    @Resource
    private DataCategoryService dataCategoryService;

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
        IPage<DataCategory> result = dataCategoryService.page(page, name);
        return Response.success(result);
    }

    // 保留原有的list接口
    @GetMapping("/list")
    public Response<List<DataCategory>> list() {
        return Response.success(dataCategoryService.list());
    }

    // ... 其他现有方法保持不变
}
```

#### 2.3.3 RuleController

**文件路径：** `com.hr.backend.controller.RuleController`

**新增接口：**

```java
package com.hr.backend.controller;

import com.baomidou.mybatisplus.core.metadata.IPage;
import com.baomidou.mybatisplus.extension.plugins.pagination.Page;
import com.hr.backend.common.Response;
import com.hr.backend.model.entity.WarningRule;
import com.hr.backend.service.WarningRuleService;
import org.springframework.security.access.prepost.PreAuthorize;
import org.springframework.web.bind.annotation.*;

import javax.annotation.Resource;

/**
 * 预警规则管理控制器
 */
@RestController
@RequestMapping("/api/rule")
@PreAuthorize("hasRole('HR_ADMIN')")
public class RuleController {

    @Resource
    private WarningRuleService warningRuleService;

    /**
     * 分页查询预警规则列表
     * @param current 当前页码，默认1
     * @param size 每页条数，默认10
     * @param ruleType 规则类型（可选）
     * @param isActive 生效状态（可选）
     * @return 分页结果
     */
    @GetMapping("/page")
    public Response<IPage<WarningRule>> page(
            @RequestParam(defaultValue = "1") Long current,
            @RequestParam(defaultValue = "10") Long size,
            @RequestParam(required = false) String ruleType,
            @RequestParam(required = false) Boolean isActive) {
        Page<WarningRule> page = new Page<>(current, size);
        IPage<WarningRule> result = warningRuleService.page(page, ruleType, isActive);
        return Response.success(result);
    }

    // ... 其他现有方法保持不变
}
```

#### 2.3.4 ReportController

**文件路径：** `com.hr.backend.controller.ReportController`

**新增接口：**

```java
package com.hr.backend.controller;

import com.baomidou.mybatisplus.core.metadata.IPage;
import com.baomidou.mybatisplus.extension.plugins.pagination.Page;
import com.hr.backend.common.Response;
import com.hr.backend.model.entity.ReportTemplate;
import com.hr.backend.service.ReportTemplateService;
import org.springframework.security.access.prepost.PreAuthorize;
import org.springframework.web.bind.annotation.*;

import javax.annotation.Resource;

/**
 * 报表模板管理控制器
 */
@RestController
@RequestMapping("/api/report")
@PreAuthorize("hasRole('HR_ADMIN')")
public class ReportController {

    @Resource
    private ReportTemplateService reportTemplateService;

    /**
     * 分页查询报表模板列表
     * @param current 当前页码，默认1
     * @param size 每页条数，默认10
     * @param category 报表分类（可选）
     * @param name 报表名称（可选，支持模糊查询）
     * @return 分页结果
     */
    @GetMapping("/page")
    public Response<IPage<ReportTemplate>> page(
            @RequestParam(defaultValue = "1") Long current,
            @RequestParam(defaultValue = "10") Long size,
            @RequestParam(required = false) String category,
            @RequestParam(required = false) String name) {
        Page<ReportTemplate> page = new Page<>(current, size);
        IPage<ReportTemplate> result = reportTemplateService.page(page, category, name);
        return Response.success(result);
    }

    // ... 其他现有方法保持不变
}
```

#### 2.3.5 FavoriteController

**文件路径：** `com.hr.backend.controller.FavoriteController`

**新增接口：**

```java
package com.hr.backend.controller;

import com.baomidou.mybatisplus.core.metadata.IPage;
import com.baomidou.mybatisplus.extension.plugins.pagination.Page;
import com.hr.backend.common.Response;
import com.hr.backend.model.entity.Favorite;
import com.hr.backend.service.FavoriteService;
import org.springframework.security.core.Authentication;
import org.springframework.security.core.context.SecurityContextHolder;
import org.springframework.web.bind.annotation.*;

import javax.annotation.Resource;

/**
 * 收藏管理控制器
 */
@RestController
@RequestMapping("/api/favorite")
public class FavoriteController {

    @Resource
    private FavoriteService favoriteService;

    /**
     * 分页查询当前用户的收藏列表
     * @param current 当前页码，默认1
     * @param size 每页条数，默认10
     * @param favType 收藏类型（可选）
     * @return 分页结果
     */
    @GetMapping("/page")
    public Response<IPage<Favorite>> page(
            @RequestParam(defaultValue = "1") Long current,
            @RequestParam(defaultValue = "10") Long size,
            @RequestParam(required = false) String favType) {
        // 从JWT中获取当前登录用户ID
        Authentication authentication = SecurityContextHolder.getContext().getAuthentication();
        Long userId = Long.parseLong(authentication.getName());

        Page<Favorite> page = new Page<>(current, size);
        IPage<Favorite> result = favoriteService.pageByUser(page, userId, favType);
        return Response.success(result);
    }

    // ... 其他现有方法保持不变
}
```

**安全设计说明：**
- 使用 `SecurityContextHolder` 从JWT中获取用户ID
- Service层自动按用户ID过滤，确保数据隔离
- 不需要额外的权限注解，所有登录用户都可以访问自己的收藏

### 2.4 Service层设计

为每个Service接口添加分页查询方法，并在实现类中实现具体的分页逻辑。

#### 2.4.1 DepartmentService

**接口定义：**

```java
package com.hr.backend.service;

import com.baomidou.mybatisplus.core.metadata.IPage;
import com.baomidou.mybatisplus.extension.plugins.pagination.Page;
import com.baomidou.mybatisplus.extension.service.IService;
import com.hr.backend.model.entity.Department;
import com.baomidou.mybatisplus.core.conditions.query.LambdaQueryWrapper;

/**
 * 部门服务接口
 */
public interface DepartmentService extends IService<Department> {

    /**
     * 分页查询部门列表
     * @param page 分页对象
     * @param name 部门名称（可选，支持模糊查询）
     * @return 分页结果
     */
    IPage<Department> page(Page<Department> page, String name);

    // ... 其他现有方法保持不变
}
```

**实现类：**

```java
package com.hr.backend.service.impl;

import com.baomidou.mybatisplus.core.conditions.query.LambdaQueryWrapper;
import com.baomidou.mybatisplus.core.metadata.IPage;
import com.baomidou.mybatisplus.extension.plugins.pagination.Page;
import com.baomidou.mybatisplus.extension.service.impl.ServiceImpl;
import com.hr.backend.mapper.DepartmentMapper;
import com.hr.backend.model.entity.Department;
import com.hr.backend.service.DepartmentService;
import org.apache.commons.lang3.StringUtils;
import org.springframework.stereotype.Service;

/**
 * 部门服务实现类
 */
@Service
public class DepartmentServiceImpl extends ServiceImpl<DepartmentMapper, Department>
        implements DepartmentService {

    @Override
    public IPage<Department> page(Page<Department> page, String name) {
        LambdaQueryWrapper<Department> wrapper = new LambdaQueryWrapper<>();
        // 如果提供了名称，添加模糊查询条件
        if (StringUtils.isNotBlank(name)) {
            wrapper.like(Department::getName, name);
        }
        // 按ID升序排序
        wrapper.orderByAsc(Department::getId);
        // MyBatis-Plus会自动应用分页
        return this.page(page, wrapper);
    }

    // ... 其他现有方法保持不变
}
```

**类型安全说明：**
- 使用 `LambdaQueryWrapper` 而非字符串字段名，编译时类型检查
- 使用 `StringUtils.isNotBlank()` 进行空值检查，避免NPE
- 方法签名明确指定参数和返回值类型

#### 2.4.2 DataCategoryService

**接口定义：**

```java
package com.hr.backend.service;

import com.baomidou.mybatisplus.core.metadata.IPage;
import com.baomidou.mybatisplus.extension.plugins.pagination.Page;
import com.baomidou.mybatisplus.extension.service.IService;
import com.hr.backend.model.entity.DataCategory;

/**
 * 数据分类服务接口
 */
public interface DataCategoryService extends IService<DataCategory> {

    /**
     * 分页查询数据分类列表
     * @param page 分页对象
     * @param name 分类名称（可选，支持模糊查询）
     * @return 分页结果
     */
    IPage<DataCategory> page(Page<DataCategory> page, String name);

    // ... 其他现有方法保持不变
}
```

**实现类：**

```java
package com.hr.backend.service.impl;

import com.baomidou.mybatisplus.core.conditions.query.LambdaQueryWrapper;
import com.baomidou.mybatisplus.core.metadata.IPage;
import com.baomidou.mybatisplus.extension.plugins.pagination.Page;
import com.baomidou.mybatisplus.extension.service.impl.ServiceImpl;
import com.hr.backend.mapper.DataCategoryMapper;
import com.hr.backend.model.entity.DataCategory;
import com.hr.backend.service.DataCategoryService;
import org.apache.commons.lang3.StringUtils;
import org.springframework.stereotype.Service;

/**
 * 数据分类服务实现类
 */
@Service
public class DataCategoryServiceImpl extends ServiceImpl<DataCategoryMapper, DataCategory>
        implements DataCategoryService {

    @Override
    public IPage<DataCategory> page(Page<DataCategory> page, String name) {
        LambdaQueryWrapper<DataCategory> wrapper = new LambdaQueryWrapper<>();
        if (StringUtils.isNotBlank(name)) {
            wrapper.like(DataCategory::getName, name);
        }
        wrapper.orderByAsc(DataCategory::getId);
        return this.page(page, wrapper);
    }

    // ... 其他现有方法保持不变
}
```

#### 2.4.3 WarningRuleService

**接口定义：**

```java
package com.hr.backend.service;

import com.baomidou.mybatisplus.core.metadata.IPage;
import com.baomidou.mybatisplus.extension.plugins.pagination.Page;
import com.baomidou.mybatisplus.extension.service.IService;
import com.hr.backend.model.entity.WarningRule;

/**
 * 预警规则服务接口
 */
public interface WarningRuleService extends IService<WarningRule> {

    /**
     * 分页查询预警规则列表
     * @param page 分页对象
     * @param ruleType 规则类型（可选）
     * @param isActive 生效状态（可选）
     * @return 分页结果
     */
    IPage<WarningRule> page(Page<WarningRule> page, String ruleType, Boolean isActive);

    // ... 其他现有方法保持不变
}
```

**实现类：**

```java
package com.hr.backend.service.impl;

import com.baomidou.mybatisplus.core.conditions.query.LambdaQueryWrapper;
import com.baomidou.mybatisplus.core.metadata.IPage;
import com.baomidou.mybatisplus.extension.plugins.pagination.Page;
import com.baomidou.mybatisplus.extension.service.impl.ServiceImpl;
import com.hr.backend.mapper.WarningRuleMapper;
import com.hr.backend.model.entity.WarningRule;
import com.hr.backend.service.WarningRuleService;
import org.apache.commons.lang3.StringUtils;
import org.springframework.stereotype.Service;

/**
 * 预警规则服务实现类
 */
@Service
public class WarningRuleServiceImpl extends ServiceImpl<WarningRuleMapper, WarningRule>
        implements WarningRuleService {

    @Override
    public IPage<WarningRule> page(Page<WarningRule> page, String ruleType, Boolean isActive) {
        LambdaQueryWrapper<WarningRule> wrapper = new LambdaQueryWrapper<>();
        if (StringUtils.isNotBlank(ruleType)) {
            wrapper.eq(WarningRule::getRuleType, ruleType);
        }
        if (isActive != null) {
            wrapper.eq(WarningRule::getIsActive, isActive);
        }
        wrapper.orderByDesc(WarningRule::getCreatedTime);
        return this.page(page, wrapper);
    }

    // ... 其他现有方法保持不变
}
```

#### 2.4.4 ReportTemplateService

**接口定义：**

```java
package com.hr.backend.service;

import com.baomidou.mybatisplus.core.metadata.IPage;
import com.baomidou.mybatisplus.extension.plugins.pagination.Page;
import com.baomidou.mybatisplus.extension.service.IService;
import com.hr.backend.model.entity.ReportTemplate;

/**
 * 报表模板服务接口
 */
public interface ReportTemplateService extends IService<ReportTemplate> {

    /**
     * 分页查询报表模板列表
     * @param page 分页对象
     * @param category 报表分类（可选）
     * @param name 报表名称（可选，支持模糊查询）
     * @return 分页结果
     */
    IPage<ReportTemplate> page(Page<ReportTemplate> page, String category, String name);

    // ... 其他现有方法保持不变
}
```

**实现类：**

```java
package com.hr.backend.service.impl;

import com.baomidou.mybatisplus.core.conditions.query.LambdaQueryWrapper;
import com.baomidou.mybatisplus.core.metadata.IPage;
import com.baomidou.mybatisplus.extension.plugins.pagination.Page;
import com.baomidou.mybatisplus.extension.service.impl.ServiceImpl;
import com.hr.backend.mapper.ReportTemplateMapper;
import com.hr.backend.model.entity.ReportTemplate;
import com.hr.backend.service.ReportTemplateService;
import org.apache.commons.lang3.StringUtils;
import org.springframework.stereotype.Service;

/**
 * 报表模板服务实现类
 */
@Service
public class ReportTemplateServiceImpl extends ServiceImpl<ReportTemplateMapper, ReportTemplate>
        implements ReportTemplateService {

    @Override
    public IPage<ReportTemplate> page(Page<ReportTemplate> page, String category, String name) {
        LambdaQueryWrapper<ReportTemplate> wrapper = new LambdaQueryWrapper<>();
        if (StringUtils.isNotBlank(category)) {
            wrapper.eq(ReportTemplate::getCategory, category);
        }
        if (StringUtils.isNotBlank(name)) {
            wrapper.like(ReportTemplate::getName, name);
        }
        wrapper.orderByDesc(ReportTemplate::getCreatedTime);
        return this.page(page, wrapper);
    }

    // ... 其他现有方法保持不变
}
```

#### 2.4.5 FavoriteService

**接口定义：**

```java
package com.hr.backend.service;

import com.baomidou.mybatisplus.core.metadata.IPage;
import com.baomidou.mybatisplus.extension.plugins.pagination.Page;
import com.baomidou.mybatisplus.extension.service.IService;
import com.hr.backend.model.entity.Favorite;

/**
 * 收藏服务接口
 */
public interface FavoriteService extends IService<Favorite> {

    /**
     * 分页查询指定用户的收藏列表
     * @param page 分页对象
     * @param userId 用户ID
     * @param favType 收藏类型（可选）
     * @return 分页结果
     */
    IPage<Favorite> pageByUser(Page<Favorite> page, Long userId, String favType);

    // ... 其他现有方法保持不变
}
```

**实现类：**

```java
package com.hr.backend.service.impl;

import com.baomidou.mybatisplus.core.conditions.query.LambdaQueryWrapper;
import com.baomidou.mybatisplus.core.metadata.IPage;
import com.baomidou.mybatisplus.extension.plugins.pagination.Page;
import com.baomidou.mybatisplus.extension.service.impl.ServiceImpl;
import com.hr.backend.mapper.FavoriteMapper;
import com.hr.backend.model.entity.Favorite;
import com.hr.backend.service.FavoriteService;
import org.apache.commons.lang3.StringUtils;
import org.springframework.stereotype.Service;

/**
 * 收藏服务实现类
 */
@Service
public class FavoriteServiceImpl extends ServiceImpl<FavoriteMapper, Favorite>
        implements FavoriteService {

    @Override
    public IPage<Favorite> pageByUser(Page<Favorite> page, Long userId, String favType) {
        LambdaQueryWrapper<Favorite> wrapper = new LambdaQueryWrapper<>();
        // 必须按用户ID过滤
        wrapper.eq(Favorite::getUserId, userId);
        if (StringUtils.isNotBlank(favType)) {
            wrapper.eq(Favorite::getFavType, favType);
        }
        wrapper.orderByDesc(Favorite::getCreatedTime);
        return this.page(page, wrapper);
    }

    // ... 其他现有方法保持不变
}
```

**安全设计说明：**
- `pageByUser` 方法必须接收 `userId` 参数，确保数据隔离
- 使用 `LambdaQueryWrapper` 的 `eq` 方法进行精确匹配
- 在Controller层从JWT获取用户ID，Service层不直接依赖Spring Security

### 2.5 数据库设计

分页功能不需要修改数据库表结构，但需要确保相关表有合适的索引以优化查询性能。

#### 2.5.1 推荐索引

| 表名 | 索引字段 | 索引类型 | 说明 |
|------|---------|---------|------|
| hr_department | name | INDEX | 支持按名称模糊查询 |
| hr_data_category | name | INDEX | 支持按名称模糊查询 |
| warning_rule | rule_type, is_active | INDEX | 支持按类型和状态筛选 |
| warning_rule | created_time | INDEX | 支持按创建时间排序 |
| report_template | category, name | INDEX | 支持按分类和名称筛选 |
| report_template | created_time | INDEX | 支持按创建时间排序 |
| sys_favorite | user_id, fav_type | INDEX | 支持按用户和类型筛选 |
| sys_favorite | created_time | INDEX | 支持按创建时间排序 |

**索引创建SQL示例：**

```sql
-- 部门表索引
CREATE INDEX idx_department_name ON hr_department(name);

-- 数据分类表索引
CREATE INDEX idx_data_category_name ON hr_data_category(name);

-- 预警规则表索引
CREATE INDEX idx_warning_rule_type_status ON warning_rule(rule_type, is_active);
CREATE INDEX idx_warning_rule_created_time ON warning_rule(created_time);

-- 报表模板表索引
CREATE INDEX idx_report_template_category_name ON report_template(category, name);
CREATE INDEX idx_report_template_created_time ON report_template(created_time);

-- 收藏表索引
CREATE INDEX idx_favorite_user_type ON sys_favorite(user_id, fav_type);
CREATE INDEX idx_favorite_created_time ON sys_favorite(created_time);
```

---

## 3. 前端设计

### 3.1 统一分页状态管理

为了在多个页面复用分页逻辑，定义统一的分页状态类型：

**类型定义文件：** `src/types/pagination.ts`

```typescript
/**
 * 统一分页状态类型
 */
export interface PaginationState {
  current: number;      // 当前页码
  size: number;         // 每页条数
  total: number;        // 总记录数
}

/**
 * 分页查询参数类型
 */
export interface PageQuery {
  current: number;
  size: number;
}

/**
 * 分页响应数据类型
 */
export interface PageResponse<T> {
  records: T[];         // 当前页数据列表
  total: number;        // 总记录数
  size: number;         // 每页条数
  current: number;      // 当前页码
  pages: number;        // 总页数
}
```

**类型安全说明：**
- 使用 TypeScript 接口明确定义类型
- 泛型 `T` 用于表示不同的实体类型
- 所有字段都有明确的类型注解

### 3.2 分页组件封装

创建可复用的分页组件，统一分页交互逻辑：

**组件路径：** `src/components/PaginationComponent.vue`

```vue
<template>
  <el-pagination
    v-model:current-page="modelValue.current"
    v-model:page-size="modelValue.size"
    :total="modelValue.total"
    :page-sizes="[10, 20, 50, 100]"
    :layout="layout"
    @current-change="handleCurrentChange"
    @size-change="handleSizeChange"
    style="margin-top: 16px; justify-content: flex-end"
  />
</template>

<script setup lang="ts">
import { PaginationState } from '@/types/pagination';

interface Props {
  modelValue: PaginationState;
  layout?: string;
}

interface Emits {
  (e: 'update:modelValue', value: PaginationState): void;
  (e: 'change'): void;
}

const props = withDefaults(defineProps<Props>(), {
  layout: 'total, sizes, prev, pager, next, jumper'
});

const emit = defineEmits<Emits>();

const handleCurrentChange = () => {
  emit('change');
};

const handleSizeChange = () => {
  emit('change');
};
</script>
```

**设计说明：**
- 使用 `v-model` 实现双向绑定
- 支持自定义布局配置
- 通过事件通知父组件数据变化
- 使用 TypeScript 确保类型安全

### 3.3 页面组件集成

为每个需要分页的页面添加分页功能。

#### 3.3.1 DepartmentManagementView

**文件路径：** `src/views/admin/DepartmentManagementView.vue`

```vue
<template>
  <div>
    <div class="page-header">
      <h2 class="page-title">部门管理</h2>
      <el-button type="primary" @click="openDialog()">新增部门</el-button>
    </div>
    <el-card>
      <el-form inline class="mb-4">
        <el-form-item label="部门名称">
          <el-input v-model="query.name" placeholder="部门名称" clearable style="width: 200px" />
        </el-form-item>
        <el-form-item>
          <el-button type="primary" @click="load">查询</el-button>
          <el-button @click="resetQuery">重置</el-button>
        </el-form-item>
      </el-form>
      <el-table :data="tableData" stripe v-loading="loading">
        <el-table-column prop="id" label="ID" width="80" />
        <el-table-column prop="name" label="部门名称" />
        <el-table-column prop="description" label="描述" show-overflow-tooltip />
        <el-table-column label="操作" width="150" fixed="right">
          <template #default="{ row }">
            <el-button type="primary" link @click="openDialog(row)">编辑</el-button>
            <el-button type="danger" link @click="handleDelete(row.id)">删除</el-button>
          </template>
        </el-table-column>
      </el-table>
      <!-- 分页组件 -->
      <el-pagination
        v-model:current-page="page.current"
        v-model:page-size="page.size"
        :total="page.total"
        :page-sizes="[10, 20, 50, 100]"
        layout="total, sizes, prev, pager, next, jumper"
        @current-change="load"
        @size-change="load"
        style="margin-top: 16px; justify-content: flex-end"
      />
    </el-card>

    <!-- 新增/编辑对话框 -->
    <el-dialog v-model="dialogVisible" :title="dialogTitle" width="600px" @close="resetForm">
      <el-form :model="form" :rules="rules" ref="formRef" label-width="100px">
        <el-form-item label="部门名称" prop="name">
          <el-input v-model="form.name" placeholder="请输入部门名称" />
        </el-form-item>
        <el-form-item label="描述" prop="description">
          <el-input v-model="form.description" type="textarea" placeholder="请输入描述" />
        </el-form-item>
      </el-form>
      <template #footer>
        <el-button @click="dialogVisible = false">取消</el-button>
        <el-button type="primary" @click="handleSubmit">确定</el-button>
      </template>
    </el-dialog>
  </div>
</template>

<script setup lang="ts">
import { ref, reactive, onMounted } from 'vue';
import { ElMessage, ElMessageBox } from 'element-plus';
import type { FormInstance, FormRules } from 'element-plus';
import { departmentApi } from '@/api/department';
import type { Department } from '@/types/department';
import type { PaginationState } from '@/types/pagination';

// 查询条件
const query = reactive({
  name: ''
});

// 分页状态
const page = reactive<PaginationState>({
  current: 1,
  size: 10,
  total: 0
});

// 表格数据
const tableData = ref<Department[]>([]);
const loading = ref(false);

// 对话框状态
const dialogVisible = ref(false);
const dialogTitle = ref('');
const formRef = ref<FormInstance>();
const form = reactive({
  id: undefined as number | undefined,
  name: '',
  description: ''
});

// 表单验证规则
const rules: FormRules = {
  name: [{ required: true, message: '请输入部门名称', trigger: 'blur' }]
};

// 加载数据
const load = async () => {
  loading.value = true;
  try {
    const response = await departmentApi.page({
      current: page.current,
      size: page.size,
      name: query.name || undefined
    });
    tableData.value = response.data.records;
    page.total = response.data.total;
  } catch (error) {
    ElMessage.error('加载数据失败');
  } finally {
    loading.value = false;
  }
};

// 重置查询
const resetQuery = () => {
  query.name = '';
  page.current = 1;
  load();
};

// 打开对话框
const openDialog = (row?: Department) => {
  if (row) {
    dialogTitle.value = '编辑部门';
    Object.assign(form, row);
  } else {
    dialogTitle.value = '新增部门';
    form.id = undefined;
    form.name = '';
    form.description = '';
  }
  dialogVisible.value = true;
};

// 重置表单
const resetForm = () => {
  formRef.value?.resetFields();
};

// 提交表单
const handleSubmit = async () => {
  if (!formRef.value) return;
  await formRef.value.validate(async (valid) => {
    if (valid) {
      try {
        if (form.id) {
          await departmentApi.update(form.id, form);
          ElMessage.success('更新成功');
        } else {
          await departmentApi.add(form);
          ElMessage.success('新增成功');
        }
        dialogVisible.value = false;
        load();
      } catch (error) {
        ElMessage.error('操作失败');
      }
    }
  });
};

// 删除
const handleDelete = async (id: number) => {
  try {
    await ElMessageBox.confirm('确定要删除该部门吗？', '提示', {
      type: 'warning'
    });
    await departmentApi.delete(id);
    ElMessage.success('删除成功');
    load();
  } catch (error) {
    if (error !== 'cancel') {
      ElMessage.error('删除失败');
    }
  }
};

// 页面加载时执行
onMounted(() => {
  load();
});
</script>
```

#### 3.3.2 CategoryManagementView

**文件路径：** `src/views/admin/CategoryManagementView.vue`

```vue
<template>
  <div>
    <div class="page-header">
      <h2 class="page-title">数据分类管理</h2>
      <el-button type="primary" @click="openDialog()">新增分类</el-button>
    </div>
    <el-card>
      <el-form inline class="mb-4">
        <el-form-item label="分类名称">
          <el-input v-model="query.name" placeholder="分类名称" clearable style="width: 200px" />
        </el-form-item>
        <el-form-item>
          <el-button type="primary" @click="load">查询</el-button>
          <el-button @click="resetQuery">重置</el-button>
        </el-form-item>
      </el-form>
      <el-table :data="tableData" stripe v-loading="loading">
        <el-table-column prop="id" label="ID" width="80" />
        <el-table-column prop="name" label="分类名称" />
        <el-table-column prop="description" label="描述" show-overflow-tooltip />
        <el-table-column label="操作" width="150" fixed="right">
          <template #default="{ row }">
            <el-button type="primary" link @click="openDialog(row)">编辑</el-button>
            <el-button type="danger" link @click="handleDelete(row.id)">删除</el-button>
          </template>
        </el-table-column>
      </el-table>
      <!-- 分页组件 -->
      <el-pagination
        v-model:current-page="page.current"
        v-model:page-size="page.size"
        :total="page.total"
        :page-sizes="[10, 20, 50, 100]"
        layout="total, sizes, prev, pager, next, jumper"
        @current-change="load"
        @size-change="load"
        style="margin-top: 16px; justify-content: flex-end"
      />
    </el-card>

    <!-- 新增/编辑对话框 -->
    <el-dialog v-model="dialogVisible" :title="dialogTitle" width="600px" @close="resetForm">
      <el-form :model="form" :rules="rules" ref="formRef" label-width="100px">
        <el-form-item label="分类名称" prop="name">
          <el-input v-model="form.name" placeholder="请输入分类名称" />
        </el-form-item>
        <el-form-item label="描述" prop="description">
          <el-input v-model="form.description" type="textarea" placeholder="请输入描述" />
        </el-form-item>
      </el-form>
      <template #footer>
        <el-button @click="dialogVisible = false">取消</el-button>
        <el-button type="primary" @click="handleSubmit">确定</el-button>
      </template>
    </el-dialog>
  </div>
</template>

<script setup lang="ts">
import { ref, reactive, onMounted } from 'vue';
import { ElMessage, ElMessageBox } from 'element-plus';
import type { FormInstance, FormRules } from 'element-plus';
import { categoryApi } from '@/api/category';
import type { DataCategory } from '@/types/category';
import type { PaginationState } from '@/types/pagination';

// 查询条件
const query = reactive({
  name: ''
});

// 分页状态
const page = reactive<PaginationState>({
  current: 1,
  size: 10,
  total: 0
});

// 表格数据
const tableData = ref<DataCategory[]>([]);
const loading = ref(false);

// 对话框状态
const dialogVisible = ref(false);
const dialogTitle = ref('');
const formRef = ref<FormInstance>();
const form = reactive({
  id: undefined as number | undefined,
  name: '',
  description: ''
});

// 表单验证规则
const rules: FormRules = {
  name: [{ required: true, message: '请输入分类名称', trigger: 'blur' }]
};

// 加载数据
const load = async () => {
  loading.value = true;
  try {
    const response = await categoryApi.page({
      current: page.current,
      size: page.size,
      name: query.name || undefined
    });
    tableData.value = response.data.records;
    page.total = response.data.total;
  } catch (error) {
    ElMessage.error('加载数据失败');
  } finally {
    loading.value = false;
  }
};

// 重置查询
const resetQuery = () => {
  query.name = '';
  page.current = 1;
  load();
};

// 打开对话框
const openDialog = (row?: DataCategory) => {
  if (row) {
    dialogTitle.value = '编辑分类';
    Object.assign(form, row);
  } else {
    dialogTitle.value = '新增分类';
    form.id = undefined;
    form.name = '';
    form.description = '';
  }
  dialogVisible.value = true;
};

// 重置表单
const resetForm = () => {
  formRef.value?.resetFields();
};

// 提交表单
const handleSubmit = async () => {
  if (!formRef.value) return;
  await formRef.value.validate(async (valid) => {
    if (valid) {
      try {
        if (form.id) {
          await categoryApi.update(form.id, form);
          ElMessage.success('更新成功');
        } else {
          await categoryApi.add(form);
          ElMessage.success('新增成功');
        }
        dialogVisible.value = false;
        load();
      } catch (error) {
        ElMessage.error('操作失败');
      }
    }
  });
};

// 删除
const handleDelete = async (id: number) => {
  try {
    await ElMessageBox.confirm('确定要删除该分类吗？', '提示', {
      type: 'warning'
    });
    await categoryApi.delete(id);
    ElMessage.success('删除成功');
    load();
  } catch (error) {
    if (error !== 'cancel') {
      ElMessage.error('删除失败');
    }
  }
};

// 页面加载时执行
onMounted(() => {
  load();
});
</script>
```

#### 3.3.3 RuleManagementView

**文件路径：** `src/views/admin/RuleManagementView.vue`

```vue
<template>
  <div>
    <div class="page-header">
      <h2 class="page-title">预警规则管理</h2>
      <el-button type="primary" @click="openDialog()">新增规则</el-button>
    </div>
    <el-card>
      <el-form inline class="mb-4">
        <el-form-item label="规则类型">
          <el-select v-model="query.ruleType" placeholder="规则类型" clearable style="width: 150px">
            <el-option label="流失预警" value="TURNOVER_WARNING" />
            <el-option label="薪酬竞争力" value="COMPENSATION_BENCHMARK" />
            <el-option label="培训ROI" value="TRAINING_ROI" />
            <el-option label="绩效评估" value="PERFORMANCE_EVAL" />
            <el-option label="人才缺口" value="TALENT_GAP" />
          </el-select>
        </el-form-item>
        <el-form-item label="生效状态">
          <el-select v-model="query.isActive" placeholder="生效状态" clearable style="width: 120px">
            <el-option label="已生效" :value="true" />
            <el-option label="未生效" :value="false" />
          </el-select>
        </el-form-item>
        <el-form-item>
          <el-button type="primary" @click="load">查询</el-button>
          <el-button @click="resetQuery">重置</el-button>
        </el-form-item>
      </el-form>
      <el-table :data="tableData" stripe v-loading="loading">
        <el-table-column prop="id" label="ID" width="80" />
        <el-table-column prop="ruleName" label="规则名称" />
        <el-table-column prop="ruleType" label="规则类型">
          <template #default="{ row }">
            <el-tag>{{ getRuleTypeName(row.ruleType) }}</el-tag>
          </template>
        </el-table-column>
        <el-table-column prop="isActive" label="生效状态" width="100">
          <template #default="{ row }">
            <el-tag :type="row.isActive ? 'success' : 'info'">
              {{ row.isActive ? '已生效' : '未生效' }}
            </el-tag>
          </template>
        </el-table-column>
        <el-table-column prop="createdTime" label="创建时间" width="180" />
        <el-table-column label="操作" width="150" fixed="right">
          <template #default="{ row }">
            <el-button type="primary" link @click="openDialog(row)">编辑</el-button>
            <el-button type="danger" link @click="handleDelete(row.id)">删除</el-button>
          </template>
        </el-table-column>
      </el-table>
      <!-- 分页组件 -->
      <el-pagination
        v-model:current-page="page.current"
        v-model:page-size="page.size"
        :total="page.total"
        :page-sizes="[10, 20, 50, 100]"
        layout="total, sizes, prev, pager, next, jumper"
        @current-change="load"
        @size-change="load"
        style="margin-top: 16px; justify-content: flex-end"
      />
    </el-card>

    <!-- 新增/编辑对话框 -->
    <el-dialog v-model="dialogVisible" :title="dialogTitle" width="600px" @close="resetForm">
      <el-form :model="form" :rules="rules" ref="formRef" label-width="100px">
        <el-form-item label="规则名称" prop="ruleName">
          <el-input v-model="form.ruleName" placeholder="请输入规则名称" />
        </el-form-item>
        <el-form-item label="规则类型" prop="ruleType">
          <el-select v-model="form.ruleType" placeholder="请选择规则类型" style="width: 100%">
            <el-option label="流失预警" value="TURNOVER_WARNING" />
            <el-option label="薪酬竞争力" value="COMPENSATION_BENCHMARK" />
            <el-option label="培训ROI" value="TRAINING_ROI" />
            <el-option label="绩效评估" value="PERFORMANCE_EVAL" />
            <el-option label="人才缺口" value="TALENT_GAP" />
          </el-select>
        </el-form-item>
        <el-form-item label="生效状态" prop="isActive">
          <el-switch v-model="form.isActive" />
        </el-form-item>
      </el-form>
      <template #footer>
        <el-button @click="dialogVisible = false">取消</el-button>
        <el-button type="primary" @click="handleSubmit">确定</el-button>
      </template>
    </el-dialog>
  </div>
</template>

<script setup lang="ts">
import { ref, reactive, onMounted } from 'vue';
import { ElMessage, ElMessageBox } from 'element-plus';
import type { FormInstance, FormRules } from 'element-plus';
import { ruleApi } from '@/api/rule';
import type { WarningRule } from '@/types/rule';
import type { PaginationState } from '@/types/pagination';

// 查询条件
const query = reactive({
  ruleType: '',
  isActive: undefined as boolean | undefined
});

// 分页状态
const page = reactive<PaginationState>({
  current: 1,
  size: 10,
  total: 0
});

// 表格数据
const tableData = ref<WarningRule[]>([]);
const loading = ref(false);

// 对话框状态
const dialogVisible = ref(false);
const dialogTitle = ref('');
const formRef = ref<FormInstance>();
const form = reactive({
  id: undefined as number | undefined,
  ruleName: '',
  ruleType: '',
  isActive: false
});

// 表单验证规则
const rules: FormRules = {
  ruleName: [{ required: true, message: '请输入规则名称', trigger: 'blur' }],
  ruleType: [{ required: true, message: '请选择规则类型', trigger: 'change' }]
};

// 规则类型名称映射
const getRuleTypeName = (type: string) => {
  const map: Record<string, string> = {
    'TURNOVER_WARNING': '流失预警',
    'COMPENSATION_BENCHMARK': '薪酬竞争力',
    'TRAINING_ROI': '培训ROI',
    'PERFORMANCE_EVAL': '绩效评估',
    'TALENT_GAP': '人才缺口'
  };
  return map[type] || type;
};

// 加载数据
const load = async () => {
  loading.value = true;
  try {
    const response = await ruleApi.page({
      current: page.current,
      size: page.size,
      ruleType: query.ruleType || undefined,
      isActive: query.isActive
    });
    tableData.value = response.data.records;
    page.total = response.data.total;
  } catch (error) {
    ElMessage.error('加载数据失败');
  } finally {
    loading.value = false;
  }
};

// 重置查询
const resetQuery = () => {
  query.ruleType = '';
  query.isActive = undefined;
  page.current = 1;
  load();
};

// 打开对话框
const openDialog = (row?: WarningRule) => {
  if (row) {
    dialogTitle.value = '编辑规则';
    Object.assign(form, row);
  } else {
    dialogTitle.value = '新增规则';
    form.id = undefined;
    form.ruleName = '';
    form.ruleType = '';
    form.isActive = false;
  }
  dialogVisible.value = true;
};

// 重置表单
const resetForm = () => {
  formRef.value?.resetFields();
};

// 提交表单
const handleSubmit = async () => {
  if (!formRef.value) return;
  await formRef.value.validate(async (valid) => {
    if (valid) {
      try {
        if (form.id) {
          await ruleApi.update(form.id, form);
          ElMessage.success('更新成功');
        } else {
          await ruleApi.add(form);
          ElMessage.success('新增成功');
        }
        dialogVisible.value = false;
        load();
      } catch (error) {
        ElMessage.error('操作失败');
      }
    }
  });
};

// 删除
const handleDelete = async (id: number) => {
  try {
    await ElMessageBox.confirm('确定要删除该规则吗？', '提示', {
      type: 'warning'
    });
    await ruleApi.delete(id);
    ElMessage.success('删除成功');
    load();
  } catch (error) {
    if (error !== 'cancel') {
      ElMessage.error('删除失败');
    }
  }
};

// 页面加载时执行
onMounted(() => {
  load();
});
</script>
```

#### 3.3.4 ReportManagementView

**文件路径：** `src/views/admin/ReportManagementView.vue`

```vue
<template>
  <div>
    <div class="page-header">
      <h2 class="page-title">报表模板管理</h2>
      <el-button type="primary" @click="openDialog()">新增报表</el-button>
    </div>
    <el-card>
      <el-form inline class="mb-4">
        <el-form-item label="报表分类">
          <el-select v-model="query.category" placeholder="报表分类" clearable style="width: 150px">
            <el-option label="薪酬分析" value="COMPENSATION" />
            <el-option label="绩效管理" value="PERFORMANCE" />
            <el-option label="流失预警" value="TURNOVER" />
            <el-option label="培训效果" value="TRAINING" />
            <el-option label="人力成本" value="COST" />
          </el-select>
        </el-form-item>
        <el-form-item label="报表名称">
          <el-input v-model="query.name" placeholder="报表名称" clearable style="width: 200px" />
        </el-form-item>
        <el-form-item>
          <el-button type="primary" @click="load">查询</el-button>
          <el-button @click="resetQuery">重置</el-button>
        </el-form-item>
      </el-form>
      <el-table :data="tableData" stripe v-loading="loading">
        <el-table-column prop="id" label="ID" width="80" />
        <el-table-column prop="name" label="报表名称" />
        <el-table-column prop="category" label="报表分类">
          <template #default="{ row }">
            <el-tag>{{ getCategoryName(row.category) }}</el-tag>
          </template>
        </el-table-column>
        <el-table-column prop="description" label="描述" show-overflow-tooltip />
        <el-table-column prop="createdTime" label="创建时间" width="180" />
        <el-table-column label="操作" width="150" fixed="right">
          <template #default="{ row }">
            <el-button type="primary" link @click="openDialog(row)">编辑</el-button>
            <el-button type="danger" link @click="handleDelete(row.id)">删除</el-button>
          </template>
        </el-table-column>
      </el-table>
      <!-- 分页组件 -->
      <el-pagination
        v-model:current-page="page.current"
        v-model:page-size="page.size"
        :total="page.total"
        :page-sizes="[10, 20, 50, 100]"
        layout="total, sizes, prev, pager, next, jumper"
        @current-change="load"
        @size-change="load"
        style="margin-top: 16px; justify-content: flex-end"
      />
    </el-card>

    <!-- 新增/编辑对话框 -->
    <el-dialog v-model="dialogVisible" :title="dialogTitle" width="600px" @close="resetForm">
      <el-form :model="form" :rules="rules" ref="formRef" label-width="100px">
        <el-form-item label="报表名称" prop="name">
          <el-input v-model="form.name" placeholder="请输入报表名称" />
        </el-form-item>
        <el-form-item label="报表分类" prop="category">
          <el-select v-model="form.category" placeholder="请选择报表分类" style="width: 100%">
            <el-option label="薪酬分析" value="COMPENSATION" />
            <el-option label="绩效管理" value="PERFORMANCE" />
            <el-option label="流失预警" value="TURNOVER" />
            <el-option label="培训效果" value="TRAINING" />
            <el-option label="人力成本" value="COST" />
          </el-select>
        </el-form-item>
        <el-form-item label="描述" prop="description">
          <el-input v-model="form.description" type="textarea" placeholder="请输入描述" />
        </el-form-item>
      </el-form>
      <template #footer>
        <el-button @click="dialogVisible = false">取消</el-button>
        <el-button type="primary" @click="handleSubmit">确定</el-button>
      </template>
    </el-dialog>
  </div>
</template>

<script setup lang="ts">
import { ref, reactive, onMounted } from 'vue';
import { ElMessage, ElMessageBox } from 'element-plus';
import type { FormInstance, FormRules } from 'element-plus';
import { reportApi } from '@/api/report';
import type { ReportTemplate } from '@/types/report';
import type { PaginationState } from '@/types/pagination';

// 查询条件
const query = reactive({
  category: '',
  name: ''
});

// 分页状态
const page = reactive<PaginationState>({
  current: 1,
  size: 10,
  total: 0
});

// 表格数据
const tableData = ref<ReportTemplate[]>([]);
const loading = ref(false);

// 对话框状态
const dialogVisible = ref(false);
const dialogTitle = ref('');
const formRef = ref<FormInstance>();
const form = reactive({
  id: undefined as number | undefined,
  name: '',
  category: '',
  description: ''
});

// 表单验证规则
const rules: FormRules = {
  name: [{ required: true, message: '请输入报表名称', trigger: 'blur' }],
  category: [{ required: true, message: '请选择报表分类', trigger: 'change' }]
};

// 报表分类名称映射
const getCategoryName = (category: string) => {
  const map: Record<string, string> = {
    'COMPENSATION': '薪酬分析',
    'PERFORMANCE': '绩效管理',
    'TURNOVER': '流失预警',
    'TRAINING': '培训效果',
    'COST': '人力成本'
  };
  return map[category] || category;
};

// 加载数据
const load = async () => {
  loading.value = true;
  try {
    const response = await reportApi.page({
      current: page.current,
      size: page.size,
      category: query.category || undefined,
      name: query.name || undefined
    });
    tableData.value = response.data.records;
    page.total = response.data.total;
  } catch (error) {
    ElMessage.error('加载数据失败');
  } finally {
    loading.value = false;
  }
};

// 重置查询
const resetQuery = () => {
  query.category = '';
  query.name = '';
  page.current = 1;
  load();
};

// 打开对话框
const openDialog = (row?: ReportTemplate) => {
  if (row) {
    dialogTitle.value = '编辑报表';
    Object.assign(form, row);
  } else {
    dialogTitle.value = '新增报表';
    form.id = undefined;
    form.name = '';
    form.category = '';
    form.description = '';
  }
  dialogVisible.value = true;
};

// 重置表单
const resetForm = () => {
  formRef.value?.resetFields();
};

// 提交表单
const handleSubmit = async () => {
  if (!formRef.value) return;
  await formRef.value.validate(async (valid) => {
    if (valid) {
      try {
        if (form.id) {
          await reportApi.update(form.id, form);
          ElMessage.success('更新成功');
        } else {
          await reportApi.add(form);
          ElMessage.success('新增成功');
        }
        dialogVisible.value = false;
        load();
      } catch (error) {
        ElMessage.error('操作失败');
      }
    }
  });
};

// 删除
const handleDelete = async (id: number) => {
  try {
    await ElMessageBox.confirm('确定要删除该报表吗？', '提示', {
      type: 'warning'
    });
    await reportApi.delete(id);
    ElMessage.success('删除成功');
    load();
  } catch (error) {
    if (error !== 'cancel') {
      ElMessage.error('删除失败');
    }
  }
};

// 页面加载时执行
onMounted(() => {
  load();
});
</script>
```

#### 3.3.5 MyFavoritesView

**文件路径：** `src/views/MyFavoritesView.vue`

```vue
<template>
  <div>
    <div class="page-header">
      <h2 class="page-title">我的收藏</h2>
    </div>
    <el-card>
      <el-form inline class="mb-4">
        <el-form-item label="收藏类型">
          <el-select v-model="query.favType" placeholder="收藏类型" clearable style="width: 150px">
            <el-option label="报表" value="REPORT" />
            <el-option label="数据分析" value="ANALYSIS" />
            <el-option label="图表" value="CHART" />
          </el-select>
        </el-form-item>
        <el-form-item>
          <el-button type="primary" @click="load">查询</el-button>
          <el-button @click="resetQuery">重置</el-button>
        </el-form-item>
      </el-form>
      <el-table :data="tableData" stripe v-loading="loading">
        <el-table-column prop="id" label="ID" width="80" />
        <el-table-column prop="favType" label="收藏类型">
          <template #default="{ row }">
            <el-tag>{{ getFavTypeName(row.favType) }}</el-tag>
          </template>
        </el-table-column>
        <el-table-column prop="favName" label="收藏名称" />
        <el-table-column prop="favUrl" label="收藏链接" show-overflow-tooltip />
        <el-table-column prop="createdTime" label="收藏时间" width="180" />
        <el-table-column label="操作" width="100" fixed="right">
          <template #default="{ row }">
            <el-button type="danger" link @click="handleDelete(row.id)">取消收藏</el-button>
          </template>
        </el-table-column>
      </el-table>
      <!-- 分页组件 -->
      <el-pagination
        v-model:current-page="page.current"
        v-model:page-size="page.size"
        :total="page.total"
        :page-sizes="[10, 20, 50, 100]"
        layout="total, sizes, prev, pager, next, jumper"
        @current-change="load"
        @size-change="load"
        style="margin-top: 16px; justify-content: flex-end"
      />
    </el-card>
  </div>
</template>

<script setup lang="ts">
import { ref, reactive, onMounted } from 'vue';
import { ElMessage, ElMessageBox } from 'element-plus';
import { favoriteApi } from '@/api/favorite';
import type { Favorite } from '@/types/favorite';
import type { PaginationState } from '@/types/pagination';

// 查询条件
const query = reactive({
  favType: ''
});

// 分页状态
const page = reactive<PaginationState>({
  current: 1,
  size: 10,
  total: 0
});

// 表格数据
const tableData = ref<Favorite[]>([]);
const loading = ref(false);

// 收藏类型名称映射
const getFavTypeName = (type: string) => {
  const map: Record<string, string> = {
    'REPORT': '报表',
    'ANALYSIS': '数据分析',
    'CHART': '图表'
  };
  return map[type] || type;
};

// 加载数据
const load = async () => {
  loading.value = true;
  try {
    const response = await favoriteApi.page({
      current: page.current,
      size: page.size,
      favType: query.favType || undefined
    });
    tableData.value = response.data.records;
    page.total = response.data.total;
  } catch (error) {
    ElMessage.error('加载数据失败');
  } finally {
    loading.value = false;
  }
};

// 重置查询
const resetQuery = () => {
  query.favType = '';
  page.current = 1;
  load();
};

// 取消收藏
const handleDelete = async (id: number) => {
  try {
    await ElMessageBox.confirm('确定要取消收藏吗？', '提示', {
      type: 'warning'
    });
    await favoriteApi.delete(id);
    ElMessage.success('已取消收藏');
    load();
  } catch (error) {
    if (error !== 'cancel') {
      ElMessage.error('操作失败');
    }
  }
};

// 页面加载时执行
onMounted(() => {
  load();
});
</script>
```

### 3.4 API层设计

为每个模块添加分页查询的API方法。

#### 3.4.1 department.ts

**文件路径：** `src/api/department.ts`

```typescript
import request from '@/utils/request';
import type { Department } from '@/types/department';
import type { PageQuery, PageResponse } from '@/types/pagination';

/**
 * 部门API
 */
export const departmentApi = {
  /**
   * 分页查询部门列表
   */
  page(params: PageQuery & { name?: string }) {
    return request<PageResponse<Department>>({
      url: '/api/department/page',
      method: 'GET',
      params
    });
  },

  /**
   * 获取所有部门列表
   */
  list() {
    return request<Department[]>({
      url: '/api/department/list',
      method: 'GET'
    });
  },

  // ... 其他现有方法保持不变
};
```

#### 3.4.2 category.ts

**文件路径：** `src/api/category.ts`

```typescript
import request from '@/utils/request';
import type { DataCategory } from '@/types/category';
import type { PageQuery, PageResponse } from '@/types/pagination';

/**
 * 数据分类API
 */
export const categoryApi = {
  /**
   * 分页查询数据分类列表
   */
  page(params: PageQuery & { name?: string }) {
    return request<PageResponse<DataCategory>>({
      url: '/api/category/page',
      method: 'GET',
      params
    });
  },

  /**
   * 获取所有数据分类列表
   */
  list() {
    return request<DataCategory[]>({
      url: '/api/category/list',
      method: 'GET'
    });
  },

  // ... 其他现有方法保持不变
};
```

#### 3.4.3 rule.ts

**文件路径：** `src/api/rule.ts`

```typescript
import request from '@/utils/request';
import type { WarningRule } from '@/types/rule';
import type { PageQuery, PageResponse } from '@/types/pagination';

/**
 * 预警规则API
 */
export const ruleApi = {
  /**
   * 分页查询预警规则列表
   */
  page(params: PageQuery & { ruleType?: string; isActive?: boolean }) {
    return request<PageResponse<WarningRule>>({
      url: '/api/rule/page',
      method: 'GET',
      params
    });
  },

  // ... 其他现有方法保持不变
};
```

#### 3.4.4 report.ts

**文件路径：** `src/api/report.ts`

```typescript
import request from '@/utils/request';
import type { ReportTemplate } from '@/types/report';
import type { PageQuery, PageResponse } from '@/types/pagination';

/**
 * 报表模板API
 */
export const reportApi = {
  /**
   * 分页查询报表模板列表
   */
  page(params: PageQuery & { category?: string; name?: string }) {
    return request<PageResponse<ReportTemplate>>({
      url: '/api/report/page',
      method: 'GET',
      params
    });
  },

  // ... 其他现有方法保持不变
};
```

#### 3.4.5 favorite.ts

**文件路径：** `src/api/favorite.ts`

```typescript
import request from '@/utils/request';
import type { Favorite } from '@/types/favorite';
import type { PageQuery, PageResponse } from '@/types/pagination';

/**
 * 收藏API
 */
export const favoriteApi = {
  /**
   * 分页查询当前用户的收藏列表
   */
  page(params: PageQuery & { favType?: string }) {
    return request<PageResponse<Favorite>>({
      url: '/api/favorite/page',
      method: 'GET',
      params
    });
  },

  // ... 其他现有方法保持不变
};
```

**类型安全说明：**
- 使用 TypeScript 泛型确保返回类型正确
- 使用交叉类型 `PageQuery & { ... }` 扩展分页参数
- 所有API方法都有明确的类型注解

---

## 4. 接口设计

### 4.1 统一接口规范

所有分页接口遵循以下规范：

**请求规范：**
- 方法：`GET`
- 路径：`/api/{entity}/page`
- 参数：`current`（页码）、`size`（每页条数）、筛选条件（可选）

**响应规范：**
- 格式：`Response<IPage<T>>`
- 字段：`records`（数据列表）、`total`（总记录数）、`size`（每页条数）、`current`（当前页）、`pages`（总页数）

### 4.2 接口列表

| 接口名称 | 请求路径 | 请求参数 | 响应类型 | 权限要求 |
|---------|---------|---------|---------|---------|
| 部门分页查询 | GET /api/department/page | current, size, name | IPage<Department> | HR_ADMIN |
| 数据分类分页查询 | GET /api/category/page | current, size, name | IPage<DataCategory> | HR_ADMIN |
| 预警规则分页查询 | GET /api/rule/page | current, size, ruleType, isActive | IPage<WarningRule> | HR_ADMIN |
| 报表模板分页查询 | GET /api/report/page | current, size, category, name | IPage<ReportTemplate> | HR_ADMIN |
| 收藏分页查询 | GET /api/favorite/page | current, size, favType | IPage<Favorite> | 已登录用户 |

### 4.3 接口示例

#### 4.3.1 部门分页查询

**请求示例：**
```http
GET /api/department/page?current=1&size=10&name=技术
Authorization: Bearer eyJhbGciOiJIUzI1NiJ9...
```

**响应示例：**
```json
{
  "code": 200,
  "message": "success",
  "data": {
    "records": [
      {
        "id": 1,
        "name": "技术部",
        "description": "负责技术研发工作"
      },
      {
        "id": 2,
        "name": "技术研发中心",
        "description": "负责核心技术研发"
      }
    ],
    "total": 2,
    "size": 10,
    "current": 1,
    "pages": 1
  }
}
```

#### 4.3.2 收藏分页查询

**请求示例：**
```http
GET /api/favorite/page?current=1&size=10&favType=REPORT
Authorization: Bearer eyJhbGciOiJIUzI1NiJ9...
```

**响应示例：**
```json
{
  "code": 200,
  "message": "success",
  "data": {
    "records": [
      {
        "id": 1,
        "userId": 1001,
        "favType": "REPORT",
        "favName": "薪酬分析月报",
        "favUrl": "/report/compensation/monthly",
        "createdTime": "2025-03-25 10:30:00"
      }
    ],
    "total": 1,
    "size": 10,
    "current": 1,
    "pages": 1
  }
}
```

---

## 5. 数据流设计

### 5.1 分页查询数据流

```mermaid
sequenceDiagram
    participant User as 用户
    participant UI as Vue组件
    participant API as API层
    participant Controller as Controller层
    participant Service as Service层
    participant Plugin as 分页插件
    participant DB as MySQL数据库

    User->>UI: 点击分页组件
    UI->>UI: 更新分页状态
    UI->>API: 调用page方法
    API->>Controller: 发送HTTP请求
    Controller->>Service: 调用page方法
    Service->>Service: 构建QueryWrapper
    Service->>Plugin: 执行分页查询
    Plugin->>DB: 执行SQL (LIMIT/OFFSET)
    DB->>Plugin: 返回查询结果
    Plugin->>Service: 返回IPage对象
    Service->>Controller: 返回IPage对象
    Controller->>API: 返回JSON响应
    API->>UI: 返回分页数据
    UI->>UI: 更新表格数据
    UI->>User: 显示新页面数据
```

### 5.2 筛选查询数据流

```mermaid
sequenceDiagram
    participant User as 用户
    participant UI as Vue组件
    participant API as API层
    participant Controller as Controller层
    participant Service as Service层
    participant Plugin as 分页插件
    participant DB as MySQL数据库

    User->>UI: 输入筛选条件
    User->>UI: 点击查询按钮
    UI->>UI: 重置页码为1
    UI->>API: 调用page方法(带筛选参数)
    API->>Controller: 发送HTTP请求
    Controller->>Service: 调用page方法
    Service->>Service: 构建QueryWrapper(带筛选条件)
    Service->>Plugin: 执行分页查询
    Plugin->>DB: 执行SQL (WHERE + LIMIT/OFFSET)
    DB->>Plugin: 返回筛选后的结果
    Plugin->>Service: 返回IPage对象
    Service->>Controller: 返回IPage对象
    Controller->>API: 返回JSON响应
    API->>UI: 返回分页数据
    UI->>UI: 更新表格数据
    UI->>User: 显示筛选结果
```

---

## 6. 异常处理设计

### 6.1 后端异常处理

#### 6.1.1 参数校验异常

**场景：** 分页参数不合法（current < 1 或 size < 1）

**处理方式：**
```java
// 在Controller层添加参数校验
@GetMapping("/page")
public Response<IPage<Department>> page(
        @RequestParam(defaultValue = "1") Long current,
        @RequestParam(defaultValue = "10") Long size,
        @RequestParam(required = false) String name) {
    // 校验参数
    if (current < 1) current = 1L;
    if (size < 1) size = 10L;
    if (size > 100) size = 100L;

    Page<Department> page = new Page<>(current, size);
    IPage<Department> result = departmentService.page(page, name);
    return Response.success(result);
}
```

#### 6.1.2 SQL注入防护

**场景：** 用户输入包含SQL注入字符

**处理方式：**
- MyBatis-Plus的 `LambdaQueryWrapper` 自动进行参数化查询，防止SQL注入
- 不使用字符串拼接SQL，使用预编译语句

#### 6.1.3 未授权访问

**场景：** 未登录用户访问需要认证的接口

**处理方式：**
- Spring Security自动拦截未授权请求
- 返回401状态码，前端跳转到登录页面

### 6.2 前端异常处理

#### 6.2.1 网络请求异常

**场景：** 网络请求失败或服务器错误

**处理方式：**
```typescript
const load = async () => {
  loading.value = true;
  try {
    const response = await departmentApi.page({
      current: page.current,
      size: page.size,
      name: query.name || undefined
    });
    tableData.value = response.data.records;
    page.total = response.data.total;
  } catch (error) {
    ElMessage.error('加载数据失败');
  } finally {
    loading.value = false;
  }
};
```

#### 6.2.2 数据为空异常

**场景：** 查询结果为空

**处理方式：**
- 在表格中显示"暂无数据"提示
- 不显示错误消息，正常显示空状态

---

## 7. 性能优化设计

### 7.1 数据库优化

#### 7.1.1 索引优化

为常用的筛选字段和排序字段添加索引，提升查询性能：

```sql
-- 预警规则表索引
CREATE INDEX idx_warning_rule_type_status ON warning_rule(rule_type, is_active);
CREATE INDEX idx_warning_rule_created_time ON warning_rule(created_time);

-- 收藏表索引
CREATE INDEX idx_favorite_user_type ON sys_favorite(user_id, fav_type);
CREATE INDEX idx_favorite_created_time ON sys_favorite(created_time);
```

#### 7.1.2 查询优化

- 使用 `LIMIT` 和 `OFFSET` 实现数据库分页
- 避免使用 `SELECT *`，只查询需要的字段
- 使用 `EXPLAIN` 分析SQL执行计划

### 7.2 应用层优化

#### 7.2.1 缓存策略

对于高频访问且变化不频繁的数据，可以考虑使用缓存：

```java
@Service
@CacheConfig(cacheNames = "department")
public class DepartmentServiceImpl extends ServiceImpl<DepartmentMapper, Department>
        implements DepartmentService {

    @Override
    @Cacheable(key = "#page.current + '-' + #page.size + '-' + #name")
    public IPage<Department> page(Page<Department> page, String name) {
        // 实现逻辑
    }
}
```

#### 7.2.2 分页参数限制

- 限制每页最大条数为100，防止一次性加载过多数据
- 使用MyBatis-Plus分页插件的 `setMaxLimit` 方法

### 7.3 前端优化

#### 7.3.1 防抖处理

对于筛选条件的输入，添加防抖处理，避免频繁请求：

```typescript
import { debounce } from 'lodash-es';

const load = debounce(async () => {
  loading.value = true;
  try {
    const response = await departmentApi.page({
      current: page.current,
      size: page.size,
      name: query.name || undefined
    });
    tableData.value = response.data.records;
    page.total = response.data.total;
  } catch (error) {
    ElMessage.error('加载数据失败');
  } finally {
    loading.value = false;
  }
}, 300);
```

#### 7.3.2 虚拟滚动

对于大数据量场景，可以考虑使用虚拟滚动技术：

```vue
<el-table-v2
  :columns="columns"
  :data="tableData"
  :width="700"
  :height="400"
  :row-height="50"
/>
```

---

## 8. 安全设计

### 8.1 认证与授权

#### 8.1.1 JWT认证

所有分页接口都需要JWT认证：

```java
@GetMapping("/page")
@PreAuthorize("isAuthenticated()")
public Response<IPage<Department>> page(...) {
    // 实现逻辑
}
```

#### 8.1.2 角色权限控制

根据接口的敏感程度，设置不同的角色权限：

```java
// 部门管理需要HR_ADMIN角色
@PreAuthorize("hasRole('HR_ADMIN')")
public Response<IPage<Department>> page(...) {
    // 实现逻辑
}

// 收藏管理只需要登录
public Response<IPage<Favorite>> page(...) {
    // 实现逻辑
}
```

### 8.2 数据隔离

#### 8.2.1 用户数据隔离

对于收藏等个人数据，必须按用户ID过滤：

```java
@Override
public IPage<Favorite> pageByUser(Page<Favorite> page, Long userId, String favType) {
    LambdaQueryWrapper<Favorite> wrapper = new LambdaQueryWrapper<>();
    wrapper.eq(Favorite::getUserId, userId);  // 必须按用户ID过滤
    if (StringUtils.isNotBlank(favType)) {
        wrapper.eq(Favorite::getFavType, favType);
    }
    wrapper.orderByDesc(Favorite::getCreatedTime);
    return this.page(page, wrapper);
}
```

#### 8.2.2 参数化查询

使用MyBatis-Plus的 `LambdaQueryWrapper` 进行参数化查询，防止SQL注入：

```java
// 安全的方式（推荐）
LambdaQueryWrapper<Department> wrapper = new LambdaQueryWrapper<>();
wrapper.like(Department::getName, name);  // 参数化查询

// 不安全的方式（禁止）
String sql = "SELECT * FROM department WHERE name LIKE '%" + name + "%'";
```

### 8.3 输入验证

#### 8.3.1 参数校验

在Controller层添加参数校验：

```java
@GetMapping("/page")
public Response<IPage<Department>> page(
        @RequestParam(defaultValue = "1") Long current,
        @RequestParam(defaultValue = "10") Long size,
        @RequestParam(required = false) String name) {
    // 校验参数
    if (current < 1) current = 1L;
    if (size < 1) size = 10L;
    if (size > 100) size = 100L;

    // 实现逻辑
}
```

#### 8.3.2 前端输入验证

在前端添加输入验证：

```vue
<el-form :model="query" :rules="rules" ref="queryFormRef">
  <el-form-item label="部门名称" prop="name">
    <el-input
      v-model="query.name"
      placeholder="部门名称"
      clearable
      maxlength="50"
      show-word-limit
    />
  </el-form-item>
</el-form>

<script setup lang="ts">
const rules = {
  name: [
    { max: 50, message: '部门名称不能超过50个字符', trigger: 'blur' }
  ]
};
</script>
```

---

## 9. 测试设计

### 9.1 后端测试

#### 9.1.1 单元测试

为每个Service的分页方法编写单元测试：

```java
@SpringBootTest
public class DepartmentServiceTest {

    @Resource
    private DepartmentService departmentService;

    @Test
    public void testPage() {
        Page<Department> page = new Page<>(1, 10);
        IPage<Department> result = departmentService.page(page, "技术");
        assertNotNull(result);
        assertTrue(result.getRecords().size() <= 10);
    }

    @Test
    public void testPageWithInvalidParams() {
        Page<Department> page = new Page<>(0, 0);
        IPage<Department> result = departmentService.page(page, null);
        assertNotNull(result);
        assertEquals(1, result.getCurrent());  // 应该自动修正为1
        assertEquals(10, result.getSize());    // 应该自动修正为10
    }
}
```

#### 9.1.2 集成测试

为每个Controller的分页接口编写集成测试：

```java
@SpringBootTest
@AutoConfigureMockMvc
public class DepartmentControllerTest {

    @Resource
    private MockMvc mockMvc;

    @Test
    @WithMockUser(username = "admin", roles = {"HR_ADMIN"})
    public void testPage() throws Exception {
        mockMvc.perform(get("/api/department/page")
                .param("current", "1")
                .param("size", "10")
                .param("name", "技术"))
                .andExpect(status().isOk())
                .andExpect(jsonPath("$.code").value(200))
                .andExpect(jsonPath("$.data.records").isArray());
    }
}
```

### 9.2 前端测试

#### 9.2.1 组件测试

为分页组件编写单元测试：

```typescript
import { mount } from '@vue/test-utils';
import { describe, it, expect } from 'vitest';
import PaginationComponent from '@/components/PaginationComponent.vue';

describe('PaginationComponent', () => {
  it('renders correctly', () => {
    const wrapper = mount(PaginationComponent, {
      props: {
        modelValue: { current: 1, size: 10, total: 100 }
      }
    });
    expect(wrapper.find('.el-pagination').exists()).toBe(true);
  });

  it('emits change event when page changes', async () => {
    const wrapper = mount(PaginationComponent, {
      props: {
        modelValue: { current: 1, size: 10, total: 100 }
      }
    });
    await wrapper.vm.handleCurrentChange();
    expect(wrapper.emitted('change')).toBeTruthy();
  });
});
```

#### 9.2.2 E2E测试

使用Playwright编写端到端测试：

```typescript
import { test, expect } from '@playwright/test';

test('department pagination', async ({ page }) => {
  await page.goto('http://localhost:5173/admin/department');
  await page.waitForLoadState('networkidle');

  // 检查分页组件是否存在
  await expect(page.locator('.el-pagination')).toBeVisible();

  // 点击下一页
  await page.locator('.el-pagination button:has-text("下一页")').click();
  await page.waitForLoadState('networkidle');

  // 检查数据是否更新
  await expect(page.locator('.el-table tbody tr')).toHaveCount(10);
});
```

---

## 10. 部署设计

### 10.1 后端部署

#### 10.1.1 配置文件

在 `application.yml` 中配置MyBatis-Plus：

```yaml
mybatis-plus:
  configuration:
    # 开启下划线转驼峰
    map-underscore-to-camel-case: true
    # 开启缓存
    cache-enabled: true
  global-config:
    db-config:
      # 主键类型
      id-type: auto
      # 逻辑删除字段
      logic-delete-field: deleted
      logic-delete-value: 1
      logic-not-delete-value: 0
```

#### 10.1.2 数据库迁移

执行以下SQL脚本创建索引：

```sql
-- 部门表索引
CREATE INDEX idx_department_name ON hr_department(name);

-- 数据分类表索引
CREATE INDEX idx_data_category_name ON hr_data_category(name);

-- 预警规则表索引
CREATE INDEX idx_warning_rule_type_status ON warning_rule(rule_type, is_active);
CREATE INDEX idx_warning_rule_created_time ON warning_rule(created_time);

-- 报表模板表索引
CREATE INDEX idx_report_template_category_name ON report_template(category, name);
CREATE INDEX idx_report_template_created_time ON report_template(created_time);

-- 收藏表索引
CREATE INDEX idx_favorite_user_type ON sys_favorite(user_id, fav_type);
CREATE INDEX idx_favorite_created_time ON sys_favorite(created_time);
```

### 10.2 前端部署

#### 10.2.1 构建配置

在 `vite.config.ts` 中配置代理：

```typescript
export default defineConfig({
  server: {
    proxy: {
      '/api': {
        target: 'http://localhost:8081',
        changeOrigin: true
      }
    }
  }
});
```

#### 10.2.2 环境变量

在 `.env.production` 中配置生产环境变量：

```bash
VITE_API_BASE_URL=https://api.example.com
```

---

## 11. 监控与日志

### 11.1 日志记录

为分页查询添加日志记录：

```java
@Slf4j
@Service
public class DepartmentServiceImpl extends ServiceImpl<DepartmentMapper, Department>
        implements DepartmentService {

    @Override
    public IPage<Department> page(Page<Department> page, String name) {
        log.info("分页查询部门列表，页码: {}, 每页条数: {}, 名称: {}",
            page.getCurrent(), page.getSize(), name);

        LambdaQueryWrapper<Department> wrapper = new LambdaQueryWrapper<>();
        if (StringUtils.isNotBlank(name)) {
            wrapper.like(Department::getName, name);
        }
        wrapper.orderByAsc(Department::getId);

        IPage<Department> result = this.page(page, wrapper);
        log.info("分页查询完成，总记录数: {}, 当前页记录数: {}",
            result.getTotal(), result.getRecords().size());

        return result;
    }
}
```

### 11.2 性能监控

使用Spring Boot Actuator监控分页查询性能：

```yaml
management:
  endpoints:
    web:
      exposure:
        include: health,metrics,info
  metrics:
    export:
      prometheus:
        enabled: true
```

---

## 12. 附录

### 12.1 技术选型说明

| 技术组件 | 选型理由 |
|---------|---------|
| MyBatis-Plus | 提供强大的分页插件，简化分页实现 |
| LambdaQueryWrapper | 类型安全的查询条件构建，编译时检查 |
| Element Plus | 提供成熟的分页组件，减少开发成本 |
| TypeScript | 提供类型安全，减少运行时错误 |

### 12.2 相关文档

- [MyBatis-Plus分页插件文档](https://baomidou.com/pages/97710a/)
- [Element Plus分页组件文档](https://element-plus.org/zh-CN/component/pagination.html)
- [Spring Security文档](https://docs.spring.io/spring-security/reference/)

### 12.3 代码规范

- 遵循阿里巴巴Java开发手册
- 遵循Vue 3风格指南
- 使用ESLint和Prettier格式化代码
- 所有公共方法必须添加Javadoc注释

---

**文档版本**：v1.0
**创建日期**：2025-03-25
**最后更新**：2025-03-25
**作者**：SDD Agent
