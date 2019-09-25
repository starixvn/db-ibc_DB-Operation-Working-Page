
/*<info serverAlias="DBOWP-bodb_OWP" executers="bodbOWPNet" isFunction="0"></info>*/
CREATE PROCEDURE [dbo].[OWP_LiveDetail_Update_ProviderInfoRelaventMatch] @ActorId INT
	,@SessionId NVARCHAR(100)
	,@OWPMatchId INT
	,@ItemsApplyForRelativeMatch NVARCHAR(100)
	,@ErrCode INT = 0 OUTPUT
	,@ErrMsg NVARCHAR(200) = '' OUTPUT
AS
/*
Created: 20190919@Carlos.Nguyen
Task : update new Provider Info relative  
DB: bodb_OWP

Revisions:    
	20190919@Carlos.Nguyen: init SP - [Redmine: #120593]
*/
BEGIN
	SET NOCOUNT ON

	DECLARE @MatchId INT
		,@TVIdsCurrent NVARCHAR(500)
		,@ChannelCurrent NVARCHAR(100)
		,@WBCurrent NVARCHAR(100)
		,@ProviderIdsCurrent NVARCHAR(100)
		,@OtherProviderIdsCurrent NVARCHAR(100)
		,@AgentIdsCurrent NVARCHAR(100)
		,@PhoneCurrent NVARCHAR(200)
		,@NewChannel NVARCHAR(100)
		,@NewWB NVARCHAR(100)
		,@NewPhone NVARCHAR(200)
		,@NewTVIds NVARCHAR(500)
		,@NewOtherProviderIds NVARCHAR(100)
		,@NewProviderIds NVARCHAR(100)
		,@NewAgentIds NVARCHAR(100)
		,@ParentMatchId INT

	CREATE TABLE #tblMatchIdRelative (
		Id INT IDENTITY PRIMARY KEY CLUSTERED
		,MatchId INT
		)

	INSERT INTO #tblMatchIdRelative (MatchId)
	EXEC [dbo].[OWP_Find_RelevantMatches] @OWPMatchId

	SELECT TOP 1 @NewChannel = m.Channel
		,@NewWB = m.WB
		,@NewPhone = m.Phone
	FROM dbo.MatchInfo m WITH (NOLOCK)
	WHERE m.OWPMatchId = @OWPMatchId

	SELECT @NewTVIds = ISNULL(STUFF((
					SELECT ', ' + CAST(TVId AS NVARCHAR)
					FROM dbo.MatchTelevision WITH (NOLOCK)
					WHERE OWPMatchId = @OWPMatchId
					FOR XML PATH('')
					), 1, 2, ''), '')

	SELECT @NewOtherProviderIds = ISNULL(STUFF((
					SELECT ', ' + CAST(OtherProviderId AS NVARCHAR)
					FROM dbo.MatchOtherProvider WITH (NOLOCK)
					WHERE OWPMatchId = @OWPMatchId
					FOR XML PATH('')
					), 1, 2, ''), '')

	SELECT @NewProviderIds = ISNULL(STUFF((
					SELECT ', ' + CAST(ProviderId AS NVARCHAR)
					FROM dbo.MatchProvider WITH (NOLOCK)
					WHERE OWPMatchId = @OWPMatchId
					FOR XML PATH('')
					), 1, 2, ''), '')

	SELECT @NewAgentIds = ISNULL(STUFF((
					SELECT ', ' + CAST(AgentId AS NVARCHAR)
					FROM dbo.MatchAgent WITH (NOLOCK)
					WHERE OWPMatchId = @OWPMatchId
					FOR XML PATH('')
					), 1, 2, ''), '')

	DECLARE @maxRowCount INT
		,@rowStart INT = 1

	SELECT @maxRowCount = COUNT(MatchId)
	FROM #tblMatchIdRelative

	WHILE (@rowStart <= @maxRowCount)
	BEGIN
		SELECT TOP 1 @MatchId = m.MatchId
		FROM #tblMatchIdRelative AS m WITH (NOLOCK)
		WHERE m.Id = @rowStart

		SELECT TOP 1 @TVIdsCurrent = ISNULL(STUFF((
						SELECT ', ' + CAST(tv.TVId AS NVARCHAR)
						FROM dbo.MatchTelevision AS tv WITH (NOLOCK)
						WHERE tv.OWPMatchId = @MatchId
						FOR XML PATH('')
						), 1, 2, ''), '')
			,@ChannelCurrent = mi.Channel
			,@WBCurrent = mi.WB
			,@ProviderIdsCurrent = ISNULL(STUFF((
						SELECT ', ' + CAST(ProviderId AS NVARCHAR)
						FROM dbo.MatchProvider AS p WITH (NOLOCK)
						WHERE p.OWPMatchId = @MatchId
						FOR XML PATH('')
						), 1, 2, ''), '')
			,@OtherProviderIdsCurrent = ISNULL(STUFF((
						SELECT ', ' + CAST(OtherProviderId AS NVARCHAR)
						FROM dbo.MatchOtherProvider AS mo WITH (NOLOCK)
						WHERE mo.OWPMatchId = @MatchId
						FOR XML PATH('')
						), 1, 2, ''), '')
			,@AgentIdsCurrent = ISNULL(STUFF((
						SELECT ', ' + CAST(AgentId AS NVARCHAR)
						FROM dbo.MatchAgent AS ag WITH (NOLOCK)
						WHERE ag.OWPMatchId = @MatchId
						FOR XML PATH('')
						), 1, 2, ''), '')
			,@PhoneCurrent = mi.Phone
		FROM dbo.MatchInfo AS mi WITH (NOLOCK)
		WHERE mi.OWPMatchId = @MatchId

		IF CHARINDEX('TV', @ItemsApplyForRelativeMatch) > 0
		BEGIN
			SET @TVIdsCurrent = @NewTVIds
		END

		IF CHARINDEX('Channel', @ItemsApplyForRelativeMatch) > 0
		BEGIN
			SET @ChannelCurrent = @NewChannel
		END

		IF CHARINDEX('WB', @ItemsApplyForRelativeMatch) > 0
		BEGIN
			SET @WBCurrent = @NewWB
		END

		IF CHARINDEX('Provider', @ItemsApplyForRelativeMatch) > 0
		BEGIN
			SET @ProviderIdsCurrent = @NewProviderIds
		END

		IF CHARINDEX('OtherProvider', @ItemsApplyForRelativeMatch) > 0
		BEGIN
			SET @OtherProviderIdsCurrent = @NewOtherProviderIds
		END

		IF CHARINDEX('Agent', @ItemsApplyForRelativeMatch) > 0
		BEGIN
			SET @AgentIdsCurrent = @NewAgentIds
		END

		IF CHARINDEX('Phone', @ItemsApplyForRelativeMatch) > 0
		BEGIN
			SET @PhoneCurrent = @NewPhone
		END

		EXEC dbo.OWP_LiveDetail_Update_ProviderInfo @ActorId
			,@SessionId
			,@MatchId
			,@ChannelCurrent
			,@WBCurrent
			,@PhoneCurrent
			,@TVIdsCurrent
			,@OtherProviderIdsCurrent
			,@ProviderIdsCurrent
			,@AgentIdsCurrent

		SET @rowStart = @rowStart + 1
	END
END