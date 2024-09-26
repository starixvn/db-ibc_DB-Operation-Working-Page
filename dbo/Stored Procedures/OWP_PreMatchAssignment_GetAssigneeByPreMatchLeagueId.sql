/*<info serverAlias="DBOWP-bodb_OWP" executers="wsv_owp" isFunction="0"></info>*/

ALTER PROCEDURE [dbo].[OWP_PreMatchAssignment_GetAssigneeByPreMatchLeagueId] @Id INT
AS

/*  
Created: 20211213@Johnny.Thai  
Task : Get Assignee
DB: bodb_OWP  
  
Revisions:  
 20211213@Johnny.Thai : Get Assignee - [Redmine: #166513]
*/

    BEGIN
        SET NOCOUNT ON;
        SELECT u.UserId AS RecipientId, 
               u.Nickname, 
               u.Username
        FROM PreMatchAssignment AS p
             INNER JOIN [User] AS u WITH(NOLOCK) ON p.UserId = u.UserId
        WHERE p.PreMatchLeagueId = @Id;
    END;