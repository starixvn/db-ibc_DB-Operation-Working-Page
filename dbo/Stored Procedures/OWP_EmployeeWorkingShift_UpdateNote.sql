
/*<info serverAlias="DBOWP-bodb_OWP" executers="bodbOWPNet" isFunction="0"></info>*/
CREATE PROCEDURE [dbo].[OWP_EmployeeWorkingShift_UpdateNote] @ActorId INT
	,@EmployeeWorkingShiftNoteId INT
	,@Note NVARCHAR(4000)
AS
/*    
 Created: 20180312@Leo
 Task : Add working shift note
 DB: bodb_OWP

 Revisions:
	20181009@leo.vo: New structure of event assignment - [Redmine: #92868]
	20190521@kane.le: Write log - [Redmine: #113763]
	20191015@Tyler.Dang: Init SP - [Redmine: #121901]
*/
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

    DECLARE @StartRun DATETIME
		,@EndRun DATETIME
		,@Duration INT
		,@OldNote NVARCHAR(4000)
		,@OldCreatedDate DATETIME
		,@OldCreatedBy INT
		,@UserId INT
		,@LogDataOld NVARCHAR(MAX)
		,@LogData NVARCHAR(MAX)
		,@Xml XML
		,@LastUpdated DATETIME

	SELECT @OldNote = Note
		,@OldCreatedBy = CreatedBy
		,@OldCreatedDate = CreatedDate
		,@UserId = UserId
	FROM dbo.[EmployeeWorkingShiftNote] WITH (NOLOCK)
	WHERE EmployeeWorkingShiftNoteId = @EmployeeWorkingShiftNoteId
	
	SET @StartRun = GETDATE()
	SET @Xml = (
			SELECT @OldNote AS '@nt'
				,@OldCreatedDate AS '@cd'
				,@OldCreatedBy AS '@cb'
				,@EmployeeWorkingShiftNoteId AS '@ni'
			FOR XML PATH('z')
				,ROOT('r')
			)
	SET @LogDataOld = REPLACE(CONVERT(NVARCHAR(MAX), @Xml), '" />', '"/"')
	
	SET @LastUpdated = GETDATE()

	UPDATE dbo.[EmployeeWorkingShiftNote] WITH (ROWLOCK)
	SET Note = @Note
		,CreatedDate = @LastUpdated
		,CreatedBy = @ActorId
	WHERE EmployeeWorkingShiftNoteId = @EmployeeWorkingShiftNoteId
	
	--New data
	SET @Xml = (
			SELECT @Note AS '@nt'
				,@LastUpdated AS '@cd'
				,@ActorId AS '@cb'
				,@EmployeeWorkingShiftNoteId AS '@ni'
			FOR XML PATH('z')
				,ROOT('r')
			)
	SET @LogData = REPLACE(CONVERT(NVARCHAR(MAX), @Xml), '" />', '"/"')
	SET @EndRun = GETDATE()
	SET @Duration = DATEDIFF(MILLISECOND, @StartRun, @EndRun)

	EXEC dbo.OWP_WriteLog @CreatorId = @ActorId
		,@SPName = 'OWP_EmployeeWorkingShift_UpdateNote'
		,@LoggedDate = @StartRun
		,@Duration = @Duration
		,@ObjectId = @UserId
		,@Data = @LogData
		,@DataOld = @LogDataOld

	SELECT @EmployeeWorkingShiftNoteId AS NoteId
END