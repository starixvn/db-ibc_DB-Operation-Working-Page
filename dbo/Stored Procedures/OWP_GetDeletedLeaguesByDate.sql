
/*<info serverAlias="DBOWP-bodb_OWP" executers="bodbOWPNet" isFunction="0"></info>*/

ALTER PROCEDURE dbo.OWP_GetDeletedLeaguesByDate @EventDate DATE
AS

/*  
Created: 20200811@Esther.Nguyen  
Task : Get list deleted leagues 
DB: bodb_OWP  
  
Revisions:  
 20200811@Esther.Nguyen: Get list deleted leagues - [Redmine: #138643]  
*/

    BEGIN
        SET NOCOUNT ON;
        SELECT p.LeagueName, 
               pl.DeletedTime, 
               pl.DeltedBy
        FROM PreMatchAssignment AS p WITH(NOLOCK)
             INNER JOIN PreMatchAssignmentDeleteLog AS pl WITH(NOLOCK) ON pl.PreMatchAssignmentId = p.PreMatchAssignmentId
        WHERE DeletedTime = @EventDate
              AND isDeleted = 1;
    END;