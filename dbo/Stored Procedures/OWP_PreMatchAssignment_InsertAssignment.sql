/*<info serverAlias="DBOWP-bodb_OWP" executers="wsv_owp" isFunction="0"></info>*/

ALTER PROCEDURE [dbo].[OWP_PreMatchAssignment_InsertAssignment] @ActorId INT
    ,@PreMatchLeagueId INT
    ,@NewValue NVARCHAR(30) = ''
    ,@OldValue NVARCHAR(30) = ''
    ,@Bettype INT
    ,@IsTakeOver BIT
	,@AssignmentType INT
    ,@PreMatchIssueId INT = NULL
	,@AssignBySystem BIT = 0
AS

/*
Created: 20201003@Tyler
Task : Pre-Match Assignment
DB: bodb_OWP

Revisions:
	20201003@Tyler: update other assignments  - [Redmine: #142258]  
	20201026@Tyler: update insert receiver  - [Redmine: #140772]  
	20201110@Tyler: remove other assignment note - [Redmine: #144948]
	20241111@Tim: auto assignment - [Redmine: #205720]
*/
BEGIN
    SET NOCOUNT ON;
    DECLARE @userId INT;
    DECLARE @StartRun DATETIME= GETDATE()
		,@EndRun DATETIME
		,@Duration INT
		,@LogData NVARCHAR(MAX)
		,@LogDataOld NVARCHAR(MAX)
		,@Xml XML;
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
    SELECT @userId = u.UserId
    FROM dbo.[User] AS u WITH(NOLOCK)
    WHERE u.Username = @NewValue;

    INSERT INTO [dbo].[PreMatchAssignment] (
		[PreMatchLeagueId]
		,[UserId]
		,[Bettype]
		,[IsTakeOver]
		,[AssignmentType]
		,AssignBySystem
	)
    VALUES (
		@PreMatchLeagueId
		,@userId
		,@Bettype
		,@IsTakeOver
		,@AssignmentType
		,@AssignBySystem
	);

    -- Insert for receiving isssue message
    INSERT INTO [dbo].[PreMatchIssueReceiver] (
		[PreMatchIssueId]
		,[UserId]
		,[IsRead]
	)
    SELECT @PreMatchIssueId
        ,@userId
		,1
    WHERE NOT EXISTS
		(
			SELECT 1
			FROM [dbo].[PreMatchIssueReceiver]
			WHERE UserId = @userId
					AND PreMatchIssueId = @PreMatchIssueId
		)
        AND @PreMatchIssueId IS NOT NULL;

     -- Receivers for infosite matches issue
    INSERT INTO [dbo].[PreMatchIssueReceiver] (
		[PreMatchIssueId]
		,[UserId]
		,[IsRead]
    )
    SELECT PreMatchIssueId
		,@userId
        ,1
    FROM #tblMatchIssues AS i
    WHERE NOT EXISTS
		(
			SELECT 1
			FROM [dbo].[PreMatchIssueReceiver]
			WHERE PreMatchIssueId = i.PreMatchIssueId
				AND UserId = @userId
		);

    -- Log
    SET @Xml = (
		SELECT @preMatchLeagueId AS '@plid'
			,@userId AS '@uid'
			,@Bettype AS '@bt'
			,@IsTakeOver AS '@ito'
			,@NewValue AS '@un'
			,@AssignmentType AS '@at'
			,@AssignBySystem AS '@abs'
		FOR XML PATH('z'), ROOT('r')
	);

    SET @LogData = REPLACE(CONVERT(NVARCHAR(MAX), @Xml), '" />', '"/"');
    SET @EndRun = GETDATE();
    SET @Duration = DATEDIFF(MILLISECOND, @StartRun, @EndRun);

    EXEC dbo.OWP_WriteLog @CreatorId = @ActorId, 
		@SPName = 'OWP_PreMatchAssignment_InsertUpdateDeleteAssignment', 
		@LoggedDate = @StartRun, 
		@Duration = @Duration, 
		@ObjectId = @preMatchLeagueId, 
		@DataOld = @LogDataOld, 
		@Data = @LogData;
END