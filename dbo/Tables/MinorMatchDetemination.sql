CREATE TABLE [dbo].[MinorMatchDetemination] (
    [MinorBettypeId] INT             NULL,
    [Field]          SMALLINT        NULL,
    [Condition]      SMALLINT        NULL,
    [Value]          NVARCHAR (2000) NULL
);




GO
CREATE CLUSTERED INDEX [CIX_MinorMatchDetemination]
    ON [dbo].[MinorMatchDetemination]([MinorBettypeId] DESC);

