/*
	Created: Carlos.Nguyen
	Date: 20190924
	Task: [Redmine: #120415]
	DB: bodb_OWP
*/

--------------------------------
-- 1. Write Log
--------------------------------

USE [bodb_OWP]
GO

UPDATE dbo.LogAction WITH (ROWLOCK)
SET LogItems='<root><xml path="r/z" /><row item="TV" alias="tv" /><row item="TV" alias="tv" /><row item="IsUpdateTV" alias="iutv" /><row item="WatchBet" alias="wb" /><row item="IsUpdateWB" alias="iuwb" /><row item="Provider" alias="pv" /><row item="IsUpdateProvider" alias="iupv" /><row item="OtherProvider" alias="opv" /><row item="IsUpdateOtherProvider" alias="iuopv" /><row item="Phone" alias="ph" /><row item="IsUpdatePhone" alias="iuph" /><row item="Agent" alias="ag" /><row item="IsUpdateAgent" alias="iuag" /></root>'
WHERE ActionId = 96

UPDATE dbo.LogAction WITH (ROWLOCK)
SET LogItems = '<root><xml path="r/z" /><row item="MatchStatus" alias="ms" /><row item="IsSelected" alias="is" /><row item="InfoSiteMatchId" alias="ifi" /><row item="Remark" alias="rm" /><row item="Round" alias="rd" /><row item="IsUpdateRound" alias="iurd" /><row item="IsSoloMatch" alias="sl" /><row item="Venue" alias="vn" /><row item="IsUpdateVenue" alias="iuvn" /><row item="Division" alias="ds" /><row item="IsUpdateDivision" alias="iuds" /><row item="Market" alias="mk" /><row item="IsUpdateMarkets" alias="iumk" /><row item="OtherTime" alias="ot" /><row item="IsUpdateOtherTime" alias="iuot" /><row item="Website1" alias="ws1" /><row item="IsUpdateWebsite1" alias="iuws1" /><row item="Website2" alias="ws2" /><row item="IsUpdateWebsite2" alias="iuws2" /><row item="Website3" alias="ws3" /><row item="IsUpdateWebsite3" alias="iuws3" /><row item="Website4" alias="ws4" /><row item="IsUpdateWebsite4" alias="iuws4" /></root>' 
WHERE ActionId = 92

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
	98
	,4
	,28
	,2
	,'OWP_LiveDetail_DeselectMatch'
	,'OWP_LiveDetail_DeselectMatch'
	,'<root><xml path="r/z" /><row item="IsSelected" alias="is" /></root>'
	)
	
GO
