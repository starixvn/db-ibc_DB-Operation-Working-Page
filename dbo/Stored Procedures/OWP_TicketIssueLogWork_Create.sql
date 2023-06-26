
/*<info serverAlias="DBOWP-bodb_OWP" executers="bodbOWPNet" isFunction="0"></info>*/

ALTER PROCEDURE [dbo].[OWP_TicketIssueLogWork_Create] @TicketId     INT, 
                                                      @AdminSiteId  INT            = NULL, 
                                                      @Subject      NVARCHAR(2000) = NULL, 
                                                      @Status VARCHAR(10)
AS

/*      
 Created: 20220605@Johnny
 Task : New ticket issue log work
 DB: bodb_OWP      
      
 Revisions:          
	20220605@Johnny: Init sp - [Redmine: #185890]
*/

    BEGIN
        SET NOCOUNT ON;
        INSERT INTO TicketIssueLogWork
        (TicketId, 
         AdminsiteId, 
         [Subject]
        )
        VALUES
        (@TicketId, 
         @AdminSiteId, 
         @Subject
        );
        UPDATE TicketIssue
          SET 
              TicketStatus = @Status
        WHERE TicketId = @TicketId;
    END;