
/*<info serverAlias="DBOWP-bodb_OWP" executers="bodbOWPNet" isFunction="0"></info>*/

ALTER PROCEDURE [dbo].[OWP_DeleteOldMessage] @Date DATETIME
AS

/*    
 Created: 20220309@Johnny.Thai
 Task : Delete old data
 DB: bodb_OWP    
    
 Revisions:
	20220309@Johnny.Thai: Init sp - [Redmine: #137757]
	20240822@Los: Archive ticket   - [Redmine: #207945]
*/

    BEGIN
        SET NOCOUNT ON;
        CREATE TABLE #tblVipSupportTicketId(TicketId INT);
        INSERT INTO #tblVipSupportTicketId(TicketId)
               SELECT TicketId
               FROM TicketIssue
               WHERE SubtypeId = 23;
        CREATE TABLE #tblFiledId(Id INT);

        -- MOVE FileUpload
        INSERT INTO FileUpload_Old
        ([FileId], 
         [Title], 
         [CreatedDate], 
         [SavedFileName]
        )
               SELECT [FileId], 
                      [Title], 
                      [CreatedDate], 
                      [SavedFileName]
               FROM dbo.FileUpload AS fu WITH(NOLOCK)
               WHERE DATEDIFF(DAY, fu.CreatedDate, @Date) > 30;

        -- DELETE FileUpLoad
        DELETE FROM dbo.FileUpload
        WHERE DATEDIFF(DAY, CreatedDate, @Date) > 30;

        -- MOVE TicketMessage
        INSERT INTO [dbo].[TicketMessage_Old]
        ([TicketId], 
         [CreatedDate], 
         [Message], 
         [UserId], 
         [IsSaved], 
         [FileId], 
         [QuoteMessageId]
        )
               SELECT [TicketId], 
                      [CreatedDate], 
                      [Message], 
                      [UserId], 
                      [IsSaved], 
                      [FileId], 
                      [QuoteMessageId]
               FROM dbo.TicketMessage tm WITH(NOLOCK)
               WHERE DATEDIFF(DAY, tm.CreatedDate, @Date) > 30;
        -- DELETE TicketMessage
        DELETE tm
        FROM dbo.TicketMessage tm
        WHERE DATEDIFF(DAY, tm.CreatedDate, @Date) > 30;
        DROP TABLE #tblFiledId;
        DROP TABLE #tblVipSupportTicketId;
    END;