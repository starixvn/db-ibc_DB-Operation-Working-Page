/*<info serverAlias="DBOWP-bodb_OWP" executers="bodbOWPNet" isFunction="0"></info>*/
CREATE PROCEDURE [dbo].[OWP_FilterInsert] @UserId INT = 0
	,@Name NVARCHAR(max)
	,@IsPublic BIT
	,@Details NVARCHAR(max)
	,@ErrCode INT = 0 OUTPUT
	,@ErrMsg NVARCHAR(200) = '' OUTPUT
AS
/*      
 Created: 20161220@Razor.Nguyen
 Task : Insert new filter  
 DB: bodb_OWP      
      
 Revisions:          
    20171101@Raymond.Le: remove @ColumnIds
	20181009@Raymond.Le: New structure of event assignment - [Redmine: #92868]
*/
BEGIN
	SET NOCOUNT ON

	DECLARE @StartRun DATETIME = GETDATE()
		,@EndRun DATETIME
		,@Duration INT
		,@LogMatchData NVARCHAR(MAX)
		,@Xml XML
		,@FilterDetail NVARCHAR(max)
		,@DocHandler INT
		,@FilterId INT

	CREATE TABLE #Detail (
		FieldId INT
		,Operator INT
		,Value NVARCHAR(max)
		)

	BEGIN TRY
		IF EXISTS (
				SELECT 1
				FROM dbo.Filter WITH (NOLOCK)
				WHERE [FilterName] = @Name
				)
		BEGIN
			SET @ErrCode = 5201

			RETURN
		END

		EXEC sp_xml_preparedocument @DocHandler OUTPUT
			,@Details;

		INSERT INTO #Detail (
			FieldId
			,Operator
			,Value
			)
		SELECT Data.FieldId
			,Data.Operator
			,Data.Value
		FROM OPENXML(@DocHandler, '/Root/Row', 1) WITH (FieldId INT, Operator INT, Value NVARCHAR(max)) AS Data

		EXEC sp_xml_removedocument @DocHandler

		INSERT INTO dbo.Filter
		VALUES (
			@Name
			,@UserId
			,@IsPublic
			)

		SET @FilterId = SCOPE_IDENTITY()

		INSERT INTO dbo.FilterDetail (
			FilterId
			,FieldId
			,Operator
			,Value
			)
		SELECT @FilterId
			,FieldId
			,Operator
			,Value
		FROM #Detail WITH (NOLOCK)

		SELECT @FilterDetail = COALESCE(@FilterDetail + ', ', '') + CAST(FieldId AS NVARCHAR) + '###' + CAST(Operator AS NVARCHAR) + '###' + Value
		FROM #Detail WITH (NOLOCK)

		SET @Xml = (
				SELECT @Name AS '@fname'
					,@UserId AS '@us'
					,@IsPublic AS '@isp'
					,@FilterDetail AS '@con'
				FOR XML PATH('z')
					,ROOT('r')
				)
		SET @LogMatchData = REPLACE(CONVERT(NVARCHAR(MAX), @Xml), '" />', '"/"')
		SET @EndRun = GETDATE()
		SET @Duration = DATEDIFF(MILLISECOND, @StartRun, @EndRun)

		EXEC dbo.OWP_WriteLog @CreatorId = @UserId
			,@SPName = 'OWP_FilterInsert'
			,@LoggedDate = @StartRun
			,@Duration = @Duration
			,@ObjectId = @FilterId
			,@Data = @LogMatchData
			,@DataOld = NULL
	END TRY

	BEGIN CATCH
		SELECT @ErrCode = 5202

		RETURN
	END CATCH

	DROP TABLE #Detail
END