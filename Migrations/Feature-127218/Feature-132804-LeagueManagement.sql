USE bodb_OWP;
GO

CREATE TABLE [dbo].[NewLeagueSetting](
	[LeagueSettingId] [int] IDENTITY(1,1) NOT NULL,
	[OWPLeagueId] [int] NOT NULL,
	[Category] [nvarchar](20) NOT NULL,
	[Round] [nvarchar](200) NULL,
	[Division] [nvarchar](200) NULL,
	[TimeDesc] [nvarchar](50) NULL,
	[Remark] [nvarchar](2000) NULL,
	[TV] [nvarchar](50) NULL,
	[HasTV] [bit] NULL,
	[LSTNote] [varchar](200) NULL,
	[Spread_HDP] [money] NULL,
	[Spread_OU] [money] NULL,
	[Spread_1HHDP] [money] NULL,
	[Spread_1HOU] [money] NULL,
	[Speard_1X2] [money] NULL,
	[MaxbetWD_HDP] [money] NULL,
	[MaxbetWD_OU] [money] NULL,
	[MaxbetWD_1H] [money] NULL,
	[MaxbetWD_NoOfHDP] [nvarchar](20) NULL,
	[MaxbetWD_MatchOffer] [nvarchar](200) NULL,
	[MaxbetWK_HDP] [money] NULL,
	[MaxbetWK_OU] [money] NULL,
	[MaxbetWK_1H] [money] NULL,
	[MaxbetWK_NoOfHDP] [nvarchar](20) NULL,
	[MaxbetWK_MatchOffer] [nvarchar](200) NULL,
	[MaxBet_1X2Spread] [money] NULL,
	[MaxBet_FT1X2] [money] NULL,
	[MaxBet_1H1X2] [money] NULL,
	[MaxBet_1X2_MatchOffer] [nvarchar](200) NULL,
	[CN88Spread_HDP] [money] NULL,
	[CN88Spread_OU] [money] NULL,
	[CN88Spread_1HHDP] [money] NULL,
	[CN88Spread_1HOU] [money] NULL,
	[CN88MaxbetWD_HDP] [money] NULL,
	[CN88MaxbetWD_OU] [money] NULL,
	[CN88MaxbetWD_1H] [money] NULL,
	[CN88MaxbetWD_NoOfHDP] [nvarchar](20) NULL,
	[CN88MaxbetWD_MatchOffer] [nvarchar](200) NULL,
	[CN88MaxbetWK_HDP] [money] NULL,
	[CN88MaxbetWK_OU] [money] NULL,
	[CN88MaxbetWK_1H] [money] NULL,
	[CN88MaxbetWK_NoOfHDP] [nvarchar](20) NULL,
	[CN88MaxbetWK_MatchOffer] [nvarchar](200) NULL,
	[CN88MaxBet_1X2Spread] [money] NULL,
	[CN88MaxBet_FT1X2] [money] NULL,
	[CN88MaxBet_1H1X2] [money] NULL,
	[CN88MaxBet_1X2_MatchOffer] [nvarchar](200) NULL,
	[IsApplied] [bit] NOT NULL,
	[FullConditionDescription] [nvarchar](max) NULL,
	[LastModifiedBy] [int] NOT NULL,
 CONSTRAINT [PK_NewLeagueSetting] PRIMARY KEY CLUSTERED 
(
	[LeagueSettingId] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [OWP_Data]
) ON [OWP_Data] TEXTIMAGE_ON [OWP_Data]
GO

CREATE TABLE [dbo].[LeagueSettingTVCondition](
	[OperatorType] [nvarchar](50) NOT NULL,
	[Value] [nvarchar](50) NOT NULL
) ON [OWP_Data]
GO

INSERT INTO [dbo].[Module]
           ([ModuleId]
           ,[ModuleName])
     VALUES
           (9
           ,N'LeagueManagement')
GO

INSERT INTO [dbo].[ModuleObject]
           ([ModuleObjectId]
           ,[ModuleObjectName]
           ,[ModuleId])
     VALUES
           (31
           ,N'TVList'
           ,9)
GO

INSERT INTO [dbo].[ModuleObject]
           ([ModuleObjectId]
           ,[ModuleObjectName]
           ,[ModuleId])
     VALUES
           (32
           ,N'LeagueSetting'
           ,9)
GO

INSERT INTO [dbo].[LogAction]
           ([ActionId]
           ,[ModuleId]
           ,[ModuleObjectId]
           ,[ActionTypeId]
           ,[ActionName]
           ,[SPName]
           ,[LogItems])
     VALUES
           (103
           ,9
           ,32
           ,1
           ,N'OWP_LeagueManagement_Insert'
           ,N'OWP_LeagueManagement_Insert'
           ,N'<root><xml path="r/z" /><row item="OWPLeagueId" alias="lid" /><row item="LeagueSettingId" alias="lsid" /></root>')
GO

INSERT INTO [dbo].[LogAction]
           ([ActionId]
           ,[ModuleId]
           ,[ModuleObjectId]
           ,[ActionTypeId]
           ,[ActionName]
           ,[SPName]
           ,[LogItems])
     VALUES
           (104
           ,4
           ,2
           ,2
           ,N'OWP_OWPLeague_UpdateGroup'
           ,N'OWP_OWPLeague_UpdateGroup'
           ,N'<root><xml path="r/z" /><row item="OWPLeagueId" alias="lid" /><row item="CategoryId" alias="ci" /></root>')
GO

INSERT INTO [dbo].[LogAction]
           ([ActionId]
           ,[ModuleId]
           ,[ModuleObjectId]
           ,[ActionTypeId]
           ,[ActionName]
           ,[SPName]
           ,[LogItems])
     VALUES
           (105
           ,9
           ,32
           ,2
           ,N'OWP_LeagueManagement_Update'
           ,N'OWP_LeagueManagement_Update'
           ,N'<root><xml path="r/z" /><row item="LeagueSettingId" alias="lsid" />
				<row item="OWPLeagueId" alias="olid" />
				<row item="TimeDesc" alias="td" />
				<row item="Remark" alias="rm" />
				<row item="TV" alias="tv" />
				<row item="HasTV" alias="htv" />
				<row item="LSTNote" alias="ln" />
				<row item="Spread_HDP" alias="shdp" />
				<row item="Spread_OU" alias="sou" />
				<row item="Spread_1HHDP" alias="s1hhdp" />
				<row item="Spread_1HOU" alias="s1hou" />
				<row item="Speard_1X2" alias="s1x2" />
				<row item="MaxbetWD_HDP" alias="mwdhdp" />
				<row item="MaxbetWD_OU" alias="mwdou" />
				<row item="MaxbetWD_1H" alias="mwd1h" />
				<row item="MaxbetWD_NoOfHDP" alias="mwdnohdp" />
				<row item="MaxbetWD_MatchOffer" alias="mwdmo" />
				<row item="MaxbetWK_HDP" alias="mwkhdp" />
				<row item="MaxbetWK_OU" alias="mwkou" />
				<row item="MaxbetWK_1H" alias="mwk1h" />
				<row item="MaxbetWK_NoOfHDP" alias="mwknohdp" />
				<row item="MaxbetWK_MatchOffer" alias="mwkmo" />
				<row item="MaxBet_1X2Spread" alias="mb1x2s" />
				<row item="MaxBet_FT1X2" alias="mbft1x2" />
				<row item="MaxBet_1H1X2" alias="mb1h1x2" />
				<row item="MaxBet_1X2_MatchOffer" alias="mb1x2mo" />
				<row item="CN88Spread_HDP" alias="cn88shdp" />
				<row item="CN88Spread_OU" alias="cn88sou" />
				<row item="CN88Spread_1HHDP" alias="cn88s1hhdp" />
				<row item="CN88Spread_1HOU" alias="cn88s1hou" />
				<row item="CN88MaxbetWD_HDP" alias="cn88mwdhdp" />
				<row item="CN88MaxbetWD_OU" alias="cn88mwdou" />
				<row item="CN88MaxbetWD_1H" alias="cn88mwd1h" />
				<row item="CN88MaxbetWD_NoOfHDP" alias="cn88mwdnohdp" />
				<row item="CN88MaxbetWD_MatchOffer" alias="cn88mwdmo" />
				<row item="CN88MaxbetWK_HDP" alias="cn88mwkhdp" />
				<row item="CN88MaxbetWK_OU" alias="cn88mwkou" />
				<row item="CN88MaxbetWK_1H" alias="cn88mwk1h" />
				<row item="CN88MaxbetWK_NoOfHDP" alias="cn88mwknohdp" />
				<row item="CN88MaxbetWK_MatchOffer" alias="cn88mwkmo" />
				<row item="CN88MaxBet_1X2Spread" alias="cn88mb1x2s" />
				<row item="CN88MaxBet_FT1X2" alias="cn88mbft1x2" />
				<row item="CN88MaxBet_1H1X2" alias="cn88mb1h1x2" />
				<row item="CN88MaxBet_1X2_MatchOffer" alias="cn88mb1x2mo" />
				<row item="Category" alias="c" />
				<row item="IsApplied" alias="ia" />
				<row item="Round" alias="r" />
				<row item="Division" alias="d" />
				<row item="FullConditionDescription" alias="fcd" />
				<row item="LastModifiedBy" alias="lm" /></root>')
GO

INSERT INTO [dbo].[LogAction]
           ([ActionId]
           ,[ModuleId]
           ,[ModuleObjectId]
           ,[ActionTypeId]
           ,[ActionName]
           ,[SPName]
           ,[LogItems])
     VALUES
           (106
           ,9
           ,32
           ,3
           ,N'OWP_LeagueManagement_Delete'
           ,N'OWP_LeagueManagement_Delete'
           ,N'<root><xml path="r/z" /><row item="LeagueSettingId" alias="lsid" />
				<row item="OWPLeagueId" alias="olid" />
				<row item="TimeDesc" alias="td" />
				<row item="Remark" alias="rm" />
				<row item="TV" alias="tv" />
				<row item="HasTV" alias="htv" />
				<row item="LSTNote" alias="ln" />
				<row item="Spread_HDP" alias="shdp" />
				<row item="Spread_OU" alias="sou" />
				<row item="Spread_1HHDP" alias="s1hhdp" />
				<row item="Spread_1HOU" alias="s1hou" />
				<row item="Speard_1X2" alias="s1x2" />
				<row item="MaxbetWD_HDP" alias="mwdhdp" />
				<row item="MaxbetWD_OU" alias="mwdou" />
				<row item="MaxbetWD_1H" alias="mwd1h" />
				<row item="MaxbetWD_NoOfHDP" alias="mwdnohdp" />
				<row item="MaxbetWD_MatchOffer" alias="mwdmo" />
				<row item="MaxbetWK_HDP" alias="mwkhdp" />
				<row item="MaxbetWK_OU" alias="mwkou" />
				<row item="MaxbetWK_1H" alias="mwk1h" />
				<row item="MaxbetWK_NoOfHDP" alias="mwknohdp" />
				<row item="MaxbetWK_MatchOffer" alias="mwkmo" />
				<row item="MaxBet_1X2Spread" alias="mb1x2s" />
				<row item="MaxBet_FT1X2" alias="mbft1x2" />
				<row item="MaxBet_1H1X2" alias="mb1h1x2" />
				<row item="MaxBet_1X2_MatchOffer" alias="mb1x2mo" />
				<row item="CN88Spread_HDP" alias="cn88shdp" />
				<row item="CN88Spread_OU" alias="cn88sou" />
				<row item="CN88Spread_1HHDP" alias="cn88s1hhdp" />
				<row item="CN88Spread_1HOU" alias="cn88s1hou" />
				<row item="CN88MaxbetWD_HDP" alias="cn88mwdhdp" />
				<row item="CN88MaxbetWD_OU" alias="cn88mwdou" />
				<row item="CN88MaxbetWD_1H" alias="cn88mwd1h" />
				<row item="CN88MaxbetWD_NoOfHDP" alias="cn88mwdnohdp" />
				<row item="CN88MaxbetWD_MatchOffer" alias="cn88mwdmo" />
				<row item="CN88MaxbetWK_HDP" alias="cn88mwkhdp" />
				<row item="CN88MaxbetWK_OU" alias="cn88mwkou" />
				<row item="CN88MaxbetWK_1H" alias="cn88mwk1h" />
				<row item="CN88MaxbetWK_NoOfHDP" alias="cn88mwknohdp" />
				<row item="CN88MaxbetWK_MatchOffer" alias="cn88mwkmo" />
				<row item="CN88MaxBet_1X2Spread" alias="cn88mb1x2s" />
				<row item="CN88MaxBet_FT1X2" alias="cn88mbft1x2" />
				<row item="CN88MaxBet_1H1X2" alias="cn88mb1h1x2" />
				<row item="CN88MaxBet_1X2_MatchOffer" alias="cn88mb1x2mo" />
				<row item="Category" alias="c" />
				<row item="IsApplied" alias="ia" />
				<row item="Round" alias="r" />
				<row item="Division" alias="d" />
				<row item="FullConditionDescription" alias="fcd" />
				<row item="LastModifiedBy" alias="lm" /></root>')
GO

INSERT INTO [dbo].[LogAction]
           ([ActionId]
           ,[ModuleId]
           ,[ModuleObjectId]
           ,[ActionTypeId]
           ,[ActionName]
           ,[SPName]
           ,[LogItems])
     VALUES
           (107
           ,9
           ,32
           ,2
           ,N'OWP_LeagueManagement_UpdateCondition'
           ,N'OWP_LeagueManagement_UpdateCondition'
           ,N'<root><xml path="r/z" /><row item="LeagueSettingId" alias="lsid" />
				<row item="OWPLeagueId" alias="olid" />
				<row item="TimeDesc" alias="td" />
				<row item="Remark" alias="rm" />
				<row item="TV" alias="tv" />
				<row item="HasTV" alias="htv" />
				<row item="LSTNote" alias="ln" />
				<row item="Spread_HDP" alias="shdp" />
				<row item="Spread_OU" alias="sou" />
				<row item="Spread_1HHDP" alias="s1hhdp" />
				<row item="Spread_1HOU" alias="s1hou" />
				<row item="Speard_1X2" alias="s1x2" />
				<row item="MaxbetWD_HDP" alias="mwdhdp" />
				<row item="MaxbetWD_OU" alias="mwdou" />
				<row item="MaxbetWD_1H" alias="mwd1h" />
				<row item="MaxbetWD_NoOfHDP" alias="mwdnohdp" />
				<row item="MaxbetWD_MatchOffer" alias="mwdmo" />
				<row item="MaxbetWK_HDP" alias="mwkhdp" />
				<row item="MaxbetWK_OU" alias="mwkou" />
				<row item="MaxbetWK_1H" alias="mwk1h" />
				<row item="MaxbetWK_NoOfHDP" alias="mwknohdp" />
				<row item="MaxbetWK_MatchOffer" alias="mwkmo" />
				<row item="MaxBet_1X2Spread" alias="mb1x2s" />
				<row item="MaxBet_FT1X2" alias="mbft1x2" />
				<row item="MaxBet_1H1X2" alias="mb1h1x2" />
				<row item="MaxBet_1X2_MatchOffer" alias="mb1x2mo" />
				<row item="CN88Spread_HDP" alias="cn88shdp" />
				<row item="CN88Spread_OU" alias="cn88sou" />
				<row item="CN88Spread_1HHDP" alias="cn88s1hhdp" />
				<row item="CN88Spread_1HOU" alias="cn88s1hou" />
				<row item="CN88MaxbetWD_HDP" alias="cn88mwdhdp" />
				<row item="CN88MaxbetWD_OU" alias="cn88mwdou" />
				<row item="CN88MaxbetWD_1H" alias="cn88mwd1h" />
				<row item="CN88MaxbetWD_NoOfHDP" alias="cn88mwdnohdp" />
				<row item="CN88MaxbetWD_MatchOffer" alias="cn88mwdmo" />
				<row item="CN88MaxbetWK_HDP" alias="cn88mwkhdp" />
				<row item="CN88MaxbetWK_OU" alias="cn88mwkou" />
				<row item="CN88MaxbetWK_1H" alias="cn88mwk1h" />
				<row item="CN88MaxbetWK_NoOfHDP" alias="cn88mwknohdp" />
				<row item="CN88MaxbetWK_MatchOffer" alias="cn88mwkmo" />
				<row item="CN88MaxBet_1X2Spread" alias="cn88mb1x2s" />
				<row item="CN88MaxBet_FT1X2" alias="cn88mbft1x2" />
				<row item="CN88MaxBet_1H1X2" alias="cn88mb1h1x2" />
				<row item="CN88MaxBet_1X2_MatchOffer" alias="cn88mb1x2mo" />
				<row item="Category" alias="c" />
				<row item="IsApplied" alias="ia" />
				<row item="Round" alias="r" />
				<row item="Division" alias="d" />
				<row item="FullConditionDescription" alias="fcd" />
				<row item="LastModifiedBy" alias="lm" /></root>')
GO

INSERT INTO [dbo].[LogAction]
           ([ActionId]
           ,[ModuleId]
           ,[ModuleObjectId]
           ,[ActionTypeId]
           ,[ActionName]
           ,[SPName]
           ,[LogItems])
     VALUES
           (108
           ,9
           ,31
           ,2
           ,N'OWP_LeagueManagement_UpdateTVCondition'
           ,N'OWP_LeagueManagement_UpdateTVCondition'
           ,N'<root><xml path="r/z" /><row item="OperatorType" alias="ot" /><row item="Value" alias="vl" /></root>')
GO