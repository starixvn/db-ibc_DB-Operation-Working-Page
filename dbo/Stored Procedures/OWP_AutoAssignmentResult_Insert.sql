
/*<info serverAlias="DBOWP-bodb_OWP" executers="bodbOWPNet" isFunction="0"></info>*/
CREATE PROCEDURE [dbo].[OWP_AutoAssignmentResult_Insert] @RequestId VARCHAR(50)
	,@Status INT
	,@AutoAssignmentResultDoc NVARCHAR(MAX)
	,@ErrCode INT  OUTPUT
	,@ErrMsg NVARCHAR(50) OUTPUT
AS
/*
Created: 20181221@Raymond.Le
Task : Insert auto assignment result
DB: bodb_OWP

@Status values:
  Error: -1,
  Success: 0,
  Running: 1
  
Revisions:
	20181221@Raymond.Le: Initial SP - [Redmine: #106196]
	20190503@Leo.Vo: Save request when failure - [Redmine: #112737]
	20191015@Kane.Le: update statusCode - [Redmine: #121765]
	20200601@Carlos.Nguyen: Return ErrorCode, ErrorMessage - [Redmine: #124448]
	20200528@Carlos.Nguyen: Update status code for request last - [Redmine: #126964]
*/
BEGIN
	SET NOCOUNT ON

	DECLARE @idoc INT

	DECLARE @requestLast VARCHAR(255),
		@eventDateGetRequest DATE
	
	SELECT TOP 1 @eventDateGetRequest=req.EventDate
							FROM AutoAssignmentRequest AS req WITH (NOLOCK)
							WHERE req.RequestId=@RequestId
		
	SELECT TOP 1 @requestLast=req.RequestId
	FROM AutoAssignmentRequest AS req WITH (NOLOCK)
	WHERE req.EventDate =@eventDateGetRequest
	ORDER BY req.CreatedDate DESC
	
	UPDATE dbo.AutoAssignmentRequest WITH (ROWLOCK)
	SET [Status] = @Status,
		ResponseDate= GETDATE()
	WHERE RequestId = @requestLast
		AND [Status] <> @Status 

	IF @@ROWCOUNT = 1
		AND @Status = 0 -- save result if success
	BEGIN
		EXEC sp_xml_preparedocument @idoc OUTPUT
			,@AutoAssignmentResultDoc

		INSERT INTO dbo.AutoAssignmentResult (
			RequestId
			,[OWPMatchId]
			,[Bettype]
			,[UserId]
			,[StatusCode]
			)
		SELECT @RequestId
			,[OWPMatchId]
			,[Bettype]
			,NULLIF([UserId], '') AS [UserId]
			,[StatusCode]
		FROM OPENXML(@idoc, '/Root/Row', 1) WITH ([OWPMatchId] [int], [Bettype] [int], [UserId] [int], [StatusCode] [int])

		EXEC sp_xml_removedocument @idoc
	END
	
	SET @ErrCode=0
END