$WinEvent = Get-WinEvent -FilterHashtable @{LogName='Security'; ID='4740'} | Select-Object -First 1

[PSCustomObject] @{
    Username = [string] $WinEvent.Properties[0].Value
    CallerComputer = [string] $WinEvent.Properties[1].Value
    TimeCreated = [datetime] $WinEvent.TimeCreated
} | Export-Csv -Path "$PSScriptRoot\AccountLockoutLog($([datetime]::Now.ToString('MMMM-yyyy'))).csv" -Append -NoTypeInformation