CREATE TABLE [dbo].[LogAction] (
    [ActionId]       INT            NOT NULL,
    [ModuleId]       INT            NOT NULL,
    [ModuleObjectId] INT            NOT NULL,
    [ActionTypeId]   INT            NOT NULL,
    [ActionName]     NVARCHAR (200) NOT NULL,
    [SPName]         VARCHAR (50)   NOT NULL,
    [LogItems]       VARCHAR (MAX)  NOT NULL,
    CONSTRAINT [PK_LogAction] PRIMARY KEY CLUSTERED ([ActionId] ASC)
);

