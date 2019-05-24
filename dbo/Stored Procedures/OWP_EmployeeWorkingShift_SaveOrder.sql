/*<info serverAlias="DBOWP-bodb_OWP" executers="bodbOWPNet" isFunction="0"></info>*/
CREATE PROCEDURE [dbo].[OWP_EmployeeWorkingShift_SaveOrder] @ActorId INT
	,@UserId INT
	,@SectionId INT
	,@EmployeeIds NVARCHAR(MAX)
AS
/*    
 Created: 20190321@Leo
 Task : Save working shift order
 DB: bodb_OWP

 Revisions:
	20190321@Leo.Vo: Initial SP - [Redmine: #110322]
	20190520@Leo.Vo: Write log - [Redmine: #113763]
*/
BEGIN
	SET NOCOUNT ON;

	DECLARE @StartRun DATETIME
		,@EndRun DATETIME
		,@Duration INT
		,@LogData NVARCHAR(MAX)
		,@LogDataOld NVARCHAR(MAX)
		,@Xml XML

	SET @StartRun = GETDATE()
	SET @Xml = (
			SELECT @UserId AS '@uid'
				,(
					STUFF((
							SELECT ',' + CAST(EmployeeId AS NVARCHAR(30))
							FROM dbo.EmployeeWorkingShiftOrder WITH (NOLOCK)
							WHERE UserId = @UserId
								AND SectionId = @SectionId
							ORDER BY OrderId
							FOR XML PATH('')
							), 1, 1, '')
					) AS '@eids'
			FOR XML PATH('z')
				,ROOT('r')
			)
	SET @LogDataOld = REPLACE(CONVERT(NVARCHAR(MAX), @Xml), '" />', '"/"')

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

	-- write log
	SET @Xml = (
			SELECT @UserId AS '@uid'
				,@EmployeeIds AS '@eids'
			FOR XML PATH('z')
				,ROOT('r')
			)
	SET @LogData = REPLACE(CONVERT(NVARCHAR(MAX), @Xml), '" />', '"/"')
	SET @EndRun = GETDATE()
	SET @Duration = DATEDIFF(MILLISECOND, @StartRun, @EndRun)

	EXEC dbo.OWP_WriteLog @CreatorId = @ActorId
		,@SPName = 'OWP_EmployeeWorkingShift_SaveOrder'
		,@LoggedDate = @StartRun
		,@Duration = @Duration
		,@ObjectId = @SectionId
		,@Data = @LogData
		,@DataOld = @LogDataOld
END