USE [DYNAMICS]
GO

/****** Object:  Table [dbo].[GPCurrentUsers]    Script Date: 10/8/2021 11:16:11 AM ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

CREATE TABLE [dbo].[GPCurrentUsers](
	[ID] [Int] IDENTITY(1,1) NOT NULL,
	[QueryTime] [DateTime] NULL,
	[CurrentUserCount] [Int] NULL
) ON [PRIMARY]
GO


