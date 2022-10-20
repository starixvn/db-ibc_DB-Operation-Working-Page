
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
        CREATE TABLE #tblParentId
        (OwpMatchId     INT, 
         ParentMatchId  INT, 
         MinorBettypeId INT
        );
		--handle for 15 mins of total booking, no.of corners
        INSERT INTO #tblParentId
        (OwpMatchId, 
         ParentMatchId, 
         MinorBettypeId
        )
               SELECT mm.MinorMatchId, 
                      mm.ParentMatchId,
                      CASE
                          WHEN mm.MinorBettypeId = -3
                          THEN -5
                          WHEN mm.MinorBettypeId = -6
                          THEN -8
                          ELSE null
                      END
               FROM MinorMatch AS mm
               WHERE mm.MinorMatchId = @OwpMatchId;
        IF NOT EXISTS
        (
            SELECT *
            FROM #tblParentId
        )
			--handle for parent match
            BEGIN
                INSERT INTO #tblParentId
                (OwpMatchId, 
                 ParentMatchId, 
                 MinorBettypeId
                )
                       SELECT mm.MinorMatchId, 
                              @OwpMatchId, 
                              NULL
                       FROM MinorMatch AS mm
                       WHERE mm.ParentMatchId = @OwpMatchId
                             AND mm.MinorBettypeId IN(-1, -2, -88, -89);
                INSERT INTO #tblParentId
                (OwpMatchId, 
                 ParentMatchId, 
                 MinorBettypeId
                )
                       SELECT @OwpMatchId, 
                              NULL, 
                              NULL;
        END;
		--handle others special match
        INSERT INTO #tblParentId
        (OwpMatchId, 
         ParentMatchId, 
         MinorBettypeId
        )
               SELECT mm.MinorMatchId, 
                      mm.ParentMatchId, 
                      mm.MinorBettypeId
               FROM MinorMatch AS mm
                    INNER JOIN #tblParentId AS p ON mm.ParentMatchId = p.ParentMatchId
                                                    AND mm.MinorBettypeId = p.MinorBettypeId;
		--select recipient
        SELECT u.UserId AS RecipientId, 
               u.Nickname, 
               u.Username
        FROM Assignment AS a
             INNER JOIN [User] AS u WITH(NOLOCK) ON a.UserId = u.UserId
             INNER JOIN #tblParentId AS p WITH(NOLOCK) ON p.OwpMatchId = a.OWPMatchId;
    END;