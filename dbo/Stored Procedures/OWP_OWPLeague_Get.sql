/*<info serverAlias="DBOWP-bodb_OWP" executers="bodbOWPNet" isFunction="0"></info>*/
CREATE PROCEDURE [dbo].[OWP_OWPLeague_Get] @Keywords NVARCHAR(100) = ''
	,@SelectTop INT = NULL
AS
/*
Created: 20161221@Tim.Trinh
Task : select league with search string
DB: bodb_OWP

Revisions:
	20181009@Raymond.Le: new structure 
*/
BEGIN
	SET NOCOUNT ON

	IF @SelectTop IS NULL
	BEGIN
		SELECT league.OWPLeagueId
			,league.OWPLeagueName AS [Name]
		FROM dbo.OWPLeague AS league WITH (NOLOCK)
		WHERE (
				LEN(@Keywords) = 0
				OR league.OWPLeagueName LIKE '%' + @Keywords + '%'
				)
	END
	ELSE
	BEGIN
		SELECT TOP (@SelectTop) league.OWPLeagueId
			,league.OWPLeagueName AS [Name]
		FROM dbo.OWPLeague AS league WITH (NOLOCK)
		WHERE (
				LEN(@Keywords) = 0
				OR league.OWPLeagueName LIKE '%' + @Keywords + '%'
				)
	END
END