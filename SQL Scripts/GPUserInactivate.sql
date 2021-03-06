USE [DYNAMICS]
GO
/****** Object:  StoredProcedure [dbo].[GPUserInactivate]    Script Date: 10/8/2021 11:11:45 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:		Jon Godwin
-- Create date: 2018-03-09
-- Description:	Inactivates Users That Have Not Logged In in over 90 Days.
-- =============================================
CREATE PROCEDURE [dbo].[GPUserInactivate] 
	
AS
BEGIN

SET NOCOUNT ON;

----Old Logic
----UPDATE	dbo.SY01400 
----SET		UserStatus = 2
----WHERE	UserStatus <> 3
----		AND USERID NOT IN ('sa', 'DYNSA', 'gpautopost','sqlguy','postmaster','rockysoft-gp','postmaster_1','postmaster_2','postmaster_3','postmaster_4')
----		AND USERID NOT IN 
----				(
----				SELECT	Name
----				FROM	dbo.GPLastLogin
----				WHERE	LastLogin > DateAdd(DAY,-90,GetDate())
----				)

--Update to Send Email When Account is Deactivated
DECLARE @UserName Varchar(15)
DECLARE @FirstName Varchar(50)
DECLARE @Email Varchar(100)
DECLARE	@LastLogin DateTime
DECLARE	@UserStatus Int
DECLARE @Body NVarchar(MAX)
DECLARE @EmailSubject NVarchar(100)
;

DECLARE	DeactivatedUsers CURSOR LOCAL FAST_FORWARD READ_ONLY FOR
	SELECT	GLL.Name
			, GLL.LastLogin
			, GUC.FirstName
			, GUC.Email
			, S.UserStatus
	FROM	dbo.GPLastLogin GLL
	INNER JOIN	
			dbo.GPUserContact GUC
				ON GLL.Name = GUC.GPUserName
	INNER JOIN	
			dbo.SY01400 S
				ON GLL.Name = S.USERID
	WHERE	GLL.LastLogin < DATEADD(DAY,-90,GETDATE())
			AND GLL.Name NOT IN ('sa', 'DYNSA', 'gpautopost','sqlguy','postmaster','rockysoft-gp','postmaster_1','postmaster_2','postmaster_3','postmaster_4')
			AND S.UserStatus = 1
;

OPEN DeactivatedUsers
;

WHILE 1 = 1
BEGIN 
	FETCH NEXT FROM DeactivatedUsers INTO @UserName, @LastLogin, @FirstName, @Email, @UserStatus;
	IF @@FETCH_STATUS = -1 BREAK;

	UPDATE	dbo.SY01400 
	SET		UserStatus = 2
	WHERE	USERID = @UserName

	SET @Body =	@FirstName + ', <br/><br/>Your Dynamics GP account - <i>' + @UserName + '</i> has been deactivated due to inactivity. Your last log in to Dynamics GP was on ' + CONVERT(Varchar,@LastLogin,101) + '. If you need your account to be reactivated, please contact the Service Desk.'
				+ '<br/><br/>Thank You,<br/><br/>Dynamics GP Administrator<br/>dbanotifications@pharmaca.com'

	SET @EmailSubject = 'GP Account Deactivated - ' + @UserName

EXEC msdb.dbo.sp_send_dbmail
	@profile_name = 'Dynamics Notifications'
	, @recipients = @Email
	, @copy_recipients = 'gp_admins@pharmaca.com; developers@pharmaca.com'
	, @subject = @EmailSubject
	, @body = @Body
	, @body_format = 'HTML'

END	

CLOSE DeactivatedUsers
;

DEALLOCATE DeactivatedUsers
;

RETURN
;

END
