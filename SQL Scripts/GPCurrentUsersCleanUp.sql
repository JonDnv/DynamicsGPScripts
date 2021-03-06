USE [DYNAMICS]
GO
/****** Object:  StoredProcedure [dbo].[GPCurrentUsersCleanUp]    Script Date: 10/8/2021 11:11:21 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO


-- =============================================
-- Author:		Jon Godwin
-- Create date: 2018-03-07
-- Description:	Removes Old Data from the GPCurrentUsers table.
-- =============================================
CREATE PROCEDURE [dbo].[GPCurrentUsersCleanUp]
	
AS
BEGIN

SET NOCOUNT ON;

DELETE	dbo.GPCurrentUsers
WHERE	QueryTime < DateAdd(DAY,-7,GetDate())

END
