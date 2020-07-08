
/*<info serverAlias="DBOWP-bodb_OWP" executers="bodbOWPNet" isFunction="0"></info>*/

ALTER PROCEDURE [dbo].[OWP_AssignmentUpload_AllMatcheIdsByDateSel] @EventDate DATE
AS

/*
Created: 20200310@Jacob
Task : Assignment Uploading
DB: bodb_OWP

Revisions:
	20200310@Jacob: New structure of Assignment Uploading - [Redmine: #129397]
	
*/

     SET NOCOUNT ON;
     DECLARE @EventFromDateTime DATETIME= DATEADD(HOUR, 12, CONVERT(DATETIME, @EventDate));
     DECLARE @EventToDateTime DATETIME= DATEADD(HOUR, 36, CONVERT(DATETIME, @EventDate));
  
     -- Result
     SELECT m.[OWPMatchId]
     FROM dbo.OWPMatch m WITH(NOLOCK)
     WHERE m.EventDateTime BETWEEN @EventFromDateTime AND @EventToDateTime;