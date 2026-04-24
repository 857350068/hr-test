# 人力资源数据中心

基于SpringBoot + Vue3 + Hadoop + Hive的人力资源管理系统

## 项目结构

```
HrDataCenter/
├── backend/                 # 后端项目 (原hr-backend)
│   ├── src/
│   │   └── main/
│   │       ├── java/
│   │       │   └── com/hr/datacenter/
│   │       │       ├── common/      # 通用类
│   │       │       ├── config/      # 配置类
│   │       │       ├── controller/  # 控制器
│   │       │       ├── dto/         # 数据传输对象
│   │       │       ├── entity/      # 实体类
│   │       │       ├── mapper/      # MyBatis Mapper
│   │       │       ├── security/    # 安全相关
│   │       │       ├── service/     # 业务逻辑
│   │       │       └── util/        # 工具类
│   │       └── resources/
│   │           ├── sql/             # SQL脚本
│   │           └── application.yml  # 配置文件
│   └── pom.xml
├── frontend/                # 前端项目 (原hr-frontend)
│   ├── src/
│   │   ├── api/             # API接口
│   │   ├── assets/          # 静态资源
│   │   ├── components/      # 组件
│   │   ├── router/          # 路由
│   │   ├── store/           # 状态管理
│   │   ├── views/           # 页面
│   │   ├── App.vue
│   │   └── main.js
│   ├── index.html
│   ├── package.json
│   └── vite.config.js
├── database/                # 数据库脚本
│   ├── 1mysql/             # MySQL 脚本与补丁
│   ├── 2hive/              # Hive 脚本与补丁
│   ├── dev/                # 开发/测试用 SQL（非生产初始化）
│   ├── hr_datacenter_mysql_init.sql
│   └── hr_datacenter_hive_init.sql
├── docs/                    # 项目文档（按用途分子目录，见 docs/README.md）
├── scripts/                 # 部署与运维脚本（含 deploy_db、leave-test 等）
├── backend-legacy/          # 旧版后端 (数据分析中心)
├── frontend-legacy/         # 旧版前端 (数据分析中心)
└── README.md
```

## 技术栈

### 后端
- SpringBoot 2.7.18
- MyBatis Plus 3.5.3.1
- Spring Security
- JWT
- MySQL 8.0
- Hadoop 3.2.4
- Hive 3.1.3

### 前端
- Vue 3
- Element Plus
- Vue Router
- Axios
- ECharts
- Vite

## 快速开始

### 前置要求

- JDK 1.8+
- Node.js 16+
- MySQL 8.0+
- Maven 3.6+

### 1. 数据库初始化

```bash
# 登录MySQL
mysql -u root -p

# 执行MySQL初始化脚本
source database/hr_datacenter_mysql_init.sql
```

```bash
# 初始化Hive（示例）
hive -f database/hr_datacenter_hive_init.sql
```

**默认测试账号:**
- 用户名: admin / 密码: 123456
- 用户名: hr001 / 密码: 123456

### 2. 后端启动

```bash
# 进入后端目录
cd backend

# 使用Maven编译打包
mvn clean package

# 运行项目
mvn spring-boot:run

# 或者运行打包后的jar包
java -jar target/hr-datacenter-1.0.0.jar
```

后端启动成功后,访问地址:
- 接口地址: http://localhost:8080/api

### 3. 前端启动

```bash
# 进入前端目录
cd frontend

# 安装依赖
npm install

# 启动开发服务器
npm run dev

# 构建生产版本
npm run build
```

前端启动成功后,访问地址:
- 开发环境: http://localhost:3000
- 生产环境: 需要配置Nginx

## 功能模块

### 已实现功能（与 `docs/06-项目总览/项目文档.md` 一致）
- ✅ 用户登录认证（JWT + 前端 Bearer）
- ✅ 用户注册（跳转登录并回填用户名）
- ✅ 个人中心（资料维护、密码修改）
- ✅ 员工信息管理（CRUD、批量导入等）
- ✅ 首页看板（员工总数、本月入职、本月离职、流失率）
- ✅ 考勤、请假、绩效、薪酬、培训等业务模块
- ✅ 数据分析（侧栏：分析看板、组织效能、人才梯队、薪酬分析、预警分析；支持筛选与收藏）
- ✅ 系统管理（操作日志、数据分类、消息通知、收藏中心）
- ✅ 管理增强（规则管理、模型管理、报表中心、执行记录、分享记录）
- ✅ 鉴权收口（登录/注册放行，其余接口需Bearer Token，系统管理关键接口已启用方法级权限）
- ✅ 预警闭环（规则阈值 + 模型权重驱动流失/缺口/成本预警）
- ✅ 培训效果跟踪与绩效改进概览（页面概览卡 + 后端统计接口）

### 规划功能
- ⏳ 移动端适配
- ⏳ 更细粒度RBAC（用户-角色关系表、按钮级权限）

## 验收映射（任务书 -> 系统能力）

- 基础功能：登录/注册/员工/考勤/请假/绩效/薪酬/培训均已前后端贯通。
- 核心功能：组织效能、人才梯队、薪酬分析、预警分析、人力成本超支预警已实现接口与图表页面。
- 管理功能：数据分类、消息、操作日志、规则、模型、报表中心已具备管理入口，并支持报表执行/分享记录。
- 用户能力：个人中心、收藏中心已实现，支持闭环演示。
- 数据链路：MySQL 初始化脚本、增量补丁、Hive 同步服务已对齐维表/事实表/聚合表。

## 联调建议用例

1. 登录 -> 进入首页看板 -> 验证动态指标。
2. 进入分析看板/预警分析 -> 应用筛选 -> 收藏当前筛选。
3. 进入系统管理 -> 规则管理/模型管理调整阈值与权重 -> 打开预警分析观察结果变化。
4. 进入报表中心 -> 新增任务/导出报表/分享报表 -> 查看执行记录与分享记录。
5. 进入培训管理、绩效管理 -> 查看培训效果概览与绩效改进概览。
6. 进入个人中心 -> 更新资料与修改密码 -> 重新登录验证。

## 开发说明

### 后端开发

1. 在`com.hr.datacenter.entity`包下创建实体类
2. 在`com.hr.datacenter.mapper`包下创建Mapper接口
3. 在`com.hr.datacenter.service`包下创建Service类
4. 在`com.hr.datacenter.controller`包下创建Controller类

### 前端开发

1. 在`src/api`目录下创建API接口文件
2. 在`src/views`目录下创建页面组件
3. 在`src/router/index.js`中配置路由

## 注意事项

1. **数据库配置**: 请修改`backend/src/main/resources/application.yml`中的数据库连接信息
2. **端口冲突**: 如果8080端口被占用,请修改后端配置文件中的`server.port`
3. **跨域问题**: 前端已配置代理,开发环境下无需处理跨域
4. **Hive配置**: 如需使用完整数据中心链路,请先配置Hadoop和Hive环境

## 环境与口径说明（重要）

- **默认模式（推荐答辩演示）**: 使用`application.yml`，`spring.datasource.hive`连接真实Hive，分析/预警走Hive数据源，同步服务可将MySQL业务数据同步至Hive。
- **VM兼容模式**: 使用`application-vm.yml`时，`hive`数据源可回落到MySQL兼容链路，主要用于无Hive集群的本地联调或演示。
- **答辩建议口径**: 业务模块（员工/考勤/培训等）是“数据采集源”；核心价值在“数据中心分析与预警展示”。

### 答辩演示模式（前端一键开关）

- 位置：登录后右上角导航栏（`答辩演示模式`）
- 开启效果：弱化/隐藏非核心业务菜单，仅保留数据中心主链路菜单（总览、专题分析、数据治理）
- 代码位置：`frontend/src/views/Layout.vue`
- 本地持久化键：`localStorage.defenseModeEnabled`

### 运行模式识别接口（后端）

- 接口：`GET /api/system/runtime/profile`
- 作用：返回当前运行模式、激活Profile、数据源识别结果（真实Hive/兼容模式）、同步开关状态
- 代码位置：`backend/src/main/java/com/hr/datacenter/controller/system/RuntimeProfileController.java`

## 菜单信息架构（已调整）

- **数据中心总览**: 首页看板、分析看板、预警分析
- **专题分析**: 组织效能、人才梯队、薪酬分析
- **数据治理**: 数据分类、规则管理、模型管理、报表中心、操作日志、用户管理
- **业务数据源**: 员工、考勤、请假、绩效、薪酬、培训、招聘
- **个人与协同**: 消息通知、我的收藏

## 联系方式

- 项目地址: d:\HrDataCenter
- 问题反馈: 请查看 `docs/06-项目总览/项目文档.md` 或 `docs/README.md`

## 详细文档

完整的项目文档请查看 [docs/06-项目总览/项目文档.md](docs/06-项目总览/项目文档.md)；全部文档索引见 [docs/README.md](docs/README.md)。主文档包含：
- 详细的技术架构说明
- 完整的功能模块介绍
- 开发指南和代码规范
- 部署说明和常见问题
- API接口文档
- 数据库表结构
- 答辩逐条映射清单请查看 [答辩PPT-题目条目映射清单.md](答辩PPT-题目条目映射清单.md)

## 许可证

MIT License
