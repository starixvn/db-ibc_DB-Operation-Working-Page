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