/*<info serverAlias="DBOWP-bodb_OWP" executers="bodbOWPNet" isFunction="0"></info>*/
CREATE PROCEDURE[dbo].[OWP_FilterDelete] @UserId INT
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
		,@Columns NVARCHAR(max)
		,@Detail NVARCHAR(max)
		,@FilterName NVARCHAR(max)
		,@CreatedBy INT
		,@IsPublic BIT

	SET @StartRun = GETDATE()

	BEGIN TRY
		IF (
				NOT EXISTS (
					SELECT 1
					FROM dbo.Filter AS f WITH (NOLOCK)
					WHERE f.FilterId = @FilterId
						AND f.CreatedBy = @UserId
					)
				)
		BEGIN
			SET @ErrCode = 5401

			RETURN
		END

		SELECT @Columns = COALESCE(@Columns + ', ', '') + CAST(ColumnId AS NVARCHAR)
		FROM dbo.FilterColumn WITH (NOLOCK)
		WHERE FilterId = @FilterId

		SELECT @Detail = COALESCE(@Detail + ', ', '') + CAST(FilterId AS NVARCHAR) + '###' + CAST(FieldId AS NVARCHAR) + '###' + cast(Operator AS NVARCHAR) + '###' + Value
		FROM dbo.[FilterDetail] WITH (NOLOCK)
		WHERE FilterId = @FilterId

		SELECT @FilterName = FilterName
			,@CreatedBy = CreatedBy
			,@IsPublic = IsPublic
		FROM dbo.Filter WITH (NOLOCK)

		SET @Xml = (
				SELECT @Filterid AS '@id'
					,@FilterName AS '@fname'
					,@CreatedBy AS '@cby'
					,@IsPublic AS '@isp'
					,@Columns AS '@col'
					,@Detail AS '@detail'
				FOR XML PATH('z')
					,ROOT('r')
				)
		SET @LogMatchData = REPLACE(CONVERT(NVARCHAR(MAX), @Xml), '" />', '"/"')

		DELETE
		FROM dbo.Filter
		WHERE CreatedBy = @UserId
			AND FilterId = @FilterId

		DELETE
		FROM dbo.FilterColumn
		WHERE FilterId = @FilterId

		DELETE
		FROM dbo.FilterDetail
		WHERE FilterId = @FilterId

		SET @EndRun = GETDATE()
		SET @Duration = DATEDIFF(MILLISECOND, @StartRun, @EndRun)

		EXEC dbo.OWP_WriteLog @CreatorId = @UserId
			,@SPName = 'OWP_FilterDelete'
			,@LoggedDate = @StartRun
			,@Duration = @Duration
			,@ObjectId = @FilterId
			,@Data = @LogMatchData
			,@DataOld = NULL
	END TRY

	BEGIN CATCH
		SELECT @ErrCode = 5402

		RETURN
	END CATCH
END