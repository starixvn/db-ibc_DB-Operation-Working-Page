CREATE TABLE [dbo].[MessageUser] (
    [MessageUserId] INT            IDENTITY (1, 1) NOT NULL,
    [MessageId]     INT            NOT NULL,
    [UserId]        INT            NOT NULL,
    [IsViewed]      BIT            CONSTRAINT [DF_MessageUser_IsViewed] DEFAULT ((0)) NOT NULL,
    [CreatedDate]   DATETIME       CONSTRAINT [DF_MessageUser_CreatedDate] DEFAULT (getdate()) NULL,
    [CreatedBy]     INT            NULL,
    [SessionId]     NVARCHAR (100) NULL,
    CONSTRAINT [PK_MessageUser] PRIMARY KEY CLUSTERED ([MessageUserId] ASC, [MessageId] ASC, [UserId] ASC)
);



