USE [DYNAMICS]
GO

/****** Object:  Table [dbo].[GPUserContact]    Script Date: 10/8/2021 11:17:02 AM ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

CREATE TABLE [dbo].[GPUserContact](
	[ID] [Int] IDENTITY(1,1) NOT FOR REPLICATION NOT NULL,
	[GPUserName] [Varchar](15) NOT NULL,
	[FirstName] [Varchar](50) NULL,
	[LastName] [Varchar](50) NULL,
	[DomainName] [Varchar](50) NULL,
	[Email] [Varchar](100) NULL,
	[Active] [Bit] NULL,
 CONSTRAINT [PK_GPUserContact] PRIMARY KEY CLUSTERED 
(
	[ID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]
GO


