CREATE TABLE [dbo].[LeagueSettingRoundCondition] (
    [RoundConditionId] INT           IDENTITY (1, 1) NOT NULL,
    [OperatorType]     NVARCHAR (50) NOT NULL,
    [Value]            NVARCHAR (50) NOT NULL,
    CONSTRAINT [PK_LeagueSettingRoundCondition] PRIMARY KEY CLUSTERED ([RoundConditionId] ASC)
);



