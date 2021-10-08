$subjectline = "Files Failed to Copy from Server(s) "
$bodystart = "The files on the following server(s) have failed to copy to the GP-Share:<br/><br/>"
$serverlist = $null
$bodyend = "<br/>Failure Exit Code Definitions:<br/>2 - Extra files or directories were detected.<br/>8 - Some files or directories could not be copied and the retry limit was exceeded.<br/> 16 - Robocopy did not copy any files. Check parameters & share rights."
$fullbody = $null
$server = '000-WINSRV-DEV'
$task = $null
$startTime = $null
$endTime = $null
$share = $null

if (Test-Path -Path \\254-idpa-dd1.pharmaca.com\GP-Share) {

    if (test-path E:\Scripts\GPShare-RobocopyLog.txt)
    {
        remove-item E:\Scripts\GPShare-RobocopyLog.txt
    }     
    
    $startTime = (Get-Date -Format "yyy-MM-dd HH:mm:ss")
    $task = "000-SRV-PTAPP Panatrack Copy"
    $share = "IDPA"
    robocopy "\\000-srv-ptapp\c$\Program Files (x86)\Panatrack" "\\254-idpa-dd1.pharmaca.com\GP-Share\FileBackup\000-SRV-PTAPP\Panatrack" /e /mir /r:3 /w:120 /np /log+:E:\Scripts\GPShare-RobocopyLog.txt   
    if ($lastexitcode -ge 8) {
      $endTime = (Get-Date -Format "yyy-MM-dd HH:mm:ss")
      Invoke-DbaQuery -SqlInstance 000-WINSRV-RPT -Database ITReporting -Query "INSERT INTO dbo.RobocopyBackups (Server, Share, Task, ExitCode, StartTime, EndTime) VALUES ('$server','$share', '$task', '$lastexitcode', '$startTime', '$endtime')"
      $serverlist += "000-SRV-PTAPP - Directory: 000-SRV-PTAPP\C$\Program Files (x86)\Panatrack - ($lastexitcode)<br/>"
    }
    else {
      $endTime = (Get-Date -Format "yyy-MM-dd HH:mm:ss")
      Invoke-DbaQuery -SqlInstance 000-WINSRV-RPT -Database ITReporting -Query "INSERT INTO dbo.RobocopyBackups (Server, Share, Task, ExitCode, StartTime, EndTime) VALUES ('$server','$share', '$task', '$lastexitcode', '$startTime', '$endtime')"
    }
    
    $startTime = (Get-Date -Format "yyy-MM-dd HH:mm:ss")
    $task = "000-SRV-PTAPP IT Folder Copy"
    $share = "IDPA"
    robocopy "\\000-srv-ptapp\c$\IT" "\\254-idpa-dd1.pharmaca.com\GP-Share\FileBackup\000-SRV-PTAPP\IT" /e /mir /r:3 /w:120 /np /log+:E:\Scripts\GPShare-RobocopyLog.txt   
    if ($lastexitcode -ge 8) {
      $endTime = (Get-Date -Format "yyy-MM-dd HH:mm:ss")
      Invoke-DbaQuery -SqlInstance 000-WINSRV-RPT -Database ITReporting -Query "INSERT INTO dbo.RobocopyBackups (Server, Share, Task, ExitCode, StartTime, EndTime) VALUES ('$server','$share', '$task', '$lastexitcode', '$startTime', '$endtime')"
      $serverlist += "000-SRV-PTAPP - Directory: 000-SRV-PTAPP\C$\IT - ($lastexitcode)<br/>"
    }
    else {
      $endTime = (Get-Date -Format "yyy-MM-dd HH:mm:ss")
      Invoke-DbaQuery -SqlInstance 000-WINSRV-RPT -Database ITReporting -Query "INSERT INTO dbo.RobocopyBackups (Server, Share, Task, ExitCode, StartTime, EndTime) VALUES ('$server','$share', '$task', '$lastexitcode', '$startTime', '$endtime')"
    }

    $startTime = (Get-Date -Format "yyy-MM-dd HH:mm:ss")
    $task = "000-WINSRV-RDGP Microsoft Dynamics Folder Copy"
    $share = "IDPA"
    robocopy "\\000-winsrv-rdgp\c$\Program Files (x86)\Microsoft Dynamics" "\\254-idpa-dd1.pharmaca.com\GP-Share\FileBackup\000-WINSRV-RDGP\Microsoft Dynamics" /e /mir /r:3 /w:120 /np /log+:E:\Scripts\GPShare-RobocopyLog.txt
    if ($lastexitcode -ge 8) {
      $endTime = (Get-Date -Format "yyy-MM-dd HH:mm:ss")
      Invoke-DbaQuery -SqlInstance 000-WINSRV-RPT -Database ITReporting -Query "INSERT INTO dbo.RobocopyBackups (Server, Share, Task, ExitCode, StartTime, EndTime) VALUES ('$server','$share', '$task', '$lastexitcode', '$startTime', '$endtime')"
      $serverlist += "000-WINSRV-RDGP - Directory: 000-WINSRV-RDGP\C$\Program Files (x86)\Microsoft Dynamics - ($lastexitcode)<br/>"
    }
    else {
      $endTime = (Get-Date -Format "yyy-MM-dd HH:mm:ss")
      Invoke-DbaQuery -SqlInstance 000-WINSRV-RPT -Database ITReporting -Query "INSERT INTO dbo.RobocopyBackups (Server, Share, Task, ExitCode, StartTime, EndTime) VALUES ('$server','$share', '$task', '$lastexitcode', '$startTime', '$endtime')"
    }

    $startTime = (Get-Date -Format "yyy-MM-dd HH:mm:ss")
    $task = "000-WINSRV-RDGP IT Folder Copy"
    $share = "IDPA"
    robocopy "\\000-winsrv-rdgp\c$\IT" "\\254-idpa-dd1.pharmaca.com\GP-Share\FileBackup\000-WINSRV-RDGP\IT" /e /mir /r:3 /w:120 /np /log+:E:\Scripts\GPShare-RobocopyLog.txt
    if ($lastexitcode -ge 8) {
      $endTime = (Get-Date -Format "yyy-MM-dd HH:mm:ss")
      Invoke-DbaQuery -SqlInstance 000-WINSRV-RPT -Database ITReporting -Query "INSERT INTO dbo.RobocopyBackups (Server, Share, Task, ExitCode, StartTime, EndTime) VALUES ('$server','$share', '$task', '$lastexitcode', '$startTime', '$endtime')"
      $serverlist += "000-WINSRV-RDGP - Directory: 000-WINSRV-RDGP\C$\IT - ($lastexitcode)<br/>"
    }
    else {
      $endTime = (Get-Date -Format "yyy-MM-dd HH:mm:ss")
      Invoke-DbaQuery -SqlInstance 000-WINSRV-RPT -Database ITReporting -Query "INSERT INTO dbo.RobocopyBackups (Server, Share, Task, ExitCode, StartTime, EndTime) VALUES ('$server','$share', '$task', '$lastexitcode', '$startTime', '$endtime')"
    }

    $startTime = (Get-Date -Format "yyy-MM-dd HH:mm:ss")
    $task = "000-WINSRV-RTGP Microsoft Dynamics Folder Copy"
    $share = "IDPA"
    robocopy "\\000-winsrv-rtgp\c$\Program Files (x86)\Microsoft Dynamics" "\\254-idpa-dd1.pharmaca.com\GP-Share\FileBackup\000-WINSRV-RTGP\Microsoft Dynamics" /e /mir /r:3 /w:120 /np /log+:E:\Scripts\GPShare-RobocopyLog.txt
    if ($lastexitcode -ge 8) {
      $endTime = (Get-Date -Format "yyy-MM-dd HH:mm:ss")
      Invoke-DbaQuery -SqlInstance 000-WINSRV-RPT -Database ITReporting -Query "INSERT INTO dbo.RobocopyBackups (Server, Share, Task, ExitCode, StartTime, EndTime) VALUES ('$server','$share', '$task', '$lastexitcode', '$startTime', '$endtime')"
      $serverlist += "000-WINSRV-RTGP - Directory: 000-WINSRV-RTGP\C$\Program Files (x86)\Microsoft Dynamics - ($lastexitcode)<br/>"
    }
    else {
      $endTime = (Get-Date -Format "yyy-MM-dd HH:mm:ss")
      Invoke-DbaQuery -SqlInstance 000-WINSRV-RPT -Database ITReporting -Query "INSERT INTO dbo.RobocopyBackups (Server, Share, Task, ExitCode, StartTime, EndTime) VALUES ('$server','$share', '$task', '$lastexitcode', '$startTime', '$endtime')"
    }

    $startTime = (Get-Date -Format "yyy-MM-dd HH:mm:ss")
    $task = "000-WINSRV-RTGP IT Folder Copy"
    $share = "IDPA"
    robocopy "\\000-winsrv-rtgp\c$\IT" "\\254-idpa-dd1.pharmaca.com\GP-Share\FileBackup\000-WINSRV-RTGP\IT" /e /mir /r:3 /w:120 /np /log+:E:\Scripts\GPShare-RobocopyLog.txt
    if ($lastexitcode -ge 8) {
      $endTime = (Get-Date -Format "yyy-MM-dd HH:mm:ss")
      Invoke-DbaQuery -SqlInstance 000-WINSRV-RPT -Database ITReporting -Query "INSERT INTO dbo.RobocopyBackups (Server, Share, Task, ExitCode, StartTime, EndTime) VALUES ('$server','$share', '$task', '$lastexitcode', '$startTime', '$endtime')"
      $serverlist += "000-WINSRV-RTGP - Directory: 000-WINSRV-RTGP\C$\IT - ($lastexitcode)<br/>"
    }
    else {
      $endTime = (Get-Date -Format "yyy-MM-dd HH:mm:ss")
      Invoke-DbaQuery -SqlInstance 000-WINSRV-RPT -Database ITReporting -Query "INSERT INTO dbo.RobocopyBackups (Server, Share, Task, ExitCode, StartTime, EndTime) VALUES ('$server','$share', '$task', '$lastexitcode', '$startTime', '$endtime')"
    }
    
    $startTime = (Get-Date -Format "yyy-MM-dd HH:mm:ss")
    $task = "000-SRV-GPPM2 Microsoft Dynamics Folder Copy"
    $share = "IDPA"
    robocopy "\\000-srv-gppm2\c$\Program Files (x86)\Microsoft Dynamics" "\\254-idpa-dd1.pharmaca.com\GP-Share\FileBackup\000-SRV-GPPM2\Microsoft Dynamics" /e /mir /r:3 /w:120 /np /log+:E:\Scripts\GPShare-RobocopyLog.txt
    if ($lastexitcode -ge 8) {
      $endTime = (Get-Date -Format "yyy-MM-dd HH:mm:ss")
      Invoke-DbaQuery -SqlInstance 000-WINSRV-RPT -Database ITReporting -Query "INSERT INTO dbo.RobocopyBackups (Server, Share, Task, ExitCode, StartTime, EndTime) VALUES ('$server','$share', '$task', '$lastexitcode', '$startTime', '$endtime')"
      $serverlist += "000-SRV-GPPM2 - Directory: 000-SRV-GPPM2\C$\Program Files (x86)\Microsoft Dynamics - ($lastexitcode)<br/>"
    }
    else {
      $endTime = (Get-Date -Format "yyy-MM-dd HH:mm:ss")
      Invoke-DbaQuery -SqlInstance 000-WINSRV-RPT -Database ITReporting -Query "INSERT INTO dbo.RobocopyBackups (Server, Share, Task, ExitCode, StartTime, EndTime) VALUES ('$server','$share', '$task', '$lastexitcode', '$startTime', '$endtime')"
    }

    $startTime = (Get-Date -Format "yyy-MM-dd HH:mm:ss")
    $task = "000-SRV-GPPM2 IT Folder Copy"
    $share = "IDPA"
    robocopy "\\000-srv-gppm2\C$\IT" "\\254-idpa-dd1.pharmaca.com\GP-Share\FileBackup\000-SRV-GPPM2\IT" /e /mir /r:3 /w:120 /np /log+:E:\Scripts\GPShare-RobocopyLog.txt
    if ($lastexitcode -ge 8) {
      $endTime = (Get-Date -Format "yyy-MM-dd HH:mm:ss")
      Invoke-DbaQuery -SqlInstance 000-WINSRV-RPT -Database ITReporting -Query "INSERT INTO dbo.RobocopyBackups (Server, Share, Task, ExitCode, StartTime, EndTime) VALUES ('$server','$share', '$task', '$lastexitcode', '$startTime', '$endtime')"
      $serverlist += "000-SRV-GPPM2 - Directory: 000-SRV-GPPM2\C$\IT - ($lastexitcode)<br/>"
    }
    else {
      $endTime = (Get-Date -Format "yyy-MM-dd HH:mm:ss")
      Invoke-DbaQuery -SqlInstance 000-WINSRV-RPT -Database ITReporting -Query "INSERT INTO dbo.RobocopyBackups (Server, Share, Task, ExitCode, StartTime, EndTime) VALUES ('$server','$share', '$task', '$lastexitcode', '$startTime', '$endtime')"
    }

    $startTime = (Get-Date -Format "yyy-MM-dd HH:mm:ss")
    $task = "032-SRV-DEVSQL Microsoft Dynamics Folder Copy"
    $share = "IDPA"
    robocopy "\\032-srv-devsql\c$\Program Files (x86)\Microsoft Dynamics" "\\254-idpa-dd1.pharmaca.com\GP-Share\FileBackup\032-SRV-DEVSQL\Microsoft Dynamics" /e /mir /r:3 /w:120 /np /log+:E:\Scripts\GPShare-RobocopyLog.txt
    if ($lastexitcode -ge 8) {
      $endTime = (Get-Date -Format "yyy-MM-dd HH:mm:ss")
      Invoke-DbaQuery -SqlInstance 000-WINSRV-RPT -Database ITReporting -Query "INSERT INTO dbo.RobocopyBackups (Server, Share, Task, ExitCode, StartTime, EndTime) VALUES ('$server','$share', '$task', '$lastexitcode', '$startTime', '$endtime')"
      $serverlist += "032-SRV-DEVSQL - Directory: 000-SRV-DEVSQL\C$\Program Files (x86)\Microsoft Dynamics - ($lastexitcode)<br/>"
    }
    else {
      $endTime = (Get-Date -Format "yyy-MM-dd HH:mm:ss")
      Invoke-DbaQuery -SqlInstance 000-WINSRV-RPT -Database ITReporting -Query "INSERT INTO dbo.RobocopyBackups (Server, Share, Task, ExitCode, StartTime, EndTime) VALUES ('$server','$share', '$task', '$lastexitcode', '$startTime', '$endtime')"
    }
    
    $startTime = (Get-Date -Format "yyy-MM-dd HH:mm:ss")
    $task = "032-SRV-DEVSQL IT Folder Copy"
    $share = "IDPA"
    robocopy "\\032-srv-devsql\e$\IT" "\\254-idpa-dd1.pharmaca.com\GP-Share\FileBackup\032-SRV-DEVSQL\IT" /e /mir /r:3 /w:120 /np /log+:E:\Scripts\GPShare-RobocopyLog.txt
    if ($lastexitcode -ge 8) {
      $endTime = (Get-Date -Format "yyy-MM-dd HH:mm:ss")
      Invoke-DbaQuery -SqlInstance 000-WINSRV-RPT -Database ITReporting -Query "INSERT INTO dbo.RobocopyBackups (Server, Share, Task, ExitCode, StartTime, EndTime) VALUES ('$server','$share', '$task', '$lastexitcode', '$startTime', '$endtime')"
      $serverlist += "032-SRV-DEVSQL - Directory: 000-SRV-DEVSQL\E$\IT - ($lastexitcode)<br/>"
    }
    else {
      $endTime = (Get-Date -Format "yyy-MM-dd HH:mm:ss")
      Invoke-DbaQuery -SqlInstance 000-WINSRV-RPT -Database ITReporting -Query "INSERT INTO dbo.RobocopyBackups (Server, Share, Task, ExitCode, StartTime, EndTime) VALUES ('$server','$share', '$task', '$lastexitcode', '$startTime', '$endtime')"
    }
    
   if ($serverlist -ne $null) {
      $fullbody += $bodystart + $serverlist + $bodyend
      Send-MailMessage -SmtpServer smtp.pharmaca.com -From "DEV Management Server <winsrvdevserver@pharmaca.com>" -Subject $subjectline -Body $fullbody -To developers@pharmaca.com -BodyAsHtml -Attachments E:\Scripts\RobocopyLogs\GPShare-RobocopyLog.txt
      remove-item \\254-idpa-dd1.pharmaca.com\GP-Share\GPShare-RobocopyLog.txt
      Exit
    }
    else {
      Try
        {
        Compress-7Zip -Path \\254-idpa-dd1.pharmaca.com\GP-Share\FileBackup -OutputPath \\254-idpa-dd1.pharmaca.com\GP-Share -ArchiveFileName ('GP-FileBackup ' + (Get-Date -Format yyyyMMdd) + '.zip') -CompressionLevel Fast -ErrorAction Stop
        Get-ChildItem \\254-idpa-dd1.pharmaca.com\GP-Share -File -Include GP-FileBackup*.zip | Where CreationTime -LT (Get-Date).AddDays(-60) | Remove-Item -Force -ErrorAction Stop
        }
      Catch
        {
        Send-MailMessage -SmtpServer smtp.pharmaca.com -From "DEV Management Server <winsrvdevserver@pharmaca.com>" -Subject "Error Compressing GP-Share Files" -Body "The backup to the GP-Share was successful but there was an error compressing the GP-Share directory on the IDPA." -To developers@pharmaca.com -Attachments \\254-idpa-dd1.pharmaca.com\GP-Share\GPShare-RobocopyLog.txt
        remove-item \\254-idpa-dd1.pharmaca.com\GP-Share\GPShare-RobocopyLog.txt
        Exit
        }   
     }

if (Test-Path -Path \\pharmacasqlbackups.file.core.windows.net\pharmacagpshare) {
    $startTime = (Get-Date -Format "yyy-MM-dd HH:mm:ss")
    $task = "GP-Share Copy"
    $share = "Azure"
    robocopy "\\254-idpa-dd1.pharmaca.com\GP-Share" "\\pharmacasqlbackups.file.core.windows.net\pharmacagpshare" /e /mir /r:3 /w:120 /np /log+:E:\Scripts\GPShare-RobocopyLog.txt
        if ($lastexitcode -ge 8) {
            $endTime = (Get-Date -Format "yyy-MM-dd HH:mm:ss")
            Send-MailMessage -SmtpServer smtp.pharmaca.com -From "DEV Management Server <winsrvdevserver@pharmaca.com>" -Subject 'The DR Backup Of The GP-Share To Azure Failed' -Body 'The GP-Share backup succeded but the DR sync to Azure share pharmacagpshare failed with exit code ' + $lastexitcode + ' on 000-WINSRV-DEV. Ensure the Azure share is available and resync as soon as possible.<br/>' + $bodyend -To developers@pharmaca.com -Attachments E:\Scripts\RobocopyLogs\GPShare-RobocopyLog.txt -BodyAsHtml
            Invoke-DbaQuery -SqlInstance 000-WINSRV-RPT -Database ITReporting -Query "INSERT INTO dbo.RobocopyBackups (Server, Share, Task, ExitCode, StartTime, EndTime) VALUES ('$server','$share', '$task', '$lastexitcode', '$startTime', '$endtime')"
            exit
    }
        }
        else {
            $endTime = (Get-Date -Format "yyy-MM-dd HH:mm:ss")
            Send-MailMessage -SmtpServer smtp.pharmaca.com -From "DEV Management Server <winsrvdevserver@pharmaca.com>" -Subject "GP Share File Backup Successful" -Body 'All steps of the GP file backup scheduled task on 000-WINSRV-DEV have completed successfully.' -To developers@pharmaca.com -Attachments E:\Scripts\RobocopyLogs\GPShare-RobocopyLog.txt
            Invoke-DbaQuery -SqlInstance 000-WINSRV-RPT -Database ITReporting -Query "INSERT INTO dbo.RobocopyBackups (Server, Share, Task, ExitCode, StartTime, EndTime) VALUES ('$server','$share', '$task', '$lastexitcode', '$startTime', '$endtime')"
            exit
        }

}
else {
    Send-MailMessage -SmtpServer smtp.pharmaca.com -From "DEV Management Server <winsrvdevserver@pharmaca.com>" -Subject "The GP-Share Is Unavailable" -Body "The GP-Share directory on the IDPA is unavailble to 000-WINSRV-DEV. Ensure the share is available as soon as possible." -To developers@pharmaca.com 
    Exit
    }