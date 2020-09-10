
/*<info serverAlias="DBOWP-bodb_OWP" executers="bodbOWPNet" isFunction="0"></info>*/
/*
Created: 20200811@Mira
Task : Pre-Match assignment
DB: bodb_OWP	

Revisions:
	20200811@Mira: Pre-Match assignment - [Redmine: #138643]
	20200818@Tyler: Pre-Match assignment log - [Redmine: #138643]
*/

/****** Object:  Table [dbo].[PreMatchAssignment]    Script Date: 8/24/2020 10:08:15 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

IF OBJECT_ID('dbo.PreMatchAssignment', 'U') IS NOT NULL 
DROP TABLE dbo.[PreMatchAssignment]; 
GO
CREATE TABLE [dbo].[PreMatchAssignment](
	[PreMatchLeagueId] [int] NOT NULL,
	[UserId] [int] NOT NULL,
	[Bettype] [int] NOT NULL,
	[IsTakeOver] [bit] NOT NULL,
 CONSTRAINT [PK_PreMatchAssignment] PRIMARY KEY CLUSTERED 
(
	[PreMatchLeagueId] ASC,
	[UserId] ASC,
	[Bettype] ASC,
	[IsTakeOver] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [OWP_Data]
) ON [OWP_Data]
GO

/****** Object:  Table [dbo].[PreMatchLeague]    Script Date: 8/24/2020 10:08:15 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF OBJECT_ID('dbo.PreMatchLeague', 'U') IS NOT NULL 
DROP TABLE dbo.[PreMatchLeague]; 
GO
CREATE TABLE [dbo].[PreMatchLeague](
	[PreMatchLeagueId] [int] IDENTITY(1,1) NOT NULL,
	[OWPLeagueId] [int] NOT NULL,
	[EventDate] [date] NOT NULL,
	[IsDay] [bit] NOT NULL,
	[IsDeleted] [bit] NOT NULL,
	[Remark] [nvarchar](2000) NULL,
 CONSTRAINT [PK_PreMatchLeague] PRIMARY KEY CLUSTERED 
(
	[PreMatchLeagueId] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [OWP_Data]
) ON [OWP_Data]
GO

/****** Object:  Table [dbo].[PreMatchNightShiftStartTime]    Script Date: 8/24/2020 10:08:15 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF OBJECT_ID('dbo.PreMatchNightShiftStartTime', 'U') IS NOT NULL 
DROP TABLE dbo.[PreMatchNightShiftStartTime]; 
GO
CREATE TABLE [dbo].[PreMatchNightShiftStartTime](
	[EventDate] [date] NOT NULL,
	[StartTime] [time](7) NOT NULL,
 CONSTRAINT [PK_PreMatchNightShiftStartTime] PRIMARY KEY CLUSTERED 
(
	[EventDate] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [OWP_Data]
) ON [OWP_Data]
GO

INSERT INTO [dbo].[Module] ([ModuleId], [ModuleName])
SELECT 10, 'PreMatchAssignment'
WHERE NOT EXISTS(SELECT 1 FROM [dbo].[Module] WITH(NOLOCK) WHERE [ModuleId] = 1)

INSERT INTO [dbo].[ModuleObject]([ModuleObjectId], [ModuleObjectName], [ModuleId])
SELECT 34, 'ShiftAssignment', 10
WHERE NOT EXISTS(SELECT 1 FROM [dbo].[ModuleObject] WITH(NOLOCK) WHERE [ModuleObjectId] = 34)

INSERT INTO [dbo].[ModuleObject]([ModuleObjectId], [ModuleObjectName], [ModuleId])
SELECT 35, 'Remark', 10
WHERE NOT EXISTS(SELECT 1 FROM [dbo].[ModuleObject] WITH(NOLOCK) WHERE [ModuleObjectId] = 35)

INSERT INTO [dbo].[ModuleObject]([ModuleObjectId], [ModuleObjectName], [ModuleId])
SELECT 36, 'League', 10
WHERE NOT EXISTS(SELECT 1 FROM [dbo].[ModuleObject] WITH(NOLOCK) WHERE [ModuleObjectId] = 36)

INSERT INTO [dbo].[ModuleObject]([ModuleObjectId], [ModuleObjectName], [ModuleId])
SELECT 37, 'NightShiftStartTime', 10
WHERE NOT EXISTS(SELECT 1 FROM [dbo].[ModuleObject] WITH(NOLOCK) WHERE [ModuleObjectId] = 37)


INSERT INTO [dbo].[LogActionType]([ActionTypeName])
SELECT  'Recover'
WHERE NOT EXISTS(SELECT 1 FROM [dbo].[LogActionType] WITH(NOLOCK) WHERE [ActionTypeName] = 'Recover')

IF NOT EXISTS (SELECT 1 FROM [LogAction] WHERE ActionId BETWEEN 113 AND 117)
	INSERT INTO [dbo].[LogAction]
([ActionId], 
 [ModuleId], 
 [ModuleObjectId], 
 [ActionTypeId], 
 [ActionName], 
 [SPName], 
 [LogItems]
)
VALUES
(113, 
 10, 
 34, 
 2, 
 N'OWPPreMatchAssignmentUpdateAssignment', 
 N'OWP_PreMatchAssignment_InsertUpdateDeleteAssignment', 
 N'<root><xml path="r/z" /><row item="PreMatchLeagueId" alias="plid" /><row item="UserId" alias="uid" /><row item="Username" alias="un" /><row item="Bettype" alias="bt" /><row item="IsTakeOver" alias="ito" /></root>'
),
(114, 
 10, 
 36, 
 3, 
 N'OWPPreMatchAssignmentDeleteLeague', 
 N'OWP_PreMatchAssignment_DeleteLeague', 
 N'<root><xml path="r/z" /><row item="PreMatchLeagueId" alias="plid" /></root>'
),
(115, 
 10, 
 36, 
 4, 
 N'OWPPreMatchAssignmentRecoverLeague', 
 N'OWP_PreMatchAssignment_Recover', 
 N'<root><xml path="r/z" /><row item="PreMatchLeagueId" alias="plid" /></root>'
),
(116, 
 10, 
 35, 
 2, 
 N'OWPPreMatchAssignmentUpdateRemark', 
 N'OWP_PreMatchAssignment_UpdateRemark', 
 N'<root><xml path="r/z" /><row item="PreMatchLeagueId" alias="plid" /><row item="Remark" alias="rm" /></root>'
),
(117, 
 10, 
 37, 
 2, 
 N'OWPPreMatchAssignmentUpdateStartTime', 
 N'OWP_PreMatchAssignment_UpdateStartTime', 
 N'<root><xml path="r/z" /><row item="EventDate" alias="d" /><row item="StartTime" alias="t" /></root>'
);


IF EXISTS (SELECT * FROM sys.objects WHERE type = 'P' AND name = 'OWP_Infosite_TruncateCacheTable')
	DROP PROCEDURE OWP_Infosite_TruncateCacheTable
GO

