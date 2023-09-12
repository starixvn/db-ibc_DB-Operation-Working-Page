
/*<info serverAlias="DBOWP-bodb_OWP" executers="bodbOWPNet" isFunction="0"></info>*/

ALTER PROCEDURE [dbo].[OWP_EventPicking_GetLogHistory] @InfoSiteMatchId INT
AS

/*      
 Created: 20230908@Los
 Task : Get log
 DB: bodb_OWP      
 
 Revisions:
    20230908@Los: Get event picking log history - [Redmine: #190039]
*/

    BEGIN
        SET NOCOUNT ON;
     
        SELECT el.[Date], 
               el.OldValue, 
               el.NewValue,
			   el.[Action],
			   el.ModifiedBy
        FROM dbo.EventPickingLog AS el WITH(NOLOCK)
        WHERE el.InfositeId = @InfoSiteMatchId
    END;