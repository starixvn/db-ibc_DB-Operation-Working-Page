
/*<info serverAlias="DBOWP-bodb_OWP" executers="bodbOWPNet" isFunction="0"></info>*/
CREATE PROCEDURE [dbo].[OWP_Find_RelevantMatches] @OWPMatchId INT
AS
/*
Created: 20190920@Tyler.Dang
Task : Update relevant matches MatchInfo section  
DB: bodb_OWP

Revisions:
	20190920@Tyler.Dang: InitialSP - [Redmine: #120498]
*/
BEGIN
	SET NOCOUNT ON;

	DECLARE @isMainMatch BIT = 0

	IF EXISTS (
			SELECT 1
			FROM dbo.MinorMatch WITH (NOLOCK)
			WHERE ParentMatchId = @OWPMatchId
			)
	BEGIN
		SET @isMainMatch = 1
	END

	IF (@isMainMatch = 1)
	BEGIN
		SELECT MinorMatchId
		FROM dbo.MinorMatch WITH (NOLOCK)
		WHERE ParentMatchId = @OWPMatchId
	END
	ELSE
	BEGIN
		SELECT MinorMatchId
		FROM dbo.MinorMatch WITH (NOLOCK)
		WHERE MinorMatchId <> @OWPMatchId
			AND ParentMatchId = (
				SELECT TOP 1 ParentMatchId
				FROM dbo.MinorMatch WITH (NOLOCK)
				WHERE MinorMatchId = @OWPMatchId
				)
		
		UNION
		
		SELECT TOP 1 ParentMatchId
		FROM dbo.MinorMatch WITH (NOLOCK)
		WHERE MinorMatchId = @OWPMatchId
	END
END