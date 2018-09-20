CREATE TABLE [dbo].[MinorSetting] (
    [MinorSettingId] INT            IDENTITY (1, 1) NOT NULL,
    [Name]           NVARCHAR (100) NULL,
    [FromMaxBet]     MONEY          NULL,
    [ToMaxBet]       MONEY          NULL,
    CONSTRAINT [PK_MinorSetting] PRIMARY KEY CLUSTERED ([MinorSettingId] ASC) ON [PRIMARY]
);

