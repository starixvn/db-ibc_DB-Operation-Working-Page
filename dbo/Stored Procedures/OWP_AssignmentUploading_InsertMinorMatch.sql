/*<info serverAlias="DBOWP-bodb_OWP" executers="bodbOWPNet" isFunction="0"></info>*/
CREATE PROCEDURE [dbo].[OWP_AssignmentUploading_InsertMinorMatch] @SessionId VARCHAR(50)
AS
/*          
 Created: 20180622@Leo
 Task : Insert to Assignment Uploading table
 DB: bodb_OWP          
          
 Revisions:
	20181009@Raymond.Le: new structure      
*/
BEGIN
	SET NOCOUNT ON

	CREATE TABLE #tblMinorBettypeForMainMatch (
		MinorBettypeId INT
		,MinorRowIndex SMALLINT
		,RowNumber INT
		,MaxBetHDP NVARCHAR(200)
		,SpreadHDP NVARCHAR(200)
		,TraderHDP NVARCHAR(200)
		,OtherTradersHDP XML
		)

	CREATE TABLE #tbl15MinsForMinorBettype (
		ParentId INT
		,ChildId INT
		)


	--data to create minor matches for main matches
	INSERT INTO #tblMinorBettypeForMainMatch(
		MinorBettypeId
		,MinorRowIndex
		,RowNumber
		,MaxBetHDP
		,SpreadHDP
		,TraderHDP
		,OtherTradersHDP
		)
	SELECT -1, 1, a.RowNumber, a.MaxBetXMins, a.SpreadXMins, a.Trader15Mins, a.OtherTraders15Mins
	FROM dbo.AssignmentUploading AS a WITH (NOLOCK)
	WHERE a.SessionId = @SessionId
		AND a.MinorBettypeId IS NULL
		AND (a.Trader15Mins <> '' OR a.OtherTraders15Mins IS NOT NULL OR a.MaxBetXMins <> '' OR a.SpreadXMins <> '')
	UNION ALL
	SELECT -2, 2, a.RowNumber, a.MaxBetXMins, a.SpreadXMins, a.Trader10Mins, a.OtherTraders10Mins
	FROM dbo.AssignmentUploading AS a WITH (NOLOCK)
	WHERE a.SessionId = @SessionId
		AND a.MinorBettypeId IS NULL
		AND (a.Trader10Mins <> '' OR a.OtherTraders10Mins IS NOT NULL OR a.MaxBetXMins <> '' OR a.SpreadXMins <> '')
	UNION ALL
	SELECT -88, 3, a.RowNumber, a.MaxBetFM, a.SpreadFM, a.TraderFM, a.OtherTradersFM
	FROM dbo.AssignmentUploading AS a WITH (NOLOCK)
	WHERE a.SessionId = @SessionId
		AND a.MinorBettypeId IS NULL
	UNION ALL
	SELECT -89, 4, a.RowNumber, '', '', a.TraderAIO, a.OtherTradersAIO
	FROM dbo.AssignmentUploading AS a WITH (NOLOCK)
	WHERE a.SessionId = @SessionId
		AND a.MinorBettypeId IS NULL


	--Insert rows for minor matches of main matches
	INSERT INTO dbo.AssignmentUploading (
		SessionId
		,RowNumber
		,EventDate
		,KickOffTime
		,League
		,Home
		,Away
		,MaxBetHDP
		,SpreadHDP
		,TraderHDP
		,OtherTradersHDP
		,MatchStatus
		,ParentRowNumber
		,MinorBettypeId
		)
	SELECT a.SessionId
		,a.RowNumber + mb.MinorRowIndex
		,a.EventDate
		,a.KickOffTime
		,REPLACE(t.League, '<name>', a.League)
		,REPLACE(t.Home, '<name>', a.Home)
		,REPLACE(t.Away, '<name>', a.Away)
		,mb.MaxBetHDP
		,mb.SpreadHDP
		,mb.TraderHDP
		,mb.OtherTradersHDP
		,a.MatchStatus
		,a.RowNumber
		,t.MinorBettypeId
	FROM dbo.AssignmentUploading AS a WITH (NOLOCK)
	INNER JOIN #tblMinorBettypeForMainMatch AS mb ON mb.RowNumber = a.RowNumber
		AND a.SessionId = @SessionId
	INNER JOIN dbo.MinorMatchTemplateSetting AS t WITH (NOLOCK) ON t.MinorBettypeId = mb.MinorBettypeId
		AND t.IsActive = 1


	-- mapping bettype 15' of minor bettypes No. Of Corner & Total Booking
	INSERT INTO #tbl15MinsForMinorBettype (
		ParentId
		,ChildId
		)
	VALUES (-3, -5)
		,(-6,-8)


	--Insert minor matches 15 mins for minor bettypes 'No. Of Corner' & 'Total Booking'
	INSERT dbo.AssignmentUploading (
		SessionId
		,RowNumber
		,EventDate
		,KickOffTime
		,League
		,Home
		,Away
		,MaxBetHDP
		,SpreadHDP
		,TraderHDP
		,OtherTradersHDP
		,MatchStatus
		,ParentRowNumber
		,MinorBettypeId
		)
	SELECT a.SessionId
		,a.RowNumber + 1
		,a.EventDate
		,a.KickOffTime
		,REPLACE(t.League, '<name>', a2.League)
		,REPLACE(t.Home, '<name>', a2.Home)
		,REPLACE(t.Away, '<name>', a2.Away)
		,a.MaxBetXMins
		,a.SpreadXMins
		,a.Trader15Mins
		,a.OtherTraders15Mins
		,a.MatchStatus
		,a.ParentRowNumber
		,mb.ChildId
	FROM dbo.AssignmentUploading AS a WITH (NOLOCK)
	INNER JOIN dbo.AssignmentUploading AS a2 WITH (NOLOCK) ON a.SessionId = a2.SessionId
		AND a.ParentRowNumber = a2.RowNumber
	INNER JOIN #tbl15MinsForMinorBettype AS mb ON a.MinorBettypeId = mb.ParentId
	INNER JOIN dbo.MinorMatchTemplateSetting AS t WITH (NOLOCK) ON t.MinorBettypeId = mb.ChildId
		AND t.IsActive = 1
	WHERE a.SessionId = @SessionId
		AND a.MinorBettypeId IN (-3, -6)
		AND (a.Trader15Mins <> '' OR a.OtherTraders15Mins IS NOT NULL OR a.MaxBetXMins <> '' OR a.SpreadXMins <> '')


	-- drop tables
	DROP TABLE #tblMinorBettypeForMainMatch
	DROP TABLE #tbl15MinsForMinorBettype

END