USE bodb_OWP
GO

-- create table InfoSiteMatch
CREATE TABLE [dbo].[InfoSiteMatch](
	[InfoSiteMatchId] [int] NOT NULL,
	[EventDateTime] [datetime] NOT NULL,
	[UpdatedTime] [datetime] NOT NULL,
	[LeagueName] [nvarchar](2000) NOT NULL,
	[HomeName] [nvarchar](2000) NOT NULL,
	[AwayName] [nvarchar](2000) NOT NULL,
	[Round] [nvarchar](2000) NULL,
	[Division] [nvarchar](2000) NULL,
	[Agent] [nvarchar](2000) NULL,
	[TV] [nvarchar](2000) NULL,
	[Channel] [nvarchar](2000) NULL,
	[WB] [nvarchar](2000) NULL,
	[Website1] [nvarchar](2000) NULL,
	[Website2] [nvarchar](2000) NULL,
	[Website3] [nvarchar](2000) NULL,
	[Website4] [nvarchar](2000) NULL,
	[OWPLeagueId] [int] NOT NULL,
	[OWPHomeId] [int] NOT NULL,
	[OWPAwayId] [int] NOT NULL,
	[AgentIds] [varchar](200) NULL,
	[TVIds] [varchar](200) NULL,
 CONSTRAINT [PK_InfoSiteMatch] PRIMARY KEY CLUSTERED 
(
	[InfoSiteMatchId] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [OWP_Data]
) ON [OWP_Data]
GO

-- indexing
CREATE NONCLUSTERED INDEX	IX_InfoSiteMatch_EventDateTime ON dbo.InfoSiteMatch (
								EventDateTime ASC
							) ON OWP_Index;
							
CREATE NONCLUSTERED INDEX 	IX_InfoSiteMatch_UpdatedTime ON [dbo].[InfoSiteMatch](
								[UpdatedTime] ASC
							) ON [OWP_Index];

CREATE NONCLUSTERED INDEX	IX_OWPMatch_EventDateTime ON dbo.OWPMatch (
								EventDateTime ASC
							) ON OWP_Index;

CREATE NONCLUSTERED INDEX	IX_MatchInfo_IsSelected ON dbo.MatchInfo (
								IsSelected DESC
							)
							INCLUDE (OWPMatchId) ON OWP_Index;

CREATE NONCLUSTERED INDEX	IX_MinorMatch_ParentMatchId ON dbo.MinorMatch (
								ParentMatchId ASC
							)
							 ON OWP_Index;
GO

-- Add column InfoSiteMatchId to table OWPMatch							 
ALTER TABLE [dbo].[OWPMatch]
ADD [InfoSiteMatchId] INT NULL;					 
GO

-- Rename column MatchId to InfoSiteMatchId in table AssignmentUploading	
ALTER TABLE dbo.AssignmentUploading
DROP CONSTRAINT DF_AssignmentUploading_MatchId;

EXECUTE sys.sp_rename 'dbo.AssignmentUploading.MatchId', 'InfoSiteMatchId', 'COLUMN';

ALTER TABLE dbo.AssignmentUploading ADD  CONSTRAINT DF_AssignmentUploading_InfoSiteMatchId  DEFAULT (N'') FOR InfoSiteMatchId;
GO
