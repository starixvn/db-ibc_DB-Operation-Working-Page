/*<info serverAlias="DBOWP-bodb_OWP" executers="bodbOWPNet" isFunction="0"></info>*/
CREATE PROC [dbo].[OWP_MessageGetByUserIdWithPaging] @UserId INT
	,@PageSize INT = 25
	,@PageNumber INT = 1
	,@Keyword NVARCHAR(250) = NULL
	,@IsWatcher BIT = NULL
	,@TotalRecords INT = 0 OUTPUT
AS
/*    
Created: 20190214@Kane.Le
Task : Get all messages by User ID whith paging
DB: bodb_OWP
    
Revisions:    
  20190214@Kane.Le: init SP - [Redmine: #108723]
  
*/
BEGIN
	CREATE TABLE #FilterdMessageIds (MessageId INT)

	IF @IsWatcher IS NOT NULL
	BEGIN
		INSERT INTO #FilterdMessageIds
		SELECT mm.MessageId
		FROM dbo.[Message] mm WITH (NOLOCK)
		WHERE mm.IsWatcher = @IsWatcher
	END
	ELSE
	BEGIN
		INSERT INTO #FilterdMessageIds
		SELECT mm.MessageId
		FROM dbo.[Message] mm WITH (NOLOCK)
	END

	CREATE TABLE #FilterdMessage (
		MessageId INT
		,UserId INT
		,IsViewed BIT
		,MessageContent NVARCHAR(MAX)
		,CreatedBy INT
		,CreatedDate DATETIME
		,IsImportant BIT
		,MessageType TINYINT
		,SystemMessageType TINYINT
		)

	IF @Keyword IS NOT NULL
	BEGIN
		INSERT INTO #FilterdMessage
		SELECT mm.MessageId
			,um.UserId
			,um.IsViewed
			,mm.MessageContent
			,mm.CreatedBy
			,mm.CreatedDate
			,mm.IsImportant
			,mm.MessageType
			,mt.SystemMessageType
		FROM dbo.MessageUser um WITH (NOLOCK)
		JOIN dbo.[Message] mm WITH (NOLOCK) ON um.MessageId = mm.MessageId
		LEFT JOIN dbo.MessageTemplate AS mt WITH (NOLOCK) ON mm.MessageType = mt.MsgTemplateId
		WHERE mm.MessageId IN (
				SELECT MessageId
				FROM #FilterdMessageIds
				)
			AND um.UserId = @UserId
			AND mm.MessageContent LIKE '%' + @Keyword + '%'
	END
	ELSE
	BEGIN
		INSERT INTO #FilterdMessage
		SELECT mm.MessageId
			,um.UserId
			,um.IsViewed
			,mm.MessageContent
			,mm.CreatedBy
			,mm.CreatedDate
			,mm.IsImportant
			,mm.MessageType
			,mt.SystemMessageType
		FROM dbo.MessageUser um WITH (NOLOCK)
		JOIN dbo.[Message] mm WITH (NOLOCK) ON um.MessageId = mm.MessageId
		LEFT JOIN dbo.MessageTemplate AS mt WITH (NOLOCK) ON mm.MessageType = mt.MsgTemplateId
		WHERE mm.MessageId IN (
				SELECT MessageId
				FROM #FilterdMessageIds
				)
			AND um.UserId = @UserId
	END

	SELECT *
	FROM (
		SELECT ROW_NUMBER() OVER (
				ORDER BY MessageId DESC
				) AS RowNumber
			,fm.MessageId
			,fm.MessageContent
			,fm.IsViewed
			,fm.UserId
			,fm.CreatedBy
			,fm.CreatedDate
			,fm.IsImportant
			,fm.MessageType
			,fm.SystemMessageType
		FROM #FilterdMessage fm
		) AS x
	WHERE RowNumber BETWEEN ((@PageNumber - 1) * @PageSize + 1)
			AND (@PageNumber * @PageSize)

	SELECT @TotalRecords = COUNT(1)
	FROM #FilterdMessage

	DROP TABLE #FilterdMessage

	DROP TABLE #FilterdMessageIds
END