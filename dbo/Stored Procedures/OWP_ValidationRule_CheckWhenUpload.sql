/*<info serverAlias="DBOWP-bodb_OWP" executers="bodbOWPNet" isFunction="0"></info>*/
CREATE PROCEDURE [dbo].[OWP_ValidationRule_CheckWhenUpload] @SessionId VARCHAR(50)
AS
/*  
 Created: 20170214@Tim.Trinh
 Task : validation rule when upload
 DB: bodb_OWP
  
 Revisions:
	20180621@Leo.Vo: New structure of event assignment - [Redmine: #92868]
 */
BEGIN
	SET NOCOUNT ON

	DECLARE @TotalRule SMALLINT
		,@RowIndex SMALLINT = 1
		,@sqlstring NVARCHAR(500)
		,@RuleId INT

	-- get rules for Assignment Uploading
	CREATE TABLE #tblValidationRule (
		RowIndex SMALLINT IDENTITY(1, 1)
		,RuleId SMALLINT
		,SPName VARCHAR(200)
		)

	INSERT INTO #tblValidationRule (
		RuleId
		,SPName
		)
	SELECT r.RuleId
		,r.SPName
	FROM dbo.[Function] AS f WITH (NOLOCK)
	INNER JOIN dbo.FunctionRule AS fr WITH (NOLOCK) ON f.FunctionId = fr.FunctionId
	INNER JOIN dbo.ValidationRule AS r WITH (NOLOCK) ON fr.RuleId = r.RuleId
		AND r.IsActive = 1
	WHERE f.FunctionName = 'AssignmentUploading'

	SELECT @TotalRule = COUNT(1)
	FROM #tblValidationRule WITH (NOLOCK)

	-- update status of current Assignment Uploading
	UPDATE dbo.AssignmentUploadingLog
	WITH (
			ROWLOCK
			,UPDLOCK
			)

	SET [Status] = 1 --In progress
		,StartDate = GETDATE()
	WHERE SessionId = @SessionId
		AND [Status] = 0 --pending

	WHILE @RowIndex <= @TotalRule
	BEGIN
		SELECT @sqlstring = SPName + ' @SessionId=''' + @SessionId + ''''
			,@ruleId = RuleId
		FROM #tblValidationRule WITH (NOLOCK)
		WHERE RowIndex = @RowIndex

		BEGIN TRY
			--WAITFOR DELAY '00:00:01'
			INSERT INTO dbo.AssignmentUploadingResult (
				SessionId
				,RowNumber
				,RuleId
				,ResultType
				,[Message]
				)
			EXEC sp_executesql @sqlstring
		END TRY

		BEGIN CATCH
			UPDATE dbo.AssignmentUploadingLog
			WITH (
					ROWLOCK
					,UPDLOCK
					)

			SET [Status] = 2 --error
				,LogMessage += '\n' + 'Row Number: ' + CAST(@RowIndex AS VARCHAR(1000)) + ' --- Message: ' + ERROR_MESSAGE() + ' --- RuleId: ' + CAST(@ruleId AS VARCHAR(10))
			WHERE SessionId = @SessionId
		END CATCH

		SET @RowIndex = @RowIndex + 1
	END

	UPDATE dbo.AssignmentUploadingLog
	WITH (
			ROWLOCK
			,UPDLOCK
			)

	SET [Status] = 3 -- validated
		,EndDate = GETDATE()
	WHERE SessionId = @SessionId
		AND [Status] = 1 -- in progress

	DROP TABLE #tblValidationRule
END