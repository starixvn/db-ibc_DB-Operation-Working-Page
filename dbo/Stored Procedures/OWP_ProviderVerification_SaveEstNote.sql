
/*<info serverAlias="DBOWP-bodb_OWP" executers="wsv_owp" isFunction="0"></info>*/

CREATE PROCEDURE [dbo].[OWP_ProviderVerification_SaveEstNote] @OwpMatchId INT, 
                                                                   @EstNote    NVARCHAR(500) = NULL
AS

/*
Created: 20240404@Liam
Task : Provider verification
DB: bodb_OWP

Revisions:
	20240404@Liam: save est note - [Redmine: #202819]
*/

    BEGIN
        IF EXISTS
        (
            SELECT 1
            FROM ProviderVerification p
            WHERE p.OWPMatchId = @OwpMatchId
        )
            BEGIN
                UPDATE ProviderVerification
                  SET 
                      ESTNote = @EstNote
                WHERE OWPMatchId = @OwpMatchId;
        END;
            ELSE
            BEGIN
                INSERT INTO ProviderVerification
                (OWPMatchId, 
                 ESTNote
                )
                VALUES
                (@OwpMatchId, 
                 @EstNote
                );
        END;
    END;