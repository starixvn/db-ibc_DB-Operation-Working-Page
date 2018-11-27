/*<info serverAlias="DBOWP-bodb_OWP" executers="bodbOWPNet" isFunction="0"></info>*/
CREATE PROCEDURE [dbo].[OWP_AssignmentUploading_Insert] @UserId INT
	,@SessionId VARCHAR(50)
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
	20180621@Leo.Vo: New structure of event assignment - [Redmine: #92868]
	20181015@Raymond.Le: Allow input LA trader of Next Corners, Next Booking - [Redmine: #103202]
	20181031@Raymond.Le: Replace column MatchId by InfoSiteMatchId - [Redmine: #104052] 
*/
BEGIN
	SET NOCOUNT ON

	DECLARE @idoc INT
		,@totalRule INT
		,@totalRow INT
		,@NumberDayDeleteOldData INT = 1
		,@Today DATETIME = GETDATE()


	-- remove old data
	DELETE
	FROM dbo.AssignmentUploading WITH (ROWLOCK)
	WHERE SessionId IN (
			SELECT SessionId
			FROM dbo.AssignmentUploadingLog WITH (NOLOCK)
			WHERE CreatedDate < DATEADD(DAY, - @NumberDayDeleteOldData, @Today)
			)

	DELETE
	FROM dbo.AssignmentUploadingResult WITH (ROWLOCK)
	WHERE SessionId IN (
			SELECT SessionId
			FROM dbo.AssignmentUploadingLog WITH (NOLOCK)
			WHERE CreatedDate < DATEADD(DAY, - @NumberDayDeleteOldData, @Today)
			)

	DELETE
	FROM dbo.AssignmentUploadingLog WITH (ROWLOCK)
	WHERE CreatedDate < DATEADD(DAY, - @NumberDayDeleteOldData, @Today)


	-- insert raw data
	EXEC sp_xml_preparedocument @idoc OUTPUT
		,@AssignmentUploadDoc

	INSERT INTO dbo.AssignmentUploading (
		SessionId
		,RowNumber
		,EventDate
		,MatchNo
		,MatchStatus
		,InfoSiteMatchId
		,KickOffTime
		,OtherTime
		,MatchOffer
		,League
		,Home
		,Away
		,Note
		,[Round]
		,Division
		,Remark
		,MaxBetHDP
		,SpreadHDP
		,NoHDP
		,TraderHDP
		,OtherTradersHDP
		,MaxBet1HHDP
		,Spread1HHDP
		,Trader1HHDP
		,OtherTraders1HHDP
		,MaxBetOU
		,SpreadOU
		,TraderOU
		,OtherTradersOU
		,MaxBet1HOU
		,Spread1HOU
		,Trader1HOU
		,OtherTraders1HOU
		,MaxBet1X2
		,Spread1X2
		,Trader1X2
		,OtherTraders1X2
		,MaxBet1H1X2
		,Spread1H1X2
		,Trader1H1X2
		,OtherTraders1H1X2
		,MaxBetXMins
		,SpreadXMins
		,Trader15Mins
		,OtherTraders15Mins
		,Trader10Mins
		,OtherTraders10Mins
		,LA
		,OtherLA
		,MaxBetFM
		,SpreadFM
		,TraderFM
		,OtherTradersFM
		,TraderAIO
		,OtherTradersAIO
		,Agent
		,TV
		,Channel
		,WB
		,[Provider]
		,Runner
		,Phone
		,Website1
		,Website2
		,Website3
		,Website4
		,MinorBettypeId
		,ParentRowNumber
		)
	SELECT @SessionId
		,RowNumber * 10
		,EventDate
		,MatchNo
		,MatchStatus
		,InfoSiteMatchId
		,KickOffTime
		,OtherTime
		,MatchOffer
		,LeagueName
		,HomeName
		,AwayName
		,NULLIF(Note, '')
		,[Round]
		,Division
		,Remark
		,MaxBetHDP
		,SpreadHDP
		,NoHDP
		,TraderHDP
		,NULLIF(OtherTradersHDP, '')
		,MaxBet1HHDP
		,Spread1HHDP
		,Trader1HHDP
		,NULLIF(OtherTraders1HHDP, '')
		,MaxBetOU
		,SpreadOU
		,TraderOU
		,NULLIF(OtherTradersOU, '')
		,MaxBet1HOU
		,Spread1HOU
		,Trader1HOU
		,NULLIF(OtherTraders1HOU, '')
		,MaxBet1X2
		,Spread1X2
		,Trader1X2
		,NULLIF(OtherTraders1X2, '')
		,MaxBet1H1X2
		,Spread1H1X2
		,Trader1H1X2
		,NULLIF(OtherTraders1H1X2, '')
		,MaxBetXMins
		,SpreadXMins
		,Trader15Mins
		,NULLIF(OtherTraders15Mins, '')
		,Trader10Mins
		,NULLIF(OtherTraders10Mins, '')
		,LA
		,NULLIF(OtherLA, '')
		,MaxBetFM
		,SpreadFM
		,TraderFM
		,NULLIF(OtherTradersFM, '')
		,TraderAIO
		,NULLIF(OtherTradersAIO, '')
		,Agent
		,TV
		,Channel
		,WatchBet
		,[Provider]
		,Runner
		,Phone
		,Website1
		,Website2
		,Website3
		,Website4
		,NULL
		,NULL
	FROM OPENXML(@idoc, '/Root/Row', 1) WITH (
		[RowNumber] [int]
		,[EventDate] [date]
		,[MatchNo] [varchar](50)
		,[MatchStatus] [varchar](15)
		,[InfoSiteMatchId] [nvarchar](200)
		,[KickOffTime] [nvarchar](200)
		,[OtherTime] [nvarchar](200)
		,[MatchOffer] [nvarchar](50)
		,[LeagueName] [nvarchar](2000)
		,[HomeName] [nvarchar](2000)
		,[AwayName] [nvarchar](2000)
		,[Note] [nvarchar](max)
		,[Round] [nvarchar](2000)
		,[Division] [nvarchar](2000)
		,[Remark] [nvarchar](2000)
		,[MaxBetHDP] [nvarchar](200)
		,[SpreadHDP] [nvarchar](200)
		,[NoHDP] [nvarchar](20)
		,[TraderHDP] [nvarchar](200)
		,[OtherTradersHDP] [nvarchar](max)
		,[MaxBet1HHDP] [nvarchar](200)
		,[Spread1HHDP] [nvarchar](200)
		,[Trader1HHDP] [nvarchar](200)
		,[OtherTraders1HHDP] [nvarchar](max)
		,[MaxBetOU] [nvarchar](200)
		,[SpreadOU] [nvarchar](200)
		,[TraderOU] [nvarchar](200)
		,[OtherTradersOU] [nvarchar](max)
		,[MaxBet1HOU] [nvarchar](200)
		,[Spread1HOU] [nvarchar](200)
		,[Trader1HOU] [nvarchar](200)
		,[OtherTraders1HOU] [nvarchar](max)
		,[MaxBet1X2] [nvarchar](200)
		,[Spread1X2] [nvarchar](200)
		,[Trader1X2] [nvarchar](200)
		,[OtherTraders1X2] [nvarchar](max)
		,[MaxBet1H1X2] [nvarchar](200)
		,[Spread1H1X2] [nvarchar](200)
		,[Trader1H1X2] [nvarchar](200)
		,[OtherTraders1H1X2] [nvarchar](max)
		,[MaxBetXMins] [nvarchar](200)
		,[SpreadXMins] [nvarchar](200)
		,[Trader15Mins] [nvarchar](200)
		,[OtherTraders15Mins] [nvarchar](max)
		,[Trader10Mins] [nvarchar](200)
		,[OtherTraders10Mins] [nvarchar](max)
		,[LA] [nvarchar](200)
		,[OtherLA] [nvarchar](2000)
		,[MaxBetFM] [nvarchar](200)
		,[SpreadFM] [nvarchar](200)
		,[TraderFM] [nvarchar](200)
		,[OtherTradersFM] [nvarchar](max)
		,[TraderAIO] [nvarchar](200)
		,[OtherTradersAIO] [nvarchar](max)
		,[Agent] [nvarchar](2000)
		,[TV] [nvarchar](2000)
		,[Channel] [nvarchar](100)
		,[WatchBet] [nvarchar](100)
		,[Provider] [nvarchar](2000)
		,[Runner] [nvarchar](2000)
		,[Phone] [nvarchar](50)
		,[Website1] [nvarchar](1000)
		,[Website2] [nvarchar](1000)
		,[Website3] [nvarchar](1000)
		,[Website4] [nvarchar](1000)
		)

	EXEC sp_xml_removedocument @idoc

	
	-- determine minor matches 
	EXEC dbo.OWP_AssignmentUploading_DetermineMinorMatch @SessionId

	
	-- remove 15', 10' data of minor match but not No.Of Cornor and Total Booking
	UPDATE dbo.AssignmentUploading WITH (ROWLOCK)
	SET MaxBetXMins = ''
		,SpreadXMins = ''
		,Trader15Mins = ''
		,OtherTraders15Mins = NULL
		,Trader10Mins = ''
		,OtherTraders10Mins = NULL
	WHERE SessionId = @SessionId
		AND MinorBettypeId IS NOT NULL
		AND MinorBettypeId NOT IN (-3, -6)


	-- remove FM, AIO data of minor match
	UPDATE dbo.AssignmentUploading WITH (ROWLOCK)
	SET MaxBetFM = ''
		,SpreadFM = ''
		,TraderFM = ''
		,OtherTradersFM = NULL
		,TraderAIO = ''
		,OtherTradersAIO = NULL
	WHERE SessionId = @SessionId
		AND MinorBettypeId IS NOT NULL

	-- insert minor matches 10' & 15'
	EXEC dbo.OWP_AssignmentUploading_InsertMinorMatch @SessionId

	select au.OtherTradersHDP
	FROM dbo.AssignmentUploading AS au WITH (NOLOCK)
	where SessionId = @SessionId

	
	-- insert other traders
	INSERT INTO dbo.AssignmentUploadingOtherTrader (
		SessionId
		,RowNumber
		,Bettype
		,Trader
		,Note
		)
	SELECT @SessionId
		,au.RowNumber
		,1
		,m.c.value('@u', 'nvarchar(200)') AS Trader
		,m.c.value('@n', 'nvarchar(200)') AS Note
	FROM dbo.AssignmentUploading AS au WITH (NOLOCK)
	OUTER APPLY au.OtherTradersHDP.nodes('Root/r') as m(c)
	WHERE au.SessionId = @SessionId AND au.OtherTradersHDP IS NOT NULL
	UNION ALL
	SELECT @SessionId
		,au.RowNumber
		,3
		,m.c.value('@u', 'nvarchar(200)') AS Trader
		,m.c.value('@n', 'nvarchar(200)') AS Note
	FROM dbo.AssignmentUploading AS au WITH (NOLOCK)
	OUTER APPLY au.OtherTradersOU.nodes('Root/r') as m(c)
	WHERE au.SessionId = @SessionId AND au.OtherTradersOU IS NOT NULL
	UNION ALL
	SELECT @SessionId
		,au.RowNumber
		,5
		,m.c.value('@u', 'nvarchar(200)') AS Trader
		,m.c.value('@n', 'nvarchar(200)') AS Note
	FROM dbo.AssignmentUploading AS au WITH (NOLOCK)
	OUTER APPLY au.OtherTraders1X2.nodes('Root/r') as m(c)
	WHERE au.SessionId = @SessionId AND au.OtherTraders1X2 IS NOT NULL
	UNION ALL
	SELECT @SessionId
		,au.RowNumber
		,7
		,m.c.value('@u', 'nvarchar(200)') AS Trader
		,m.c.value('@n', 'nvarchar(200)') AS Note
	FROM dbo.AssignmentUploading AS au WITH (NOLOCK)
	OUTER APPLY au.OtherTraders1HHDP.nodes('Root/r') as m(c)
	WHERE au.SessionId = @SessionId AND au.OtherTraders1HHDP IS NOT NULL
	UNION ALL
	SELECT @SessionId
		,au.RowNumber
		,8
		,m.c.value('@u', 'nvarchar(200)') AS Trader
		,m.c.value('@n', 'nvarchar(200)') AS Note
	FROM dbo.AssignmentUploading AS au WITH (NOLOCK)
	OUTER APPLY au.OtherTraders1HOU.nodes('Root/r') as m(c)
	WHERE au.SessionId = @SessionId AND au.OtherTraders1HOU IS NOT NULL
	UNION ALL
	SELECT @SessionId
		,au.RowNumber
		,15
		,m.c.value('@u', 'nvarchar(200)') AS Trader
		,m.c.value('@n', 'nvarchar(200)') AS Note
	FROM dbo.AssignmentUploading AS au WITH (NOLOCK)
	OUTER APPLY au.OtherTraders1H1X2.nodes('Root/r') as m(c)
	WHERE au.SessionId = @SessionId AND au.OtherTraders1H1X2 IS NOT NULL
	UNION ALL
	SELECT @SessionId
		,au.RowNumber
		,-1002
		,m.c.value('@u', 'nvarchar(200)') AS Trader
		,m.c.value('@n', 'nvarchar(200)') AS Note
	FROM dbo.AssignmentUploading AS au WITH (NOLOCK)
	OUTER APPLY au.OtherLA.nodes('Root/r') as m(c)
	WHERE au.SessionId = @SessionId AND au.OtherLA IS NOT NULL


	-- calculate total row for processing (for notify about % complete when validating rules)
	SELECT @totalRow = COUNT(1)
	FROM dbo.AssignmentUploading WITH (NOLOCK)
	WHERE SessionId = @SessionId

	SELECT @totalRule = COUNT(1)
	FROM dbo.FunctionRule AS fr WITH (NOLOCK)
	INNER JOIN dbo.[Function] AS f WITH (NOLOCK) ON f.FunctionId = fr.FunctionId
	INNER JOIN dbo.ValidationRule AS r WITH (NOLOCK) ON r.RuleId = fr.RuleId
	WHERE f.FunctionName = 'AssignmentUploading'
		AND r.IsActive = 1
		
	INSERT INTO dbo.AssignmentUploadingLog (
		SessionId
		,UserId
		,TotalRowResult
		,[Status]
		)
	VALUES (
		@SessionId
		,@UserId
		,@totalRow * @totalRule
		,0
		)
END