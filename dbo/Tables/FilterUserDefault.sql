CREATE TABLE [dbo].[FilterUserDefault] (
    [FilterId] INT NOT NULL,
    [UserId]   INT NOT NULL,
    CONSTRAINT [PK_FilterUserDefault] PRIMARY KEY NONCLUSTERED ([FilterId] ASC, [UserId] ASC)
);

