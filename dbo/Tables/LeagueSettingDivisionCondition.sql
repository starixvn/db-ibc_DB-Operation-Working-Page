CREATE TABLE [dbo].[LeagueSettingDivisionCondition] (
    [DivisionConditionId] INT           IDENTITY (1, 1) NOT NULL,
    [OperatorType]        NVARCHAR (50) NOT NULL,
    [Value]               NVARCHAR (50) NOT NULL,
    CONSTRAINT [PK_LeagueSettingDivisionCondition] PRIMARY KEY CLUSTERED ([DivisionConditionId] ASC)
);



