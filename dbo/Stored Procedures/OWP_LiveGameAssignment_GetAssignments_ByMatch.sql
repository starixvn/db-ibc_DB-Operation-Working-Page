
/*<info serverAlias="DBOWP-bodb_OWP" executers="wsv_owp" isFunction="0"></info>*/

CREATE PROCEDURE [dbo].[OWP_LiveGameAssignment_GetAssignments_ByMatch] @InfoSiteMatchId INT
AS

/*
 Created: 20251103@Hank
 Task : get assignment by match id
 DB: bodb_OWP

 Revisions:
	20251103@Hank: Initial SP - [Feature: #241087]
*/

     SET NOCOUNT ON;

     -- Return assignments for main match only (exclude minor matches)
     SELECT a.AssignmentId, 
            a.OWPMatchId, 
            a.Bettype,
            a.UserId,
            u.Username, 
            u.Nickname, 
            a.AssignmentNote
     FROM dbo.Assignment AS a WITH(NOLOCK)
          INNER JOIN dbo.OWPMatch AS om WITH(NOLOCK) ON a.OWPMatchId = om.OWPMatchId
          LEFT JOIN dbo.[User] AS u WITH(NOLOCK) ON a.UserId = u.UserId
     WHERE om.InfoSiteMatchId = @InfoSiteMatchId;