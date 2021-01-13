
/*<info serverAlias="DBOWP-bodb_OWP" executers="bodbOWPNet" isFunction="0"></info>*/
/*
Created: 20200810@Jacob
Task : Archive plan for OWP tables
DB: bodb_OWP	

Revisions:
	20200810@Jacob: Archive plan for OWP tables - [Redmine: #137757]
	20210113@Esther: Adding SABA 6mins match to LA Report - [Redmine: #148267]
*/

SET ANSI_NULLS ON;
GO
SET QUOTED_IDENTIFIER ON;
GO

-- Sum Table
CREATE TABLE [dbo].[TraderReport]
([ReportDate]              [DATE] NOT NULL, 
 [UserId]                  [INT] NOT NULL, 
 [Username]                [VARCHAR](50) NULL, 
 [TotalMatch]              [INT] NULL, 
 [Type1_FT_HDP]            [INT] NULL, 
 [Type1_FT_OU]             [INT] NULL, 
 [Type1_FT_HDPOU]          [INT] NULL, 
 [Type2_AUS_League]        [INT] NULL, 
 [Type2_AUS_League_Corner] [INT] NULL, 
 [Type2_JAP_Divison1]      [INT] NULL, 
 [Type2_JAP_Divison2]      [INT] NULL, 
 [Type3_Solo_Major]        [INT] NULL, 
 [Type4_Major]             [INT] NULL, 
 [Type4_Minor1]            [INT] NULL, 
 [Type4_Minor2]            [INT] NULL, 
 [Type4_Minor3]            [INT] NULL, 
 [Type4_1ST_Major]         [INT] NULL, 
 [Type4_1ST_Other]         [INT] NULL, 
 [Type4_Fantasy]           [INT] NULL, 
 [Type4_Corner_NextCorner] [INT] NULL, 
 [Type4_15M]               [INT] NULL, 
 [Type4_10M]               [INT] NULL, 
 [Type4_TotalBooking]      [INT] NULL, 
 [Type4_PKSO]              [INT] NULL, 
 [Type4_Winner]            [INT] NULL, 
 [PH_1X2_Major]            [INT] NULL, 
 [PH_1X2_Minor1]           [INT] NULL, 
 [PH_1X2_Minor2]           [INT] NULL, 
 [PH_1X2_Minor3]           [INT] NULL, 
 [PH_1X2_Others]           [INT] NULL, 
 [TurnOver_FT_HDP]         [INT] NULL, 
 [TurnOver_FT_OU]          [INT] NULL, 
 [TurnOver_1H_HDP]         [INT] NULL, 
 [TurnOver_1H_OU]          [INT] NULL, 
 [TurnOver_Others]         [INT] NULL, 
 [WinLoss_FT_HDP]          [INT] NULL, 
 [Winloss_FT_OU]           [INT] NULL, 
 [Winloss_1H_HDP]          [INT] NULL, 
 [Winloss_1H_OU]           [INT] NULL, 
 [Winloss_Others]          [INT] NULL, 
 [Robot3_X2]               [INT] NULL, 
 [Robot3_X3]               [INT] NULL, 
 [Robot3_X3_Plus]          [INT] NULL, 
 [Robot5_X5]               [INT] NULL, 
 [CreatedDate]             [DATETIMEOFFSET](7) NULL, 
 CONSTRAINT [PK_TraderReport] PRIMARY KEY CLUSTERED([ReportDate] ASC, [UserId] ASC)
)
ON [OWP_Data];

-- LA Report
GO
CREATE TABLE [dbo].[LAReport]
([ReportDate]     [DATE] NOT NULL, 
 [UserId]         [INT] NOT NULL, 
 [Username]       [VARCHAR](50) NULL, 
 [TotalMatches]   [INT] NULL, 
 [LinkLowerThan3] INT NULL, 
 [LinkX3]         INT NULL, 
 [LinkX6]         INT NULL, 
 [LinkX9Plus]     INT NULL, 
 [ProviderTv]     INT NULL, 
 [Provider]       INT NULL, 
 [TV]             INT NULL, 
 [Reporter]       INT NULL, 
 [CornerPlus]     INT NULL, 
 [TBookingPlus]   INT NULL, 
 [Fantasy]        INT NULL, 
 [GoalKick]       INT NULL, 
 [OtherProducts]  INT NULL, 
 [FTCorner]       INT NULL, 
 [ESoccer5Mins]   INT NULL, 
 [ESoccer15Mins]  INT NULL, 
 [ESoccer20Mins]  INT NULL, 
 [Others]         INT NULL, 
 [CreatedDate]    [DATETIMEOFFSET](7) NULL, 
 CONSTRAINT [PK_LAReport] PRIMARY KEY CLUSTERED([ReportDate] ASC, [UserId] ASC)
)
ON [OWP_Data];
GO

ALTER TABLE [dbo].[LAReport]
ADD [ESoccer6Mins]   INT NULL;