
/*<info serverAlias="DBOWP-bodb_OWP" executers="wsv_owp,wsv_nap" isFunction="0"></info>*/

ALTER PROCEDURE [dbo].[OWP_GetNewUser]
AS

/*
Created: 2020250414@Los
Task: Get new user
DB: bodb_OWP
Original: 

Revisions:
	20250414@Los: get new user - [Redmine: #223430]
*/

    BEGIN
        SET NOCOUNT ON;
        SELECT CASE WHEN Username IS NULL
		THEN Nickname
		ELSE Username
		END 'UserName',
		UserId
		FROM [User]
		WHERE ChatUserId IS NULL;
    END;