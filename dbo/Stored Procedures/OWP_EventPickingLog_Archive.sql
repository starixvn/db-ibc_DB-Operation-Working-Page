
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

    WHILE 1 = 1
    BEGIN
        WITH ToMove AS (
            SELECT TOP (@BatchSize) *
            FROM dbo.EventPickingLog WITH (ROWLOCK, READPAST)
            WHERE [Date] < @CutoffDate
            ORDER BY [Date]
        )
        INSERT INTO dbo.EventPickingLog_Old
        SELECT * FROM ToMove;

        -- Delete those rows
        DELETE FROM ToMove;

        IF @@ROWCOUNT < @BatchSize BREAK;

        WAITFOR DELAY '00:00:02';
    END

END;