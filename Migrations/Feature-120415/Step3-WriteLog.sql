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
SET LogItems='<root><xml path="r/z" /><row item="OWPMatchId" alias="mt" /><row item="TVCode" alias="tv" /><row item="Channel" alias="ch" /><row item="WatchBet" alias="wb" /><row item="Provider" alias="pv" /><row item="OtherProvider" alias="opv" /><row item="Phone" alias="ph" /><row item="Agent" alias="ag" /></root>'
WHERE ActionId=96

UPDATE dbo.LogAction WITH (ROWLOCK)
SET LogItems = '<root><xml path="r/z" /><row item="OWPMatchId" alias="mt" /><row item="MatchStatus" alias="ms" /><row item="InfoSiteMatchId" alias="ifi" /><row item="Remark" alias="rm" /><row item="Round" alias="rd" /><row item="IsSoloMatch" alias="sl" /><row item="Venue" alias="vn" /><row item="Division" alias="ds" /><row item="Market" alias="mk" /><row item="OtherTime" alias="ot" /><row item="Website1" alias="ws1" /><row item="Website2" alias="ws2" /><row item="Website3" alias="ws3" /><row item="Website4" alias="ws4" /></root>' 
WHERE SPName = 'OWP_LiveDetail_Update_MatchInfo'

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
