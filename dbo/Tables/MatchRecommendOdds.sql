CREATE TABLE [dbo].[MatchRecommendOdds] (
    [MatchRecommendOddsId] INT        IDENTITY (1, 1) NOT NULL,
    [OWPMatchId]           INT        NOT NULL,
    [Bettype]              INT        NOT NULL,
    [HDP]                  SMALLMONEY NULL,
    [TeamChoice]           TINYINT    NULL,
    [CreatedBy]            INT        NOT NULL,
    [CreatedDate]          DATETIME   CONSTRAINT [DF_MatchRecommendOdd_CreatedDate] DEFAULT (getdate()) NOT NULL,
    CONSTRAINT [PK_MatchRecommendOdd] PRIMARY KEY CLUSTERED ([MatchRecommendOddsId] ASC)
);



