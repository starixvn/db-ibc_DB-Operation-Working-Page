CREATE PROCEDURE [dbo].[OWP_MessageGetBySessionId] @SessionId NVARCHAR(100) = ''
AS
/*    
Created: 20170404@Alvin.Nguyen  
Task : Get all messages by Session ID   
DB: bodb_OWP    
    
Revisions:
    20170725@Tim.Trinh: message for match cancelled
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
			,CreatedDate
			,CreatedBy
		FROM dbo.MessageUser WITH (NOLOCK)
		WHERE SessionId = @SessionId
		) AS mu
		LEFT JOIN dbo.[Message] AS m WITH (NOLOCK) ON mu.MessageId = m.MessageId
	ORDER BY mu.CreatedDate DESC

	SELECT DISTINCT u.UserId
		,u.Username
	FROM dbo.[User] AS u WITH (NOLOCK)
		INNER JOIN #tblUserMessage AS mu WITH (NOLOCK) ON u.UserId = mu.UserId

	SELECT UserId
		,IsImportant
		,(CASE 
			WHEN MessageType = 1 THEN REPLACE(MessageContent, 'ASSIGNED', '<span class="txt-bold">ASSIGNED</span>')
			WHEN MessageType = 2 THEN REPLACE(MessageContent, 'REMOVED', '<span class="txt-bold">REMOVED</span>')
			WHEN MessageType = 6 AND MessageContent LIKE '%Cancel%' THEN REPLACE(MessageContent, 'Cancel', '<span class="txt-bold badge-label suspended">CANCEL</span>')
			WHEN MessageType = 6 AND MessageContent LIKE '%Postponed%' THEN REPLACE(MessageContent, 'Postponed', '<span class="txt-bold badge-label suspended">POSTPONED</span>')
			WHEN MessageType = 6 AND MessageContent LIKE '%Suspended%' THEN REPLACE(MessageContent, 'Suspended', '<span class="txt-bold badge-label suspended">SUSPENDED</span>')
			ELSE MessageContent END
		) AS 'MessageContent'
		,MessageType
	FROM #tblUserMessage WITH (NOLOCK)

	DROP TABLE #tblUserMessage
END