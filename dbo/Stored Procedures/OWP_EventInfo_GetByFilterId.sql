/*<info serverAlias="DBOWP-bodb_OWP" executers="bodbOWPNet" isFunction="0"></info>*/
CREATE PROCEDURE [dbo].[OWP_EventInfo_GetByFilterId] @FilterId INT
	,@ShowAll BIT = 0
AS
/*
Created: 20161223@Tim.Trinh
Task : get event information by filterid
DB: bodb_OWP

Param's Explanation:

Revisions:
	20181009@Raymond.Le: New structure of event assignment - [Redmine: #92868]
	20181026@Raymond.Le: Enhance performance page Live Game List - [Redmine: #103598]
	20181106@Raymond.Le: Remove paging in SP - [Redmine: #104291]
*/
BEGIN
	SET NOCOUNT ON

	-- filter
	DECLARE @EventDate DATE
		,@HomeName NVARCHAR(500)
		,@AwayName NVARCHAR(500)
		,@WatchBet NVARCHAR(500)
		,@Phone NVARCHAR(50)
		,@Channel NVARCHAR(100)
		,@FromTime TIME
		,@ToTime TIME
		,@FromMaxBet MONEY
		,@ToMaxBet MONEY
		,@FromSpread SMALLMONEY
		,@ToSpread SMALLMONEY
		,@LeagueIds NVARCHAR(MAX)
		,@AssigneeIds NVARCHAR(MAX)
		,@AgentIds NVARCHAR(MAX)
		,@ProviderIds NVARCHAR(MAX)
		,@RunnerIds NVARCHAR(MAX)
		,@TVIds NVARCHAR(MAX)
		,@MatchNumber NVARCHAR(50)
		,@Remark NVARCHAR(500) 
		,@AssigneeLocation INT
		,@MatchStatusIds NVARCHAR(20) 

	-- get filter
	SET @EventDate = dbo.fnc_GetEventDateFilter(@FilterId)
	SET @HomeName = dbo.fnc_GetValueFilter(@FilterId, 'HomeTeam')
	SET @AwayName = dbo.fnc_GetValueFilter(@FilterId, 'AwayTeam')
	SET @WatchBet = dbo.fnc_GetValueFilter(@FilterId, 'WatchBet')
	SET @Channel = dbo.fnc_GetValueFilter(@FilterId, 'Channel')
	SET @Phone = dbo.fnc_GetValueFilter(@FilterId, 'Phone')
	SET @LeagueIds = dbo.fnc_GetValueFilter(@FilterId, 'League')
	SET @AssigneeIds = dbo.fnc_GetValueFilter(@FilterId, 'Assignee')
	SET @AgentIds = dbo.fnc_GetValueFilter(@FilterId, 'Agent')
	SET @ProviderIds = dbo.fnc_GetValueFilter(@FilterId, 'Provider')
	SET @RunnerIds = dbo.fnc_GetValueFilter(@FilterId, 'Runner')
	SET @TVIds = dbo.fnc_GetValueFilter(@FilterId, 'TV')
	SET @MatchNumber = dbo.fnc_GetValueFilter(@FilterId, 'MatchNumber')
	SET @Remark = dbo.fnc_GetValueFilter(@FilterId, 'Remark')
	SET @AssigneeLocation = ISNULL(dbo.fnc_GetValueFilter(@FilterId, 'AssigneeLocation'), -1)
	SET @MatchStatusIds = dbo.fnc_GetValueFilter(@FilterId, 'MatchStatus')

	SELECT TOP 1 @FromTime = FromTime
		,@ToTime = ToTime
	FROM dbo.fnc_GetKickOffTimeFilter(@FilterId)

	SELECT TOP 1 @FromMaxBet = FromMaxBet
		,@ToMaxBet = ToMaxBet
	FROM dbo.fnc_GetMaxBetFilter(@FilterId)

	SELECT TOP 1 @FromSpread = FromSpread
		,@ToSpread = ToSpread
	FROM dbo.fnc_GetSpreadFilter(@FilterId)

		EXEC [dbo].[OWP_EventInfo_Get] @EventDate = @EventDate
		,@HomeName = @HomeName
		,@AwayName = @AwayName
		,@WatchBet = @WatchBet
		,@Phone = @Phone
		,@Channel = @Channel
		,@FilterFromTime = @FromTime
		,@FilterToTime = @ToTime
		,@FromMaxBet = @FromMaxBet
		,@ToMaxBet = @ToMaxBet
		,@FromSpread = @FromSpread
		,@ToSpread = @ToSpread
		,@LeagueIds = @LeagueIds
		,@AssigneeIds = @AssigneeIds
		,@AgentIds = @AgentIds
		,@ProviderIds = @ProviderIds
		,@RunnerIds = @RunnerIds
		,@TVIds = @TVIds
		,@MatchNumber = @MatchNumber
		,@Remark = @Remark
		,@AssigneeLocation = @AssigneeLocation
		,@MatchStatusIds = @MatchStatusIds
		,@ShowAll = @ShowAll
END