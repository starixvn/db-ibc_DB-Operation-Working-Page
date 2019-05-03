
/*<info serverAlias="DBOWP-bodb_OWP" executers="bodbOWPNet" isFunction="0"></info>*/
CREATE PROCEDURE [dbo].[OWP_AutoAssignmentResult_Insert] @RequestId VARCHAR(50)
	,@Status INT
	,@AutoAssignmentResultDoc NVARCHAR(MAX)
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
*/
BEGIN
	SET NOCOUNT ON

	DECLARE @idoc INT

	UPDATE dbo.AutoAssignmentRequest WITH (ROWLOCK)
	SET [Status] = @Status
	WHERE RequestId = @RequestId
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
			)
		SELECT @RequestId
			,[OWPMatchId]
			,[Bettype]
			,NULLIF([UserId], '') AS [UserId]
		FROM OPENXML(@idoc, '/Root/Row', 1) WITH ([OWPMatchId] [int], [Bettype] [int], [UserId] [int])

		EXEC sp_xml_removedocument @idoc
	END
END