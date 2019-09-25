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

UPDATE dbo.LogAction
SET LogItems='<root><xml path="r/z" /><row item="OWPMatchId" alias="mt" /><row item="TVCode" alias="tv" /><row item="Channel" alias="ch" /><row item="WatchBet" alias="wb" /><row item="Provider" alias="pv" /><row item="OtherProvider" alias="opv" /><row item="Phone" alias="ph" /><row item="Agent" alias="ag" /></root>'
WHERE ActionId=96

GO
