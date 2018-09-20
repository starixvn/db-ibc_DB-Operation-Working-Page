CREATE TABLE [dbo].[FilterColumn] (
    [FilterId] INT NOT NULL,
    [ColumnId] INT NOT NULL,
    CONSTRAINT [PK_FilterColumn] PRIMARY KEY CLUSTERED ([ColumnId] ASC, [FilterId] ASC) ON [PRIMARY]
);

