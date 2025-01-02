
/*<info serverAlias="DBOWP-bodb_OWP" executers="wsv_owp" isFunction="0"></info>*/

CREATE PROCEDURE [dbo].[OWP_SyncMatchInfoToAdminSite_GetMatchOdd] @MatchIds VARCHAR(MAX)
AS
/*
Created: 20241223@Tim
Task: sync match odds to AdminSite
DB: bodb_OWP

Revisions:
	20241223@Tim: initial - [Redmine: #212957]
*/
BEGIN
	SET NOCOUNT ON;

    DECLARE @BettypeHandicap INT = 1, @BettypeOU INT = 3

    CREATE TABLE #tblMatch (OWPMatchId INT)

    INSERT INTO #tblMatch (OWPMatchId)
    SELECT value
    FROM STRING_SPLIT(@MatchIds, ',') AS m

    SELECT odd.OWPMatchId
        ,odd.Bettype AS BettypeId
        ,odd.TeamChoice
        ,odd.HDP
    FROM dbo.MatchRecommendOdds AS odd WITH (NOLOCK)
        INNER JOIN #tblMatch AS m ON odd.OWPMatchId = m.OWPMatchId
    WHERE odd.Bettype IN (@BettypeHandicap, @BettypeOU)

	SELECT odd.OWPMatchId
        ,dt.Choice
        ,odd.Bettype AS BettypeId
		,dt.Odds
	FROM dbo.MatchRecommendOdds AS odd WITH (NOLOCK)
	    INNER JOIN dbo.MatchRecommendOddsDetail AS dt WITH (NOLOCK) ON odd.MatchRecommendOddsId = dt.MatchRecommendOddsId
        INNER JOIN #tblMatch AS m ON odd.OWPMatchId = m.OWPMatchId
	WHERE odd.Bettype IN (@BettypeHandicap, @BettypeOU)

    DROP TABLE #tblMatch
END