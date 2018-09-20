CREATE PROCEDURE [dbo].[OWP_AssignmentUploading_DetectSpecificMinorMatch] @SessionId NVARCHAR(100)
AS
/*          
 Created: 20170214@Razor.Nguyen
 Task : Insert to Assignment Uploading table
 DB: bodb_OWP          
          
 Revisions:      
    20170823@Tim.Trinh: add CancelStatus
	20171206@Raymond.Le:  Change cancel status to Match status
	20171207@Raymond.Le: Insert more info to minor match
    20180614@Leo: change datatype of column Round & OutSide to nvarchar(2000)
*/
BEGIN
	SET NOCOUNT ON

	CREATE TABLE #tblMinorBettype (
		ParentId INT
		,ChildId INT
		)

	DECLARE @MinorBettype15Mins INT = - 1
		,@MinorBettype10Mins INT = - 2

	INSERT INTO #tblMinorBettype (
		ParentId
		,ChildId
		)
	VALUES (
		- 3
		,- 5
		)
		,(
		- 6
		,- 8
		)

	CREATE TABLE #tblAssignmentUploading (
		SessionId NVARCHAR(100)
		,RowNumber INT NOT NULL
		,MatchId INT NULL
		,EventDate DATE NULL
		,KickOffTime NVARCHAR(20) NULL
		,League NVARCHAR(2000) NULL
		,Home NVARCHAR(2000) NULL
		,Away NVARCHAR(2000) NULL
		,HDP10Mins NVARCHAR(2000) NULL
		,OU10Mins NVARCHAR(2000) NULL
		,HDP15Mins NVARCHAR(2000) NULL
		,OU15Mins NVARCHAR(2000) NULL
		,MinorBettypeId INT NULL
		,TV NVARCHAR(500) NULL
		,Channel NVARCHAR(100) NULL
		,WB NVARCHAR(100) NULL
		,Agent NVARCHAR(100) NULL
		,Provider NVARCHAR(100) NULL
		,Runner NVARCHAR(100) NULL
		,Phone NVARCHAR(50) NULL
		,[Round] NVARCHAR(2000) NULL
		,OutSide NVARCHAR(2000) NULL
		,Remark NVARCHAR(2000) NULL
		,NoHDP NVARCHAR(20) NULL
		,MatchOffer NVARCHAR(50) NULL
		,OtherTime NVARCHAR(20) NULL
		,Website NVARCHAR(1000) NULL
		,Website2 NVARCHAR(1000) NULL
		,Website3 NVARCHAR(1000) NULL
		,Website4 NVARCHAR(1000) NULL
		,MatchStatus NVARCHAR(15)
		)

	INSERT #tblAssignmentUploading (
		SessionId
		,RowNumber
		,MatchId
		,EventDate
		,KickOffTime
		,League
		,Home
		,Away
		,HDP10Mins
		,OU10Mins
		,HDP15Mins
		,OU15Mins
		,MinorBettypeId
		,TV
		,Channel 
		,WB 
		,Agent 
		,Provider 
		,Runner 
		,Phone
		,[Round] 
		,OutSide 
		,Remark 
		,NoHDP
		,MatchOffer
		,OtherTime
		,Website 
		,Website2 
		,Website3 
		,Website4 
		,MatchStatus
		)
	SELECT SessionId
		,RowNumber
		,MatchId
		,EventDate
		,KickOffTime
		,League
		,Home
		,Away
		,HDP10Mins
		,OU10Mins
		,HDP15Mins
		,OU15Mins
		,MinorBettypeId
		,TV
		,Channel 
		,WB 
		,Agent 
		,Provider 
		,Runner 
		,Phone
		,[Round] 
		,OutSide 
		,Remark 
		,NoHDP
		,MatchOffer
		,OtherTime
		,Website 
		,Website2 
		,Website3 
		,Website4 
		,MatchStatus
	FROM dbo.AssignmentUploading WITH (NOLOCK)
	WHERE SessionId = @SessionId
		AND (
			LEN(LTRIM(RTRIM(HDP10Mins))) > 0
			OR LEN(LTRIM(RTRIM(OU10Mins))) > 0
			OR LEN(LTRIM(RTRIM(HDP15Mins))) > 0
			OR LEN(LTRIM(RTRIM(HDP15Mins))) > 0
			)

	--10 mins
	INSERT INTO dbo.AssignmentUploading (
		SessionId
		,RowNumber
		,EventDate
		,KickOffTime
		,League
		,Home
		,Away
		,TraderHDP
		,TraderOU
		,TV
		,Channel 
		,WB 
		,Agent 
		,Provider 
		,Runner 
		,Phone
		,[Round] 
		,OutSide 
		,Remark 
		,NoHDP
		,MatchOffer
		,OtherTime
		,Website 
		,Website2 
		,Website3 
		,Website4 
		,MatchStatus
		)
	SELECT a.SessionId
		,a.RowNumber + 1
		,a.EventDate
		,a.KickOffTime
		,REPLACE(t.League, '<name>', a.League)
		,REPLACE(t.Home, '<name>', a.Home)
		,REPLACE(t.Away, '<name>', a.Away)
		,a.HDP10Mins
		,a.OU10Mins
		,a.TV
		,a.Channel 
		,a.WB 
		,a.Agent 
		,a.Provider 
		,a.Runner 
		,a.Phone
		,a.[Round] 
		,a.OutSide 
		,a.Remark 
		,a.NoHDP
		,a.MatchOffer
		,a.OtherTime
		,a.Website 
		,a.Website2 
		,a.Website3 
		,a.Website4 
		,a.MatchStatus
	FROM #tblAssignmentUploading AS a WITH (NOLOCK)
		INNER JOIN dbo.MinorMatchTemplateSetting AS t WITH (NOLOCK) ON t.MinorBettypeId = @MinorBettype10Mins
		AND t.IsRepresented = 1
		AND t.IsActive = 1
	WHERE a.MinorBettypeId IS NULL
		AND (
			LEN(LTRIM(RTRIM(HDP10Mins))) > 0
			OR LEN(LTRIM(RTRIM(OU10Mins))) > 0
			)

	--15 mins
	INSERT dbo.AssignmentUploading (
		SessionId
		,RowNumber
		,EventDate
		,KickOffTime
		,League
		,Home
		,Away
		,TraderHDP
		,TraderOU
		,TV
		,Channel 
		,WB 
		,Agent 
		,Provider 
		,Runner 
		,Phone
		,[Round] 
		,OutSide 
		,Remark 
		,NoHDP
		,MatchOffer
		,OtherTime
		,Website 
		,Website2 
		,Website3 
		,Website4 
		,MatchStatus
		)
	SELECT a.SessionId
		,a.RowNumber + 2
		,a.EventDate
		,a.KickOffTime
		,REPLACE(t.League, '<name>', a.League)
		,REPLACE(t.Home, '<name>', a.Home)
		,REPLACE(t.Away, '<name>', a.Away)
		,a.HDP15Mins
		,a.OU15Mins
		,a.TV
		,a.Channel 
		,a.WB 
		,a.Agent 
		,a.Provider 
		,a.Runner 
		,a.Phone
		,a.[Round] 
		,a.OutSide 
		,a.Remark 
		,a.NoHDP
		,a.MatchOffer
		,a.OtherTime
		,a.Website 
		,a.Website2 
		,a.Website3 
		,a.Website4 
		,a.MatchStatus
	FROM #tblAssignmentUploading AS a WITH (NOLOCK)
		INNER JOIN dbo.MinorMatchTemplateSetting AS t WITH (NOLOCK) ON t.MinorBettypeId = @MinorBettype15Mins
		AND t.IsRepresented = 1
		AND t.IsActive = 1
	WHERE a.MinorBettypeId IS NULL
		AND (
			LEN(LTRIM(RTRIM(HDP15Mins))) > 0
			OR LEN(LTRIM(RTRIM(OU15Mins))) > 0
			)

	--15 mins for minor bettype
	INSERT dbo.AssignmentUploading (
		SessionId
		,RowNumber
		,EventDate
		,KickOffTime
		,League
		,Home
		,Away
		,TraderHDP
		,TraderOU
		,TV
		,Channel 
		,WB 
		,Agent 
		,Provider 
		,Runner 
		,Phone
		,[Round] 
		,OutSide 
		,Remark 
		,NoHDP
		,MatchOffer
		,OtherTime
		,Website 
		,Website2 
		,Website3 
		,Website4 
		,MatchStatus
		)
	SELECT a.SessionId
		,a.RowNumber + 2
		,a.EventDate
		,a.KickOffTime
		,REPLACE(t.League, '<name>', RTRIM(LEFT(a.League, LEN(a.League) - c.LeagueChars)))
		,REPLACE(t.Home, '<name>', RTRIM(LEFT(a.Home, LEN(a.Home) - c.HomeChars)))
		,REPLACE(t.Away, '<name>', RTRIM(LEFT(a.Away, LEN(a.Away) - c.AwayChars)))
		,a.HDP15Mins
		,a.OU15Mins
		,a.TV
		,a.Channel 
		,a.WB 
		,a.Agent 
		,a.Provider 
		,a.Runner 
		,a.Phone
		,a.[Round] 
		,a.OutSide 
		,a.Remark 
		,a.NoHDP
		,a.MatchOffer
		,a.OtherTime
		,a.Website 
		,a.Website2 
		,a.Website3 
		,a.Website4 
		,a.MatchStatus
	FROM #tblAssignmentUploading AS a WITH (NOLOCK)
		INNER JOIN #tblMinorBettype AS m WITH (NOLOCK) ON m.ParentId = a.MinorBettypeId
		INNER JOIN dbo.MinorMatchTemplateSetting AS t WITH (NOLOCK) ON t.MinorBettypeId = m.ChildId
		INNER JOIN (
		SELECT mmd.MinorBettypeId
			,MAX(CASE mmd.Field
					WHEN 4 THEN CAST(mmd.Value AS INT)
					END) 'LeagueChars'
			,MAX(CASE mmd.Field
					WHEN 5 THEN CAST(mmd.Value AS INT)
					END) 'HomeChars'
			,MAX(CASE mmd.Field
					WHEN 6 THEN CAST(mmd.Value AS INT)
					END) 'AwayChars'
		FROM dbo.MinorMatchDetemination AS mmd WITH (NOLOCK)
		WHERE mmd.Field IN (4, 5, 6)
		GROUP BY mmd.MinorBettypeId
		) c ON a.MinorBettypeId = c.MinorBettypeId
	WHERE t.IsRepresented = 1
		AND t.IsActive = 1
		AND (LEN(LTRIM(RTRIM(a.League))) - c.LeagueChars) > 0
		AND (LEN(LTRIM(RTRIM(a.Home))) - c.HomeChars) > 0
		AND (LEN(LTRIM(RTRIM(a.Away))) - c.AwayChars) > 0
		AND (
			LEN(LTRIM(RTRIM(HDP15Mins))) > 0
			OR LEN(LTRIM(RTRIM(OU15Mins))) > 0
			)

	DROP TABLE #tblMinorBettype

	DROP TABLE #tblAssignmentUploading
END