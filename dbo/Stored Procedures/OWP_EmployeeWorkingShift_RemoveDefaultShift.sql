
/*<info serverAlias="DBOWP-bodb_OWP" executers="bodbOWPNet" isFunction="0"></info>*/
CREATE PROCEDURE [dbo].[OWP_EmployeeWorkingShift_RemoveDefaultShift] @EmployeeId INT
	,@DayOfTheWeek INT
AS
/*    
 Created: 20190225@Leo.Vo
 Task : Remove default working shift
 DB: bodb_OWP
 
Revisions:
	20190215@Leo.Vo: Initial SP - [Redmine: #108723]
*/
BEGIN
	SET NOCOUNT ON;

	DELETE dbo.EmployeeWorkingShiftDefault WITH (ROWLOCK)
	WHERE UserId = @EmployeeId
		AND DayOfTheWeek = @DayOfTheWeek
END