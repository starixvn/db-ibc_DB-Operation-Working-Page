/*<info serverAlias="DBOWP-bodb_OWP" executers="bodbOWPNet" isFunction="1"></info>*/
CREATE FUNCTION [dbo].[fnc_GetValueFilter] (
	@FilterId INT
	,@FilterName VARCHAR(500)
	)
RETURNS NVARCHAR(MAX)
AS
/*
Created: 20161223@Tim.Trinh
Task : get value filter
DB: bodb_OWP

Param's Explanation:

Revisions:
	20181009@Raymond.Le: new structure
 
*/
BEGIN
	DECLARE @Value NVARCHAR(MAX)

	IF EXISTS (
			SELECT 1
			FROM dbo.FilterDetail AS dt WITH (NOLOCK)
				INNER JOIN dbo.FilterField AS field WITH (NOLOCK) ON dt.FieldId = field.FieldId
				AND field.[Name] = @FilterName
			WHERE FilterId = @FilterId
			)
	BEGIN
		SELECT @Value = dt.Value
		FROM dbo.FilterDetail AS dt WITH (NOLOCK)
			INNER JOIN dbo.FilterField AS field WITH (NOLOCK) ON dt.FieldId = field.FieldId
			AND field.[Name] = @FilterName
		WHERE FilterId = @FilterId
	END

	RETURN @Value
END