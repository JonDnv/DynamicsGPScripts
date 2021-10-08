$server = '000-WINSRV-DEV'
$task = 'GP-Share Copy'
$share = 'Azure'
$startTime = $null
$endTime = $null
$bodyend = "<br/>Failure Exit Code Definitions:<br/>2 - Extra files or directories were detected.<br/>8 - Some files or directories could not be copied and the retry limit was exceeded.<br/> 16 - Robocopy did not copy any files. Check parameters & share rights."

if (Test-Path -Path \\254-idpa-dd1.pharmaca.com\GP-Share\Autocomplete) {
Try
{
    Get-ChildItem \\254-idpa-dd1.pharmaca.com\GP-Share\Autocomplete -Recurse -File | Remove-Item -Force -ErrorAction Stop

    Get-ChildItem '\\000-winsrv-rtgp\c$\Users\*\appdata\Roaming' -Recurse -Include *.dat, *.idx |  foreach {
    $split = $_.Fullname  -split '\\'
    $DestFile =  $split[1..($split.Length - 1)] -join '\' 
    $DestFile =  "\\254-idpa-dd1.pharmaca.com\GP-Share\Autocomplete\000-WINSRV-RTGP\$DestFile"
    $null = New-Item -Path  $DestFile -Type File -Force
    Copy-Item -Path  $_.FullName -Destination $DestFile -Force
    } -ErrorAction Stop

    Get-ChildItem '\\000-winsrv-rdgp\c$\Users\*\appdata\Roaming' -Recurse -Include *.dat, *.idx |  foreach {
    $split = $_.Fullname  -split '\\'
    $DestFile =  $split[1..($split.Length - 1)] -join '\' 
    $DestFile =  "\\254-idpa-dd1.pharmaca.com\GP-Share\Autocomplete\000-WINSRV-RDGP\$DestFile"
    $null = New-Item -Path  $DestFile -Type File -Force
    Copy-Item -Path  $_.FullName -Destination $DestFile -Force
    } -ErrorAction Stop
}
Catch {
   Send-MailMessage -SmtpServer smtp.pharmaca.com -From "DEV Management Server <winsrvdevserver@pharmaca.com>" -Subject "GP Autocomplete Backup Failed" -Body "The GP autocomplete backup scheduled task on 000-WINSRV-DEV has failed. Verify functionality and rerun." -To developers@pharmaca.com 
   Exit
}
    
Try {
    Compress-Archive \\254-idpa-dd1.pharmaca.com\GP-Share\Autocomplete\ -DestinationPath ('\\254-idpa-dd1.pharmaca.com\GP-Share\Autocomplete ' + (Get-Date -Format yyyyMMdd) + '.zip') -ErrorAction Stop
    Get-ChildItem \\254-idpa-dd1.pharmaca.com\GP-Share -File -Include Autocomplete*.zip | Where CreationTime -LT (Get-Date).AddDays(-14) | Remove-Item -Force -ErrorAction Stop
}
Catch {
    Send-MailMessage -SmtpServer smtp.pharmaca.com -From "DEV Management Server <winsrvdevserver@pharmaca.com>" -Subject "GP Autocomplete File Compression Failed" -Body "The file compression portion of the GP autocomplete backups scheduled task on 000-WINSRV-DEV has failed. Verify functionality and rerun." -To developers@pharmaca.com
    exit
}

if (Test-Path -Path \\pharmacasqlbackups.file.core.windows.net\pharmacagpshare) {
    $startTime = (Get-Date -Format "yyy-MM-dd HH:mm:ss")
    robocopy "\\254-idpa-dd1.pharmaca.com\GP-Share" "\\pharmacasqlbackups.file.core.windows.net\pharmacagpshare" /e /mir /r:3 /w:120 /np /log:E:\Scripts\GPShare-RobocopyLog.txt
        if ($lastexitcode -ge 8) {
            $endTime = (Get-Date -Format "yyy-MM-dd HH:mm:ss")
            Send-MailMessage -SmtpServer smtp.pharmaca.com -From "DEV Management Server <winsrvdevserver@pharmaca.com>" -Subject 'The DR Backup Of The GP-Share To Azure Failed' -Body 'The GP Autocomplete Backup scheduled task succeded but the GP-Share file copy to Azure share "pharmacagpshare" failed with exit code ' + $lastexitcode + ' on 000-WINSRV-DEV. Ensure the Azure share is available and resync as soon as possible.<br/>' + $bodyend -To developers@pharmaca.com -Attachments E:\Scripts\GPShare-RobocopyLog.txt -BodyAsHtml
            Invoke-DbaQuery -SqlInstance 000-WINSRV-RPT -Database ITReporting -Query "INSERT INTO dbo.RobocopyBackups (Server, Share, Task, ExitCode, StartTime, EndTime) VALUES ('$server','$share', '$task', '$lastexitcode', '$startTime', '$endtime')"
            exit
    }
        else {
            $endTime = (Get-Date -Format "yyy-MM-dd HH:mm:ss")
            Invoke-DbaQuery -SqlInstance 000-WINSRV-RPT -Database ITReporting -Query "INSERT INTO dbo.RobocopyBackups (Server, Share, Task, ExitCode, StartTime, EndTime) VALUES ('$server','$share', '$task', '$lastexitcode', '$startTime', '$endtime')"
            exit
        }
} else {
    Send-MailMessage -SmtpServer smtp.pharmaca.com -From "DEV Management Server <winsrvdevserver@pharmaca.com>" -Subject "The Azure Share pharmacagpshare Is Unavailable" -Body "The Azure share pharmacagpshare is unavailble to 000-WINSRV-DEV. Ensure the share is available as soon as possible." -To developers@pharmaca.com
    Exit
}
}

else {
    Send-MailMessage -SmtpServer smtp.pharmaca.com -From "DEV Management Server <winsrvdevserver@pharmaca.com>" -Subject "The GP-Share Is Unavailable" -Body "The GP-Share directory on the IDPA is unavailble to 000-WINSRV-DEV. Ensure the share is available as soon as possible." -To developers@pharmaca.com
    Exit
}