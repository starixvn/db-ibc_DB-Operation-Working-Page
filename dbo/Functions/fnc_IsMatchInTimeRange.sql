
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
*/
BEGIN
	DECLARE @FromTimeSendMessage DATETIME
		,@ToTimeSendMessage DATETIME
		,@FromTimeSendMessageSpecialBettype DATETIME
		,@ToTimeSendMessageSpecialBettype DATETIME
		,@EventDateTime DATETIME
		,@IsSelected BIT
		,@MinorBettypeId INT
	DECLARE @tblCornerBookingBetTypes TABLE (MinorBettypeId INT NOT NULL)

	-- list of minor bettypes Corner & Booking but not 15 mins
	INSERT INTO @tblCornerBookingBetTypes
	SELECT MinorBettypeId
	FROM dbo.MinorBettype WITH (NOLOCK)
	WHERE ParentBetTypeId IS NULL
		AND IsActive = 1
		AND MinorBettypeName NOT LIKE '%15 mins%'
		AND (
			MinorBettypeName LIKE '%corner%'
			OR MinorBettypeName LIKE '%booking%'
			)

	SELECT @FromTimeSendMessage = FromTime
		,@ToTimeSendMessage = ToTime
		,@FromTimeSendMessageSpecialBettype = FromTimeForSpecialBettype
		,@ToTimeSendMessageSpecialBettype = ToTimeForSpecialBettype
	FROM dbo.fnc_GetDateTimeForTraderViewTime()

	-- get info
	SELECT @EventDateTime = m.EventDateTime
		,@IsSelected = mi.IsSelected
		,@MinorBettypeId = mm.MinorBettypeId
	FROM dbo.OWPMatch AS m WITH (NOLOCK)
		INNER JOIN dbo.MatchInfo AS mi WITH (NOLOCK) ON m.OWPMatchId = mi.OWPMatchId
		LEFT JOIN dbo.MinorMatch AS mm WITH (NOLOCK) ON m.OWPMatchId = mm.MinorMatchId
	WHERE m.OWPMatchId = @OWPMatchId

	IF (
			@IsSelected = 1
			AND (
				(
					@MinorBettypeId IS NULL
					AND @EventDateTime >= @FromTimeSendMessage
					AND @EventDateTime <= @ToTimeSendMessage
					)
				OR (
					@MinorBettypeId IS NOT NULL
					AND 1 = (CASE 
						WHEN EXISTS (
								SELECT 1
								FROM @tblCornerBookingBetTypes
								WHERE MinorBetTypeId = @MinorBettypeId
								) THEN CASE 
								WHEN @EventDateTime >= @FromTimeSendMessageSpecialBettype
									AND @EventDateTime <= @ToTimeSendMessageSpecialBettype THEN 1
								ELSE 0
								END
						ELSE CASE 
								WHEN @EventDateTime >= @FromTimeSendMessage
									AND @EventDateTime <= @ToTimeSendMessage THEN 1
								ELSE 0
								END END
						)
					)
				)
			) RETURN 1

	RETURN 0
END