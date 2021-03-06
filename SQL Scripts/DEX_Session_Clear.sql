USE [DYNAMICS]
GO
/****** Object:  StoredProcedure [dbo].[DEX_Session_Clear]    Script Date: 10/8/2021 11:11:06 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:		Jon Godwin
-- Create date: 2019-01-07
-- Description:	Clears Stuck Sessions in the 
--				DEX_SESSION Table
-- =============================================
CREATE PROCEDURE [dbo].[DEX_Session_Clear] 

AS
BEGIN
SET NOCOUNT ON;

DELETE TempDB..DEX_SESSION where Session_ID not in (SELECT SQLSESID from DYNAMICS..ACTIVITY)
DELETE TempDB..DEX_LOCK where Session_ID not in (SELECT SQLSESID from DYNAMICS..ACTIVITY)


END
