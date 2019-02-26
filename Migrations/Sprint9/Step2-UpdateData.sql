/*
	Created: Raymond.Le
	Date: 2019-01-17
	Task: Script sprint 9 - [Redmine: #107257]
	DB: bodb_OWP
*/

/*PLEASE DON'T FORMAT THIS FILE*/

-----------------
-- 2. Update Data
-----------------
USE [bodb_OWP]
GO

-- update data table [MessageTemplate]
UPDATE [dbo].[MessageTemplate] WITH (ROWLOCK, UPDLOCK)
SET MsgTemplateCode = 'EditOtherProvider'
	,MsgTemplateContent = '<user> edited Other Provider of <home> vs <away><bettype>.
- Old: <oldvalue>
- New: <newvalue>'
WHERE MsgTemplateId = 17

UPDATE [dbo].[MessageTemplate] WITH (ROWLOCK, UPDLOCK)
SET MsgTemplateCode = 'EditProvider'
	,MsgTemplateContent = '<user> edited Provider of <home> vs <away><bettype>.
- Old: <oldvalue>
- New: <newvalue>'
WHERE MsgTemplateId = 18

-- insert message template
INSERT [dbo].[MessageTemplate] ([MsgTemplateId], [MsgTemplateCode], [MsgTemplateContent], [IsActive], [SystemMessageType]) VALUES (28, N'EditKOTime', N'<user> edited KO Time of <home> vs <away><bettype>.
- Old: <oldvalue>
- New: <newvalue>', 1, 1)
INSERT [dbo].[MessageTemplate] ([MsgTemplateId], [MsgTemplateCode], [MsgTemplateContent], [IsActive], [SystemMessageType]) VALUES (29, N'EditMaxbet', N'<user> edited Maxbet <type> of <home> vs <away><bettype>.
- Old: <oldvalue>
- New: <newvalue>', 1, 1)
INSERT [dbo].[MessageTemplate] ([MsgTemplateId], [MsgTemplateCode], [MsgTemplateContent], [IsActive], [SystemMessageType]) VALUES (30, N'EditSpread', N'<user> edited Spread <type> of <home> vs <away><bettype>.
- Old: <oldvalue>
- New: <newvalue>', 1, 1)
INSERT [dbo].[MessageTemplate] ([MsgTemplateId], [MsgTemplateCode], [MsgTemplateContent], [IsActive], [SystemMessageType]) VALUES (31, N'EditLeague', N'InfoSite edited League of <home> vs <away>.
- Old: <oldvalue>
- New: <newvalue>', 1, 1)
INSERT [dbo].[MessageTemplate] ([MsgTemplateId], [MsgTemplateCode], [MsgTemplateContent], [IsActive], [SystemMessageType]) VALUES (32, N'EditTeam', N'InfoSite edited Team of match from <oldevent> to <newevent>', 1, 1)

-- update data table [FilterField]
UPDATE [dbo].[FilterField] WITH (ROWLOCK, UPDLOCK)
SET [Name] = 'OtherProvider'
	,[Text] = 'Other Provider'
WHERE FieldId = 13

UPDATE [dbo].[FilterField] WITH (ROWLOCK, UPDLOCK)
SET [Name] = 'Provider'
	,[Text] = 'Provider'
WHERE FieldId = 14

-- change rule template
UPDATE dbo.ValidationRule WITH (ROWLOCK, UPDLOCK)
SET MessageFormat = 'Invalid NO.HDP: <content>'
WHERE RuleId = 28;

UPDATE dbo.ValidationRule WITH (ROWLOCK, UPDLOCK)
SET MessageFormat = 'Invalid Match Offer: <content>'
WHERE RuleId = 29;

-- Change NoOfHDP
-- init data NoOfHDP in table RefResource
INSERT INTO dbo.RefResource(RefName, ResourceId, [Value])
VALUES ('NoOfHDP', 1, '1HDP'),
('NoOfHDP', 2, '2HDP'), 
('NoOfHDP', 3, '2+1H'), 
('NoOfHDP', 4, '3DHP'), 
('NoOfHDP', 5, '4DHP') 

-- migrate data
UPDATE dbo.MatchInfo WITH (ROWLOCK, UPDLOCK)
SET NoOfHDPId = 1
WHERE NoOfHDP = '1HDP';

UPDATE dbo.MatchInfo WITH (ROWLOCK, UPDLOCK)
SET NoOfHDPId = 2
WHERE NoOfHDP = '2HDP';

UPDATE dbo.MatchInfo WITH (ROWLOCK, UPDLOCK)
SET NoOfHDPId = 3
WHERE NoOfHDP = '2+1H';

UPDATE dbo.MatchInfo WITH (ROWLOCK, UPDLOCK)
SET NoOfHDPId = 4
WHERE NoOfHDP = '3HDP';

UPDATE dbo.MatchInfo WITH (ROWLOCK, UPDLOCK)
SET NoOfHDPId = 5
WHERE NoOfHDP = '4HDP';
GO

---------------------------------------
-- Change Match Offer
-- init data MatchOffer in table RefResource
INSERT INTO dbo.RefResource(RefName, ResourceId, [Value])
VALUES ('MatchOffer', 1, 'KO+15'), 
('MatchOffer', 2, 'Fast Market'), 
('MatchOffer', 3, '10s Accept'), 
('MatchOffer', 4, '15s Accept'), 
('MatchOffer', 5, '20s Accept');

-- migrate data for MatchOffer 'KO+15' & 'Fast Market'
INSERT INTO dbo.MatchOfferDetail (
	OWPMatchId
	,MatchOfferId
	)
SELECT mi.OWPMatchId
	,r.ResourceId
FROM dbo.MatchInfo AS mi WITH (NOLOCK)
	INNER JOIN dbo.RefResource AS r WITH (NOLOCK) ON mi.KOTimeRemark = r.[Value]
	AND r.RefName = 'MatchOffer';

-- migrate data for MatchOffer 'KO+15 Fast Market'
INSERT INTO dbo.MatchOfferDetail (OWPMatchId, MatchOfferId)
SELECT mi.OWPMatchId
	,r.ResourceId
FROM (
	SELECT OWPMatchId
	FROM dbo.MatchInfo WITH (NOLOCK)
	WHERE KOTimeRemark = 'KO+15 Fast Market'
	) AS mi
	CROSS JOIN (
	SELECT ResourceId
	FROM dbo.RefResource WITH (NOLOCK)
	WHERE RefName = 'MatchOffer'
		AND [Value] IN ('KO+15', 'Fast Market')
	) AS r;
GO	
