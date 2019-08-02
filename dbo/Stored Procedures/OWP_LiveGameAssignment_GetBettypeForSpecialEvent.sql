
/*<info serverAlias="DBOWP-bodb_OWP" executers="bodbOWPNet" isFunction="0"></info>*/
CREATE PROCEDURE [dbo].[OWP_LiveGameAssignment_GetBettypeForSpecialEvent]
AS
/*
Created: 2016-17-24@Carlos
Task : Get bettype for match info
DB: bodb_OWP

Revisions:
	20190724@Carlos: Initial SP - [Feature: #117461]
*/
BEGIN
	SELECT m.MinorBettypeId
		,m.MinorBettypeName
	FROM dbo.MinorBettype m WITH (NOLOCK)
	WHERE IsActive = 1
		AND ParentBettypeId IS NULL
		AND MinorBettypeId NOT IN (- 1, - 2, - 5, - 8)
	ORDER BY m.MinorBettypeName ASC
END