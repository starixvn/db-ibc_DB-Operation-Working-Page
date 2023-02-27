
/*<info serverAlias="DBOWP-bodb_OWP" executers="bodbOWPNet" isFunction="0"></info>*/
/*
Created: 20230209@Carlos.nguyen
Task : Add refresource
DB: bodb_OWP	

Revisions:
	20230209@Carlos.nguyen: Create table - [Redmine: #183243]
*/
--create table SectionLevelDefault
IF OBJECT_ID('dbo.SectionLevelDefault', 'U') IS NOT NULL
    DROP TABLE dbo.[SectionLevelDefault]; 
GO
CREATE TABLE SectionLevelDefault
([LevelId] INT PRIMARY KEY, 
 [Order]   INT
);

--create table SectionLevel
IF OBJECT_ID('dbo.SectionLevel', 'U') IS NOT NULL
    DROP TABLE dbo.[SectionLevel]; 
GO
CREATE TABLE SectionLevel
(SectionId INT PRIMARY KEY, 
 [LevelId] INT NOT NULL, 
 [Order]   INT
);

--create table SectionBetTypePreferencesDefault
IF OBJECT_ID('dbo.SectionBetTypePreferencesDefault', 'U') IS NOT NULL
    DROP TABLE dbo.[SectionBetTypePreferencesDefault]; 
GO

CREATE TABLE SectionBetTypePreferencesDefault
([BettypeId] INT PRIMARY KEY, 
 [Order]     INT
);

--create table SectionBetTypePreferences
IF OBJECT_ID('dbo.SectionBetTypePreferences', 'U') IS NOT NULL
    DROP TABLE dbo.[SectionBetTypePreferences]; 
GO
CREATE TABLE SectionBetTypePreferences
(SectionId   INT PRIMARY KEY, 
 [BettypeId] INT NOT NULL, 
 [Order]     INT
);

--create table UserBetTypePreferences
IF OBJECT_ID('dbo.UserBetTypePreferences', 'U') IS NOT NULL
    DROP TABLE dbo.[UserBetTypePreferences]; 
GO
CREATE TABLE UserBetTypePreferences
([Id]        [INT] IDENTITY(1, 1) PRIMARY KEY, 
 UserId      INT NOT NULL, 
 [BettypeId] INT NOT NULL
);