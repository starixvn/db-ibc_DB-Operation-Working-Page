/*<info serverAlias="DBOWP-bodb_OWP" executers="bodbOWPNet" isFunction="1"></info>*/
CREATE FUNCTION [dbo].[OWP_GetLeagueOptionId] (@OptionsIds INT)
RETURNS INT
AS
/*
Created: 20170302@Tim.Trinh
Task : get league option
DB: bodb_OWP

Param's Explanation:

Revisions:
	20181009@Raymond.Le: new structure 
*/
BEGIN
	DECLARE @id INT
		,@weekday SMALLINT = 2
		,@weekend SMALLINT = 4
		,@OptIds INT

	SELECT @id = Value
	FROM dbo.LeagueOption WITH (NOLOCK)
	WHERE POWER(2.0, Value) = @OptionsIds

	-- check weekend
	IF ISNULL(@id, 0) = 0
	BEGIN
		SET @OptIds = @OptionsIds - @weekend

		SELECT @id = Value
		FROM dbo.LeagueOption WITH (NOLOCK)
		WHERE POWER(2.0, Value) = @OptIds
	END
	
	-- check weekday
	IF ISNULL(@id, 0) = 0
	BEGIN
		SET @OptIds = @OptionsIds - @weekday

		SELECT @id = Value
		FROM dbo.LeagueOption WITH (NOLOCK)
		WHERE POWER(2.0, Value) = @OptIds
	END

	RETURN @id
END