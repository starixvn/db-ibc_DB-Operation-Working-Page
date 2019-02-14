CREATE TABLE [dbo].[MessageUser] (
    [MessageUserId] INT            IDENTITY (1, 1) NOT NULL,
    [MessageId]     INT            NOT NULL,
    [UserId]        INT            NOT NULL,
    [IsViewed]      BIT            CONSTRAINT [DF_MessageUser_IsViewed] DEFAULT ((0)) NOT NULL,
    [SessionId]     NVARCHAR (100) NULL,
    CONSTRAINT [PK_MessageUser] PRIMARY KEY NONCLUSTERED ([MessageUserId] ASC) ON [OWP_Index]
);








GO
CREATE NONCLUSTERED INDEX [IX_MessageUser_SessionId]
    ON [dbo].[MessageUser]([SessionId] ASC)
    ON [OWP_Index];


GO
CREATE NONCLUSTERED INDEX [IX_MessageUser_MessageId]
    ON [dbo].[MessageUser]([MessageId] ASC)
    ON [OWP_Index];


GO
CREATE CLUSTERED INDEX [CIX_MessageUser]
    ON [dbo].[MessageUser]([UserId] ASC);

