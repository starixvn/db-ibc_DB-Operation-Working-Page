CREATE TABLE [dbo].[MinorSettingDetail] (
    [MinorBettypeId] INT        NOT NULL,
    [MinorSettingId] INT        NOT NULL,
    [Spread]         SMALLMONEY NULL,
    [MaxBet]         MONEY      NULL,
    CONSTRAINT [PK_MinorSettingDetail] PRIMARY KEY CLUSTERED ([MinorBettypeId] ASC, [MinorSettingId] ASC) ON [PRIMARY]
);

