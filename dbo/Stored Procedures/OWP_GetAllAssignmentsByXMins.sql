
/*<info serverAlias="DBOWP-bodb_OWP" executers="bodbOWPNet" isFunction="0"></info>*/

ALTER PROCEDURE dbo.[OWP_GetAllAssignmentsByXMins] @LastTimeInCache VARCHAR(MAX)
AS

/*
Created: 20200723@Esther.Nguyen
Task : Ready to Trade Status  
DB: bodb_OWP

Revisions:
	20200723@Esther.Nguyen: Staff's readiness notification - [Redmine: #137751]
	20200810@Mira.Nguyen: edit xMins - [Redmine: #137751]
	20200928@Mira.Nguyen: fix bug get special minor bettype - [Redmine: #137751]
*/

    BEGIN
        SET NOCOUNT ON;
        DECLARE @XMins INT= 15;
        DECLARE @OWPNow DATETIME= DATEADD(hh, 12, GETDATE());
        DECLARE @LastTimeNotification DATETIME= DATEADD(mi, @XMins, @OWPNow);
        DECLARE @FromTime DATETIME;

        -- Get From Time
        IF(@LastTimeInCache = '')
            BEGIN
                SELECT @FromTime = @OWPNow;
        END;
            ELSE
            SELECT @FromTime = @LastTimeInCache;

        -- Result
        SELECT @LastTimeNotification;
        SELECT CASE
                   WHEN mm.MinorBettypeId IN(-1, -2, -88, -89)
                   THEN mp.OWPMatchId
                   ELSE a.[OWPMatchId]
               END AS MatchId, 
               a.[UserId], 
               u.Username
        FROM [dbo].[Assignment] a WITH(NOLOCK)
             INNER JOIN dbo.OWPMatch m WITH(NOLOCK) ON m.OWPMatchId = a.OWPMatchId
             LEFT JOIN dbo.[User] u ON u.UserId = a.UserId
             LEFT JOIN dbo.MatchInfo i WITH(NOLOCK) ON m.OWPMatchId = i.OWPMatchId
             LEFT JOIN dbo.MinorMatch mm WITH(NOLOCK) ON m.OWPMatchId = mm.MinorMatchId
             LEFT JOIN dbo.OWPMatch AS mp WITH(NOLOCK) ON mp.OWPMatchId = mm.ParentMatchId
             LEFT JOIN dbo.ReadyTradeStatus r WITH(NOLOCK) ON((mm.MinorBettypeId IN(-1, -2, -88, -89)
                                                               AND mp.OWPMatchId = r.MatchId)
                                                              OR a.[OWPMatchId] = r.MatchId)
                                                             AND r.UserId = a.UserId
        WHERE i.IsSelected = 1
              AND m.EventDateTime BETWEEN @FromTime AND @LastTimeNotification
              AND r.ReadyDateTime IS NULL
              AND i.MatchStatus LIKE 'Live';
    END;