CREATE TABLE [dbo].[AutoAssignmentMatchHistory] (
    [MatchId]        INT            NOT NULL,
    [Bettype]        INT            NOT NULL,
    [KOTime]         DATETIME       NOT NULL,
    [OtherTime]      TIME (7)       NULL,
    [Venue]          NVARCHAR (100) NULL,
    [ReportLanguage] NVARCHAR (100) NULL,
    PRIMARY KEY CLUSTERED ([MatchId] ASC, [Bettype] ASC)
);

