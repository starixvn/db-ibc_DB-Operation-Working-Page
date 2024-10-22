/*<info serverAlias="DBOWP-bodb_OWP" executers="wsv_owp" isFunction="1"></info>*/
CREATE FUNCTION [dbo].[fnc_GetEventDateFilter] (@FilterId INT)
RETURNS DATE
AS
/*
Created: 20170103@Tim.Trinh
Task : get Event Date filter
DB: bodb_OWP

Param's Explanation:

Revisions:
    20171109@Quinn.Vo: get Yesterday
	20181009@Leo.Vo: New structure of event assignment - [Redmine: #92868]
*/
BEGIN
	DECLARE @EventDate DATE
		,@Today DATE
		,@EventDateFilter NVARCHAR(100)

	SET @Today = GETDATE()

	IF EXISTS (
			SELECT 1
			FROM dbo.FilterDetail AS dt WITH (NOLOCK)
				INNER JOIN dbo.FilterField AS field WITH (NOLOCK) ON dt.FieldId = field.FieldId
				AND field.[Name] = 'EventDate'
			WHERE FilterId = @FilterId
			)
	BEGIN
		SELECT @EventDateFilter = RTRIM(LTRIM(dt.Value))
		FROM dbo.FilterDetail AS dt WITH (NOLOCK)
			INNER JOIN dbo.FilterField AS field WITH (NOLOCK) ON dt.FieldId = field.FieldId
			AND field.[Name] = 'EventDate'
		WHERE FilterId = @FilterId

		IF LEN(@EventDateFilter) > 0
		BEGIN
			SELECT @EventDate = (CASE @EventDateFilter
					WHEN '0' THEN @Today
					WHEN '1' THEN DATEADD(DAY, 1, @Today)
					WHEN '2' THEN DATEADD(DAY, -1, @Today)
					ELSE CAST(@EventDateFilter AS DATE) END
					)
		END
	END

	RETURN @EventDate
END