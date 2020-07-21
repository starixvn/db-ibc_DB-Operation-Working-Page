/*<info serverAlias="DBOWP-bodb_OWP" executers="bodbOWPNet" isFunction="0"></info>*/
ALTER PROCEDURE [dbo].[OWP_MessageGetByUserId] @UserId INT
	,@IsWatcher BIT = 0
	,@SelectTop INT = 10
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
  20180813@Leo: default value for parameters - [Redmine: #92868]
  20190108@Leo: handle with CreatedBy=0 - [Redmine: #107257]
  20190213@Kane.Le: remove createdDate vs CreatedBy table MessageUser - [Redmine: #108723]
  20190222@Leo.Vo: support watcher - [Redmine: #108723]
  20200105@Kane.Le: Fix High CPU - [Redmine: #108723]
  20200228@Jacob: Revise Index - [Redmine: #129435]
  20200721@Mirra: Rewrite SP, Only display select top message - [Redmine: #137752]
*/
BEGIN
	SET NOCOUNT ON

	DECLARE @Message TINYINT = 3
		,@MinDate DATE = DATEADD(day, - 1, CAST(GETDATE() AS DATE))
	 
	SELECT @TotalNotViewMessage = COUNT(m.MessageId)
	FROM dbo.[Message] AS m WITH (NOLOCK)
		INNER JOIN dbo.MessageUser AS mu WITH (NOLOCK) ON mu.MessageId = m.MessageId
	WHERE mu.UserId = @UserId
		AND m.IsWatcher = @IsWatcher
		AND mu.IsViewed = 0
		AND m.CreatedDate >= @MinDate

	SELECT TOP (@SelectTop) ROW_NUMBER() OVER (
			ORDER BY mu.MessageId DESC
			) AS RowNumber
		,mu.MessageId
		,mu.IsViewed
		,m.MessageContent
		,m.CreatedBy
		,m.CreatedDate
		,m.IsImportant
		,(CASE 
			WHEN mt.SystemMessageType = @Message THEN u.ProfilePic
			ELSE NULL END
			) AS ProfilePic
		,m.MessageType
		,mt.SystemMessageType
	FROM dbo.MessageUser AS mu WITH (NOLOCK)
		INNER JOIN dbo.[Message] AS m WITH (NOLOCK) ON mu.MessageId = m.MessageId
		LEFT JOIN dbo.[User] AS u WITH (NOLOCK) ON m.CreatedBy = u.UserId
		LEFT JOIN dbo.MessageTemplate AS mt WITH (NOLOCK) ON m.MessageType = mt.MsgTemplateId
	WHERE mu.UserId = @UserId
		AND m.IsWatcher = @IsWatcher
		AND m.CreatedDate >= @MinDate 	
END