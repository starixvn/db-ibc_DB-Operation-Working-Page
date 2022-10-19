
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
        CREATE TABLE #tblMinorMatchByParentId(OwpMatchId INT);
        INSERT INTO #tblMinorMatchByParentId(OwpMatchId)
               SELECT mm.MinorMatchId
               FROM MinorMatch AS mm
               WHERE mm.ParentMatchId = @OwpMatchId
                     AND mm.MinorBettypeId IN(-1, -2, -88, -89, -5, -6);
		INSERT INTO #tblMinorMatchByParentId(OwpMatchId)
		SELECT @OwpMatchId
        SELECT u.UserId AS RecipientId, 
               u.Nickname, 
               u.Username
        FROM Assignment AS a
             INNER JOIN [User] AS u WITH(NOLOCK) ON a.UserId = u.UserId
             INNER JOIN #tblMinorMatchByParentId AS mm WITH(NOLOCK) ON mm.OwpMatchId = a.OWPMatchId
    END;