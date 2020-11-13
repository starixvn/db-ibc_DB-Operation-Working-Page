
/*<info serverAlias="DBOWP-bodb_OWP" executers="bodbOWPNet" isFunction="0"></info>*/

ALTER PROCEDURE [dbo].[OWP_PreMatchAssignment_Recover] @ActorId          INT, 
                                                       @PreMatchLeagueId INT
AS

/*
Created: 20200817@Tyler
Task : Pre-Match Assignment
DB: bodb_OWP

Revisions:
	20200817@Tyler: Init sync SP - [Redmine: #138643]
	20201003@Tyler: update other assignments  - [Redmine: #142258]  	
	20201102@Tyler: recover for both Day/Night shift  - [Redmine: #144400]  	
	20201113@Tyler: fix recover both Day/Night shift  - [Redmine: #144948]  	
*/

    BEGIN
        SET NOCOUNT ON;
        DECLARE @eventDate DATE, @OWPLeagueId INT, @isDayShift BIT, @StartRun DATETIME= GETDATE(), @EndRun DATETIME, @Duration INT, @LogData NVARCHAR(MAX), @Xml XML;
        SELECT @eventDate = EventDate, 
               @OWPLeagueId = OWPLeagueId,
			   @isDayShift = IsDay
        FROM dbo.[PreMatchLeague] WITH(NOLOCK)
        WHERE PreMatchLeagueId = @PreMatchLeagueId;

		--recover
        UPDATE dbo.[PreMatchLeague] WITH(ROWLOCK)
          SET 
              IsDeleted = 0
        WHERE PreMatchLeagueId = @PreMatchLeagueId;

        -- recover Day/NightShift
        IF NOT EXISTS
        (
            SELECT 1
            FROM dbo.PreMatchNightShiftStartTime WITH(NOLOCK)
            WHERE EventDate = @eventDate
        )
            BEGIN
                DECLARE @sameDayShiftPreMatchLeagueId INT;
                SELECT @sameDayShiftPreMatchLeagueId = PreMatchLeagueId
                FROM dbo.[PreMatchLeague] WITH(NOLOCK)
                WHERE EventDate = @eventDate
                      AND OWPLeagueId = @OWPLeagueId
					  AND IsDay <> @isDayShift;

                UPDATE dbo.[PreMatchLeague] WITH(ROWLOCK)
                  SET 
                      IsDeleted = 0
                WHERE PreMatchLeagueId = @sameDayShiftPreMatchLeagueId;

                SET @Xml = (
                SELECT @sameDayShiftPreMatchLeagueId AS '@plid' FOR XML PATH('z'), ROOT('r'));
                SET @LogData = REPLACE(CONVERT(NVARCHAR(MAX), @Xml), '" />', '"/"');
                SET @EndRun = GETDATE();
                SET @Duration = DATEDIFF(MILLISECOND, @StartRun, @EndRun);
                EXEC dbo.OWP_WriteLog 
                     @CreatorId = @ActorId, 
                     @SPName = 'OWP_PreMatchAssignment_Recover', 
                     @LoggedDate = @StartRun, 
                     @Duration = @Duration, 
                     @ObjectId = @sameDayShiftPreMatchLeagueId, 
                     @Data = @LogData;
            END;

        SET @Xml = (
        SELECT @preMatchLeagueId AS '@plid' FOR XML PATH('z'), ROOT('r'));
        SET @LogData = REPLACE(CONVERT(NVARCHAR(MAX), @Xml), '" />', '"/"');
        SET @EndRun = GETDATE();
        SET @Duration = DATEDIFF(MILLISECOND, @StartRun, @EndRun);
        EXEC dbo.OWP_WriteLog 
             @CreatorId = @ActorId, 
             @SPName = 'OWP_PreMatchAssignment_Recover', 
             @LoggedDate = @StartRun, 
             @Duration = @Duration, 
             @ObjectId = @preMatchLeagueId, 
             @Data = @LogData;
    END;