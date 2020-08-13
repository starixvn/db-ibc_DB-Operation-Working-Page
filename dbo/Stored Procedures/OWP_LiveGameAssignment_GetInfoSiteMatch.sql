
/*<info serverAlias="DBOWP-bodb_OWP" executers="bodbOWPNet" isFunction="0"></info>*/
CREATE PROCEDURE [dbo].[OWP_LiveGameAssignment_GetInfoSiteMatch] @InfoSiteMatchId INT
	,@EventDate DATE
	,@ErrCode INT = 0 OUTPUT
	,@ErrMsg NVARCHAR(MAX) = '' OUTPUT
AS
/*
Created: 20190725@Tyler.Dang
Task : Get InfoSiteMatch on Add new event
DB: bodb_OWP

Revisions:
	20190725@Tyler.Dang: Initial SP - [Redmine: #117578]
	20190912@Leo.Vo: Return tv & agent detail - [Redmine: #119650]
	20190918@Kane.Le: Check duplicate InfoSiteID - [Redmine: #120415]
	20191021@Leo.Vo: Check duplicate InfoSiteID - [Redmine: #120415]
*/
BEGIN
	SET NOCOUNT ON

	DECLARE @FromDate DATETIME = DATEADD(DAY, DATEDIFF(DAY, 0, @EventDate), '12:00:00')
		,@ToDate DATETIME = DATEADD(DAY, DATEDIFF(DAY, - 1, @EventDate), '11:59:59')

	IF EXISTS (
			SELECT 1
			FROM dbo.OWPMatch AS m WITH (NOLOCK)
			WHERE m.InfoSiteMatchId = @InfoSiteMatchId
				AND m.EventDateTime >= @FromDate AND m.EventDateTime <= @ToDate
			)
	BEGIN
		SELECT @ErrCode = 2
			,@ErrMsg = 'InfoSiteID is duplicating.'

		RETURN
	END

	IF NOT EXISTS (
			SELECT 1
			FROM dbo.[InfoSiteMatch] AS m WITH (NOLOCK)
			WHERE m.InfoSiteMatchId = @InfoSiteMatchId
			)
	BEGIN
		SELECT @ErrCode = 1
			,@ErrMsg = 'This InfoSiteID is not existing.'

		RETURN
	END

	DECLARE @AgentIds VARCHAR(200)
		,@TVIds VARCHAR(200)

	SELECT @AgentIds = AgentIds
		,@TVIds = TVIds
	FROM dbo.InfoSiteMatch WITH (NOLOCK)
	WHERE InfoSiteMatchId = @InfoSiteMatchId

	DECLARE @tblAgentIds TABLE (AgentId INT)
	DECLARE @tblTVIds TABLE (TVId INT)

	INSERT INTO @tblAgentIds (AgentId)
	SELECT Value
	FROM dbo.fnc_SplitString(@AgentIds, ',')

	INSERT INTO @tblTVIds (TVId)
	SELECT Value
	FROM dbo.fnc_SplitString(@TVIds, ',')

	SELECT CAST(EventDateTime AS TIME) [KOTime]
		,LeagueName
		,HomeName
		,AwayName
		,[Round]
		,Division
		,WB
		,IPTV AS IpTv
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

	SELECT @ErrCode = 0
		,@ErrMsg = ''
END