/*
	Created: Leo.Vo
	Date: 20190506
	Task: [Redmine: #112737]
	DB: bodb_OWP
*/

--------------------------------
-- 1. Alter schema
--------------------------------
USE bodb_OWP

CREATE TABLE [dbo].[MatchAgent] (
    [OWPMatchId] INT NOT NULL,
    [AgentId]    INT NOT NULL,
    CONSTRAINT [PK_MatchAgent] PRIMARY KEY CLUSTERED ([OWPMatchId] ASC, [AgentId] ASC)
);
GO

CREATE TABLE [dbo].[MatchOtherProvider] (
    [OWPMatchId]      INT NOT NULL,
    [OtherProviderId] INT NOT NULL,
    CONSTRAINT [PK_MatchOtherProvider] PRIMARY KEY CLUSTERED ([OWPMatchId] ASC, [OtherProviderId] ASC)
);
GO

CREATE TABLE [dbo].[MatchProvider] (
    [OWPMatchId] INT NOT NULL,
    [ProviderId] INT NOT NULL,
    CONSTRAINT [PK_MatchProvider] PRIMARY KEY CLUSTERED ([OWPMatchId] ASC, [ProviderId] ASC)
);
GO

CREATE TABLE [dbo].[MatchTelevision] (
    [OWPMatchId] INT NOT NULL,
    [TVId]       INT NOT NULL,
    CONSTRAINT [PK_MatchTelevision] PRIMARY KEY CLUSTERED ([OWPMatchId] ASC, [TVId] ASC)
);
GO

ALTER TABLE dbo.MatchInfo
ALTER COLUMN Phone NVARCHAR(200)

GO

ALTER TABLE dbo.AssignmentUploading
ALTER COLUMN Phone NVARCHAR(200)

GO