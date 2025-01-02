
/*<info serverAlias="DBOWP-bodb_OWP" executers="wsv_owp" isFunction="0"></info>*/

CREATE PROCEDURE [dbo].[OWP_SyncMatchInfoToAdminSite_GetAssignment] @MatchIds VARCHAR(MAX)
AS
/*
Created: 20241223@Tim
Task: sync match assignment to AdminSite
DB: bodb_OWP

Revisions:
	20241223@Tim: initial - [Redmine: #212957]
*/
BEGIN
	SET NOCOUNT ON;

    DECLARE @Bettype_Handicap INT = 1, @Bettype_OU INT = 3
        ,@Bettype_1H_Handicap INT = 7, @Bettype_1H_OU INT = 8
        ,@Bettype_FT_1x2 INT = 5, @Bettype_HT_1x2 INT = 15
        ,@Bettype_LA INT= -1002, @Bettype_AllInOne INT= -89
        ,@Bettype_AllInOneCorners INT= -289, @Bettype_AllInOneTotalBookings INT= -189

    CREATE TABLE #tblMatch (OWPMatchId INT)

    INSERT INTO #tblMatch (OWPMatchId)
    SELECT value
    FROM STRING_SPLIT(@MatchIds, ',') AS m    
    
    SELECT a.OWPMatchId
        ,CASE WHEN a.Bettype = @Bettype_AllInOne THEN -1004 ELSE a.Bettype END AS BettypeId
        ,a.UserId
        ,u.Username
    FROM dbo.Assignment AS a WITH(NOLOCK)
        INNER JOIN #tblMatch AS tm WITH(NOLOCK) ON a.OWPMatchId = tm.OWPMatchId
        LEFT JOIN dbo.[User] AS u WITH(NOLOCK) ON a.UserId = u.UserId
    WHERE a.Bettype IN (@Bettype_Handicap, @Bettype_OU, @Bettype_1H_Handicap, @Bettype_1H_OU, @Bettype_FT_1x2, @Bettype_HT_1x2, @Bettype_LA, @Bettype_AllInOne)
        AND a.AssignmentType = 1

    DROP TABLE #tblMatch
END