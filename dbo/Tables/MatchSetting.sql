CREATE TABLE [dbo].[MatchSetting] (
    [OWPMatchId] INT        NOT NULL,
    [Bettype]    INT        NOT NULL,
    [Spread]     SMALLMONEY NULL,
    [Maxbet]     MONEY      NULL,
    [SpreadCN88] SMALLMONEY NULL,
    [MaxbetCN88] MONEY      NULL,
    CONSTRAINT [PK_MatchSetting] PRIMARY KEY CLUSTERED ([OWPMatchId] ASC, [Bettype] ASC)
);





