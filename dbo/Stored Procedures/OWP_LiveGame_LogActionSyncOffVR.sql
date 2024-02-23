
/*<info serverAlias="DBOWP-bodb_OWP" executers="bodbOWPNet" isFunction="0"></info>*/

ALTER PROCEDURE [dbo].[OWP_LiveGame_LogActionSyncOffVR] @EventDate DATE, 
                                                        @ActorId   INT, 
                                                        @SyncTime  DATETIME
AS

/*
Created: 20231117@Mira
Task : Sync off VR
DB: bodb_OWP

Revisions:
	20231117@Mira: Log action sync off vr - [Redmine: #195697]	
	20231226@Mira: get matches by new condition - [Redmine: #197659]
*/

    BEGIN
        SET NOCOUNT ON;
        IF EXISTS
        (
            SELECT 1
            FROM SyncOffVRHistory WITH(NOLOCK)
            WHERE EventDate = @EventDate
        )
            BEGIN
                UPDATE SyncOffVRHistory
                  SET 
                      SyncDateTime = @SyncTime, 
                      CreatedBy = @ActorId
                WHERE EventDate = @EventDate;
        END;
            ELSE
            BEGIN
                INSERT INTO SyncOffVRHistory
                (EventDate, 
                 SyncDateTime, 
                 CreatedBy
                )
                VALUES
                (@EventDate, 
                 @SyncTime, 
                 @ActorId
                );
        END;
    END;