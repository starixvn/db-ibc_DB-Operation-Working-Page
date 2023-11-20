
/*<info serverAlias="DBOWP-bodb_OWP" executers="bodbOWPNet" isFunction="0"></info>*/

CREATE PROCEDURE [dbo].[OWP_LiveGame_GetLastUpdatedSyncOffVR] @EventDate DATE
AS

/*
Created: 20231117@Mira
Task : Sync off VR
DB: bodb_OWP

Revisions:
	20231117@Mira: get log action sync off vr - [Redmine: #195697]	
*/

     SELECT SyncDateTime, 
            u.Username
     FROM SyncOffVRHistory s WITH(NOLOCK)
          INNER JOIN dbo.[User] u WITH(NOLOCK) ON u.UserId = s.CreatedBy
     WHERE EventDate = @EventDate;