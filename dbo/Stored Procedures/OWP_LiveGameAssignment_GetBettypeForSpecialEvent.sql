
/*<info serverAlias="DBOWP-bodb_OWP" executers="bodbOWPNet" isFunction="0"></info>*/
CREATE PROCEDURE [dbo].[OWP_LiveGameAssignment_GetBettypeForSpecialEvent] @ParentMatchId INT
AS
/*
Created: 2016-17-24@Carlos
Task : Get bettype for match info
DB: bodb_OWP

Revisions:
	20190724@Carlos: Initial SP - [Feature: #117461]
*/
BEGIN
	SELECT mb.MinorBettypeId
		,mb.MinorBettypeName
	FROM dbo.MinorBettype AS mb WITH (NOLOCK)
		LEFT JOIN (
		SELECT MinorBettypeId
		FROM dbo.MinorMatch WITH (NOLOCK)
		WHERE ParentMatchId = @ParentMatchId
		) AS mm ON mb.MinorBettypeId = mm.MinorBettypeId
	WHERE mb.IsActive = 1
		AND mb.ParentBettypeId IS NULL
		AND mb.MinorBettypeId NOT IN (- 1, - 2, - 5, - 8)
		AND mm.MinorBettypeId IS NULL
	ORDER BY (CASE WHEN mb.[Order] IS NULL THEN 9999999 ELSE mb.[Order] END) ASC, mb.MinorBettypeName ASC
END