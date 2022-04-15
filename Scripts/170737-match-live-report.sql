
/*<info serverAlias="DBOWP-bodb_OWP" executers="bodbOWPNet" isFunction="0"></info>*/
/*
Created: 20220401@Tyler
Task : Match live report
DB: bodb_OWP	

Revisions:
	20220401@Tyler: Init script - [Redmine: #170737]
*/

IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[MatchLiveReport]') AND type in (N'U'))
DROP TABLE [dbo].[MatchLiveReport]
GO

SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

CREATE TABLE [dbo].[MatchLiveReport](
	[Id] [int] IDENTITY(1,1) NOT NULL,
	[EventDate] [date] NOT NULL,
	[LeagueCategory] [nvarchar](20) NOT NULL,
	[BetType] [nvarchar](100) NOT NULL,
	[IsSaba] [bit] NOT NULL,
	[MatchCount] [int] NOT NULL
) ON [OWP_Data]
GO

CREATE CLUSTERED INDEX IX_MatchLiveReport_EventDate   
    ON dbo.MatchLiveReport (EventDate);
GO
