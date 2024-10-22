
/*<info serverAlias="DBOWP-bodb_OWP" executers="wsv_owp" isFunction="0"></info>*/
CREATE PROCEDURE [dbo].[OWP_EmployeeWorkingShiftDefault_QueryByUser] @UserIds VARCHAR(MAX)
AS
/*      
 Created: 20190531@leo.vo  
 Task : Working Shift Management
 DB: bodb_OWP      
 
 Revisions:
	 20190531@Leo.Vo: Initial SP [Redmine: #114442]
*/
BEGIN
	SET NOCOUNT ON;

	DECLARE @tblUser TABLE (UserId INT)

	INSERT INTO @tblUser (UserId)
	SELECT t.val
	FROM dbo.fnc_SplitStrings(@UserIds, ',') AS t
	OPTION (MAXRECURSION 0)

	SELECT s.UserId
		,s.DayOfTheWeek
		,s.ShiftId
	FROM dbo.EmployeeWorkingShiftDefault AS s WITH (NOLOCK)
		INNER JOIN @tblUser AS u ON s.UserId = u.UserId
END;