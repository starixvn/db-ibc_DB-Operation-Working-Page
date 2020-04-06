CREATE TABLE [dbo].[LeagueSettingTVCondition] (
    [OperatorType] TINYINT       NOT NULL,
    [Value]        NVARCHAR (50) NOT NULL
);


GO
CREATE NONCLUSTERED INDEX [IX_LeagueSettingTVCondition]
    ON [dbo].[LeagueSettingTVCondition]([OperatorType] ASC);

