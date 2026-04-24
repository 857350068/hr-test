-- ============================================================================
-- 兼容：Mapper 使用 sys_user.id、password_hash、sys_user_role、sys_role.id、sys_role.data_scope
-- 与现有 user_id、password、role_code 并存（普通列 + 同步 SQL）
-- 说明：为兼容 MySQL 8.0.28，采用 INFORMATION_SCHEMA + PREPARE 动态加列
-- ============================================================================

SET NAMES utf8mb4;
USE `hr_datacenter`;

DROP PROCEDURE IF EXISTS `sp_apply_mysql_compat_20260423`;
DELIMITER $$
CREATE PROCEDURE `sp_apply_mysql_compat_20260423`()
BEGIN
    DECLARE col_count INT DEFAULT 0;
    DECLARE col_extra VARCHAR(255) DEFAULT '';

    -- sys_role.data_scope
    SELECT COUNT(*) INTO col_count
    FROM INFORMATION_SCHEMA.COLUMNS
    WHERE TABLE_SCHEMA = DATABASE() AND TABLE_NAME = 'sys_role' AND COLUMN_NAME = 'data_scope';
    IF col_count = 0 THEN
        SET @sql = 'ALTER TABLE `sys_role` ADD COLUMN `data_scope` VARCHAR(32) NOT NULL DEFAULT ''ALL'' COMMENT ''数据范围 ALL/DEPT/SELF'' AFTER `role_code`';
        PREPARE stmt FROM @sql; EXECUTE stmt; DEALLOCATE PREPARE stmt;
    END IF;

    -- sys_role.id
    SELECT COUNT(*) INTO col_count
    FROM INFORMATION_SCHEMA.COLUMNS
    WHERE TABLE_SCHEMA = DATABASE() AND TABLE_NAME = 'sys_role' AND COLUMN_NAME = 'id';
    IF col_count = 0 THEN
        SET @sql = 'ALTER TABLE `sys_role` ADD COLUMN `id` BIGINT NULL COMMENT ''与 role_id 一致（兼容列）''';
        PREPARE stmt FROM @sql; EXECUTE stmt; DEALLOCATE PREPARE stmt;
    END IF;
    SELECT IFNULL(EXTRA, '') INTO col_extra
    FROM INFORMATION_SCHEMA.COLUMNS
    WHERE TABLE_SCHEMA = DATABASE() AND TABLE_NAME = 'sys_role' AND COLUMN_NAME = 'id'
    LIMIT 1;
    IF col_extra LIKE '%GENERATED%' THEN
        SET @sql = 'ALTER TABLE `sys_role` DROP COLUMN `id`';
        PREPARE stmt FROM @sql; EXECUTE stmt; DEALLOCATE PREPARE stmt;
        SET @sql = 'ALTER TABLE `sys_role` ADD COLUMN `id` BIGINT NULL COMMENT ''与 role_id 一致（兼容列）''';
        PREPARE stmt FROM @sql; EXECUTE stmt; DEALLOCATE PREPARE stmt;
    END IF;

    -- sys_user.id
    SELECT COUNT(*) INTO col_count
    FROM INFORMATION_SCHEMA.COLUMNS
    WHERE TABLE_SCHEMA = DATABASE() AND TABLE_NAME = 'sys_user' AND COLUMN_NAME = 'id';
    IF col_count = 0 THEN
        SET @sql = 'ALTER TABLE `sys_user` ADD COLUMN `id` BIGINT NULL COMMENT ''与 user_id 一致（兼容列）''';
        PREPARE stmt FROM @sql; EXECUTE stmt; DEALLOCATE PREPARE stmt;
    END IF;
    SELECT IFNULL(EXTRA, '') INTO col_extra
    FROM INFORMATION_SCHEMA.COLUMNS
    WHERE TABLE_SCHEMA = DATABASE() AND TABLE_NAME = 'sys_user' AND COLUMN_NAME = 'id'
    LIMIT 1;
    IF col_extra LIKE '%GENERATED%' THEN
        SET @sql = 'ALTER TABLE `sys_user` DROP COLUMN `id`';
        PREPARE stmt FROM @sql; EXECUTE stmt; DEALLOCATE PREPARE stmt;
        SET @sql = 'ALTER TABLE `sys_user` ADD COLUMN `id` BIGINT NULL COMMENT ''与 user_id 一致（兼容列）''';
        PREPARE stmt FROM @sql; EXECUTE stmt; DEALLOCATE PREPARE stmt;
    END IF;

    -- sys_user.password_hash
    SELECT COUNT(*) INTO col_count
    FROM INFORMATION_SCHEMA.COLUMNS
    WHERE TABLE_SCHEMA = DATABASE() AND TABLE_NAME = 'sys_user' AND COLUMN_NAME = 'password_hash';
    IF col_count = 0 THEN
        SET @sql = 'ALTER TABLE `sys_user` ADD COLUMN `password_hash` VARCHAR(200) NULL COMMENT ''与 password 一致（兼容列）''';
        PREPARE stmt FROM @sql; EXECUTE stmt; DEALLOCATE PREPARE stmt;
    END IF;
    SELECT IFNULL(EXTRA, '') INTO col_extra
    FROM INFORMATION_SCHEMA.COLUMNS
    WHERE TABLE_SCHEMA = DATABASE() AND TABLE_NAME = 'sys_user' AND COLUMN_NAME = 'password_hash'
    LIMIT 1;
    IF col_extra LIKE '%GENERATED%' THEN
        SET @sql = 'ALTER TABLE `sys_user` DROP COLUMN `password_hash`';
        PREPARE stmt FROM @sql; EXECUTE stmt; DEALLOCATE PREPARE stmt;
        SET @sql = 'ALTER TABLE `sys_user` ADD COLUMN `password_hash` VARCHAR(200) NULL COMMENT ''与 password 一致（兼容列）''';
        PREPARE stmt FROM @sql; EXECUTE stmt; DEALLOCATE PREPARE stmt;
    END IF;
END$$
DELIMITER ;

CALL `sp_apply_mysql_compat_20260423`();
DROP PROCEDURE IF EXISTS `sp_apply_mysql_compat_20260423`;

UPDATE `sys_role` SET `id` = `role_id` WHERE `id` IS NULL OR `id` <> `role_id`;
UPDATE `sys_role` SET `data_scope` = CASE `role_code`
    WHEN 'ROLE_MANAGER' THEN 'DEPT'
    WHEN 'ROLE_EMPLOYEE' THEN 'SELF'
    ELSE 'ALL'
END;

UPDATE `sys_user`
SET `id` = `user_id`,
    `password_hash` = `password`
WHERE `id` IS NULL OR `id` <> `user_id` OR `password_hash` IS NULL OR `password_hash` <> `password`;

DROP TABLE IF EXISTS `sys_user_role`;
CREATE TABLE `sys_user_role` (
    `user_id` BIGINT NOT NULL COMMENT 'sys_user.user_id',
    `role_id` BIGINT NOT NULL COMMENT 'sys_role.role_id',
    PRIMARY KEY (`user_id`, `role_id`),
    KEY `idx_sur_role_id` (`role_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci COMMENT='用户-角色关联';

INSERT INTO `sys_user_role` (`user_id`, `role_id`)
SELECT u.`user_id`, r.`role_id`
FROM `sys_user` u
INNER JOIN `sys_role` r ON r.`role_code` = u.`role_code` AND r.`deleted` = 0
WHERE u.`deleted` = 0;

SELECT 'mysql_compat_sys_user_role_20260423 applied' AS status;
