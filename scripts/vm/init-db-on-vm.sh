#!/usr/bin/env bash
set -euo pipefail

MYSQL_HOST="${MYSQL_HOST:-127.0.0.1}"
MYSQL_PORT="${MYSQL_PORT:-3306}"
MYSQL_USER="${MYSQL_USER:-root}"
MYSQL_PASSWORD="${MYSQL_PASSWORD:-123456}"
MYSQL_DB="${MYSQL_DB:-hr_datacenter}"
UPLOAD_DIR="${UPLOAD_DIR:-/opt/hrdatacenter/upload/database}"
MYSQL_OPTS=(--force -h"${MYSQL_HOST}" -P"${MYSQL_PORT}" -u"${MYSQL_USER}" -p"${MYSQL_PASSWORD}")

mysql "${MYSQL_OPTS[@]}" \
  -e "CREATE DATABASE IF NOT EXISTS ${MYSQL_DB} DEFAULT CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;"

mysql "${MYSQL_OPTS[@]}" \
  "${MYSQL_DB}" < "${UPLOAD_DIR}/hr_datacenter_mysql_init.sql"

if [[ -f "${UPLOAD_DIR}/1mysql/insert_data.sql" ]]; then
  mysql "${MYSQL_OPTS[@]}" \
    "${MYSQL_DB}" < "${UPLOAD_DIR}/1mysql/insert_data.sql"
fi

if [[ -f "${UPLOAD_DIR}/mysql_patch_20260416.sql" ]]; then
  mysql "${MYSQL_OPTS[@]}" \
    "${MYSQL_DB}" < "${UPLOAD_DIR}/mysql_patch_20260416.sql"
fi

if [[ -f "${UPLOAD_DIR}/update_user_passwords.sql" ]]; then
  mysql "${MYSQL_OPTS[@]}" \
    "${MYSQL_DB}" < "${UPLOAD_DIR}/update_user_passwords.sql"
fi

if [[ -f "${UPLOAD_DIR}/mysql_compat_sys_user_role_20260423.sql" ]]; then
  mysql "${MYSQL_OPTS[@]}" \
    "${MYSQL_DB}" < "${UPLOAD_DIR}/mysql_compat_sys_user_role_20260423.sql"
fi

echo "MySQL initialization finished."
