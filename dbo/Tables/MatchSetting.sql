CREATE TABLE [dbo].[MatchSetting] (
    [OWPMatchId]  INT        NOT NULL,
    [Bettype]     INT        NOT NULL,
    [Spread]      SMALLMONEY NULL,
    [Maxbet]      MONEY      NULL,
    [IsCancelled] BIT        CONSTRAINT [DF_MatchSetting_IsOffered] DEFAULT ((0)) NOT NULL,
    CONSTRAINT [PK_MatchSetting] PRIMARY KEY CLUSTERED ([OWPMatchId] ASC, [Bettype] ASC)
);

