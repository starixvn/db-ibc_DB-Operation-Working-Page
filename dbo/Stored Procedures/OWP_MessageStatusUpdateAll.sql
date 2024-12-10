/*<info serverAlias="DBOWP-bodb_OWP" executers="wsv_owp" isFunction="0"></info>*/
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
    20241203@Tim: prevent deadlocked
	20241210@Tim: enhance performance
*/
BEGIN
	SET NOCOUNT ON

	DROP TABLE IF EXISTS #updMessageUser
	DROP TABLE IF EXISTS #tempForUpdate

	CREATE TABLE #updMessageUser (MessageUserId INT, IsUpdate BIT DEFAULT(0))
	CREATE TABLE #tempForUpdate (MessageUserId INT)

	INSERT INTO #updMessageUser (MessageUserId)
	SELECT MessageUserId
	FROM dbo.MessageUser AS mu WITH (NOLOCK)
		INNER JOIN dbo.[Message] AS m WITH (NOLOCK) ON mu.MessageId = m.MessageId
	WHERE mu.UserId = @UserId AND m.IsWatcher = @IsWatcher AND IsViewed <> @IsViewed
		
	DECLARE @batchSize INT = 2000

	WHILE (1=1)
	BEGIN	
		UPDATE TOP (@batchSize) c  
		SET c.IsUpdate = 1
		OUTPUT DELETED.MessageUserId INTO #tempForUpdate(MessageUserId)
		FROM #updMessageUser c 
		WHERE IsUpdate = 0
	
		IF @@ROWCOUNT = 0
			BREAK

		UPDATE mu
		SET IsViewed = @IsViewed
		FROM dbo.MessageUser AS mu WITH (ROWLOCK)
			INNER JOIN #tempForUpdate AS m ON mu.MessageUserId = m.MessageUserId
	
		TRUNCATE TABLE #tempForUpdate
	END 
END