/*<info serverAlias="DBOWP-bodb_OWP" executers="bodbOWPNet" isFunction="1"></info>*/
CREATE FUNCTION [dbo].[OWP_MaxBetGet] (
	@OWPMatchId INT
	,@LeagueId INT
	,@Bettype INT
	)
RETURNS MONEY
AS
/*
Created: 20161020@julien
Task : get max bet
DB: bodb_OWP

Param's Explanation:

Revisions:
    20170420@Tim.Trinh: fix bug get max bet for 1X2, 1H 1X2
	20181009@Raymond.Le: New structure of event assignment - [Redmine: #92868]
	20190109@Raymond.Le: Rename Provider to Other Provider, Runner to Provider - [Redmine: #107257]
*/
BEGIN
	DECLARE @MaxBet MONEY
		,@Total INT = 0
		,@MatchDate DATETIME = NULL
		,@weekday BIT = 0
		,@weekend BIT = 0
		,@tv BIT = 0
		,@ukrb BIT = 0 --UK/RB
		,@FT1X2 INT = 5
		,@1H1X2 INT = 15

	SELECT @MatchDate = DATEADD(dd, DATEDIFF(dd, 0, EventDate), CAST(KickOffTime AS DATETIME))
	FROM dbo.OWPMatch AS om WITH (NOLOCK)
	WHERE om.OWPMatchId = @OWPMatchId

	-- check weekday
	SELECT @weekday = CASE ISNULL(DATEPART(dw, @MatchDate), - 1)
			WHEN 1 THEN 0 --'Weekend'
			WHEN 2 THEN 1
			WHEN 3 THEN 1
			WHEN 4 THEN 1
			WHEN 5 THEN 1
			WHEN 6 THEN 1
			WHEN 7 THEN 0 --'Weekend'
			END

	-- check weekday 		
	SELECT @weekend = CASE ISNULL(DATEPART(dw, @MatchDate), - 1)
			WHEN 1 THEN 1 --'Weekend'
			WHEN 2 THEN 0
			WHEN 3 THEN 0
			WHEN 4 THEN 0
			WHEN 5 THEN 0
			WHEN 6 THEN 0
			WHEN 7 THEN 1 --'Weekend'
			END

	-- check tv
	SELECT @tv = (CASE 
			WHEN NULLIF(mi.TVCode, '') IS NOT NULL THEN 1
			ELSE 0 END
			)
	FROM dbo.MatchInfo AS mi WITH (NOLOCK)
	WHERE mi.OWPMatchId = @OWPMatchId

	-- check UK
	SELECT @ukrb = (CASE 
			WHEN NULLIF(mi.Channel, '') IS NOT NULL
				OR NULLIF(mi.OtherProvider, '') IS NOT NULL THEN 1
			ELSE 0 END
			)
	FROM dbo.MatchInfo AS mi WITH (NOLOCK)
	WHERE mi.OWPMatchId = @OWPMatchId

	IF @tv = 1
		AND @ukrb = 1
	BEGIN
		SET @ukrb = 0
	END

	IF @Bettype = @FT1X2
		OR @Bettype = @1H1X2
	BEGIN
		SET @Total = POWER(2 * @tv, 3) + POWER(2 * @ukrb, 4)
	END
	ELSE
	BEGIN
		SET @Total = POWER(2 * @weekday, 1) + POWER(2 * @weekend, 2) + POWER(2 * @tv, 3) + POWER(2 * @ukrb, 4)
	END

	SELECT @MaxBet = ls.Maxbet
	FROM dbo.LeagueSetting AS ls WITH (NOLOCK)
	WHERE ls.LeagueId = @LeagueId
		AND ls.OptionsId = @Total
		AND ls.Bettype = @Bettype

	RETURN @MaxBet
END