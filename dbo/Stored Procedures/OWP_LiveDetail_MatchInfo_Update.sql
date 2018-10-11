/*<info serverAlias="DBOWP-bodb_OWP" executers="bodbOWPNet" isFunction="0"></info>*/
CREATE PROCEDURE [dbo].[OWP_LiveDetail_MatchInfo_Update] @UserId INT
	,@OWPMatchId INT
	,@Channel NVARCHAR(100) = ''
	,@WB NVARCHAR(100) = ''
	,@Phone NVARCHAR(50) = ''
	,@Remark NVARCHAR(2000) = ''
	,@NoOfHDP NVARCHAR(20) = ''
	,@IsSoloMatch BIT = 0
	,@KOTimeRemark NVARCHAR(50) = ''
	,@Round NVARCHAR(2000) = ''
	,@Division NVARCHAR(2000) = ''
	,@Venue NVARCHAR(100) = ''
	,@OtherTime DATETIME = NULL
	,@TVIds NVARCHAR(500) = ''
	,@ProviderIds NVARCHAR(100) = ''	
	,@RunnerIds NVARCHAR(100) = ''
	,@AgentIds NVARCHAR(100) = ''
	,@MarketIds NVARCHAR(100) = ''
	,@ErrCode INT = 0 OUTPUT
	,@ErrMsg NVARCHAR(200) = '' OUTPUT
AS
/*
Created: 20161208@Razor.Nguyen
Task : update new Match Detail Info  
DB: bodb_OWP

Revisions:
    20170824@Tim.Trinh: send message when update Cancel status
	20180814@Raymond.Le: new design Live Detail
	20181009@Leo.Vo: New structure of event assignment - [Redmine: #92868]
*/
BEGIN
	SET NOCOUNT ON

	DECLARE @StartRun DATETIME = GETDATE()
		,@EndRun DATETIME
		,@Duration INT
		,@OldData NVARCHAR(MAX)
		,@NewData NVARCHAR(MAX)
		,@Xml XML
		,@OldChannel NVARCHAR(100)
		,@OldWB NVARCHAR(100)
		,@OldPhone NVARCHAR(50)
		,@OldRemark NVARCHAR(2000)
		,@OldNoOfHDP NVARCHAR(20)
		,@OldIsSoloMatch BIT
		,@OldKOTimeRemark NVARCHAR(50)		
		,@OldRound NVARCHAR(2000)
		,@OldDivision NVARCHAR(2000)
		,@OldVenue NVARCHAR(100)
		,@OldOtherTime TIME
		,@OldTVIds NVARCHAR(500)
		,@OldProviderIds NVARCHAR(100)		
		,@OldRunnerIds NVARCHAR(100)
		,@OldAgentIds NVARCHAR(100)
		,@OldMarketIds NVARCHAR(100)
		,@Today DATETIME = GETDATE()
		,@MatchName NVARCHAR(MAX)
		,@EventDateTime DATETIME


	BEGIN TRY
		SELECT @OldMarketIds = COALESCE(@OldMarketIds + ', ', '') + CAST(MarketId AS NVARCHAR)
		FROM dbo.MatchMarket WITH (NOLOCK)
		WHERE OWPMatchId = @OWPMatchId

		SELECT @OldChannel = m.Channel
			,@OldWB = m.WB
			,@OldPhone = m.Phone
			,@OldRemark = m.Remark
			,@OldNoOfHDP = m.NoOfHDP
			,@OldIsSoloMatch = m.IsSoloMatch
			,@OldKOTimeRemark = m.KOTimeRemark
			,@OldRound = m.[Round]
			,@OldDivision = m.Division
			,@OldVenue = m.Venue
			,@OldOtherTime = om.OtherTime
			,@OldTVIds = m.TVCode
			,@OldProviderIds = m.Provider
			,@OldRunnerIds = m.Runner
			,@OldAgentIds = m.Agent
		FROM dbo.MatchInfo m WITH (NOLOCK)
			LEFT JOIN dbo.OWPMatch om WITH (NOLOCK) ON om.OWPMatchId = m.OWPMatchId
		WHERE m.OWPMatchId = @OWPMatchId

		UPDATE dbo.MatchInfo WITH (ROWLOCK, UPDLOCK)
		SET Channel = @Channel
			,WB = @WB
			,Phone = @Phone
			,Remark = @Remark
			,NoOfHDP = @NoOfHDP
			,IsSoloMatch = @IsSoloMatch
			,KOTimeRemark = @KOTimeRemark
			,[Round] = @Round
			,Division = @Division
			,Venue = @Venue
			,Provider = @ProviderIds
			,Runner = @RunnerIds
			,TVCode = @TVIds
			,Agent = @AgentIds
		WHERE OWPMatchId = @OWPMatchId

		UPDATE dbo.OWPMatch WITH (ROWLOCK, UPDLOCK)
		SET OtherTime = @OtherTime
		WHERE OWPMatchId = @OWPMatchId

		DELETE
		FROM dbo.MatchMarket
		WHERE OWPMatchId = @OWPMatchId

		IF (ISNULL(@MarketIds, '') != '')
		BEGIN
			INSERT INTO dbo.MatchMarket (
			OWPMatchId
			,MarketId
			)
			SELECT @OWPMatchId
				,val
			FROM dbo.strSplit(ISNULL(@MarketIds, ''), ',')
		END

		-- write log
		SET @Xml = (
				SELECT CASE 
						WHEN ISNULL(@OldChannel, '') <> ISNULL(@Channel, '') THEN @OldChannel
						ELSE NULL
						END AS '@c'
					,CASE 
						WHEN ISNULL(@OldWB, '') <> ISNULL(@WB, '') THEN @OldWB
						ELSE NULL
						END AS '@wb'
					,CASE 
						WHEN ISNULL(@OldPhone, '') <> ISNULL(@Phone, '') THEN @OldPhone
						ELSE NULL
						END AS '@p'
					,CASE 
						WHEN ISNULL(@OldRemark, '') <> ISNULL(@Remark, '') THEN @OldRemark
						ELSE NULL
						END AS '@r'
					,CASE 
						WHEN ISNULL(@OldNoOfHDP, '') <> ISNULL(@NoOfHDP, '') THEN @OldNoOfHDP
						ELSE NULL
						END AS '@nhdp'
					,CASE 
						WHEN ISNULL(@OldIsSoloMatch, '') <> ISNULL(@IsSoloMatch, '') THEN @OldIsSoloMatch
						ELSE NULL
						END AS '@ism'
					,CASE 
						WHEN ISNULL(@OldKOTimeRemark, '') <> ISNULL(@KOTimeRemark, '') THEN @OldKOTimeRemark
						ELSE NULL
						END AS '@kotr'
					,CASE 
						WHEN ISNULL(@OldRound, '') <> ISNULL(@Round, '') THEN @OldRound
						ELSE NULL
						END AS '@ro'
					,CASE 
						WHEN ISNULL(@OldDivision, '') <> ISNULL(@Division, '') THEN @OldDivision
						ELSE NULL
						END AS '@d'
					,CASE 
						WHEN ISNULL(@OldVenue, '') <> ISNULL(@Venue, '') THEN @OldVenue
						ELSE NULL
						END AS '@v'
					,CASE 
						WHEN ISNULL(@OldOtherTime, '') <> ISNULL(CAST(@OtherTime AS TIME), '') THEN @OldOtherTime
						ELSE NULL
						END AS '@ot'
					,CASE 
						WHEN ISNULL(@OldTVIds, '') <> ISNULL(@TVIds, '') THEN @OldTVIds
						ELSE NULL
						END AS '@tvids'
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
					,CASE 
						WHEN ISNULL(@OldAgentIds, '') <> ISNULL(@AgentIds, '') THEN @OldAgentIds
						ELSE NULL
						END AS 'a'
				FOR XML PATH('z')
					,ROOT('r')
				)
		SET @OldData = REPLACE(CONVERT(NVARCHAR(MAX), @Xml), '" />', '"/"')
		SET @Xml = (
				SELECT CASE 
						WHEN ISNULL(@OldChannel, '') <> ISNULL(@Channel, '') THEN @Channel
						ELSE NULL
						END AS '@c'
					,CASE 
						WHEN ISNULL(@OldWB, '') <> ISNULL(@WB, '') THEN @WB
						ELSE NULL
						END AS '@wb'
					,CASE 
						WHEN ISNULL(@OldPhone, '') <> ISNULL(@Phone, '') THEN @Phone
						ELSE NULL
						END AS '@p'
					,CASE 
						WHEN ISNULL(@OldRemark, '') <> ISNULL(@Remark, '') THEN @Remark
						ELSE NULL
						END AS '@r'
					,CASE 
						WHEN ISNULL(@OldNoOfHDP, '') <> ISNULL(@NoOfHDP, '') THEN @NoOfHDP
						ELSE NULL
						END AS '@nhdp'
					,CASE 
						WHEN ISNULL(@OldIsSoloMatch, '') <> ISNULL(@IsSoloMatch, '') THEN @IsSoloMatch
						ELSE NULL
						END AS '@ism'
					,CASE 
						WHEN ISNULL(@OldKOTimeRemark, '') <> ISNULL(@KOTimeRemark, '') THEN @KOTimeRemark
						ELSE NULL
						END AS '@kotr'
					,CASE 
						WHEN ISNULL(@OldRound, '') <> ISNULL(@Round, '') THEN @Round
						ELSE NULL
						END AS '@ro'
					,CASE 
						WHEN ISNULL(@OldDivision, '') <> ISNULL(@Division, '') THEN @Division
						ELSE NULL
						END AS '@d'
					,CASE 
						WHEN ISNULL(@OldVenue, '') <> ISNULL(@Venue, '') THEN @Venue
						ELSE NULL
						END AS '@v'
					,CASE 
						WHEN ISNULL(@OldOtherTime, '') <> ISNULL(CAST(@OtherTime AS TIME), '') THEN CAST(@OtherTime AS TIME)
						ELSE NULL
						END AS '@ot'
					,CASE 
						WHEN ISNULL(@OldTVIds, '') <> ISNULL(@TVIds, '') THEN @TVIds
						ELSE NULL
						END AS '@tvids'
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
					,CASE 
						WHEN ISNULL(@OldAgentIds, '') <> ISNULL(@AgentIds, '') THEN @AgentIds
						ELSE NULL
						END AS 'a'
				FOR XML PATH('z')
					,ROOT('r')
				)
		SET @NewData = REPLACE(CONVERT(NVARCHAR(MAX), @Xml), '" />', '"/"')
		SET @EndRun = GETDATE()
		SET @Duration = DATEDIFF(MILLISECOND, @StartRun, @EndRun)

		EXEC dbo.OWP_WriteLog @CreatorId = @UserId
			,@SPName = 'OWP_LiveDetail_MatchInfo_Update'
			,@LoggedDate = @StartRun
			,@Duration = @Duration
			,@ObjectId = @OWPMatchId
			,@Data = @NewData
			,@DataOld = @OldData
	END TRY

	BEGIN CATCH
		SELECT @ErrMsg = 'Update Match Info failed. Please try again.'
			,@ErrCode = 5001 -- ActionId + 01

		RETURN
	END CATCH
END