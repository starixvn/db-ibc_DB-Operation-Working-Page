
/*<info serverAlias="DBOWP-bodb_OWP" executers="wsv_owp" isFunction="0"></info>*/

ALTER PROCEDURE [dbo].[OWP_LiveGameAssignment_GetLastUpdated] @EventDate DATE
AS

/*
Created: 20200715@Esther
Task : Last Updated
DB: bodb_OWP

Revisions:	
	20200715@Esther.Nguyen: Show Latest Update Info - [Redmine: #137417]	
*/

     SELECT [UploadDateTime]
     FROM AssignmentUploadHistory
	 WHERE EventDate = @EventDate