USE [bodb_OWP]
GO
/****** Object:  Table [dbo].[SpecialProduct]    Script Date: 07/01/2020 10:26:37 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_PADDING ON
GO
/*<info serverAlias="DBOWP-bodb_OWP" executers="bodbOWPNet" isFunction="0"></info>*/
CREATE TABLE [dbo].[SpecialProduct](
	[ProductId] [int] IDENTITY(1,1) NOT NULL,
	[Maxbet_FTHDP] [money] NULL,
	[Maxbet_NoOfCorner] [money] NULL,
	[Spread_NoOfCorner] [money] NULL,
	[Maxbet_NextCorner] [money] NULL,
	[Spread_NextCorner] [money] NULL,
	[Maxbet_10_15Mins] [money] NULL,
	[Spread_10_15Mins] [money] NULL,
	[Maxbet_TB] [money] NULL,
	[Spread_TB] [money] NULL,
	[Maxbet_NextTB] [money] NULL,
	[Spread_NextTB] [money] NULL,
	[Maxbet_PS] [money] NULL,
	[Spread_PS] [money] NULL,
	[Maxbet_Winner] [money] NULL,
	[Spread_Winner] [money] NULL,
	[Remark] [nvarchar](2000) NULL,
	[LastUpdate] [varchar](255) NULL,
	[Type] [varchar](10) NULL,
PRIMARY KEY CLUSTERED 
(
	[ProductId] ASC
)WITH (PAD_INDEX  = OFF, STATISTICS_NORECOMPUTE  = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS  = ON, ALLOW_PAGE_LOCKS  = ON) ON [OWP_Data]
) ON [OWP_Data]
GO
SET ANSI_PADDING OFF
GO
INSERT INTO [dbo].[ModuleObject]
           ([ModuleObjectId]
           ,[ModuleObjectName]
           ,[ModuleId])
VALUES(
	33,
	N'SpecialProduct',
	9)
GO
INSERT INTO [dbo].[LogAction]
           ([ActionId]
           ,[ModuleId]
           ,[ModuleObjectId]
           ,[ActionTypeId]
           ,[ActionName]
           ,[SPName]
           ,[LogItems])
VALUES(109,9,33,1,N'OWPSpecialProductInsert',N'OWP_SpecialProductInsert',N'<root><xml path="r/z" /><row item="Product" alias="p" /><row item="Value" alias="vl" /></root>')
,(110,9,33,2,N'OWPSpecialProductUpdate',N'OWP_SpecialProductUpdate',N'<root><xml path="r/z" /><row item="Product" alias="p" /><row item="Value" alias="vl" /></root>')
,(111,9,33,3,N'OWPSpecialProductDelete',N'OWP_SpecialProductDelete',N'<root><xml path="r/z" /><row item="Product" alias="p" /><row item="Value" alias="vl" /></root>')
,(112,9,33,3,N'OWPSpecialProductDelete_Row',N'OWP_SpecialProductDeleteRow',N'<root><xml path="r/z" /><row item="Id" alias="pid" /><row item="FTHDP" alias="fthdp" /><row item="MBNoOfCorner" alias="mbnoofcorner" /><row item="SpreadNoOfCorner" alias="spreadnoofcorner" /><row item="MBNextCorner" alias="mbnextcorner" /><row item="SpreadNextCorner" alias="spreadnextcorner" /><row item="MB1015Mins" alias="mb1015mins" /><row item="Spread1015Mins" alias="sp1015mins" /><row item="MBTotalBooking" alias="mbtb" /><row item="SpreadTotalBooking" alias="spreadtb" /><row item="MBNextTotalBooking" alias="mbntb" /><row item="SpNextTotalBooking" alias="spreadntb" /><row item="MBPenaltyShootout" alias="mbps" /><row item="SpreadPenaltyShootout" alias="spreadps" /><row item="MBWinner" alias="mbwinner" /><row item="SpreadWinner" alias="spreadwinner" /><row item="Remark" alias="remark" /></root>')
GO