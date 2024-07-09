
/*<info serverAlias="DBACC-bodb02" executers="wsv_nap" isFunction="0"></info>*/

CREATE PROCEDURE [dbo].[OWP_TaskList_GetMinorMatchByMatchId] @MatchId INT, 
                                                             @SubType INT
AS

/*    
 Created: 20220120@Tyler
 Task : get AdminSiteMatchId for OWP task list
 DB: bodb_OWP    
    
 Revisions:
	20220120@Tyler: Initial SP - [Redmine: #167774]
	20240708@Mira: Only get valid child match id - [Redmine: #207671]
*/

    BEGIN
        SET NOCOUNT ON;
        SELECT m.matchid
        FROM dbo.[match] m
             INNER JOIN dbo.match_remark mr WITH(NOLOCK) ON m.MatchId = mr.matchid
        WHERE m.ParentID = @MatchId
              AND mr.SubType = @SubType
              AND m.IsDeleted = 0;
    END;