/*<info serverAlias="DBOWP-bodb_OWP" executers="bodbOWPNet" isFunction="0"></info>*/
CREATE PROCEDURE [dbo].[OWP_MessageUpdateReadStatus] @UserId INT = 0
	,@MessageId INT 
AS
/*  
Created: 
Task : 
DB: bodb_OWP  
  
Revisions:
	20190214@Kane.Le: Init SP - [Redmine: #92868]
*/
BEGIN
	SET NOCOUNT ON

	UPDATE dbo.MessageUser WITH (UPDLOCK, ROWLOCK)
	SET IsViewed = 1
	WHERE UserId = @UserId AND MessageId = @MessageId
END