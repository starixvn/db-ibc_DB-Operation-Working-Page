
/*<info serverAlias="DBOWP-bodb_OWP" executers="wsv_owp" isFunction="0"></info>*/
ALTER PROCEDURE [dbo].[OWP_ProviderVerification_SaveAgentConfirm] @OwpMatchId    INT, 
                                                                  @ActorId       INT, 
                                                                  @AgentSelected NVARCHAR(255) = NULL
AS

/*
Created: 20240404@Liam
Task : Provider verification
DB: bodb_OWP

Revisions:
	20240404@Liam: save agent confirm - [Redmine: #202819]
	20250321@Lilac: write log save agent confirm - [Redmine: #213719]
	20250515@Lilac: refactor write log save agent confirm - [Redmine: #213719]
*/

    BEGIN
		DECLARE @Now DATETIME = DATEADD(HOUR, 12, GETDATE());
		DECLARE @LogString NVARCHAR(MAX) = '';
		DECLARE @AgentIdTable TABLE (AgentId INT);
       
        IF EXISTS
        (
            SELECT 1
            FROM ProviderVerification p
            WHERE p.OWPMatchId = @OwpMatchId
        )
            BEGIN
                UPDATE ProviderVerification WITH(ROWLOCK)
                  SET 
                      IsConfirmManual = 1
                WHERE OWPMatchId = @OwpMatchId;
        END;
            ELSE
            BEGIN
                INSERT INTO ProviderVerification
                (OWPMatchId, 
                 IsConfirmManual
                )
                VALUES
                (@OwpMatchId, 
                 1
                );
        END;

        --- delete previous confirm
        DELETE FROM MatchAgentConfirm WITH(ROWLOCK)
        WHERE OWPMatchId = @OwpMatchId;

        --- insert current confirm
		
	    INSERT INTO MatchAgentConfirm (OWPMatchId, AgentId)
		SELECT @OwpMatchId, 
                value
        FROM STRING_SPLIT(@AgentSelected, ',');

		 DECLARE @TrimmedAgent NVARCHAR(255) = LTRIM(RTRIM(@AgentSelected));

		IF @TrimmedAgent IS NULL OR @TrimmedAgent = ''
		BEGIN
			INSERT INTO @AgentIdTable (AgentId)
			VALUES (NULL);
		END
		ELSE
		BEGIN
			-- Insert valid agent IDs
			INSERT INTO @AgentIdTable (AgentId)
			SELECT TRY_CAST(value AS INT)
			FROM STRING_SPLIT(@TrimmedAgent, ',')
			WHERE TRY_CAST(value AS INT) IS NOT NULL;
		END


		SELECT @LogString = 
			'{ "CreatorId": ' + CAST(@ActorId AS NVARCHAR) + ', "Data": ' +
			ISNULL('[' + STRING_AGG(
				'{ "OWPMatchId": ' + CAST(@OwpMatchId AS NVARCHAR) +
				', "AgentId": ' + 
					CASE 
						WHEN AgentId IS NULL THEN 'null' 
						ELSE CAST(AgentId AS NVARCHAR) 
					END +
				' }', ', '), '[]') +
			'}'
		FROM @AgentIdTable;

		EXEC dbo.OWP_InternalSystem_WriteLog 
		@CreatedDate = @Now, 
		@Action = 'ProviderVerification-SaveAgentConfirm', 
		@Payload = @LogString;

       
    END;


