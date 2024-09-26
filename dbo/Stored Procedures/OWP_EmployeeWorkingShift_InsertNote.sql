
/*<info serverAlias="DBOWP-bodb_OWP" executers="wsv_owp" isFunction="0"></info>*/
CREATE PROCEDURE [dbo].[OWP_EmployeeWorkingShift_InsertNote] @ActorId INT
	,@UserId INT
	,@ShiftDate DATETIME
	,@Note NVARCHAR(4000)	
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
		,@LogData NVARCHAR(MAX)
		,@Xml XML
		,@LastUpdated DATETIME
		,@NoteId INT

	SET @StartRun = GETDATE()
	SELECT @LastUpdated = GETDATE()

	INSERT INTO dbo.EmployeeWorkingShiftNote(UserId, CreatedDate, CreatedBy, Note, ShiftDate)
	VALUES (@UserId, @LastUpdated, @ActorId, @Note, @ShiftDate);
	SET @NoteId = SCOPE_IDENTITY()

	--New data
	SET @Xml = (
			SELECT @LastUpdated AS '@cd'
				,@ShiftDate AS '@sd'
				,@Note AS '@nt'
				,@NoteId AS '@ni'
			FOR XML PATH('z')
				,ROOT('r')
			)
	SET @LogData = REPLACE(CONVERT(NVARCHAR(MAX), @Xml), '" />', '"/"')
	SET @EndRun = GETDATE()
	SET @Duration = DATEDIFF(MILLISECOND, @StartRun, @EndRun)

	EXEC dbo.OWP_WriteLog @CreatorId = @ActorId
		,@SPName = 'OWP_EmployeeWorkingShift_InsertNote'
		,@LoggedDate = @StartRun
		,@Duration = @Duration
		,@ObjectId = @UserId
		,@Data = @LogData

	SELECT @NoteId  AS NoteId 

END