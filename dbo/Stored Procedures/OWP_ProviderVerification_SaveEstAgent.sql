
/*<info serverAlias="DBOWP-bodb_OWP" executers="wsv_owp" isFunction="0"></info>*/

ALTER PROCEDURE [dbo].[OWP_ProviderVerification_SaveEstAgent] @OwpMatchId INT, 
                                                              @ActorId    INT, 
                                                              @EstAgent   NVARCHAR(500) = NULL
AS

/*
Created: 20240404@Los
Task : Provider verification
DB: bodb_OWP

Revisions:
	20240404@Los: save est agent - [Redmine: #202819]
*/

    BEGIN
        DECLARE @StartRun DATETIME, @EndRun DATETIME, @Duration INT, @LogDataOld NVARCHAR(MAX), @LogData NVARCHAR(MAX), @Xml XML, @EstAgentOld VARCHAR(500);

        SET @StartRun = GETDATE();
		SELECT @EstAgentOld=m.Agent_EST
		FROM [MatchInfo] AS m WITH (NOLOCK)
		WHERE m.OWPMatchId=@OwpMatchId;

		--Old data
		SET @Xml = (
			SELECT @EstAgentOld AS '@esta'
			FOR XML PATH('z')
				,ROOT('r')
			)
	SET @LogDataOld = REPLACE(CONVERT(NVARCHAR(MAX), @Xml), '" />', '"/"')

        UPDATE MatchInfo
          SET 
              Agent_EST = @EstAgent
        WHERE OWPMatchId = @OwpMatchId;

		--New data
		SET @Xml = (
			SELECT @EstAgent AS '@esta'
			FOR XML PATH('z')
				,ROOT('r')
			)

		SET @LogData = REPLACE(CONVERT(NVARCHAR(MAX), @Xml), '" />', '"/"')
        SET @EndRun = GETDATE();
        SET @Duration = DATEDIFF(MILLISECOND, @StartRun, @EndRun);
        EXEC dbo.OWP_WriteLog 
             @CreatorId = @ActorId, 
             @SPName = 'OWP_ProviderVerification_SaveEstAgent', 
             @LoggedDate = @StartRun, 
             @Duration = @Duration, 
             @ObjectId = @ActorId, 
             @Data = @LogData, 
             @DataOld = @LogDataOld;;
    END;