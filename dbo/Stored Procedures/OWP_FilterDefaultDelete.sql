/*<info serverAlias="DBOWP-bodb_OWP" executers="wsv_owp" isFunction="0"></info>*/
CREATE PROCEDURE[dbo].[OWP_FilterDefaultDelete] @UserId INT
	,@ErrCode INT = 0 OUTPUT
	,@ErrMsg NVARCHAR(200) = '' OUTPUT
AS
/*      
 ALTERd: 20161220@Razor.Nguyen
 Task : Delete default filter  
 DB: bodb_OWP      
      
 Revisions:          
	20181009@Raymond.Le: New structure of event assignment - [Redmine: #92868]
*/
BEGIN
	SET NOCOUNT ON

	DECLARE @StartRun DATETIME
		,@EndRun DATETIME
		,@Duration INT
		,@LogMatchData NVARCHAR(MAX)
		,@Xml XML
		,@FilterId INT

	SET @StartRun = GETDATE()

	BEGIN TRY
		SELECT TOP 1 @FilterId = f.Filterid
		FROM FilterUserDefault AS f WITH (NOLOCK)
		WHERE f.UserId = @UserId

		DELETE
		FROM dbo.FilterUserDefault
		WHERE UserId = @UserId

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
			,@SPName = 'OWP_FilterDefaultDelete'
			,@LoggedDate = @StartRun
			,@Duration = @Duration
			,@ObjectId = @FilterId
			,@Data = NULL
			,@DataOld = @LogMatchData
	END TRY

	BEGIN CATCH
		SELECT @ErrCode = 5601

		RETURN
	END CATCH
END