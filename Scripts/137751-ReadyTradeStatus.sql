/*<info serverAlias="DBOWP-bodb_OWP" executers="bodbOWPNet" isFunction="0"></info>*/

/*
Created: 20200722@Esther
Task : Task List - Ready to Trade Status
DB: bodb_OWP	

Revisions:
	20200722@Esther: New structure of Task List - [Redmine: #137751]
*/

CREATE TABLE [dbo].[ReadyTradeStatus](
	[MatchId] [int] NOT NULL,
	[UserId] [int] NOT NULL,
	[ReadyDateTime] [datetime] NOT NULL,
 CONSTRAINT [PK_ReadyTradeStatus] PRIMARY KEY CLUSTERED 
(
	[MatchId] ASC,
	[UserId] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [OWP_Data]
) ON [OWP_Data]
GO


