#!/usr/bin/env bash
set -euo pipefail

APP_DIR="${APP_DIR:-/opt/hrdatacenter}"

pkill -f 'hr-data-center\.jar|HrDataCenter.*jar' >/dev/null 2>&1 || true

mkdir -p "${APP_DIR}/logs" /tmp/hadoop-yarn
chown hadoop:hadoop "${APP_DIR}/logs" /tmp/hadoop-yarn || true
chmod 1777 /tmp/hadoop-yarn || true

su -s /bin/bash -c "
  export MYSQL_PASSWORD='123456'
  export MYSQL_HOST='127.0.0.1'
  export MYSQL_PORT='3306'
  export MYSQL_DB='hr_datacenter'
  export MYSQL_USER='root'
  export HIVE_HOST='127.0.0.1'
  export HIVE_PORT='10000'
  export HIVE_DB='hr_datacenter_dw'
  export HIVE_USER='hadoop'
  export HIVE_PASSWORD=''
  export DATA_SYNC_ENABLED='false'
  export HADOOP_USER_NAME='hadoop'
  export JWT_SECRET='hrDataCenterSecretKey2024ForJwtTokenGenerationAndAuthenticationWithSecure512BitKeyLength!!'
  nohup /opt/jdk1.8/bin/java -jar ${APP_DIR}/backend/hr-data-center.jar --spring.profiles.active=vm > ${APP_DIR}/logs/backend.log 2>&1 &
" hadoop

if command -v systemctl >/dev/null 2>&1; then
  systemctl restart nginx
else
  nginx -s reload || nginx
fi

sleep 6
echo "===BACKEND_PROCESS==="
pgrep -af 'hr-data-center\.jar|HrDataCenter.*jar' || true
echo "===HEALTH_8080==="
curl -sS -m 10 http://127.0.0.1:8080/api || true
echo
echo "===NGINX_HOME==="
curl -sS -I -m 10 http://127.0.0.1/ || true
