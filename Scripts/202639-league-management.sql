
/*<info serverAlias="DBOWP-bodb_OWP" executers="wsv_owp" isFunction="0"></info>*/
/*
Created: 20240422@Carlos.nguyen
Task : Provider arrangement log
DB: bodb_OWP

Revisions:
	20240422@Carlos.nguyen: init data league management - [Redmine: #202639]
*/

ALTER TABLE OWPLeague
ADD New_CategoryId INT;

CREATE TABLE [dbo].[LeagueManagementSetting]
([Id]                       [INT] IDENTITY(1, 1) , 
 [OWPLeagueId]              [INT] NOT NULL, 
 [FullConditionDescription] [NVARCHAR](MAX) NULL, 
 [Spread_HDP]               [MONEY] NULL, 
 [Spread_OU]                [MONEY] NULL, 
 [Spread_Note]              [NVARCHAR](2000) NULL, 
 [MaxbetWD_HDP]             [MONEY] NULL, 
 [MaxbetWD_HDP_Note]        [NVARCHAR](2000) NULL, 
 [WD_NoOfHDP]               [NVARCHAR](2000), 
 [WD_NoOfHDP_Note]          [NVARCHAR](2000) NULL, 
 [MaxbetWK_HDP]             [MONEY] NULL, 
 [MaxbetWK_HDP_Note]        [NVARCHAR](2000) NULL, 
 [WK_NoOfHDP]               [NVARCHAR](2000) NULL, 
 [WK_NoOfHDP_Note]          [NVARCHAR](2000) NULL, 
 [LSTNote]                  [NVARCHAR](2000) NULL, 
 [Remark2]                  [NVARCHAR](2000) NULL, 
 [Comment]                  [NVARCHAR](MAX) NULL,
 CONSTRAINT [PK_LeagueManagementSetting] PRIMARY KEY CLUSTERED([Id] ASC)
 WITH(PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [OWP_Data]
)
ON [OWP_Data];

CREATE TABLE [dbo].[EventPicking]
([Id]              [INT] IDENTITY(1, 1), 
 [InfositeMatchId] [INT], 
 MaxbetHdp         MONEY, 
 SpreadHdp         MONEY, 
 SpreadOu          MONEY, 
 NoOfHDP           NVARCHAR(2000),
 LSTNote NVARCHAR(2000),
 CONSTRAINT [PK_EventPicking] PRIMARY KEY CLUSTERED([Id] ASC)
 WITH(PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [OWP_Data]
)
ON [OWP_Data];
------------- log ------------------

INSERT INTO [dbo].[Module]
([ModuleId], 
 [ModuleName]
)
       SELECT 20, 
              'NewLeagueSetting'
       WHERE NOT EXISTS
       (
           SELECT 1
           FROM [dbo].[Module] WITH(NOLOCK)
           WHERE [ModuleId] = 20
       );
INSERT INTO [dbo].[ModuleObject]
([ModuleObjectId], 
 [ModuleObjectName], 
 [ModuleId]
)
       SELECT 48, 
              'NewLeagueSetting', 
              20
       WHERE NOT EXISTS
       (
           SELECT 1
           FROM [dbo].[ModuleObject] WITH(NOLOCK)
           WHERE [ModuleObjectId] = 48
       );
IF NOT EXISTS
(
    SELECT 1
    FROM [LogAction]
    WHERE ActionId = 134
)
    INSERT INTO [dbo].[LogAction]
    ([ActionId], 
     [ModuleId], 
     [ModuleObjectId], 
     [ActionTypeId], 
     [ActionName], 
     [SPName], 
     [LogItems]
    )
    VALUES
    (134, 
     20, 
     48, 
     2, 
     N'OWP_NewLeagueSetting_UpdateLeagueSetting', 
     N'OWP_NewLeagueSetting_UpdateLeagueSetting', 
     N'<root><xml path="r/z"/><row item="LeagueSettingId" />
				<row item="OWPLeagueId" />
				<row item="FullConditionDescription" />
				<row item="Spread_HDP_Value" />
				<row item="Spread_OU_Value" />
				<row item="Spread_Note" />
				<row item="MaxbetWD_HDP_Value" />
				<row item="MaxbetWD_HDP_Note" />
				<row item="WD_NoOfHDP_Value" />
				<row item="WD_NoOfHDP_Note" />
				<row item="WK_NoOfHDP_Value" />
				<row item="WK_NoOfHDP_Note" />
				</root>'
    );
INSERT INTO [dbo].[Module]
([ModuleId], 
 [ModuleName]
)
       SELECT 21, 
              'EventPicking'
       WHERE NOT EXISTS
       (
           SELECT 1
           FROM [dbo].[Module] WITH(NOLOCK)
           WHERE [ModuleId] = 21
       );
INSERT INTO [dbo].[ModuleObject]
([ModuleObjectId], 
 [ModuleObjectName], 
 [ModuleId]
)
       SELECT 49, 
              'EventPicking', 
              21
       WHERE NOT EXISTS
       (
           SELECT 1
           FROM [dbo].[ModuleObject] WITH(NOLOCK)
           WHERE [ModuleObjectId] = 49
       );
IF NOT EXISTS
(
    SELECT 1
    FROM [LogAction]
    WHERE ActionId = 135
)
    INSERT INTO [dbo].[LogAction]
    ([ActionId], 
     [ModuleId], 
     [ModuleObjectId], 
     [ActionTypeId], 
     [ActionName], 
     [SPName], 
     [LogItems]
    )
    VALUES
    (135, 
     21, 
     49, 
     2, 
     N'OWP_EventPicking_UpdateMaxbetSpread', 
     N'OWP_EventPicking_UpdateMaxbetSpread', 
     N'<root><xml path="r/z"/>
				<row item="InfoSiteMatchId" />
				<row item="MaxbetHdp" />
				<row item="NoOfHDP" />
				<row item="SpreadHdp" />
				<row item="SpreadOu" />
			</root>'
    );