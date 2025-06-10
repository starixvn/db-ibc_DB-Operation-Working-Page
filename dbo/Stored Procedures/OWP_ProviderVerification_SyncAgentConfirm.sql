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
	20250610@Lilac.Nguyen: change confirm provider rule - [Redmine: #227452]

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

		-- 1. Match is Cancel or (Postponed/Suspended without Provider)
		SELECT DISTINCT
			t.OWPMatchId,
			t.MatchId,
			12 AS AgentId --Cancel
		FROM #tblAgentConfirm t
		LEFT JOIN dbo.OWPMatch m WITH(NOLOCK) ON m.OWPMatchId = t.OWPMatchId
		LEFT JOIN dbo.MatchInfo i WITH(NOLOCK) ON m.OWPMatchId = i.OWPMatchId
		LEFT JOIN AdminsiteProviderMatch ap WITH(NOLOCK) ON ap.MatchId = t.MatchId
		WHERE i.MatchStatus = 'Cancel'
		   OR (i.MatchStatus IN ('Postponed', 'Suspended') AND ap.MatchId IS NULL)

		UNION

		-- 2. ProviderId get from Inhouse Provider
		SELECT DISTINCT
			t.OWPMatchId,
			t.MatchId,
			CASE ap.ProviderId
				WHEN 3 THEN 1     -- 365GV
				WHEN 15 THEN 5    -- IMG
				WHEN 17 THEN 6    -- RB2
				WHEN 18 THEN 8    -- RTS
				WHEN 19 THEN 3    -- BG
				WHEN 20 THEN 2    -- Betradar
				ELSE ap.ProviderId
			END AS AgentId
		FROM #tblAgentConfirm t
		LEFT JOIN AdminsiteProviderMatch ap WITH(NOLOCK) ON ap.MatchId = t.MatchId
		LEFT JOIN dbo.OWPMatch m WITH(NOLOCK) ON m.OWPMatchId = t.OWPMatchId
		LEFT JOIN dbo.MatchInfo i WITH(NOLOCK) ON m.OWPMatchId = i.OWPMatchId
		WHERE i.MatchStatus NOT IN ('Cancel', 'Postponed', 'Suspended')
		  AND ap.ProviderId IS NOT NULL

		UNION

		-- 3. ProviderId get from LST Book Provider
		SELECT DISTINCT
			t.OWPMatchId,
			t.MatchId,
			a.AgentId
		FROM #tblAgentConfirm t
		LEFT JOIN AgentOption a WITH(NOLOCK) ON a.AgentName = t.Agent
		LEFT JOIN dbo.OWPMatch m WITH(NOLOCK) ON m.OWPMatchId = t.OWPMatchId
		LEFT JOIN dbo.MatchInfo i WITH(NOLOCK) ON m.OWPMatchId = i.OWPMatchId
		WHERE i.MatchStatus NOT IN ('Cancel', 'Postponed', 'Suspended')
		  AND a.AgentId IS NOT NULL;

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

