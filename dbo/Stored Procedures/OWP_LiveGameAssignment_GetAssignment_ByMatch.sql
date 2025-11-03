
/*<info serverAlias="DBOWP-bodb_OWP" executers="wsv_owp" isFunction="0"></info>*/

CREATE PROCEDURE [dbo].[OWP_LiveGameAssignment_GetAssignment_ByMatch] @OwpMatchId INT      DATE, 
                                                     @MatchStatusIds NVARCHAR(100) = NULL
AS

/*
 Created: 20251103@Hank
 Task : get assignment by match id
 DB: bodb_OWP

 Revisions:
	20251103@Hank: Initial SP - [Feature: #241087]
*/

     SET NOCOUNT ON;
     SELECT a.AssignmentId, 
            a.OWPMatchId, 
            a.Bettype,
            a.UserId,
            u.Username, 
            u.Nickname, 
            a.AssignmentNote
     FROM dbo.Assignment AS a
     INNER JOIN dbp.[User] u ON a.UserId = u.UserId
     WHERE a.OWPMatchId = @OwpMatchId