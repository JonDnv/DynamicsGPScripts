USE [DYNAMICS]
GO
/****** Object:  StoredProcedure [dbo].[GPUserActivate]    Script Date: 10/8/2021 11:11:26 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

-- =============================================
-- Author:		Jon Godwin
-- Create date: 2018-03-09
-- Description:	Inactivates Users That Have Not Logged In in over 90 Days.
-- =============================================
ALTER PROCEDURE [dbo].[GPUserActivate] 
	
@UserName Varchar(20)

AS
BEGIN

SET NOCOUNT ON;

UPDATE	dbo.SY01400 
SET		UserStatus = 1
WHERE	UserStatus <> 3
		AND USERID = @UserName
		
END
