
/*<info serverAlias="DBOWP-bodb_OWP" executers="bodbOWPNet" isFunction="0"></info>*/

ALTER PROCEDURE [dbo].[OWP_TicketTypeRecipient_SaveTicketTypeRecipient] @TicketTypeId INT, 
                                                                        @Recipients   NVARCHAR(MAX)
AS

/*    
Created: 20210914@Tyler  
Task : Ticket Type Recipient page  
DB: bodb_OWP  
    
Revisions:    
  20210914@Tyler: Initial SP - [Redmine: #160545]  
*/

    BEGIN
        SET NOCOUNT ON;
        DECLARE @tmpRecipient TABLE
        (TicketTypeRecipientId INT NULL, 
         RecipientId           INT NOT NULL, 
         RecipientType         TINYINT NOT NULL
        );
        DECLARE @idoc INT;
        EXEC sp_xml_preparedocument 
             @idoc OUTPUT, 
             @Recipients;
        INSERT INTO @tmpRecipient
               SELECT DISTINCT 
                      TicketTypeRecipientId, 
                      RecipientId, 
                      RecipientType
               FROM OPENXML(@idoc, '/Root/Recipient', 1) WITH(TicketTypeRecipientId INT, RecipientId INT, RecipientType TINYINT);
        EXEC sp_xml_removedocument 
             @idoc;

        -- Delete
        DELETE r
        FROM dbo.TicketTypeRecipient r
             LEFT JOIN @tmpRecipient t ON r.TicketTypeRecipientId = t.TicketTypeRecipientId
        WHERE t.RecipientId IS NULL
              AND r.TypeId = @TicketTypeId;

        -- Insert
        INSERT INTO dbo.TicketTypeRecipient
        (TypeId, 
         RecipientType, 
         RecipientId
        )
               SELECT @TicketTypeId, 
                      r.RecipientType, 
                      r.RecipientId
               FROM @tmpRecipient r
               WHERE r.TicketTypeRecipientId = 0;
    END;