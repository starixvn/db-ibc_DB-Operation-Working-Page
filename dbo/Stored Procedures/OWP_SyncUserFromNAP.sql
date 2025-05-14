
/*<info serverAlias="DBOWP-bodb_OWP" executers="wsv_owp" isFunction="0"></info>*/

ALTER PROCEDURE [dbo].[OWP_SyncUserFromNAP] @UserId   INT, 
                                            @Username VARCHAR(30), 
                                            @ErrCode  INT           = 0 OUTPUT, 
                                            @ErrMsg   NVARCHAR(200) = '' OUTPUT
AS

/*
Created: 20250508@Los
Task: Sync user from NAP.
DB: bodb_OWP
Original: 

Revisions:
	20250508@Los: Sync user from NAP - [Redmine: #224556]
*/

    BEGIN
        SET NOCOUNT ON;
        IF NOT EXISTS
        (
            SELECT 1
            FROM dbo.[User] WITH(NOLOCK)
            WHERE UserId = @UserId
        )
            BEGIN
                BEGIN TRY
                    INSERT INTO dbo.[User]
                    (UserId, 
                     Username
                    )
                    VALUES
                    (@UserId, 
                     @username
                    );
        END TRY
                BEGIN CATCH
                    BEGIN
                        SELECT @ErrCode = 1, 
                               @ErrMsg = 'Insert user failed.';
        END;
        END CATCH;
        END;
            ELSE
            BEGIN
                SELECT @ErrCode = 1, 
                       @ErrMsg = 'User already exists.';
        END;
    END;