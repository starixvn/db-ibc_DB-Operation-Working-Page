/*<info serverAlias="DBOWP-bodb_OWP" executers="bodbOWPNet" isFunction="1"></info>*/
CREATE FUNCTION [dbo].[OWP_GetCurrentMatchStatus]
(
	@EventDate DATETIME
	,@KickOffTime TIME
	,@CurrentStatus NVARCHAR(15)
)
RETURNS NVARCHAR(15)
AS
/*
Created: 20171113@Raymond.Le
Task : get current match status
DB: bodb_OWP

Revisions:
	20181009@Raymond.Le: new structure
*/
BEGIN
	DECLARE	@str_Live NVARCHAR(15) = 'Live'
			,@str_Inplay NVARCHAR(15) = 'In-play'
			,@str_Completed NVARCHAR(15) = 'Completed'
			,@EventDateTime DATETIME 
			,@CompletedTime DATETIME 
			,@CurrentTime DATETIME
			,@NewStatus NVARCHAR(15)

	SET @CurrentStatus = ISNULL(@CurrentStatus, @str_Live)

	IF (@CurrentStatus = @str_Live )
	BEGIN
		SET @EventDateTime = (@EventDate + @KickOffTime)
		SET @CompletedTime = DATEADD(minute, 120, @EventDateTime)
		SET @CurrentTime = DATEADD(HOUR,12,GETDATE())

		SET @NewStatus = CASE WHEN @CurrentTime >= @EventDateTime AND @CurrentTime < @CompletedTime THEN @str_Inplay
								WHEN @CurrentTime >= @CompletedTime THEN @str_Completed
								ELSE  @CurrentStatus
								END

	END
	ELSE
	BEGIN
		SET @NewStatus = @CurrentStatus
	END

	RETURN @NewStatus
END