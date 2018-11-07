
/*<info serverAlias="DBOWP-bodb_OWP" executers="bodbOWPNet" isFunction="0"></info>*/
CREATE PROCEDURE [dbo].[OWP_EmployeeWorkingShift_QuickDelete_WorkingShiftColor] @Name NVARCHAR(50)
	,@ErrCode INT = 0 OUTPUT
	,@ErrMsg NVARCHAR(200) = '' OUTPUT
AS
/*    
 Created: 20181009@Kane.Le
 Task : Delete Shift Color [Redmine: #102867]
 DB: bodb_OWP
 
 Param's Explanation:
 @Name: '8 > 17'

 Revisions:
	 20181012@Kane.Le: Initial SP - [Redmine: #102867]
*/
BEGIN
	SET NOCOUNT ON;

	DELETE
	FROM EmployeeWorkingShiftColor
	WHERE NAME = LTRIM(RTRIM(@Name))

	SET @ErrCode = 0
	SET @ErrMsg = 'Ok'

	RETURN
END