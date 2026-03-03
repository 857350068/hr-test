# 人力资源数据中心系统 (HrDataCenter)

> 基于 Spring Boot + Vue3 构建的企业级HR数据分析平台，采用 MySQL + Hive 双数据库架构

## 项目简介

人力资源数据中心系统是一个综合性的HR数据分析平台，支持组织效能分析、人才梯队建设、薪酬福利分析、绩效管理、员工流失预警、培训效果评估、人力成本优化、人才发展预测等八大核心功能模块。

## 技术栈

### 前端
- Vue.js 3.4.0 - 渐进式JavaScript框架
- Element Plus 2.5.0 - UI组件库
- Pinia 2.1.7 - 状态管理
- Vue Router 4.2.5 - 路由管理
- Axios 1.6.5 - HTTP客户端
- Vite 5.0.0 - 构建工具
- ECharts 5.4.3 - 数据可视化

### 后端
- Spring Boot 2.7.18 - Java应用框架
- JDK 1.8 - Java开发工具包
- MyBatis Plus 3.5.5 - ORM框架
- MySQL Connector 8.0.33 - MySQL驱动
- Hive JDBC 3.1.3 - Hive驱动
- Druid 1.2.20 - 数据库连接池
- JWT 0.11.5 - 身份认证
- EasyExcel 3.3.2 - Excel处理

### 数据库
- MySQL 8.0.33 - 业务数据库
- Hive 3.1.3 - 分析数据库
- Hadoop 3.x - 分布式存储

## 快速开始

### 环境要求
- JDK 1.8+
- Maven 3.6+
- Node.js 16+
- MySQL 8.0.33

### 1. 克隆项目

```bash
git clone https://github.com/your-username/HrDataCenter.git
cd HrDataCenter
```

### 2. 数据库初始化

```bash
# 创建MySQL数据库并导入数据
mysql -u root -p < database/mysql/init.sql

# 如果需要使用Hive，请先配置Hadoop和Hive环境
beeline -u "jdbc:hive2://localhost:10000/default" -f database/hive/init.sql
```

### 3. 后端启动

```bash
cd backend

# 修改配置文件
# 编辑 src/main/resources/application-dev.yml
# 配置数据库连接信息

# 安装依赖并启动
mvn clean install
mvn spring-boot:run
```

后端服务将在 http://localhost:8081 启动

### 4. 前端启动

```bash
cd frontend

# 安装依赖
npm install

# 启动开发服务器
npm run dev
```

前端服务将在 http://localhost:5173 启动

### 5. 访问系统

打开浏览器访问 http://localhost:5173

默认登录账号：
- 用户名：admin
- 密码：123456

## 项目结构

```
HrDataCenter/
├── backend/                 # 后端项目
│   ├── src/
│   │   ├── main/
│   │   │   ├── java/        # Java源代码
│   │   │   └── resources/   # 配置文件
│   │   └── test/            # 测试代码
│   └── pom.xml              # Maven配置
├── frontend/                # 前端项目
│   ├── src/
│   │   ├── api/             # API接口
│   │   ├── assets/          # 静态资源
│   │   ├── router/          # 路由配置
│   │   ├── stores/          # 状态管理
│   │   └── views/           # 页面组件
│   ├── index.html
│   └── package.json
├── database/                # 数据库脚本
│   ├── mysql/
│   │   └── init.sql         # MySQL初始化脚本
│   └── hive/
│       └── init.sql         # Hive初始化脚本
├── 完整的系统开发文档/         # 项目文档
└── README.md
```

## 核心功能

### 1. 仪表盘
- 数据概览
- 部门统计
- 绩效分析
- 预警信息

### 2. 数据分析
- 组织效能分析
- 人才梯队建设
- 薪酬福利分析
- 绩效管理体系
- 员工流失预警
- 培训效果评估
- 人力成本优化
- 人才发展预测

### 3. 系统管理
- 用户管理
- 部门管理
- 预警规则管理
- 报表模板管理
- 数据分类管理
- 数据同步管理

### 4. 个人中心
- 个人信息
- 修改密码
- 我的收藏

## 部署说明

详细的部署流程请参考 [DEPLOY.md](DEPLOY.md) 和 [技术流程归纳总结.md](完整的系统开发文档/技术流程归纳总结.md)

## 开发文档

- [完整开发文档](完整的系统开发文档/人力资源数据中心系统-完整开发文档.md)
- [代码注释文档](完整的系统开发文档/人力资源数据中心系统-完整代码注释与开发文档.md)
- [技术流程归纳总结](完整的系统开发文档/技术流程归纳总结.md)
- [部署文档](DEPLOY.md)

## 常见问题

### 1. 后端启动失败
- 检查JDK版本是否为1.8
- 检查MySQL服务是否启动
- 检查数据库连接配置是否正确

### 2. 前端无法访问后端
- 检查后端服务是否正常启动
- 检查vite.config.js中的代理配置
- 检查防火墙设置

### 3. 登录失败
- 检查数据库中是否存在admin用户
- 检查密码是否正确（默认：123456）
- 检查用户状态是否启用

## 贡献指南

欢迎贡献代码！请遵循以下步骤：

1. Fork 本仓库
2. 创建特性分支 (`git checkout -b feature/AmazingFeature`)
3. 提交更改 (`git commit -m 'Add some AmazingFeature'`)
4. 推送到分支 (`git push origin feature/AmazingFeature`)
5. 提交 Pull Request

## 许可证

本项目采用 MIT 许可证 - 详见 [LICENSE](LICENSE) 文件

## 联系方式

如有问题，请通过以下方式联系：

- 提交 Issue
- 发送邮件至：your-email@example.com

## 致谢

感谢所有为本项目做出贡献的开发者！

---

**注意**：本项目仅供学习和参考使用，请勿用于商业用途。
