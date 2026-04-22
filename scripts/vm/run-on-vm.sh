#!/usr/bin/env bash
set -euo pipefail

APP_DIR="${APP_DIR:-/opt/hrdatacenter}"
MYSQL_PASSWORD="${MYSQL_PASSWORD:-123456}"
JWT_SECRET="${JWT_SECRET:-hrDataCenterSecretKey2024ForJwtTokenGenerationAndAuthenticationWithSecure512BitKeyLength!!}"
MYSQL_HOST="${MYSQL_HOST:-127.0.0.1}"
MYSQL_PORT="${MYSQL_PORT:-3306}"
MYSQL_DB="${MYSQL_DB:-hr_datacenter}"
MYSQL_USER="${MYSQL_USER:-root}"
HIVE_HOST="${HIVE_HOST:-127.0.0.1}"
HIVE_PORT="${HIVE_PORT:-10000}"
HIVE_DB="${HIVE_DB:-hr_datacenter_dw}"
HIVE_USER="${HIVE_USER:-hadoop}"
HIVE_PASSWORD="${HIVE_PASSWORD:-}"
INIT_DATABASE="${INIT_DATABASE:-true}"
DATA_SYNC_ENABLED="${DATA_SYNC_ENABLED:-false}"
HADOOP_USER_NAME="${HADOOP_USER_NAME:-hadoop}"
JAVA_BIN="${JAVA_BIN:-}"

if [[ -z "${JAVA_BIN}" ]]; then
  JAVA_BIN="$(command -v java || true)"
fi
if [[ -z "${JAVA_BIN}" && -x "/opt/jdk1.8/bin/java" ]]; then
  JAVA_BIN="/opt/jdk1.8/bin/java"
fi
if [[ -z "${JAVA_BIN}" ]]; then
  echo "未找到可用的 Java 可执行文件，请设置 JAVA_BIN 或配置 PATH。"
  exit 1
fi

if [[ ${#JWT_SECRET} -lt 32 ]]; then
  echo "JWT_SECRET 长度过短，已回退到默认安全密钥。"
  JWT_SECRET="hrDataCenterSecretKey2024ForJwtTokenGenerationAndAuthenticationWithSecure512BitKeyLength!!"
fi

echo "[1/8] 创建目录: ${APP_DIR}"
mkdir -p "${APP_DIR}"/{backend,logs,frontend-dist}
mkdir -p "${APP_DIR}/logs/report-exports"

echo "[2/8] 停止旧后端进程"
pkill -f "hr-data-center\\.jar|HrDataCenter.*jar" >/dev/null 2>&1 || true

echo "[3/8] 覆盖前端静态资源"
if [[ -d "${APP_DIR}/upload/frontend-dist" ]]; then
  rm -rf "${APP_DIR}/frontend-dist"
  mv "${APP_DIR}/upload/frontend-dist" "${APP_DIR}/frontend-dist"
else
  echo "未找到 ${APP_DIR}/upload/frontend-dist，请先上传前端构建产物。"
  exit 1
fi

echo "[4/8] 覆盖后端jar"
if [[ -f "${APP_DIR}/upload/backend.jar" ]]; then
  cp -f "${APP_DIR}/upload/backend.jar" "${APP_DIR}/backend/hr-data-center.jar"
else
  echo "未找到 ${APP_DIR}/upload/backend.jar，请先上传后端jar。"
  exit 1
fi

echo "[5/8] 初始化数据库 (可选)"
if [[ "${INIT_DATABASE}" == "true" ]]; then
  echo "执行 MySQL 初始化脚本"
  MYSQL_CMD=(mysql --force -h"${MYSQL_HOST}" -P"${MYSQL_PORT}" -u"${MYSQL_USER}" -p"${MYSQL_PASSWORD}")
  if ! command -v mysql >/dev/null 2>&1; then
    echo "未检测到 mysql 客户端，跳过数据库初始化。"
  elif [[ -d "${APP_DIR}/upload/database" ]]; then
    "${MYSQL_CMD[@]}" -e \
      "CREATE DATABASE IF NOT EXISTS ${MYSQL_DB} DEFAULT CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;"
    "${MYSQL_CMD[@]}" "${MYSQL_DB}" < "${APP_DIR}/upload/database/hr_datacenter_mysql_init.sql"
    if [[ -f "${APP_DIR}/upload/database/1mysql/insert_data.sql" ]]; then
      "${MYSQL_CMD[@]}" "${MYSQL_DB}" < "${APP_DIR}/upload/database/1mysql/insert_data.sql"
    fi
    if [[ -f "${APP_DIR}/upload/database/mysql_patch_20260416.sql" ]]; then
      "${MYSQL_CMD[@]}" "${MYSQL_DB}" < "${APP_DIR}/upload/database/mysql_patch_20260416.sql"
    fi
    if [[ -f "${APP_DIR}/upload/database/update_user_passwords.sql" ]]; then
      "${MYSQL_CMD[@]}" "${MYSQL_DB}" < "${APP_DIR}/upload/database/update_user_passwords.sql"
    fi
  else
    echo "未找到 ${APP_DIR}/upload/database，跳过数据库初始化。"
  fi
fi

echo "[6/8] 启动后端 (profile=vm)"
export MYSQL_PASSWORD JWT_SECRET MYSQL_HOST MYSQL_PORT MYSQL_DB MYSQL_USER
export HIVE_HOST HIVE_PORT HIVE_DB HIVE_USER HIVE_PASSWORD DATA_SYNC_ENABLED HADOOP_USER_NAME
mkdir -p /tmp/hadoop-yarn
chown hadoop:hadoop /tmp/hadoop-yarn || true
chmod 1777 /tmp/hadoop-yarn
chown -R hadoop:hadoop "${APP_DIR}/logs" || true
su -s /bin/bash -c "nohup ${JAVA_BIN} -jar ${APP_DIR}/backend/hr-data-center.jar --spring.profiles.active=vm > ${APP_DIR}/logs/backend.log 2>&1 &" hadoop

sleep 3

echo "[7/8] 配置并重启 Nginx"
if [[ -f "${APP_DIR}/upload/nginx.conf" ]]; then
  cp -f "${APP_DIR}/upload/nginx.conf" /etc/nginx/nginx.conf
elif [[ -f "${APP_DIR}/upload/nginx-hrdatacenter.conf" ]]; then
  cp -f "${APP_DIR}/upload/nginx-hrdatacenter.conf" /etc/nginx/conf.d/hrdatacenter.conf
else
  echo "未找到 Nginx 配置文件（nginx.conf 或 nginx-hrdatacenter.conf）。"
  exit 1
fi

if command -v systemctl >/dev/null 2>&1; then
  systemctl enable nginx >/dev/null 2>&1 || true
  systemctl restart nginx
else
  nginx -s reload || nginx
fi

echo "[8/8] 输出访问地址"
VM_IP="$(hostname -I | awk '{print $1}')"
echo "----------------------------------------"
echo "前端访问: http://${VM_IP}/"
echo "后端健康: http://${VM_IP}/api"
echo "后端日志: ${APP_DIR}/logs/backend.log"
echo "----------------------------------------"
