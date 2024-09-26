
/*<info serverAlias="DBOWP-bodb_OWP" executers="wsv_owp" isFunction="0"></info>*/

CREATE PROCEDURE [dbo].[OWP_DeleteOldData_NoOfferMatch] @Date DATETIME
AS

/*    
 Created: 20221206Carlos.nguyen
 Task : Delete old data
 DB: bodb_OWP    
    
 Revisions:
	20220309@Johnny.Thai: Init sp - [Redmine: #179302]	
*/

    BEGIN
        SET NOCOUNT ON;
        
        DELETE tm
        FROM dbo.EventPickingNoOfferMatch tm
        WHERE DATEDIFF(DAY, tm.CreatedDate, @Date) > 30
    END;