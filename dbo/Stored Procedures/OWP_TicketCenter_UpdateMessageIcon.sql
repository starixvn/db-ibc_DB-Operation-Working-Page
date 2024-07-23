
/*<info serverAlias="DBOWP-bodb_OWP" executers="wsv_owp" isFunction="0"></info>*/

CREATE PROCEDURE [dbo].[OWP_TicketCenter_UpdateMessageIcon] @MessageId INT, 
                                                            @IconKey   NVARCHAR(200), 
                                                            @CreatorId INT
AS

/*
Created: 20240523@Liam
Task : add message icon
DB: bodb_OWP

Revisions:

    20240523@Liam: add message icon  - [Redmine: #201603]
*/

    BEGIN
        SET NOCOUNT ON;
        DECLARE @Action NVARCHAR(10);
        IF EXISTS
        (
            SELECT 1
            FROM MessageIcon WITH(NOLOCK)
            WHERE MessageId = @MessageId
                  AND IconKey = @IconKey
                  AND CreatorId = @CreatorId
        )
            BEGIN
                -- If it exists, delete it
                DELETE FROM MessageIcon
                WHERE MessageId = @MessageId
                      AND IconKey = @IconKey
                      AND CreatorId = @CreatorId;
                SET @Action = 'Deleted';
        END;
            ELSE
            BEGIN
                -- If it doesn't exist, insert it
                INSERT INTO MessageIcon
                (MessageId, 
                 IconKey, 
                 CreatorId
                )
                VALUES
                (@MessageId, 
                 @IconKey, 
                 @CreatorId
                );
                SET @Action = 'Inserted';
        END;

        -- Output the action performed
        SELECT @Action;
    END;