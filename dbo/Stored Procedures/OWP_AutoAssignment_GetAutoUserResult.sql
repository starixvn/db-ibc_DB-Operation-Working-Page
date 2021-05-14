
/*<info serverAlias="DBOWP-bodb_OWP" executers="bodbOWPNet" isFunction="0"></info>*/

ALTER PROCEDURE [dbo].[OWP_AutoAssignment_GetAutoUserResult] @EventDate DATE
AS

/*
Created: @Carlos.Nguyen
Task : Get data LA for report
DB: bodb_OWP

Revisions:
	20191004@Carlos.Nguyen: Initial SP - [Redmine: #121452]
	20200427@Carlos.Nguyen: Update param [Redmine: #133428]
	20210511@Mira: Auto trader assignment - [Redmine: #132710]
*/

    BEGIN
        SET NOCOUNT ON;
        CREATE TABLE #tblRequest
        (RequestId    VARCHAR(500), 
         OWPMatchId   INT, 
         UserId_LA    INT, 
         UserId_FTHDP INT, 
         UserId_1HHDP INT, 
         UserId_FTOU  INT, 
         UserId_1HOU  INT, 
         Bettype      INT
        );
        INSERT INTO #tblRequest
        (RequestId, 
         OWPMatchId, 
         UserId_LA, 
         UserId_FTHDP, 
         UserId_1HHDP, 
         UserId_FTOU, 
         UserId_1HOU, 
         Bettype
        )
               SELECT DISTINCT 
                      aur.RequestId, 
                      au.OWPMatchId, 
                      au.UserId_LA, 
                      au.UserId_FTHDP, 
                      au.UserId_1HHDP, 
                      au.UserId_FTOU, 
                      au.UserId_1HOU, 
                      au.Bettype
               FROM dbo.AutoAssignmentResult AS au WITH(NOLOCK)
                    INNER JOIN dbo.AutoAssignmentRequest AS aur WITH(NOLOCK) ON aur.EventDate = @EventDate
                                                                                AND aur.ResponseDate IS NOT NULL;
        SELECT DISTINCT 
               ISNULL(m.MinorMatchId, au.OWPMatchId) AS OWPMatchId, 
               u1.Username 'Trader_LA', 
               u2.Username 'Trader_FTHDP', 
               u3.Username 'Trader_1HHDP', 
               u4.Username 'Trader_FTOU', 
               u5.Username 'Trader_1HOU'
        FROM #tblRequest AS au WITH(NOLOCK)
             INNER JOIN dbo.[User] AS u1 WITH(NOLOCK) ON au.UserId_LA = u1.UserId
             INNER JOIN dbo.[User] AS u2 WITH(NOLOCK) ON au.UserId_FTHDP = u2.UserId
             INNER JOIN dbo.[User] AS u3 WITH(NOLOCK) ON au.UserId_1HHDP = u3.UserId
             INNER JOIN dbo.[User] AS u4 WITH(NOLOCK) ON au.UserId_FTOU = u4.UserId
             INNER JOIN dbo.[User] AS u5 WITH(NOLOCK) ON au.UserId_1HOU = u5.UserId
             LEFT JOIN dbo.MinorMatch AS m WITH(NOLOCK) ON m.ParentMatchId = au.OWPMatchId
                                                           AND m.MinorBettypeId = au.Bettype;
        SELECT *
        FROM #tblRequest;
        DROP TABLE #tblRequest;
    END;