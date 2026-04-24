# 数据库执行总入口（推荐）

你现在只需要记住一条链路（已经写进 VM 部署脚本）：

1. `hr_datacenter_mysql_init.sql`
2. `1mysql/insert_data.sql`
3. `1mysql/insert_large_data.sql`（可选，数据量大）
4. `mysql_patch_20260416.sql`
5. `update_user_passwords.sql`（`admin/hr001` 密码重置为 `123456` 的 BCrypt）
6. `mysql_compat_sys_user_role_20260423.sql`（兼容 `sys_user_role` / `id` / `password_hash` / `data_scope`）

## 你的关键密码口径

`123456` 对应 BCrypt：

`$2a$10$FdfhJ8LfmYT.mWXFa5Ba3.niJvVgJMxmM5lrPpsxxpDXeSom7Mr5C`

该密文已在 `update_user_passwords.sql` 中落地。

## 一键执行位置

- VM 全量重建 + 部署：`scripts/vm/deploy-and-run.ps1`
- VM 端执行逻辑：`scripts/vm/run-on-vm.sh`

默认会：

- 备份并删除同名库（`RESET_MYSQL_DB=true`）
- 重新导入上面 6 步 SQL
- 启动后端与 Nginx

