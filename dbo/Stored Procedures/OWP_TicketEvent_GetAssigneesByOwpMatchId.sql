
/*<info serverAlias="DBOWP-bodb_OWP" executers="bodbOWPNet" isFunction="0"></info>*/

ALTER PROCEDURE [dbo].[OWP_TicketEvent_GetAssigneesByOwpMatchId] @OwpMatchId INT
AS

/*  
Created: 20221004@Johnny.Thai  
Task : Get Assignee
DB: bodb_OWP  
  
Revisions:  
20221004@Johnny.Thai   : Get Assignee - [Redmine: #178183]
20240222@Los : Get Assignee relative - [Redmine: #200265]
*/

    BEGIN
        SET NOCOUNT ON;
        CREATE TABLE #tblOwpMatch(Id INT);
        INSERT INTO #tblOwpMatch(Id)
        VALUES(@OwpMatchId);
        INSERT INTO #tblOwpMatch(Id)
               SELECT mm.ParentMatchId
               FROM MinorMatch AS mm
               WHERE mm.MinorMatchId = @OwpMatchId;
        INSERT INTO #tblOwpMatch(Id)
               SELECT mm.MinorMatchId
               FROM MinorMatch AS mm
                    INNER JOIN #tblOwpMatch AS r ON mm.ParentMatchId = r.Id;

        --select recipient
        SELECT DISTINCT 
               u.UserId AS RecipientId, 
               u.Nickname, 
               u.Username
        FROM Assignment AS a
             INNER JOIN [User] AS u WITH(NOLOCK) ON a.UserId = u.UserId
             INNER JOIN #tblOwpMatch AS p WITH(NOLOCK) ON p.Id = a.OWPMatchId;
        DROP TABLE #tblOwpMatch;
    END;