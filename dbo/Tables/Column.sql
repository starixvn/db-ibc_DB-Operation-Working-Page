CREATE TABLE [dbo].[Column] (
    [ColumnId]          INT            IDENTITY (1, 1) NOT NULL,
    [ParentColumnId]    INT            NULL,
    [Name]              NVARCHAR (100) NULL,
    [Text]              NVARCHAR (100) NULL,
    [IsActive]          BIT            NULL,
    [IsAlwayDisplay]    BIT            NULL,
    [IsDefaultSelected] BIT            NULL,
    [DisplayOrder]      INT            NULL,
    CONSTRAINT [PK_Column] PRIMARY KEY CLUSTERED ([ColumnId] ASC) ON [PRIMARY]
);

