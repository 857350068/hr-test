# 分页功能部署文档

## 部署概述

本文档详细说明了分页功能的部署步骤、验证方法和回滚方案，确保分页功能能够顺利部署到测试环境和生产环境。

**部署内容：**
- 后端代码：MyBatis-Plus配置、Service层、Controller层
- 前端代码：API封装、页面组件
- 数据库：索引优化

**部署环境：**
- 测试环境
- 生产环境

---

## 1. 部署前准备

### 1.1 代码审查检查清单

**后端代码检查：**
- [ ] MyBatis-Plus配置类已创建 (`MybatisPlusConfig.java`)
- [ ] 5个Service接口已添加分页方法
- [ ] 5个Service实现类已实现分页方法
- [ ] 5个Controller已添加分页接口
- [ ] 所有代码已通过编译
- [ ] 所有代码已通过单元测试

**前端代码检查：**
- [ ] 5个API文件已添加分页方法
- [ ] 5个页面组件已集成分页功能
- [ ] 所有代码已通过ESLint检查
- [ ] 所有代码已通过构建

**数据库检查：**
- [ ] 索引创建SQL脚本已准备
- [ ] 索引验证SQL脚本已准备
- [ ] 数据库备份已完成

### 1.2 环境准备

**后端环境准备：**
```bash
# 检查Java版本（需要Java 8+）
java -version

# 检查Maven版本
mvn -version

# 检查数据库连接
mysql -h localhost -u root -p
```

**前端环境准备：**
```bash
# 检查Node.js版本（需要Node.js 14+）
node -version

# 检查npm版本
npm -version
```

**数据库环境准备：**
```bash
# 检查MySQL版本（需要MySQL 8.0+）
mysql --version

# 备份数据库
mysqldump -h localhost -u root -p hr_datacenter > backup_$(date +%Y%m%d_%H%M%S).sql
```

---

## 2. 部署步骤

### 2.1 部署到测试环境

#### 步骤1：部署后端代码

```bash
# 1. 进入后端项目目录
cd backend

# 2. 拉取最新代码
git pull origin main

# 3. 编译项目
mvn clean package -DskipTests

# 4. 备份现有JAR文件
cp target/hr-datacenter-1.0.0.jar target/hr-datacenter-1.0.0.jar.backup

# 5. 停止现有服务
# 根据实际情况选择停止服务的方式
# 方式1：使用systemctl
sudo systemctl stop hr-datacenter

# 方式2：使用kill命令
ps aux | grep hr-datacenter
kill -9 <PID>

# 6. 部署新的JAR文件
cp target/hr-datacenter-1.0.0.jar /opt/hr-datacenter/

# 7. 启动服务
# 方式1：使用systemctl
sudo systemctl start hr-datacenter

# 方式2：使用nohup
nohup java -jar /opt/hr-datacenter/hr-datacenter-1.0.0.jar > /opt/hr-datacenter/logs/app.log 2>&1 &

# 8. 查看日志
tail -f /opt/hr-datacenter/logs/app.log
```

#### 步骤2：创建数据库索引

```bash
# 1. 连接到数据库
mysql -h localhost -u root -p hr_datacenter

# 2. 执行索引创建脚本
source /path/to/database/pagination_indexes.sql

# 3. 验证索引创建
source /path/to/database/verify_indexes.sql

# 4. 退出数据库
exit;
```

#### 步骤3：部署前端代码

```bash
# 1. 进入前端项目目录
cd frontend

# 2. 拉取最新代码
git pull origin main

# 3. 安装依赖
npm install

# 4. 构建项目
npm run build

# 5. 备份现有构建文件
cp -r dist dist.backup

# 6. 部署新的构建文件
# 根据实际情况选择部署方式
# 方式1：部署到Nginx
rm -rf /usr/share/nginx/html/*
cp -r dist/* /usr/share/nginx/html/

# 方式2：部署到Tomcat
rm -rf /opt/tomcat/webapps/ROOT/*
cp -r dist/* /opt/tomcat/webapps/ROOT/

# 7. 重启Web服务器
# 方式1：重启Nginx
sudo systemctl restart nginx

# 方式2：重启Tomcat
sudo systemctl restart tomcat
```

#### 步骤4：验证部署

```bash
# 1. 检查后端服务状态
curl http://localhost:8080/actuator/health

# 2. 检查前端页面
curl http://localhost/

# 3. 测试分页接口
curl -X GET "http://localhost:8080/api/department/page?current=1&size=10" \
  -H "Authorization: Bearer YOUR_TOKEN"

# 4. 查看应用日志
tail -f /opt/hr-datacenter/logs/app.log
```

---

### 2.2 部署到生产环境

**注意：** 生产环境部署需要更加谨慎，建议在低峰期进行。

#### 步骤1：部署前检查

```bash
# 1. 确认测试环境已通过所有测试
# 2. 确认测试环境运行稳定
# 3. 确认数据库备份已完成
# 4. 确认回滚方案已准备
```

#### 步骤2：部署后端代码

**蓝绿部署（推荐）：**

```bash
# 1. 进入后端项目目录
cd backend

# 2. 编译生产版本
mvn clean package -Pprod -DskipTests

# 3. 部署到蓝色环境（当前运行）
# 假设蓝色环境端口为8080
cp target/hr-datacenter-1.0.0.jar /opt/hr-datacenter/blue/

# 4. 启动蓝色环境
nohup java -jar /opt/hr-datacenter/blue/hr-datacenter-1.0.0.jar \
  --server.port=8080 > /opt/hr-datacenter/blue/logs/app.log 2>&1 &

# 5. 验证蓝色环境
curl http://localhost:8080/actuator/health

# 6. 切换流量到蓝色环境
# 修改负载均衡器配置，将流量切换到蓝色环境

# 7. 停止绿色环境（旧版本）
sudo systemctl stop hr-datacenter-green
```

#### 步骤3：创建数据库索引

```bash
# 1. 在低峰期执行索引创建
# 2. 使用在线DDL（Online DDL）避免锁表
mysql -h localhost -u root -p hr_datacenter

# 3. 执行索引创建脚本
source /path/to/database/pagination_indexes.sql

# 4. 监控索引创建进度
SHOW PROCESSLIST;

# 5. 验证索引创建
SHOW INDEX FROM hr_department;
SHOW INDEX FROM hr_data_category;
SHOW INDEX FROM warning_rule;
SHOW INDEX FROM report_template;
SHOW INDEX FROM sys_favorite;

# 6. 退出数据库
exit;
```

#### 步骤4：部署前端代码

```bash
# 1. 进入前端项目目录
cd frontend

# 2. 构建生产版本
npm run build:prod

# 3. 部署到CDN或静态资源服务器
# 方式1：部署到CDN
aws s3 sync dist/ s3://your-cdn-bucket/

# 方式2：部署到Nginx
rm -rf /usr/share/nginx/html/*
cp -r dist/* /usr/share/nginx/html/

# 4. 清除CDN缓存（如果使用CDN）
aws cloudfront create-invalidation --distribution-id YOUR_DISTRIBUTION_ID --paths "/*"

# 5. 重启Web服务器
sudo systemctl reload nginx
```

#### 步骤5：验证部署

```bash
# 1. 检查后端服务状态
curl http://localhost:8080/actuator/health

# 2. 检查前端页面
curl https://your-domain.com/

# 3. 测试分页接口
curl -X GET "https://your-domain.com/api/department/page?current=1&size=10" \
  -H "Authorization: Bearer YOUR_TOKEN"

# 4. 查看应用日志
tail -f /opt/hr-datacenter/blue/logs/app.log

# 5. 监控系统指标
# CPU、内存、磁盘、网络等
```

---

## 3. 验证步骤

### 3.1 功能验证

**验证清单：**

- [ ] 部门管理分页功能正常
- [ ] 数据分类管理分页功能正常
- [ ] 预警规则管理分页功能正常
- [ ] 报表模板管理分页功能正常
- [ ] 我的收藏分页功能正常
- [ ] 筛选功能正常
- [ ] 分页组件正常
- [ ] 用户数据隔离正常

**验证方法：**

1. **手动测试**
   - 访问各个管理页面
   - 执行分页操作
   - 执行筛选操作
   - 验证数据正确性

2. **自动化测试**
   - 运行测试计划中的测试用例
   - 查看测试报告
   - 确认所有测试通过

### 3.2 性能验证

**验证清单：**

- [ ] 分页查询响应时间 < 1秒
- [ ] 数据库索引正确创建
- [ ] 无慢查询日志
- [ ] 系统资源使用正常

**验证方法：**

1. **响应时间测试**
   ```bash
   # 使用curl测试响应时间
   time curl -X GET "http://localhost:8080/api/department/page?current=1&size=10" \
     -H "Authorization: Bearer YOUR_TOKEN"
   ```

2. **数据库性能测试**
   ```sql
   -- 查看慢查询日志
   SHOW VARIABLES LIKE 'slow_query_log%';

   -- 使用EXPLAIN分析SQL
   EXPLAIN SELECT * FROM hr_department WHERE name LIKE '%技术%' ORDER BY id LIMIT 10;
   ```

3. **系统资源监控**
   ```bash
   # 查看CPU使用率
   top

   # 查看内存使用情况
   free -h

   # 查看磁盘使用情况
   df -h

   # 查看网络连接
   netstat -an
   ```

### 3.3 安全验证

**验证清单：**

- [ ] JWT认证正常
- [ ] 权限控制正常
- [ ] 数据隔离正常
- [ ] SQL注入防护有效
- [ ] 参数校验正常

**验证方法：**

1. **认证测试**
   ```bash
   # 未登录访问
   curl -X GET "http://localhost:8080/api/department/page?current=1&size=10"

   # 使用有效Token访问
   curl -X GET "http://localhost:8080/api/department/page?current=1&size=10" \
     -H "Authorization: Bearer YOUR_TOKEN"
   ```

2. **权限测试**
   ```bash
   # 普通用户访问管理员接口
   curl -X GET "http://localhost:8080/api/department/page?current=1&size=10" \
     -H "Authorization: Bearer USER_TOKEN"
   ```

3. **数据隔离测试**
   ```bash
   # 用户A访问收藏接口
   curl -X GET "http://localhost:8080/api/favorite/page?current=1&size=10" \
     -H "Authorization: Bearer USER_A_TOKEN"

   # 用户B访问收藏接口
   curl -X GET "http://localhost:8080/api/favorite/page?current=1&size=10" \
     -H "Authorization: Bearer USER_B_TOKEN"
   ```

---

## 4. 回滚方案

### 4.1 回滚触发条件

**以下情况需要回滚：**

- 部署后出现严重Bug
- 性能严重下降
- 数据库索引创建失败
- 安全问题
- 用户反馈严重问题

### 4.2 回滚步骤

#### 步骤1：回滚后端代码

```bash
# 1. 停止当前服务
sudo systemctl stop hr-datacenter

# 2. 恢复备份的JAR文件
cp /opt/hr-datacenter/hr-datacenter-1.0.0.jar.backup /opt/hr-datacenter/hr-datacenter-1.0.0.jar

# 3. 启动服务
sudo systemctl start hr-datacenter

# 4. 查看日志
tail -f /opt/hr-datacenter/logs/app.log
```

#### 步骤2：回滚数据库索引

```bash
# 1. 连接到数据库
mysql -h localhost -u root -p hr_datacenter

# 2. 删除新创建的索引
DROP INDEX IF EXISTS idx_department_name ON hr_department;
DROP INDEX IF EXISTS idx_data_category_name ON hr_data_category;
DROP INDEX IF EXISTS idx_warning_rule_type_status ON warning_rule;
DROP INDEX IF EXISTS idx_warning_rule_created_time ON warning_rule;
DROP INDEX IF EXISTS idx_report_template_category_name ON report_template;
DROP INDEX IF EXISTS idx_report_template_created_time ON report_template;
DROP INDEX IF EXISTS idx_favorite_user_type ON sys_favorite;
DROP INDEX IF EXISTS idx_favorite_created_time ON sys_favorite;

# 3. 验证索引删除
SHOW INDEX FROM hr_department;
SHOW INDEX FROM hr_data_category;
SHOW INDEX FROM warning_rule;
SHOW INDEX FROM report_template;
SHOW INDEX FROM sys_favorite;

# 4. 退出数据库
exit;
```

#### 步骤3：回滚前端代码

```bash
# 1. 恢复备份的构建文件
rm -rf /usr/share/nginx/html/*
cp -r dist.backup/* /usr/share/nginx/html/

# 2. 重启Web服务器
sudo systemctl restart nginx

# 3. 清除CDN缓存（如果使用CDN）
aws cloudfront create-invalidation --distribution-id YOUR_DISTRIBUTION_ID --paths "/*"
```

#### 步骤4：验证回滚

```bash
# 1. 检查后端服务状态
curl http://localhost:8080/actuator/health

# 2. 检查前端页面
curl http://localhost/

# 3. 测试原有功能
curl -X GET "http://localhost:8080/api/department/list" \
  -H "Authorization: Bearer YOUR_TOKEN"
```

---

## 5. 监控和维护

### 5.1 监控指标

**后端监控指标：**

- 应用健康状态
- 响应时间
- 错误率
- CPU使用率
- 内存使用率
- 数据库连接数
- 慢查询数量

**前端监控指标：**

- 页面加载时间
- API请求成功率
- 错误日志

**数据库监控指标：**

- 查询响应时间
- 慢查询数量
- 索引使用率
- 连接数

### 5.2 日志管理

**后端日志：**

```bash
# 查看应用日志
tail -f /opt/hr-datacenter/logs/app.log

# 查看错误日志
tail -f /opt/hr-datacenter/logs/error.log

# 查看访问日志
tail -f /opt/hr-datacenter/logs/access.log
```

**数据库日志：**

```bash
# 查看慢查询日志
tail -f /var/log/mysql/slow-query.log

# 查看错误日志
tail -f /var/log/mysql/error.log
```

**前端日志：**

```bash
# 查看Nginx访问日志
tail -f /var/log/nginx/access.log

# 查看Nginx错误日志
tail -f /var/log/nginx/error.log
```

### 5.3 定期维护

**每日维护：**

- 检查应用日志
- 检查错误日志
- 检查系统资源使用情况

**每周维护：**

- 分析慢查询日志
- 优化数据库索引
- 清理过期日志

**每月维护：**

- 性能测试
- 安全扫描
- 备份验证

---

## 6. 常见问题

### 6.1 部署问题

**问题1：后端服务启动失败**

解决方案：
1. 检查Java版本
2. 检查端口是否被占用
3. 检查数据库连接
4. 查看应用日志

**问题2：前端页面无法访问**

解决方案：
1. 检查Nginx配置
2. 检查静态文件路径
3. 检查防火墙设置
4. 查看Nginx日志

**问题3：数据库索引创建失败**

解决方案：
1. 检查数据库权限
2. 检查表是否存在
3. 检查索引是否已存在
4. 查看数据库错误日志

### 6.2 性能问题

**问题1：分页查询很慢**

解决方案：
1. 检查索引是否创建
2. 使用EXPLAIN分析SQL
3. 优化SQL语句
4. 增加数据库缓存

**问题2：系统资源占用过高**

解决方案：
1. 检查是否有内存泄漏
2. 优化代码
3. 增加服务器资源
4. 使用负载均衡

### 6.3 安全问题

**问题1：JWT Token过期**

解决方案：
1. 刷新Token
2. 延长Token有效期
3. 实现Token自动刷新

**问题2：数据隔离失效**

解决方案：
1. 检查JWT Token解析
2. 检查Service层过滤逻辑
3. 检查Controller层用户ID获取

---

## 7. 联系方式

**技术支持：**
- 邮箱：support@hrdatacenter.com
- 电话：400-XXX-XXXX
- 工作时间：周一至周五 9:00-18:00

**紧急联系：**
- 邮箱：emergency@hrdatacenter.com
- 电话：400-XXX-XXXX（24小时）

---

**文档版本：** v1.0
**创建日期：** 2026-03-25
**作者：** SDD Agent
**最后更新：** 2026-03-25
