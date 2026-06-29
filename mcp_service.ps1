param(
    [Parameter(Mandatory=$true, Position=0)]
    [ValidateSet("status","start","stop","restart")]
    [string]$Command
)

$TASK = "MetaTrader MCP Server"
$URL  = "http://localhost:8000/api/v1/account/info"

function Get-Status {
    $task   = Get-ScheduledTask -TaskName $TASK -ErrorAction SilentlyContinue
    $proc   = Get-CimInstance Win32_Process -Filter "Name='python.exe'" -ErrorAction SilentlyContinue |
              Where-Object { $_.CommandLine -like "*metatrader_openapi*" }

    $httpOk = $false
    try {
        $r = Invoke-WebRequest -Uri $URL -TimeoutSec 3 -UseBasicParsing -ErrorAction Stop
        $httpOk = ($r.StatusCode -eq 200)
    } catch {}

    Write-Host ""
    Write-Host "=== MetaTrader MCP Server ===" -ForegroundColor Cyan
    Write-Host "Tarea Windows : $($task.State)"
    Write-Host "Proceso Python: $(if ($proc) { "corriendo (PID $($proc.ProcessId))" } else { "no encontrado" })"
    Write-Host "HTTP /account : $(if ($httpOk) { "OK" } else { "no responde" })" -ForegroundColor $(if ($httpOk) { "Green" } else { "Red" })
    Write-Host ""
}

function Start-Server {
    Write-Host "Arrancando..." -ForegroundColor Yellow
    Start-ScheduledTask -TaskName $TASK
    Start-Sleep -Seconds 6
    Get-Status
}

function Stop-Server {
    Write-Host "Parando..." -ForegroundColor Yellow
    Stop-ScheduledTask -TaskName $TASK -ErrorAction SilentlyContinue
    Get-CimInstance Win32_Process -Filter "Name='python.exe'" -ErrorAction SilentlyContinue |
        Where-Object { $_.CommandLine -like "*metatrader_openapi*" } |
        ForEach-Object { Stop-Process -Id $_.ProcessId -Force -ErrorAction SilentlyContinue }
    Start-Sleep -Seconds 2
    Get-Status
}

switch ($Command) {
    "status"  { Get-Status }
    "start"   { Start-Server }
    "stop"    { Stop-Server }
    "restart" { Stop-Server; Start-Server }
}
