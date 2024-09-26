/*<info serverAlias="DBOWP-bodb_OWP" selecters="wsv_owp" isFunction="1"></info>*/
CREATE FUNCTION [dbo].[fnc_GetMaxBetFilter] (@FilterId INT)
RETURNS TABLE WITH SCHEMABINDING
AS
/*
Created: 20161223@Tim.Trinh
Task : get max bet filter
DB: bodb_OWP

Param's Explanation:

Revisions:
	20181009@Raymond.Le: New structure of event assignment - [Redmine: #92868]
 
*/
RETURN (
		SELECT FromMaxBet = CAST(MIN(dt.Value) AS MONEY)
			,ToMaxBet = CAST(MAX(dt.Value) AS MONEY)
		FROM dbo.FilterDetail AS dt WITH (NOLOCK)
			INNER JOIN dbo.FilterField AS field WITH (NOLOCK) ON dt.FieldId = field.FieldId
			AND field.[Name] = 'MaxBet'
		WHERE FilterId = @FilterId
			AND ISNULL(dt.Value, '') <> ''
		)