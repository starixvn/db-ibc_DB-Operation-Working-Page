
/*<info serverAlias="DBOWP-bodb_OWP" executers="bodbOWPNet" isFunction="0"></info>*/

ALTER PROCEDURE [dbo].[OWP_TicketCenter_UpdateSingleRecipientReader] @TicketIds   NVARCHAR(MAX), 
                                                                     @RecipientId INT, 
                                                                     @IsRead      BIT           = NULL
AS

/*
 Created: 20210917@Carlos.Nguyen
 Task : Upate is read
 DB: bodb_OWP      
      
 Revisions:          
	20210917@Carlos.Nguyen: Event ticket - [Redmine: #158037]
	20240816@Mira: consolidate ticket - [Redmine: #207945]
*/

    BEGIN
        SET NOCOUNT ON;
        DECLARE @TicketIdsTable TABLE(TicketId INT);

        -- Parse TicketIds
        INSERT INTO @TicketIdsTable(TicketId)
               SELECT CAST(value AS INT)
               FROM STRING_SPLIT(@TicketIds, ',');

        -- Update
        UPDATE tmr
          SET 
              tmr.IsRead = @IsRead
        FROM TicketMessageReader tmr
             INNER JOIN @TicketIdsTable t ON tmr.TicketId = t.TicketId
        WHERE tmr.RecipientId = @RecipientId
              AND tmr.IsRead <> @IsRead;
    END;