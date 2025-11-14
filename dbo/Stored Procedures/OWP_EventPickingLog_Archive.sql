
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

    DECLARE @BatchSize INT = 20000;
    DECLARE @CutoffDate DATETIME = DATEADD(DAY, -40, @Date);
    DECLARE @RowCount INT;

    WHILE 1 = 1
    BEGIN
        -- Delete and archive in one operation using OUTPUT clause
        DELETE TOP (@BatchSize) FROM dbo.EventPickingLog WITH (READPAST)
        OUTPUT DELETED.Id, 
               DELETED.[Date], 
               DELETED.InfositeId, 
               DELETED.UpdateTypeId, 
               DELETED.ModifiedBy, 
               DELETED.[Action], 
               DELETED.OldValue, 
               DELETED.NewValue, 
               DELETED.HomeUpdated, 
               DELETED.AwayUpdated, 
               DELETED.FromService
        INTO dbo.EventPickingLog_Old
        WHERE [Date] < @CutoffDate;

        SET @RowCount = @@ROWCOUNT;

        IF @RowCount < @BatchSize BREAK;

        WAITFOR DELAY '00:00:02';
    END

END;