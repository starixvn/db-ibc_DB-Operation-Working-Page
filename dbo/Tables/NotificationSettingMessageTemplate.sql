CREATE TABLE [dbo].[NotificationSettingMessageTemplate] (
    [NotificationSettingId] SMALLINT NOT NULL,
    [MessageTemplateId]     SMALLINT NOT NULL,
    CONSTRAINT [PK_NotificationSettingMessageTemplate] PRIMARY KEY CLUSTERED ([NotificationSettingId] ASC, [MessageTemplateId] ASC)
);

