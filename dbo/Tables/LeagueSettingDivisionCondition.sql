CREATE TABLE [dbo].[LeagueSettingDivisionCondition] (
    [DivisionConditionId] INT           IDENTITY (1, 1) NOT NULL,
    [OperatorType]        TINYINT       NOT NULL,
    [Value]               NVARCHAR (50) NOT NULL,
    CONSTRAINT [PK_LeagueSettingDivisionCondition] PRIMARY KEY CLUSTERED ([DivisionConditionId] ASC)
);

