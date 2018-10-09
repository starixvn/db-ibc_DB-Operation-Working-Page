CREATE TABLE [dbo].[MatchRecommendOddsDetail] (
    [MatchRecommendOddsId] INT     NOT NULL,
    [Choice]               TINYINT NOT NULL,
    [Odds]                 MONEY   NULL,
    CONSTRAINT [PK_MatchRecommendOddDetail] PRIMARY KEY CLUSTERED ([MatchRecommendOddsId] ASC, [Choice] ASC)
);

