/*<info serverAlias="DBOWP-bodb_OWP" executers="wsv_owp" isFunction="0"></info>*/
/*
Created: 20250723@Hank
Task : Backup LeagueManagementSetting table data
DB: bodb_OWP

Revisions:
	20250723@Hank: Backup LeagueManagementSetting data - [Redmine: #233199]
	20250903@Hank: Update script to not truncate table - [Redmine: #233199]
*/

-- Drop backup table if exists
IF OBJECT_ID('dbo.LeagueManagementSetting_Backup', 'U') IS NOT NULL
BEGIN
    DROP TABLE [dbo].[LeagueManagementSetting_Backup];
    PRINT 'Existing backup table dropped.';
END

GO 

-- Create backup table
CREATE TABLE [dbo].[LeagueManagementSetting_Backup](
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
	[Comment] [nvarchar](max) NULL,
	[BackupDate] [datetime] NOT NULL DEFAULT GETDATE()
) ON [OWP_Data] TEXTIMAGE_ON [OWP_Data]
GO

-- Insert all data from original table to backup table
INSERT INTO [dbo].[LeagueManagementSetting_Backup]
(
	[OWPLeagueId],
	[FullConditionDescription],
	[Spread_HDP],
	[Spread_OU],
	[Spread_Note],
	[MaxbetWD_HDP],
	[MaxbetWD_HDP_Note],
	[WD_NoOfHDP],
	[WD_NoOfHDP_Note],
	[MaxbetWK_HDP],
	[MaxbetWK_HDP_Note],
	[WK_NoOfHDP],
	[WK_NoOfHDP_Note],
	[LSTNote],
	[Remark2],
	[Comment]
)
SELECT 
	[OWPLeagueId],
	[FullConditionDescription],
	[Spread_HDP],
	[Spread_OU],
	[Spread_Note],
	[MaxbetWD_HDP],
	[MaxbetWD_HDP_Note],
	[WD_NoOfHDP],
	[WD_NoOfHDP_Note],
	[MaxbetWK_HDP],
	[MaxbetWK_HDP_Note],
	[WK_NoOfHDP],
	[WK_NoOfHDP_Note],
	[LSTNote],
	[Remark2],
	[Comment]
FROM [dbo].[LeagueManagementSetting] WITH (NOLOCK);

GO 

TRUNCATE TABLE [dbo].[LeagueManagementSetting];