
/*<info serverAlias="DBOWP-bodb_OWP" executers="bodbOWPNet" isFunction="0"></info>*/

ALTER PROCEDURE [dbo].[OWP_DeleteOldMessage] @Date DATETIME
AS

/*    
 Created: 20220309@Johnny.Thai
 Task : Delete old data
 DB: bodb_OWP    
    
 Revisions:
	20220309@Johnny.Thai: Init sp - [Redmine: #137757]
	20230630@Johnny.Thai: Exlude VIP Support - [Redmine: #190284]
*/

    BEGIN
        SET NOCOUNT ON;
        CREATE TABLE #tblVipSupportTicketId(TicketId INT);
        INSERT INTO #tblVipSupportTicketId(TicketId)
               SELECT TicketId
               FROM TicketIssue
               WHERE SubtypeId = 23;
        CREATE TABLE #tblFiledId(Id INT);
        INSERT INTO #tblFiledId(Id)
               SELECT FileId
               FROM dbo.TicketMessage AS tm
               WHERE DATEDIFF(DAY, tm.CreatedDate, @Date) > 30
                     AND tm.IsSaved = 0
                     AND tm.FileId IS NOT NULL
                     AND tm.TicketId NOT IN
               (
                   SELECT TicketId
                   FROM #tblVipSupportTicketId
               );

        -- DELETE FileUpLoad
        DELETE FROM dbo.FileUpload
        WHERE FileId IN
        (
            SELECT Id
            FROM #tblFiledId
        );
        -- DELETE TicketMessage
        DELETE tm
        FROM dbo.TicketMessage tm
        WHERE DATEDIFF(DAY, tm.CreatedDate, @Date) > 30
              AND tm.IsSaved = 0
              AND tm.TicketId NOT IN
        (
            SELECT TicketId
            FROM #tblVipSupportTicketId
        );
        DROP TABLE #tblFiledId;
        DROP TABLE #tblVipSupportTicketId;
    END;