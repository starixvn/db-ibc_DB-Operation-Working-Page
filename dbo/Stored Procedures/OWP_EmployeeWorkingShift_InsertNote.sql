
/*<info serverAlias="DBOWP-bodb_OWP" executers="bodbOWPNet" isFunction="0"></info>*/
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
			SELECT @UserId AS '@ui'
				,@LastUpdated AS '@cd'
				,@ShiftDate AS '@sd'
				,@Note AS '@nt'
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
		,@ObjectId = @NoteId
		,@Data = @LogData

	SELECT @NoteId  AS NoteId 

END