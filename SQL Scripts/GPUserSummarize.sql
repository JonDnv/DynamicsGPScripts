USE [DYNAMICS]
GO
/****** Object:  StoredProcedure [dbo].[GPUserSummarize]    Script Date: 10/8/2021 11:11:49 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO


-- =============================================
-- Author:		Jon Godwin
-- Create date: 2018-03-07
-- Description:	Summarizes the GPCurrentUsers Table on a Daily Basis.
--				Should be scheduled to run daily.
--				Used to check for License Bloat.
-- =============================================
CREATE PROCEDURE [dbo].[GPUserSummarize] 

AS
BEGIN

SET NOCOUNT ON;

INSERT INTO	dbo.GPUserRoundUp
	(
	QueryDate
	, MinUsers
	, AvgUsers
	, MaxUsers
	, MaxID
	)	
	(
	SELECT	Convert(Date,Min(QueryTime)) --QueryDate
			, Min(CurrentUserCount) --MinUsers
			, Ceiling(Avg(CurrentUserCount)) --AvgUsers
			, Max(CurrentUserCount) --MaxUsers
			, Max(ID) --MaxID
	FROM	dbo.GPCurrentUsers 
	WHERE	Convert(Date, QueryTime) = Convert(Date,GetDate()-1)
	)

END
