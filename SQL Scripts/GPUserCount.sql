USE [DYNAMICS]
GO
/****** Object:  StoredProcedure [dbo].[GPUserCount]    Script Date: 10/8/2021 11:11:41 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO


-- =============================================
-- Author:		Jon Godwin
-- Create date: 2018-03-07
-- Description:	Procedure captures concurrent GP Users at the time of execution.
--				Should be scheduled frequently and is Summarized in the GPUserRoundUp table.
-- =============================================
CREATE PROCEDURE [dbo].[GPUserCount]
	
AS
BEGIN

SET NOCOUNT ON;

INSERT INTO dbo.GPCurrentUsers
	(
	QueryTime
	, CurrentUserCount
	)
	(
	SELECT	GetDate() --QueryTime
			, (SELECT Count(*) FROM DYNAMICS..ACTIVITY) --CurrentUserCount
	)

END
