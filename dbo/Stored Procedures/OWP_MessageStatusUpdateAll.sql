CREATE PROCEDURE [dbo].[OWP_MessageStatusUpdateAll] @UserId INT = 0
	,@IsViewed BIT = 1
AS
/*  
Created: 
Task : 
DB: bodb_OWP  
  
Revisions:  
     
*/
BEGIN
	SET NOCOUNT ON

	UPDATE dbo.MessageUser WITH (UPDLOCK, ROWLOCK)
	SET IsViewed = @IsViewed
	WHERE UserId = @UserId
END