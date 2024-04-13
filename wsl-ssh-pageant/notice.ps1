Add-Type -AssemblyName System.Windows.Forms
$notifyIcon = New-Object System.Windows.Forms.NotifyIcon

# 加载一个图标（这里使用系统图标，你也可以指定其他图标的路径）
$notifyIcon.Icon = [System.Drawing.SystemIcons]::Information
$notifyIcon.Visible = $true

# 显示通知提示
$notifyIcon.ShowBalloonTip(10000, "wsl-ssh-pageant", "ssh-agent created.", [System.Windows.Forms.ToolTipIcon]::Info)

# 防止脚本结束后立即消失
Start-Sleep -Seconds 1

# 清理图标，避免在系统托盘中留下死图标
$notifyIcon.Dispose()
