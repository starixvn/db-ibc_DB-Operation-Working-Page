/*<info serverAlias="DBOWP-bodb_OWP" executers="wsv_owp" isFunction="0"></info>*/

ALTER PROCEDURE [dbo].[OWP_OSLiveGameAssignment_GetEventStatusFromMainDB] @AdminsiteMatchIds VARCHAR(MAX)
AS

/*    
 Created: 20220112@Carlos.nguyen
 Task : Get Event Status From MainDB
 DB: bodb_OWP    
    
 Revisions:
	20220112@Carlos.nguyen: Initial SP - [Redmine: #167315]
	
*/

    BEGIN
        SET NOCOUNT ON;
       
       DECLARE @tempMatch TABLE(MatchId INT);
   
     INSERT INTO @tempMatch
            SELECT DISTINCT 
                   val
            FROM fnc_SplitStrings(@AdminsiteMatchIds, ',') u OPTION(MAXRECURSION 0);
            
       SELECT tm.MatchId AS AdminsiteMatchId,
		db2m.eventstatus AS MatchStatus
       FROM bodb02.dbo.match AS db2m WITH (NOLOCK)
		INNER JOIN @tempMatch AS tm ON tm.MatchId=db2m.matchid
    END;