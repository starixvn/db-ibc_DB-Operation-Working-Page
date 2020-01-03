/*
	Created: Kane.Le
	Date: 20191220
	Task: schema [Redmine: #124448]
	DB: bodb_OWP
*/

USE bodb_OWP;
GO

-- add new column Market
ALTER TABLE dbo.MatchInfo
ADD Market NVARCHAR(250)
GO

ALTER TABLE dbo.MatchSetting
ALTER COLUMN Spread MONEY
GO
ALTER TABLE dbo.MatchSetting
ALTER COLUMN SpreadCN88 MONEY
GO

ALTER TABLE dbo.AutoAssignmentRequest
ADD Id INT IDENTITY(1,1),
	RequestDate DATETIME,
	ResponseDate DATETIME
GO

CREATE TABLE [dbo].[LSTReport](
	[ReportDate] [date] NULL,
	[UserId] [int] NULL,
	[Username] [varchar](50) NULL,
	[SectionId] [int] NULL,
	[SectionName] [nvarchar](50) NULL,
	[TotalMatch] [int] NULL,
	[Type1_FT_HDP] [int] NULL,
	[Type1_FT_OU] [int] NULL,
	[Type1_FT_HDPOU] [int] NULL,
	[Type2_AUS_League] [int] NULL,
	[Type2_AUS_League_Corner] [int] NULL,
	[Type2_JAP_Divison1] [int] NULL,
	[Type2_JAP_Divison2] [int] NULL,
	[Robot3_X2] [int] NULL,
	[Robot3_X3] [int] NULL,
	[Robot3_X3_Plus] [int] NULL,
	[Type3_Solo_Major] [int] NULL,
	[Type4_Major] [int] NULL,
	[Type4_Minor1] [int] NULL,
	[Type4_Minor2] [int] NULL,
	[Type4_Minor3] [int] NULL,
	[Type4_1ST_Major] [int] NULL,
	[Type4_1ST_Other] [int] NULL,
	[Type4_Fantasy] [int] NULL,
	[Type4_Corner_NextCorner] [int] NULL,
	[Type4_15M] [int] NULL,
	[Type4_10M] [int] NULL,
	[Type4_TotalBooking] [int] NULL,
	[Type4_PKSO] [int] NULL,
	[Type4_Winner] [int] NULL,
	[PH_1X2_Major] [int] NULL,
	[PH_1X2_Minor1] [int] NULL,
	[PH_1X2_Minor2] [int] NULL,
	[PH_1X2_Minor3] [int] NULL,
	[PH_1X2_Others] [int] NULL,
	[X5] [int] NULL,
	[TurnOver_FT_HDP] [int] NULL,
	[TurnOver_FT_OU] [int] NULL,
	[TurnOver_1H_HDP] [int] NULL,
	[TurnOver_1H_OU] [int] NULL,
	[TurnOver_Others] [int] NULL,
	[WinLoss_FT_HDP] [int] NULL,
	[Winloss_FT_OU] [int] NULL,
	[Winloss_1H_HDP] [int] NULL,
	[Winloss_1H_OU] [int] NULL,
	[Winloss_Others] [int] NULL,
	[CreatedDate] [datetimeoffset](7) NULL
) ON [OWP_Data]
GO


CREATE CLUSTERED INDEX IX_ReportDate_UserId_LSTReport
ON dbo.LSTReport (ReportDate, UserId);
GO