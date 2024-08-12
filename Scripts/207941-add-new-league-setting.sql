
/*<info serverAlias="DBOWP-bodb_OWP" executers="wsv_owp" isFunction="0"></info>*/
/*
Created: 20240801@Carlos.nguyen
Task : Remove/insert league setting
DB: bodb_OWP

Revisions:
	20240801@Los: Remove/insert league setting   - [Redmine: #207941]
*/

---------------Remove old setting---------------------
DELETE FROM LeagueManagementSetting
------------- log ------------------

INSERT INTO [dbo].[Module]
([ModuleId], 
 [ModuleName]
)
       SELECT 30, 
              'RemoveLeagueSetting'
       WHERE NOT EXISTS
       (
           SELECT 1
           FROM [dbo].[Module] WITH(NOLOCK)
           WHERE [ModuleId] = 30
       );
GO


INSERT INTO [dbo].[ModuleObject]
([ModuleObjectId], 
 [ModuleObjectName], 
 [ModuleId]
)
       SELECT 60, 
              'RemoveLeagueSetting', 
              30
       WHERE NOT EXISTS
       (
           SELECT 1
           FROM [dbo].[ModuleObject] WITH(NOLOCK)
           WHERE [ModuleObjectId] = 60
       );
GO


IF NOT EXISTS
(
    SELECT 1
    FROM [LogAction]
    WHERE ActionId = 140
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
    (140, 
     30, 
     60, 
     3, 
     N'OWP_NewLeagueSetting_RemoveLeagueSetting', 
     N'OWP_NewLeagueSetting_RemoveLeagueSetting', 
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
				<row item="LSTNote" />
				<row item="Remark2" />
				<row item="Comment" />
				</root>'
    );
GO