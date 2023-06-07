
/*<info serverAlias="DBACC-bodb02" executers="bodbAdminNet" isFunction="0"></info>*/

ALTER PROCEDURE [dbo].[OWP_TaskList_GetCompletedMatchFromMainDB] @AdminSiteIds VARCHAR(MAX)
AS

/*
Created: 20230526@Mira
Task : Refactor task list
DB: bodb02

Revisions:
	20230526@Mira: Refactor task list - [Redmine: #188624]
*/

    BEGIN
        SET NOCOUNT ON;
        -- AdminSiteIds
        DECLARE @tblAdminSiteIds TABLE(MatchId INT);
        INSERT INTO @tblAdminSiteIds
               SELECT DISTINCT 
                      value
               FROM STRING_SPLIT(@AdminSiteIds, ',') u OPTION(MAXRECURSION 0);

        -- select completed match
        SELECT DISTINCT 
               m.matchid
        FROM dbo.match m WITH(NOLOCK)
             INNER JOIN @tblAdminSiteIds AS a ON m.matchid = a.MatchId
        WHERE m.eventstatus = 'Completed';
    END;