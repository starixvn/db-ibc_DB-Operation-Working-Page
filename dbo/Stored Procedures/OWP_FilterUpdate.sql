/*<info serverAlias="DBOWP-bodb_OWP" executers="bodbOWPNet" isFunction="0"></info>*/
CREATE PROCEDURE [dbo].[OWP_FilterUpdate] @UserId INT = 0
	,@FilterId INT = 0
	,@Details NVARCHAR(max)
	,@ErrCode INT = 0 OUTPUT
	,@ErrMsg NVARCHAR(200) = '' OUTPUT
AS
/*      
 Created: 20171207@Raymond.Le
 Task : Update Filter 
 DB: bodb_OWP      

 Revisions:
	20181009@Raymond.Le: new structure           
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
		---
		,@ActionInsert TINYINT = 1
		,@ActionUpdate TINYINT = 2
		,@ActionDelete TINYINT = 3

	CREATE TABLE #Detail (
		FieldId INT
		,Operator INT
		,Value NVARCHAR(max)
		,[Action] TINYINT
		)

	BEGIN TRY
		EXEC sp_xml_preparedocument @DocHandler OUTPUT
			,@Details;

		INSERT INTO #Detail (
			FieldId
			,Operator
			,Value
			,[Action]
			)
		SELECT Data.FieldId
			,Data.Operator
			,Data.Value
			,@ActionUpdate
		FROM OPENXML(@DocHandler, '/Root/Row', 1) WITH (FieldId INT, Operator INT, Value NVARCHAR(max)) AS Data

		EXEC sp_xml_removedocument @DocHandler

		-- INSERT field will remove
		INSERT INTO #Detail (
			FieldId
			,Operator
			,Value
			,[Action]
			)
		SELECT fd.FieldId
			,fd.Operator
			,fd.Value
			,@ActionDelete
		FROM dbo.FilterDetail AS fd 
		WHERE fd.FilterId = @FilterId
			AND fd.FieldId NOT IN (SELECT FieldId 
									FROM #Detail)

		-- update col action field will insert
		UPDATE d
		SET [Action] = @ActionInsert
		FROM #Detail AS d
		WHERE d.FieldId NOT IN (SELECT FieldId
								FROM dbo.FilterDetail
								WHERE FilterId = @FilterId)

		---------------------------------
		--- Update new value for field		
		UPDATE fd WITH (UPDLOCK, ROWLOCK)
		SET fd.Value = d.Value
		FROM dbo.FilterDetail AS fd
			LEFT JOIN #Detail AS d ON fd.FieldId = d.FieldId
								AND fd.Operator = d.Operator
		WHERE fd.FilterId = @FilterId
			AND d.[Action] = @ActionUpdate
		
		--- Delete field not exist in #Detail
		DELETE fd
		FROM dbo.FilterDetail AS fd  WITH (UPDLOCK, ROWLOCK)
			INNER JOIN #Detail AS d ON fd.FieldId = d.FieldId
		WHERE fd.FilterId = @FilterId
			AND d.[Action] = @ActionDelete

		--- Insert new field
		INSERT INTO dbo.FilterDetail (
			FilterId
			,FieldId
			,Operator
			,Value
		)
		SELECT 
			@FilterId
			,d.FieldId
			,d.Operator
			,d.Value
		FROM #Detail AS d
		WHERE d.[Action] = @ActionInsert


		SELECT @FilterDetail = COALESCE(@FilterDetail + ', ', '') + CAST(FieldId AS NVARCHAR) + '###' + CAST(Operator AS NVARCHAR) + '###' + Value
		FROM #Detail WITH (NOLOCK)

		SET @Xml = (
				SELECT @FilterId AS '@fid'
					,@UserId AS '@us'
					,@FilterDetail AS '@con'
				FOR XML PATH('z')
					,ROOT('r')
				)
		SET @LogMatchData = REPLACE(CONVERT(NVARCHAR(MAX), @Xml), '" />', '"/"')
		SET @EndRun = GETDATE()
		SET @Duration = DATEDIFF(MILLISECOND, @StartRun, @EndRun)

		EXEC dbo.OWP_WriteLog @CreatorId = @UserId
			,@SPName = 'OWP_FilterUpdate'
			,@LoggedDate = @StartRun
			,@Duration = @Duration
			,@ObjectId = @FilterId
			,@Data = @LogMatchData
			,@DataOld = NULL
	END TRY

	BEGIN CATCH
		SELECT @ErrCode = 5203

		RETURN
	END CATCH

	DROP TABLE #Detail
END
/*
GO
GRANT EXECUTE ON [dbo].[OWP_FilterUpdate] TO [bodbOWPNet]
GO

GRANT VIEW DEFINITION ON [dbo].[OWP_FilterUpdate] TO [bodbOWPNet]
GO
*/