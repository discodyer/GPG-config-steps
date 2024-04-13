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