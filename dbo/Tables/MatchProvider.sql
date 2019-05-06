CREATE TABLE [dbo].[MatchProvider] (
    [OWPMatchId] INT NOT NULL,
    [ProviderId] INT NOT NULL,
    CONSTRAINT [PK_MatchProvider] PRIMARY KEY CLUSTERED ([OWPMatchId] ASC, [ProviderId] ASC)
);

