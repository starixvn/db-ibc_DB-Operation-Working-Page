CREATE TABLE [dbo].[ModuleObject] (
    [ModuleObjectId]   INT           NOT NULL,
    [ModuleObjectName] NVARCHAR (50) NOT NULL,
    [ModuleId]         INT           NULL,
    CONSTRAINT [PK_ModuleObject] PRIMARY KEY CLUSTERED ([ModuleObjectId] ASC)
);

