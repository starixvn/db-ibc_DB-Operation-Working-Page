CREATE PROCEDURE [dbo].[OWP_Match_CheckExistPhoneOnDuration] @Phone NVARCHAR(100)
	,@OWPMatchId INT
	,@MatchLengthMinute INT
AS
/*  
 Created: 2016-12-12@Razor.Nguyen
 Task : Check Phone exists in Match having KOTime from x to y
 DB: bodb_OWP  
  
 Revisions:     
 */
BEGIN
	SET NOCOUNT ON

	DECLARE @FromTimeGMT8 DATETIME
		,@ToTimeGMT8 DATETIME
		,@FromTimeGMT4 DATETIME
		,@ToTimeGMT4 DATETIME
		,@MatchId INT
		,@IsExistPhoneOnDuration BIT = 0

	SELECT @MatchId = MatchId
	FROM dbo.OWPMatch WITH (NOLOCK)
	WHERE OWPMatchId = @OWPMatchId

	IF (@MatchId IS NULL)
	BEGIN
		SELECT @FromTimeGMT8 = DATEADD(minute, - 1 * @MatchLengthMinute, m.EventDate + m.KickOffTime)
			,@ToTimeGMT8 = DATEADD(minute, @MatchLengthMinute, m.EventDate + m.KickOffTime)
		FROM dbo.OWPMatch m WITH (NOLOCK)
		WHERE m.OWPMatchId = @OWPMatchId

		IF (
				@FromTimeGMT8 IS NOT NULL
				AND @ToTimeGMT8 IS NOT NULL
				)
		BEGIN
			SELECT @FromTimeGMT4 = dbo.[OWP_ConvertDateGMT-4](@FromTimeGMT8, CAST(@FromTimeGMT8 AS TIME))
				,@ToTimeGMT4 = dbo.[OWP_CONVERTDATEGMT-4](@ToTimeGMT8, CAST(@ToTimeGMT8 AS TIME))
		END
	END
	ELSE
	BEGIN
		SELECT @FromTimeGMT4 = DATEADD(minute, - 1 * @MatchLengthMinute, m.GlobalShowTime)
			,@ToTimeGMT4 = DATEADD(minute, @MatchLengthMinute, m.GlobalShowTime)
		FROM bodb02.dbo.match m WITH (NOLOCK)
		WHERE MatchId = @MatchId

		IF (
				@FromTimeGMT4 IS NULL
				OR @ToTimeGMT4 IS NULL
				)
		BEGIN
			SELECT @FromTimeGMT4 = DATEADD(minute, - 1 * @MatchLengthMinute, m.GlobalShowTime)
				,@ToTimeGMT4 = DATEADD(minute, @MatchLengthMinute, m.GlobalShowTime)
			FROM bodb02.dbo.match14 m WITH (NOLOCK)
			WHERE MatchId = @MatchId
		END

		IF (
				@FromTimeGMT4 IS NOT NULL
				AND @ToTimeGMT4 IS NOT NULL
				)
		BEGIN
			SELECT @FromTimeGMT8 = dbo.[OWP_ConvertDateGMT+8](@FromTimeGMT4)
				,@ToTimeGMT8 = dbo.[OWP_ConvertDateGMT+8](@ToTimeGMT4)
		END
	END

	IF (
			@FromTimeGMT8 IS NOT NULL
			AND @ToTimeGMT8 IS NOT NULL
			AND @FromTimeGMT4 IS NOT NULL
			AND @ToTimeGMT4 IS NOT NULL
			AND (
				EXISTS (
					SELECT 1
					FROM dbo.OWPMatch m WITH (NOLOCK)
						INNER JOIN dbo.MatchInfo info WITH (NOLOCK) ON info.OWPMatchId = m.OWPMatchId
					WHERE info.Phone = @Phone
						AND m.MatchId IS NULL
						AND m.OWPMatchId <> @OWPMatchId
						AND (m.EventDate + m.KickOffTime) BETWEEN @FromTimeGMT8
							AND @ToTimeGMT8
					)
				OR (
					EXISTS (
						SELECT 1
						FROM bodb02.dbo.match m WITH (NOLOCK)
							INNER JOIN dbo.OWPMatch owp WITH (NOLOCK) ON owp.MatchId = m.MatchId
							INNER JOIN dbo.MatchInfo info WITH (NOLOCK) ON info.OWPMatchId = owp.OWPMatchId
						WHERE info.Phone = @Phone
							AND (@MatchId IS NULL OR m.MatchId <> @MatchId)
							AND m.GlobalShowTime BETWEEN @FromTimeGMT4
								AND @ToTimeGMT4
						)
					)
				OR (
					EXISTS (
						SELECT 1
						FROM bodb02.dbo.match14 m WITH (NOLOCK)
							INNER JOIN dbo.OWPMatch owp WITH (NOLOCK) ON owp.MatchId = m.MatchId
							INNER JOIN dbo.MatchInfo info WITH (NOLOCK) ON info.OWPMatchId = owp.OWPMatchId
						WHERE info.Phone = @Phone
							AND (@MatchId IS NULL OR m.MatchId <> @MatchId)
							AND m.GlobalShowTime BETWEEN @FromTimeGMT4
								AND @ToTimeGMT4
						)
					)
				)
			)
	BEGIN
		SET @IsExistPhoneOnDuration = 1
	END

	SELECT @IsExistPhoneOnDuration
END