
/*<info serverAlias="DBOWP-bodb_OWP" executers="bodbOWPNet" isFunction="0"></info>*/
CREATE PROCEDURE [dbo].[OWP_EmployeeWorkingShift_ValidateBeforeDelete_WorkingShiftColor] @ShiftId NVARCHAR(50)
	,@ErrCode INT = 0 OUTPUT
	,@ErrMsg NVARCHAR(200) = '' OUTPUT
AS
/*    
 Created: 20181009@Kane.Le
 Task : Validate before Delete Shift Color [Redmine: #102867]
 DB: bodb_OWP
 
Revisions:
	 20181012@Kane.Le: Initial SP - [Redmine: #102867]
	 20190123@Leo.Vo: New schema of WS - [Redmine: #108206]
*/
BEGIN
	SET NOCOUNT ON;

	DECLARE @ShiftCode NVARCHAR(50)

	IF EXISTS (
			SELECT 1
			FROM dbo.EmployeeWorkingShift WITH (NOLOCK)
			WHERE ShiftId = @ShiftId
			)
	BEGIN
		SELECT @ShiftCode = ShiftCode
		FROM dbo.EmployeeWorkingShiftColor WITH (NOLOCK)
		WHERE ShiftId = @ShiftId

		SET @ErrCode = 1
		SET @ErrMsg = 'You cannot delete the assigned shift </br><b>' + UPPER(@ShiftCode) + '</b>'

		RETURN
	END
	ELSE
	BEGIN
		SET @ErrCode = 0
		SET @ErrMsg = 'Ok'

		RETURN
	END
END