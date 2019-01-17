/*
	Created: Raymond.Le
	Date: 2019-01-17
	Task: [Redmine: #107257]
	DB: bodb_OWP
*/

/*PLEASE DON'T FORMAT THIS FILE*/
USE [bodb_OWP]
GO

------------------
-- 1. Alter schema
-- rename table Provider to OtherProvider
EXECUTE	sys.sp_rename 'dbo.Provider', 'OtherProvider';
EXECUTE	sys.sp_rename 'dbo.OtherProvider.ProviderId' , 'OtherProviderId' , 'COLUMN';
EXECUTE	sys.sp_rename 'dbo.OtherProvider.ProviderName' , 'OtherProviderName' , 'COLUMN';
EXECUTE	sys.sp_rename 'OtherProvider.PK_Provider', 'PK_OtherProvider';
EXECUTE	sys.sp_rename 'OtherProvider.IX_Provider_ProviderName', 'IX_OtherProvider_OtherProviderName';

-- rename column Provider to OtherProvider in [MatchInfo]
EXECUTE	sys.sp_rename 'dbo.MatchInfo.Provider', 'OtherProvider', 'COLUMN';

-- rename column Provider to OtherProvider in [AssignmentUploading]
EXECUTE	sys.sp_rename 'dbo.AssignmentUploading.Provider' , 'OtherProvider' , 'COLUMN';
EXECUTE	sys.sp_rename 'DF_AssignmentUploading_Provider', 'DF_AssignmentUploading_OtherProvider';

-- rename table Runner to Provider
EXECUTE	sys.sp_rename 'dbo.Runner', 'Provider';
EXECUTE	sys.sp_rename 'dbo.Provider.RunnerId' , 'ProviderId' , 'COLUMN';
EXECUTE	sys.sp_rename 'dbo.Provider.RunnerName' , 'ProviderName' , 'COLUMN';
EXECUTE	sys.sp_rename 'Provider.PK_Runner', 'PK_Provider';
EXECUTE	sys.sp_rename 'Provider.IX_Runner_RunnerName', 'IX_Provider_ProviderName';

-- rename column Runner to Provider in [MatchInfo]
EXECUTE	sys.sp_rename 'dbo.MatchInfo.Runner', 'Provider', 'COLUMN';

-- rename column Runner to Provider in [AssignmentUploading]
EXECUTE	sys.sp_rename 'dbo.AssignmentUploading.Runner' , 'Provider' , 'COLUMN';
EXECUTE	sys.sp_rename 'DF_AssignmentUploading_Runner', 'DF_AssignmentUploading_Provider';

-- Rename unused SP
EXECUTE	sys.sp_rename 'OWP_Provider_GetAll', 'DEL_OWP_Provider_GetAll';
EXECUTE	sys.sp_rename 'OWP_LiveDetail_Provider_GetByMatchId', 'DEL_OWP_LiveDetail_Provider_GetByMatchId';
EXECUTE	sys.sp_rename 'OWP_Runner_GetAll', 'DEL_OWP_Runner_GetAll';
EXECUTE	sys.sp_rename 'OWP_LiveDetail_Runner_GetByMatchId', 'DEL_OWP_LiveDetail_Runner_GetByMatchId';

-- remove column RefResourceId
ALTER TABLE dbo.RefResource
DROP COLUMN RefResourceId;

-- add column NoOfHDP to table MatchInfo
ALTER TABLE [dbo].[MatchInfo] ADD NoOfHDPId INT NULL;

-- increase size of column MatchOffer
ALTER TABLE dbo.AssignmentUploading
ALTER COLUMN MatchOffer NVARCHAR(2000)

-- Add column IsDeleted to table InfoSiteMatch
ALTER TABLE dbo.InfoSiteMatch ADD IsDeleted BIT DEFAULT(0)

-- create table NotificationQueue
CREATE TABLE [dbo].[NotificationQueue] (
    [Sessionid]   VARCHAR (50) NOT NULL,
    [CreatedDate] DATETIME     CONSTRAINT [DF_NotificationQueue_CreatedDate] DEFAULT (getdate()) NOT NULL,
    CONSTRAINT [PK_NotificationQueue] PRIMARY KEY CLUSTERED ([Sessionid] ASC)
);

-- new table MatchOfferDetail
CREATE TABLE [dbo].[MatchOfferDetail] (
    [OWPMatchId]   INT NOT NULL,
    [MatchOfferId] INT NOT NULL,
    CONSTRAINT [PK_MatchOfferDetail] PRIMARY KEY CLUSTERED ([OWPMatchId] ASC, [MatchOfferId] ASC)
);

GO
-----------------
-- 2. Update Data
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
UPDATE [dbo].[FilterField]
SET [Name] = 'OtherProvider'
	,[Text] = 'Other Provider'
WHERE FieldId = 13

UPDATE [dbo].[FilterField]
SET [Name] = 'Provider'
	,[Text] = 'Provider'
WHERE FieldId = 14

-- change rule template
UPDATE dbo.ValidationRule
SET MessageFormat = 'Invalid NO.HDP: <content>'
WHERE RuleId = 28;

UPDATE dbo.ValidationRule
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

-----------------------------------------
-- 3. Remove unused Column, SP
-- drop column KOTimeRemark in table MatchInfo
ALTER TABLE dbo.MatchInfo
DROP COLUMN KOTimeRemark;

-- drop column NoOfHDP in table MatchInfo
ALTER TABLE dbo.MatchInfo
DROP COLUMN NoOfHDP;

-- delete unused SP
DROP PROCEDURE dbo.DEL_OWP_Provider_GetAll;
DROP PROCEDURE dbo.DEL_OWP_LiveDetail_Provider_GetByMatchId;
DROP PROCEDURE dbo.DEL_OWP_Runner_GetAll;
DROP PROCEDURE dbo.DEL_OWP_LiveDetail_Runner_GetByMatchId;
GO

