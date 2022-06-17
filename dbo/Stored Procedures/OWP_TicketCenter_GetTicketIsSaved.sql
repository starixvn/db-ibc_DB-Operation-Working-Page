
/*<info serverAlias="DBOWP-bodb_OWP" executers="bodbOWPNet" isFunction="0"></info>*/

ALTER PROCEDURE [dbo].[OWP_TicketCenter_GetTicketIsSaved]
AS

/*      
 Created: 20220616@Johnny.Thai
 Task : Get TicketId Have Saved Message
 DB: bodb_OWP      
      
 Revisions:          
	20220616@Johnny.Thai: Init  - [Redmine: #173994]
*/

    BEGIN
        SET NOCOUNT ON;
        SELECT DISTINCT 
               TicketId
        FROM TicketMessage
        WHERE IsSaved = 1;
    END;