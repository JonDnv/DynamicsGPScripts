robocopy "\\000-srv-ptapp\c$\Program Files (x86)\Panatrack" "\\254-idpa-dd1.pharmaca.com\GP-Backups\GP-Share\000-SRV-PTAPP\Panatrack" /e /mir /r:3 /w:120 /np

robocopy "\\000-winsrv-rdgp\c$\Program Files (x86)\Microsoft Dynamics" "\\254-idpa-dd1.pharmaca.com\GP-Backups\GP-Share\000-WINSRV-RDGP\Microsoft Dynamics" /e /mir /r:3 /w:120 /np

robocopy "\\000-winsrv-rdgp\c$\IT" "\\254-idpa-dd1.pharmaca.com\GP-Backups\GP-Share\000-WINSRV-RDGP\IT" /e /mir /r:3 /w:120 /np

Powershell.exe -executionpolicy remotesigned -Verb RunAs -File  C:\Scripts\RDGP-GPAutoCompleteBackup.ps1

robocopy "\\000-winsrv-rtgp\c$\Program Files (x86)\Microsoft Dynamics" "\\254-idpa-dd1.pharmaca.com\GP-Backups\GP-Share\000-WINSRV-RTGP\Microsoft Dynamics" /e /mir /r:3 /w:120 /np

robocopy "\\000-winsrv-rtgp\c$\IT" "\\254-idpa-dd1.pharmaca.com\GP-Backups\GP-Share\000-WINSRV-RTGP\IT" /e /mir /r:3 /w:120 /np

Powershell.exe -executionpolicy remotesigned -Verb RunAs -File  C:\Scripts\RTGP-GPAutoCompleteBackup.ps1

robocopy "\\000-srv-gppm2\c$\Program Files (x86)\Microsoft Dynamics" "\\254-idpa-dd1.pharmaca.com\GP-Backups\GP-Share\000-SRV-GPPM2\Microsoft Dynamics" /e /mir /r:3 /w:120 /np

robocopy "\\000-srv-gppm2\c$\IT" "\\254-idpa-dd1.pharmaca.com\GP-Backups\GP-Share\000-SRV-GPPM2\IT" /e /mir /r:3 /w:120 /np

robocopy "\\032-srv-devsql\c$\Program Files (x86)\Microsoft Dynamics" "\\254-idpa-dd1.pharmaca.com\GP-Backups\GP-Share\032-SRV-DEVSQL\Microsoft Dynamics" /e /mir /r:3 /w:120 /np

robocopy "\\032-srv-devsql\e$\IT" "\\254-idpa-dd1.pharmaca.com\GP-Backups\GP-Share\032-SRV-DEVSQL\IT" /e /mir /r:3 /w:120 /np

Powershell.exe -executionpolicy remotesigned -Verb RunAs -File  C:\Scripts\GP-Share_CleanUp.ps1