/*<info serverAlias="DBOWP-bodb_OWP" executers="wsv_owp" isFunction="0"></info>*/

ALTER PROCEDURE [dbo].[OWP_ProviderVerification_SyncAgentConfirm] @AgentConfirms NVARCHAR(MAX)
AS

/*
Created: 20240404@Mira
Task : Provider verification
DB: bodb_OWP

Revisions:
	20240404@Mira: Sync agent confirm - [Redmine: #202819]
	20240321@Lilac.Nguyen: Update Sync agent confirm with data sync Adminsite - [Redmine: #213719]
	20240326@Lilac.Nguyen: fix duplicate insert into table MatchAgentConfirm - [Redmine: #213719]

*/

    BEGIN

		DECLARE @Now DATETIME = DATEADD(HOUR, 12, GETDATE());
		DECLARE @LogTable TABLE (LogMessage NVARCHAR(MAX));
		DECLARE @LogString NVARCHAR(MAX) = '';

		CREATE TABLE #tblAgentConfirm (
			OWPMatchId INT,
			MatchId INT, 
			Agent NVARCHAR(255)
		);

		INSERT INTO #tblAgentConfirm
		SELECT DISTINCT OWPMatchId, MatchId, Agent
		FROM OPENJSON(@AgentConfirms) 
		WITH (OWPMatchId INT, MatchId INT, Agent NVARCHAR(255));

		DELETE t WITH(ROWLOCK)
		FROM dbo.MatchAgentConfirm t
		INNER JOIN #tblAgentConfirm a ON t.OWPMatchId = a.OWPMatchId;

		INSERT INTO dbo.MatchAgentConfirm (OWPMatchId, MatchId, AgentId)
			OUTPUT 
				'{ "OWPMatchId": ' + CAST(inserted.OWPMatchId AS NVARCHAR) +
				', "MatchId": ' + CAST(inserted.MatchId AS NVARCHAR) + 
				', "AgentId": ' + COALESCE(CAST(inserted.AgentId AS NVARCHAR), 'NULL') + ' }'
			INTO @LogTable (LogMessage)
		SELECT DISTINCT
			t.OWPMatchId,
			t.MatchId,
			COALESCE(
			CASE ap.ProviderId 
				WHEN 3 THEN 1   -- 365GV
				WHEN 15 THEN 5  -- IMG
				WHEN 17 THEN 6  -- RB2
				WHEN 18 THEN 8  -- RTS
				WHEN 19 THEN 3  -- BG
				WHEN 20 THEN 2  -- Betradar
				ELSE ap.ProviderId
				END, 
				a.AgentId
			) AS AgentId
		FROM #tblAgentConfirm t
		LEFT JOIN AgentOption a WITH(NOLOCK) ON a.AgentName = t.Agent
		LEFT JOIN AdminsiteProviderMatch AS ap WITH(NOLOCK) ON ap.MatchId = t.MatchId;

		SELECT @LogString = 
		'[' + 
		STUFF((SELECT ', ' + '"' + LogMessage + '"' 
			   FROM @LogTable 
			   FOR XML PATH(''), TYPE).value('.', 'NVARCHAR(MAX)'), 1, 2, '') 
		+ ']';

		EXEC dbo.OWP_InternalSystem_WriteLog 
			@CreatedDate = @Now, 
			@Action = 'ProviderVerification-SyncSaveAgentConfirm', 
			@Payload = @LogString;

    DROP TABLE #tblAgentConfirm;
    END;
