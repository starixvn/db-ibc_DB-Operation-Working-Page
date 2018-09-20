CREATE TABLE [dbo].[MatchRecommendOdds] (
    [Id]          INT        IDENTITY (1, 1) NOT NULL,
    [OWPMatchId]  INT        NOT NULL,
    [Bettype]     INT        NOT NULL,
    [HDP]         SMALLMONEY NULL,
    [Choice]      INT        NOT NULL,
    [Odds]        MONEY      NULL,
    [CreatedBy]   INT        NULL,
    [CreatedDate] DATETIME   NULL,
    CONSTRAINT [PK_MatchRecommendOdds_1] PRIMARY KEY CLUSTERED ([Id] ASC)
);

