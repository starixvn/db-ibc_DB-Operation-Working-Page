/*<info serverAlias="DBOWP-bodb_OWP" executers="bodbOWPNet" isFunction="0"></info>*/
CREATE PROCEDURE [dbo].[OWP_LeagueOption_Insert] @OptionId INT OUTPUT
	,@Name NVARCHAR(100) = ''
	,@CategoryId INT
	,@UserId INT
	,@ErrCode INT = 0 OUTPUT
	,@ErrMsg NVARCHAR(200) = '' OUTPUT
AS
/*
Created: 20170301@Tim.Trinh
Task : insert league option
DB: bodb_OWP

Revisions:
	20181009@Raymond.Le: New structure of event assignment - [Redmine: #92868]
   
*/
BEGIN
	SET NOCOUNT ON
	
	DECLARE @MaxOption INT = 30

	DECLARE @OptId INT
		,@StartRun DATETIME
		,@EndRun DATETIME
		,@Duration INT
		,@LogData NVARCHAR(MAX)
		,@Xml XML
		,@Value INT

	SELECT @Value = ISNULL(MAX(Value), 1) + 1
	FROM dbo.LeagueOption WITH (NOLOCK)
	
	IF @Value > @MaxOption
	BEGIN
	   SELECT @ErrMsg = 'Can not add more option.'
			,@ErrCode = 5903 -- ActionId + 01

		RETURN
	END

	IF EXISTS (
			SELECT 1
			FROM dbo.LeagueOption WITH (NOLOCK)
			WHERE [Name] = @Name
			)
	BEGIN
		SELECT @ErrMsg = 'The option name already exists.'
			,@ErrCode = 5901 -- ActionId + 01

		RETURN
	END

	BEGIN TRY
		SET @StartRun = GETDATE()

		INSERT INTO dbo.LeagueOption (
			[Name]
			,CategoryId
			,Value
			)
		VALUES (
			@Name
			,@CategoryId
			,@Value
			)

		SELECT @OptId = SCOPE_IDENTITY()

		SELECT @OptionId = POWER(2, @Value)

		-- write log
		SET @Xml = (
				SELECT @OptId AS '@opt'
					,@Name AS '@n'
					,@CategoryId AS '@c'
					,@Value AS '@vl'
				FOR XML PATH('z')
					,ROOT('r')
				)
		SET @LogData = REPLACE(CONVERT(NVARCHAR(MAX), @Xml), '" />', '"/"')
		SET @EndRun = GETDATE()
		SET @Duration = DATEDIFF(MILLISECOND, @StartRun, @EndRun)

		EXEC dbo.OWP_WriteLog @CreatorId = @UserId
			,@SPName = 'OWP_LeagueOption_Insert'
			,@LoggedDate = @StartRun
			,@Duration = @Duration
			,@ObjectId = @OptId
			,@Data = @LogData
			,@DataOld = NULL
	END TRY

	BEGIN CATCH
		SELECT @ErrMsg = 'Insert new option failed. Please try again.'
			,@ErrCode = 5902 -- ActionId + 01

		RETURN
	END CATCH
END