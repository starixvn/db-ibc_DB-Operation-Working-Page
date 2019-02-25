CREATE TABLE [dbo].[Message] (
    [MessageId]      INT            IDENTITY (1, 1) NOT NULL,
    [MessageContent] NVARCHAR (MAX) NOT NULL,
    [CreatedBy]      INT            NOT NULL,
    [CreatedDate]    DATETIME       CONSTRAINT [DF_Message_CreatedDate] DEFAULT (getdate()) NOT NULL,
    [IsImportant]    BIT            CONSTRAINT [DF_Message_IsImportant] DEFAULT ((0)) NULL,
    [MessageType]    TINYINT        NOT NULL,
    [IsWatcher]      BIT            CONSTRAINT [DF_Message_IsWatcher] DEFAULT ((0)) NULL,
    CONSTRAINT [PK_Message] PRIMARY KEY CLUSTERED ([MessageId] ASC)
);







