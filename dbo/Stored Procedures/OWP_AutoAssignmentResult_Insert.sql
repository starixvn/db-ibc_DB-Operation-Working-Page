
/*<info serverAlias="DBOWP-bodb_OWP" executers="bodbOWPNet" isFunction="0"></info>*/
CREATE PROCEDURE [dbo].[OWP_AutoAssignmentResult_Insert] @RequestId VARCHAR(50)
	,@AutoAssignmentResultDoc NVARCHAR(MAX)
AS
/*
Created: 20181221@Raymond.Le
Task : Insert auto assignment result
DB: bodb_OWP

Revisions:
	20181221@Raymond.Le: Initial SP - [Redmine: #106196]
*/
BEGIN
	SET NOCOUNT ON

	DECLARE @idoc INT
		,@Status INT

	SELECT @Status = [Status]
	FROM dbo.AutoAssignmentRequest WITH (NOLOCK)
	WHERE RequestId = @RequestId

	IF @Status = 1
	BEGIN
		UPDATE dbo.AutoAssignmentRequest WITH (ROWLOCK)
		SET [Status] = 0
		WHERE RequestId = @RequestId

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