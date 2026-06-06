param(
    [Parameter(Mandatory)]
    [ValidateSet('shutdown', 'restart', 'lock', 'sleep', 'hibernate', 'cancel')]
    [string]$Action,

    [int]$Delay = 0
)

if ($Action -eq 'cancel') {
    Write-Host "取消已计划的关机/重启..." -ForegroundColor Yellow
    shutdown /a
    exit
}

$actionName = @{
    shutdown  = '关机'
    restart   = '重启'
    lock      = '锁屏'
    sleep     = '睡眠'
    hibernate = '休眠'
}

$displayAction = $actionName[$Action]

if ($Delay -gt 0) {
    Write-Host "将在 $Delay 秒后$displayAction ..." -ForegroundColor Cyan
}

switch ($Action) {
    'shutdown' {
        if ($Delay -eq 0) { shutdown /s /t 0 }
        else { shutdown /s /t $Delay }
    }
    'restart' {
        if ($Delay -eq 0) { shutdown /r /t 0 }
        else { shutdown /r /t $Delay }
    }
    'lock' {
        if ($Delay -gt 0) { Start-Sleep -Seconds $Delay }
        (New-Object -ComObject Shell.Application).WindowsSecurity()
    }
    'sleep' {
        if ($Delay -gt 0) { Start-Sleep -Seconds $Delay }
        rundll32.exe powrprof.dll,SetSuspendState 0,1,0
    }
    'hibernate' {
        if ($Delay -gt 0) { Start-Sleep -Seconds $Delay }
        rundll32.exe powrprof.dll,SetSuspendState 1,0,0
    }
}
