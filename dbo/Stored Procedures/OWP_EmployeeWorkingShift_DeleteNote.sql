/*<info serverAlias="DBOWP-bodb_OWP" executers="bodbOWPNet" isFunction="0"></info>*/
CREATE PROCEDURE [dbo].[OWP_EmployeeWorkingShift_DeleteNote] @ActorId INT
	,@EmployeeWorkingShiftNoteId INT
AS
/*
Created: 20191015@Tyler.Dang
Task : Insert new EmployeeWorkingShift Note
DB: bodb_OWP

Revisions:
	20191015@Tyler.Dang: Init SP - [Redmine: #121901]
*/
BEGIN
	SET NOCOUNT ON;

    DECLARE @StartRun DATETIME
		,@EndRun DATETIME
		,@Duration INT
		,@OldNote NVARCHAR(4000)
		,@OldCreatedDate DATETIME
		,@OldCreatedBy INT
		,@UserId INT
		,@OldShiftDate DATETIME
		,@LogDataOld NVARCHAR(MAX)
		,@Xml XML
		,@LastUpdated DATETIME

	SELECT @OldNote = Note
		,@OldCreatedBy = CreatedBy
		,@OldCreatedDate = CreatedDate
		,@OldShiftDate = ShiftDate
		,@UserId = UserId
	FROM dbo.[EmployeeWorkingShiftNote] WITH (NOLOCK)
	WHERE EmployeeWorkingShiftNoteId = @EmployeeWorkingShiftNoteId
	
	SET @StartRun = GETDATE()
	SET @Xml = (
			SELECT @OldNote AS '@nt'
				,@OldCreatedDate AS '@cd'
				,@OldCreatedBy AS '@cb'
				,@OldShiftDate AS '@sd'
				,@EmployeeWorkingShiftNoteId AS '@ni'
			FOR XML PATH('z')
				,ROOT('r')
			)
	SET @LogDataOld = REPLACE(CONVERT(NVARCHAR(MAX), @Xml), '" />', '"/"')
	
	SET @LastUpdated = GETDATE()

	DELETE FROM dbo.[EmployeeWorkingShiftNote] WITH (ROWLOCK, UPDLOCK)
	WHERE EmployeeWorkingShiftNoteId = @EmployeeWorkingShiftNoteId
	
	SET @EndRun = GETDATE()
	SET @Duration = DATEDIFF(MILLISECOND, @StartRun, @EndRun)

	EXEC dbo.OWP_WriteLog @CreatorId = @ActorId
		,@SPName = 'OWP_EmployeeWorkingShift_DeleteNote'
		,@LoggedDate = @StartRun
		,@Duration = @Duration
		,@ObjectId = @UserId
		,@DataOld = @LogDataOld
END