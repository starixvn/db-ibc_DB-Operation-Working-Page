
/*<info serverAlias="DBOWP-bodb_OWP" executers="bodbOWPNet" isFunction="0"></info>*/

ALTER PROCEDURE [dbo].[OWP_AssginmentUpload_MatchAssignmentsDel] @MatchIds NVARCHAR(MAX)
AS

/*
Created: 20200310@Jacob
Task : Assignment Uploading
DB: bodb_OWP

Revisions:
	20200310@Jacob: New structure of Assignment Uploading - [Redmine: #129397]
	
*/

     SET NOCOUNT ON;
     DECLARE @tempMatch TABLE(MatchId INT);
     INSERT INTO @tempMatch
            SELECT DISTINCT 
                   val
            FROM fnc_SplitStrings(@MatchIds, ',') u OPTION(MAXRECURSION 0);

     -- DELETE Assignment
     DELETE ma
     FROM dbo.Assignment ma
          INNER JOIN @tempMatch t ON t.MatchId = ma.OWPMatchId;