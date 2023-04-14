
/*<info serverAlias="DBOWP-bodb_OWP" executers="bodbOWPNet" isFunction="0"></info>*/

ALTER PROCEDURE [dbo].[OWP_AssigneeSuggestionList_GetParentMatchInfo] @OwpMatchId VARCHAR(500)
AS

/*
Created: 202303238@Los
Task: Query parent matchId
DB: bodb_OWP   
 
Revisions:
	202303238@Los: Initial SP - [Redmine: #185365]
	//

*/

    BEGIN
        SET NOCOUNT ON;
        DECLARE @tempMatch TABLE(MatchId INT);
        INSERT INTO @tempMatch
               SELECT DISTINCT 
                      val
               FROM fnc_SplitStrings(@OwpMatchId, ',') u OPTION(MAXRECURSION 0);
        SELECT DISTINCT 
               mi.Remark, 
               owpm.KickOffTime AS 'KOTime', 
               mm.ParentMatchId AS 'OwpMatchId'
        FROM MinorMatch AS mm WITH(NOLOCK)
             INNER JOIN @tempMatch AS t ON mm.MinorMatchId = t.MatchId
             INNER JOIN OWPMatch AS owpm WITH(NOLOCK) ON mm.ParentMatchId = owpm.OWPMatchId
             INNER JOIN MatchInfo AS mi WITH(NOLOCK) ON mi.OWPMatchId = mm.ParentMatchId;
    END;