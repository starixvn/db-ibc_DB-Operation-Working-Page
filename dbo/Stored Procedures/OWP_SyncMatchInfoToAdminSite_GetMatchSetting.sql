
/*<info serverAlias="DBOWP-bodb_OWP" executers="wsv_owp" isFunction="0"></info>*/

CREATE PROCEDURE [dbo].[OWP_SyncMatchInfoToAdminSite_GetMatchSetting] @MatchIds VARCHAR(MAX)
AS
/*
Created: 20241223@Tim
Task: sync match settings to AdminSite
DB: bodb_OWP

Revisions:
	20241223@Tim: initial - [Redmine: #212957]
*/
BEGIN
	SET NOCOUNT ON;

    DECLARE @Bettype_Handicap INT = 1, @Bettype_OU INT = 3
        ,@Bettype_1H_Handicap INT = 7, @Bettype_1H_OU INT = 8
        ,@Bettype_FT_1x2 INT = 5, @Bettype_HT_1x2 INT = 15

    CREATE TABLE #tblMatch (OWPMatchId INT)

    INSERT INTO #tblMatch (OWPMatchId)
    SELECT value
    FROM STRING_SPLIT(@MatchIds, ',') AS m

    SELECT m.OWPMatchId
        ,ms.Bettype AS BettypeId
        ,ms.Maxbet
        ,ms.Spread
    FROM dbo.MatchSetting AS ms WITH (NOLOCK)
        INNER JOIN #tblMatch AS m ON ms.OWPMatchId = m.OWPMatchId
    WHERE ms.Bettype IN (@Bettype_Handicap, @Bettype_OU, @Bettype_1H_Handicap, @Bettype_1H_OU, @Bettype_FT_1x2, @Bettype_HT_1x2)

    DROP TABLE #tblMatch
END