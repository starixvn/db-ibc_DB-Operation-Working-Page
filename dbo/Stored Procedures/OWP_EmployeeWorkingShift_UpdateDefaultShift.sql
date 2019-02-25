/*<info serverAlias="DBOWP-bodb_OWP" executers="bodbOWPNet" isFunction="0"></info>*/
CREATE PROCEDURE [dbo].[OWP_EmployeeWorkingShift_UpdateDefaultShift] @EmployeeId INT
	,@ShiftId INT
	,@DayOfTheWeek INT
AS
/*    
 Created: 20190225@Leo.Vo
 Task : Update default working shift
 DB: bodb_OWP
 
Revisions:
	20190215@Leo.Vo: Initial SP - [Redmine: #108723]
*/
BEGIN
	SET NOCOUNT ON;

	DECLARE @EmployeeWorkingShift TABLE (
		[EmployeeId] [int] NOT NULL
		,[ShiftId] [int] NOT NULL
		,[ShiftDate] [date] NOT NULL
		,[ShiftStartTime] [datetime] NULL
		,[ShiftEndTime] [datetime] NULL
		)

	UPDATE dbo.EmployeeWorkingShiftDefault WITH (ROWLOCK)
	SET ShiftId = @ShiftId
	WHERE UserId = @EmployeeId
		AND DayOfTheWeek = @DayOfTheWeek

	IF @@ROWCOUNT = 0
	BEGIN
		INSERT INTO dbo.EmployeeWorkingShiftDefault (
			UserId
			,DayOfTheWeek
			,ShiftId
			)
		VALUES (
			@EmployeeId
			,@DayOfTheWeek
			,@ShiftId
			)
	END

END