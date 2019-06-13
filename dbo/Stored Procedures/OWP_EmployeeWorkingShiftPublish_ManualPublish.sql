
/*<info serverAlias="DBOWP-bodb_OWP" executers="bodbOWPNet" isFunction="0"></info>*/
CREATE PROCEDURE [dbo].[OWP_EmployeeWorkingShiftPublish_ManualPublish] @ActorId INT
	,@SectionId INT
	,@FromDate DATE
	,@ToDate DATE
	,@IsPublished BIT = 0
AS
/*    
 Created: 20190530@Kane.Le
 Task : Publish working shift
 DB: bodb_OWP

 Revisions:
	20190530@Kane.Le: Initial SP - [Redmine: #110322]	
*/
BEGIN
	SET NOCOUNT ON;

	DECLARE @StartRun DATETIME
		,@EndRun DATETIME
		,@Duration INT
		,@LogData NVARCHAR(MAX)
		,@LogDataOld NVARCHAR(MAX)
		,@OldSectionId INT
		,@OldFromDate DATE
		,@OldToDate DATE
		,@OldIsPublished BIT
		,@OldLastPublishedById INT
		,@OldLastPublishedDate DATE
		 
		,@Xml XML

	SET @StartRun = GETDATE()

	SELECT TOP 1 @OldSectionId = o.SectionId
		,@OldFromDate = o.FromDate
		,@OldToDate = o.ToDate
		,@OldIsPublished = o.IsPublished
		,@OldLastPublishedById = o.LastPublishedById
		,@OldLastPublishedDate = o.LastPublishedDate
	FROM dbo.EmployeeWorkingShiftPublish AS o WITH (NOLOCK)
	WHERE o.SectionId = @SectionId
		AND o.FromDate = @FromDate
		AND o.ToDate = @ToDate

	SET @Xml = (
			SELECT @OldSectionId AS '@sid'
				,@OldFromDate AS '@frd'
				,@OldToDate AS '@tod'
				,@OldIsPublished AS '@isp'
				,@OldLastPublishedById AS '@uid'
				,@OldLastPublishedDate AS '@lad'
			FOR XML PATH('z')
				,ROOT('r')
			)
	SET @LogDataOld = REPLACE(CONVERT(NVARCHAR(MAX), @Xml), '" />', '"/"')

	UPDATE dbo.EmployeeWorkingShiftPublish
	WITH (ROWLOCK)

	SET SectionId = @SectionId
		,IsPublished = @IsPublished
		,LastPublishedById = @ActorId
		,LastPublishedDate = GETDATE()
	WHERE SectionId = @SectionId
		AND FromDate = @FromDate
		AND ToDate = @ToDate

	IF @@ROWCOUNT = 0
	BEGIN
		-- insert
		SET @IsPublished = 1

		INSERT INTO dbo.EmployeeWorkingShiftPublish (
			SectionId
			,FromDate
			,ToDate
			,IsPublished
			,LastPublishedById
			,LastPublishedDate
			)
		VALUES (
			@SectionId
			,@FromDate
			,@ToDate
			,@IsPublished
			,@ActorId
			,GETDATE()
			)
	END

	SET @Xml = (
			SELECT @SectionId AS '@sid'
				,@FromDate AS '@frd'
				,@ToDate AS '@tod'
				,@IsPublished AS '@isp'
				,@ActorId AS '@uid'
				,GETDATE() AS '@lad'
			FOR XML PATH('z')
				,ROOT('r')
			)
	SET @LogData = REPLACE(CONVERT(NVARCHAR(MAX), @Xml), '" />', '"/"')
	SET @EndRun = GETDATE()
	SET @Duration = DATEDIFF(MILLISECOND, @StartRun, @EndRun)

	EXEC dbo.OWP_WriteLog @CreatorId = @ActorId
		,@SPName = 'OWP_EmployeeWorkingShiftPublish_Update'
		,@LoggedDate = @StartRun
		,@Duration = @Duration
		,@ObjectId = @SectionId
		,@Data = @LogData
		,@DataOld = @LogDataOld
END