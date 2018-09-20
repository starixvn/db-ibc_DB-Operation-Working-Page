CREATE PROCEDURE [dbo].[OWP_MessageGetByUserId] @UserId INT = 0
	,@SelectTop INT = NULL
	,@LastMessageId INT = NULL
	,@TotalNotViewMessage INT OUTPUT
AS
/*    
Created: 20161004@Long.Luu
Task : Get all messages by User ID
DB: bodb_OWP
    
Revisions:
  20170116@Tim.Trinh: get message type  
  20170725@Tim.Trinh: messages for match cancelled
  20180614@Jacob.Phan: Message - Only display yesterday and today message in message box - Hotfix #96282
       
*/
BEGIN
	SET NOCOUNT ON

	DECLARE @AnnouncementMessage TINYINT = 2
		,@Message TINYINT = 3
		,@CurrentRow INT = NULL

	SELECT @TotalNotViewMessage = COUNT(m.MessageId)
	FROM dbo.[Message] AS m WITH (NOLOCK)
		INNER JOIN dbo.MessageUser AS mu WITH (NOLOCK) ON mu.MessageId = m.MessageId
	WHERE mu.UserId = @UserId
		AND mu.IsViewed = 0
		AND mu.CreatedDate >= DATEADD(day,-2, CAST(GETDATE() AS DATE))

	--create ordered table message
	CREATE TABLE #OrderedMessage (
		RowNumber INT
		,MessageId INT
		,IsViewed BIT
		,MessageContent NVARCHAR(MAX)
		,CreatedBy INT
		,CreatedDate DATETIME
		,IsImportant BIT
		,ProfilePic VARCHAR
		,MessageType TINYINT
		)

	SET @SelectTop = ISNULL(@SelectTop, 0)

	IF (@SelectTop = 0)
	BEGIN
		SELECT RowNumber
			,MessageId
			,IsViewed
			,MessageContent
			,CreatedBy
			,CreatedDate
			,IsImportant
			,ProfilePic
			,MessageType
		FROM #OrderedMessage WITH (NOLOCK)

		DROP TABLE #OrderedMessage

		RETURN
	END

	INSERT INTO #OrderedMessage (
		RowNumber
		,MessageId
		,IsViewed
		,MessageContent
		,CreatedBy
		,CreatedDate
		,IsImportant
		,ProfilePic
		,MessageType
		)
	SELECT ROW_NUMBER() OVER (
			ORDER BY mu.CreatedDate DESC
			) AS RowNumber
		,mu.MessageId
		,mu.IsViewed
		,m.MessageContent
		,mu.CreatedBy
		,mu.CreatedDate
		,m.IsImportant
		,(CASE 
			WHEN mt.ParentMsgTypeId IS NOT NULL
				AND mt.ParentMsgTypeId = @Message THEN u.ProfilePic
			ELSE NULL END
			) AS ProfilePic
		,(CASE 
			WHEN m.IsPublic = 1 THEN @AnnouncementMessage
			ELSE m.MessageType END
			) AS MessageType
	FROM dbo.MessageUser AS mu WITH (NOLOCK)
		INNER JOIN dbo.[Message] AS m WITH (NOLOCK) ON mu.MessageId = m.MessageId
		INNER JOIN dbo.[User] AS u WITH (NOLOCK) ON mu.CreatedBy = u.UserId
		LEFT JOIN dbo.MessageTemplate AS mt WITH (NOLOCK) ON m.MessageType = mt.MsgTemplateId
	WHERE mu.UserId = @UserId
	AND mu.CreatedDate >= DATEADD(day,-2, CAST(GETDATE() AS DATE))
	
	SELECT @CurrentRow = RowNumber
	FROM #OrderedMessage WITH (NOLOCK)
	WHERE MessageId = @LastMessageId

	SET @CurrentRow = ISNULL(@CurrentRow, 0)

	SELECT om.RowNumber
		,om.MessageId
		,om.IsViewed
		,(CASE 
			WHEN om.MessageType = 1 THEN REPLACE(om.MessageContent, 'ASSIGNED', '<span class="txt-bold success-info">ASSIGNED</span>')
			WHEN om.MessageType = 2 THEN REPLACE(om.MessageContent, 'REMOVED', '<span class="txt-bold error-info">REMOVED</span>')
			WHEN om.MessageType = 6 AND om.MessageContent LIKE '%Cancel%' THEN REPLACE(om.MessageContent, 'Cancel', '<span class="txt-bold cancel-info">CANCEL</span>')
			WHEN om.MessageType = 6 AND om.MessageContent LIKE '%Postponed%' THEN REPLACE(om.MessageContent, 'Postponed', '<span class="txt-bold cancel-info">POSTPONED</span>')
			WHEN om.MessageType = 6 AND om.MessageContent LIKE '%Suspended%' THEN REPLACE(om.MessageContent, 'Suspended', '<span class="txt-bold cancel-info">SUSPENDED</span>')
			ELSE om.MessageContent END
			) AS 'MessageContent'
		,om.CreatedBy
		,om.CreatedDate
		,om.IsImportant
		,om.ProfilePic
		,(CASE 
			WHEN mt.ParentMsgTypeId IS NOT NULL THEN mt.ParentMsgTypeId
			ELSE om.MessageType END
			) AS MessageType
	FROM #OrderedMessage AS om WITH (NOLOCK)
		LEFT JOIN dbo.MessageTemplate AS mt WITH (NOLOCK) ON om.MessageType = mt.MsgTemplateId
	WHERE om.RowNumber >= (1 + @CurrentRow)
		AND om.RowNumber <= (@SelectTop + @CurrentRow)

	DROP TABLE #OrderedMessage
END