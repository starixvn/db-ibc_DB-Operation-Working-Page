
/*<info serverAlias="DBOWP-bodb_OWP" executers="bodbOWPNet" isFunction="0"></info>*/

ALTER PROCEDURE [dbo].[OWP_PreMatchAssignment_UpdateRemark] @ActorId          INT, 
                                                            @PreMatchLeagueId INT, 
                                                            @Remark           NVARCHAR(2000) = ''
AS

/*
Created: 20200817@Tyler
Task : Pre-Match Assignment
DB: bodb_OWP

Revisions:
	20200817@Tyler: Init sync SP - [Redmine: #138643]
	20200914@Tyler: Update select with nolock - [Redmine: #138643]
	20201003@Tyler: update other assignments  - [Redmine: #142258]  	
*/

     SET NOCOUNT ON;
     DECLARE @remarkOldValue NVARCHAR(2000);
     SELECT @remarkOldValue = Remark
     FROM dbo.[PreMatchLeague] WITH(NOLOCK)
     WHERE PreMatchLeagueId = @PreMatchLeagueId;
     SET @remarkOldValue = ISNULL(@remarkOldValue, '');
     IF(@remarkOldValue <> @Remark)
         BEGIN
             DECLARE @StartRun DATETIME= GETDATE(), @EndRun DATETIME, @Duration INT, @LogData NVARCHAR(MAX), @LogDataOld NVARCHAR(MAX), @Xml XML;
             SET @Xml =
             (
                 SELECT PreMatchLeagueId AS '@plid', 
                        @remarkOldValue AS '@rm'
                 FROM dbo.[PreMatchLeague] WITH(NOLOCK)
                 WHERE PreMatchLeagueId = @PreMatchLeagueId FOR XML PATH('z'), ROOT('r')
             );
             SET @LogDataOld = REPLACE(CONVERT(NVARCHAR(MAX), @Xml), '" />', '"/"');
             UPDATE dbo.[PreMatchLeague] WITH(ROWLOCK)
               SET 
                   Remark = @Remark
             WHERE PreMatchLeagueId = @PreMatchLeagueId;

             SET @Xml =
             (
                 SELECT PreMatchLeagueId AS '@plid', 
                        Remark AS '@rm'
                 FROM dbo.[PreMatchLeague] WITH(NOLOCK)
                 WHERE PreMatchLeagueId = @PreMatchLeagueId FOR XML PATH('z'), ROOT('r')
             );

             SET @LogData = REPLACE(CONVERT(NVARCHAR(MAX), @Xml), '" />', '"/"');
             SET @EndRun = GETDATE();
             SET @Duration = DATEDIFF(MILLISECOND, @StartRun, @EndRun);
             EXEC dbo.OWP_WriteLog 
                  @CreatorId = @ActorId, 
                  @SPName = 'OWP_PreMatchAssignment_UpdateRemark', 
                  @LoggedDate = @StartRun, 
                  @Duration = @Duration, 
                  @ObjectId = @preMatchLeagueId, 
                  @DataOld = @LogDataOld, 
                  @Data = @LogData;
         END;