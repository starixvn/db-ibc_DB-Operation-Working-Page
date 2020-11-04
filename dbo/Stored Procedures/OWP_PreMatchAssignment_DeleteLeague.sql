
/*<info serverAlias="DBOWP-bodb_OWP" executers="bodbOWPNet" isFunction="0"></info>*/

ALTER PROCEDURE [dbo].[OWP_PreMatchAssignment_DeleteLeague] @ActorId          INT, 
                                                            @PreMatchLeagueId INT
AS

/*
Created: 20200817@Tyler
Task : Delete Pre-Match Assignment
DB: bodb_OWP

Revisions:
	20200817@Tyler: Init sync SP - [Redmine: #138643]
	20201003@Tyler: update other assignments  - [Redmine: #142258]  	
	20201102@Tyler: delete for both Day/Night shift  - [Redmine: #144400]  	
*/

    BEGIN
        SET NOCOUNT ON;
        DECLARE @eventDate DATE, @OWPLeagueId INT, @StartRun DATETIME= GETDATE(), @EndRun DATETIME, @Duration INT, @LogDataOld NVARCHAR(MAX), @Xml XML;
        SELECT @eventDate = EventDate, 
               @OWPLeagueId = OWPLeagueId
        FROM dbo.[PreMatchLeague] WITH(NOLOCK)
        WHERE PreMatchLeagueId = @PreMatchLeagueId;
        IF EXISTS
        (
            SELECT 1
            FROM dbo.[PreMatchLeague] WITH(NOLOCK)
            WHERE PreMatchLeagueId = @PreMatchLeagueId
                  AND IsDeleted = 0
        )
            BEGIN
                UPDATE dbo.[PreMatchLeague] WITH(ROWLOCK)
                  SET 
                      IsDeleted = 1
                WHERE PreMatchLeagueId = @PreMatchLeagueId;

                -- Delete NightShift
                IF NOT EXISTS
                (
                    SELECT 1
                    FROM dbo.PreMatchNightShiftStartTime WITH(NOLOCK)
                    WHERE EventDate = @eventDate
                )
                    BEGIN
                        DECLARE @nightShiftPreMatchLeagueId INT;
                        SELECT @nightShiftPreMatchLeagueId = PreMatchLeagueId
                        FROM dbo.[PreMatchLeague] WITH(NOLOCK)
                        WHERE EventDate = @eventDate
                              AND OWPLeagueId = @OWPLeagueId
                              AND IsDay = 0;

                        UPDATE dbo.[PreMatchLeague] WITH(ROWLOCK)
                          SET 
                              IsDeleted = 1
                        WHERE PreMatchLeagueId = @nightShiftPreMatchLeagueId;

                        SET @Xml = (
                        SELECT @nightShiftPreMatchLeagueId AS '@plid' FOR XML PATH('z'), ROOT('r'));
                        SET @LogDataOld = REPLACE(CONVERT(NVARCHAR(MAX), @Xml), '" />', '"/"');
                        SET @EndRun = GETDATE();
                        SET @Duration = DATEDIFF(MILLISECOND, @StartRun, @EndRun);
                        EXEC dbo.OWP_WriteLog 
                             @CreatorId = @ActorId, 
                             @SPName = 'OWP_PreMatchAssignment_DeleteLeague', 
                             @LoggedDate = @StartRun, 
                             @Duration = @Duration, 
                             @ObjectId = @nightShiftPreMatchLeagueId, 
                             @DataOld = @LogDataOld;
                    END;

                SET @Xml = (
                SELECT @PreMatchLeagueId AS '@plid' FOR XML PATH('z'), ROOT('r'));
                SET @LogDataOld = REPLACE(CONVERT(NVARCHAR(MAX), @Xml), '" />', '"/"');
                SET @EndRun = GETDATE();
                SET @Duration = DATEDIFF(MILLISECOND, @StartRun, @EndRun);
                EXEC dbo.OWP_WriteLog 
                     @CreatorId = @ActorId, 
                     @SPName = 'OWP_PreMatchAssignment_DeleteLeague', 
                     @LoggedDate = @StartRun, 
                     @Duration = @Duration, 
                     @ObjectId = @PreMatchLeagueId, 
                     @DataOld = @LogDataOld;
            END;
    END;