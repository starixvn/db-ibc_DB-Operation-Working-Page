
/*<info serverAlias="DBOWP-bodb_OWP" executers="bodbOWPNet" isFunction="0"></info>*/

ALTER PROCEDURE [dbo].[OWP_AssginmentUpload_MatchesDel] @MatchIds NVARCHAR(MAX)
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

     -- Match			
     DELETE m
     FROM dbo.OWPMatch m
          INNER JOIN @tempMatch t ON m.OWPMatchId = t.MatchId;
     DELETE m
     FROM dbo.MinorMatch m
          INNER JOIN @tempMatch t ON m.MinorMatchId = t.MatchId;
     DELETE m
     FROM dbo.MinorMatch m
          INNER JOIN @tempMatch t ON m.ParentMatchId = t.MatchId;
     DELETE m
     -- Match Info
     FROM MatchInfo m
          INNER JOIN @tempMatch t ON m.OWPMatchId = t.MatchId;
     DELETE m
     -- Others
     FROM dbo.MatchAgent m
          INNER JOIN @tempMatch t ON m.OWPMatchId = t.MatchId;
     DELETE m
     FROM dbo.Assignment m
          INNER JOIN @tempMatch t ON t.MatchId = m.OWPMatchId;
     DELETE m
     FROM MatchNote m
          INNER JOIN @tempMatch t ON m.OWPMatchId = t.MatchId;
     DELETE m
     FROM MatchOfferDetail m
          INNER JOIN @tempMatch t ON m.OWPMatchId = t.MatchId;
     DELETE mm
     FROM MatchOtherProvider mm
          INNER JOIN @tempMatch t ON mm.OWPMatchId = t.MatchId;
     DELETE mm
     FROM MatchProvider mm
          INNER JOIN @tempMatch t ON mm.OWPMatchId = t.MatchId;
     DELETE m
     FROM MatchSetting m
          INNER JOIN @tempMatch t ON m.OWPMatchId = t.MatchId;
     DELETE m
     FROM MatchTelevision m
          INNER JOIN @tempMatch t ON m.OWPMatchId = t.MatchId;