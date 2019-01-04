
/*<info serverAlias="DBOWP-bodb_OWP" executers="bodbOWPNet" isFunction="0"></info>*/
CREATE PROCEDURE [dbo].[Task_OWP_SyncInfoSiteMatch]
AS
/*    
 Created: 20181030@Leo.Vo
 Task : Sync InfoSite match
 DB: bodb_OWP    
    
 Revisions:
	20181030@Leo.Vo: Initial SP - [Redmine: #103598]
	20181129@Leo.Vo: Not sync Agent - [Redmine: #105574]
	20190104@Kane.Le: Not sync IsDeleted events - [Redmine: #107257]
*/
BEGIN
	SET NOCOUNT ON

	DECLARE @Today DATE = CONVERT(DATE, GETDATE())
		,@NumberDayDeleteOldData INT = 1

	-- remove old data
	DELETE dbo.InfoSiteMatch
	WITH (ROWLOCK)
	WHERE EventDateTime < DATEADD(DAY, - @NumberDayDeleteOldData, @Today)

	-- create temp table remove IsDeleted
	CREATE TABLE #tblInfoSiteMatch (
		[InfoSiteMatchId] [int] NOT NULL
		,[EventDateTime] [datetime] NOT NULL
		,[UpdatedTime] [datetime] NOT NULL
		,[LeagueName] [nvarchar](2000) NOT NULL
		,[HomeName] [nvarchar](2000) NOT NULL
		,[AwayName] [nvarchar](2000) NOT NULL
		,[Round] [nvarchar](2000) NULL
		,[Division] [nvarchar](2000) NULL
		,[Agent] [nvarchar](2000) NULL
		,[TV] [nvarchar](2000) NULL
		,[Channel] [nvarchar](2000) NULL
		,[WB] [nvarchar](2000) NULL
		,[Website1] [nvarchar](2000) NULL
		,[Website2] [nvarchar](2000) NULL
		,[Website3] [nvarchar](2000) NULL
		,[Website4] [nvarchar](2000) NULL
		,[OWPLeagueId] [int] NOT NULL
		,[OWPHomeId] [int] NOT NULL
		,[OWPAwayId] [int] NOT NULL
		,[AgentIds] [varchar](200) NULL
		,[TVIds] [varchar](200) NULL
		,[IsDeleted] [bit] NULL
		)

	INSERT INTO #tblInfoSiteMatch
	SELECT [InfoSiteMatchId]
		,[EventDateTime]
		,[UpdatedTime]
		,[LeagueName]
		,[HomeName]
		,[AwayName]
		,[Round]
		,[Division]
		,[Agent]
		,[TV]
		,[Channel]
		,[WB]
		,[Website1]
		,[Website2]
		,[Website3]
		,[Website4]
		,[OWPLeagueId]
		,[OWPHomeId]
		,[OWPAwayId]
		,[AgentIds]
		,[TVIds]
		,[IsDeleted]
	FROM dbo.InfoSiteMatch WITH (NOLOCK)
	WHERE IsDeleted <> 1

	-- sync League
	MERGE INTO dbo.OWPMatch AS om
	USING (
		SELECT im.InfoSiteMatchId
			,im.OWPLeagueId
		FROM #tblInfoSiteMatch AS im WITH (NOLOCK)
		) AS im
		ON om.InfoSiteMatchId = im.InfoSiteMatchId
	WHEN MATCHED
		AND om.OWPLeagueId <> im.OWPLeagueId
		THEN
			UPDATE
			SET om.OWPLeagueId = im.OWPLeagueId;

	-- sync Home
	MERGE INTO dbo.OWPMatch AS om
	USING (
		SELECT im.InfoSiteMatchId
			,im.OWPHomeId
		FROM #tblInfoSiteMatch AS im WITH (NOLOCK)
		) AS im
		ON om.InfoSiteMatchId = im.InfoSiteMatchId
	WHEN MATCHED
		AND om.OWPHomeId <> im.OWPHomeId
		THEN
			UPDATE
			SET om.OWPHomeId = im.OWPHomeId;

	-- sync Away
	MERGE INTO dbo.OWPMatch AS om
	USING (
		SELECT im.InfoSiteMatchId
			,im.OWPAwayId
		FROM #tblInfoSiteMatch AS im WITH (NOLOCK)
		) AS im
		ON om.InfoSiteMatchId = im.InfoSiteMatchId
	WHEN MATCHED
		AND om.OWPAwayId <> im.OWPAwayId
		THEN
			UPDATE
			SET om.OWPAwayId = im.OWPAwayId;

	-- sync TVIds
	MERGE INTO dbo.MatchInfo AS om
	USING (
		SELECT om.OWPMatchId
			,im.TVIds
		FROM #tblInfoSiteMatch AS im WITH (NOLOCK)
		INNER JOIN dbo.OWPMatch AS om WITH (NOLOCK) ON im.InfoSiteMatchId = om.InfoSiteMatchId
		) AS im
		ON om.OWPMatchId = im.OWPMatchId
	WHEN MATCHED
		AND om.TVCode <> im.TVIds
		THEN
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
		FROM #tblInfoSiteMatch AS im WITH (NOLOCK)
		INNER JOIN dbo.OWPMatch AS om WITH (NOLOCK) ON im.InfoSiteMatchId = om.InfoSiteMatchId
		) AS im
		ON mi.OWPMatchId = im.OWPMatchId
	WHEN MATCHED
		THEN
			UPDATE
			SET mi.[Round] = im.[Round]
				,mi.Division = im.Division
				,mi.Channel = im.Channel
				,mi.WB = im.WB
				,mi.Website1 = im.Website1
				,mi.Website2 = im.Website2
				,mi.Website3 = im.Website3
				,mi.Website4 = im.Website4;

	DROP TABLE #tblInfoSiteMatch
END