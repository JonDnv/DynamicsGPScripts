USE [DYNAMICS]
GO
/****** Object:  StoredProcedure [dbo].[ExtendedLoginEmail]    Script Date: 10/8/2021 11:11:16 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:		Jon Godwin
-- Create date: 2018-09-26
-- Description:	Checks for Users Logged In For 
--				An Extended Period of Time & 
--				Emails Notification to Them.
-- =============================================
ALTER PROCEDURE [dbo].[ExtendedLoginEmail] 
AS
BEGIN
SET NOCOUNT ON;

DECLARE @UserName Varchar(15)
DECLARE @FirstName Varchar(50)
DECLARE @Email Varchar(100)
DECLARE	@LoginTime DateTime
DECLARE @LoginDurationHours Int
DECLARE @Body NVarchar(MAX)
DECLARE @EmailSubject NVarchar(100)
DECLARE	@DomainName Varchar(MAX)
DECLARE	@cmd1 Varchar(1000)
DECLARE @cmd2 Varchar(1000)
DECLARE @sql Varchar(1000)
;

DECLARE	Contacts CURSOR LOCAL FAST_FORWARD READ_ONLY FOR

SELECT	A.USERID
		, A.LOGINDAT + A.LOGINTIM LogInTime
		, DATEDIFF(HOUR, A.LOGINDAT + A.LOGINTIM, GETDATE()) HoursLoggedIn
		, GUC.FirstName
		, GUC.Email
		, GUC.DomainName
FROM	DYNAMICS..ACTIVITY A
INNER JOIN
		DYNAMICS..GPUserContact GUC
			ON A.USERID = GUC.GPUserName
LEFT OUTER JOIN
		DYNAMICS..SY00800 S
			ON A.USERID = S.USERID
LEFT OUTER JOIN
		DYNAMICS..SY00801 S2
			ON A.USERID = S2.USERID
WHERE	DATEDIFF(HOUR, A.LOGINDAT + A.LOGINTIM, GETDATE()) >= 24
		AND S.USERID IS NULL
		AND S2.USERID IS NULL
		AND	A.USERID NOT IN ('sa', 'DYNSA', 'gpautopost','sqlguy','postmaster','rockysoft-gp','postmaster_1','postmaster_2','postmaster_3','postmaster_4', 'mishur', 'mishur_post')

OPEN Contacts
;

WHILE 1 = 1
BEGIN 
	FETCH NEXT FROM Contacts INTO @UserName, @LoginTime, @LoginDurationHours, @FirstName, @Email, @DomainName;
	IF @@FETCH_STATUS = -1 BREAK;

IF @LoginTime >= 24 AND @LoginTime < 72
BEGIN

	SET @Body =	@FirstName + ', <br/><br/>You are showing to be logged into GP with user name <i>' + @UserName +'</i>since ' 
				+ ' '  + CONVERT(Varchar(30),@LoginTime, 22) + '. You have been logged in for ' + CAST(DATEDIFF(HOUR, @LoginTime, GETDATE()) AS Varchar) + ' hours.<br/><br/>If you are actively working in Dynamics GP, please ignore this message. However, if you have left a session open, please note that GP is not designed to be left open indefinitely and should be closed when not in use. Please be sure to close your GP client using the standard process and reopen it before working any further.<br/><br/>If you do not have a client open, you may have a stuck session. Notify the Service Desk of this issue before opening a GP Client.<br/><br/>Thank You,<br/><br/>Dynamics GP Administrator<br/>dbanotifications@pharmaca.com'

	SET @EmailSubject = 'Extended GP Login - ' + CAST(@LoginDurationHours AS Varchar(15)) + ' Hours'

	EXEC msdb.dbo.sp_send_dbmail
		@profile_name = 'Dynamics Notifications'
		, @recipients = @Email
		, @copy_recipients = 'gp_admins@pharmaca.com'
		, @subject = @EmailSubject
		, @body = @Body
		, @body_format = 'HTML'
	;

END

ELSE

IF @LoginTime >= 72
BEGIN		

	SET @cmd1 = 'powershell "$computerName = ''000-winsrv-rdgp''; $userName = ''' + @DomainName + '''; $quserResult = quser $userName /SERVER$computerName; $quserRegex = $quserResult | ForEach-Object -Process { $_ -replace ''\s{2,}'','','' }; $quserObject = $quserRegex | ConvertFrom-Csv; $userSession = $quserObject | Where-Object -FilterScript {$_.USERNAME -eq $userName}; logoff $userSession.ID /server:$computerName"'

	PRINT @cmd1

	--EXEC master..xp_cmdshell @cmd1

	SET @cmd2 = 'powershell "$computerName = ''000-winsrv-rtgp''; $userName = ''' + @DomainName + '''; $quserResult = quser $userName /SERVER$computerName; $quserRegex = $quserResult | ForEach-Object -Process { $_ -replace ''\s{2,}'','','' }; $quserObject = $quserRegex | ConvertFrom-Csv; $userSession = $quserObject | Where-Object -FilterScript {$_.USERNAME -eq $userName}; logoff $userSession.ID /server:$computerName"'

	PRINT @cmd2
	--EXEC master..xp_cmdshell @cmd2

	SET	@sql = 'DELETE DYNAMICS.dbo.ACTIVITY WHERE USERID = ''' + @UserName + ''''

	EXEC (@sql)
	
	SET @Body =	@FirstName + ', <br/><br/>You you have been logged into GP with user name <i>' + @UserName +'</i>since ' 
				+ ' '  + CONVERT(Varchar(30),@LoginTime, 22) + '. You have been logged in for ' + CAST(DATEDIFF(HOUR, @LoginTime, GETDATE()) AS Varchar) + ' hours and are showing no activity on your account.<br/><br/>Due to the lack of activity on your account, your Dynamics GP session is being terminated.<br/><br/>If you did not have a client open, you may have had a stuck session. Notify the Service Desk of this issue before opening a Dynamics GP Client.<br/><br/>Thank You,<br/><br/>Dynamics GP Administrator<br/>dbanotifications@pharmaca.com'

	SET @EmailSubject = 'GP Session Terminated - ' + @UserName

	EXEC msdb.dbo.sp_send_dbmail
		@profile_name = 'Dynamics Notifications'
		, @recipients = @Email
		, @copy_recipients = 'gp_admins@pharmaca.com'
		, @subject = @EmailSubject
		, @body = @Body
		, @body_format = 'HTML'
;

END
;

END	

CLOSE Contacts
;

DEALLOCATE Contacts
;

RETURN
;

END
