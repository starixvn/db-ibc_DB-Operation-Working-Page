/*<info serverAlias="DBOWP-bodb_OWP" executers="wsv_owp" isFunction="0"></info>*/
CREATE PROCEDURE [dbo].[OWP_MessageGetBySessionId] @SessionId NVARCHAR(100) = ''
AS
/*    
Created: 20170404@Alvin.Nguyen  
Task : Get all messages by Session ID   
DB: bodb_OWP    
    
Revisions:
    20170725@Tim.Trinh: message for match cancelled
	20180831@Leo: New structure of event assignment, replace in JS - [Redmine: #92868]
*/
BEGIN
	SET NOCOUNT ON

	CREATE TABLE #tblUserMessage (
		UserId INT
		,IsImportant BIT
		,MessageContent NVARCHAR(MAX)
		,MessageType INT
		)

	INSERT INTO #tblUserMessage (
		UserId
		,IsImportant
		,MessageContent
		,MessageType
		)
	SELECT mu.UserId
		,m.IsImportant
		,m.MessageContent
		,m.MessageType
	FROM (
		SELECT MessageId
			,UserId
			,IsViewed			
		FROM dbo.MessageUser WITH (NOLOCK)
		WHERE SessionId = @SessionId
		) AS mu
		LEFT JOIN dbo.[Message] AS m WITH (NOLOCK) ON mu.MessageId = m.MessageId
	ORDER BY m.CreatedDate DESC

	SELECT DISTINCT u.UserId
		,u.Username
	FROM dbo.[User] AS u WITH (NOLOCK)
		INNER JOIN #tblUserMessage AS mu WITH (NOLOCK) ON u.UserId = mu.UserId

	SELECT UserId
		,IsImportant
		,MessageContent
		,MessageType
	FROM #tblUserMessage WITH (NOLOCK)

	DROP TABLE #tblUserMessage
END