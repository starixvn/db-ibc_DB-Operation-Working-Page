/*<info serverAlias="DBOWP-bodb_OWP" executers="wsv_owp" isFunction="0"></info>*/

ALTER PROCEDURE [dbo].[OWP_PreMatchAssignment_AutoAssign] @ActorId INT
	,@Assignments NVARCHAR(MAX) = ''
AS
/*
Created: 20241108@Tim
Task: Pre-Match Assignment
DB: bodb_OWP

Revisions:
	20241108@Tim: Init SP - [Redmine: #205720]
*/
BEGIN
    SET NOCOUNT ON;

	DECLARE @RowNumber INT = 1
		,@TotalRow INT

	CREATE TABLE #tblAssignment (
		RowNumber INT IDENTITY PRIMARY KEY CLUSTERED
		,PreMatchLeagueId INT
		,UserId INT
		,Username NVARCHAR(30)
		,Bettype INT
		,IsTakeOver BIT
		,AssignmentType TINYINT
		)

	INSERT INTO #tblAssignment (PreMatchLeagueId, UserId, Username, Bettype, IsTakeOver, AssignmentType)
	SELECT PreMatchLeagueId, UserId, Username, Bettype, IsTakeOver, AssignmentType
	FROM OPENJSON(@Assignments) WITH (PreMatchLeagueId INT, UserId INT, Username NVARCHAR(30), Bettype INT, IsTakeOver BIT, AssignmentType TINYINT)

	SELECT @TotalRow = COUNT(1)
	FROM #tblAssignment

	WHILE @RowNumber <= @TotalRow
	BEGIN
		DECLARE @preMatchLeagueId INT = 0
			,@userId INT = 0
			,@bettype INT = 0
			,@isTakeOver BIT = 0
			,@assignmentType TINYINT = 0
			,@preMatchIssueId INT = 0
			,@newUsername NVARCHAR(30) = ''
			,@oldUsername NVARCHAR(30) = ''

		SELECT @preMatchLeagueId = PreMatchLeagueId
			,@userId = UserId
			,@bettype = Bettype
			,@isTakeOver = IsTakeOver
			,@assignmentType = AssignmentType
		FROM #tblAssignment
		WHERE RowNumber = @RowNumber

		SELECT @oldUsername = u.Username
		FROM dbo.PreMatchAssignment AS a WITH(NOLOCK)
			INNER JOIN dbo.PreMatchLeague AS l WITH(NOLOCK) ON a.PreMatchLeagueId = l.PreMatchLeagueId
			INNER JOIN dbo.[User] AS u WITH(NOLOCK) ON a.UserId = u.UserId
		WHERE l.PreMatchLeagueId = @PreMatchLeagueId
			AND a.Bettype = @bettype
			AND a.IsTakeOver = @isTakeOver
			AND a.AssignmentType = @assignmentType
		SET @oldUsername = ISNULL(@oldUsername, '')

		SELECT @newUsername = Username
		FROM dbo.[User] WITH(NOLOCK)
		WHERE UserId = @userId

		SELECT @preMatchIssueId = i.PreMatchIssueId
        FROM dbo.PreMatchIssue AS i WITH(NOLOCK)
             INNER JOIN dbo.PreMatchLeague AS l WITH(NOLOCK) ON i.OWPLeagueId = l.OWPLeagueId
        WHERE l.PreMatchLeagueId = @PreMatchLeagueId

		IF @oldUsername <> @newUsername
        BEGIN
            EXEC dbo.OWP_PreMatchAssignment_InsertUpdateDeleteAssignment @ActorId = @ActorId
                ,@PreMatchLeagueId = @PreMatchLeagueId
                ,@NewValue = @newUsername
                ,@OldValue = @oldUsername
                ,@Bettype = @bettype
                ,@IsTakeOver = @isTakeOver
                ,@PreMatchIssueId = @preMatchIssueId
				,@AssignmentType = @assignmentType
				,@AssignBySystem = 1
        END

		SET @RowNumber = @RowNumber + 1
	END

	DROP TABLE #tblAssignment
END;