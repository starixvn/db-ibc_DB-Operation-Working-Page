
/*<info serverAlias="DBOWP-bodb_OWP" executers="wsv_owp" isFunction="0"></info>*/

ALTER PROCEDURE [dbo].[OWP_AssignmentUpload_UploadHistoryInsertOrUpdate] @EventDate DATE
AS

/*
Created: 20200715@Esther
Task : Last Updated
DB: bodb_OWP

Revisions:	
	20200715@Esther.Nguyen: Show Latest Update Info - [Redmine: #137417]	
*/

     IF EXISTS
     (
         SELECT 1
         FROM AssignmentUploadHistory
         WHERE EventDate = @EventDate
     )
         BEGIN
             UPDATE AssignmentUploadHistory
               SET 
                   [UploadDateTime] = DATEADD(HOUR, 12, CONVERT(DATETIME, GETDATE()))
             WHERE EventDate = @EventDate;
		 END
         ELSE
         BEGIN
             INSERT INTO AssignmentUploadHistory
             (EventDate, 
              [UploadDateTime]
             )
             VALUES
             (@EventDate, 
              DATEADD(HOUR, 12, CONVERT(DATETIME, GETDATE()))
             );
		 END;