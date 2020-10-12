/*<info serverAlias="DBOWP-bodb_OWP" executers="bodbOWPNet" isFunction="0"></info>*/

/*
Created: 20200918@Carlos.Nguyen
Task : Auto reassign -> Update schema table AutoAssignmentSuspenderHistory
DB: bodb_OWP	

Revisions:
	 20200918@Carlos.Nguyen: Auto re-assign for LA - [Redmine: #126964]
*/

DROP TABLE AutoAssignmentSuspenderHistory

USE [bodb_OWP]
GO
/****** Object:  Table [dbo].[AutoAssignmentSuspenderHistory]    Script Date: 09/18/2020 09:55:52 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_PADDING ON
GO
CREATE TABLE [dbo].[AutoAssignmentSuspenderHistory](
	[UserId] [int] NOT NULL,
	[InTime] [varchar](500) NOT NULL,
	[OutTime] [varchar](500) NULL,
	[SpeakChinese] [bit] NULL,
	[SpeakEnglish] [bit] NULL,
PRIMARY KEY CLUSTERED 
(
	[UserId] ASC,
	[InTime] ASC
)WITH (PAD_INDEX  = OFF, STATISTICS_NORECOMPUTE  = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS  = ON, ALLOW_PAGE_LOCKS  = ON) ON [OWP_Data]
) ON [OWP_Data]
GO
SET ANSI_PADDING OFF
GO




