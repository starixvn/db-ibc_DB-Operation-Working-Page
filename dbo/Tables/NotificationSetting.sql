CREATE TABLE [dbo].[NotificationSetting] (
    [NotificationSettingId] SMALLINT       NOT NULL,
    [Name]                  NVARCHAR (250) NOT NULL,
    [IsWatcher]             BIT            CONSTRAINT [DF_NotificationSetting_IsWatcher] DEFAULT ((0)) NOT NULL,
    [DefaultValue]          NVARCHAR (250) NULL,
    [Order]                 INT            NULL,
    CONSTRAINT [PK_NotificationSetting] PRIMARY KEY CLUSTERED ([NotificationSettingId] ASC)
);







