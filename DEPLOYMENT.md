# 人力资源数据中心 - 部署指南

## 项目概述
- **项目名称**: 人力资源数据中心 (Hr Data Center)
- **部署环境**: VMware CentOS7 一主两从集群
- **部署架构**: 前后端分离 + 大数据组件

## 集群环境信息

### 机器角色分配
| 机器名 | IP地址 | 角色 | 部署内容 |
|--------|--------|------|----------|
| bigdata1 | 192.168.116.131 | Master主节点 | 后端JAR + 前端静态文件 + MySQL + Hive + Nginx |
| bigdata2 | 192.168.116.132 | Slave从节点 | Hadoop DataNode + NodeManager |
| bigdata3 | 192.168.116.133 | Slave从节点 | Hadoop DataNode + NodeManager |

### 核心组件信息
- **JDK**: /opt/jdk1.8 (版本 1.8)
- **MySQL**: /usr/local/mysql (版本 8.0.28, 端口 3306)
- **Hive**: /opt/hive (版本 3.1.3, 端口 10000)
- **Hadoop**: /data/soft/hadoop-3.2.0
- **Nginx**: /usr/sbin/nginx (端口 80)

## 部署文件说明

### 1. 后端部署文件
- **文件路径**: `backend/target/hr-data-center-1.0.0.jar`
- **文件大小**: 约 80MB (包含所有依赖)
- **运行端口**: 8080
- **访问路径**: http://192.168.116.131:8080/api

### 2. 前端部署文件
- **文件路径**: `frontend/dist/`
- **包含内容**:
  - index.html (入口文件)
  - assets/ (静态资源目录)
    - CSS样式文件
    - JavaScript文件
    - 图片等资源

## 部署步骤

### 第一步: 上传部署文件到bigdata1

#### 1.1 上传后端JAR文件
```bash
# 在Windows本地使用scp上传
scp backend/target/hr-data-center-1.0.0.jar root@192.168.116.131:/opt/app/

# 或者使用Xftp等工具上传到 /opt/app/ 目录
```

#### 1.2 上传前端静态文件
```bash
# 在Windows本地使用scp上传整个dist目录
scp -r frontend/dist/* root@192.168.116.131:/data/www/hr-datacenter/

# 或者使用Xftp等工具上传到 /data/www/hr-datacenter/ 目录
```

### 第二步: 配置Nginx

#### 2.1 在bigdata1上创建Nginx配置文件
```bash
# 登录bigdata1
ssh root@192.168.116.131

# 创建Nginx配置文件
vi /etc/nginx/conf.d/hr-datacenter.conf
```

#### 2.2 Nginx配置内容
```nginx
server {
    listen 80;
    server_name 192.168.116.131;

    # 前端静态文件
    location / {
        root /data/www/hr-datacenter;
        index index.html;
        try_files $uri $uri/ /index.html;
    }

    # 后端API代理
    location /api {
        proxy_pass http://127.0.0.1:8080;
        proxy_set_header Host $host;
        proxy_set_header X-Real-IP $remote_addr;
        proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
        proxy_set_header X-Forwarded-Proto $scheme;

        # WebSocket支持
        proxy_http_version 1.1;
        proxy_set_header Upgrade $http_upgrade;
        proxy_set_header Connection "upgrade";
    }

    # 静态资源缓存
    location ~* \.(js|css|png|jpg|jpeg|gif|ico|svg|woff|woff2|ttf|eot)$ {
        root /data/www/hr-datacenter;
        expires 30d;
        add_header Cache-Control "public, immutable";
    }
}
```

#### 2.3 重启Nginx服务
```bash
# 检查配置文件语法
nginx -t

# 重启Nginx
systemctl restart nginx

# 查看Nginx状态
systemctl status nginx
```

### 第三步: 配置MySQL数据库

#### 3.1 确认MySQL服务运行状态
```bash
# 查看MySQL服务状态
systemctl status mysqld

# 如果未启动,启动MySQL
systemctl start mysqld
```

#### 3.2 创建数据库
```bash
# 登录MySQL
mysql -u root -p123456

# 创建数据库
CREATE DATABASE IF NOT EXISTS hr_datacenter DEFAULT CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;

# 退出MySQL
exit;
```

#### 3.3 导入数据库表结构
```bash
# 如果有SQL脚本文件,上传到服务器后执行
mysql -u root -p123456 hr_datacenter < database_schema.sql
```

### 第四步: 配置Hive数据仓库

#### 4.1 确认Hive服务运行状态
```bash
# 查看Hive相关进程
jps | grep -i hive

# 查看HiveServer2端口
netstat -lntp | grep 10000
```

#### 4.2 创建Hive数据库
```bash
# 登录Hive
hive

# 创建数据仓库数据库
CREATE DATABASE IF NOT EXISTS hr_datacenter_dw;

# 退出Hive
exit;
```

### 第五步: 启动后端服务

#### 5.1 创建启动脚本
```bash
# 创建启动脚本
vi /opt/app/start-hr-datacenter.sh
```

#### 5.2 启动脚本内容
```bash
#!/bin/bash

APP_NAME="hr-data-center"
JAR_FILE="/opt/app/hr-data-center-1.0.0.jar"
LOG_FILE="/opt/app/logs/hr-datacenter.log"
PID_FILE="/opt/app/hr-datacenter.pid"

# 创建日志目录
mkdir -p /opt/app/logs

# 启动函数
start() {
    if [ -f $PID_FILE ]; then
        PID=$(cat $PID_FILE)
        if ps -p $PID > /dev/null 2>&1; then
            echo "$APP_NAME 已经在运行 (PID: $PID)"
            return 1
        else
            rm -f $PID_FILE
        fi
    fi

    echo "正在启动 $APP_NAME ..."
    nohup java -jar $JAR_FILE > $LOG_FILE 2>&1 &
    echo $! > $PID_FILE

    sleep 3
    if ps -p $(cat $PID_FILE) > /dev/null 2>&1; then
        echo "$APP_NAME 启动成功 (PID: $(cat $PID_FILE))"
        return 0
    else
        echo "$APP_NAME 启动失败,请查看日志: $LOG_FILE"
        return 1
    fi
}

# 停止函数
stop() {
    if [ ! -f $PID_FILE ]; then
        echo "$APP_NAME 未在运行"
        return 1
    fi

    PID=$(cat $PID_FILE)
    if ps -p $PID > /dev/null 2>&1; then
        echo "正在停止 $APP_NAME (PID: $PID) ..."
        kill $PID

        # 等待进程结束
        for i in {1..30}; do
            if ! ps -p $PID > /dev/null 2>&1; then
                rm -f $PID_FILE
                echo "$APP_NAME 已停止"
                return 0
            fi
            sleep 1
        done

        # 强制杀死进程
        kill -9 $PID
        rm -f $PID_FILE
        echo "$APP_NAME 已强制停止"
    else
        rm -f $PID_FILE
        echo "$APP_NAME 未在运行"
    fi
}

# 重启函数
restart() {
    stop
    sleep 2
    start
}

# 状态函数
status() {
    if [ -f $PID_FILE ]; then
        PID=$(cat $PID_FILE)
        if ps -p $PID > /dev/null 2>&1; then
            echo "$APP_NAME 正在运行 (PID: $PID)"
            return 0
        else
            rm -f $PID_FILE
            echo "$APP_NAME 未在运行"
            return 1
        fi
    else
        echo "$APP_NAME 未在运行"
        return 1
    fi
}

# 根据参数执行相应操作
case "$1" in
    start)
        start
        ;;
    stop)
        stop
        ;;
    restart)
        restart
        ;;
    status)
        status
        ;;
    *)
        echo "使用方法: $0 {start|stop|restart|status}"
        exit 1
        ;;
esac

exit $?
```

#### 5.3 设置脚本权限并启动
```bash
# 设置执行权限
chmod +x /opt/app/start-hr-datacenter.sh

# 启动服务
/opt/app/start-hr-datacenter.sh start

# 查看服务状态
/opt/app/start-hr-datacenter.sh status

# 查看启动日志
tail -f /opt/app/logs/hr-datacenter.log
```

### 第六步: 配置系统服务(可选)

#### 6.1 创建systemd服务文件
```bash
vi /etc/systemd/system/hr-datacenter.service
```

#### 6.2 服务文件内容
```ini
[Unit]
Description=HR Data Center Service
After=network.target mysql.service

[Service]
Type=forking
User=root
Group=root
WorkingDirectory=/opt/app
ExecStart=/opt/app/start-hr-datacenter.sh start
ExecStop=/opt/app/start-hr-datacenter.sh stop
ExecReload=/opt/app/start-hr-datacenter.sh restart
Restart=on-failure
RestartSec=10

[Install]
WantedBy=multi-user.target
```

#### 6.3 启用并启动服务
```bash
# 重新加载systemd配置
systemctl daemon-reload

# 启用开机自启
systemctl enable hr-datacenter

# 启动服务
systemctl start hr-datacenter

# 查看服务状态
systemctl status hr-datacenter
```

## 验证部署

### 1. 检查服务运行状态
```bash
# 检查后端Java进程
jps | grep -i hr

# 检查端口监听
netstat -lntp | grep 8080

# 检查Nginx状态
systemctl status nginx

# 检查MySQL状态
systemctl status mysqld
```

### 2. 访问应用
- **前端页面**: http://192.168.116.131
- **后端API**: http://192.168.116.131/api
- **健康检查**: http://192.168.116.131/api/health

### 3. 测试数据库连接
```bash
# 测试MySQL连接
mysql -h 192.168.116.131 -u root -p123456 hr_datacenter

# 测试Hive连接
beeline -u jdbc:hive2://192.168.116.131:10000/hr_datacenter_dw -n hive
```

## 配置说明

### 后端配置文件 (application.yml)
```yaml
server:
  port: 8080
  servlet:
    context-path: /api

spring:
  datasource:
    mysql:
      jdbc-url: jdbc:mysql://192.168.116.131:3306/hr_datacenter
      username: root
      password: "123456"
    hive:
      jdbc-url: jdbc:hive2://192.168.116.131:10000/hr_datacenter_dw
      username: hive
      password: ""

jwt:
  secret: hrDataCenterSecretKey2024ForJwtTokenGenerationAndAuthenticationWithSecure512BitKeyLength!!
  expiration: 7200000  # 2小时
```

### 前端配置
- **API基础路径**: /api (通过Nginx代理到后端)
- **静态资源路径**: /data/www/hr-datacenter/
- **Nginx端口**: 80

## 常见问题处理

### 1. 后端启动失败
```bash
# 查看详细日志
tail -f /opt/app/logs/hr-datacenter.log

# 检查Java版本
java -version

# 检查端口占用
netstat -lntp | grep 8080

# 检查MySQL连接
mysql -h 192.168.116.131 -u root -p123456 -e "SELECT 1"
```

### 2. 前端页面无法访问
```bash
# 检查Nginx配置
nginx -t

# 检查Nginx状态
systemctl status nginx

# 检查静态文件权限
ls -la /data/www/hr-datacenter/

# 查看Nginx错误日志
tail -f /var/log/nginx/error.log
```

### 3. 数据库连接失败
```bash
# 检查MySQL服务
systemctl status mysqld

# 检查MySQL端口
netstat -lntp | grep 3306

# 测试MySQL连接
mysql -h 192.168.116.131 -u root -p123456

# 检查防火墙
firewall-cmd --list-all
```

### 4. Hive连接失败
```bash
# 检查Hive服务
jps | grep -i hive

# 检查Hive端口
netstat -lntp | grep 10000

# 测试Hive连接
beeline -u jdbc:hive2://192.168.116.131:10000 -n hive
```

## 运维管理

### 日志管理
```bash
# 后端应用日志
/opt/app/logs/hr-datacenter.log

# Nginx访问日志
/var/log/nginx/access.log

# Nginx错误日志
/var/log/nginx/error.log

# MySQL日志
/var/log/mysqld.log
```

### 服务管理
```bash
# 启动服务
systemctl start hr-datacenter

# 停止服务
systemctl stop hr-datacenter

# 重启服务
systemctl restart hr-datacenter

# 查看服务状态
systemctl status hr-datacenter

# 查看服务日志
journalctl -u hr-datacenter -f
```

### 备份策略
```bash
# 数据库备份
mysqldump -u root -p123456 hr_datacenter > backup_$(date +%Y%m%d).sql

# 前端静态文件备份
tar -czf hr-datacenter-frontend-$(date +%Y%m%d).tar.gz /data/www/hr-datacenter/

# 后端JAR备份
cp /opt/app/hr-data-center-1.0.0.jar /opt/app/backup/hr-data-center-1.0.0-$(date +%Y%m%d).jar
```

## 性能优化建议

### 1. JVM参数优化
```bash
# 修改启动脚本,添加JVM参数
java -Xms512m -Xmx1024m -XX:+UseG1GC -jar $JAR_FILE
```

### 2. MySQL优化
```bash
# 修改MySQL配置文件
vi /etc/my.cnf

# 添加优化参数
[mysqld]
max_connections=200
innodb_buffer_pool_size=1G
query_cache_size=64M
```

### 3. Nginx优化
```bash
# 修改Nginx配置
worker_processes auto;
worker_connections 2048;

# 启用gzip压缩
gzip on;
gzip_types text/plain text/css application/json application/javascript;
```

## 安全建议

1. **修改默认密码**: 修改MySQL root密码和JWT密钥
2. **配置防火墙**: 只开放必要的端口(80, 22, 3306, 10000)
3. **启用HTTPS**: 配置SSL证书,启用HTTPS访问
4. **定期备份**: 建立定期备份机制
5. **监控告警**: 配置服务监控和异常告警

## 技术支持

如有问题,请联系技术支持团队或查看项目文档。

---

**部署完成时间**: 2026-04-08
**版本**: 1.0.0
**部署人员**: 系统管理员
