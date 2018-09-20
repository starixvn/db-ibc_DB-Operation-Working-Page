CREATE TABLE [dbo].[Filter] (
    [FilterId]   INT            IDENTITY (1, 1) NOT NULL,
    [FilterName] NVARCHAR (100) NOT NULL,
    [CreatedBy]  INT            NOT NULL,
    [IsPublic]   BIT            NOT NULL,
    CONSTRAINT [PK_Filter] PRIMARY KEY CLUSTERED ([FilterId] ASC)
);

