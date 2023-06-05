
/*<info serverAlias="DBOWP-bodb_OWP" executers="bodbOWPNet" isFunction="0"></info>*/

CREATE PROCEDURE [dbo].[OWP_TicketIssueLogWork_Create] @TicketId    INT, 
                                                       @AdminSiteId INT            = NULL, 
                                                       @Subject     NVARCHAR(2000) = NULL, 
                                                       @LeagueName  NVARCHAR(500)  = NULL, 
                                                       @HomeName    NVARCHAR(500)  = NULL, 
                                                       @AwayName    NVARCHAR(500)  = NULL
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
         [Subject], 
         LeagueName, 
         HomeName, 
         AwayName
        )
        VALUES
        (@TicketId, 
         @AdminSiteId, 
         @Subject, 
         @LeagueName, 
         @HomeName, 
         @AwayName
        );
    END;