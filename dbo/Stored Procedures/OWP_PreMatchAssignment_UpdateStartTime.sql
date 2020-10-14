
/*<info serverAlias="DBOWP-bodb_OWP" executers="bodbOWPNet" isFunction="0"></info>*/

ALTER PROCEDURE [dbo].[OWP_PreMatchAssignment_UpdateStartTime] @ActorId   INT, 
                                                               @Date      DATE, 
                                                               @StartTime TIME(7)
AS

/*
Created: 20200817@Tyler
Task : Pre-Match Assignment
DB: bodb_OWP

Revisions:
	20200817@Tyler: Init sync SP - [Redmine: #138643]
	20201003@Tyler: update other assignments  - [Redmine: #142258]  	
*/

     SET NOCOUNT ON;
     DECLARE @StartRun DATETIME= GETDATE(), @EndRun DATETIME, @Duration INT, @LogData NVARCHAR(MAX), @LogDataOld NVARCHAR(MAX), @Xml XML;
     IF EXISTS
     (
         SELECT 1
         FROM dbo.[PreMatchNightShiftStartTime] WITH(NOLOCK)
         WHERE EventDate = @Date
     )
         BEGIN
             DECLARE @oldStartTime TIME(7);
             SELECT @oldStartTime = StartTime
             FROM dbo.[PreMatchNightShiftStartTime] WITH(NOLOCK)
             WHERE EventDate = @Date;
             IF(@StartTime <> @oldStartTime)
                 BEGIN
                     SET @Xml =
                     (
                         SELECT EventDate AS '@d', 
                                StartTime AS '@t'
                         FROM dbo.[PreMatchNightShiftStartTime] WITH(NOLOCK)
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
                         FROM dbo.[PreMatchNightShiftStartTime] WITH(NOLOCK)
                         WHERE EventDate = @Date FOR XML PATH('z'), ROOT('r')
                     );
                     SET @LogData = REPLACE(CONVERT(NVARCHAR(MAX), @Xml), '" />', '"/"');
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
                 FROM dbo.[PreMatchNightShiftStartTime] WITH(NOLOCK)
                 WHERE EventDate = @Date FOR XML PATH('z'), ROOT('r')
             );
             SET @LogData = REPLACE(CONVERT(NVARCHAR(MAX), @Xml), '" />', '"/"');
             SET @EndRun = GETDATE();
             SET @Duration = DATEDIFF(MILLISECOND, @StartRun, @EndRun);
             EXEC dbo.OWP_WriteLog 
                  @CreatorId = @ActorId, 
                  @SPName = 'OWP_PreMatchAssignment_UpdateStartTime', 
                  @LoggedDate = @StartRun, 
                  @Duration = @Duration, 
                  @Data = @LogData;
         END;