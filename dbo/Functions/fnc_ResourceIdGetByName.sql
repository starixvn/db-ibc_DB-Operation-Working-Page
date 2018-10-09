/*<info serverAlias="DBOWP-bodb_OWP" executers="bodbOWPNet" isFunction="1"></info>*/
CREATE FUNCTION [dbo].[fnc_ResourceIdGetByName] (
	@ResourceType VARCHAR(30)
	,@ResourceValues NVARCHAR(MAX)
	)
RETURNS NVARCHAR(200)
/*    
Created: 20161027@Long.Luu    
Task : Get ResourceId by Name    
DB: bodb_OWP    
    
Revisions:
	20181009@Raymond.Le: new structure      
*/
AS
BEGIN
	DECLARE @ResourceIds NVARCHAR(200)

	IF (
			@ResourceValues = ''
			OR @ResourceValues IS NULL
			)
	BEGIN
		SET @ResourceIds = ''

		RETURN @ResourceIds
	END

	DECLARE @Resources TABLE (
		RowIndex INT IDENTITY(1, 1)
		,ResourceValue NVARCHAR(20)
		)

	INSERT INTO @Resources (ResourceValue)
	SELECT CAST(VAL AS NVARCHAR(20)) AS ResourceValue
	FROM dbo.strSplit(@ResourceValues, ',')

	DECLARE @TotalRow INT
		,@rowIndex INT

	SELECT @TotalRow = COUNT(1)
	FROM @Resources

	SET @rowIndex = 1

	WHILE @rowIndex <= @TotalRow
	BEGIN
		DECLARE @Value NVARCHAR(200)
		DECLARE @Id INT = - 1

		SELECT @Value = LTRIM(RTRIM(r.ResourceValue))
		FROM @Resources r
		WHERE r.RowIndex = @rowIndex

		SELECT TOP 1 @Id = rr.ResourceId
		FROM dbo.RefResource rr WITH (NOLOCK)
		WHERE rr.RefName = @ResourceType
			AND rr.Value = @Value

		SET @ResourceIds = @ResourceIds + CAST(@Id AS VARCHAR(5)) + ','
		SET @rowIndex = @rowIndex + 1
	END

	SET @ResourceIds = SUBSTRING(@ResourceIds, 0, LEN(@ResourceIds))

	RETURN @ResourceIds
END