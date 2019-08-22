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
	92
	,4
	,28
	,2
	,'OWP_LiveDetail_MatchInfo_Update'
	,'OWP_LiveDetail_MatchInfo_Update'
	,'<root><xml path="r/z" /><row item="OWPMatchId" alias="mt" /><row item="MatchStatus" alias="ms" /><row item="InfoSiteMatchId" alias="ifi" /><row item="Remark" alias="rm" /><row item="IsSelected" alias="is" /><row item="SelectedBy" alias="sb" /><row item="Round" alias="rd" /><row item="IsSoloMatch" alias="sl" /><row item="Venue" alias="vn" /><row item="Division" alias="ds" /><row item="Market" alias="mk" /><row item="OtherTime" alias="ot" /><row item="Website1" alias="ws1" /><row item="Website2" alias="ws2" /><row item="Website3" alias="ws3" /><row item="Website4" alias="ws4" /></root>'
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
	96
	,4
	,28
	,2
	,'OWP_LiveDetail_Update_ProviderInfo'
	,'OWP_LiveDetail_Update_ProviderInfo'
	,'<root><xml path="r/z" /><row item="OWPMatchId" alias="mt" /><row item="TVCode" alias="tv" /><row item="Channel" alias="ch" /><row item="WatchBet" alias="wb" /><row item="Provider" alias="pv" /><row item="Runner" alias="rn" /><row item="Phone" alias="ph" /><row item="Agent" alias="ag" /></root>'
	)

GO

