#!/usr/bin/env bash
set -euo pipefail

APP_JAR="${APP_JAR:-/opt/hrdatacenter/backend/hr-data-center.jar}"
LOG_FILE="${LOG_FILE:-/opt/hrdatacenter/logs/backend.log}"

export MYSQL_HOST="${MYSQL_HOST:-127.0.0.1}"
export MYSQL_PORT="${MYSQL_PORT:-3306}"
export MYSQL_DB="${MYSQL_DB:-hr_datacenter}"
export MYSQL_USER="${MYSQL_USER:-root}"
export MYSQL_PASSWORD="${MYSQL_PASSWORD:-123456}"

export HIVE_HOST="${HIVE_HOST:-127.0.0.1}"
export HIVE_PORT="${HIVE_PORT:-10000}"
export HIVE_DB="${HIVE_DB:-hr_datacenter_dw}"
export HIVE_USER="${HIVE_USER:-hadoop}"
export HIVE_PASSWORD="${HIVE_PASSWORD:-}"
export HADOOP_USER_NAME="${HADOOP_USER_NAME:-hadoop}"

export JWT_SECRET="${JWT_SECRET:-HrDataCenterGraduationProjectJwtSecret_2026_VeryLong_And_Secure_AtLeast_64_Chars_ABCDEF}"
export DATA_SYNC_ENABLED="${DATA_SYNC_ENABLED:-false}"

mkdir -p "$(dirname "${LOG_FILE}")"
mkdir -p /tmp/hadoop-yarn
chown hadoop:hadoop /tmp/hadoop-yarn || true
chmod 1777 /tmp/hadoop-yarn
chown -R hadoop:hadoop /opt/hrdatacenter/logs || true
pkill -f "hr-data-center\\.jar|HrDataCenter.*jar" >/dev/null 2>&1 || true
su -s /bin/bash -c "nohup /opt/jdk1.8/bin/java -jar ${APP_JAR} --spring.profiles.active=vm > ${LOG_FILE} 2>&1 &" hadoop
echo "Backend started in background."
