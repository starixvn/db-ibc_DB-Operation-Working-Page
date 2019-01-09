CREATE TABLE [dbo].[NotificationQueue] (
    [Sessionid]   VARCHAR (50) NOT NULL,
    [CreatedDate] DATETIME     CONSTRAINT [DF_NotificationQueue_CreatedDate] DEFAULT (getdate()) NOT NULL,
    CONSTRAINT [PK_NotificationQueue] PRIMARY KEY CLUSTERED ([Sessionid] ASC)
);

