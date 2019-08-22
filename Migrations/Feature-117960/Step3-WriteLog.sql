/*
	Created: Kane.Le
	Date: 20190814
	Task: [Redmine: #117960]
	DB: bodb_OWP
*/

--------------------------------
-- 1. Write Log
--------------------------------

INSERT INTO dbo.ModuleObject (ModuleObjectId, ModuleObjectName, ModuleId)
VALUES (28, 'Edit Event', 4)

INSERT INTO dbo.LogAction (
	ActionId
	,ModuleId
	,[ModuleObjectId]
	,[ActionTypeId]
	,[ActionName]
	,[SPName]
	,[LogItems]
	)
VALUES (
	90
	,4
	,28
	,2
	,'OWP_LiveGameAssignment_EditSingleMatch'
	,'OWP_LiveGameAssignment_EditSingleMatch'
	,'<root><xml path="r/z" /><row item="OWPMatchId" alias="mid" /><row item="LeagueName" alias="lname" /><row item="HomeName" alias="hname" /><row item="AwayName" alias="aname" /><row item="MatchNo" alias="mno" /><row item="KickOfTime" alias="ko" /></root>'
	)

GO

INSERT INTO dbo.LogAction (
	ActionId
	,ModuleId
	,[ModuleObjectId]
	,[ActionTypeId]
	,[ActionName]
	,[SPName]
	,[LogItems]
	)
VALUES (
	91
	,4
	,28
	,2
	,'OWP_MatchSetting_Create'
	,'OWP_MatchSetting_Create'
	,'<root><xml path="r/z" /><row item="Bettype" alias="bttype" /><row item="Maxbet" alias="mbet" /><row item="Spread" alias="spread" /><row item="MaxbetCN88" alias="mbetCN88" /><row item="SpreadCN88" alias="sCN88" /></root>'
	)

GO

INSERT INTO dbo.LogAction (
	ActionId
	,ModuleId
	,[ModuleObjectId]
	,[ActionTypeId]
	,[ActionName]
	,[SPName]
	,[LogItems]
	)
VALUES (
	92
	,4
	,28
	,2
	,'OWP_LiveDetail_Update_MatchInfo'
	,'OWP_LiveDetail_Update_MatchInfo'
	,'<root><xml path="r/z" /><row item="OWPMatchId" alias="mt" /><row item="InfoSiteMatchId" alias="ifi" /><row item="Remark" alias="rm" /><row item="Round" alias="rd" /><row item="IsSoloMatch" alias="sl" /><row item="Venue" alias="vn" /><row item="Division" alias="ds" /><row item="Market" alias="mk" /><row item="OtherTime" alias="ot" /><row item="Website1" alias="ws1" /><row item="Website2" alias="ws2" /><row item="Website3" alias="ws3" /><row item="Website4" alias="ws4" /></root>'
	)

GO

INSERT INTO dbo.LogAction (
	ActionId
	,ModuleId
	,[ModuleObjectId]
	,[ActionTypeId]
	,[ActionName]
	,[SPName]
	,[LogItems]
	)
VALUES (
	93
	,4
	,28
	,2
	,'OWP_LiveDetail_MatchInfo_UpdateMatchStatus'
	,'OWP_LiveDetail_MatchInfo_UpdateMatchStatus'
	,'<root><xml path="r/z" /><row item="OWPMatchId" alias="mt" /><row item="MatchStatus" alias="ms" /></root>'
	)

GO

INSERT INTO dbo.LogAction (
	ActionId
	,ModuleId
	,[ModuleObjectId]
	,[ActionTypeId]
	,[ActionName]
	,[SPName]
	,[LogItems]
	)
VALUES (
	94
	,4
	,28
	,2
	,'OWP_MatchSetting_Delete'
	,'OWP_MatchSetting_Delete'
	,'<root><xml path="r/z" /><row item="Bettype" alias="bttype" /><row item="Maxbet" alias="mbet" /><row item="Spread" alias="spread" /><row item="MaxbetCN88" alias="mbetCN88" /><row item="SpreadCN88" alias="sCN88" /></root>'
	)

GO

INSERT INTO dbo.LogAction (
	ActionId
	,ModuleId
	,[ModuleObjectId]
	,[ActionTypeId]
	,[ActionName]
	,[SPName]
	,[LogItems]
	)
VALUES (
	95
	,4
	,28
	,2
	,'OWP_MatchSetting_Update'
	,'OWP_MatchSetting_Update'
	,'<root><xml path="r/z" /><row item="Bettype" alias="bttype" /><row item="Maxbet" alias="mbet" /><row item="Spread" alias="spread" /><row item="MaxbetCN88" alias="mbetCN88" /><row item="SpreadCN88" alias="sCN88" /></root>'
	)

GO

INSERT INTO dbo.LogAction (
	ActionId
	,ModuleId
	,[ModuleObjectId]
	,[ActionTypeId]
	,[ActionName]
	,[SPName]
	,[LogItems]
	)
VALUES (
	96
	,4
	,28
	,2
	,'OWP_LiveDetail_Update_ProviderInfo'
	,'OWP_LiveDetail_Update_ProviderInfo'
	,'<root><xml path="r/z" /><row item="OWPMatchId" alias="mt" /><row item="TVCode" alias="tv" /><row item="Channel" alias="ch" /><row item="WatchBet" alias="wb" /><row item="Provider" alias="pv" /><row item="Runner" alias="rn" /><row item="Phone" alias="ph" /><row item="Agent" alias="ag" /></root>'
	)

GO

INSERT INTO dbo.LogAction (
	ActionId
	,ModuleId
	,[ModuleObjectId]
	,[ActionTypeId]
	,[ActionName]
	,[SPName]
	,[LogItems]
	)
VALUES (
	97
	,4
	,28
	,2
	,'OWP_LiveDetail_UpdateTradingInfo'
	,'OWP_LiveDetail_UpdateTradingInfo'
	,'<root><xml path="r/z" /><row item="OWPMatchId" alias="mt" /><row item="NoOfHDPId" alias="hdp" /><row item="MatchOfferIds" alias="mo" /></root>'
	)
GO
