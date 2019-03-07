/*
	Created: Raymond.Le
	Date: 2019-01-17
	Task: Script sprint 9 - [Redmine: #107257]
	DB: bodb_OWP
*/

--------------------------------
-- 1. Alter schema, create table
--------------------------------
USE [bodb_OWP]
GO

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
) ON [OWP_Data];

-- new table MatchOfferDetail
CREATE TABLE [dbo].[MatchOfferDetail] (
    [OWPMatchId]   INT NOT NULL,
    [MatchOfferId] INT NOT NULL,
    CONSTRAINT [PK_MatchOfferDetail] PRIMARY KEY CLUSTERED ([OWPMatchId] ASC, [MatchOfferId] ASC)
) ON [OWP_Data];
GO

