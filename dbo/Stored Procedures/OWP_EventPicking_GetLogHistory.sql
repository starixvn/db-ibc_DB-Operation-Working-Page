
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
	20250226@Frankie: ignore round Web1-4, Link - [Redmine: #217894]
*/

    BEGIN
        SET NOCOUNT ON;

		DECLARE @IgnoreUpdateTypeIds TABLE (UpdateTypeId INT);

        INSERT INTO @IgnoreUpdateTypeIds (UpdateTypeId)
        SELECT Id
        FROM dbo.[EventPickingUpdateType]
        WHERE RAndDUpdate IN ('Update Round (H-A/T)', 
			'Cancel Round (H-A/T)', 
			'Update Web1', 
			'Cancel Web1', 
			'Update Web2', 
			'Cancel Web2', 
			'Update Web3', 
			'Cancel Web3', 
			'Update Web4', 
			'Cancel Web4', 
			'Update Link', 
			'Cancel Link'
		);

        SELECT el.[Date],
               el.OldValue,
               el.NewValue,
               el.[Action],
               el.ModifiedBy
        FROM dbo.EventPickingLog AS el WITH(NOLOCK)
        WHERE el.InfositeId = @InfoSiteMatchId 
          AND el.UpdateTypeId NOT IN (SELECT UpdateTypeId FROM @IgnoreUpdateTypeIds)
        ORDER BY el.[Date] DESC;
    END;
