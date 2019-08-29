
/*<info serverAlias="DBOWP-bodb_OWP" executers="bodbOWPNet" isFunction="0"></info>*/
CREATE PROCEDURE [dbo].[OWP_LiveGameAssignment_EditMainMatch] @OWPMatchId INT
	,@LeagueName NVARCHAR(500)
	,@HomeName NVARCHAR(200)
	,@AwayName NVARCHAR(200)
	,@MatchNo VARCHAR(50) = ''
	,@KickOffTime TIME(7)
	,@ActorId INT = NULL
	,@SessionId VARCHAR(50) = NULL
	,@ErrCode INT = 0 OUTPUT
	,@ErrMsg NVARCHAR(MAX) = '' OUTPUT
AS
/*
 Created: 20190725@Kane.Le
 Task : add new event
 DB: bodb_OWP

 Revisions:
	20190724@Kane.Le: Initial SP - [Feature: #117461]
*/
BEGIN
	SET NOCOUNT ON

	EXEC dbo.OWP_LiveGameAssignment_EditSingleMatch @OWPMatchId = @OWPMatchId
		,@LeagueName = @LeagueName
		,@HomeName = @HomeName
		,@AwayName = @AwayName
		,@MatchNo = @MatchNo
		,@ActorId = @ActorId
		,@SessionId = @SessionId
		,@KickOffTime = @KickOffTime
		,@ErrCode = @ErrCode OUTPUT
		,@ErrMsg = @ErrMsg OUTPUT

	DECLARE @tblSpecialEventTemplate TABLE (
		RowNumber INT IDENTITY
		,LeagueName NVARCHAR(500)
		,HomeName NVARCHAR(200)
		,AwayName NVARCHAR(200)
		,ParentMatchId INT
		,MinorBettypeId INT
		,MinorMatchId INT
		)
	DECLARE @tblMinorBettypeId TABLE (
		RowNumber INT IDENTITY
		,MinorMatchId INT
		,MinorBettypeId INT
		,ParentMatchId INT
		)

	INSERT INTO @tblMinorBettypeId
	SELECT mm.MinorMatchId
		,mm.MinorBettypeId
		,mm.ParentMatchId
	FROM dbo.MinorMatch AS mm WITH (NOLOCK)
	WHERE ParentMatchId = @OWPMatchId

	DECLARE @LoopCounter INT = 1
		,@MaxRowCount INT
		,@MinorBettypeId INT
		,@ParentMatchId INT
		,@MinorMatchId INT
		,@RowNumber INT

	SELECT @MaxRowCount = COUNT(*)
	FROM @tblMinorBettypeId

	WHILE (@LoopCounter <= @MaxRowCount)
	BEGIN
		SELECT @MinorBettypeId = MinorBettypeId
			,@ParentMatchId = ParentMatchId
			,@MinorMatchId = MinorMatchId
		FROM @tblMinorBettypeId
		WHERE @LoopCounter = RowNumber

		INSERT INTO @tblSpecialEventTemplate (
			LeagueName
			,HomeName
			,AwayName
			)
		EXEC [dbo].[OWP_LiveGameAssignment_GetSpecialEventTemplate] @ParentMatchId = @OWPMatchId
			,@MinorBettypeId = @MinorBettypeId

		UPDATE @tblSpecialEventTemplate
		SET ParentMatchId = @ParentMatchId
			,MinorBettypeId = @MinorBettypeId
			,MinorMatchId = @MinorMatchId
		WHERE @LoopCounter = RowNumber

		SET @LoopCounter = @LoopCounter + 1
	END

	SET @LoopCounter = 1
	SET @MaxRowCount = 0;

	SELECT @MaxRowCount = COUNT(*)
	FROM @tblSpecialEventTemplate	 
	 
	WHILE (@LoopCounter <= @MaxRowCount)
	BEGIN
		SELECT @LeagueName = LeagueName
			,@HomeName = HomeName
			,@AwayName = AwayName
			,@OWPMatchId = MinorMatchId
		FROM @tblSpecialEventTemplate
		WHERE @LoopCounter = RowNumber
		 
		EXEC dbo.OWP_LiveGameAssignment_EditSingleMatch @OWPMatchId = @OWPMatchId
			,@LeagueName = @LeagueName
			,@HomeName = @HomeName
			,@AwayName = @AwayName
			,@MatchNo = NULL
			,@SessionId = @SessionId
			,@ActorId = @ActorId
			,@KickOffTime = @KickOffTime
			,@ErrCode = @ErrCode OUTPUT
			,@ErrMsg = @ErrMsg OUTPUT
			 
		SET @LoopCounter = @LoopCounter + 1
	END
	 
	SELECT @ErrCode = 0
		,@ErrMsg = 'The event has been edited successfully!'
END