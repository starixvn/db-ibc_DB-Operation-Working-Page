
/*<info serverAlias="DBOWP-bodb_OWP" executers="bodbOWPNet" isFunction="0"></info>*/
CREATE PROCEDURE [dbo].[OWP_EmployeeWorkingShift_QueryWeeklyBySection]
	 @SectionId VARCHAR(200)
	,@FromDate DATE
	,@ToDate DATE
AS
/*      
 Created: 20191024@carlos.nguyen
 Task : Public working shift
 DB: bodb_OWP      
 
 Revisions:
     20191024@carlos.nguyen Initial SP  - [Redmine: #122661]
*/

BEGIN
	DECLARE @UserIds VARCHAR(200);
	
	SELECT @UserIds = ISNULL(STUFF((
					SELECT ', ' + CAST(u.UserId AS NVARCHAR)
					FROM dbo.[User] AS u WITH (NOLOCK)
					WHERE u.SectionId = @SectionId
					FOR XML PATH('')
					), 1, 2, ''), '')
	EXEC dbo.OWP_EmployeeWorkingShift_QueryWeeklyByUser @UserIds=@UserIds,@FromDate=@FromDate,@ToDate=@ToDate
END