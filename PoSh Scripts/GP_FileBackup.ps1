Try
{
    Export-DbaSpConfigure -SqlInstance 000-SRV-GP -FilePath \\254-idpa-dd1.pharmaca.com\GP-Backups\BackupFiles\GP_SPCONFIG.SQL -EnableException -ErrorAction SilentlyContinue
    Export-DbaLogin -SqlInstance 000-SRV-GP -EnableException -FilePath \\254-idpa-dd1.pharmaca.com\GP-Backups\BackupFiles\GP_LOGINS.SQL -ErrorAction Stop
    Export-DbaUser -SqlInstance 000-SRV-GP -EnableException -FilePath \\254-idpa-dd1.pharmaca.com\GP-Backups\BackupFiles\GP_DBUSERS.SQL -ErrorAction Stop
    Get-DbaAgentJob -SqlInstance 000-SRV-GP -EnableException | Export-DbaScript -FilePath \\254-idpa-dd1.pharmaca.com\GP-Backups\BackupFiles\GP_JOBS.SQL -ErrorAction Stop
    Get-DbaDbStoredProcedure -SqlInstance 000-srv-gp -Database master,Integration,PanatrackerGP6,RockySoft_Reports1,Rockysoft1 -ExcludeSystemSp -EnableException | Export-DbaScript -FilePath \\254-idpa-dd1.pharmaca.com\gp-Backups\BackupFiles\GP_SPROCS.SQL -ErrorAction Stop
    Get-DbaLinkedServer -SqlInstance 000-SRV-GP -EnableException | Export-DbaScript -FilePath \\254-idpa-dd1.pharmaca.com\GP-Backups\BackupFiles\GP_LINKEDSERVERS.SQL -ErrorAction Stop
    Copy-Item -Path 'E:\Program Files\Microsoft SQL Server\MSSQL12.MSSQLSERVER\MSSQL\Binn\mssqlsystemresource.mdf' -Destination '\\254-idpa-dd1.pharmaca.com\GP-Backups\BackupFiles\ResourceDB\mssqlsystemresource.mdf' -ErrorAction Stop
    Copy-Item -Path 'E:\Program Files\Microsoft SQL Server\MSSQL12.MSSQLSERVER\MSSQL\Binn\mssqlsystemresource.ldf' -Destination '\\254-idpa-dd1.pharmaca.com\GP-Backups\BackupFiles\ResourceDB\mssqlsystemresource.ldf' -ErrorAction Stop
    Compress-Archive -LiteralPath '\\254-idpa-dd1.pharmaca.com\GP-Backups\BackupFiles\' -DestinationPath ('\\254-idpa-dd1.pharmaca.com\GP-Backups\BackupFiles ' + (Get-Date -Format yyyyMMdd) + '.zip') -CompressionLevel Optimal -ErrorAction Stop
    Get-ChildItem -Path \\254-idpa-dd1.pharmaca.com\GP-Backups\BackupFiles -Include *.* -File -Recurse | foreach {$_.Delete()} -ErrorAction Stop
    Get-ChildItem -Path '\\254-idpa-dd1.pharmaca.com\GP-Backups' -Include BackupFiles*.zip -File | Where-Object {$_.CreationTime -lt (Get-Date).AddDays(-90)} | Remove-Item -ErrorAction Stop
    Exit
} 
Catch
{
    Send-MailMessage -SmtpServer smtp.pharmaca.com -From "GP SQL Agent <gpagent@pharmaca.com>" -Subject "000-SRV-GP SQL File Backup Failed" -Body "The SQL file backup scheduled task on 000-SRV-GP failed to complete. Verify functionality and rerun." -To dbanotifications@pharmaca.com
    Exit
}