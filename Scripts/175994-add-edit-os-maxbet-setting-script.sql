
/*
	Created: Johnny.Thai
	Date: 20220804
	Task: [Redmine: #175994]
	DB: bodb_OWP
*/

--------------------------------
-- 1. Write Log
--------------------------------
INSERT INTO dbo.Module
(ModuleId, 
 ModuleName
)
VALUES
(14, 
 'OsLeagueSetting'
);
INSERT INTO dbo.ModuleObject
(ModuleObjectId, 
 ModuleObjectName, 
 ModuleId
)
VALUES
(42, 
 'OsLeagueSetting', 
 14
);
INSERT INTO dbo.LogAction
(ActionId, 
 ModuleId, 
 [ModuleObjectId], 
 [ActionTypeId], 
 [ActionName], 
 [SPName], 
 [LogItems]
)
VALUES
(123, 
 14, 
 42, 
 1, 
 'OWP_OSLeagueSetting_Add', 
 'OWP_OSLeagueSetting_Add', 
 '<root><xml path="r/z" /><row item="LeagueName" alias="osLeagueName" /><row item="Region" alias="osRegion" /><row item="Category" alias="osCategory" /><row item="Round" alias="osRound" /><row item="WeekMatch" alias="osWeekMatch" /><row item="OfferLines" alias="osOfferLines" /><row item="BetDelay" alias="osBetDelay" /><row item="Provider" alias="osProvider" /><row item="KOFromTime" alias="osKOFromTime" /><row item="KOToTime" alias="osKOToTime" /><row item="SpreadHDP" alias="osSpreadHDP" /><row item="SpreadOU" alias="osSpreadOU" /><row item="MaxBetHDP" alias="osMaxBetHDP" /><row item="MaxBetOU" alias="osMaxBetOU" /><row item="Remark" alias="osRemark" /><row item="IsManualUpdateScore" alias="osIsManualUpdateScore" /><row item="IsIpTvOnly" alias="osIsIpTvOnly" /><row item="BetType" alias="osBetType" /></root>'
);

INSERT INTO dbo.LogAction
(ActionId, 
 ModuleId, 
 [ModuleObjectId], 
 [ActionTypeId], 
 [ActionName], 
 [SPName], 
 [LogItems]
)
VALUES
(124, 
 14, 
 42, 
 2, 
 'OWP_OSLeagueSetting_Edit', 
 'OWP_OSLeagueSetting_Edit', 
 '<root><xml path="r/z" /><row item="LeagueName" alias="osLeagueName" /><row item="Region" alias="osRegion" /><row item="Category" alias="osCategory" /><row item="Round" alias="osRound" /><row item="WeekMatch" alias="osWeekMatch" /><row item="OfferLines" alias="osOfferLines" /><row item="BetDelay" alias="osBetDelay" /><row item="Provider" alias="osProvider" /><row item="KOFromTime" alias="osKOFromTime" /><row item="KOToTime" alias="osKOToTime" /><row item="SpreadHDP" alias="osSpreadHDP" /><row item="SpreadOU" alias="osSpreadOU" /><row item="MaxBetHDP" alias="osMaxBetHDP" /><row item="MaxBetOU" alias="osMaxBetOU" /><row item="Remark" alias="osRemark" /><row item="IsManualUpdateScore" alias="osIsManualUpdateScore" /><row item="IsIpTvOnly" alias="osIsIpTvOnly" /><row item="BetType" alias="osBetType" /></root>'
);
GO