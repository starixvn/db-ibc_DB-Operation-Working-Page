
/*<info serverAlias="DBACC-bodb02" executers="wsv_nap" isFunction="0"></info>*/

CREATE PROCEDURE [dbo].[OWP_PreMatchAssignment_GetEarlyOfferedLeagues] @EventDate DATE
AS

/*
Created: 20231122@Johnny
Task: Get early offered leagues
DB: bodb_OWP

Revisions:
	20231122@Johnny: Init sp - [Redmine: #194878]
*/

    BEGIN
        SET NOCOUNT ON;
        SELECT DISTINCT 
               l.leaguename
        FROM odds o WITH(NOLOCK)
             INNER JOIN match m WITH(NOLOCK) ON m.matchid = o.matchid
             INNER JOIN league l WITH(NOLOCK) ON l.leagueid = m.leagueid
        WHERE m.eventdate = @EventDate
              AND m.sporttype = 1
              AND o.oddsstatus <> 'closed'
              AND m.Isdeleted = 0
              AND m.isTestMatch = 0
        ORDER BY l.leaguename;
    END;