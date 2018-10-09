/*<info serverAlias="DBOWP-bodb_OWP" executers="bodbOWPNet" isFunction="0"></info>*/
CREATE PROCEDURE [dbo].[OWP_MessageStatusUpdateAll] @UserId INT = 0
	,@IsViewed BIT = 1
AS
/*  
Created: 
Task : 
DB: bodb_OWP  
  
Revisions:
	20181009@Raymond.Le: new structure 
*/
BEGIN
	SET NOCOUNT ON

	UPDATE dbo.MessageUser WITH (UPDLOCK, ROWLOCK)
	SET IsViewed = @IsViewed
	WHERE UserId = @UserId
END