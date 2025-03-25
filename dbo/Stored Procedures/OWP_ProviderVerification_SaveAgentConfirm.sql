
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
*/

    BEGIN
		DECLARE @Now DATETIME = DATEADD(HOUR, 12, GETDATE());
		DECLARE @LogTable TABLE (LogMessage NVARCHAR(MAX));
		DECLARE @LogString NVARCHAR(MAX) = '';
       
        IF EXISTS
        (
            SELECT 1
            FROM ProviderVerification p
            WHERE p.OWPMatchId = @OwpMatchId
        )
            BEGIN
                UPDATE ProviderVerification
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
        DELETE FROM MatchAgentConfirm
        WHERE OWPMatchId = @OwpMatchId;

        --- insert current confirm
		
	    INSERT INTO MatchAgentConfirm (OWPMatchId, AgentId)
			OUTPUT 
				'{ "OWPMatchId": ' + CAST(inserted.OWPMatchId AS NVARCHAR) +
				', "AgentId": ' + COALESCE(CAST(inserted.AgentId AS NVARCHAR), '"NULL"') + ' }'
			INTO @LogTable (LogMessage)
		SELECT @OwpMatchId, 
                value
        FROM STRING_SPLIT(@AgentSelected, ',');

		SELECT @LogString = 
			'{ "CreatorId": ' + CAST(@ActorId AS NVARCHAR) + ', "Data": ' +
			CASE 
				WHEN COUNT(*) = 0 THEN '[]' 
				ELSE '[' + STRING_AGG(LogMessage, ', ') + ']' 
			END + '}'
		FROM @LogTable;


		EXEC dbo.OWP_InternalSystem_WriteLog 
		@CreatedDate = @Now, 
		@Action = 'ProviderVerification-SaveAgentConfirm', 
		@Payload = @LogString;

       
    END;
