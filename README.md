# GPG-config-steps

Gnupg configuration guide under windows with Canokeys  
记录一下 windows 的 GPG (Canokeys) 安装和配置步骤

1. 下载并安装[Gpg4win](https://gpg4win.org/get-gpg4win.html)

2. 导入公钥
```powershell
PS C:\> gpg --import public-key.pub
```

3. 设置子密钥指向 `Canokey`
```powershell
PS C:\> gpg --edit-card
gpg/card> fetch
```

4. 查看本地私钥，可以看到已经指向了 `Canokey`
```powershell
PS C:\> gpg --fingerprint --keyid-format long -K
```

5. 导入成功后，进入编辑模式，以设置密钥信任等级为 `绝对（Ultimate）`。
```powershell
PS C:\> gpg --edit-key email@example.com
```

6. 获取`身份验证（Authentication）`独立子密钥的 `KeyGrip`
```powershell
PS C:\> gpg -K --with-keygrip
```
复制以`[A]`为标识的`身份验证（Authentication）`独立子密钥的 `KeyGrip`，创建并添加到`%APPDATA%\Roaming\gnupg\sshcontrol`文件中，之后另起一行。注意换行符需要是`LF`，不能是`CRLF`

7. 创建并在`%APPDATA%\Roaming\gnupg\gpg-agent.conf`中插入
```
enable-ssh-support
enable-putty-support
```
创建并在`%APPDATA%\Roaming\gnupg\gpg.conf`中插入
```
use-agent
```
注意需要另起一行，换行符需要是`LF`，不能是`CRLF`

8. 下载[`wsl-ssh-pageant-amd64-gui.exe`](https://github.com/benpye/wsl-ssh-pageant/releases)，创建并放到`C:\wsl-ssh-pageant\`目录下

9. 在`C:\wsl-ssh-pageant\`目录下创建脚本文件 `gpg-agent.vbs` 内容如下
```
sockFilePath = "C:\wsl-ssh-pageant\ssh-agent.sock"
Set fso = CreateObject("Scripting.FileSystemObject")
IF fso.FileExists(sockFilePath) Then
    fso.DeleteFile sockFilePath
End If

With CreateObject("Wscript.Shell")
    .Run """C:\Program Files (x86)\gnupg\bin\gpg-connect-agent.exe"" /bye", 0
    .Run "C:\wsl-ssh-pageant\wsl-ssh-pageant-amd64-gui.exe --force --wsl C:\wsl-ssh-pageant\ssh-agent.sock --winssh ssh-pageant --systray", 0
    .Run "powershell -ExecutionPolicy Bypass -File C:\wsl-ssh-pageant\notice.ps1", 0
End With
```

创建脚本文件 `notice.ps1` 内容如下
```
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
```

然后给`gpg-agent.vbs`创建一个快捷方式，复制到开始菜单的启动文件夹下让它开机自启

10.添加环境变量 `SSH_AUTH_SOCK` = `\\.\pipe\ssh-pageant`

11.运行
```powershell
PS C:\> ssh-add -L 
```

查看是否和
```powershell
PS C:\> gpg --export-ssh-key YOUR_KEY_ID 
```

输出一致

如果输出是

```
Error connecting to agent: No such file or directory 
```

查看`ssh-agent`是否正常运行

```powershell
PS C:\> get-service ssh* 
```

管理员权限运行`Powershell`

`Win`＋`R`，输入 `wt`，同时按下 `Ctrl`＋`Shift`＋`Enter`

```powershell
PS C:\> Set-Service -Name ssh-agent -StartupType Manual
PS C:\> Start-Service ssh-agent
```
手动启动一下服务

12. 进行一个重启

13. `~/.ssh/config`

```
Host github.com
    User git
    Port 443
    HostName ssh.github.com
```

14. `~/.gitconfig`

```
[core]
	sshCommand = \"C:/Windows/System32/OpenSSH/ssh.exe\"
[commit]
	gpgsign = true
[gpg]
	program = C:\\Program Files (x86)\\GnuPG\\bin\\gpg.exe
[credential "https://gitee.com"]
	provider = generic
```

## reference

https://github.com/benpye/wsl-ssh-pageant

https://gist.github.com/matusnovak/302c7b003043849337f94518a71df777

https://lab.jinkan.org/2021/08/01/using-gpg-for-ssh-authentication-on-windows-10/

https://developer.aliyun.com/article/848731#slide-9