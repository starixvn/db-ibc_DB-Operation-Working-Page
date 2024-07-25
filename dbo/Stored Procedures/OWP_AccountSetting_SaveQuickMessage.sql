
/*<info serverAlias="DBOWP-bodb_OWP" executers="wsv_owp" isFunction="0"></info>*/

ALTER PROCEDURE [dbo].[OWP_AccountSetting_SaveQuickMessage] @Id       INT            = 0, 
                                                            @Shortcut NVARCHAR(100), 
                                                            @Message  NVARCHAR(1000), 
                                                            @UserId   INT
AS

/*      
 Created: 20240521@Mira
 Task : Account Setting page
 DB: bodb_OWP      
 
 Revisions:
    20240521@Mira: save quick message - [Redmine: #201603]
*/

    BEGIN
        SET NOCOUNT ON;
        DECLARE @LogTime DATETIME= GETDATE();
        IF EXISTS
        (
            SELECT 1
            FROM dbo.QuickMessage
            WHERE Id = @Id
        )
            BEGIN
                UPDATE dbo.QuickMessage
                  SET 
                      Shortcut = @Shortcut, 
                      [Message] = @Message, 
                      CreatedDate = @LogTime
                WHERE Id = @Id;
        END;
            ELSE
            BEGIN
                INSERT INTO dbo.QuickMessage
                (Shortcut, 
                 [Message], 
                 CreatedDate, 
                 CreatorId
                )
                VALUES
                (@Shortcut, 
                 @Message, 
                 @LogTime, 
                 @UserId
                );
        END;
    END;