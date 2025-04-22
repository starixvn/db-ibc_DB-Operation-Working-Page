
/*<info serverAlias="DBOWP-bodb_OWP" executers="wsv_owp,wsv_nap" isFunction="0"></info>*/

CREATE PROCEDURE [dbo].[OWP_UpdateChatUserId] @UserJson VARCHAR(MAX)
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
        UPDATE u
          SET 
              u.ChatUserId = c.ChatUserId
        FROM [User] AS u WITH (NOLOCK)
             INNER JOIN OPENJSON(@UserJson) WITH(UserId INT, ChatUserId VARCHAR(50)) AS c ON u.UserId = c.UserId;
    END;