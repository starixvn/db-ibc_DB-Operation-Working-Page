/*<info serverAlias="DBOWP-bodb_OWP" executers="bodbOWPNet" isFunction="0"></info>*/

/*
Created: 20200728@Carlos.Nguyen
Task : Update data Streaming sync from InfoSite
DB: bodb_OWP	

Revisions:
	20200728@Carlos.Nguyen: New structure of InfoSiteMatch - [Redmine: #137755]
*/

ALTER TABLE InfoSiteMatch
ADD [IPTV] NVARCHAR(2000);

ALTER TABLE MatchInfo
ADD [IPTV] NVARCHAR(2000);

INSERT INTO MessageTemplate
(
	MsgTemplateId,
	MsgTemplateCode,
	MsgTemplateContent,
	SystemMessageType
)
VALUES
(41,
'EditIPTV',
'Was updated IPTV: [<New>] for the match: <Match.No> - <League> - <Event> updated by <User>, previous: [<Old>]',
1)

GO

IF EXISTS (SELECT * FROM sys.objects WHERE type = 'P' AND name = 'OWP_EventInsertFromInfoSite')
DROP PROCEDURE OWP_EventInsertFromInfoSite
GO

IF EXISTS (SELECT * FROM sys.objects WHERE type = 'P' AND name = 'OWP_EventPicking_Get')
DROP PROCEDURE OWP_EventPicking_Get
GO

IF EXISTS(SELECT 1 FROM sys.columns 
          WHERE Name = N'AdminSiteId'
          AND Object_ID = Object_ID(N'dbo.OWPMatch'))
BEGIN
	
	ALTER TABLE dbo.OWPMatch
	DROP COLUMN AdminSiteId;    
END


IF EXISTS(SELECT 1 FROM sys.columns 
          WHERE Name = N'LocalTV'
          AND Object_ID = Object_ID(N'dbo.MatchInfo'))
BEGIN
	
	ALTER TABLE dbo.MatchInfo
	DROP COLUMN LocalTV;    
END


IF EXISTS(SELECT 1 FROM sys.columns 
          WHERE Name = N'LiveTV'
          AND Object_ID = Object_ID(N'dbo.MatchInfo'))
BEGIN
	
	ALTER TABLE dbo.MatchInfo
	DROP COLUMN LiveTV;    
END


GO
