/*<info serverAlias="DBOWP-bodb_OWP" executers="bodbOWPNet" isFunction="0"></info>*/
CREATE PROCEDURE [dbo].[OWP_EmployeeWorkingShift_UpdateShiftCode] @EmployeeId INT
	,@ShiftCode NVARCHAR(50)
	,@ShiftDate DATE
	,@ShiftStartTime DATETIME = NULL
	,@ShiftEndTime DATETIME = NULL
AS
/*    
 Created: 20180914@Kane.Le
 Task : Edit working shift by date
 DB: bodb_OWP
 
Revisions:
	20181009@Raymond.Le: new structure
*/
BEGIN
	SET NOCOUNT ON;

	IF EXISTS (
			SELECT 1
			FROM dbo.EmployeeWorkingShift WITH (NOLOCK)
			WHERE EmployeeId = @EmployeeId				
				AND ShiftDate = @ShiftDate
			)
	BEGIN
		UPDATE dbo.EmployeeWorkingShift WITH (ROWLOCK, UPDLOCK)
		SET ShiftCode = @ShiftCode
			,ShiftStartTime = @ShiftStartTime
			,ShiftEndTime = @ShiftEndTime
		WHERE EmployeeId = @EmployeeId
			AND ShiftDate = @ShiftDate
	END
	ELSE
	BEGIN
		INSERT INTO dbo.EmployeeWorkingShift (
			EmployeeId
			,ShiftCode
			,ShiftDate
			,ShiftStartTime
			,ShiftEndTime
			)
		VALUES (
			@EmployeeId
			,@ShiftCode
			,@ShiftDate
			,@ShiftStartTime
			,@ShiftEndTime
			);
	END
END