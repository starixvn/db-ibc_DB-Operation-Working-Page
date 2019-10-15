
/*<info serverAlias="DBOWP-bodb_OWP" executers="bodbOWPNet" isFunction="0"></info>*/
CREATE PROCEDURE [dbo].[OWP_UserRemark_Update] @ActorId INT
	,@UserId INT
	,@Category INT
	,@Remark NVARCHAR(200)
AS
/*    
 Created: 20191011@Leo
 Task : Add working shift remark
 DB: bodb_OWP

 Revisions:
	20191011@Leo.Vo: Initial SP - [Redmine: #121765]
*/
BEGIN	
	SET NOCOUNT ON;

	DECLARE @StartRun DATETIME
		,@EndRun DATETIME
		,@Duration INT
		,@OldRemark NVARCHAR(200)
		,@LogDataOld NVARCHAR(MAX)
		,@LogData NVARCHAR(MAX)
		,@Xml XML
		
	SELECT @OldRemark = Remark
	FROM dbo.UserRemark WITH (NOLOCK)
	WHERE UserId = @UserId AND Category = @Category
	
	SET @StartRun = GETDATE()
	SET @Xml = (
			SELECT @Category AS '@ca'
				,@OldRemark AS '@rm'
			FOR XML PATH('z')
				,ROOT('r')
			)
	SET @LogDataOld = REPLACE(CONVERT(NVARCHAR(MAX), @Xml), '" />', '"/"')
	
	UPDATE dbo.UserRemark WITH (ROWLOCK)
	SET Remark = @Remark
	WHERE UserId = @UserId AND Category = @Category
	
	IF @@ROWCOUNT = 0
	BEGIN
		INSERT INTO dbo.UserRemark (UserId, Category, Remark)
		VALUES (@UserId, @Category, @Remark);
	END

	--New data
	SET @Xml = (
			SELECT @Category AS '@ca'
				,@Remark AS '@rm'
			FOR XML PATH('z')
				,ROOT('r')
			)
	SET @LogData = REPLACE(CONVERT(NVARCHAR(MAX), @Xml), '" />', '"/"')
	SET @EndRun = GETDATE()
	SET @Duration = DATEDIFF(MILLISECOND, @StartRun, @EndRun)

	EXEC dbo.OWP_WriteLog @CreatorId = @ActorId
		,@SPName = 'OWP_EmployeeWorkingShift_UpdateRemark'
		,@LoggedDate = @StartRun
		,@Duration = @Duration
		,@ObjectId = @UserId
		,@Data = @LogData
		,@DataOld = @LogDataOld
END