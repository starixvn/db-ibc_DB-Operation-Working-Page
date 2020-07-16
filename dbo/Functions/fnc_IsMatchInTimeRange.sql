
/*<info serverAlias="DBOWP-bodb_OWP" executers="bodbOWPNet" isFunction="1"></info>*/
CREATE FUNCTION [dbo].[fnc_IsMatchInTimeRange] (@OWPMatchId INT)
RETURNS BIT
AS
/*
Created: Leo.Vo@20181012
Task: Check a match is in time range to send message or not (working for main match)
DB: bodb_OWP

Param's Explanation:
Revisions:
	20181012@Leo.Vo: Initial SP - [Redmine: #102867]
	20190308@Raymond.Le: Check match is in time range for minor match - [Redmine: #109560]
	20200710@Mira.Nguyen: Apply new time range - [Redmine: #137410]
*/
BEGIN
	DECLARE @FromTimeSendMessage DATETIME
		,@ToTimeSendMessage DATETIME
		,@EventDateTime DATETIME
		,@IsSelected BIT

	SELECT @FromTimeSendMessage = FromTime
		,@ToTimeSendMessage = ToTime
	FROM dbo.fnc_GetDateTimeForTraderViewTime()

	-- get info
	SELECT @EventDateTime = m.EventDateTime
		,@IsSelected = mi.IsSelected
	FROM dbo.OWPMatch AS m WITH (NOLOCK)
		INNER JOIN dbo.MatchInfo AS mi WITH (NOLOCK) ON m.OWPMatchId = mi.OWPMatchId
	WHERE m.OWPMatchId = @OWPMatchId

	IF (
			@IsSelected = 1
			AND @EventDateTime BETWEEN @FromTimeSendMessage AND @ToTimeSendMessage
		) RETURN 1

	RETURN 0
END