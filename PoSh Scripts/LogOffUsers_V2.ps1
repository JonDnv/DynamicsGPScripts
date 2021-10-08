[CmdletBinding()]
param(
    [Parameter(Mandatory=$true)]
    [string]$domainAccount,

    [Parameter(Mandatory=$true)]
    [string]$gpAccount
)

Write-Output "The user has been cleared of their GP session and from the GP RemoteApp. If the user was in the Terminal Server, you must manually clear the user's session from 000-WINSRV-RTGP."

Get-TSSession -ComputerName 000-WINSRV-RDGP | Where-Object {$_.UserName -eq $domainAccount} | Stop-TSSession -ComputerName 000-winsrv-rdgp -ErrorAction SilentlyContinue -Force

$query = "EXEC DYNAMICS.dbo.StuckUser @UserID = " + $gpAccount
Invoke-DbaQuery -SqlInstance 000-SRV-GP -Database DYNAMICS -Query $query