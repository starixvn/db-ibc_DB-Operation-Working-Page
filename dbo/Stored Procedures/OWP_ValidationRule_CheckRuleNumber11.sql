/*<info serverAlias="DBOWP-bodb_OWP" executers="wsv_owp" isFunction="0"></info>*/
CREATE PROCEDURE [dbo].[OWP_ValidationRule_CheckRuleNumber11]
	@SessionId VARCHAR(50) = ''
	,@OWPMatchId INT = NULL
	,@Value NVARCHAR(4000) = NULL
AS
/*
 Created: 20170213@Tim.Trinh
 Task : Rule number 11: Duplicate trader
 DB: bodb_OWP

 Revisions:
    20170407@Tim.Trinh: remove check data in bodb02
	20180416@leo.vo: add FM, AIO
	20180723@Raymond.Le: Modify rule follow new uploading structure - [Redmine: #92868] 
	20181031@Raymond.Le: Replace column MatchId by InfoSiteMatchId - [Redmine: #104052]
	20190521@Leo.Vo: Add Username value - [Feature: #113765]
	20200830@Jacob: Delete unused code - [Redmine: #137757]
*/
BEGIN
	SET NOCOUNT ON

	DECLARE @RuleId SMALLINT = 11
		,@RuleResultType TINYINT
		,@Passed TINYINT
		,@Message NVARCHAR(MAX)
		,@MatchLengthToTrade SMALLINT
		,@MaxTradingMatchesSameTime TINYINT
		,@NextCorners INT = - 4
		,@NoOfCorners INT = - 3
		,@Specific15MinsNoOfCorners INT = - 5
		,@LastCorners INT = - 90
		,@HomeSingleTeamOUOfCorners INT = - 94
		,@AwaySingleTeamOUOfCorners INT = - 95
		-----
		,@idoc INT
		,@Username NVARCHAR(30)
		,@Bettype INT
		,@UserId INT
		,@EventDateTime DATETIME
		,@ParentMatchId INT
		,@MinorBettypeId INT
		,@MainAssignment TINYINT = 1
		,@BettypeLA INT = - 1002

	CREATE TABLE #tblCornerBettype (Bettype INT)

	CREATE TABLE #tblAssignmentInfo (
		OWPMatchId INT
		,owpEventDate DATETIME
		,Home NVARCHAR(200)
		,Away NVARCHAR(200)
		,UserId INT
		,MinorMatchId INT NULL
		,ParentMatchId INT NULL
		,MinorBettypeId INT NULL
		,MinorBettypeName NVARCHAR(100)
		)

	CREATE TABLE #tblAssignmentUploading (
		RowNumber INT
		,owpEventDate DATETIME NULL
		,UserId INT
		,Trader NVARCHAR(100)
		,IsViolated BIT
		,MinorBettypeId INT NULL
		,ParentRowNumber INT NULL
		)

	CREATE TABLE #tblCountMatchTrading (
		RowNumber INT
		,OtherRowNumber NVARCHAR(MAX)
		,UserId INT
		,Trader NVARCHAR(100)
		,IsViolated BIT
		,Total INT
		)

	CREATE TABLE #tblMatchDuplicateTrader (
		RowNumber INT
		,OtherRowNumber NVARCHAR(MAX)
		,Trader NVARCHAR(100)
		,MatchName NVARCHAR(MAX)
		)

	CREATE TABLE #tblCombineMatchDuplicate (
		RowNumber INT
		,OtherRowNumber NVARCHAR(MAX)
		,Trader NVARCHAR(100)
		)

	CREATE TABLE #tblCombineTraderDuplicate (
		RowNumber INT
		,Result NVARCHAR(MAX)
		)

	SELECT @RuleResultType = RuleResultType
		,@Message = MessageFormat
	FROM dbo.ValidationRule WITH (NOLOCK)
	WHERE RuleId = @RuleId

	SELECT @Passed = ResourceId
	FROM dbo.RefResource WITH (NOLOCK)
	WHERE RefName = 'RuleResultType'
		AND [Value] = 'Passed'

	SELECT @MatchLengthToTrade = [Value]
	FROM dbo.RefResource WITH (NOLOCK)
	WHERE RefName = 'MatchLengthToTrade'

	SELECT @MaxTradingMatchesSameTime = [Value]
	FROM dbo.RefResource WITH (NOLOCK)
	WHERE RefName = 'MaxTradingMatchesSameTime'

	INSERT INTO #tblCornerBettype
	VALUES (@NextCorners)
		,(@NoOfCorners)
		,(@Specific15MinsNoOfCorners)
		,(@LastCorners)
		,(@HomeSingleTeamOUOfCorners)
		,(@AwaySingleTeamOUOfCorners)

	-- edit
	BEGIN
		EXEC sp_xml_preparedocument @idoc OUTPUT
			,@Value

		SELECT TOP 1 @UserId = data.UserId
			,@Bettype = data.Bettype
		FROM OPENXML(@idoc, '/Root/Row', 1) WITH (Bettype INT, UserId INT) AS data

		EXEC sp_xml_removedocument @idoc

		SELECT @EventDateTime = DATEADD(dd, DATEDIFF(dd, 0, EventDate), CAST(KickOffTime AS DATETIME))
			,@ParentMatchId = mm.ParentMatchId
			,@MinorBettypeId = mm.MinorBettypeId
		FROM dbo.OWPMatch AS om WITH (NOLOCK)
			LEFT JOIN dbo.MinorMatch AS mm WITH (NOLOCK) ON om.OWPMatchId = mm.MinorMatchId
		WHERE OWPMatchId = @OWPMatchId

		-- Get Match duplicate
		INSERT INTO #tblAssignmentInfo (
			OWPMatchId
			,owpEventDate
			,UserId
			,MinorMatchId
			,ParentMatchId
			,MinorBettypeId
			,MinorBettypeName
			)
		SELECT om.OWPMatchId
			,DATEADD(dd, DATEDIFF(dd, 0, om.EventDate), CAST(om.KickOffTime AS DATETIME))
			,a.UserId
			,minor.MinorMatchId
			,minor.ParentMatchId
			,minor.MinorBettypeId
			,CASE 
				WHEN minor.MinorBettypeId IS NOT NULL THEN 'bettype: ' + mib.MinorBettypeName
				ELSE 'bettype: ' + mab.ShortName
				END
		FROM dbo.OWPMatch AS om WITH (NOLOCK)
			INNER JOIN dbo.Assignment AS a WITH (NOLOCK) ON om.OWPMatchId = a.OWPMatchId
			LEFT JOIN dbo.MinorMatch AS minor WITH (NOLOCK) ON om.OWPMatchId = minor.MinorMatchId
			LEFT JOIN dbo.MinorBettype AS mib WITH (NOLOCK) ON mib.ParentBettypeId = minor.MinorBettypeId
			AND mib.InheritedBettypeId = a.Bettype
			LEFT JOIN dbo.MajorBettype AS mab WITH (NOLOCK) ON mab.BettypeId = a.Bettype
		WHERE om.OWPMatchId <> @OWPMatchId
			AND a.UserId = @UserId
			AND a.AssignmentType = @MainAssignment
			AND a.Bettype <> @BettypeLA
			AND DATEADD(dd, DATEDIFF(dd, 0, om.EventDate), CAST(om.KickOffTime AS DATETIME)) BETWEEN DATEADD(MINUTE, - 1 * @MatchLengthToTrade, @EventDateTime)
				AND DATEADD(MINUTE, @MatchLengthToTrade, @EventDateTime)
			AND (
				(
					ISNULL(@ParentMatchId, 0) = 0
					AND (
						@OWPMatchId <> ISNULL(minor.ParentMatchId, 0)
						OR (
							@OWPMatchId = ISNULL(minor.ParentMatchId, 0)
							AND minor.MinorBettypeId IN (
								SELECT Bettype
								FROM #tblCornerBettype
								)
							)
						)
					)
				OR (
					@ParentMatchId IS NOT NULL
					AND minor.ParentMatchId IS NOT NULL
					AND (
						@ParentMatchId <> ISNULL(minor.ParentMatchId, 0)
						OR (
							@ParentMatchId = ISNULL(minor.ParentMatchId, 0)
							AND minor.MinorBettypeId IN (
								SELECT Bettype
								FROM #tblCornerBettype
								)
							)
						)
					)
				OR (
					ISNULL(minor.ParentMatchId, 0) = 0
					AND (
						om.OWPMatchId <> ISNULL(@ParentMatchId, 0)
						OR (
							om.OWPMatchId = ISNULL(@ParentMatchId, 0)
							AND @MinorBettypeId IN (
								SELECT Bettype
								FROM #tblCornerBettype
								)
							)
						)
					)
				OR (
					minor.ParentMatchId IS NOT NULL
					AND @ParentMatchId IS NOT NULL
					AND (
						minor.ParentMatchId <> ISNULL(@ParentMatchId, 0)
						OR (
							minor.ParentMatchId = ISNULL(@ParentMatchId, 0)
							AND @MinorBettypeId IN (
								SELECT Bettype
								FROM #tblCornerBettype
								)
							)
						)
					)
				)

		-- Set match home, away name = home, away name of parent match
		UPDATE ai
		SET ai.Home = home.OWPTeamName
			,ai.Away = away.OWPTeamName
		FROM #tblAssignmentInfo AS ai
			LEFT JOIN dbo.OWPMatch AS om WITH (NOLOCK) ON om.OWPMatchId = ISNULL(ai.ParentMatchId, ai.OWPMatchId)
			LEFT JOIN dbo.OWPTeam AS home WITH (NOLOCK) ON om.OWPHomeId = home.OWPTeamId
			LEFT JOIN dbo.OWPTeam AS away WITH (NOLOCK) ON om.OWPAwayId = away.OWPTeamId

		IF (
				SELECT COUNT(1)
				FROM #tblAssignmentInfo WITH (NOLOCK)
				GROUP BY UserId
				) > @MaxTradingMatchesSameTime - 1
		BEGIN
			INSERT INTO #tblMatchDuplicateTrader (
				RowNumber
				,MatchName
				)
			SELECT 1
				,Home + ' -vs- ' + Away + ' - ' + MinorBettypeName
			FROM #tblAssignmentInfo WITH (NOLOCK)

			SELECT @RuleResultType AS ResultType
				,REPLACE(@Message, '<content>', STUFF((
							SELECT DISTINCT '; ' + MatchName
							FROM #tblMatchDuplicateTrader WITH (NOLOCK)
							WHERE RowNumber = 1
							FOR XML PATH('')
							), 1, 2, '')) AS [Message]
		END
		ELSE
		BEGIN
			SELECT @Passed AS ResultType
				,'' AS [Message]
		END
	END

	DROP TABLE #tblCornerBettype

	DROP TABLE #tblAssignmentInfo

	DROP TABLE #tblAssignmentUploading

	DROP TABLE #tblCountMatchTrading

	DROP TABLE #tblMatchDuplicateTrader

	DROP TABLE #tblCombineMatchDuplicate

	DROP TABLE #tblCombineTraderDuplicate
END