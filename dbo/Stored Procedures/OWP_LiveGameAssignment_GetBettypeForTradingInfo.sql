
/*<info serverAlias="DBOWP-bodb_OWP" executers="bodbOWPNet" isFunction="0"></info>*/
CREATE PROCEDURE [dbo].[OWP_LiveGameAssignment_GetBettypeForTradingInfo]
AS
/*
Created: 20190724@Carlos
Task : Get all bettype for trading info
DB: bodb_OWP

Revisions:
	20190724@Carlos: Initial SP - [Feature: #117461]
*/
BEGIN
	SELECT BettypeId
		,ShortName
	FROM dbo.MajorBettype WITH (NOLOCK)
	WHERE BettypeId <> - 1002 AND BettypeId <> - 1004
	ORDER BY (CASE WHEN BettypeId < 0 THEN -BettypeId ELSE 0 END), BettypeId ASC
END