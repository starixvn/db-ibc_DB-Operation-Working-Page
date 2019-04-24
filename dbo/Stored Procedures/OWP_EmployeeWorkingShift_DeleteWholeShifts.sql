
/*<info serverAlias="DBOWP-bodb_OWP" executers="bodbOWPNet" isFunction="0"></info>*/
CREATE PROCEDURE [dbo].[OWP_EmployeeWorkingShift_DeleteWholeShifts] @ActorId INT
	,@UserId INT
	,@FromDate DATE
	,@ToDate DATE
AS
/*      
 Created: 20190419@Lita.Tang
 Task : Delete whole shifts in week 
 DB: bodb_OWP  
   
Revisions:  
	20190419@Lita.Tang: Initial SP - [Redmine: #111840]  
*/
BEGIN
	SET NOCOUNT ON;

	DELETE dbo.EmployeeWorkingShift WITH (ROWLOCK, UPDLOCK)
	WHERE EmployeeId = @UserId
		AND ShiftDate BETWEEN @FromDate
			AND @ToDate
END