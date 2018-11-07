
/*<info serverAlias="DBOWP-bodb_OWP" executers="bodbOWPNet" isFunction="0"></info>*/
CREATE PROCEDURE [dbo].[OWP_EmployeeWorkingShift_QuickInsert_WorkingShiftColor] @Name NVARCHAR(50)
	,@Background NVARCHAR(50)
	,@Color NVARCHAR(50)
	,@ErrCode INT = 0 OUTPUT
	,@ErrMsg NVARCHAR(200) = '' OUTPUT
AS
/*    
 Created: 20181009@Kane.Le
 Task : Insert Shift Color [Redmine: #102867]
 DB: bodb_OWP
 
 Param's Explanation:
 @Name: '8 > 17'
 @Background: '#3399cc'
 @Color: '#3399cc'
 
 Revisions:
	 20181012@Kane.Le: Initial SP - [Redmine: #102867]
*/
BEGIN
	SET NOCOUNT ON;

	IF EXISTS (
			SELECT 1
			FROM dbo.EmployeeWorkingShiftColor WITH (NOLOCK)
			WHERE NAME = LTRIM(RTRIM(@Name))
			)
	BEGIN
		SET @ErrCode = 1
		SET @ErrMsg = 'Shift existed'

		RETURN
	END
	ELSE
	BEGIN
		INSERT INTO dbo.EmployeeWorkingShiftColor (
			NAME
			,Background
			,Color
			)
		VALUES (
			UPPER(LTRIM(RTRIM(@Name)))
			,@Background
			,@Color
			);

		SET @ErrCode = 0
		SET @ErrMsg = 'Ok'

		RETURN
	END
END