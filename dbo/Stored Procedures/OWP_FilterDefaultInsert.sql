CREATE PROCEDURE[dbo].[OWP_FilterDefaultInsert] @UserId INT
	,@FilterId INT
	,@ErrCode INT = 0 OUTPUT
	,@ErrMsg NVARCHAR(200) = '' OUTPUT
AS
/*      
 ALTERd: 20161220@Razor.Nguyen
 Task : Insert new filter  
 DB: bodb_OWP      
      
 Revisions:          
 
*/
BEGIN
	SET NOCOUNT ON

	DECLARE @StartRun DATETIME
		,@EndRun DATETIME
		,@Duration INT
		,@LogMatchData NVARCHAR(MAX)
		,@Xml XML

	SET @StartRun = GETDATE()

	BEGIN TRY
		IF (
				NOT EXISTS (
					SELECT 1
					FROM dbo.Filter AS f WITH (NOLOCK)
					WHERE f.FilterId = @FilterId
						AND (
							f.CreatedBy = @UserId
							OR (
								f.CreatedBy <> @UserId
								AND f.IsPublic = 1
								)
							)
					)
				)
		BEGIN
			SET @ErrCode = 5501

			RETURN
		END

		DELETE
		FROM dbo.FilterUserDefault
		WHERE UserId = @UserId

		INSERT INTO dbo.FilterUserDefault (
			FilterId
			,UserId
			)
		VALUES (
			@FilterId
			,@UserId
			)

		SET @Xml = (
				SELECT @FilterId AS 'id'
					,@UserId AS 'us'
				FOR XML PATH('z')
					,ROOT('r')
				)
		SET @LogMatchData = REPLACE(CONVERT(NVARCHAR(MAX), @Xml), '" />', '"/"')
		SET @EndRun = GETDATE()
		SET @Duration = DATEDIFF(MILLISECOND, @StartRun, @EndRun)

		EXEC dbo.OWP_WriteLog @CreatorId = @UserId
			,@SPName = 'OWP_FilterDefaultInsert'
			,@LoggedDate = @StartRun
			,@Duration = @Duration
			,@ObjectId = @FilterId
			,@Data = @LogMatchData
			,@DataOld = NULL
	END TRY

	BEGIN CATCH
		SELECT @ErrCode = 5502

		RETURN
	END CATCH
END