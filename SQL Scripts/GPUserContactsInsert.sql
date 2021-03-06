USE [DYNAMICS]
GO
/****** Object:  StoredProcedure [dbo].[GPUserContactsInsert]    Script Date: 10/8/2021 11:11:31 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

-- =============================================
-- Author:		Jon Godwin
-- Create date: 2018-09-21
-- Description:	Job Emails Users Logged In Over
--				12 Hours and Advises Them to 
--				Close & Reopen GP Before Using 
--				Further
-- =============================================
CREATE PROCEDURE [dbo].[GPUserContactsInsert] 

@UserName Varchar(15)
, @FirstName Varchar(50)
, @LastName Varchar(50)
, @Email Varchar(100)

AS
BEGIN
SET NOCOUNT ON;

IF @UserName NOT IN (SELECT GPUserName FROM GPUserContact)
INSERT	DYNAMICS.dbo.GPUserContact 
(
GPUserName
, FirstName
, LastName
, Email
)
SELECT	@UserName
		, @FirstName
		, @LastName
		, @Email

END
