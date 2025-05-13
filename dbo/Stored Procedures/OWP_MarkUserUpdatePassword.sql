
/*<info serverAlias="DBOWP-bodb_OWP" executers="wsv_owp" isFunction="0"></info>*/

CREATE PROCEDURE [dbo].[OWP_MarkUserUpdatePassword] @UserId INT
AS

/*
Created: 20250508@Los
Task: Mark user update password.
DB: bodb_OWP
Original: 

Revisions:
	20250508@Los: Mark user update password - [Redmine: #224556]
*/

    BEGIN
        UPDATE [User] WITH(ROWLOCK, UPDLOCK)
          SET 
              PasswordUpdateCount = PasswordUpdateCount + 1, 
              LastPasswordChangedAt = DATEADD(HOUR, 12, CONVERT(DATETIME, GETDATE()))
        WHERE UserId = @UserId;
    END;