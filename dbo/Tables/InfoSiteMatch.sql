CREATE TABLE [dbo].[InfoSiteMatch] (
    [InfoSiteMatchId] INT             NOT NULL,
    [LeagueName]      NVARCHAR (2000) NOT NULL,
    [HomeName]        NVARCHAR (2000) NOT NULL,
    [AwayName]        NVARCHAR (2000) NOT NULL,
    [Round]           NVARCHAR (2000) NULL,
    [Division]        NVARCHAR (2000) NULL,
    [Agent]           NVARCHAR (2000) NULL,
    [TV]              NVARCHAR (2000) NULL,
    [Channel]         NVARCHAR (2000) NULL,
    [WB]              NVARCHAR (2000) NULL,
    [Website1]        NVARCHAR (2000) NULL,
    [Website2]        NVARCHAR (2000) NULL,
    [Website3]        NVARCHAR (2000) NULL,
    [Website4]        NVARCHAR (2000) NULL,
    [EventDate]       DATE            NULL,
    [OWPLeagueId]     INT             NOT NULL,
    [OWPHomeId]       INT             NOT NULL,
    [OWPAwayId]       INT             NOT NULL,
    [AgentIds]        VARCHAR (200)   NULL,
    [TVIds]           VARCHAR (200)   NULL,
    CONSTRAINT [PK_InfoSiteMatch] PRIMARY KEY CLUSTERED ([InfoSiteMatchId] ASC)
);

