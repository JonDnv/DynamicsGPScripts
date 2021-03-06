USE [DYNAMICS]
GO
/****** Object:  StoredProcedure [dbo].[GPUserContactUpdate]    Script Date: 10/8/2021 11:11:36 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:		Jon Godwin
-- Create date: 2018-09-24
-- Description:	Updates GPUserContact Table With
--				New Users & Sets Inactive Users
-- =============================================
CREATE PROCEDURE [dbo].[GPUserContactUpdate]
AS
BEGIN
SET NOCOUNT ON;

INSERT INTO DYNAMICS.dbo.GPLastLogin
	(
	Name
	, LastLogin
	)
SELECT	S.USERID
		, GETDATE()
FROM	dbo.SY01400 S
WHERE	S.USERID NOT IN 
		(
		SELECT	GLL.Name
		FROM	dbo.GPLastLogin GLL
		)
;

INSERT INTO DYNAMICS.dbo.GPUserContact 
(
GPUserName
)
SELECT	S.USERID
FROM	dbo.SY01400 S
WHERE	S.USERID NOT IN 
		(
		SELECT	GUC.GPUserName
		FROM	dbo.GPUserContact GUC
		)
;

UPDATE DYNAMICS.dbo.GPUserContact
SET Active = 1 WHERE GPUserName 
IN (SELECT S.USERID FROM dbo.SY01400 S WHERE S.UserStatus = 1)
;

UPDATE DYNAMICS.dbo.GPUserContact 
SET Active = 0 WHERE GPUserName
NOT IN (SELECT S.USERID FROM dbo.SY01400 S WHERE S.UserStatus = 1)
;

IF OBJECT_ID('tempdb..#MissingContacts') IS NOT NULL
DROP TABLE #MissingContacts

SELECT	GUC.GPUserName
		, CASE WHEN GUC.FirstName IS NULL THEN 'MISSING' ELSE GUC.FirstName END AS FirstName
		, CASE WHEN GUC.LastName IS NULL THEN 'MISSING' ELSE GUC.LastName END AS LastName
		, CASE WHEN GUC.Email IS NULL THEN 'MISSING' ELSE GUC.Email END AS Email
		, CASE WHEN GUC.Active = 1 THEN 'Active' ELSE 'Inactive' END AS Active
INTO	#MissingContacts
FROM	DYNAMICS.dbo.GPUserContact GUC
WHERE	GUC.FirstName IS NULL 
		OR GUC.LastName IS NULL
		OR GUC.Email IS NULL

DECLARE @xml NVarchar(MAX)
DECLARE @body NVarchar(MAX)

SET @xml = CAST(( SELECT MC.GPUserName AS 'td','', MC.FirstName AS 'td','', MC.LastName AS 'td','',MC.Email AS 'td','',MC.Active AS 'td' FROM #MissingContacts MC FOR XML PATH('tr'), ELEMENTS ) AS NVARCHAR(MAX))

SET @xml = REPLACE(@xml,'<td>','<td align="Center">')

SET @body = '<html><body><H3 align="Center">GP Users Missing Contact Information</H3><table border = 1 align="Center"><tr><th align="Center"> GP User ID </th><th align = "Center"> First Name </th><th align = "Center"> Last Name </th><th align = "Center"> Email Address </th><th align = "Center"> Active User </th></tr>'

SET @body = @body + @xml + '</table></body></html>'

IF (SELECT COUNT(*) FROM DYNAMICS.dbo.GPUserContact GUC WHERE GUC.FirstName IS NULL OR GUC.LastName IS NULL OR GUC.Email IS NULL) >= 1
EXEC msdb.dbo.sp_send_dbmail
@profile_name = 'Dynamics Notifications', -- replace with your SQL Database Mail Profile 
@body = @body,
@body_format ='HTML',
@recipients = 'gp_admins@pharmaca.com', -- replace with your email address
@subject = 'GP Users Missing Contact Information' 
;

IF OBJECT_ID('tempdb..#MissingContacts') IS NOT NULL
DROP TABLE #MissingContacts
;

END
