CREATE FUNCTION [dbo].[OWP_SpreadGet] (
	@OWPMatchId INT
	,@LeagueId INT
	,@Bettype INT
	)
RETURNS MONEY
AS
/*
Created: 20161020@julien
Task : get spread
DB: bodb_OWP

Param's Explanation:

Revisions:
 
*/
BEGIN
	DECLARE @Spread MONEY
		,@Total INT = 0
		,@tv BIT = 0
		,@ukrb BIT = 0 --UK/RB

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
				OR NULLIF(mi.Provider, '') IS NOT NULL THEN 1
			ELSE 0 END
			)
	FROM dbo.MatchInfo AS mi WITH (NOLOCK)
	WHERE mi.OWPMatchId = @OWPMatchId

	IF @tv = 1
		AND @ukrb = 1
	BEGIN
		SET @ukrb = 0
	END

	SET @Total = POWER(2 * @tv, 3) + POWER(2 * @ukrb, 4)

	SELECT @Spread = ls.Spread
	FROM dbo.LeagueSetting AS ls WITH (NOLOCK)
	WHERE ls.LeagueId = @LeagueId
		AND ls.OptionsId = @Total
		AND ls.Bettype = @Bettype

	RETURN @Spread
END