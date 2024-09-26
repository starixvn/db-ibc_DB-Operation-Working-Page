/*<info serverAlias="DBOWP-bodb_OWP" executers="wsv_owp" isFunction="0"></info>*/
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
 '<root><xml path="r/z" /><row item="Round" alias="osRound" /><row item="WeekMatch" alias="osWeekMatch" /><row item="OfferLines" alias="osOfferLines" /><row item="BetDelay" alias="osBetDelay" /><row item="Provider" alias="osProvider" /><row item="KOFromTime" alias="osKOFromTime" /><row item="KOToTime" alias="osKOToTime" /><row item="SpreadHDP" alias="osSpreadHDP" /><row item="SpreadOU" alias="osSpreadOU" /><row item="MaxBetHDP" alias="osMaxBetHDP" /><row item="MaxBetOU" alias="osMaxBetOU" /><row item="Remark" alias="osRemark" /><row item="IsManualUpdateScore" alias="osIsManualUpdateScore" /><row item="IsIpTvOnly" alias="osIsIpTvOnly" /><row item="BetType" alias="osBetType" /></root>'
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
 '<root><xml path="r/z" /><row item="Round" alias="osRound" /><row item="WeekMatch" alias="osWeekMatch" /><row item="OfferLines" alias="osOfferLines" /><row item="BetDelay" alias="osBetDelay" /><row item="Provider" alias="osProvider" /><row item="KOFromTime" alias="osKOFromTime" /><row item="KOToTime" alias="osKOToTime" /><row item="SpreadHDP" alias="osSpreadHDP" /><row item="SpreadOU" alias="osSpreadOU" /><row item="MaxBetHDP" alias="osMaxBetHDP" /><row item="MaxBetOU" alias="osMaxBetOU" /><row item="Remark" alias="osRemark" /><row item="IsManualUpdateScore" alias="osIsManualUpdateScore" /><row item="IsIpTvOnly" alias="osIsIpTvOnly" /><row item="BetType" alias="osBetType" /></root>'
);
GO


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
(125, 
 14, 
 42, 
 2, 
 'OWP_OSLeagueInfo_Add', 
 'OWP_OSLeagueInfo_Add', 
 '<root><xml path="r/z" /><row item="LeagueName" alias="osLeagueName" /><row item="IsActive" alias="osIsActive" /><row item="Region" alias="osRegion" /><row item="Category" alias="osCategory" /></root>'
);
GO



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
(126, 
 14, 
 42, 
 2, 
 'OWP_OSLeagueInfo_Edit', 
 'OWP_OSLeagueInfo_Edit', 
 '<root><xml path="r/z" /><row item="LeagueName" alias="osLeagueName" /><row item="IsActive" alias="osIsActive" /><row item="Region" alias="osRegion" /><row item="Category" alias="osCategory" /></root>'
);
GO

--------------------------------
--2. correct data 
--------------------------------

CREATE TABLE LeagueNameTemp ( Active bit ,  OldLeagueName  nvarchar(500),
    NewLeagueName  nvarchar(500))

INSERT INTO LeagueNameTemp values (1,'NBA','*NBA'),
(0,'NBA Play Off','*NBA Play Off'),
(0,'NBA Play Off Most 3 Points','*NBA Play Off Most 3 Points'),
(0,'NBA Play Off Most Point Scored Away','*NBA Play Off Most Point Scored Away'),
(0,'NBA Play Off Most Point Scored Home','*NBA Play Off Most Point Scored Home'),
(0,'WNBA','*WNBA'),
(1,'FIBA 3x3 Series Women (in Ulaanbaatar, Mongolia)','*FIBA 3x3 Series Women (in Ulaanbaatar, Mongolia)'),
(1,'NBA Play-In Tournament','*NBA Play-In Tournament'),
(1,'WNBA Pre Season','*WNBA Pre Season'),
(1,'WNBA Regular Season','*WNBA Regular Season'),
(1,'NBA Regular Season (New)(Last Two Match)','*NBA Regular Season (New)(Last Two Match)'),
(1,'NBA Preseason (New)','*NBA Preseason (New)'),
(1,'NBA Scrimmage Games','*NBA Scrimmage Games'),
(1,'WNBA Final','*WNBA Final'),
(1,'NBA 2K League','*NBA 2K League'),
(1,'NBA Regular Season (New)','*NBA Regular Season (New)'),
(1,'NBA Most Point Scored','*NBA Most Point Scored'),
(1,'NBA Summer League','*NBA Summer League'),
(1,'NBA Summer League (in Sacramento)','*NBA Summer League (in Sacramento)'),
(1,'WNBA PlayOffs','*WNBA PlayOffs'),
(1,'WNBA All Star Game','*WNBA All Star Game'),
(1,'NBA Most 3 Points','*NBA Most 3 Points'),
(1,'*NBA G League (in Orlando, Florida)','*NBA G League (in Orlando, Florida)'),
(1,'NBA G League','*NBA G League'),
(1,'NBA Summer League (in California)','*NBA Summer League (in California)'),
(1,'NBA Summer League (in Utah)','*NBA Summer League (in Utah)')

UPDATE OSLeague
SET LeagueName = temp.NewLeagueName,
    IsActive = temp.Active
FROM OSLeague AS l
INNER JOIN LeagueNameTemp AS temp 
       ON  l.LeagueName = temp.OldLeagueName

DROP TABLE LeagueNameTemp

CREATE TABLE OSSettingBetDelay(
	Id INT IDENTITY(1,1) PRIMARY KEY,
	LeagueSettingId INT NOT NULL,
	BetDelayId  INT
)

INSERT INTO OSSettingBetDelay 
SELECT t.LeagueSettingId, t.BetDelayId FROM OSLeagueSetting t

ALTER TABLE OSLeagueSetting
DROP COLUMN BetDelayId;

UPDATE OSLeagueSetting 
SET KOFromTime =DATEADD(MINUTE, 1, KOFromTime)
WHERE KOFromTime is not null and KOToTime is null 

UPDATE OSRegionOption
SET [Label]= '3x3 Challenge'
WHERE [Label]= '3x3 Challenger'

UPDATE OSWeekMatchOption
SET [Label]= '21st'
WHERE [Label]= '21th'

UPDATE OSWeekMatchOption
SET [Label]= '22nd'
WHERE [Label]= '22th'

UPDATE OSWeekMatchOption
SET [Label]= '23rd'
WHERE [Label]= '23th'
 
DROP TABLE OSStatusOption
DROP PROCEDURE OWP_OSLeagueSetting_GetStatusOption

