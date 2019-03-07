/*<info serverAlias="DBOWP-bodb_OWP" executers="bodbOWPNet" isFunction="0"></info>*/
CREATE PROCEDURE [dbo].[OWP_MessageStatusUpdateAll] @UserId INT
	,@IsWatcher BIT = 0
	,@IsViewed BIT = 1
AS
/*  
Created: 
Task : 
DB: bodb_OWP  
  
Revisions:
	20181009@Raymond.Le: New structure of event assignment - [Redmine: #92868]
*/
BEGIN
	SET NOCOUNT ON

	UPDATE mu
	SET IsViewed = @IsViewed
	FROM dbo.MessageUser AS mu WITH (ROWLOCK)
		INNER JOIN dbo.[Message] AS m WITH (NOLOCK) ON mu.MessageId = m.MessageId
	WHERE mu.UserId = @UserId
		AND m.IsWatcher = @IsWatcher
END