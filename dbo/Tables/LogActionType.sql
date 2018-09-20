CREATE TABLE [dbo].[LogActionType] (
    [ActionTypeId]   INT           IDENTITY (1, 1) NOT NULL,
    [ActionTypeName] NVARCHAR (50) NOT NULL,
    CONSTRAINT [PK_LogActionType] PRIMARY KEY CLUSTERED ([ActionTypeId] ASC)
);

