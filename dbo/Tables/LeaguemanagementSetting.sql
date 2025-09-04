USE [bodb_OWP]
GO

CREATE TABLE [dbo].[LeagueManagementSetting](
	[Id] [int] IDENTITY(1,1) NOT NULL,
	[OWPLeagueId] [int] NOT NULL,
	[FullConditionDescription] [nvarchar](max) NULL,
	[Spread_HDP] [money] NULL,
	[Spread_OU] [money] NULL,
	[Spread_Note] [nvarchar](2000) NULL,
	[MaxbetWD_HDP] [money] NULL,
	[MaxbetWD_HDP_Note] [nvarchar](2000) NULL,
	[WD_NoOfHDP] [nvarchar](2000) NULL,
	[WD_NoOfHDP_Note] [nvarchar](2000) NULL,
	[MaxbetWK_HDP] [money] NULL,
	[MaxbetWK_HDP_Note] [nvarchar](2000) NULL,
	[WK_NoOfHDP] [nvarchar](2000) NULL,
	[WK_NoOfHDP_Note] [nvarchar](2000) NULL,
	[LSTNote] [nvarchar](2000) NULL,
	[Remark2] [nvarchar](2000) NULL,
	[Comment] [nvarchar](max) NULL
) ON [OWP_Data] TEXTIMAGE_ON [OWP_Data]
GO

