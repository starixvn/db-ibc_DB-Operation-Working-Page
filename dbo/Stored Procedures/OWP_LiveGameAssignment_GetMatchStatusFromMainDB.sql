
/*<info serverAlias="DBACC-bodb02" executers="wsv_nap" isFunction="0"></info>*/

ALTER PROCEDURE [dbo].[OWP_LiveGameAssignment_GetMatchStatusFromMainDB] @AdminSiteIds VARCHAR(MAX)
AS

/*
Created: 20210810@Mira
Task : Sync Special Product Match
DB: bodb02

Revisions:
	20210810@Mira: Initial - [Redmine: #153498]
*/

    BEGIN
        SET NOCOUNT ON;
        --main AdminSiteIds
        DECLARE @tblAdminSiteIds TABLE(MatchId INT);
        INSERT INTO @tblAdminSiteIds
               SELECT DISTINCT 
                      value
               FROM STRING_SPLIT(@AdminSiteIds, ',');

        -- minor AdminSiteIds
        DECLARE @tblChildAdminSiteIds TABLE
        (MatchId  INT, 
         ParentId INT
        );
        INSERT INTO @tblChildAdminSiteIds
               SELECT DISTINCT 
                      m.matchid, 
                      m.ParentID
               FROM bodb02.dbo.match m WITH(NOLOCK)
                    INNER JOIN @tblAdminSiteIds a ON a.MatchId = m.ParentID;

        -- get matchStatus of main match
        SELECT DISTINCT 
               mr.matchid 'MatchId', 
               mr.SubType, 
               mr.OfferLive, 
               NULL 'ParentId'
        FROM bodb02.dbo.match_remark mr WITH(NOLOCK)
             INNER JOIN @tblAdminSiteIds a ON a.MatchId = mr.matchid
        UNION
        -- get matchStatus of minor match
        SELECT DISTINCT 
               mr.matchid 'MatchId', 
               mr.SubType, 
               mr.OfferLive, 
               a.ParentId
        FROM bodb02.dbo.match_remark mr WITH(NOLOCK)
             INNER JOIN @tblChildAdminSiteIds a ON a.MatchId = mr.matchid;
    END;