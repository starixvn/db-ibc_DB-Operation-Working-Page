CREATE TABLE [dbo].[AutoAssignmentMatchHistory] (
    [MatchId]        INT            NOT NULL,
    [KOTime]         DATETIME       NOT NULL,
    [OtherTime]      TIME (7)       NULL,
    [Bettype]        INT            NOT NULL,
    [MaxBet]         MONEY          NULL,
    [Venue]          NVARCHAR (100) NULL,
    [RequireChinese] BIT            NULL,
    PRIMARY KEY CLUSTERED ([MatchId] ASC, [Bettype] ASC)
);





