
/*<info serverAlias="DBOWP-bodb_OWP" executers="bodbOWPNet" isFunction="0"></info>*/

CREATE PROCEDURE [dbo].[OWP_PreMatchAssignment_UpdateStartTime] @ActorId   INT, 
                                                               @Date      DATE, 
                                                               @StartTime TIME(7)
AS

/*
Created: 20200817@Tyler
Task : Pre-Match Assignment
DB: bodb_OWP

Revisions:
	20200817@Tyler: Init sync SP - [Redmine: #138643]
	
*/

    BEGIN
        SET NOCOUNT ON;
        DECLARE @StartRun DATETIME= GETDATE(), @EndRun DATETIME, @Duration INT, @LogData NVARCHAR(MAX), @LogDataOld NVARCHAR(MAX), @Xml XML;

        IF EXISTS
        (
            SELECT 1
            FROM dbo.[PreMatchNightShiftStartTime]
            WHERE EventDate = @Date
        )
            BEGIN
                SET @Xml =
                (
                    SELECT EventDate AS '@d', 
                           StartTime AS '@t'
                    FROM dbo.[PreMatchNightShiftStartTime] WITH(ROWLOCK)
                    WHERE EventDate = @Date FOR XML PATH('z'), ROOT('r')
                );
                SET @LogDataOld = REPLACE(CONVERT(NVARCHAR(MAX), @Xml), '" />', '"/"');

                UPDATE dbo.[PreMatchNightShiftStartTime] WITH(ROWLOCK)
                  SET 
                      StartTime = @StartTime
                WHERE EventDate = @Date;

                SET @Xml =
                (
                    SELECT EventDate AS '@d', 
                           StartTime AS '@t'
                    FROM dbo.[PreMatchNightShiftStartTime] WITH(ROWLOCK)
                    WHERE EventDate = @Date FOR XML PATH('z'), ROOT('r')
                );
                SET @LogData = REPLACE(CONVERT(NVARCHAR(MAX), @Xml), '" />', '"/"');
        END;
            ELSE
            BEGIN
                INSERT INTO [dbo].[PreMatchNightShiftStartTime]
                ([EventDate], 
                 [StartTime]
                )
                VALUES
                (@Date, 
                 @StartTime
                );

                SET @Xml =
                (
                    SELECT EventDate AS '@d', 
                           StartTime AS '@t'
                    FROM dbo.[PreMatchNightShiftStartTime] WITH(ROWLOCK)
                    WHERE EventDate = @Date FOR XML PATH('z'), ROOT('r')
                );
                SET @LogData = REPLACE(CONVERT(NVARCHAR(MAX), @Xml), '" />', '"/"');
        END;

        SET @EndRun = GETDATE();
        SET @Duration = DATEDIFF(MILLISECOND, @StartRun, @EndRun);

        EXEC dbo.OWP_WriteLog 
             @CreatorId = @ActorId, 
             @SPName = 'OWP_PreMatchAssignment_UpdateStartTime', 
             @LoggedDate = @StartRun, 
             @Duration = @Duration, 
             @DataOld = @LogDataOld, 
             @Data = @LogData;
    END;