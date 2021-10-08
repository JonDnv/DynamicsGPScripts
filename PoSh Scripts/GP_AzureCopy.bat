robocopy "\\254-idpa-dd1.pharmaca.com\GP-Backups" "\\pharmacasqlbackups.file.core.windows.net\pharmacagp" /e /mir /r:3 /w:120 /np
REM: suppress errors of anything < 24 because of robocopy craziness:
SET/A errlev="%ERRORLEVEL% & 24"
exit/B %errlev%