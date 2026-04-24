<#
.SYNOPSIS
    将本地 database 目录中的 MySQL SQL 脚本备份远程库后按顺序导入（适用于测试/演示环境）。

.DESCRIPTION
    - 使用 ssh / scp（Windows OpenSSH）连接 Linux 主机。
    - 在导入前对 hr_datacenter 执行 mysqldump 全库备份到远程 /tmp。
    - 默认仅处理 MySQL 脚本列表；Hive 脚本请手工在集群上用 beeline 执行。

.NOTES
    请先填写配置区的变量。不要在生产库上未经审批运行。
#>

[CmdletBinding(SupportsShouldProcess = $true)]
param(
    [switch]$SkipBackup
)

$ErrorActionPreference = 'Stop'

# ========================= 必填 / 按需修改 =========================
$RemoteHost = ''          # 例: '192.168.116.131'
$RemoteUser = ''          # 例: 'user'
$SshPort = 22
# 私钥路径，留空则使用 ssh 默认（密码登录或 ssh-agent）
$IdentityFile = ''        # 例: "$env:USERPROFILE\.ssh\id_rsa"

# 远程 MySQL（在 SSH 目标机上执行 mysql 客户端时的连接参数）
$MysqlHost = '127.0.0.1'
$MysqlPort = 3306
$MysqlUser = 'root'
$MysqlPassword = ''       # 留空则脚本在 ssh 命令中使用 MYSQL_PWD（仍有泄露风险，演示环境可接受）

$MysqlDatabase = 'hr_datacenter'

# 本地 SQL 根目录（本脚本位于 <仓库>/scripts/）
$RepoRoot = Split-Path -Parent $PSScriptRoot
$LocalSqlRoot = Join-Path $RepoRoot 'database'

# 远程临时目录（存放上传的 sql）
$RemoteWorkDir = '/tmp/hr_datacenter_sql_deploy'

# MySQL 脚本执行顺序（相对 database 目录）。可按需要增删。
$MysqlScriptOrder = @(
    'hr_datacenter_mysql_init.sql',
    'mysql_patch_20260416.sql',
    '1mysql\insert_data.sql',
    '1mysql\insert_large_data.sql',
    'update_user_passwords.sql',
    'mysql_compat_sys_user_role_20260423.sql'
)
# ================================================================

function Test-Config {
    if (-not $RemoteHost) { throw 'Set $RemoteHost in deploy_db.ps1' }
    if (-not $RemoteUser) { throw 'Set $RemoteUser in deploy_db.ps1' }
    if (-not (Test-Path $LocalSqlRoot)) { throw "Local SQL folder missing: $LocalSqlRoot" }
}

function Build-SshBaseArgs {
    $sshBaseArgs = @('-p', "$SshPort")
    if ($IdentityFile) {
        $sshBaseArgs += @('-i', $IdentityFile)
    }
    return $sshBaseArgs
}

function Invoke-RemoteSh {
    param([string]$Command)
    $sshTarget = "${RemoteUser}@${RemoteHost}"
    $base = Build-SshBaseArgs
    $full = @('ssh') + $base + @($sshTarget, $Command)
    Write-Host ">> ssh $sshTarget ..."
    & $full[0] $full[1..($full.Length - 1)]
    if ($LASTEXITCODE -ne 0) { throw "Remote command failed: $Command" }
}

function Copy-ToRemote {
    param([string]$LocalPath, [string]$RemotePath)
    $sshTarget = "${RemoteUser}@${RemoteHost}"
    $base = Build-SshBaseArgs
    $full = @('scp') + $base + @($LocalPath, "${sshTarget}:$RemotePath")
    Write-Host ">> scp -> $RemotePath"
    & $full[0] $full[1..($full.Length - 1)]
    if ($LASTEXITCODE -ne 0) { throw "scp failed: $LocalPath" }
}

# Bash single-quote wrapping for arbitrary password text
function ConvertTo-BashSingleQuoted {
    param([string]$Value)
    if ([string]::IsNullOrEmpty($Value)) { return "''" }
    $q = [char]39
    $bs = [char]92
    $inner = $Value.Replace($q, [string]::Concat($q, $bs, $q, $q))
    return [string]::Concat($q, $inner, $q)
}

Test-Config

foreach ($rel in $MysqlScriptOrder) {
    $p = Join-Path $LocalSqlRoot $rel
    if (-not (Test-Path $p)) {
        Write-Warning "Skip missing file: $p"
    }
}

$ts = Get-Date -Format 'yyyyMMdd_HHmmss'
$backupName = "backup_${MysqlDatabase}_${ts}.sql"
$backupRemotePath = "$RemoteWorkDir/$backupName"

if ($PSCmdlet.ShouldProcess($RemoteHost, 'MySQL deploy')) {

    Invoke-RemoteSh "mkdir -p $RemoteWorkDir && chmod 700 $RemoteWorkDir"

    if (-not $SkipBackup) {
        if ($MysqlPassword) {
            $pwdQ = ConvertTo-BashSingleQuoted $MysqlPassword
            $dumpCmd = "export MYSQL_PWD=$pwdQ; mysqldump -h$MysqlHost -P$MysqlPort -u$MysqlUser --single-transaction --routines --triggers $MysqlDatabase > $backupRemotePath"
        }
        else {
            $dumpCmd = "mysqldump -h$MysqlHost -P$MysqlPort -u$MysqlUser --single-transaction --routines --triggers $MysqlDatabase > $backupRemotePath"
        }
        Write-Host '>> mysqldump backup (ignore errors if DB missing; init script may create it)...'
        Invoke-RemoteSh $dumpCmd
    }
    else {
        Write-Warning 'SkipBackup set: skipped remote mysqldump.'
    }

    foreach ($rel in $MysqlScriptOrder) {
        $localFile = Join-Path $LocalSqlRoot $rel
        if (-not (Test-Path $localFile)) { continue }

        $leaf = Split-Path $rel -Leaf
        $remoteFile = "$RemoteWorkDir/$leaf"
        Copy-ToRemote -LocalPath $localFile -RemotePath $remoteFile

        if ($MysqlPassword) {
            $pwdQ = ConvertTo-BashSingleQuoted $MysqlPassword
            $importCmd = "export MYSQL_PWD=$pwdQ; mysql -h$MysqlHost -P$MysqlPort -u$MysqlUser --default-character-set=utf8mb4 < $remoteFile"
        }
        else {
            $importCmd = "mysql -h$MysqlHost -P$MysqlPort -u$MysqlUser --default-character-set=utf8mb4 < $remoteFile"
        }
        Write-Host ">> import: $rel"
        Invoke-RemoteSh $importCmd
    }

    Write-Host "Done. Remote backup (if created): $backupRemotePath"
    Write-Host 'Hive SQL not run by this script; run hr_datacenter_hive_init.sql and 2hive/*.sql with beeline on the cluster.'
}
