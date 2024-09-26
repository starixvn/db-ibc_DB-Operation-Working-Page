
/*<info serverAlias="DBACC-bodb02" executers="wsv_nap" isFunction="0"></info>*/

ALTER PROCEDURE [dbo].[OWP_PrematchAssignment_GetOddStatusFromMainDB] @AdminSiteMatchIds NVARCHAR(MAX)
AS

/*
Created: 20220321@Mira
Task : Match Offer in Prematch page
DB: bodb02

Revisions:
		20220321@Mira: Get odd status - [Redmine: #170097]
*/

    BEGIN
        SET NOCOUNT ON;
        --main AdminSiteIds
        DECLARE @tblAdminSiteIds TABLE(MatchId INT);
        DECLARE @hdp INT= 1;
        DECLARE @ou INT= 3;
        INSERT INTO @tblAdminSiteIds
               SELECT DISTINCT 
                      val
               FROM f_SplitString(@AdminSiteMatchIds, ',') u OPTION(MAXRECURSION 0);

        -- get OddStatus bettype HDP & OU
        SELECT DISTINCT 
               mr.matchid 'AdminSiteMatchId', 
               mr.bettype, 
               mr.oddsstatus
        FROM bodb02.dbo.odds mr WITH(NOLOCK)
             INNER JOIN @tblAdminSiteIds t ON t.MatchId = mr.matchid
        WHERE mr.bettype IN(1, 3);
    END;