Get-EventLog -LogName Security -After (date).AddSeconds(-300) -Before (date) | Where-Object -Property InstanceId -Match "4769" | Where-Object -Property ReplacementStrings -Contains $name | fl

# TODO: Popup if output from Get-EventLog is not null
