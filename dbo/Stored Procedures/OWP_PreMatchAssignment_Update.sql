USE [bodb_OWP]
GO
/****** Object:  StoredProcedure [dbo].[OWP_PreMatchAssignment_Update]    Script Date: 9/30/2020 11:29:24 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

/*<info serverAlias="DBOWP-bodb_OWP" executers="bodbOWPNet" isFunction="0"></info>*/

ALTER PROCEDURE [dbo].[OWP_PreMatchAssignment_Update] @ActorId          INT, 
                                                      @PreMatchLeagueId INT, 
                                                      @HDP              NVARCHAR(30)   = '', 
                                                      @OU               NVARCHAR(30)   = '', 
                                                      @HDPTakeOver      NVARCHAR(30)   = '', 
                                                      @OUTakeOver       NVARCHAR(30)   = '', 
                                                      @Remark           NVARCHAR(2000) = ''
AS

/*
Created: 20200817@Tyler
Task : Pre-Match Assignment
DB: bodb_OWP

Revisions:
	20200817@Tyler: Init sync SP - [Redmine: #138643]
	20200922@Tyler: Update Prematch issue - [Redmine: #140620]
	
*/

    BEGIN
        SET NOCOUNT ON;
        DECLARE @hdpBettype INT= 1;
        DECLARE @ouBettype INT= 3;
        DECLARE @hdpOldValue NVARCHAR(30);
        DECLARE @ouOldValue NVARCHAR(30);
        DECLARE @hdpTakeOverOldValue NVARCHAR(30);
        DECLARE @ouTakeOverOldValue NVARCHAR(30);
        DECLARE @remarkOldValue NVARCHAR(2000);
        DECLARE @preMatchIssueId INT;

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
              AND a.IsTakeOver = 0;
        SET @hdpOldValue = ISNULL(@hdpOldValue, '');

        SELECT @ouOldValue = u.Username
        FROM dbo.[PreMatchAssignment] AS a WITH(NOLOCK)
             INNER JOIN dbo.[PreMatchLeague] AS l WITH(NOLOCK) ON a.PreMatchLeagueId = l.PreMatchLeagueId
             INNER JOIN dbo.[User] AS u WITH(NOLOCK) ON a.UserId = u.UserId
        WHERE l.PreMatchLeagueId = @PreMatchLeagueId
              AND a.Bettype = @ouBettype
              AND a.IsTakeOver = 0;
        SET @ouOldValue = ISNULL(@ouOldValue, '');

        SELECT @hdpTakeOverOldValue = u.Username
        FROM dbo.[PreMatchAssignment] AS a WITH(NOLOCK)
             INNER JOIN dbo.[PreMatchLeague] AS l WITH(NOLOCK) ON a.PreMatchLeagueId = l.PreMatchLeagueId
             INNER JOIN dbo.[User] AS u WITH(NOLOCK) ON a.UserId = u.UserId
        WHERE l.PreMatchLeagueId = @PreMatchLeagueId
              AND a.Bettype = @hdpBettype
              AND a.IsTakeOver = 1;
        SET @hdpTakeOverOldValue = ISNULL(@hdpTakeOverOldValue, '');

        SELECT @ouTakeOverOldValue = u.Username
        FROM dbo.[PreMatchAssignment] AS a WITH(NOLOCK)
             INNER JOIN dbo.[PreMatchLeague] AS l WITH(NOLOCK) ON a.PreMatchLeagueId = l.PreMatchLeagueId
             INNER JOIN dbo.[User] AS u WITH(NOLOCK) ON a.UserId = u.UserId
        WHERE l.PreMatchLeagueId = @PreMatchLeagueId
              AND a.Bettype = @ouBettype
              AND a.IsTakeOver = 1;
        SET @ouTakeOverOldValue = ISNULL(@ouTakeOverOldValue, '');

        SELECT @preMatchIssueId = i.PreMatchIssueId
        FROM dbo.[PreMatchIssue] AS i WITH(NOLOCK)
             INNER JOIN dbo.[PreMatchLeague] AS l WITH(NOLOCK) ON i.OWPLeagueId = l.OWPLeagueId
        WHERE l.PreMatchLeagueId = @PreMatchLeagueId;

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
    END;