CREATE TABLE [dbo].[MatchSetting] (
    [OWPMatchId] INT   NOT NULL,
    [Bettype]    INT   NOT NULL,
    [Spread]     MONEY NULL,
    [Maxbet]     MONEY NULL,
    [SpreadCN88] MONEY NULL,
    [MaxbetCN88] MONEY NULL,
    CONSTRAINT [PK_MatchSetting] PRIMARY KEY CLUSTERED ([OWPMatchId] ASC, [Bettype] ASC)
);







