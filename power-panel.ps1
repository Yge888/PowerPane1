Add-Type -AssemblyName System.Windows.Forms
[System.Windows.Forms.Application]::EnableVisualStyles()

$form = New-Object System.Windows.Forms.Form
$form.Text = "电源控制面板"
$form.Size = New-Object System.Drawing.Size(400, 350)
$form.StartPosition = "CenterScreen"
$form.FormBorderStyle = "FixedDialog"
$form.MaximizeBox = $false

$lblAction = New-Object System.Windows.Forms.Label
$lblAction.Text = "选择操作:"
$lblAction.Location = New-Object System.Drawing.Point(20, 20)
$lblAction.AutoSize = $true
$form.Controls.Add($lblAction)

$comboAction = New-Object System.Windows.Forms.ComboBox
$comboAction.DropDownStyle = "DropDownList"
$comboAction.Items.AddRange(@("关机", "重启", "锁屏", "睡眠", "休眠"))
$comboAction.SelectedIndex = 0
$comboAction.Location = New-Object System.Drawing.Point(100, 17)
$comboAction.Size = New-Object System.Drawing.Size(250, 25)
$form.Controls.Add($comboAction)

$lblDelay = New-Object System.Windows.Forms.Label
$lblDelay.Text = "延迟时间:"
$lblDelay.Location = New-Object System.Drawing.Point(20, 65)
$lblDelay.AutoSize = $true
$form.Controls.Add($lblDelay)

$numDelay = New-Object System.Windows.Forms.NumericUpDown
$numDelay.Location = New-Object System.Drawing.Point(100, 63)
$numDelay.Size = New-Object System.Drawing.Size(120, 25)
$numDelay.Minimum = 0
$numDelay.Maximum = 86400
$numDelay.Value = 0
$form.Controls.Add($numDelay)

$lblUnit = New-Object System.Windows.Forms.Label
$lblUnit.Text = "秒（0 = 立即）"
$lblUnit.Location = New-Object System.Drawing.Point(225, 65)
$lblUnit.AutoSize = $true
$form.Controls.Add($lblUnit)

$btnExecute = New-Object System.Windows.Forms.Button
$btnExecute.Text = "执行"
$btnExecute.Location = New-Object System.Drawing.Point(100, 110)
$btnExecute.Size = New-Object System.Drawing.Size(250, 45)
$btnExecute.Font = New-Object System.Drawing.Font("Microsoft YaHei", 12, [System.Drawing.FontStyle]::Bold)
$btnExecute.BackColor = [System.Drawing.Color]::FromArgb(220, 60, 60)
$btnExecute.ForeColor = [System.Drawing.Color]::White
$form.Controls.Add($btnExecute)

$btnCancel = New-Object System.Windows.Forms.Button
$btnCancel.Text = "取消已计划的关机/重启"
$btnCancel.Location = New-Object System.Drawing.Point(100, 170)
$btnCancel.Size = New-Object System.Drawing.Size(250, 35)
$btnCancel.Font = New-Object System.Drawing.Font("Microsoft YaHei", 9)
$form.Controls.Add($btnCancel)

$lblStatus = New-Object System.Windows.Forms.Label
$lblStatus.Text = ""
$lblStatus.Location = New-Object System.Drawing.Point(20, 225)
$lblStatus.Size = New-Object System.Drawing.Size(340, 60)
$lblStatus.ForeColor = [System.Drawing.Color]::DarkGreen
$form.Controls.Add($lblStatus)

$btnExecute.Add_Click({
    $action = $comboAction.SelectedItem
    $delay = [int]$numDelay.Value

    $cmdExe = ""
    $cmdArgs = ""

    if ($action -eq "关机") {
        if ($delay -eq 0) { $cmdArgs = "/c shutdown /s /t 0" } else { $cmdArgs = "/c shutdown /s /t $delay" }
        $cmdExe = "cmd.exe"
    }
    elseif ($action -eq "重启") {
        if ($delay -eq 0) { $cmdArgs = "/c shutdown /r /t 0" } else { $cmdArgs = "/c shutdown /r /t $delay" }
        $cmdExe = "cmd.exe"
    }
    elseif ($action -eq "锁屏") {
        $cmdExe = "rundll32.exe"
        $cmdArgs = "user32.dll,LockWorkStation"
    }
    elseif ($action -eq "睡眠") {
        $cmdExe = "rundll32.exe"
        $cmdArgs = "powrprof.dll,SetSuspendState 0,1,0"
    }
    elseif ($action -eq "休眠") {
        $cmdExe = "rundll32.exe"
        $cmdArgs = "powrprof.dll,SetSuspendState 1,0,0"
    }

    $msg = "确定要执行【$action】操作吗？"
    if ($delay -gt 0) { $msg = $msg + "`n延迟: $delay 秒" } else { $msg = $msg + "`n立即执行" }

    $result = [System.Windows.Forms.MessageBox]::Show($msg, "确认", [System.Windows.Forms.MessageBoxButtons]::YesNo, [System.Windows.Forms.MessageBoxIcon]::Warning)

    if ($result -eq [System.Windows.Forms.DialogResult]::Yes) {
        Start-Process -FilePath $cmdExe -ArgumentList $cmdArgs -WindowStyle Hidden
        if ($delay -gt 0) {
            $lblStatus.Text = "已执行: $action (${delay}秒后)"
        } else {
            $lblStatus.Text = "已执行: $action"
        }
        $lblStatus.ForeColor = [System.Drawing.Color]::DarkGreen
    }
})

$btnCancel.Add_Click({
    cmd.exe /c "shutdown /a" 2>$null
    $lblStatus.Text = "已取消已计划的关机/重启"
    $lblStatus.ForeColor = [System.Drawing.Color]::Blue
})

[void]$form.ShowDialog()