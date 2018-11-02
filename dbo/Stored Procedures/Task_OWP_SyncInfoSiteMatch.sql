
/*<info serverAlias="DBOWP-bodb_OWP" executers="bodbOWPNet" isFunction="0"></info>*/
CREATE PROCEDURE [dbo].[Task_OWP_SyncInfoSiteMatch]
AS
/*    
 Created: 20181030@Leo.Vo
 Task : Sync InfoSite match
 DB: bodb_OWP    
    
 Revisions:
	20181030@Leo.Vo: Initial SP - [Redmine: #103598]
*/
BEGIN
	SET NOCOUNT ON

	DECLARE @Today DATE = CONVERT(DATE, GETDATE())
		,@NumberDayDeleteOldData INT = 1

	-- remove old data
	DELETE dbo.InfoSiteMatch WITH (ROWLOCK, UPDLOCK)
	WHERE EventDateTime < DATEADD(DAY, - @NumberDayDeleteOldData, @Today)

	-- sync League
	MERGE INTO dbo.OWPMatch AS om
	USING (
		SELECT im.InfoSiteMatchId
			,im.OWPLeagueId
		FROM dbo.InfoSiteMatch AS im WITH (NOLOCK)
		) AS im ON om.InfoSiteMatchId = im.InfoSiteMatchId
	WHEN MATCHED
		AND om.OWPLeagueId <> im.OWPLeagueId THEN
			UPDATE
			SET om.OWPLeagueId = im.OWPLeagueId;

	-- sync Home
	MERGE INTO dbo.OWPMatch AS om
	USING (
		SELECT im.InfoSiteMatchId
			,im.OWPHomeId
		FROM dbo.InfoSiteMatch AS im WITH (NOLOCK)
		) AS im ON om.InfoSiteMatchId = im.InfoSiteMatchId
	WHEN MATCHED
		AND om.OWPHomeId <> im.OWPHomeId THEN
			UPDATE
			SET om.OWPHomeId = im.OWPHomeId;

	-- sync Away
	MERGE INTO dbo.OWPMatch AS om
	USING (
		SELECT im.InfoSiteMatchId
			,im.OWPAwayId
		FROM dbo.InfoSiteMatch AS im WITH (NOLOCK)
		) AS im ON om.InfoSiteMatchId = im.InfoSiteMatchId
	WHEN MATCHED
		AND om.OWPAwayId <> im.OWPAwayId THEN
			UPDATE
			SET om.OWPAwayId = im.OWPAwayId;

	-- sync AgentIds
	MERGE INTO dbo.MatchInfo AS om
	USING (
		SELECT om.OWPMatchId
			,im.AgentIds
		FROM dbo.InfoSiteMatch AS im WITH (NOLOCK)
			INNER JOIN dbo.OWPMatch AS om WITH (NOLOCK) ON im.InfoSiteMatchId = om.InfoSiteMatchId
		) AS im ON om.OWPMatchId = im.OWPMatchId
	WHEN MATCHED
		AND om.Agent <> im.AgentIds THEN
			UPDATE
			SET om.Agent = im.AgentIds;

	-- sync TVIds
	MERGE INTO dbo.MatchInfo AS om
	USING (
		SELECT om.OWPMatchId
			,im.TVIds
		FROM dbo.InfoSiteMatch AS im WITH (NOLOCK)
			INNER JOIN dbo.OWPMatch AS om WITH (NOLOCK) ON im.InfoSiteMatchId = om.InfoSiteMatchId
		) AS im ON om.OWPMatchId = im.OWPMatchId
	WHEN MATCHED
		AND om.TVCode <> im.TVIds THEN
			UPDATE
			SET om.TVCode = im.TVIds;

	-- sync Round, Division, Channel, WB, Website1, Website2, Website3, Website4
	MERGE INTO dbo.MatchInfo AS mi
	USING (
		SELECT om.OWPMatchId
			,im.[Round]
			,im.Division
			,im.Channel
			,im.WB
			,im.Website1
			,im.Website2
			,im.Website3
			,im.Website4
		FROM dbo.InfoSiteMatch AS im WITH (NOLOCK)
			INNER JOIN dbo.OWPMatch AS om WITH (NOLOCK) ON im.InfoSiteMatchId = om.InfoSiteMatchId
		) AS im ON mi.OWPMatchId = im.OWPMatchId
	WHEN MATCHED THEN
			UPDATE
			SET mi.[Round] = im.[Round]
				,mi.Division = im.Division
				,mi.Channel = im.Channel
				,mi.WB = im.WB
				,mi.Website1 = im.Website1
				,mi.Website2 = im.Website2
				,mi.Website3 = im.Website3
				,mi.Website4 = im.Website4;
END