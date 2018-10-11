/*<info serverAlias="DBOWP-bodb_OWP" selecters="bodbOWPNet" isFunction="1"></info>*/
CREATE FUNCTION [dbo].[fnc_GetSpreadFilter] (@FilterId INT)
RETURNS TABLE WITH SCHEMABINDING
AS
/*
Created: 20161223@Tim.Trinh
Task : get spread filter
DB: bodb_OWP

Param's Explanation:

Revisions:
	20181009@Raymond.Le: New structure of event assignment - [Redmine: #92868]
 
*/
RETURN (
		SELECT FromSpread = CAST(MIN(dt.Value) AS SMALLMONEY)
			,ToSpread = CAST(MAX(dt.Value) AS SMALLMONEY)
		FROM dbo.FilterDetail AS dt WITH (NOLOCK)
			INNER JOIN dbo.FilterField AS field WITH (NOLOCK) ON dt.FieldId = field.FieldId
			AND field.[Name] = 'Spread'
		WHERE FilterId = @FilterId
			AND ISNULL(dt.Value, '') <> ''
		)