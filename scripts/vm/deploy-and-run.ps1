param(
    [string]$VmHost = "192.168.116.131",
    [string]$VmUser = "root",
    [string]$RemoteDir = "/opt/hrdatacenter/upload",
    [string]$SshKeyPath = "",
    [string]$RootPassword = "",
    [string]$MysqlPassword = "123456",
    [string]$JwtSecret = "hrDataCenterSecretKey2024ForJwtTokenGenerationAndAuthenticationWithSecure512BitKeyLength!!",
    [bool]$InitDatabase = $true
)

$ErrorActionPreference = "Stop"

function Get-SshArgs {
    param(
        [string]$SshKeyPath,
        [string]$RootPassword,
        [string]$AskpassScriptPath
    )
    $args = @(
        "-o", "StrictHostKeyChecking=accept-new",
        "-o", "ConnectTimeout=15"
    )

    if (-not [string]::IsNullOrWhiteSpace($RootPassword)) {
        $env:VM_SSH_PASSWORD = $RootPassword
        $env:SSH_ASKPASS = $AskpassScriptPath
        $env:SSH_ASKPASS_REQUIRE = "force"
        $env:DISPLAY = "dummy"
        $args += @(
            "-o", "PreferredAuthentications=password",
            "-o", "PubkeyAuthentication=no"
        )
        return $args
    }

    if (-not [string]::IsNullOrWhiteSpace($SshKeyPath)) {
        $args += @("-i", $SshKeyPath, "-o", "BatchMode=yes")
    }
    return $args
}

$root = Split-Path -Parent (Split-Path -Parent $PSScriptRoot)
$backendDir = Join-Path $root "backend"
$frontendDir = Join-Path $root "frontend"
$databaseDir = Join-Path $root "database"
$askpassScript = Join-Path $PSScriptRoot "askpass.cmd"

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

Write-Host "[4/8] Create remote upload directory..."
& ssh @sshArgs $vm "mkdir -p $RemoteDir"

Write-Host "[5/8] Upload backend and frontend artifacts..."
& scp @sshArgs $jar.FullName "$vm`:$RemoteDir/backend.jar"
& scp @sshArgs -r $frontendDist "$vm`:$RemoteDir/frontend-dist"
if (Test-Path $databaseDir) {
    & scp @sshArgs -r $databaseDir "$vm`:$RemoteDir/database"
}
& scp @sshArgs (Join-Path $PSScriptRoot "run-on-vm.sh") "$vm`:$RemoteDir/run-on-vm.sh"
& scp @sshArgs (Join-Path $PSScriptRoot "nginx-hrdatacenter.conf") "$vm`:$RemoteDir/nginx-hrdatacenter.conf"
& scp @sshArgs (Join-Path $PSScriptRoot "nginx.conf") "$vm`:$RemoteDir/nginx.conf"

Write-Host "[6/8] Execute remote run script..."
$remoteCmd = @"
chmod +x $RemoteDir/run-on-vm.sh &&
export MYSQL_PASSWORD='$MysqlPassword' &&
export JWT_SECRET='$JwtSecret' &&
export INIT_DATABASE='$($InitDatabase.ToString().ToLower())' &&
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
