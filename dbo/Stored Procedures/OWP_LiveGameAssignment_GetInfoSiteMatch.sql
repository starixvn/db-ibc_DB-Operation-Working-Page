
/*<info serverAlias="DBOWP-bodb_OWP" executers="bodbOWPNet" isFunction="0"></info>*/

CREATE PROCEDURE [dbo].[OWP_LiveGameAssignment_GetInfoSiteMatch] @InfoSiteMatchId INT
AS
/*
Created: 20190725@Tyler.Dang
Task : Get InfoSiteMatch on Add new event
DB: bodb_OWP

Revisions:
	20190725@Tyler.Dang: Initial SP - [Redmine: #117578]
	20190912@Leo.Vo: Return tv & agent detail - [Redmine: #119650]
*/
BEGIN
	SET NOCOUNT ON
	
	DECLARE @AgentIds VARCHAR(200)
		,@TVIds VARCHAR(200)
		
	SELECT @AgentIds = AgentIds
		,@TVIds = TVIds
	FROM dbo.InfoSiteMatch WITH (NOLOCK)
	WHERE InfoSiteMatchId = @InfoSiteMatchId
	
	DECLARE @tblAgentIds TABLE(
		AgentId INT
	)
	DECLARE @tblTVIds TABLE(
		TVId INT
	)
	
	INSERT INTO @tblAgentIds (
		AgentId
	)
	SELECT val
	FROM dbo.strSplit(@AgentIds, ',')
	
	INSERT INTO @tblTVIds (
		TVId
	)
	SELECT val
	FROM dbo.strSplit(@TVIds, ',')
	
	SELECT CAST(EventDateTime AS TIME) [KOTime]
		,LeagueName
		,HomeName
		,AwayName
		,[Round]
		,Division
		,WB
		,Channel
		,Website1
		,Website2
		,Website3
		,Website4
	FROM dbo.[InfoSiteMatch] WITH (NOLOCK)
	WHERE InfoSiteMatchId = @InfoSiteMatchId
	
	SELECT a.AgentId
		,a.AgentName
	FROM dbo.Agent AS a WITH (NOLOCK)
	INNER JOIN @tblAgentIds AS i ON a.AgentId = i.AgentId
	
	SELECT tv.TVId
		,tv.TVCode
		,tv.Color
	FROM dbo.Television AS tv WITH (NOLOCK)
	INNER JOIN @tblTVIds AS i ON tv.TVId = i.TVId
END