CREATE TABLE [dbo].[Runner] (
    [RunnerId]   INT            IDENTITY (1, 1) NOT NULL,
    [RunnerName] NVARCHAR (100) NOT NULL,
    CONSTRAINT [PK_Runner] PRIMARY KEY CLUSTERED ([RunnerId] ASC)
);




GO
CREATE UNIQUE NONCLUSTERED INDEX [IX_Runner_RunnerName]
    ON [dbo].[Runner]([RunnerName] ASC)
    ON [OWP_Index];

