try{
    Remove-PSDrive -Name Z -Force

    $User = "pharmaca\dev_gpengine"
    $PWord = ConvertTo-SecureString -String "jADU6)}u=(V^SvAXT;%D7TN/P" -AsPlainText -Force
    $cred = New-Object -TypeName System.Management.Automation.PSCredential -ArgumentList $User, $PWord
    New-PSDrive -Name "Z" -Root '\\254-idpa-dd1.pharmaca.com\GP-Share' -Persist -PSProvider "FileSystem" -Credential $cred
    
    Get-ChildItem -Path '\\pharmacasqlbackups.file.core.windows.net\pharmacagp\GP-Share' -Include *.* -File | Where-Object {$_.CreationTime -lt (Get-Date).AddDays(-7)} | Remove-Item -ErrorAction Stop
    
    Copy-Item -Path '\\254-idpa-dd1.pharmaca.com\GP-Share' -Destination '\\pharmacasqlbackups.file.core.windows.net\pharmacagp' -Recurse -Force -ErrorAction Stop

    Remove-PSDrive -Name Z
} 
catch {
        Send-MailMessage -From 'DR Copy To Azure <drazurecopy@pharmaca.com>' -To 'dbanotifications@pharmaca.com' -Subject 'The GP-Share Backup to Azure Has Failed' -Body 'The GP-Share Backup that occurs on 000-WINSRV-DEV as a scheduled task has failed. Please check and correct the process and ensure the backups are completing correctly.' -SmtpServer smtp.pharmaca.com
}