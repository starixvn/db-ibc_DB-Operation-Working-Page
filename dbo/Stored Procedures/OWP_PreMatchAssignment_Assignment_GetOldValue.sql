/*<info serverAlias="DBOWP-bodb_OWP" executers="bodbOWPNet" isFunction="0"></info>*/
ALTER PROCEDURE [dbo].[OWP_PreMatchAssignment_Assignment_GetOldValue]  @PreMatchLeagueId INT
                                         
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
		 
        -- main assignment
        DECLARE @hdpOldValue NVARCHAR(30);
        DECLARE @ouOldValue NVARCHAR(30);
        DECLARE @hdpTakeOverOldValue NVARCHAR(30);
        DECLARE @ouTakeOverOldValue NVARCHAR(30);

        -- other assignments
        DECLARE @otherHdpOldValue NVARCHAR(30);
        DECLARE @otherOuOldValue NVARCHAR(30);
        DECLARE @otherHdpTakeOverOldValue NVARCHAR(30);
        DECLARE @otherOuTakeOverOldValue NVARCHAR(30);

        -- main assignments
        SELECT @hdpOldValue = u.Username
        , @isDay= l.IsDay
        FROM dbo.[PreMatchAssignment] AS a WITH(NOLOCK)
             INNER JOIN dbo.[PreMatchLeague] AS l WITH(NOLOCK) ON a.PreMatchLeagueId = l.PreMatchLeagueId
             INNER JOIN dbo.[User] AS u WITH(NOLOCK) ON a.UserId = u.UserId
        WHERE l.PreMatchLeagueId = @PreMatchLeagueId
              AND a.Bettype = @hdpBettype
              AND a.IsTakeOver = 0
              AND a.AssignmentType = 1;
        SET @hdpOldValue = ISNULL(@hdpOldValue, '');
        --
        SELECT @ouOldValue = u.Username
        , @isDay= l.IsDay
        FROM dbo.[PreMatchAssignment] AS a WITH(NOLOCK)
             INNER JOIN dbo.[PreMatchLeague] AS l WITH(NOLOCK) ON a.PreMatchLeagueId = l.PreMatchLeagueId
             INNER JOIN dbo.[User] AS u WITH(NOLOCK) ON a.UserId = u.UserId
        WHERE l.PreMatchLeagueId = @PreMatchLeagueId
              AND a.Bettype = @ouBettype
              AND a.IsTakeOver = 0
              AND a.AssignmentType = 1;
        SET @ouOldValue = ISNULL(@ouOldValue, '');
        --
        SELECT @hdpTakeOverOldValue = u.Username
        , @isDay= l.IsDay
        FROM dbo.[PreMatchAssignment] AS a WITH(NOLOCK)
             INNER JOIN dbo.[PreMatchLeague] AS l WITH(NOLOCK) ON a.PreMatchLeagueId = l.PreMatchLeagueId
             INNER JOIN dbo.[User] AS u WITH(NOLOCK) ON a.UserId = u.UserId
        WHERE l.PreMatchLeagueId = @PreMatchLeagueId
              AND a.Bettype = @hdpBettype
              AND a.IsTakeOver = 1
              AND a.AssignmentType = 1;
        SET @hdpTakeOverOldValue = ISNULL(@hdpTakeOverOldValue, '');
        --
        SELECT @ouTakeOverOldValue = u.Username
        , @isDay= l.IsDay
        FROM dbo.[PreMatchAssignment] AS a WITH(NOLOCK)
             INNER JOIN dbo.[PreMatchLeague] AS l WITH(NOLOCK) ON a.PreMatchLeagueId = l.PreMatchLeagueId
             INNER JOIN dbo.[User] AS u WITH(NOLOCK) ON a.UserId = u.UserId
        WHERE l.PreMatchLeagueId = @PreMatchLeagueId
              AND a.Bettype = @ouBettype
              AND a.IsTakeOver = 1
              AND a.AssignmentType = 1;
        SET @ouTakeOverOldValue = ISNULL(@ouTakeOverOldValue, '');

        -- other assignments
        SELECT @otherHdpOldValue = u.Username
        , @isDay= l.IsDay
        FROM dbo.[PreMatchAssignment] AS a WITH(NOLOCK)
             INNER JOIN dbo.[PreMatchLeague] AS l WITH(NOLOCK) ON a.PreMatchLeagueId = l.PreMatchLeagueId
             LEFT JOIN dbo.[User] AS u WITH(NOLOCK) ON a.UserId = u.UserId
        WHERE l.PreMatchLeagueId = @PreMatchLeagueId
              AND a.Bettype = @hdpBettype
              AND a.IsTakeOver = 0
              AND a.AssignmentType = 2;
        SET @otherHdpOldValue = ISNULL(@otherHdpOldValue, '');
        --
        SELECT @otherOuOldValue = u.Username
        , @isDay= l.IsDay
        FROM dbo.[PreMatchAssignment] AS a WITH(NOLOCK)
             INNER JOIN dbo.[PreMatchLeague] AS l WITH(NOLOCK) ON a.PreMatchLeagueId = l.PreMatchLeagueId
             LEFT JOIN dbo.[User] AS u WITH(NOLOCK) ON a.UserId = u.UserId
        WHERE l.PreMatchLeagueId = @PreMatchLeagueId
              AND a.Bettype = @ouBettype
              AND a.IsTakeOver = 0
              AND a.AssignmentType = 2;
        SET @otherOuOldValue = ISNULL(@otherOuOldValue, '');
        --
        SELECT @otherHdpTakeOverOldValue = u.Username
        , @isDay= l.IsDay
        FROM dbo.[PreMatchAssignment] AS a WITH(NOLOCK)
             INNER JOIN dbo.[PreMatchLeague] AS l WITH(NOLOCK) ON a.PreMatchLeagueId = l.PreMatchLeagueId
             LEFT JOIN dbo.[User] AS u WITH(NOLOCK) ON a.UserId = u.UserId
        WHERE l.PreMatchLeagueId = @PreMatchLeagueId
              AND a.Bettype = @hdpBettype
              AND a.IsTakeOver = 1
              AND a.AssignmentType = 2;
        SET @otherHdpTakeOverOldValue = ISNULL(@otherHdpTakeOverOldValue, '');
        --
        SELECT @otherOuTakeOverOldValue = u.Username
        , @isDay= l.IsDay
        FROM dbo.[PreMatchAssignment] AS a WITH(NOLOCK)
             INNER JOIN dbo.[PreMatchLeague] AS l WITH(NOLOCK) ON a.PreMatchLeagueId = l.PreMatchLeagueId
             LEFT JOIN dbo.[User] AS u WITH(NOLOCK) ON a.UserId = u.UserId
        WHERE l.PreMatchLeagueId = @PreMatchLeagueId
              AND a.Bettype = @ouBettype
              AND a.IsTakeOver = 1
              AND a.AssignmentType = 2;
        SET @otherOuTakeOverOldValue = ISNULL(@otherOuTakeOverOldValue, '');
        
        -- select main assignments
        SELECT @PreMatchLeagueId
        , @isDay
         ,@hdpOldValue
         ,@ouOldValue 
         ,@hdpTakeOverOldValue 
         ,@ouTakeOverOldValue 

        -- selectother assignments
         ,@otherHdpOldValue 
         ,@otherOuOldValue 
         ,@otherHdpTakeOverOldValue 
         ,@otherOuTakeOverOldValue 
END
                                                    