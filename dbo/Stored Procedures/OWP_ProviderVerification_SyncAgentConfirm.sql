/*<info serverAlias="DBOWP-bodb_OWP" executers="wsv_owp" isFunction="0"></info>*/

ALTER PROCEDURE [dbo].[OWP_ProviderVerification_SyncAgentConfirm] @AgentConfirms NVARCHAR(MAX)
AS

/*
Created: 20240404@Mira
Task : Provider verification
DB: bodb_OWP

Revisions:
	20240404@Mira: Sync agent confirm - [Redmine: #202819]
	20250321@Lilac.Nguyen: Update Sync agent confirm with data sync Adminsite - [Redmine: #213719]
	20250326@Lilac.Nguyen: fix duplicate insert into table MatchAgentConfirm - [Redmine: #213719]
	20250515@Lilac.Nguyen: change confirm provider rule - [Redmine: #226465]

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
			CASE 
				WHEN i.MatchStatus IN ('Cancel', 'Postponed', 'Suspended') THEN 12	-- Cancel
				WHEN ap.ProviderId = 3 THEN 1    -- 365GV
				WHEN ap.ProviderId = 15 THEN 5   -- IMG
				WHEN ap.ProviderId = 17 THEN 6   -- RB2
				WHEN ap.ProviderId = 18 THEN 8   -- RTS
				WHEN ap.ProviderId = 19 THEN 3   -- BG
				WHEN ap.ProviderId = 20 THEN 2   -- Betradar
				ELSE ap.ProviderId
			END,
			a.AgentId
		) AS AgentId

		FROM #tblAgentConfirm t
		LEFT JOIN AgentOption a WITH(NOLOCK) ON a.AgentName = t.Agent
		LEFT JOIN AdminsiteProviderMatch AS ap WITH(NOLOCK) ON ap.MatchId = t.MatchId
		LEFT JOIN dbo.OWPMatch m WITH(NOLOCK) ON m.OWPMatchId = t.OWPMatchId
        LEFT JOIN dbo.MatchInfo i WITH(NOLOCK) ON m.OWPMatchId = i.OWPMatchId;

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

