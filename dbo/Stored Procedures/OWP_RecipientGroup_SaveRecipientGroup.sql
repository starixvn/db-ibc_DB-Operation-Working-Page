
/*<info serverAlias="DBOWP-bodb_OWP" executers="bodbOWPNet" isFunction="0"></info>*/

ALTER PROCEDURE [dbo].[OWP_RecipientGroup_SaveRecipientGroup] @GroupId    INT, 
                                                              @GroupName  VARCHAR(50), 
                                                              @Recipients VARCHAR(MAX)
AS

/*    
Created: 20210923@Mira  
Task : Ticket Setting  
DB: bodb_OWP  
    
Revisions:    
  20210923@Mira: Initial SP - [Redmine: #160545]  
*/

    BEGIN
        SET NOCOUNT ON;
        DECLARE @tmpRecipients TABLE(UserId INT);
        INSERT INTO @tmpRecipients
               SELECT DISTINCT 
                      val
               FROM fnc_SplitStrings(@Recipients, ',') u OPTION(MAXRECURSION 0);

        -- INSERT or UPDATE GroupName
        IF EXISTS
        (
            SELECT 1
            FROM dbo.TicketGroup
            WHERE GroupId = @GroupId
        )
            BEGIN
                UPDATE dbo.TicketGroup
                  SET 
                      GroupName = @GroupName
                WHERE GroupId = @GroupId;
        END;
            ELSE
            BEGIN
                INSERT INTO dbo.TicketGroup([GroupName])
            VALUES(@GroupName);
                SELECT @GroupId = SCOPE_IDENTITY();
        END;

        -- INSERT or DELETE RecipientGroup
        MERGE dbo.RecipientGroup WITH(ROWLOCK) AS rg
        USING @tmpRecipients AS t
        ON rg.GroupId = @GroupId
           AND rg.RecipientId = t.UserId
            WHEN NOT MATCHED BY TARGET
            THEN
              INSERT([GroupId], 
                     [RecipientId])
              VALUES
        (@GroupId, 
         t.UserId
        )
            WHEN NOT MATCHED BY SOURCE AND rg.GroupId = @GroupId
            THEN DELETE;
    END;