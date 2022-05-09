/*
Created: 20220428@Johnny
Task : Get User section
DB: bodb_OWP

Revisions:
	20220428@Johnny: Init SP - [Redmine: #171934]  	 
*/

/*<info serverAlias="DBOWP-bodb_OWP" executers="bodbOWPNet" isFunction="0"></info>*/

ALTER PROCEDURE [dbo].[OWP_User_GetSectionIdByUserId] @UserId INT
AS
    BEGIN
        SET NOCOUNT ON;
        SELECT CASE
                   WHEN u.SectionId IS NULL
                   THEN 0
                   ELSE u.SectionId
               END
        FROM dbo.[User] AS u
        WHERE u.UserId = @UserId;
    END;