CREATE TABLE [dbo].[MatchMarket] (
    [OWPMatchId] INT     NOT NULL,
    [MarketId]   TINYINT NOT NULL,
    CONSTRAINT [PK_MatchMarket] PRIMARY KEY CLUSTERED ([OWPMatchId] ASC, [MarketId] ASC)
);

