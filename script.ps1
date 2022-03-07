$name = 'svc_backup'
$command = Get-EventLog -LogName Security -After (date).AddSeconds(-300) -Before (date) | Where-Object -Property InstanceId -Match "4769" | Where-Object -Property ReplacementStrings -Contains $name | fl


If ($command -ne $null)  {
    Add-Type -AssemblyName System.Windows.Forms 
    $global:balloon = New-Object System.Windows.Forms.NotifyIcon
    $path = (Get-Process -id $pid).Path
    $balloon.Icon = [System.Drawing.Icon]::ExtractAssociatedIcon($path) 
    $balloon.BalloonTipIcon = [System.Windows.Forms.ToolTipIcon]::Warning 
    $balloon.BalloonTipText = 'SPN Honeypot has been triggered!'
    $balloon.BalloonTipTitle = "Kerberoasting Detected!" 
    $balloon.Visible = $true 
    $balloon.ShowBalloonTip(5000)
}
Else {
    echo "Null"
}
