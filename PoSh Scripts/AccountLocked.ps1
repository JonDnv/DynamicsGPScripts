[CmdletBinding()]
param(
    [Parameter(Mandatory=$true)]
    [string]$User
)

$query = "EXEC master.dbo.GPAccountReset @UserID = '" + $User + "'"
Invoke-DbaQuery -ServerInstance 000-srv-gp -Database master -Query $query -MessagesToOutput