
/*<info serverAlias="DBOWP-bodb_OWP" executers="bodbOWPNet" isFunction="0"></info>*/

ALTER PROCEDURE [dbo].[OWP_OSAssignmentUpload_GetSectionBBSupportive]
AS

/*
Created: 20231106@Los
Task : Get section BB supportive
DB: bodb_OWP

Revisions:
	20231106@Los: Init SP - [Redmine: #195697]	
*/

    BEGIN
        SELECT CAST(u.UserId AS VARCHAR(100))
        FROM dbo.[User] AS u WITH(NOLOCK)
        WHERE u.SectionId = 35;
    END;