
/*<info serverAlias="DBOWP-bodb_OWP" executers="wsv_owp" isFunction="1"></info>*/
ALTER FUNCTION [dbo].[OWP_SpreadGet] (
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
	20181009@Raymond.Le: New structure of event assignment - [Redmine: #92868]
	20190109@Raymond.Le: Rename Provider to Other Provider, Runner to Provider - [Redmine: #107257]
	20190506@Leo.Vo: Change schema of Provider, OtherProvider, Agent, Television - [Redmine: #112918]
	20240821@Mira: Comment function - [Redmine: #112918]
*/
BEGIN
	--DECLARE @Spread MONEY
	--	,@Total INT = 0
	--	,@tv BIT = 0
	--	,@ukrb BIT = 0 --UK/RB

	---- check tv
	--SET @tv = 0

	--IF EXISTS (
	--		SELECT 1
	--		FROM dbo.MatchTelevision WITH (NOLOCK)
	--		WHERE OWPMatchId = @OWPMatchId
	--		)
	--BEGIN
	--	SET @tv = 1
	--END

	---- check UK
	--SET @ukrb = 0

	--IF (
	--		EXISTS (
	--			SELECT 1
	--			FROM dbo.MatchInfo WITH (NOLOCK)
	--			WHERE OWPMatchId = @OWPMatchId
	--				AND Channel IS NOT NULL
	--				AND Channel <> ''
	--			)
	--		OR EXISTS (
	--			SELECT 1
	--			FROM dbo.MatchOtherProvider WITH (NOLOCK)
	--			WHERE OWPMatchId = @OWPMatchId
	--			)
	--		)
	--BEGIN
	--	SET @ukrb = 1
	--END

	--IF @tv = 1
	--	AND @ukrb = 1
	--BEGIN
	--	SET @ukrb = 0
	--END

	--SET @Total = POWER(2 * @tv, 3) + POWER(2 * @ukrb, 4)

	--SELECT @Spread = ls.Spread
	--FROM dbo.LeagueSetting AS ls WITH (NOLOCK)
	--WHERE ls.LeagueId = @LeagueId
	--	AND ls.OptionsId = @Total
	--	AND ls.Bettype = @Bettype

	RETURN NULL;
END