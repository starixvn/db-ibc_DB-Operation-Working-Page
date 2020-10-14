/*<info serverAlias="DBOWP-bodb_OWP" executers="bodbOWPNet" isFunction="0"></info>*/

ALTER PROCEDURE [dbo].[OWP_PreMatchAssignment_Update] @ActorId              INT, 
                                                      @PreMatchLeagueId     INT, 
                                                      @HDP                  NVARCHAR(30)   = '', 
                                                      @OU                   NVARCHAR(30)   = '', 
                                                      @HDPTakeOver          NVARCHAR(30)   = '', 
                                                      @OUTakeOver           NVARCHAR(30)   = '', 
                                                      @OtherHDP             NVARCHAR(30)   = '', 
                                                      @OtherOU              NVARCHAR(30)   = '', 
                                                      @OtherHDPTakeOver     NVARCHAR(30)   = '', 
                                                      @OtherOUTakeOver      NVARCHAR(30)   = '', 
                                                      @OtherHDPNote         NVARCHAR(200)  = '', 
                                                      @OtherOUNote          NVARCHAR(200)  = '', 
                                                      @OtherHDPTakeOverNote NVARCHAR(200)  = '', 
                                                      @OtherOUTakeOverNote  NVARCHAR(200)  = '', 
                                                      @Remark               NVARCHAR(2000) = ''
AS

/*
Created: 20200817@Tyler
Task : Pre-Match Assignment
DB: bodb_OWP

Revisions:
	20200817@Tyler: Init sync SP - [Redmine: #138643]
	20200922@Tyler: Update Prematch issue - [Redmine: #140620]
	20200914@Tyler: Update issue receiver - [Redmine: #142258]
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
        DECLARE @otherHdpNoteOldValue NVARCHAR(200);
        DECLARE @otherOuNoteOldValue NVARCHAR(200);
        DECLARE @otherHdpTakeOverNoteOldValue NVARCHAR(200);
        DECLARE @otherOuTakeOverNoteOldValue NVARCHAR(200);

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
        SELECT @otherHdpOldValue = u.Username, 
               @otherHdpNoteOldValue = a.AssignmentNote
        FROM dbo.[PreMatchAssignment] AS a WITH(NOLOCK)
             INNER JOIN dbo.[PreMatchLeague] AS l WITH(NOLOCK) ON a.PreMatchLeagueId = l.PreMatchLeagueId
             LEFT JOIN dbo.[User] AS u WITH(NOLOCK) ON a.UserId = u.UserId
        WHERE l.PreMatchLeagueId = @PreMatchLeagueId
              AND a.Bettype = @hdpBettype
              AND a.IsTakeOver = 0
              AND a.AssignmentType = 2;
        SET @otherHdpOldValue = ISNULL(@otherHdpOldValue, '');
        SET @otherHdpNoteOldValue = ISNULL(@otherHdpNoteOldValue, '');
		--
        SELECT @otherOuOldValue = u.Username, 
               @otherOuNoteOldValue = a.AssignmentNote
        FROM dbo.[PreMatchAssignment] AS a WITH(NOLOCK)
             INNER JOIN dbo.[PreMatchLeague] AS l WITH(NOLOCK) ON a.PreMatchLeagueId = l.PreMatchLeagueId
             LEFT JOIN dbo.[User] AS u WITH(NOLOCK) ON a.UserId = u.UserId
        WHERE l.PreMatchLeagueId = @PreMatchLeagueId
              AND a.Bettype = @ouBettype
              AND a.IsTakeOver = 0
              AND a.AssignmentType = 2;
        SET @otherOuOldValue = ISNULL(@otherOuOldValue, '');
        SET @otherOuNoteOldValue = ISNULL(@otherOuNoteOldValue, '');
		--
        SELECT @otherHdpTakeOverOldValue = u.Username, 
               @otherHdpTakeOverNoteOldValue = a.AssignmentNote
        FROM dbo.[PreMatchAssignment] AS a WITH(NOLOCK)
             INNER JOIN dbo.[PreMatchLeague] AS l WITH(NOLOCK) ON a.PreMatchLeagueId = l.PreMatchLeagueId
             LEFT JOIN dbo.[User] AS u WITH(NOLOCK) ON a.UserId = u.UserId
        WHERE l.PreMatchLeagueId = @PreMatchLeagueId
              AND a.Bettype = @hdpBettype
              AND a.IsTakeOver = 1
              AND a.AssignmentType = 2;
        SET @otherHdpTakeOverOldValue = ISNULL(@otherHdpTakeOverOldValue, '');
        SET @otherHdpTakeOverNoteOldValue = ISNULL(@otherHdpTakeOverNoteOldValue, '');
		--
        SELECT @otherOuTakeOverOldValue = u.Username, 
               @otherOuTakeOverNoteOldValue = a.AssignmentNote
        FROM dbo.[PreMatchAssignment] AS a WITH(NOLOCK)
             INNER JOIN dbo.[PreMatchLeague] AS l WITH(NOLOCK) ON a.PreMatchLeagueId = l.PreMatchLeagueId
             LEFT JOIN dbo.[User] AS u WITH(NOLOCK) ON a.UserId = u.UserId
        WHERE l.PreMatchLeagueId = @PreMatchLeagueId
              AND a.Bettype = @ouBettype
              AND a.IsTakeOver = 1
              AND a.AssignmentType = 2;
        SET @otherOuTakeOverOldValue = ISNULL(@otherOuTakeOverOldValue, '');
        SET @otherOuTakeOverNoteOldValue = ISNULL(@otherOuTakeOverNoteOldValue, '');

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
                     @PreMatchIssueId = @preMatchIssueId;
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
                     @PreMatchIssueId = @preMatchIssueId;
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
                     @PreMatchIssueId = @preMatchIssueId;
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
                     @PreMatchIssueId = @preMatchIssueId;
        END;
        IF(@remarkOldValue <> @Remark)
            BEGIN
                EXEC dbo.[OWP_PreMatchAssignment_UpdateRemark] 
                     @ActorId = @ActorId, 
                     @PreMatchLeagueId = @PreMatchLeagueId, 
                     @Remark = @Remark;
        END;

		-- other assingment
        IF(@otherHdpOldValue <> @OtherHDP OR @otherHdpNoteOldValue <> @OtherHDPNote)
            BEGIN
                EXEC dbo.[OWP_PreMatchAssignment_InsertUpdateDeleteOtherAssignment] 
                     @ActorId = @ActorId, 
                     @PreMatchLeagueId = @PreMatchLeagueId, 
                     @NewValue = @OtherHDP, 
                     @OldValue = @otherHdpOldValue,
					 @NewNoteValue =  @OtherHDPNote,
					 @OldNoteValue = @otherHdpNoteOldValue,
                     @Bettype = @hdpBettype, 
                     @IsTakeOver = 0, 
                     @PreMatchIssueId = @preMatchIssueId;
        END;
        IF(@otherOuOldValue <> @OtherOU OR @otherOuNoteOldValue <> @OtherOUNote)
            BEGIN
                EXEC dbo.[OWP_PreMatchAssignment_InsertUpdateDeleteOtherAssignment] 
                     @ActorId = @ActorId, 
                     @PreMatchLeagueId = @PreMatchLeagueId, 
                     @NewValue = @OtherOU, 
                     @OldValue = @otherOuOldValue, 
					 @NewNoteValue =  @OtherOUNote,
					 @OldNoteValue = @otherOuNoteOldValue,
                     @Bettype = @ouBettype, 
                     @IsTakeOver = 0, 
                     @PreMatchIssueId = @preMatchIssueId;
        END;
        IF(@otherHdpTakeOverOldValue <> @OtherHDPTakeOver OR @otherHdpTakeOverNoteOldValue <> @OtherHDPTakeOverNote)
            BEGIN
                EXEC dbo.[OWP_PreMatchAssignment_InsertUpdateDeleteOtherAssignment] 
                     @ActorId = @ActorId, 
                     @PreMatchLeagueId = @PreMatchLeagueId, 
                     @NewValue = @OtherHDPTakeOver, 
                     @OldValue = @otherHdpTakeOverOldValue, 
					 @NewNoteValue =  @OtherHDPTakeOverNote,
					 @OldNoteValue = @otherHdpTakeOverNoteOldValue,
                     @Bettype = @hdpBettype, 
                     @IsTakeOver = 1, 
                     @PreMatchIssueId = @preMatchIssueId;
        END;
        IF(@otherOuTakeOverOldValue <> @OtherOUTakeOver OR @otherOuTakeOverNoteOldValue <> @OtherOUTakeOverNote)
            BEGIN
                EXEC dbo.[OWP_PreMatchAssignment_InsertUpdateDeleteOtherAssignment] 
                     @ActorId = @ActorId, 
                     @PreMatchLeagueId = @PreMatchLeagueId, 
                     @NewValue = @OtherOUTakeOver, 
                     @OldValue = @otherOuTakeOverOldValue, 
					 @NewNoteValue =  @OtherOUTakeOverNote,
					 @OldNoteValue = @otherOuTakeOverNoteOldValue,
                     @Bettype = @ouBettype, 
                     @IsTakeOver = 1, 
                     @PreMatchIssueId = @preMatchIssueId;
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