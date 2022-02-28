
/*<info serverAlias="DBOWP-bodb_OWP" executers="bodbOWPNet" isFunction="0"></info>*/

ALTER PROCEDURE [dbo].[OWP_TicketTypeRecipient_SaveTicketTypeRecipient] @TicketTypeId INT, 
                                                                        @Recipients   NVARCHAR(MAX), 
                                                                        @Subtypes     NVARCHAR(MAX)
AS

/*    
Created: 20210914@Tyler  
Task : Ticket Type Recipient page  
DB: bodb_OWP  
    
Revisions:    
  20210914@Tyler: Initial SP - [Redmine: #160545]  
  20220222@Mira: Save subtypes - [Redmine: #168468]  
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

        -- parse subtypes
        DECLARE @tmpSubtype TABLE
        (SubtypeId   INT NULL, 
         TypeId      INT NOT NULL, 
         SubtypeName VARCHAR(100)
        );
        EXEC sp_xml_preparedocument 
             @idoc OUTPUT, 
             @Subtypes;
        INSERT INTO @tmpSubtype
               SELECT DISTINCT 
                      SubtypeId, 
                      TypeId, 
                      SubtypeName
               FROM OPENXML(@idoc, '/Root/Subtype', 1) WITH(SubtypeId INT, TypeId INT, SubtypeName VARCHAR(100));
        EXEC sp_xml_removedocument 
             @idoc;

        -- Delete recipient
        DELETE r
        FROM dbo.TicketTypeRecipient r
             LEFT JOIN @tmpRecipient t ON r.TicketTypeRecipientId = t.TicketTypeRecipientId
        WHERE t.RecipientId IS NULL
              AND r.TypeId = @TicketTypeId;

        -- Insert recipient
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

        -- Update subtype
        UPDATE s
          SET 
              SubtypeName = t.SubtypeName
        FROM dbo.TicketSubtype s
             INNER JOIN @tmpSubtype t ON s.SubtypeId = t.SubtypeId
        WHERE t.SubtypeName <> s.SubtypeName
              AND s.TypeId = @TicketTypeId;

        -- Insert recipient
        INSERT INTO dbo.TicketSubtype
        (SubtypeName, 
         TypeId
        )
               SELECT SubtypeName, 
                      TypeId
               FROM @tmpSubtype t
               WHERE t.SubtypeId = 0
                     OR t.SubtypeId IS NULL;
    END;