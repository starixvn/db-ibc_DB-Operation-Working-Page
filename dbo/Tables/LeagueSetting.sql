CREATE TABLE [dbo].[LeagueSetting] (
    [LeagueId]     INT        NOT NULL,
    [OptionsId]    INT        NOT NULL,
    [Bettype]      INT        NOT NULL,
    [Spread]       SMALLMONEY NULL,
    [Maxbet]       MONEY      NULL,
    [ModifiedBy]   INT        NULL,
    [ModifiedDate] DATETIME   NULL,
    CONSTRAINT [PK_LeagueSetting] PRIMARY KEY CLUSTERED ([LeagueId] ASC, [OptionsId] ASC, [Bettype] ASC)
);

