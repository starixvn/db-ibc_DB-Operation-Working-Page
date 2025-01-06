
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
        ,@Bettype_NoOfCorners INT= -3, @Bettype_TotalBooking INT= -6

    CREATE TABLE #tblMatch (OWPMatchId INT, ParentMatchId INT, MinorBettypeId INT)

    INSERT INTO #tblMatch (OWPMatchId, ParentMatchId, MinorBettypeId)
    SELECT m.value, minor.ParentMatchId, minor.MinorBettypeId
    FROM STRING_SPLIT(@MatchIds, ',') AS m
        LEFT JOIN dbo.MinorMatch AS minor WITH (NOLOCK) ON m.value = minor.MinorMatchId
    
    SELECT a.OWPMatchId
        ,a.Bettype AS BettypeId
        ,a.UserId
        ,u.Username
    FROM dbo.Assignment AS a WITH(NOLOCK)
        INNER JOIN #tblMatch AS tm WITH(NOLOCK) ON a.OWPMatchId = tm.OWPMatchId
        INNER JOIN dbo.[User] AS u WITH(NOLOCK) ON a.UserId = u.UserId
    WHERE a.Bettype IN (@Bettype_Handicap, @Bettype_OU, @Bettype_1H_Handicap, @Bettype_1H_OU, @Bettype_FT_1x2, @Bettype_HT_1x2, @Bettype_LA)
        AND a.AssignmentType = 1

    UNION
    -- get AIO trader of main match
    SELECT DISTINCT m.OWPMatchId
            ,-1004 AS 'BettypeId'
            ,a.UserId
            ,u.Username
    FROM #tblMatch AS m
        INNER JOIN dbo.MinorMatch AS minor WITH(NOLOCK) ON minor.ParentMatchId = m.OWPMatchId
        AND m.ParentMatchId IS NULL
        INNER JOIN dbo.Assignment AS a WITH(NOLOCK) ON a.OWPMatchId = minor.MinorMatchId
        INNER JOIN dbo.[User] AS u WITH(NOLOCK) ON a.UserId = u.UserId
    WHERE minor.MinorBettypeId = @Bettype_AllInOne

    UNION
    -- get AIO trader of minor match (no. of corner and total booking)
    SELECT DISTINCT m.OWPMatchId
            ,-1004 AS 'BettypeId'
            ,a.UserId
            ,u.Username
    FROM #tblMatch AS m
        INNER JOIN dbo.MinorMatch AS minor WITH(NOLOCK) ON minor.ParentMatchId = m.OWPMatchId
        INNER JOIN dbo.Assignment AS a WITH(NOLOCK) ON a.OWPMatchId = minor.MinorMatchId
        INNER JOIN dbo.[User] AS u WITH(NOLOCK) ON a.UserId = u.UserId
    WHERE (
            m.MinorBettypeId = @Bettype_NoOfCorners
            AND minor.MinorBettypeId = @Bettype_AllInOneCorners
        )
        OR (
            m.MinorBettypeId = @Bettype_TotalBooking
            AND minor.MinorBettypeId = @Bettype_AllInOneTotalBookings
        )

    DROP TABLE #tblMatch
END