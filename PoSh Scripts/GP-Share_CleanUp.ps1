Compress-7Zip -Path \\254-idpa-dd1.pharmaca.com\GP-Backups\GP-Share\ -OutputPath \\254-idpa-dd1.pharmaca.com\GP-Backups\ -ArchiveFileName ('GP-Share ' + (Get-Date -Format yyyyMMdd) + '.zip') -CompressionLevel Fast
Get-ChildItem \\254-idpa-dd1.pharmaca.com\GP-Backups\ -File -Include GP-Share*.zip | Where CreationTime -LT (Get-Date).AddDays(-90) | Remove-Item -Force
Exit