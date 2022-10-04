/*<info serverAlias="DBOWP-bodb_OWP" executers="bodbOWPNet" isFunction="0"></info>*/

ALTER PROCEDURE [dbo].[OWP_TicketEvent_GetAssigneesByOwpMatchId] @OwpMatchId INT
AS

/*  
Created: 20221004@Johnny.Thai  
Task : Get Assignee
DB: bodb_OWP  
  
Revisions:  
20221004@Johnny.Thai   : Get Assignee - [Redmine: #178183]
*/

    BEGIN
        SET NOCOUNT ON;
        SELECT u.UserId AS RecipientId, 
               u.Nickname, 
               u.Username
        FROM Assignment AS a
             INNER JOIN [User] AS u WITH(NOLOCK) ON a.UserId = u.UserId
        WHERE a.OWPMatchId = @OwpMatchId;
    END;