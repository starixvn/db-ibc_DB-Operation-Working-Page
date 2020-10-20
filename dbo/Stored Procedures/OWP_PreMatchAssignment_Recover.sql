
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
*/

     SET NOCOUNT ON;
     DECLARE @StartRun DATETIME= GETDATE(), @EndRun DATETIME, @Duration INT, @LogData NVARCHAR(MAX), @Xml XML;
     UPDATE dbo.[PreMatchLeague] WITH(ROWLOCK)
       SET 
           IsDeleted = 0
     WHERE PreMatchLeagueId = @PreMatchLeagueId;

     SET @Xml =
     (
         SELECT @preMatchLeagueId AS '@plid' FOR XML PATH('z'), ROOT('r')
     );

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