/*<info serverAlias="DBOWP-bodb_OWP" executers="bodbOWPNet" isFunction="0"></info>*/
ALTER PROCEDURE [dbo].[OWP_PreMatchNotification_QueryAssignmentByPreMatchLeagueId]  @PreMatchLeagueId INT
                                         
AS
/*
Created: 20210615@Carlos.nguyen
Task : Pre-Match notification
DB: bodb_OWP

Revisions:
	20210615@Carlos.nguyen: Get old value (use to compare with new value to send noti) - [Redmine: #156321]
*/
BEGIN
	SET NOCOUNT ON;
        DECLARE @hdpBettype INT= 1;
        DECLARE @ouBettype INT= 3;
     
		DECLARE @isDay BIT = NULL;
		DECLARE @leagueName NVARCHAR(200);
		
        -- main assignment
        DECLARE @hdp NVARCHAR(30);
        DECLARE @ou NVARCHAR(30);
        DECLARE @hdpTakeOver NVARCHAR(30);
        DECLARE @ouTakeOver NVARCHAR(30);
        DECLARE @hdpUserId INT;
        DECLARE @ouUserId INT;
        DECLARE @hdpTakeOverUserId INT;
        DECLARE @ouTakeOverUserId INT;

        -- other assignments
        DECLARE @otherHdp NVARCHAR(30);
        DECLARE @otherOu NVARCHAR(30);
        DECLARE @otherHdpTakeOver NVARCHAR(30);
        DECLARE @otherOuTakeOver NVARCHAR(30);
        DECLARE @otherHdpUserId INT;
        DECLARE @otherOuUserId INT;
        DECLARE @otherHdpTakeOverUserId INT;
        DECLARE @otherOuTakeOverUserId INT;
	
		-- league name
		SELECT @leagueName= owpl.OWPLeagueName
		FROM dbo.[PreMatchLeague] AS l WITH(NOLOCK)
			INNER JOIN OWPLeague owpl WITH(NOLOCK) ON l.OWPLeagueId=owpl.OWPLeagueId
		WHERE l.PreMatchLeagueId=@PreMatchLeagueId
		
        -- main assignments
        SELECT @hdp = u.Username
        , @hdpUserId=u.UserId
        FROM dbo.[PreMatchAssignment] AS a WITH(NOLOCK)
             INNER JOIN dbo.[PreMatchLeague] AS l WITH(NOLOCK) ON a.PreMatchLeagueId = l.PreMatchLeagueId
             INNER JOIN dbo.[User] AS u WITH(NOLOCK) ON a.UserId = u.UserId
        WHERE l.PreMatchLeagueId = @PreMatchLeagueId
              AND a.Bettype = @hdpBettype
              AND a.IsTakeOver = 0
              AND a.AssignmentType = 1;
        SET @hdp = ISNULL(@hdp, '');
        
        --
        SELECT @ou = u.Username
         , @ouUserId=u.UserId
        FROM dbo.[PreMatchAssignment] AS a WITH(NOLOCK)
             INNER JOIN dbo.[PreMatchLeague] AS l WITH(NOLOCK) ON a.PreMatchLeagueId = l.PreMatchLeagueId
             INNER JOIN dbo.[User] AS u WITH(NOLOCK) ON a.UserId = u.UserId
        WHERE l.PreMatchLeagueId = @PreMatchLeagueId
              AND a.Bettype = @ouBettype
              AND a.IsTakeOver = 0
              AND a.AssignmentType = 1;
        SET @ou = ISNULL(@ou, '');
        
        --
        SELECT @hdpTakeOver = u.Username
         , @hdpTakeOverUserId=u.UserId
        FROM dbo.[PreMatchAssignment] AS a WITH(NOLOCK)
             INNER JOIN dbo.[PreMatchLeague] AS l WITH(NOLOCK) ON a.PreMatchLeagueId = l.PreMatchLeagueId
             INNER JOIN dbo.[User] AS u WITH(NOLOCK) ON a.UserId = u.UserId
        WHERE l.PreMatchLeagueId = @PreMatchLeagueId
              AND a.Bettype = @hdpBettype
              AND a.IsTakeOver = 1
              AND a.AssignmentType = 1;
        SET @hdpTakeOver = ISNULL(@hdpTakeOver, '');
        
        --
        SELECT @ouTakeOver = u.Username
         , @ouTakeOverUserId=u.UserId
        FROM dbo.[PreMatchAssignment] AS a WITH(NOLOCK)
             INNER JOIN dbo.[PreMatchLeague] AS l WITH(NOLOCK) ON a.PreMatchLeagueId = l.PreMatchLeagueId
             INNER JOIN dbo.[User] AS u WITH(NOLOCK) ON a.UserId = u.UserId
        WHERE l.PreMatchLeagueId = @PreMatchLeagueId
              AND a.Bettype = @ouBettype
              AND a.IsTakeOver = 1
              AND a.AssignmentType = 1;
        SET @ouTakeOver = ISNULL(@ouTakeOver, '');

        -- other assignments
        SELECT @otherHdp = u.Username
         , @otherHdpUserId=u.UserId
        FROM dbo.[PreMatchAssignment] AS a WITH(NOLOCK)
             INNER JOIN dbo.[PreMatchLeague] AS l WITH(NOLOCK) ON a.PreMatchLeagueId = l.PreMatchLeagueId
             LEFT JOIN dbo.[User] AS u WITH(NOLOCK) ON a.UserId = u.UserId
        WHERE l.PreMatchLeagueId = @PreMatchLeagueId
              AND a.Bettype = @hdpBettype
              AND a.IsTakeOver = 0
              AND a.AssignmentType = 2;
        SET @otherHdp = ISNULL(@otherHdp, '');
        
        --
        SELECT @otherOu = u.Username
         , @otherOuUserId=u.UserId
        FROM dbo.[PreMatchAssignment] AS a WITH(NOLOCK)
             INNER JOIN dbo.[PreMatchLeague] AS l WITH(NOLOCK) ON a.PreMatchLeagueId = l.PreMatchLeagueId
             LEFT JOIN dbo.[User] AS u WITH(NOLOCK) ON a.UserId = u.UserId
        WHERE l.PreMatchLeagueId = @PreMatchLeagueId
              AND a.Bettype = @ouBettype
              AND a.IsTakeOver = 0
              AND a.AssignmentType = 2;
        SET @otherOu = ISNULL(@otherOu, '');
        
        --
        SELECT @otherHdpTakeOver = u.Username
         , @otherHdpTakeOverUserId=u.UserId
        FROM dbo.[PreMatchAssignment] AS a WITH(NOLOCK)
             INNER JOIN dbo.[PreMatchLeague] AS l WITH(NOLOCK) ON a.PreMatchLeagueId = l.PreMatchLeagueId
             LEFT JOIN dbo.[User] AS u WITH(NOLOCK) ON a.UserId = u.UserId
        WHERE l.PreMatchLeagueId = @PreMatchLeagueId
              AND a.Bettype = @hdpBettype
              AND a.IsTakeOver = 1
              AND a.AssignmentType = 2;
        SET @otherHdpTakeOver = ISNULL(@otherHdpTakeOver, '');
        
        --
        SELECT @otherOuTakeOver = u.Username
        , @otherOuTakeOverUserId=u.UserId
        FROM dbo.[PreMatchAssignment] AS a WITH(NOLOCK)
             INNER JOIN dbo.[PreMatchLeague] AS l WITH(NOLOCK) ON a.PreMatchLeagueId = l.PreMatchLeagueId
             LEFT JOIN dbo.[User] AS u WITH(NOLOCK) ON a.UserId = u.UserId
        WHERE l.PreMatchLeagueId = @PreMatchLeagueId
              AND a.Bettype = @ouBettype
              AND a.IsTakeOver = 1
              AND a.AssignmentType = 2;
        SET @otherOuTakeOver = ISNULL(@otherOuTakeOver, '');
        
        SELECT @isDay= IsDay FROM PreMatchLeague WHERE PreMatchLeagueId= @PreMatchLeagueId
        
        -- select main assignments
        SELECT @PreMatchLeagueId AS PreMatchLeagueId
		, @leagueName AS LeagueName
        , @isDay AS IsDay
         ,@hdp AS Hdp
         ,@ou AS Ou
         ,@hdpTakeOver AS HdpTakeOver
         ,@ouTakeOver AS OuTakeOver
         ,@hdpUserId AS HdpUserId
         ,@ouUserId AS OuUserId
         ,@hdpTakeOverUserId AS HdpTakeOverUserId
         ,@ouTakeOverUserId AS OuTakeOverUserId

        -- selectother assignments
         ,@otherHdp AS OtherHdp
         ,@otherOu AS OtherOu
         ,@otherHdpTakeOver AS OtherHdpTakeOver
         ,@otherOuTakeOver AS OtherOuTakeOver
         ,@otherHdpUserId AS OtherHdpUserId
         ,@otherOuUserId AS OtherOuUserId
         ,@otherHdpTakeOverUserId AS OtherHdpTakeOverUserId
         ,@otherOuTakeOverUserId AS OtherOuTakeOverUserId
END
                                                    