
/*<info serverAlias="DBOWP-bodb_OWP" executers="bodbOWPNet" isFunction="0"></info>*/
/*
Created: 20200929@Tyler
Task : Pre-Match enhancement
DB: bodb_OWP	

Revisions:
	20200929@Tyler: Alter DB - [Redmine: #142258]
*/

CREATE TABLE [dbo].[PreMatchNote](
	[PreMatchNoteId] [int] IDENTITY(1,1) NOT NULL,
	[OWPLeagueId] [int] NULL,
	[InfoSiteMatchId] [int] NULL,
	[EventDate] [date] NOT NULL,
 CONSTRAINT [PK_PreMatchNote] PRIMARY KEY CLUSTERED 
(
	[PreMatchNoteId] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [OWP_Data]
) ON [OWP_Data]
GO

CREATE TABLE [dbo].[PreMatchNoteMessage](
	[PreMatchNoteMessageId] [int] IDENTITY(1,1) NOT NULL,
	[PreMatchNoteId] [int] NOT NULL,
	[CreatedDate] [datetime] NOT NULL,
	[UserId] [int] NOT NULL,
	[Message] [nvarchar](2000) NOT NULL,
 CONSTRAINT [PK_PreMatchNoteMessage] PRIMARY KEY CLUSTERED 
(
	[PreMatchNoteMessageId] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [OWP_Data]
) ON [OWP_Data]
GO

ALTER TABLE [dbo].[PreMatchAssignment]
ADD AssignmentType TINYINT NOT NULL DEFAULT(1), 
    AssignmentNote NVARCHAR(200);

ALTER TABLE [dbo].[PreMatchAssignment]
DROP CONSTRAINT [PK_PreMatchAssignment]

ALTER TABLE [dbo].[PreMatchAssignment]
ADD CONSTRAINT [PK_PreMatchAssignment] PRIMARY KEY CLUSTERED ([PreMatchLeagueId] ASC,
	[UserId] ASC,
	[Bettype] ASC,
	[IsTakeOver] ASC,
	[AssignmentType] ASC)