
/*<info serverAlias="DBOWP-bodb_OWP" executers="bodbOWPNet" isFunction="0"></info>*/
CREATE PROCEDURE [dbo].[OWP_EmployeeWorkingShift_QuickDelete_WorkingShiftColor] @ShiftId NVARCHAR(50)
AS
/*    
 Created: 20181009@Kane.Le
 Task : Delete Shift Color [Redmine: #102867]
 DB: bodb_OWP

 Revisions:
	 20181012@Kane.Le: Initial SP - [Redmine: #102867]
	 20190123@Leo.Vo: New schema of WS - [Redmine: #108206]
*/
BEGIN
	SET NOCOUNT ON;

	DELETE
	FROM EmployeeWorkingShiftColor WITH (ROWLOCK)
	WHERE ShiftId = @ShiftId

END