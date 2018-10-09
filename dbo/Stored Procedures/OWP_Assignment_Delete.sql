/*<info serverAlias="DBOWP-bodb_OWP" executers="bodbOWPNet" isFunction="0"></info>*/
CREATE PROCEDURE [dbo].[OWP_Assignment_Delete] @ActorId INT
	,@SessionId NVARCHAR(50)
	,@AssignmentId INT
	,@ErrCode INT = 0 OUTPUT
	,@ErrMsg NVARCHAR(200) = '' OUTPUT
AS
/*
Created: 20180816@Leo
Task: Delete Assignment at Live Detail.
DB: bodb_OWP

Revisions:
	20181009@Raymond.Le: new structure
*/
BEGIN
	SET NOCOUNT ON

	DECLARE @owpToday DATETIME = DATEADD(hh, 12, GETDATE())
		,@EventDateTime DATETIME
		,@MessageDeleteAssignmentId INT
		,@MessageDeleteAssignment NVARCHAR(500)
		,@MessageDeleteOtherAssignmentId INT
		,@MessageDeleteOtherAssignment NVARCHAR(500)
		,@FromTimeSendMessage DATETIME
		,@ToTimeSendMessage DATETIME
		,@FromTimeSendMessageSpecialBettype DATETIME
		,@ToTimeSendMessageSpecialBettype DATETIME
		,@OWPMatchId INT
		,@Bettype INT
		,@AssignmentType INT


	SELECT @OWPMatchId = OWPMatchId
		,@Bettype = Bettype
		,@AssignmentType = AssignmentType
	FROM dbo.Assignment WITH (NOLOCK)
	WHERE AssignmentId = @AssignmentId

	IF @OWPMatchId IS NULL
	BEGIN
		SELECT @ErrCode = 1
			,@ErrMsg = 'Assignment is not existed or deleted'

		RETURN
	END


	CREATE TABLE #RemoveAssignment
    ( 
        AssignmentId INT, 
        Bettype  INT NOT NULL, 
        AssignmentType TINYINT NOT NULL,
		UserId INT,
		AssignmentNote NVARCHAR(200)
    );


	DELETE FROM dbo.Assignment WITH (UPDLOCK)
	OUTPUT deleted.AssignmentId
		,deleted.Bettype
		,deleted.AssignmentType
		,deleted.UserId
		,deleted.AssignmentNote
	INTO #RemoveAssignment
	WHERE AssignmentId = @AssignmentId

	
	IF @AssignmentType = 1
	BEGIN
		-- remove other assignments
		DELETE FROM dbo.Assignment WITH (UPDLOCK)
		OUTPUT deleted.AssignmentId
			,deleted.Bettype
			,deleted.AssignmentType
			,deleted.UserId
			,deleted.AssignmentNote
		INTO #RemoveAssignment
		WHERE OWPMatchId = @OWPMatchId AND Bettype = @Bettype
	END


	-- list of minor bettypes Corner & Booking but not 15 mins
	CREATE TABLE #tblCornerBookingBetTypes (
		MinorBetTypeId INT NOT NULL
	)
	INSERT INTO #tblCornerBookingBetTypes
	SELECT MinorBettypeId FROM dbo.MinorBettype WITH (NOLOCK)
	WHERE ParentBetTypeId IS NULL
		AND IsActive = 1
		AND MinorBettypeName NOT LIKE '%15 mins%'
		AND (MinorBettypeName LIKE '%corner%' OR MinorBettypeName LIKE '%booking%')


	CREATE TABLE #tblMessage (
		UserId INT
		,MessageContent NVARCHAR(MAX)
		,MessageTypeId INT
		,MinorBetTypeId INT
		,EventDateTime DATETIME
		)

	SELECT @EventDateTime = DATEADD(DAY, DATEDIFF(DAY, 0, om.EventDate), CAST(om.KickOffTime AS VARCHAR(10)))
	FROM dbo.OWPMatch AS om WITH (NOLOCK)
		INNER JOIN dbo.MatchInfo AS info WITH (NOLOCK) ON om.OWPMatchId = info.OWPMatchId
	WHERE om.OWPMatchId = @OWPMatchId

	SELECT @FromTimeSendMessage = FromTime
		,@ToTimeSendMessage = ToTime
		,@FromTimeSendMessageSpecialBettype = FromTimeForSpecialBettype
		,@ToTimeSendMessageSpecialBettype= ToTimeForSpecialBettype
	FROM dbo.fnc_GetDateTimeForTraderViewTime()

	SELECT @MessageDeleteAssignment = mt.MsgTemplateContent
		,@MessageDeleteAssignmentId = mt.MsgTemplateId
	FROM dbo.MessageTemplate mt WITH (NOLOCK)
	WHERE mt.MsgTemplateCode = 'AssignmentDelete'

	SELECT @MessageDeleteOtherAssignment = mt.MsgTemplateContent
		,@MessageDeleteOtherAssignmentId = mt.MsgTemplateId
	FROM dbo.MessageTemplate AS mt WITH (NOLOCK)
	WHERE mt.MsgTemplateCode = 'OtherAssignmentDelete'


	-- send message to trader unassigned
	INSERT INTO #tblMessage (
		UserId
		,MessageContent
		,MessageTypeId
		,MinorBetTypeId
		,EventDateTime
	)
	SELECT u.UserId
		,REPLACE
			(REPLACE
				(CASE WHEN al.AssignmentType = 1
				THEN @MessageDeleteAssignment
				ELSE REPLACE(@MessageDeleteOtherAssignment, '<note>', RTRIM(LTRIM(REPLACE(al.AssignmentNote, '#<user>', '')))) END
				,'<bettype>'
				,al.BetTypeName)
			,'<event>'
			, h.OWPTeamName + ' vs ' + a.OWPTeamName)
		,CASE WHEN al.AssignmentType = 1
			THEN @MessageDeleteAssignmentId
			ELSE @MessageDeleteOtherAssignmentId
			END
		,al.MinorBetTypeId
		,m.EventDateTime
	FROM (
	SELECT (CASE WHEN mm.MinorMatchId IS NULL
				THEN d.OWPMatchId
				ELSE mm.ParentMatchId
				END) AS OWPMatchId
			,(CASE WHEN mm.MinorMatchId IS NULL
				THEN mjb.ShortName
				ELSE mb.MinorBettypeName
				END) AS BetTypeName
			,d.AssignmentType
			,d.UserId
			,d.AssignmentNote
			,mm.MinorBettypeId
		FROM (
			SELECT @OWPMatchId AS OWPMatchId
				,BetType
				,AssignmentType
				,UserId
				,AssignmentNote
			FROM #RemoveAssignment AS a
			WHERE UserId IS NOT NULL) AS d
		LEFT JOIN dbo.MajorBettype AS mjb WITH (NOLOCK) ON d.BetType = mjb.BettypeId
		LEFT JOIN dbo.MinorMatch AS mm WITH (NOLOCK) ON d.OWPMatchId = mm.MinorMatchId
		LEFT JOIN dbo.MinorBettype AS mb WITH (NOLOCK) ON mm.MinorBettypeId = mb.ParentBettypeId
			AND d.BetType = mb.InheritedBettypeId
		) AS al
	INNER JOIN dbo.OWPMatch AS m WITH (NOLOCK) ON al.OWPMatchId = m.OWPMatchId
	INNER JOIN dbo.OWPTeam AS h WITH (NOLOCK) ON h.OWPTeamId = m.OWPHomeId
	INNER JOIN dbo.OWPTeam AS a WITH (NOLOCK) ON a.OWPTeamId = m.OWPAwayId
	INNER JOIN dbo.[User] AS u WITH (NOLOCK) ON u.UserId = al.UserId


	-- insert message
	MERGE dbo.[Message] WITH (ROWLOCK) AS ms
	USING (SELECT m.UserId
			,m.MessageContent
			,m.MessageTypeId
		FROM #tblMessage AS m
		WHERE (m.MinorBetTypeId IS NULL 
			AND m.EventDateTime >= @FromTimeSendMessage
			AND m.EventDateTime <= @ToTimeSendMessage
		)
		OR (m.MinorBetTypeId IS NOT NULL
			AND 1 = (CASE WHEN EXISTS (
						SELECT 1 FROM #tblCornerBookingBetTypes
						WHERE MinorBetTypeId = m.MinorBetTypeId)
					THEN
						CASE WHEN m.EventDateTime >= @FromTimeSendMessageSpecialBettype
							AND m.EventDateTime <= @ToTimeSendMessageSpecialBettype
						THEN 1
						ELSE 0
						END
					ELSE
						CASE WHEN m.EventDateTime >= @FromTimeSendMessage
							AND m.EventDateTime <= @ToTimeSendMessage
						THEN 1
						ELSE 0
						END
					END)
		)
	) AS msn ON 1 = 0
	WHEN NOT MATCHED THEN
		INSERT (
			MessageContent
			,CreatedBy
			,IsImportant
			,MessageType
			)
		VALUES (
			msn.MessageContent
			,@ActorId
			,1
			,msn.MessageTypeId
			)
	OUTPUT inserted.MessageId
		,msn.UserId
		,@ActorId
		,@SessionId
	INTO dbo.MessageUser([MessageId], [UserId], [CreatedBy], [SessionId]);


	DROP TABLE #RemoveAssignment;
END