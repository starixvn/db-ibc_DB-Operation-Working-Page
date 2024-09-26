
/*<info serverAlias="DBOWP-bodb_OWP" executers="wsv_owp" isFunction="0"></info>*/
/*
Created: 20200811@Mira
Task : Event Checking New Add
DB: bodb_OWP	

Revisions:
	20201020@Mira: EventCheckingNewAdd - [Redmine: #140772]
	20201020@Esther: Remove EventDate from PreMatchIssue - [Redmine: #140772]
*/
/****** Object:  Table [dbo].[NewAddRequest]    Script Date: 10/20/2020 9:39:18 AM ******/

SET ANSI_NULLS ON;
GO
SET QUOTED_IDENTIFIER ON;
GO

CREATE TABLE [dbo].[NewAddRequest]
([PrematchIssueId] [INT] NOT NULL, 
 [LeagueName]      [NVARCHAR](500) NOT NULL, 
 [MatchName]       [NVARCHAR](500) NULL, 
 CONSTRAINT [PK_NewAddRequest] PRIMARY KEY CLUSTERED([PrematchIssueId] ASC)
 WITH(PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [OWP_Data]
)
ON [OWP_Data];
GO

ALTER TABLE dbo.[PreMatchIssue] 
DROP COLUMN EventDate;