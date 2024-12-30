/*<info serverAlias="DBOWP-bodb_OWP" executers="wsv_owp" isFunction="1"></info>*/
CREATE FUNCTION [dbo].[fnc_GetLeagueGroupByDate]
(
	@Date DATETIME
	,@OWPLeagueId INT
)
RETURNS NVARCHAR(15)
AS
/*  
 Created: Frankie@20241210
 Task : Update League Group
 DB: bodb_OWP

 Revisions:
	20241210@Frankie: Update League Group - [Redmine: #214351]
*/

BEGIN
	DECLARE @LeagueGr NVARCHAR(MAX);

	SELECT @LeagueGr = ref.Value
	FROM dbo.OWPLeague AS owpl WITH (NOLOCK)
		LEFT JOIN dbo.LeagueCategoryHistory AS lch WITH (NOLOCK) ON owpl.OWPLeagueId = lch.OWPLeagueId
																AND @Date >= lch.StartDate
																AND (@Date <= lch.EndDate OR lch.EndDate IS NULL)
		LEFT JOIN dbo.RefResource AS ref WITH (NOLOCK) ON ref.RefName='LeagueCategory' 
													AND ref.ResourceId = lch.CategoryId
	WHERE owpl.OWPLeagueId = @OWPLeagueId

	RETURN @LeagueGr
END
