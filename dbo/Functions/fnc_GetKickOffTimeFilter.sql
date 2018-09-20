CREATE FUNCTION [dbo].[fnc_GetKickOffTimeFilter] (@FilterId INT)
RETURNS TABLE WITH SCHEMABINDING
AS
/*
Created: 20161223@Tim.Trinh
Task : get kick off time filter
DB: bodb_OWP

Param's Explanation:

Revisions:
 
*/
RETURN (
		SELECT FromTime = CAST(MIN(dt.Value) AS TIME)
			,ToTime = CAST(MAX(dt.Value) AS TIME)
		FROM dbo.FilterDetail AS dt WITH (NOLOCK)
			INNER JOIN dbo.FilterField AS field WITH (NOLOCK) ON dt.FieldId = field.FieldId
			AND field.[Name] = 'KOTime'
		WHERE FilterId = @FilterId
			AND ISNULL(dt.Value, '') <> ''
		)