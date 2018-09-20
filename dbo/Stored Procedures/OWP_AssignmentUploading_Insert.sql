CREATE PROCEDURE [dbo].[OWP_AssignmentUploading_Insert] @SessionId NVARCHAR(100)
	,@UserId INT = 0
	,@AssignmentUploadDoc NVARCHAR(MAX)
AS
/*          
 Created: 20170214@Razor.Nguyen
 Task : Insert to Assignment Uploading table
 DB: bodb_OWP          

 Revisions:      
    20170504@Tim.Trinh: limit data length
    20170724@Tim.Trinh: add CancelStatus, Round, Division, Remark, NoHDP, MatchOffer column
    20171012@Tim.Trinh: add OtherTime, Website, Website2, Website3, Website4 column,
	20180416@leo.vo: add FM, AIO
    20180614@Leo: change datatype of column Round & OutSide to nvarchar(2000)
*/
BEGIN
	SET NOCOUNT ON

	DECLARE @idoc INT
		,@totalRule INT
		,@totalRow INT
		,@NumberDayDeleteOldData INT = 1
		,@Today DATETIME = GETDATE()

		,@str_Live NVARCHAR(15) = 'Live'
		,@str_Cancel NVARCHAR(15) = 'Cancel'
		,@str_Postponed NVARCHAR(15) = 'Postponed'
		,@str_Suspended NVARCHAR(15) = 'Suspended'
	EXEC sp_xml_preparedocument @idoc OUTPUT
		,@AssignmentUploadDoc

	DELETE
	FROM dbo.AssignmentUploading WITH (UPDLOCK)
	WHERE SessionId IN (
			SELECT SessionId
			FROM dbo.AssignmentUploadingLog WITH (NOLOCK)
			WHERE DATEDIFF(DD, CreatedDate, @Today) > @NumberDayDeleteOldData
			)

	DELETE
	FROM dbo.AssignmentUploadingResult WITH (UPDLOCK)
	WHERE SessionId IN (
			SELECT SessionId
			FROM dbo.AssignmentUploadingLog WITH (NOLOCK)
			WHERE DATEDIFF(DD, CreatedDate, @Today) > @NumberDayDeleteOldData
			)

	DELETE
	FROM dbo.AssignmentUploadingLog WITH (UPDLOCK)
	WHERE DATEDIFF(DD, CreatedDate, @Today) > @NumberDayDeleteOldData

	INSERT INTO dbo.AssignmentUploading (
		SessionId
		,RowNumber
		,MatchNo
		,MatchId
		,EventDate
		,KickOffTime
		,OtherTime
		,League
		,Home
		,Away
		,MatchStatus
		,[Round]
		,OutSide
		,Remark
		,Note
		,MaxBetHDP
		,SpreadHDP
		,NoHDP
		,TraderHDP
		,StandbyHDP
		,OtherTimeHDP
		,ETPKHDP
		,MaxBet1HHDP
		,Spread1HHDP
		,Trader1HHDP
		,Standby1HHDP
		,OtherTime1HHDP
		,MaxBetOU
		,SpreadOU
		,TraderOU
		,StandbyOU
		,OtherTimeOU
		,ETPKOU
		,MaxBet1HOU
		,Spread1HOU
		,Trader1HOU
		,Standby1HOU
		,OtherTime1HOU
		,MaxBet1X2
		,Spread1X2
		,Trader1X2
		,Standby1X2
		,OtherTime1X2
		,MaxBet1H1X2
		,Spread1H1X2
		,Trader1H1X2
		,Standby1H1X2
		,OtherTime1H1X2
		,HDP10Mins
		,OU10Mins
		,HDP15Mins
		,OU15Mins
		,LA1H
		,Standby1HLA
		,OtherTime1HLA
		,ETPK1HLA
		,LA2H
		,Standby2HLA
		,OtherTime2HLA
		,ETPK2HLA
		,FM
		,AIO
		,TV
		,Channel
		,WB
		,Agent
		,Provider
		,Runner
		,Phone
		,MatchOffer
		,Website
		,Website2
		,Website3
		,Website4
		,MinorBettypeId
		,ParentMatchId
		,ParentRowNumber
		)
	SELECT @SessionId
		,Data.RowNum * 10
		,Data.MatchNo
		,Data.MatchId
		,Data.EventDate
		,Data.KickOffTime
		,Data.OtherTime
		,Data.LeagueName
		,Data.HomeName
		,Data.AwayName
		,(CASE 
			WHEN ISNULL(Data.MatchStatus, '') = '' 
				OR LOWER(LTRIM(RTRIM(Data.MatchStatus))) = 'live' 
				OR LOWER(LTRIM(RTRIM(Data.MatchStatus))) = 'in-play' 
				OR LOWER(LTRIM(RTRIM(Data.MatchStatus))) = 'completed' THEN @str_Live
			WHEN LOWER(LTRIM(RTRIM(Data.MatchStatus))) = 'cancel' THEN @str_Cancel
			WHEN LOWER(LTRIM(RTRIM(Data.MatchStatus))) = 'postponed' THEN @str_Postponed
			WHEN LOWER(LTRIM(RTRIM(Data.MatchStatus))) = 'suspended' THEN @str_Suspended
			ELSE Data.MatchStatus END
		)
		,Data.[Round]
		,Data.OutSide
		,Data.Remark
		,Data.Note
		,Data.HdpMaxBet
		,Data.HdpSpread
		,Data.NoHDP
		,Data.HdpTrader
		,Data.HdpStandBy
		,Data.HdpOtherTime
		,Data.HdpEtpk
		,Data.Hdp1HMaxBet
		,Data.Hdp1HSpread
		,Data.Hdp1HTrader
		,Data.Hdp1HStandBy
		,Data.Hdp1HOtherTime
		,Data.OUMaxBet
		,Data.OUSpread
		,Data.OUTrader
		,Data.OUStandBy
		,Data.OUOtherTime
		,Data.OUEtpk
		,Data.OU1HMaxBet
		,Data.OU1HSpread
		,Data.OU1HTrader
		,Data.OU1HStandBy
		,Data.OU1HOtherTime
		,Data.OneXTwoMaxBet
		,Data.OneXTwoSpread
		,Data.OneXTwoTrader
		,Data.OneXTwoStandBy
		,Data.OneXTwoOtherTime
		,Data.OneXTwo1HMaxBet
		,Data.OneXTwo1HSpread
		,Data.OneXTwo1HTrader
		,Data.OneXTwo1HStandBy
		,Data.OneXTwo1HOtherTime
		,Data.HDP10Mins
		,Data.OU10Mins
		,Data.HDP15Mins
		,Data.OU15Mins
		,Data.LA1HTrader
		,Data.LA1HStandBy
		,Data.LA1HOtherTime
		,Data.LA1HEtpk
		,Data.LA2HTrader
		,Data.LA2HStandBy
		,Data.LA2HOtherTime
		,Data.LA2HEtpk
		,Data.FM
		,Data.AIO
		,Data.TVCode
		,Data.Channel
		,Data.WatchBet
		,Data.Agent
		,Data.Provider
		,Data.Runner
		,Data.Phone
		,Data.MatchOffer
		,Data.Website
		,Data.Website2
		,Data.Website3
		,Data.Website4
		,NULL
		,NULL
		,NULL
	FROM OPENXML(@idoc, '/Root/Row', 1) WITH (
			RowNum INT, MatchNo NVARCHAR(2000), MatchId NVARCHAR(2000), EventDate NVARCHAR(2000), KickOffTime NVARCHAR(20), OtherTime NVARCHAR(20),
			LeagueName NVARCHAR(2000), HomeName NVARCHAR(200), AwayName NVARCHAR(200), MatchStatus NVARCHAR(15),
			[Round] NVARCHAR(2000), OutSide NVARCHAR(2000), Remark NVARCHAR(2000), Note NVARCHAR(MAX),
			HdpMaxBet NVARCHAR(200), HdpSpread NVARCHAR(200), NoHDP NVARCHAR(10), HdpTrader NVARCHAR(100), HdpStandBy NVARCHAR(100), HdpOtherTime NVARCHAR(100), HdpEtpk NVARCHAR(100),
			Hdp1HMaxBet NVARCHAR(200), Hdp1HSpread NVARCHAR(200), Hdp1HTrader NVARCHAR(100), Hdp1HStandBy NVARCHAR(100), Hdp1HOtherTime NVARCHAR(100),
			OUMaxBet NVARCHAR(200), OUSpread NVARCHAR(200), OUTrader NVARCHAR(100), OUStandBy NVARCHAR(100), OUOtherTime NVARCHAR(100), [OUEtpk] NVARCHAR(100),
			OU1HMaxBet NVARCHAR(200), OU1HSpread NVARCHAR(200), OU1HTrader NVARCHAR(100), OU1HStandBy NVARCHAR(100), OU1HOtherTime NVARCHAR(100),
			OneXTwoMaxBet NVARCHAR(200), OneXTwoSpread NVARCHAR(200), OneXTwoTrader NVARCHAR(100), OneXTwoStandBy NVARCHAR(100), OneXTwoOtherTime NVARCHAR(100),
			OneXTwo1HMaxBet NVARCHAR(200), OneXTwo1HSpread NVARCHAR(200), OneXTwo1HTrader NVARCHAR(100), OneXTwo1HStandBy NVARCHAR(100), OneXTwo1HOtherTime NVARCHAR(100),
			Hdp10Mins NVARCHAR(100), OU10Mins NVARCHAR(100), Hdp15Mins NVARCHAR(100), OU15Mins NVARCHAR(100),
			LA1HTrader NVARCHAR(100), LA1HStandBy NVARCHAR(100), LA1HOtherTime NVARCHAR(100), LA1HEtpk NVARCHAR(100),
			LA2HTrader NVARCHAR(100), LA2HStandBy NVARCHAR(100), LA2HOtherTime NVARCHAR(100), LA2HEtpk NVARCHAR(100),
			FM NVARCHAR(100), AIO NVARCHAR(100),
			TVCode NVARCHAR(500), Channel NVARCHAR(100), WatchBet NVARCHAR(100), Agent NVARCHAR(100),
			Provider NVARCHAR(100), Runner NVARCHAR(100), Phone NVARCHAR(50), MatchOffer NVARCHAR(50),
			Website NVARCHAR(1000), Website2 NVARCHAR(1000), Website3 NVARCHAR(1000), Website4 NVARCHAR(1000)
			) AS Data

	EXEC sp_xml_removedocument @idoc

	SELECT @totalRule = COUNT(1)
	FROM dbo.FunctionRule AS fr WITH (NOLOCK)
		INNER JOIN dbo.[Function] AS f WITH (NOLOCK) ON f.FunctionId = fr.FunctionId
		INNER JOIN dbo.ValidationRule AS r WITH (NOLOCK) ON r.RuleId = fr.RuleId
	WHERE f.FunctionName = 'AssignmentUploading'
		AND r.IsActive = 1

	-- run the first times to find Major, minor bettype
	EXEC dbo.OWP_MinorMatchDetermineBySession @SessionId

	EXEC dbo.OWP_AssignmentUploading_DetectSpecificMinorMatch @SessionId

	-- run the second to find minor bettype of above specific minor match
	EXEC dbo.[OWP_MinorMatchDetermineBySession] @SessionId

	SELECT @totalRow = COUNT(1)
	FROM dbo.AssignmentUploading WITH (NOLOCK)
	WHERE SessionId = @SessionId

	INSERT INTO dbo.AssignmentUploadingLog (
		SessionId
		,UserId
		,TotalRowResult
		,CreatedDate
		,StartDate
		,EndDate
		,[Status]
		,LogMessage
		)
	VALUES (
		@SessionId
		,@UserId
		,@totalRow * @totalRule
		,GETDATE()
		,NULL
		,NULL
		,0
		,''
		)
END