
/*<info serverAlias="DBOWP-bodb_OWP" executers="bodbOWPNet" isFunction="0"></info>*/
CREATE PROCEDURE [dbo].[OWP_LiveGameAssignment_DetectMinorMatch] @LeagueName NVARCHAR(500)
	,@HomeName NVARCHAR(200)
	,@AwayName NVARCHAR(200)
	,@MinorBettypeId INT = NULL OUTPUT
	,@ParentMatchId INT = NULL OUTPUT
AS
/*
 Created: 20190903@Kane.Le
 Task : detect minor match
 DB: bodb_OWP

 Revisions:
	20190903@Kane.Le: Initial SP - [Feature: #117960]	
*/
BEGIN
	SET NOCOUNT ON;

	-- determine minor match
	CREATE TABLE #tblRuleChecking (
		MinorBettypeId INT
		,IsFalse INT
		);

	INSERT INTO #tblRuleChecking (
		MinorBettypeId
		,IsFalse
		)
	SELECT mmd.MinorBettypeId
		,CASE 
			WHEN mmd.[Condition] = 1
				AND mmd.Field = 1
				AND @LeagueName LIKE '%' + mmd.[Value] + '%'
				THEN 0
			WHEN mmd.[Condition] = 2
				AND mmd.Field = 1
				AND @LeagueName NOT LIKE '%' + mmd.[Value] + '%'
				THEN 0
			WHEN mmd.[Condition] = 1
				AND mmd.Field = 2
				AND @HomeName LIKE '%' + mmd.[Value] + '%'
				THEN 0
			WHEN mmd.[Condition] = 2
				AND mmd.Field = 2
				AND @HomeName NOT LIKE '%' + mmd.[Value] + '%'
				THEN 0
			WHEN mmd.[Condition] = 1
				AND mmd.Field = 3
				AND @AwayName LIKE '%' + mmd.[Value] + '%'
				THEN 0
			WHEN mmd.[Condition] = 2
				AND mmd.Field = 3
				AND @AwayName NOT LIKE '%' + mmd.[Value] + '%'
				THEN 0
			ELSE 1
			END
	FROM dbo.MinorMatchDetemination AS mmd WITH (NOLOCK)
	WHERE mmd.Field IN (
			1
			,2
			,3
			);

	SELECT @MinorBettypeId = MinorBettypeId
	FROM #tblRuleChecking WITH (NOLOCK)
	GROUP BY MinorBettypeId
	HAVING SUM(IsFalse) = 0;

	DROP TABLE #tblRuleChecking;
END;