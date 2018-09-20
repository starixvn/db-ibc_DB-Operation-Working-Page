CREATE TABLE [dbo].[Message] (
    [MessageId]      INT            IDENTITY (1, 1) NOT NULL,
    [MessageContent] NVARCHAR (MAX) NOT NULL,
    [CreatedBy]      INT            NOT NULL,
    [CreatedDate]    DATETIME       NOT NULL,
    [IsImportant]    BIT            CONSTRAINT [DF_Message_IsImportant] DEFAULT ((0)) NULL,
    [IsPermanent]    BIT            CONSTRAINT [DF_Message_IsPermanent] DEFAULT ((0)) NULL,
    [IsPublic]       BIT            NULL,
    [MessageType]    TINYINT        NULL,
    CONSTRAINT [PK_Message] PRIMARY KEY CLUSTERED ([MessageId] ASC)
);

