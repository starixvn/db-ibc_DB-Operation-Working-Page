/*<info serverAlias="DBOWP-bodb_OWP" executers="wsv_owp" isFunction="0"></info>*/

CREATE PROCEDURE [dbo].[OWP_ProviderVerification_SaveRemark] @OwpMatchId INT, 
                                                             @Remark    NVARCHAR(2000) = NULL,
                                                             @ActorId    INT

AS

/*
Created: 20250305@Lilac
Task : Provider verification
DB: bodb_OWP

Revisions:
	20250305@Lilac: save remark - [Redmine: #213719]
    20250321@Lilac: Update provider main matches by date, add col MatchId - [Redmine: #213719]
*/

    BEGIN
		DECLARE @Now DATETIME = DATEADD(HOUR, 12, GETDATE());
		DECLARE @PayloadLog NVARCHAR(1000) = CONCAT(
			'{"OwpMatchId": ', @OwpMatchId, 
			', "CreatorId": ', @ActorId, 
			', "Remark": "', ISNULL(@Remark, 'NULL'), '"}'
		);


        IF EXISTS
        (
            SELECT 1
            FROM ProviderVerification p WITH (NOLOCK)
            WHERE p.OWPMatchId = @OwpMatchId
        )
            BEGIN
                UPDATE ProviderVerification WITH(ROWLOCK)
                  SET 
                      Remark = @Remark
                WHERE OWPMatchId = @OwpMatchId;
        END;
            ELSE
            BEGIN
                INSERT INTO ProviderVerification
                (OWPMatchId, 
                 Remark
                )
                VALUES
                (@OwpMatchId, 
                 @Remark
                );
        END;

		EXEC dbo.OWP_InternalSystem_WriteLog 
			@CreatedDate = @Now, 
			@Action = 'ProviderVerification-SaveRemark', 
			@Payload = @PayloadLog

    END;
