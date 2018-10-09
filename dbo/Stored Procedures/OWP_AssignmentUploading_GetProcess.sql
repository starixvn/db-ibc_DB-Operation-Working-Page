/*<info serverAlias="DBOWP-bodb_OWP" executers="bodbOWPNet" isFunction="0"></info>*/
CREATE PROCEDURE [dbo].[OWP_AssignmentUploading_GetProcess] @SessionId VARCHAR(50)
AS
/*          
 Created: 20170214@Razor.Nguyen
 Task : Get Assignment Uploading progress
 DB: bodb_OWP          
          
 Revisions:      
         20180621@Leo.Vo: new structure of Upload Assignment
*/
BEGIN
	SET NOCOUNT ON

	DECLARE @FailedType INT
		,@MajorWarning INT
		,@MinorWarning INT
		,@TotalRowResult INT
		,@CurrentRowResult INT
		,@WarningRecord INT
		,@FailedRecord INT
		,@TotalRecord INT

	SELECT @FailedType = ResourceId
	FROM dbo.RefResource WITH (NOLOCK)
	WHERE RefName = 'RuleResultType'
		AND Value = 'Failed'

	SELECT @MajorWarning = ResourceId
	FROM dbo.RefResource WITH (NOLOCK)
	WHERE RefName = 'RuleResultType'
		AND Value = 'Major Warning'

	SELECT @MinorWarning = ResourceId
	FROM dbo.RefResource WITH (NOLOCK)
	WHERE RefName = 'RuleResultType'
		AND Value = 'Minor Warning'

	SELECT @TotalRecord = COUNT(1)
	FROM dbo.AssignmentUploading WITH (NOLOCK)
	WHERE SessionId = @SessionId
	GROUP BY SessionId

	SELECT @CurrentRowResult = COUNT(1)
	FROM dbo.AssignmentUploadingResult WITH (NOLOCK)
	WHERE SessionId = @SessionId
	GROUP BY SessionId

	SELECT @WarningRecord = COUNT(DISTINCT RowNumber)
	FROM dbo.AssignmentUploadingResult WITH (NOLOCK)
	WHERE SessionId = @SessionId
		AND (
			ResultType = @MajorWarning
			OR ResultType = @MinorWarning
			)
	GROUP BY SessionId

	SELECT @FailedRecord = COUNT(DISTINCT RowNumber)
	FROM dbo.AssignmentUploadingResult WITH (NOLOCK)
	WHERE SessionId = @SessionId
		AND ResultType = @FailedType
	GROUP BY SessionId

	SELECT l.SessionId
		,[Status]
		,LogMessage AS 'ErrorMessage'
		,TotalRowResult
		,@CurrentRowResult AS CurrentRowResult
		,@WarningRecord AS WarningRecord
		,@FailedRecord AS FailedRecord
		,@TotalRecord AS TotalRecord
	FROM dbo.AssignmentUploadingLog AS l WITH (NOLOCK)
	WHERE l.SessionId = @SessionId

	SELECT SessionId
		,RowNumber / 10 AS RowNumber
		,result.RuleId
		,RuleName
		,ResultType
		,ref.Value AS 'ResultTypeName'
		,[Message] AS 'ResultMessage'
	FROM dbo.AssignmentUploadingResult AS result WITH (NOLOCK)
	INNER JOIN dbo.RefResource AS ref WITH (NOLOCK) ON result.ResultType = ref.ResourceId
	INNER JOIN dbo.ValidationRule AS r WITH (NOLOCK) ON r.RuleId = result.RuleId
	WHERE ref.RefName = 'RuleResultType'
		AND result.SessionId = @SessionId
		AND ref.Value != 'Passed'
		AND result.RowNumber % 10 = 0
END