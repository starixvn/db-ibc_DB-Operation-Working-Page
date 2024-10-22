
/*<info serverAlias="DBOWP-bodb_OWP" executers="wsv_owp" isFunction="0"></info>*/

ALTER PROCEDURE [dbo].[OWP_PreMatchAssignment_Update] @ActorId          INT, 
                                                      @PreMatchLeagueId INT, 
                                                      @HDP              NVARCHAR(30)   = '', 
                                                      @OU               NVARCHAR(30)   = '', 
                                                      @HDPTakeOver      NVARCHAR(30)   = '', 
                                                      @OUTakeOver       NVARCHAR(30)   = '', 
                                                      @OtherHDP         NVARCHAR(30)   = '', 
                                                      @OtherOU          NVARCHAR(30)   = '', 
                                                      @OtherHDPTakeOver NVARCHAR(30)   = '', 
                                                      @OtherOUTakeOver  NVARCHAR(30)   = '', 
                                                      @Remark           NVARCHAR(2000) = ''
AS

/*
Created: 20200817@Tyler
Task : Pre-Match Assignment
DB: bodb_OWP

Revisions:
	20200817@Tyler: Init sync SP - [Redmine: #138643]
	20200922@Tyler: Update Prematch issue - [Redmine: #140620]
	20200914@Tyler: Update issue receiver - [Redmine: #142258]
	20201110@Tyler: remove other assignment note - [Redmine: #144948]
*/

    BEGIN
        SET NOCOUNT ON;
        DECLARE @hdpBettype INT= 1;
        DECLARE @ouBettype INT= 3;
        DECLARE @remarkOldValue NVARCHAR(2000);
        DECLARE @preMatchIssueId INT;

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

        --
        SELECT @remarkOldValue = Remark
        FROM dbo.[PreMatchLeague] WITH(NOLOCK)
        WHERE PreMatchLeagueId = @PreMatchLeagueId;
        SET @remarkOldValue = ISNULL(@remarkOldValue, '');

        -- main assignments
        SELECT @hdpOldValue = u.Username
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
        FROM dbo.[PreMatchAssignment] AS a WITH(NOLOCK)
             INNER JOIN dbo.[PreMatchLeague] AS l WITH(NOLOCK) ON a.PreMatchLeagueId = l.PreMatchLeagueId
             LEFT JOIN dbo.[User] AS u WITH(NOLOCK) ON a.UserId = u.UserId
        WHERE l.PreMatchLeagueId = @PreMatchLeagueId
              AND a.Bettype = @ouBettype
              AND a.IsTakeOver = 1
              AND a.AssignmentType = 2;
        SET @otherOuTakeOverOldValue = ISNULL(@otherOuTakeOverOldValue, '');

        --
        SELECT @preMatchIssueId = i.PreMatchIssueId
        FROM dbo.[PreMatchIssue] AS i WITH(NOLOCK)
             INNER JOIN dbo.[PreMatchLeague] AS l WITH(NOLOCK) ON i.OWPLeagueId = l.OWPLeagueId
        WHERE l.PreMatchLeagueId = @PreMatchLeagueId;

        -- main assingment
        IF(@hdpOldValue <> @HDP)
            BEGIN
                EXEC dbo.[OWP_PreMatchAssignment_InsertUpdateDeleteAssignment] 
                     @ActorId = @ActorId, 
                     @PreMatchLeagueId = @PreMatchLeagueId, 
                     @NewValue = @HDP, 
                     @OldValue = @hdpOldValue, 
                     @Bettype = @hdpBettype, 
                     @IsTakeOver = 0, 
                     @PreMatchIssueId = @preMatchIssueId,
					 @AssignmentType = 1;
            END;
        IF(@ouOldValue <> @OU)
            BEGIN
                EXEC dbo.[OWP_PreMatchAssignment_InsertUpdateDeleteAssignment] 
                     @ActorId = @ActorId, 
                     @PreMatchLeagueId = @PreMatchLeagueId, 
                     @NewValue = @OU, 
                     @OldValue = @ouOldValue, 
                     @Bettype = @ouBettype, 
                     @IsTakeOver = 0, 
                     @PreMatchIssueId = @preMatchIssueId,
					 @AssignmentType = 1;
            END;
        IF(@hdpTakeOverOldValue <> @HDPTakeOver)
            BEGIN
                EXEC dbo.[OWP_PreMatchAssignment_InsertUpdateDeleteAssignment] 
                     @ActorId = @ActorId, 
                     @PreMatchLeagueId = @PreMatchLeagueId, 
                     @NewValue = @HDPTakeOver, 
                     @OldValue = @hdpTakeOverOldValue, 
                     @Bettype = @hdpBettype, 
                     @IsTakeOver = 1, 
                     @PreMatchIssueId = @preMatchIssueId,
					 @AssignmentType = 1;
            END;
        IF(@ouTakeOverOldValue <> @OUTakeOver)
            BEGIN
                EXEC dbo.[OWP_PreMatchAssignment_InsertUpdateDeleteAssignment] 
                     @ActorId = @ActorId, 
                     @PreMatchLeagueId = @PreMatchLeagueId, 
                     @NewValue = @OUTakeOver, 
                     @OldValue = @ouTakeOverOldValue, 
                     @Bettype = @ouBettype, 
                     @IsTakeOver = 1, 
                     @PreMatchIssueId = @preMatchIssueId,
					 @AssignmentType = 1;
            END;
        IF(@remarkOldValue <> @Remark)
            BEGIN
                EXEC dbo.[OWP_PreMatchAssignment_UpdateRemark] 
                     @ActorId = @ActorId, 
                     @PreMatchLeagueId = @PreMatchLeagueId, 
                     @Remark = @Remark;
            END;

        -- other assingment
        IF(@otherHdpOldValue <> @OtherHDP)
            BEGIN
                EXEC dbo.[OWP_PreMatchAssignment_InsertUpdateDeleteAssignment] 
                     @ActorId = @ActorId, 
                     @PreMatchLeagueId = @PreMatchLeagueId, 
                     @NewValue = @OtherHDP, 
                     @OldValue = @otherHdpOldValue, 
                     @Bettype = @hdpBettype, 
                     @IsTakeOver = 0, 
                     @PreMatchIssueId = @preMatchIssueId,
					 @AssignmentType = 2;
            END;
        IF(@otherOuOldValue <> @OtherOU)
            BEGIN
                EXEC dbo.[OWP_PreMatchAssignment_InsertUpdateDeleteAssignment] 
                     @ActorId = @ActorId, 
                     @PreMatchLeagueId = @PreMatchLeagueId, 
                     @NewValue = @OtherOU, 
                     @OldValue = @otherOuOldValue, 
                     @Bettype = @ouBettype, 
                     @IsTakeOver = 0, 
                     @PreMatchIssueId = @preMatchIssueId,
					 @AssignmentType = 2;
            END;
        IF(@otherHdpTakeOverOldValue <> @OtherHDPTakeOver)
            BEGIN
                EXEC dbo.[OWP_PreMatchAssignment_InsertUpdateDeleteAssignment] 
                     @ActorId = @ActorId, 
                     @PreMatchLeagueId = @PreMatchLeagueId, 
                     @NewValue = @OtherHDPTakeOver, 
                     @OldValue = @otherHdpTakeOverOldValue, 
                     @Bettype = @hdpBettype, 
                     @IsTakeOver = 1, 
                     @PreMatchIssueId = @preMatchIssueId,
					 @AssignmentType = 2;
            END;
        IF(@otherOuTakeOverOldValue <> @OtherOUTakeOver)
            BEGIN
                EXEC dbo.[OWP_PreMatchAssignment_InsertUpdateDeleteAssignment] 
                     @ActorId = @ActorId, 
                     @PreMatchLeagueId = @PreMatchLeagueId, 
                     @NewValue = @OtherOUTakeOver, 
                     @OldValue = @otherOuTakeOverOldValue, 
                     @Bettype = @ouBettype, 
                     @IsTakeOver = 1, 
                     @PreMatchIssueId = @preMatchIssueId,
					 @AssignmentType = 2;
            END;
        --
        IF(@remarkOldValue <> @Remark)
            BEGIN
                EXEC dbo.[OWP_PreMatchAssignment_UpdateRemark] 
                     @ActorId = @ActorId, 
                     @PreMatchLeagueId = @PreMatchLeagueId, 
                     @Remark = @Remark;
            END;
    END;