/*<info serverAlias="DBOWP-bodb_OWP" executers="bodbOWPNet" isFunction="0"></info>*/
CREATE PROCEDURE [dbo].[OWP_MessageInsert] @UserId INT = 0
	,@MessageContent NVARCHAR(MAX) = ''
	,@MessageTo NVARCHAR(MAX) = 'All' -- in case of send to list of users, UserId separated by a comma
	,@IsImportant BIT = 0
	,@MessageType TINYINT = 1
	,@SessionId NVARCHAR(100) = NULL
	,@ErrCode INT = 0 OUTPUT
	,@ErrMsg NVARCHAR(200) = '' OUTPUT
AS
/*  
Created: 20161004@Long.Luu
Task : Insert Message
DB: bodb_OWP  
  
Revisions:  
  20170116@Tim.Trinh: add MessageType   
  20180927@Leo: remove unused columns
*/
BEGIN
	SET NOCOUNT ON

	IF (LEN(@MessageTo) = 0) RETURN

	-- Write Log: Initialize
	DECLARE @StartRun DATETIME
		,@EndRun DATETIME
		,@Duration INT
		,@MessageData NVARCHAR(MAX)
		,@Xml XML

	CREATE TABLE #SendToUsers (UserId INT)

	SET @StartRun = GETDATE()

	-- Write Log: End Initialize
	DECLARE @MessageId INT = 0

	SELECT @MessageId = m.MessageId
	FROM dbo.[Message] AS m WITH (NOLOCK)
	WHERE m.MessageContent = @MessageContent

	IF (
			@MessageId IS NULL
			OR @MessageId <= 0
			)
	BEGIN
		INSERT INTO dbo.[Message] (
			MessageContent
			,CreatedBy
			,CreatedDate
			,IsImportant
			,MessageType
			)
		VALUES (
			@MessageContent
			,@UserId
			,GETDATE()
			,@IsImportant
			,@MessageType
			)

		SELECT @MessageId = SCOPE_IDENTITY()
	END

	IF @MessageTo = 'All'
	BEGIN
		INSERT INTO #SendToUsers (UserId)
		SELECT u.UserId
		FROM dbo.[User] AS u WITH (NOLOCK)
	END
	ELSE
	BEGIN
		INSERT INTO #SendToUsers (UserId)
		SELECT DISTINCT CAST([val] AS INT) AS UserId
		FROM dbo.strSplit(@MessageTo, ',')
	END
	
		
	INSERT INTO dbo.MessageUser (
		MessageId
		,UserId
		,CreatedBy
		,CreatedDate
		,SessionId
		)
	SELECT @MessageId
		,fu.UserId
		,@UserId
		,GETDATE()
		,@SessionId
	FROM (
		SELECT DISTINCT stu.UserId
		FROM #SendToUsers AS stu
		) AS fu

	DROP TABLE #SendToUsers

	-- Write Log: Continue		
	SET @Xml = (
			SELECT @MessageContent AS '@mc'
				,@MessageTo AS '@mt'
				,@IsImportant AS '@ii'
				,0 AS '@ip'
				,@MessageType AS '@type'
			FOR XML PATH('z')
				,ROOT('r')
			)
	SET @MessageData = REPLACE(CONVERT(NVARCHAR(MAX), @Xml), '" />', '"/"')
	SET @EndRun = GETDATE()
	SET @Duration = DATEDIFF(MILLISECOND, @StartRun, @EndRun)

	EXEC dbo.OWP_WriteLog @CreatorId = @UserId
		,@SPName = 'OWP_MessageInsert'
		,@LoggedDate = @StartRun
		,@Duration = @Duration
		,@ObjectId = @MessageId
		,@Data = @MessageData
		,@DataOld = NULL
END