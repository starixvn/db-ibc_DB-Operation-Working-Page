
/*<info serverAlias="DBOWP-bodb_OWP" executers="wsv_owp" isFunction="0"></info>*/

CREATE PROCEDURE [dbo].[OWP_EventPickingLog_Archive] @Date DATETIME
AS

/*    
 Created: 20251111@Hank
 Task : Archive event picking log
 DB: bodb_OWP
    
 Revisions:
	20251111@Hank: Archive event picking log - [Redmine: #242991]
*/

    BEGIN
        SET NOCOUNT ON;
       

        -- MOVE FileUpload
        INSERT INTO EventPickingLog_Old
        ([Id], 
         [Date], 
         [InfositeId], 
         [UpdateTypeId], 
         [ModifiedBy], 
         [Action], 
         [OldValue], 
         [NewValue], 
         [HomeUpdated], 
         [AwayUpdated], 
         [FromService]
        )
        SELECT [Id], 
               [Date], 
               [InfositeId], 
               [UpdateTypeId], 
               [ModifiedBy], 
               [Action], 
               [OldValue], 
               [NewValue], 
               [HomeUpdated], 
               [AwayUpdated], 
               [FromService]
        FROM dbo.EventPickingLog AS el WITH(NOLOCK)
        WHERE DATEDIFF(DAY, el.Date, @Date) > 40;

        -- DELETE EventPickingLog
        DELETE FROM dbo.EventPickingLog
        WHERE DATEDIFF(DAY, Date, @Date) > 40;
 
    END;