/*<info serverAlias="DBOWP-bodb_OWP" executers="wsv_owp" isFunction="0"></info>*/

ALTER PROCEDURE [dbo].[OWP_PreMatchAssignment_DeleteAssignment] @ActorId INT
    ,@PreMatchLeagueId INT
    ,@NewValue NVARCHAR(30) = ''
    ,@OldValue NVARCHAR(30) = ''
    ,@Bettype INT
    ,@IsTakeOver BIT
    ,@OWPLeagueId INT
    ,@EventDate DATE
    ,@AssignmentType INT
    ,@PreMatchIssueId INT = NULL
AS
/*
Created: 20201003@Tyler
Task : Pre-Match Assignment
DB: bodb_OWP

Revisions:
	20201003@Tyler: update other assignments  - [Redmine: #142258]  
	20201110@Tyler: remove other assignment note - [Redmine: #144948]
	20241111@Tim: auto assignment - [Redmine: #205720]	
*/
BEGIN
    SET NOCOUNT ON;
    DECLARE @userId INT;
    DECLARE @StartRun DATETIME= GETDATE(), @EndRun DATETIME, @Duration INT, @LogData NVARCHAR(MAX), @LogDataOld NVARCHAR(MAX), @Xml XML;
    CREATE TABLE #tblMatchIssues(PreMatchIssueId INT);

    -- temp table
    INSERT INTO #tblMatchIssues(PreMatchIssueId)
    SELECT i.PreMatchIssueId
    FROM [dbo].[InfoSiteMatch] AS m WITH(NOLOCK)
        INNER JOIN dbo.PreMatchLeague AS pl WITH(NOLOCK) ON pl.OWPLeagueId = m.OWPLeagueId
        INNER JOIN dbo.PreMatchIssue AS i WITH(NOLOCK) ON i.InfoSiteMatchId = m.InfoSiteMatchId
    WHERE pl.PreMatchLeagueId = @PreMatchLeagueId
        AND m.EventDateTime BETWEEN DATEADD(DAY, DATEDIFF(DAY, 0, pl.EventDate), '12:00:00') AND DATEADD(DAY, DATEDIFF(DAY, -1, pl.EventDate), '11:59:59');

    --
    SET @Xml = (
		SELECT pa.PreMatchLeagueId AS '@plid'
			,pa.UserId AS '@uid'
			,pa.Bettype AS '@bt'
			,pa.IsTakeOver AS '@ito'
			,u.Username AS '@un'
			,pa.AssignmentType AS '@at'
			,pa.AssignBySystem AS '@abs'
		FROM dbo.[PreMatchAssignment] AS pa WITH(NOLOCK)
			INNER JOIN dbo.[User] AS u WITH(NOLOCK) ON pa.UserId = u.UserId
		WHERE PreMatchLeagueId = @PreMatchLeagueId
			AND Bettype = @Bettype
			AND IsTakeOver = @IsTakeOver
			AND AssignmentType = @AssignmentType
		FOR XML PATH('z'), ROOT('r')
	);

    --
    SELECT @userId = UserId
    FROM dbo.[PreMatchAssignment] WITH(NOLOCK)
    WHERE PreMatchLeagueId = @PreMatchLeagueId
        AND Bettype = @Bettype
        AND IsTakeOver = @IsTakeOver
        AND AssignmentType = @AssignmentType;

    -- delete from receiving isssue message
    DELETE r
    FROM [dbo].[PreMatchIssueReceiver] AS r WITH(ROWLOCK)
    WHERE @PreMatchIssueId IS NOT NULL
        AND r.PreMatchIssueId = @PreMatchIssueId
        AND r.UserId = @userId
        AND r.UserId NOT IN
			(
				SELECT UserId
				FROM dbo.[PreMatchIssueMessage] WITH(NOLOCK)
				WHERE PreMatchIssueId = @PreMatchIssueId
			)
        AND r.UserId NOT IN
			(
				SELECT UserId
				FROM dbo.[PreMatchAssignment] a WITH(NOLOCK)
					INNER JOIN dbo.[PreMatchLeague] l WITH(NOLOCK) ON a.PreMatchLeagueId = l.PreMatchLeagueId
				WHERE l.OWPLeagueId = @OWPLeagueId
					AND l.EventDate = EventDate
			);
    DELETE r
    FROM [dbo].[PreMatchIssueReceiver] AS r WITH(ROWLOCK)
        INNER JOIN #tblMatchIssues AS i ON i.PreMatchIssueId = r.PreMatchIssueId
    WHERE r.UserId = @userId
        AND r.UserId NOT IN
			(
				SELECT UserId
				FROM dbo.[PreMatchIssueMessage] WITH(NOLOCK)
				WHERE PreMatchIssueId = i.PreMatchIssueId
			);

    -- delete asssignment
    DELETE
    FROM dbo.[PreMatchAssignment] WITH(ROWLOCK)
    WHERE PreMatchLeagueId = @PreMatchLeagueId
		AND Bettype = @Bettype
		AND IsTakeOver = @IsTakeOver
		AND AssignmentType = @AssignmentType;

    -- Log
    SET @LogDataOld = REPLACE(CONVERT(NVARCHAR(MAX), @Xml), '" />', '"/"');
    SET @EndRun = GETDATE();
    SET @Duration = DATEDIFF(MILLISECOND, @StartRun, @EndRun);

    EXEC dbo.OWP_WriteLog @CreatorId = @ActorId, 
        @SPName = 'OWP_PreMatchAssignment_InsertUpdateDeleteAssignment',
        @LoggedDate = @StartRun,
        @Duration = @Duration,
        @ObjectId = @preMatchLeagueId,
        @DataOld = @LogDataOld,
        @Data = @LogData;
END;