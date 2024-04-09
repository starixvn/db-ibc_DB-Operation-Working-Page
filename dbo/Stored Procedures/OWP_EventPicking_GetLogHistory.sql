
/*<info serverAlias="DBOWP-bodb_OWP" executers="wsv_owp" isFunction="0"></info>*/

ALTER PROCEDURE [dbo].[OWP_EventPicking_GetLogHistory] @InfoSiteMatchId INT
AS

/*      
 Created: 20230908@Los
 Task : Get log
 DB: bodb_OWP      
 
 Revisions:
    20230908@Los: Get event picking log history - [Redmine: #190039]
	20240404@Liam: ignore round H-A/T - [Redmine: #202638]
*/

    BEGIN
        SET NOCOUNT ON;
     
        SELECT el.[Date], 
               el.OldValue, 
               el.NewValue,
			   el.[Action],
			   el.ModifiedBy
        FROM dbo.EventPickingLog AS el WITH(NOLOCK)
        WHERE el.InfositeId = @InfoSiteMatchId  and el.UpdateTypeId NOT IN(14, 15)
		ORDER BY el.[Date] DESC
    END;
