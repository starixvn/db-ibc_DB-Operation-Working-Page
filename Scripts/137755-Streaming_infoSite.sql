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



