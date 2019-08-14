CREATE FUNCTION [dbo].[OWP_GetCurrentMatchLiveStatus]
(
	@EventDate DATETIME
	,@KickOffTime TIME
)
RETURNS NVARCHAR(15)
AS
/*  
 Created: Tyler.Dang@20190814
 Task : Specify Live status (In-play, Completed or Live)
 DB: bodb_OWP
*/
BEGIN
	DECLARE	@str_Live NVARCHAR(15) = 'Live'
			,@str_Inplay NVARCHAR(15) = 'In-play'
			,@str_Completed NVARCHAR(15) = 'Completed'
			,@EventDateTime DATETIME 
			,@CompletedTime DATETIME 
			,@CurrentTime DATETIME
			,@LiveStatus NVARCHAR(15)

		SET @EventDateTime = (@EventDate + @KickOffTime)
		SET @CompletedTime = DATEADD(minute, 120, @EventDateTime)
		SET @CurrentTime = DATEADD(HOUR,12,GETDATE())

		SET @LiveStatus = CASE WHEN @CurrentTime >= @EventDateTime AND @CurrentTime < @CompletedTime THEN @str_Inplay
								WHEN @CurrentTime >= @CompletedTime THEN @str_Completed
								ELSE  @str_Live
								END

	RETURN @LiveStatus

END