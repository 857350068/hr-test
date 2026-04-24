param(
    [string]$VmHost = "192.168.116.131",
    [string]$VmUser = "root",
    [string]$RemoteDir = "/opt/hrdatacenter/upload",
    [string]$SshKeyPath = "",
    [string]$RootPassword = "",
    [string]$MysqlHost = "127.0.0.1",
    [string]$MysqlPort = "3306",
    [string]$MysqlUser = "root",
    [string]$MysqlDb = "hr_datacenter",
    [string]$MysqlPassword = "123456",
    [string]$JwtSecret = "hrDataCenterSecretKey2024ForJwtTokenGenerationAndAuthenticationWithSecure512BitKeyLength!!",
    [string]$InitDatabase = "true",
    [string]$ResetMysqlDatabase = "true"
)

# ResetMysqlDatabase=true：VM 上先备份再 DROP DATABASE hr_datacenter，再导入 database/（见 run-on-vm.sh）

$ErrorActionPreference = "Stop"

function Get-SshArgs {
    param(
        [string]$SshKeyPath,
        [string]$RootPassword,
        [string]$AskpassScriptPath
    )
    $sshExtra = @(
        "-o", "StrictHostKeyChecking=accept-new",
        "-o", "ConnectTimeout=15"
    )

    if (-not [string]::IsNullOrWhiteSpace($RootPassword)) {
        $env:VM_SSH_PASSWORD = $RootPassword
        $env:SSH_ASKPASS = $AskpassScriptPath
        $env:SSH_ASKPASS_REQUIRE = "force"
        $env:DISPLAY = "dummy"
        $sshExtra += @(
            "-o", "PreferredAuthentications=password",
            "-o", "PubkeyAuthentication=no"
        )
        return $sshExtra
    }

    if (-not [string]::IsNullOrWhiteSpace($SshKeyPath)) {
        $sshExtra += @("-i", $SshKeyPath, "-o", "BatchMode=yes")
    }
    return $sshExtra
}

$root = Split-Path -Parent (Split-Path -Parent $PSScriptRoot)
$backendDir = Join-Path $root "backend"
$frontendDir = Join-Path $root "frontend"
$databaseDir = Join-Path $root "database"
$askpassScript = Join-Path $PSScriptRoot "askpass.cmd"
$initDatabaseNormalized = $InitDatabase.ToString().Trim().ToLower()
if ($initDatabaseNormalized -notin @("true", "false")) {
    throw "InitDatabase must be true or false."
}
$resetMysqlNormalized = $ResetMysqlDatabase.ToString().Trim().ToLower()
if ($resetMysqlNormalized -notin @("true", "false")) {
    throw "ResetMysqlDatabase must be true or false."
}

Write-Host "[1/8] Build backend jar..."
Push-Location $backendDir
mvn clean package -DskipTests
Pop-Location

$jar = Get-ChildItem (Join-Path $backendDir "target") -Filter "*.jar" |
    Where-Object { $_.Name -notlike "*.original" } |
    Sort-Object LastWriteTime -Descending |
    Select-Object -First 1

if (-not $jar) {
    throw "Backend jar not found."
}

Write-Host "[2/8] Build frontend dist..."
Push-Location $frontendDir
npm install
npm run build
Pop-Location

$frontendDist = Join-Path $frontendDir "dist"
if (-not (Test-Path $frontendDist)) {
    throw "Frontend dist not found."
}

Write-Host "[3/8] Prepare SSH arguments..."
$sshArgs = Get-SshArgs -SshKeyPath $SshKeyPath -RootPassword $RootPassword -AskpassScriptPath $askpassScript
$vm = "$VmUser@$VmHost"

Write-Host "[4/8] Create/clean remote upload directory..."
& ssh @sshArgs $vm "mkdir -p $RemoteDir && rm -rf $RemoteDir/frontend-dist $RemoteDir/database"

Write-Host "[5/8] Upload backend and frontend artifacts..."
& scp @sshArgs $jar.FullName "$vm`:$RemoteDir/backend.jar"
& scp @sshArgs -r $frontendDist "$vm`:$RemoteDir/frontend-dist"
if (Test-Path $databaseDir) {
    & scp @sshArgs -r $databaseDir "$vm`:$RemoteDir/"
}
& scp @sshArgs (Join-Path $PSScriptRoot "run-on-vm.sh") "$vm`:$RemoteDir/run-on-vm.sh"
& scp @sshArgs (Join-Path $PSScriptRoot "nginx-hrdatacenter.conf") "$vm`:$RemoteDir/nginx-hrdatacenter.conf"
& scp @sshArgs (Join-Path $PSScriptRoot "nginx.conf") "$vm`:$RemoteDir/nginx.conf"

Write-Host "[6/8] Execute remote run script..."
$remoteCmd = @"
chmod +x $RemoteDir/run-on-vm.sh &&
export MYSQL_PASSWORD='$MysqlPassword' &&
export MYSQL_HOST='$MysqlHost' &&
export MYSQL_PORT='$MysqlPort' &&
export MYSQL_USER='$MysqlUser' &&
export MYSQL_DB='$MysqlDb' &&
export JWT_SECRET='$JwtSecret' &&
export INIT_DATABASE='$initDatabaseNormalized' &&
export RESET_MYSQL_DB='$resetMysqlNormalized' &&
export DATA_SYNC_ENABLED='false' &&
export HADOOP_USER_NAME='hadoop' &&
export HIVE_USER='hadoop' &&
export JAVA_BIN='/opt/jdk1.8/bin/java' &&
bash $RemoteDir/run-on-vm.sh
"@
& ssh @sshArgs $vm $remoteCmd

Write-Host "[7/8] Check backend process on VM..."
& ssh @sshArgs $vm "ps -ef | grep HrDataCenter | grep -v grep || true"

Write-Host "[8/8] Done. Open in browser: http://$VmHost/"
