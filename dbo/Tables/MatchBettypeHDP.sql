CREATE TABLE [dbo].[MatchBettypeHDP] (
    [OWPMatchId]   INT      NOT NULL,
    [Bettype]      INT      NOT NULL,
    [Handicap]     INT      NOT NULL,
    [ModifiedBy]   INT      NULL,
    [ModifiedDate] DATETIME NULL,
    CONSTRAINT [PK_MatchBettypeHDP] PRIMARY KEY CLUSTERED ([OWPMatchId] ASC, [Bettype] ASC)
);

