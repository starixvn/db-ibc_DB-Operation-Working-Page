/*<info serverAlias="DBOWP-bodb_OWP" executers="bodbOWPNet" isFunction="0"></info>*/
CREATE PROCEDURE [dbo].[OWP_EmployeeWorkingShift_UpdateNote] @UserId INT
	,@Note NVARCHAR(200) = NULL
AS
/*    
 Created: 20180312@Leo
 Task : Add working shift note
 DB: bodb_OWP

 Revisions:
	20181009@Raymond.Le: new structure
*/
BEGIN
	SET NOCOUNT ON;

	IF EXISTS (
			SELECT 1
			FROM EmployeeWorkingShiftNote
			WHERE UserId = @UserId
			)
	BEGIN
		UPDATE dbo.EmployeeWorkingShiftNote WITH (ROWLOCK, UPDLOCK)
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
END