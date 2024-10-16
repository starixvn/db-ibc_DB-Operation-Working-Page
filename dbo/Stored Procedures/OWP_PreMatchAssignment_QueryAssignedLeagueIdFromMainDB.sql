
/*<info serverAlias="DBOWP-bodb02" executers="wsv_nap" isFunction="0"></info>*/

ALTER PROCEDURE [dbo].[OWP_PreMatchAssignment_QueryAssignedLeagueIdFromMainDB] @LeagueNames NVARCHAR(MAX)
AS

/*
Created: 20220331@Mira
Task : Open Prematch Trading page
DB: bodb02

Revisions:
	20220331@Mira: Get league ids - [Redmine: #170721]
	20240925@Los: replace f_SplitString -> STRING_SPLIT [Redmine: #209152]
*/

    BEGIN
        SET NOCOUNT ON;
        --main AdminSiteIds
        DECLARE @tblLeagueNames TABLE(LeagueName NVARCHAR(500));
        INSERT INTO @tblLeagueNames
               SELECT DISTINCT 
                      value
               FROM STRING_SPLIT(@LeagueNames, ',');

        -- get league ids
        SELECT DISTINCT 
               l.leagueid, 
               l.leaguename
        FROM bodb02.dbo.league l WITH(NOLOCK)
             INNER JOIN @tblLeagueNames t ON t.LeagueName = l.leaguename
        WHERE l.leaguenametc = 'Soccer';
    END;