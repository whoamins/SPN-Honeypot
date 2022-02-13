$name = "svc_backup"
$sam = $name -replace ' ', '.'
$password = "ecfd1f2055b07c306ed3bc2709b5de6!8"
$serviceName = "BackupService"


New-ADUser -Name $name -SamAccountName $sam -AccountPassword(ConvertTo-SecureString $password -AsPlainText -force) -Enabled $true
New-Service -Name "$serviceName" -BinaryPathName "C:\Windows\System32\cmd.exe" -DisplayName ″$serviceName″
setspn -S "HOST/$serviceName" $name

# TODO: Monitor logs with id 4769 and service $serviceName
