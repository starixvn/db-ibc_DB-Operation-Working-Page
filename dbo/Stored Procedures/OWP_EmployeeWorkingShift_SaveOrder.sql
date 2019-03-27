
/*<info serverAlias="DBOWP-bodb_OWP" executers="bodbOWPNet" isFunction="0"></info>*/
CREATE PROCEDURE [dbo].[OWP_EmployeeWorkingShift_SaveOrder] @UserId INT
	,@SectionId INT
	,@EmployeeIds NVARCHAR(MAX)
AS
/*    
 Created: 20190321@Leo
 Task : Save working shift order
 DB: bodb_OWP

 Revisions:
	20190321@Leo.Vo: Initial SP - [Redmine: #110322]
*/
BEGIN
	SET NOCOUNT ON;

	DELETE dbo.EmployeeWorkingShiftOrder WITH (ROWLOCK)
	WHERE UserId = @UserId
		AND SectionId = @SectionId

	INSERT INTO dbo.EmployeeWorkingShiftOrder (
		UserId
		,SectionId
		,EmployeeId
		,OrderId
		)
	SELECT @UserId
		,@SectionId
		,val
		,ROW_NUMBER() OVER (
			ORDER BY (
					SELECT NULL
					)
			) AS OrderId
	FROM dbo.fnc_SplitStrings(@EmployeeIds, ',')
	OPTION (MAXRECURSION 0)
END