/*<info serverAlias="DBOWP-bodb_OWP" executers="wsv_owp" isFunction="0"></info>*/

CREATE PROCEDURE [dbo].[OWP_ProviderVerification_SaveRemarkBy] @OwpMatchId INT, 
                                                             @RemarkBy    NVARCHAR(2000) = NULL,
                                                             @ActorId    INT
AS

/*
Created: 20250305@Lilac
Task : Provider verification
DB: bodb_OWP

Revisions:
	20250305@Lilac: save remarkBy - [Redmine: #213719]
*/

    BEGIN

		DECLARE @PayloadLog NVARCHAR(1000) = CONCAT(
			'{"OwpMatchId": ', @OwpMatchId, 
			', "CreatorId": ', @ActorId, 
			', "RemarkBy": "', ISNULL(@RemarkBy, 'NULL'), '"}'
		);

		DECLARE @Now DATETIME = DATEADD(HOUR, 12, GETDATE());
       
        IF EXISTS
        (
            SELECT 1
            FROM ProviderVerification p WITH (NOLOCK)
            WHERE p.OWPMatchId = @OwpMatchId
        )
            BEGIN
                UPDATE ProviderVerification WITH(ROWLOCK)
                  SET 
                      RemarkBy = @RemarkBy
                WHERE OWPMatchId = @OwpMatchId;
        END;
            ELSE
            BEGIN
                INSERT INTO ProviderVerification
                (OWPMatchId, 
                 RemarkBy
                )
                VALUES
                (@OwpMatchId, 
                 @RemarkBy
                );
        END;

		EXEC dbo.OWP_InternalSystem_WriteLog 
			@CreatedDate = @Now, 
			@Action = 'ProviderVerification-SaveRemarkBy', 
			@Payload = @PayloadLog
    END;

