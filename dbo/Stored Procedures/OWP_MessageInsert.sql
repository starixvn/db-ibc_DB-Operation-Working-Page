
/*<info serverAlias="DBOWP-bodb_OWP" executers="bodbOWPNet" isFunction="0"></info>*/
CREATE PROCEDURE [dbo].[OWP_MessageInsert] @UserId INT = 0
	,@MessageContent NVARCHAR(MAX) = ''
	,@MessageTo TVP_INT READONLY
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
  20180927@Leo: remove unused columns - [Redmine: #92868]
  20181012@Leo.Vo: Notify assignee - [Redmine: #102867]
*/
BEGIN
	SET NOCOUNT ON

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

	INSERT INTO dbo.MessageUser (
		MessageId
		,UserId
		,CreatedBy
		,CreatedDate
		,SessionId
		)
	SELECT @MessageId
		,Id
		,@UserId
		,GETDATE()
		,@SessionId
	FROM @MessageTo
END