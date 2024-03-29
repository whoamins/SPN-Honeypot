﻿
Function Convert-EventLogRecord {

    [cmdletbinding()]
    [alias("clr")]

    Param(
        [Parameter(Position = 0, Mandatory, ValueFromPipeline)]
        [ValidateNotNullorEmpty()]
        [System.Diagnostics.Eventing.Reader.EventLogRecord[]]$LogRecord
    )

    Begin {
        Write-Verbose "[BEGIN  ] Starting: $($MyInvocation.Mycommand)"
    } #begin

    Process {
        foreach ($record in $LogRecord) {
            Write-Verbose "[PROCESS] Processing event id $($record.ID) from $($record.logname) log on $($record.machinename)"
            Write-Verbose "[PROCESS] Creating XML data"
            [xml]$r = $record.ToXml()

            $h = [ordered]@{
                LogName     = $record.LogName
                RecordType  = $record.LevelDisplayName
                TimeCreated = $record.TimeCreated
                ID          = $record.Id
            }

            if ($r.Event.EventData.Data.Count -gt 0) {
                Write-Verbose "[PROCESS] Parsing event data"
                if ($r.Event.EventData.Data -is [array]) {
                <#
                 I only want to enumerate with the For loop if the data is an array of objects
                 If the data is just a single string like Foo, then when using the For loop,
                 the data value will be the F and not the complete string, Foo.
                 #>
                for ($i = 0; $i -lt $r.Event.EventData.Data.count; $i++) {

                    $data = $r.Event.EventData.data[$i]
                    #test if there is structured data or just text
                    if ($data.name) {
                        $Name = $data.name
                        $Value = $data.'#text'
                    }
                    else {
                        Write-Verbose "[PROCESS] No data property name detected"
                        $Name = "RawProperties"
                        #data will likely be an array of strings
                        [string[]]$Value = $data
                    }

                    if ($h.Contains("RawProperties")) {
                        Write-Verbose "[PROCESS] Appending to RawProperties"
                        $h.RawProperties += $value
                    }
                    else {
                        Write-Verbose "[PROCESS] Adding $name"
                        $h.add($name, $Value)
                    }
                } #for data
                } #data is an array
                else {
                    $data = $r.Event.EventData.data
                    if ($data.name) {
                        $Name = $data.name
                        $Value = $data.'#text'
                    }
                    else {
                        Write-Verbose "[PROCESS] No data property name detected"
                        $Name = "RawProperties"
                        #data will likely be an array of strings
                        [string[]]$Value = $data
                    }

                    if ($h.Contains("RawProperties")) {
                        Write-Verbose "[PROCESS] Appending to RawProperties"
                        $h.RawProperties += $value
                    }
                    else {
                        Write-Verbose "[PROCESS] Adding $name"
                        $h.add($name, $Value)
                    }
                }
            } #if data
            else {
                Write-Verbose "[PROCESS] No event data to process"
            }

            $h.Add("Message", $record.Message)
            $h.Add("Keywords", $record.KeywordsDisplayNames)
            $h.Add("Source", $record.ProviderName)
            $h.Add("Computername", $record.MachineName)

            Write-Verbose "[PROCESS] Creating custom object"
            New-Object -TypeName PSObject -Property $h
        } #foreach record
    } #process

    End {
        Write-Verbose "[END    ] Ending: $($MyInvocation.Mycommand)"
    } #end
}

Function ADAuth {
    param(
        $username,
        $password)
    
    $password = $password | ConvertTo-SecureString -asPlainText -Force
    $creds = New-Object System.Management.Automation.PSCredential($username, $password)
    Start-Process powershell "calc.exe" -Credential $creds
}

$ErrorActionPreference= 'silentlycontinue'

# Configuration variables
$PSEmailServer="10.11.1.184"
$from = "kerberoasting <kerberoasting@domain.com>"
$to = "soc <soc@domain.com>"
$name = 'svc_backup'
$serviceName = "BackupService"
$serviceAccountPassword = 'ecfd1f2055b07c306ed3bc2709b5de6'
$schedulerInterval = 5
$schedulerTaskName = "BackupTask"
$binaryPathName = "C:\Windows\System32\calc.exe"


if(Get-ScheduledTaskInfo -TaskName BackupTask) {
    try {
        $ip = Get-WinEvent -FilterHashtable @{Logname="Security";ID=4769;starttime=(date).AddSeconds(($schedulerInterval * 60) * -1);endtime=date} | Convert-EventLogRecord | Where-Object -Property ServiceName -Contains $name | select IPAddress
        $ip = $ip.IpAddress.split(':')[-1]
    } catch [Exception] {
        echo "Null"
    }

    If ($ip -ne $null) {
        Add-Type -AssemblyName System.Windows.Forms 
        $global:balloon = New-Object System.Windows.Forms.NotifyIcon
        $path = (Get-Process -id $pid).Path
        $balloon.Icon = [System.Drawing.Icon]::ExtractAssociatedIcon($path) 
        $balloon.BalloonTipIcon = [System.Windows.Forms.ToolTipIcon]::Warning 
        $balloon.BalloonTipText = "SPN Honeypot has been triggered from $ip"
        $balloon.BalloonTipTitle = "Kerberoasting Detected!" 
        $balloon.Visible = $true 
        $balloon.ShowBalloonTip(5000)

        Send-MailMessage -From $from -To $to -Subject "Kerberoasting Alert!" -Body "SPN Honeypot has been triggered from $ip"
    } else {
        echo "Null"
    }
} else {
    if (!(Get-ADUser -Filter "Name -eq '$name'")) {
        New-ADUser -Name $name -SamAccountName $sam -AccountPassword(ConvertTo-SecureString $serviceAccountPassword -AsPlainText -force) -Enabled $true
        New-Service -Name "$serviceName" -BinaryPathName $binaryPathName -DisplayName "$serviceName"
        setspn -S "HOST/$serviceName" $name

        ADAuth -username $name -password $serviceAccountPassword
    }

    $scriptPath = Get-Location
    $scriptName = $MyInvocation.MyCommand.Name
    $scriptPath = "$scriptPath\$scriptName"
    $action = New-ScheduledTaskAction -Execute 'powershell.exe' -Argument "-File $scriptPath"
    $trigger = New-ScheduledTaskTrigger -Once -At (Get-Date) -RepetitionInterval (New-TimeSpan -Minutes $schedulerInterval)

    Register-ScheduledTask -Action $action -Trigger $trigger -TaskName $schedulerTaskName
}
