$action = New-ScheduledTaskAction -Execute 'powershell.exe' -Argument '-File C:\Users\Administrator\Desktop\script.ps1'

$trigger = New-ScheduledTaskTrigger -Once -At (Get-Date) -RepetitionInterval (New-TimeSpan -Minutes 5)

Register-ScheduledTask -Action $action -Trigger $trigger -TaskName "BackupTask"