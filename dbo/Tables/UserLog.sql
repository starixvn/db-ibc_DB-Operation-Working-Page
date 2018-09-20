CREATE TABLE [dbo].[UserLog] (
    [UserLogId]  INT            IDENTITY (1, 1) NOT NULL,
    [CreatorId]  INT            NOT NULL,
    [LoggedDate] DATETIME       NOT NULL,
    [ObjectId]   INT            NULL,
    [ActionId]   INT            NOT NULL,
    [Duration]   INT            NOT NULL,
    [Data]       NVARCHAR (MAX) NULL,
    [DataOld]    NVARCHAR (MAX) NULL,
    CONSTRAINT [PK_UserLog] PRIMARY KEY CLUSTERED ([UserLogId] ASC)
);

