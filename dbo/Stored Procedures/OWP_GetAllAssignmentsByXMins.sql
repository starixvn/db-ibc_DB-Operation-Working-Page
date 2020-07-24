/*<info serverAlias="DBOWP-bodb_OWP" executers="bodbOWPNet" isFunction="0"></info>*/
ALTER PROCEDURE OWP_GetAllAssignmentsByXMins @LastTimeNotification DateTime 
	
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
    DECLARE @XMins  DATETIME = DATEADD(MINUTE, 15,  GETDATE());

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
	   WHERE i.IsSelected = 1
           AND m.KickOffTime BETWEEN CONVERT(char(5), @LastTimeNotification, 108) AND CONVERT(char(5), @XMins, 108)
           AND m.EventDate = CONVERT(VARCHAR(10), GETDATE(), 111)
END

