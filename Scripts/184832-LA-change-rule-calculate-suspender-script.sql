/*<info serverAlias="DBOWP-bodb_OWP" executers="bodbOWPNet" isFunction="0"></info>*/
/*
Created: 20230613@Carlos.nguyen
Task : Add refresource
DB: bodb_OWP	

Revisions:
	20230613@Carlos.nguyen: Change datatype - [Redmine: #184832]

*/

USE [bodb_OWP]
GO
/****** Object:  Table [dbo].[LAReport]    Script Date: 6/13/2023 8:56:13 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

ALTER TABLE [dbo].[LAReport]ALTER COLUMN [TotalMatches]					[MONEY] NULL;
ALTER TABLE [dbo].[LAReport]ALTER COLUMN [Link2] 						[MONEY] NULL;
ALTER TABLE [dbo].[LAReport]ALTER COLUMN [Link3] 						[MONEY] NULL;
ALTER TABLE [dbo].[LAReport]ALTER COLUMN [Link4] 						[MONEY] NULL;
ALTER TABLE [dbo].[LAReport]ALTER COLUMN [Link5] 						[MONEY] NULL;
ALTER TABLE [dbo].[LAReport]ALTER COLUMN [Link6] 						[MONEY] NULL;
ALTER TABLE [dbo].[LAReport]ALTER COLUMN [Link7] 						[MONEY] NULL;
ALTER TABLE [dbo].[LAReport]ALTER COLUMN [Link8Plus] 					[MONEY] NULL;
ALTER TABLE [dbo].[LAReport]ALTER COLUMN [OnlyProvider] 				[MONEY] NULL;
ALTER TABLE [dbo].[LAReport]ALTER COLUMN [OnlyTV] 						[MONEY] NULL;
ALTER TABLE [dbo].[LAReport]ALTER COLUMN [OnlyReporter] 				[MONEY] NULL;
ALTER TABLE [dbo].[LAReport]ALTER COLUMN [MixedProviderTVReporter] 		[MONEY] NULL;
ALTER TABLE [dbo].[LAReport]ALTER COLUMN [CornerPlus] 					[MONEY] NULL;
ALTER TABLE [dbo].[LAReport]ALTER COLUMN [TBookingPlus] 				[MONEY] NULL;
ALTER TABLE [dbo].[LAReport]ALTER COLUMN [Fantasy] 						[MONEY] NULL;
ALTER TABLE [dbo].[LAReport]ALTER COLUMN [GoalKick] 					[MONEY] NULL;
ALTER TABLE [dbo].[LAReport]ALTER COLUMN [OtherProducts] 				[MONEY] NULL;
ALTER TABLE [dbo].[LAReport]ALTER COLUMN [FTCorner] 					[MONEY] NULL;
ALTER TABLE [dbo].[LAReport]ALTER COLUMN [FTCorner5ML] 					[MONEY] NULL;
ALTER TABLE [dbo].[LAReport]ALTER COLUMN [FiveMajorLeague] 				[MONEY] NULL;
ALTER TABLE [dbo].[LAReport]ALTER COLUMN [ESoccer5Mins] 				[MONEY] NULL;
ALTER TABLE [dbo].[LAReport]ALTER COLUMN [ESoccer6Mins] 				[MONEY] NULL;
ALTER TABLE [dbo].[LAReport]ALTER COLUMN [ESoccer15Mins] 				[MONEY] NULL;
ALTER TABLE [dbo].[LAReport]ALTER COLUMN [ESoccer16Mins] 				[MONEY] NULL;
ALTER TABLE [dbo].[LAReport]ALTER COLUMN [ESoccer20Mins] 				[MONEY] NULL;
ALTER TABLE [dbo].[LAReport]ALTER COLUMN [Others] 						[MONEY] NULL;
ALTER TABLE [dbo].[LAReport]ALTER COLUMN [TotalMatchInGroupMultiple]	[MONEY] NULL;
GO
