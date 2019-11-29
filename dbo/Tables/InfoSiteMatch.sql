CREATE TABLE [dbo].[InfoSiteMatch] (
    [InfoSiteMatchId] INT             NOT NULL,
    [EventDateTime]   DATETIME        NOT NULL,
    [UpdatedTime]     DATETIME        NOT NULL,
    [LeagueName]      NVARCHAR (500)  NOT NULL,
    [HomeName]        NVARCHAR (200)  NOT NULL,
    [AwayName]        NVARCHAR (200)  NOT NULL,
    [Round]           NVARCHAR (2000) NULL,
    [Division]        NVARCHAR (2000) NULL,
    [Agent]           NVARCHAR (2000) NULL,
    [TV]              NVARCHAR (2000) NULL,
    [Channel]         NVARCHAR (100)  NULL,
    [WB]              NVARCHAR (100)  NULL,
    [Website1]        NVARCHAR (1000) NULL,
    [Website2]        NVARCHAR (1000) NULL,
    [Website3]        NVARCHAR (1000) NULL,
    [Website4]        NVARCHAR (1000) NULL,
    [OWPLeagueId]     INT             NOT NULL,
    [OWPHomeId]       INT             NOT NULL,
    [OWPAwayId]       INT             NOT NULL,
    [AgentIds]        VARCHAR (200)   NULL,
    [TVIds]           VARCHAR (200)   NULL,
    [IsDeleted]       BIT             DEFAULT ((0)) NULL,
    [Venue]           NVARCHAR (100)  NULL,
    CONSTRAINT [PK_InfoSiteMatch] PRIMARY KEY CLUSTERED ([InfoSiteMatchId] ASC)
);














GO
CREATE NONCLUSTERED INDEX [IX_InfoSiteMatch_EventDateTime]
    ON [dbo].[InfoSiteMatch]([EventDateTime] ASC)
    ON [OWP_Index];


GO
CREATE NONCLUSTERED INDEX [IX_InfoSiteMatch_UpdatedTime]
    ON [dbo].[InfoSiteMatch]([UpdatedTime] ASC)
    ON [OWP_Index];

