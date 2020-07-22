/*
Created: 20200722@Esther
Task : Task List - Ready to Trade Status
DB: bodb_OWP	

Revisions:
	20200722@Esther: New structure of Task List - [Redmine: #137751]
*/
/*<info serverAlias="DBOWP-bodb_OWP" executers="bodbOWPNet" isFunction="0"></info>*/
CREATE TABLE [dbo].[ReadyTradeStatus](
	[MatchId] [int]  NOT NULL,
	[UserId] [int] NOT NULL,
	[ReadyDateTime] [datetime] NOT NULL
	CONSTRAINT PK_ReadyTradeStatus PRIMARY KEY (MatchId,UserId))