/*<info serverAlias="DBOWP-bodb_OWP" executers="bodbOWPNet" isFunction="0"></info>*/
ALTER PROCEDURE dbo.[OWP_GetAllAssignmentsByXMins]
	
AS
/*
Created: 20200723@Esther.Nguyen
Task : Ready to Trade Status  
DB: bodb_OWP

Revisions:
	20200723@Esther.Nguyen: Staff's readiness notification - [Redmine: #137751]
*/
BEGIN	
	SET NOCOUNT ON;
    DECLARE @XMins INT = 15;
	DECLARE @OWPNow DATETIME = DATEADD(hh , 12,  GETDATE());

   -- Result
     SELECT [AssignmentId], 
            a.[OWPMatchId] MatchId, 
            [Bettype], 
            [AssignmentType], 
            a.[UserId], 
            u.Username, 
            [AssignmentNote]
     FROM [dbo].[Assignment] a WITH(NOLOCK)
          INNER JOIN dbo.OWPMatch m WITH(NOLOCK) ON m.OWPMatchId = a.OWPMatchId
		  LEFT JOIN dbo.[User] u ON u.UserId = a.UserId
		  LEFT JOIN dbo.MatchInfo i WITH(NOLOCK) ON m.OWPMatchId = i.OWPMatchId
		  LEFT JOIN dbo.ReadyTradeStatus r WITH(NOLOCK) ON m.OWPMatchId = r.MatchId AND r.UserId = a.UserId
	   WHERE i.IsSelected = 1
           AND m.EventDateTime BETWEEN @OWPNow AND DATEADD(mi , @XMins,  @OWPNow)
		   AND r.ReadyDateTime IS NULL
		   AND i.MatchStatus like 'Live'
END

