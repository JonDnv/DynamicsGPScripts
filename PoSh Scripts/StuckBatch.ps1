[CmdletBinding()]
param(
    [Parameter(Mandatory=$true)]
    [string]$stuckBatch
)

$query = "EXEC DYNAMICS.dbo.StuckBatch @BatchNumber = '" + $stuckBatch + "'"
Invoke-DbaQuery -SqlInstance 000-srv-gp -Database DYNAMICS -Query $query -MessagesToOutput