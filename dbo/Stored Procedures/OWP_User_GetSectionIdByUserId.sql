/*
Created: 20220428@Johnny
Task : Get User section
DB: bodb_OWP

Revisions:
	20220428@Johnny: Init SP - [Redmine: #171934]  	 
*/
CREATE PROCEDURE [dbo].[OWP_User_GetSectionIdByUserId] @UserId int
	 
AS	
BEGIN
	SET NOCOUNT ON
	SELECT u.SectionId	 
	FROM dbo.[User] as u
	WHERE u.UserId = @UserId
END
