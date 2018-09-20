CREATE TABLE [dbo].[MatchBetypeCancel] (
    [OWPMatchId] INT NOT NULL,
    [BetType]    INT NOT NULL,
    CONSTRAINT [PK_MatchBetypeCancel] PRIMARY KEY CLUSTERED ([OWPMatchId] ASC, [BetType] ASC)
);

