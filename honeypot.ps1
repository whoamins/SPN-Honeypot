$name = "svc_backup"
$sam = $name -replace ' ', '.' # Change this for your company account naming
$password = "ecfd1f2055b07c306ed3bc2709b5de6!8"
$serviceName = "BackupService"

New-ADUser -Name $name -SamAccountName $sam -AccountPassword(ConvertTo-SecureString $password -AsPlainText -force) -Enabled $true
New-Service -Name "$serviceName" -BinaryPathName "C:\Windows\System32\calc.exe" -DisplayName "$serviceName"
setspn -S "HOST/$serviceName" $name

Get-EventLog -LogName Security -After (date).AddSeconds(-300) -Before (date) | Where-Object -Property InstanceId -Match "4769" | Where-Object -Property ReplacementStrings -Contains $name | fl

# TODO: Popup if output from Get-EventLog is not null
