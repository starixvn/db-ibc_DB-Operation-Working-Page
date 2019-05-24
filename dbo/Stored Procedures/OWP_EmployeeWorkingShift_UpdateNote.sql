
/*<info serverAlias="DBOWP-bodb_OWP" executers="bodbOWPNet" isFunction="0"></info>*/
CREATE PROCEDURE [dbo].[OWP_EmployeeWorkingShift_UpdateNote] @ActorId INT
	,@UserId INT
	,@Note NVARCHAR(200) = NULL
AS
/*    
 Created: 20180312@Leo
 Task : Add working shift note
 DB: bodb_OWP

 Revisions:
	20181009@Leo.Vo: New structure of event assignment - [Redmine: #92868]
	20190521@Kane.Le: Write log - [Redmine: #113763]
*/
BEGIN	
	SET NOCOUNT ON;

	DECLARE @StartRun DATETIME
		,@EndRun DATETIME
		,@Duration INT
		,@LogDataOld NVARCHAR(MAX)
		,@LogData NVARCHAR(MAX)
		,@Xml XML

	SET @StartRun = GETDATE()
	SET @Xml = (
			SELECT @UserId AS '@uid'
				,nt.Note AS '@no'
			FROM EmployeeWorkingShiftNote nt WITH (NOLOCK)
			WHERE nt.UserId = @UserId
			FOR XML PATH('z')
				,ROOT('r')
			)
	SET @LogDataOld = REPLACE(CONVERT(NVARCHAR(MAX), @Xml), '" />', '"/"')


	IF EXISTS (
			SELECT 1
			FROM EmployeeWorkingShiftNote
			WHERE UserId = @UserId
			)
	BEGIN
		UPDATE dbo.EmployeeWorkingShiftNote
		WITH (
				ROWLOCK
				,UPDLOCK
				)

		SET Note = @Note
		WHERE UserId = @UserId
	END
	ELSE
	BEGIN
		INSERT INTO dbo.EmployeeWorkingShiftNote (
			UserId
			,Note
			)
		VALUES (
			@UserId
			,@Note
			);
	END

	--New data
	SET @Xml = (
			SELECT @UserId AS '@uid'
				,@Note AS '@no'
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
END