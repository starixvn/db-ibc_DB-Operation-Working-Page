/*<info serverAlias="DBOWP-bodb_OWP" executers="bodbOWPNet" isFunction="0"></info>*/
CREATE PROCEDURE [dbo].[OWP_MessageGetByUserId] @UserId INT = 0
	,@SelectTop INT = NULL
	,@LastMessageId INT = NULL
	,@TotalNotViewMessage INT = 0 OUTPUT
AS
/*    
Created: 20161004@Long.Luu
Task : Get all messages by User ID
DB: bodb_OWP
    
Revisions:
  20170116@Tim.Trinh: get message type  
  20170725@Tim.Trinh: messages for match cancelled
  20180614@Jacob.Phan: Message - Only display yesterday and today message in message box - Hotfix #96282
  20180813@Leo: default value for parameters
*/
BEGIN
	SET NOCOUNT ON

	DECLARE @AnnouncementMessage TINYINT = 2
		,@Message TINYINT = 3
		,@CurrentRow INT = NULL
		,@MinDate DATE = DATEADD(day,-2, CAST(GETDATE() AS DATE))

	SELECT @TotalNotViewMessage = COUNT(m.MessageId)
	FROM dbo.[Message] AS m WITH (NOLOCK)
		INNER JOIN dbo.MessageUser AS mu WITH (NOLOCK) ON mu.MessageId = m.MessageId
	WHERE mu.UserId = @UserId
		AND mu.IsViewed = 0
		AND mu.CreatedDate >= @MinDate

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
		,SystemMessageType TINYINT
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
			,SystemMessageType
		FROM #OrderedMessage WITH (NOLOCK)
	END
	ELSE
	BEGIN
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
			,SystemMessageType
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
				WHEN mt.SystemMessageType = @Message THEN u.ProfilePic
				ELSE NULL END
				) AS ProfilePic
			,m.MessageType
			,mt.SystemMessageType
		FROM dbo.MessageUser AS mu WITH (NOLOCK)
			INNER JOIN dbo.[Message] AS m WITH (NOLOCK) ON mu.MessageId = m.MessageId
			INNER JOIN dbo.[User] AS u WITH (NOLOCK) ON mu.CreatedBy = u.UserId
			LEFT JOIN dbo.MessageTemplate AS mt WITH (NOLOCK) ON m.MessageType = mt.MsgTemplateId
		WHERE mu.UserId = @UserId
		AND mu.CreatedDate >= @MinDate
	
		SELECT @CurrentRow = RowNumber
		FROM #OrderedMessage WITH (NOLOCK)
		WHERE MessageId = @LastMessageId

		SET @CurrentRow = ISNULL(@CurrentRow, 0)

		SELECT om.RowNumber
			,om.MessageId
			,om.IsViewed
			,MessageContent
			,om.CreatedBy
			,om.CreatedDate
			,om.IsImportant
			,om.ProfilePic
			,om.MessageType
			,om.SystemMessageType
		FROM #OrderedMessage AS om WITH (NOLOCK)
			LEFT JOIN dbo.MessageTemplate AS mt WITH (NOLOCK) ON om.MessageType = mt.MsgTemplateId
		WHERE om.RowNumber >= (1 + @CurrentRow)
			AND om.RowNumber <= (@SelectTop + @CurrentRow)
	END

	DROP TABLE #OrderedMessage
END