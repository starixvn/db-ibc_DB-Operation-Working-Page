
/*<info serverAlias="DBACC-bodb02" executers="bodbAdminNet" isFunction="0"></info>*/

CREATE PROC OWP_TaskList_GetSubTypeSpecialProduct @MatchId INT
AS

/*    
 Created: 20220309@Luca
 Task : get SubType for OWP task list
 DB: bodb_OWP    
    
 Revisions:
	20220309@Luca: Initial SP - [Redmine: #169335]
	
*/
	-- GET get SubType for OWP task list
    BEGIN
        SET NOCOUNT ON;
        SELECT mr.SubType
        FROM match m WITH(NOLOCK)
             INNER JOIN match_remark mr WITH(NOLOCK) ON m.matchid = mr.matchid
             INNER JOIN Team t WITH(NOLOCK) ON m.homeid = t.teamid
                                               OR m.awayid = t.teamid
        WHERE t.teamname LIKE '% 1st %'
              AND m.ParentID = @MatchId;
    END;