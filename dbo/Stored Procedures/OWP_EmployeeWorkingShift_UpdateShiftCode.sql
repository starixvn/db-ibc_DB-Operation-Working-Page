/*<info serverAlias="DBOWP-bodb_OWP" executers="bodbOWPNet" isFunction="0"></info>*/
CREATE PROCEDURE [dbo].[OWP_EmployeeWorkingShift_UpdateShiftCode] @EmployeeId INT
	,@ShiftCode NVARCHAR(50)
	,@ShiftDate DATE
AS
/*    
 Created: 20180314@Kane.Le
 Task : Edit working shift by date
 DB: bodb_OWP
 
 Revisions: 
	20180312@Kane: Edit working shift by date
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
		WHERE EmployeeId = @EmployeeId
			AND ShiftDate = @ShiftDate
	END
	ELSE
	BEGIN
		INSERT INTO dbo.EmployeeWorkingShift (
			EmployeeId
			,ShiftCode
			,ShiftDate
			)
		VALUES (
			@EmployeeId
			,@ShiftCode
			,@ShiftDate
			);
	END
END