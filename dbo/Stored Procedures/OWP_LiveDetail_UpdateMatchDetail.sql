CREATE PROCEDURE [dbo].[OWP_LiveDetail_UpdateMatchDetail] @UserId INT
	,@SessionId NVARCHAR(100)
	,@OWPMatchId INT
	,@TVCode NVARCHAR(500) = ''
	,@Channel NVARCHAR(100) = ''
	,@WatchBet NVARCHAR(100) = ''
	,@Phone NVARCHAR(50) = ''
	,@KOTimeRemark NVARCHAR(50) = ''
	,@MatchStatus NVARCHAR(15)
	,@Round NVARCHAR(2000) = ''
	,@OutSide NVARCHAR(2000) = ''
	,@OtherTime TIME = NULL
	,@Venue NVARCHAR(100) = ''
	,@ProviderIds NVARCHAR(100) = ''
	,@MarketIds NVARCHAR(100) = ''
	,@RunnerIds NVARCHAR(100) = ''
	,@ErrCode INT = 0 OUTPUT
	,@ErrMsg NVARCHAR(200) = '' OUTPUT
AS
/*
Created: 20161208@Razor.Nguyen
Task : update new Match Detail Info  
DB: bodb_OWP

Revisions:
    20170824@Tim.Trinh: send message when update Cancel status
    20180614@Leo: change datatype of column Round & OutSide to nvarchar(2000)
*/
BEGIN
	SET NOCOUNT ON

	DECLARE @StartRun DATETIME = GETDATE()
		,@EndRun DATETIME
		,@Duration INT
		,@OldData NVARCHAR(MAX)
		,@NewData NVARCHAR(MAX)
		,@Xml XML
		,@OldTVCode NVARCHAR(500)
		,@OldChannel NVARCHAR(100)
		,@OldWatchBet NVARCHAR(100)
		,@OldPhone NVARCHAR(50)
		,@OldKOTimeRemark NVARCHAR(50)
		,@OldMatchStatus NVARCHAR(15)
		,@OldRound NVARCHAR(2000)
		,@OldOutSide NVARCHAR(2000)
		,@OldOtherTime TIME
		,@OldVenue NVARCHAR(100)
		,@OldProviderIds NVARCHAR(100)
		,@OldMarketIds NVARCHAR(100)
		,@OldRunnerIds NVARCHAR(100)
		,@Today DATETIME = GETDATE()
		,@OWPMatchIds NVARCHAR(20)
		,@MatchName NVARCHAR(MAX)
		,@EventDateTime DATETIME

	SET @OWPMatchIds = CAST(@OWPMatchId AS NVARCHAR(20))

	BEGIN TRY
		SELECT @OldMarketIds = COALESCE(@OldMarketIds + ', ', '') + CAST(MarketId AS NVARCHAR)
		FROM dbo.MatchMarket WITH (NOLOCK)
		WHERE OWPMatchId = @OWPMatchId

		SELECT @OldTVCode = m.TVCode
			,@OldChannel = m.Channel
			,@OldWatchBet = m.WatchBet
			,@OldPhone = m.Phone
			,@OldKOTimeRemark = m.KOTimeRemark
			,@OldMatchStatus = m.MatchStatus
			,@OldRound = m.[Round]
			,@OldOutSide = m.OutSide
			,@OldVenue = m.Venue
			,@OldOtherTime = owp.OtherTime
			,@OldProviderIds = m.Provider
			,@OldRunnerIds = m.Runner
		FROM dbo.MatchInfo m WITH (NOLOCK)
			LEFT JOIN dbo.OWPMatch owp WITH (NOLOCK) ON owp.OWPMatchId = m.OWPMatchId
			LEFT JOIN dbo.MatchMarket mk WITH (NOLOCK) ON mk.OWPMatchId = m.OWPMatchId
		WHERE m.OWPMatchId = @OWPMatchId

		UPDATE dbo.MatchInfo WITH (ROWLOCK, UPDLOCK)
		SET TVCode = @TVCode
			,Channel = @Channel
			,WatchBet = @WatchBet
			,Phone = @Phone
			,KOTimeRemark = @KOTimeRemark
			,[Round] = @Round
			,OutSide = @OutSide
			,Venue = @Venue
			,Provider = @ProviderIds
			,Runner = @RunnerIds
		WHERE OWPMatchId = @OWPMatchId

		UPDATE dbo.OWPMatch WITH (ROWLOCK, UPDLOCK)
		SET OtherTime = @OtherTime
		WHERE OWPMatchId = @OWPMatchId

		DELETE
		FROM dbo.MatchMarket
		WHERE OWPMatchId = @OWPMatchId

		IF (ISNULL(@MarketIds, '') != '')
		BEGIN
			INSERT INTO dbo.MatchMarket
			SELECT @OWPMatchId
				,val
			FROM dbo.strSplit(ISNULL(@MarketIds, ''), ',')
		END

		EXEC dbo.OWP_LiveDetail_UpdateIsCancelled @UserId = @UserId
			,@SessionId = @SessionId
			,@OWPMatchId = @OWPMatchId
			,@MatchStatus = @MatchStatus

		-- write log
		SET @Xml = (
				SELECT CASE 
						WHEN ISNULL(@OldTVCode, '') <> ISNULL(@TVCode, '') THEN @OldTVCode
						ELSE NULL
						END AS '@tvcode'
					,CASE 
						WHEN ISNULL(@OldChannel, '') <> ISNULL(@Channel, '') THEN @OldChannel
						ELSE NULL
						END AS '@c'
					,CASE 
						WHEN ISNULL(@OldWatchBet, '') <> ISNULL(@WatchBet, '') THEN @OldWatchBet
						ELSE NULL
						END AS '@wb'
					,CASE 
						WHEN ISNULL(@OldPhone, '') <> ISNULL(@Phone, '') THEN @OldPhone
						ELSE NULL
						END AS '@p'
					,CASE 
						WHEN ISNULL(@OldKOTimeRemark, '') <> ISNULL(@KOTimeRemark, '') THEN @OldKOTimeRemark
						ELSE NULL
						END AS '@ko'
					,CASE 
						WHEN @OldMatchStatus <> @MatchStatus THEN @OldMatchStatus
						ELSE NULL
						END AS '@can'
					,CASE 
						WHEN ISNULL(@OldRound, '') <> ISNULL(@Round, '') THEN @OldRound
						ELSE NULL
						END AS '@roud'
					,CASE 
						WHEN ISNULL(@OldOutSide, '') <> ISNULL(@OutSide, '') THEN @OldOutSide
						ELSE NULL
						END AS '@outs'
					,CASE 
						WHEN ISNULL(@OldVenue, '') <> ISNULL(@Venue, '') THEN @OldVenue
						ELSE NULL
						END AS '@v'
					,CASE 
						WHEN ISNULL(@OldOtherTime, '') <> ISNULL(@OtherTime, '') THEN @OldOtherTime
						ELSE NULL
						END AS '@otime'
					,CASE 
						WHEN ISNULL(@OldProviderIds, '') <> ISNULL(@ProviderIds, '') THEN @OldProviderIds
						ELSE NULL
						END AS 'pr'
					,CASE 
						WHEN ISNULL(@OldRunnerIds, '') <> ISNULL(@RunnerIds, '') THEN @OldRunnerIds
						ELSE NULL
						END AS 'rn'
					,CASE 
						WHEN ISNULL(@OldMarketIds, '') <> ISNULL(@MarketIds, '') THEN @OldMarketIds
						ELSE NULL
						END AS 'mk'
				FOR XML PATH('z')
					,ROOT('r')
				)
		SET @OldData = REPLACE(CONVERT(NVARCHAR(MAX), @Xml), '" />', '"/"')
		SET @Xml = (
				SELECT CASE 
						WHEN ISNULL(@OldTVCode, '') <> ISNULL(@TVCode, '') THEN @TVCode
						ELSE NULL
						END AS '@tvcode'
					,CASE 
						WHEN ISNULL(@OldChannel, '') <> ISNULL(@Channel, '') THEN @Channel
						ELSE NULL
						END AS '@c'
					,CASE 
						WHEN ISNULL(@OldWatchBet, '') <> ISNULL(@WatchBet, '') THEN @WatchBet
						ELSE NULL
						END AS '@wb'
					,CASE 
						WHEN ISNULL(@OldPhone, '') <> ISNULL(@Phone, '') THEN @Phone
						ELSE NULL
						END AS '@p'
					,CASE 
						WHEN ISNULL(@OldKOTimeRemark, '') <> ISNULL(@KOTimeRemark, '') THEN @KOTimeRemark
						ELSE NULL
						END AS '@ko'
					,CASE 
						WHEN @OldMatchStatus <> @MatchStatus THEN @MatchStatus
						ELSE NULL
						END AS '@can'
					,CASE 
						WHEN ISNULL(@OldRound, '') <> ISNULL(@Round, '') THEN @Round
						ELSE NULL
						END AS '@roud'
					,CASE 
						WHEN ISNULL(@OldOutSide, '') <> ISNULL(@OutSide, '') THEN @OutSide
						ELSE NULL
						END AS '@outs'
					,CASE 
						WHEN ISNULL(@OldVenue, '') <> ISNULL(@Venue, '') THEN @Venue
						ELSE NULL
						END AS '@v'
					,CASE 
						WHEN ISNULL(@OldOtherTime, '') <> ISNULL(@OtherTime, '') THEN @OtherTime
						ELSE NULL
						END AS '@otime'
					,CASE 
						WHEN ISNULL(@OldProviderIds, '') <> ISNULL(@ProviderIds, '') THEN @ProviderIds
						ELSE NULL
						END AS 'pr'
					,CASE 
						WHEN ISNULL(@OldRunnerIds, '') <> ISNULL(@RunnerIds, '') THEN @RunnerIds
						ELSE NULL
						END AS 'rn'
					,CASE 
						WHEN ISNULL(@OldMarketIds, '') <> ISNULL(@MarketIds, '') THEN @MarketIds
						ELSE NULL
						END AS 'mk'
				FOR XML PATH('z')
					,ROOT('r')
				)
		SET @NewData = REPLACE(CONVERT(NVARCHAR(MAX), @Xml), '" />', '"/"')
		SET @EndRun = GETDATE()
		SET @Duration = DATEDIFF(MILLISECOND, @StartRun, @EndRun)

		EXEC dbo.OWP_WriteLog @CreatorId = @UserId
			,@SPName = 'OWP_LiveDetail_UpdateMatchDetail'
			,@LoggedDate = @StartRun
			,@Duration = @Duration
			,@ObjectId = @OWPMatchId
			,@Data = @NewData
			,@DataOld = @OldData
	END TRY

	BEGIN CATCH
		SELECT @ErrMsg = 'Update Match Detail failed. Please try again.'
			,@ErrCode = 5001 -- ActionId + 01

		RETURN
	END CATCH
END