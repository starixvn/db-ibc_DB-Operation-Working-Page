CREATE TABLE [dbo].[NotificationSettingMapping] (
    [NotificationSettingId] SMALLINT       NOT NULL,
    [UserId]                INT            NOT NULL,
    [Value]                 NVARCHAR (250) NOT NULL,
    CONSTRAINT [PK_NotificationSettingMapping] PRIMARY KEY CLUSTERED ([NotificationSettingId] ASC, [UserId] ASC)
);

