# 人力资源数据中心系统 - CentOS 7 部署完整步骤

> 依据技术文档：`完整的系统开发文档`、`人力资源数据中心系统-完整创建计划.md`  
> 目标：Windows 11 开发并打包 → 上传 CentOS 7 虚拟机 → Nginx 代理前端 + 后端 8081 → 主机浏览器访问 http://192.168.168.100

---

## 一、环境与版本（与技术文档一致）

| 组件 | 版本 | 说明 |
|------|------|------|
| JDK | 1.8 | 生产必须 1.8 |
| MySQL | 8.0.33 | 业务库 |
| Hive | 3.1.3 | 分析库（Hadoop 已启动） |
| Nginx | 1.x | 前端静态 + API 反向代理 |
| 虚拟机 IP | 192.168.168.100 | 与主机互通 |

---

## 二、在 Windows 上打包（开发机执行）

### 1. 后端打包

```powershell
cd D:\HrDataCenter\backend
mvn clean
mvn clean package -DskipTests
```

- 产物：`backend\target\hr-datacenter-1.0.0.jar`
- 若报错：检查 JDK 1.8、无 `Map.of()`（已全部替换为 HashMap）

### 2. 前端打包

```powershell
cd D:\HrDataCenter\frontend
npm install
npm run build
```

- 产物：`frontend\dist` 整个目录（含 index.html、assets 等）

### 3. 准备上传文件

在项目根目录整理如下：

```
D:\HrDataCenter\deploy\
├── hr-datacenter-1.0.0.jar    # 从 backend\target\ 复制
├── dist\                       # 从 frontend\dist\ 整个目录
│   ├── index.html
│   └── assets\
└── database\
    ├── mysql\init.sql
    └── hive\init.sql
```

---

## 三、CentOS 7 环境准备

### 1. 安装 JDK 1.8

```bash
sudo yum install -y java-1.8.0-openjdk java-1.8.0-openjdk-devel
java -version   # 应为 1.8.x
```

### 2. 安装 Nginx

```bash
sudo yum install -y epel-release
sudo yum install -y nginx
sudo systemctl enable nginx
sudo systemctl start nginx
sudo systemctl status nginx   # 确保 running
```

### 3. 确认 MySQL 已安装并运行

```bash
sudo systemctl status mysqld   # 或 mariadb
mysql -u root -p -e "SELECT VERSION();"
```

### 4. 确认 Hadoop、Hive 已启动（分析库）

```bash
jps   # 应有 NameNode、DataNode、ResourceManager 等
# Hive 通过 beeline 或 hive 命令行连接 localhost:10000
```

---

## 四、数据库初始化（在 CentOS 7 上执行）

### 1. MySQL 初始化

```bash
# 若 deploy 已上传到 /opt/hr-deploy/
mysql -u root -p < /opt/hr-deploy/database/mysql/init.sql
```

或在 MySQL 客户端中执行 `init.sql` 全部内容。将创建库 `hr_db` 及表、初始数据。

### 2. Hive 初始化

```bash
# 确保 Hive 服务已启动
beeline -u "jdbc:hive2://localhost:10000/default" -f /opt/hr-deploy/database/hive/init.sql
```

或登录 beeline 后逐条执行 `init.sql`。

---

## 五、上传并部署

### 1. 上传文件到虚拟机

从 Windows 使用 SCP、WinSCP、FTP 等将 `deploy` 目录内容上传到虚拟机，例如：

```bash
# 在 Windows PowerShell 中（需安装 scp 或使用 WinSCP）
scp -r D:\HrDataCenter\deploy\* root@192.168.168.100:/opt/hr-deploy/
```

或使用 WinSCP 将 `hr-datacenter-1.0.0.jar`、`dist` 目录、`database` 目录上传到 `/opt/hr-deploy/`。

### 2. 目录结构（虚拟机）

```
/opt/hr-deploy/
├── hr-datacenter-1.0.0.jar
├── dist/
│   ├── index.html
│   └── assets/
└── database/
    ├── mysql/init.sql
    └── hive/init.sql
```

---

## 六、后端启动

### 1. 创建 prod 配置（可选，覆盖连接）

若需修改连接，在同目录创建 `application-prod.yml`：

```yaml
server:
  port: 8081

spring:
  datasource:
    driver-class-name: com.mysql.cj.jdbc.Driver
    url: jdbc:mysql://localhost:3306/hr_db?useUnicode=true&characterEncoding=utf8&useSSL=false&serverTimezone=Asia/Shanghai
    username: root
    password: 你的MySQL密码
  hive:
    url: jdbc:hive2://localhost:10000/default
    username: hadoop
    password: ""
    driver-class-name: org.apache.hive.jdbc.HiveDriver
```

### 2. 后台启动后端

```bash
cd /opt/hr-deploy
nohup java -jar hr-datacenter-1.0.0.jar --spring.profiles.active=prod > backend.log 2>&1 &
```

### 3. 验证后端

```bash
curl -s http://localhost:8081/api/auth/login -X POST -H "Content-Type: application/json" -d '{"username":"admin","password":"123456"}' | head -c 200
```

应返回包含 `"code":200` 和 `"token"` 的 JSON。

---

## 七、Nginx 配置（前端 + API 反向代理）

### 1. 复制前端到 Nginx 根目录

```bash
sudo mkdir -p /usr/share/nginx/html/hr
sudo cp -r /opt/hr-deploy/dist/* /usr/share/nginx/html/hr/
```

### 2. 配置 Nginx

```bash
sudo vim /etc/nginx/conf.d/hr-datacenter.conf
```

内容如下（若已有 `default.conf`，可替换或合并）：

```nginx
server {
    listen 80;
    server_name 192.168.168.100 _;
    root /usr/share/nginx/html/hr;
    index index.html;

    # 前端 SPA 路由
    location / {
        try_files $uri $uri/ /index.html;
    }

    # API 反向代理到后端 8081
    location /api {
        proxy_pass http://127.0.0.1:8081;
        proxy_set_header Host $host;
        proxy_set_header X-Real-IP $remote_addr;
        proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
        proxy_set_header X-Forwarded-Proto $scheme;
    }
}
```

### 3. 检查并重启 Nginx

```bash
sudo nginx -t
sudo systemctl restart nginx
```

---

## 八、访问验证

在主机浏览器访问：

- **http://192.168.168.100**

使用默认账号登录：

- 用户名：**admin**
- 密码：**123456**

---

## 九、故障排查

| 现象 | 可能原因 | 处理 |
|------|----------|------|
| 502 Bad Gateway | 后端未启动 | `ps aux | grep hr-datacenter`，重新 nohup 启动 |
| 404 Not Found | 前端路径错误 | 检查 `/usr/share/nginx/html/hr` 下是否有 index.html |
| 登录失败 | MySQL 未初始化 | 执行 `database/mysql/init.sql` |
| 分析接口无数据 | Hive 未启动 | 启动 Hadoop/Hive，执行 `database/hive/init.sql` |
| AbstractMethodError | Hive 依赖冲突 | 确认 pom.xml 中 Hive 已排除 Tomcat/Jetty 等依赖 |
| 端口占用 | 8081 被占 | `netstat -tlnp | grep 8081`，修改 application-prod.yml 的 port |

---

## 十、操作清单（汇总）

1. [ ] Windows：`mvn clean package -DskipTests` 打包后端  
2. [ ] Windows：`npm run build` 打包前端  
3. [ ] 整理 deploy 目录（jar、dist、database）  
4. [ ] 上传到 CentOS 7 的 /opt/hr-deploy/  
5. [ ] 执行 MySQL init.sql  
6. [ ] 执行 Hive init.sql（若用 Hive）  
7. [ ] 启动后端：`nohup java -jar hr-datacenter-1.0.0.jar --spring.profiles.active=prod &`  
8. [ ] 复制 dist 到 /usr/share/nginx/html/hr/  
9. [ ] 配置 Nginx /api 代理，重启 nginx  
10. [ ] 主机浏览器访问 http://192.168.168.100 并登录 admin/123456  

---

**文档版本**：v1.1  
**最后更新**：2026年3月2日
